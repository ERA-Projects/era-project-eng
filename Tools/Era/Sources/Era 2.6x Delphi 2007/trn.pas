unit Trn;
(* Author:      EtherniDee aka Berserker
   Description: Light-weight non-unicode internationalization support *)

(*
Language file format (extended ini)
===================================
encoding: ansi, #0 not used
===================================
any_char             = #1..#255
blank                = #1..#32
line_end             = #10
comment_marker       = ';'
section_header_start = '['
section_header_end   = ']'
key_value_separator  = '='
string_marker        = '"'

inline_blank   = blank - line_end;
inline_char    = any_char - line_end
instring_char  = any_char - string_marker
comment        = comment_marker {inline_char} [line_end]
garbage        = (blank | comment) {blank | comment}
g              = garbage
special_char   = section_header_start | section_header_end | key_value_separator | comment_marker
ident_char     = inline_char - special_char
ident          = ident_char {ident_char}
item_value     = {inline_blank}
                 (
                   {ident_char - string_marker} |
                   (string_marker {instring_char | string_marker string_marker} string_marker)
                 )
item_key       = ident_char
item           = item_key key_value_separator item_value
section_body   = item {[g] item}
section header = section_header_start {ident_char} section_header_end
section        = section_header [g] [section_body]
main           = {[g] section}
*)

interface
uses Utils;

const
  NO_LANG          = '';
  CURRENT_LANG     = 'current';
  DEFAULT_LANG_DIR = 'Language';
  TEMPLATE_CHAR    = '`';
  LANG_FILE_EXT    = 'ini';

type
  TMissingTranslHandler = procedure (const aKey, aSection, aLang: string) of object;
  TParseErrorHandler    = procedure (const Err: string) of object;

  ALangMan = class abstract
   protected
    function  GetLangDir: string;                                      virtual; abstract;
    procedure SetLangDir (const aLangDir: string);                     virtual; abstract;
    function  GetLangAutoload: boolean;                                virtual; abstract;
    procedure SetLangAutoload (aLangAutoload: boolean);                virtual; abstract;
    function  GetMainLang: string;                                     virtual; abstract;
    procedure SetMainLang (const aMainLang: string);                   virtual; abstract;
    function  GetReservLang: string;                                   virtual; abstract;
    procedure SetReservLang (const aReservLang: string);               virtual; abstract;
    function  GetOnMissingTranslation: {n} TMissingTranslHandler;      virtual; abstract;
    procedure SetOnMissingTranslation ({n} aMissingTranslHandler: TMissingTranslHandler);
                                                                       virtual; abstract;
    function  GetOnParseError: {n} TParseErrorHandler;                 virtual; abstract;
    procedure SetOnParseError ({n} aOnParseError: TParseErrorHandler); virtual; abstract;
    
   public
    (* !IsValidLang(aLang) *)
    function  LoadLangData (const aLang, aLangData, aDataSource: string): boolean;
                                                                       virtual; abstract;
    procedure UnloadLang (const aLang: string);                        virtual; abstract;
    procedure UnloadAllLangs;                                          virtual; abstract;
    function  Translate (const aKey, aSection: string; aLang: string; var Res: string): boolean;
                                                                       virtual; abstract;
    (* Returns aKey if no translation is found and calls OnMissingTranslation, if it is set *)
    function  tr (const aKey, aSection: string; aLang: string = CURRENT_LANG)
                  : string; overload;                                  virtual; abstract;
    (* Combines tr and StrLib.BuildStr. uses current language and TEMPLATE_CHAR *)
    function  tr (const aKey, aSection: string; aTemplArgs: array of string): string; overload;

    property LangDir:      string read GetLangDir write SetLangDir;
    property LangAutoload: boolean read GetLangAutoload write SetLangAutoload;
    property MainLang:     string read GetMainLang write SetMainLang;
    property ReservLang:   string read GetReservLang write SetReservLang;
    property OnMissingTranslation: {n} TMissingTranslHandler read GetOnMissingTranslation
                                                             write SetOnMissingTranslation;
    property OnParseError: {n} TParseErrorHandler read GetOnParseError write SetOnParseError;
  end; // .class ALangMan

(* Valid language name is: ('a'..'z' | 'A'..'Z' | '0'..'9' | '_') * 1..64 *)
function  IsValidLang (const aLang: string): boolean;

(* === Wrappers to access currently installed language manager in a thread-safe way === *)
function  GetLangDir: string;
procedure SetLangDir (const aLangDir: string);
function  GetLangAutoload: boolean;
procedure SetLangAutoload (aLangAutoload: boolean);
function  GetMainLang: string;
procedure SetMainLang (const aMainLang: string);
function  GetReservLang: string;
procedure SetReservLang (const aReservLang: string);
function  GetOnMissingTranslation: {n} TMissingTranslHandler;
procedure SetOnMissingTranslation ({n} aMissingTranslHandler: TMissingTranslHandler);
function  GetOnParseError: {n} TParseErrorHandler;
procedure SetOnParseError ({n} aOnParseError: TParseErrorHandler);  
function  LoadLangData (const aLang, aLangData, aDataSource: string): boolean;
procedure UnloadLang (const aLang: string);
procedure UnloadAllLangs;
function  Translate (const aKey, aSection: string; aLang: string; var Res: string): boolean;
function  tr (const aKey, aSection: string; aLang: string = CURRENT_LANG): string; overload;
function  tr (const aKey, aSection: string; aTemplArgs: array of string): string; overload;

(* Returns previously installed manager *)
function  InstallLangMan ({?} NewLangMan: ALangMan): {?} ALangMan;

implementation
uses SysUtils, DataLib, Files, TextScan, TypeWrappers, StrLib, Concur;

const
  ANY_CHARS      = [#1..#255];
  LINE_END       = #10;
  BLANKS         = [#1..#32];
  COMMENT_MARKER = ';';
  INLINE_CHARS   = ANY_CHARS - [LINE_END];

  SECTION_HEADER_START = '[';
  SECTION_HEADER_END   = ']';
  KEY_VALUE_SEPARATOR  = '=';
  SPECIAL_CHARS        = [SECTION_HEADER_START, SECTION_HEADER_END, COMMENT_MARKER,
                          KEY_VALUE_SEPARATOR];
  IDENT_CHARS          = INLINE_CHARS - SPECIAL_CHARS;
  STRING_MARKER        = '"';
  INSTRING_CHARS       = ANY_CHARS - [STRING_MARKER];
  GARBAGE_CHARS        = BLANKS + [COMMENT_MARKER];
  INLINE_BLANKS        = BLANKS - [LINE_END];


type
  (* import *)
  TDict   = DataLib.TDict;
  TString = TypeWrappers.TString;

  TLangMan = class (ALangMan)
   private
    {O} fLangs:                {O} TDict (* of {O} Sections of {O} Strings *);
    {O} fLangIsLoaded:         {U} TDict {of Ptr(1)};
    {O} fScanner:              TextScan.TTextScanner;
        fLangDir:              string;
        fLangAutoload:         boolean;
        fMainLang:             string;
        fReservLang:           string;
        fDataSourceForParsing: string;
    {n} fOnMissingTranslation: TMissingTranslHandler;
    {n} fOnParseError:         TParseErrorHandler;

    procedure ParsingError (const Err: string);
    function  SkipGarbage: boolean;
    function  ParseChar (c: char): boolean;
    function  ParseToken (const Charset: Utils.TCharset; const lngTokenName: string;
                          var Token: string): boolean;
    function  ParseSectionHeader (Sections: TDict; out Section: TDict): boolean;
    function  ParseString (var Str: string): boolean;
    function  ParseItem (Section: TDict): boolean;
    function  ParseSectionBody (Section: TDict): boolean;
    function  ParseSection (Sections: TDict): boolean;
    function  ParseLangData (const aLang: string): boolean;

    procedure LoadLang (const aLang: string);
    (* Does not try using ReservLang on fail as opposed to Translate *)
    function  TranslateIntoLang (const aKey, aSection, aLang: string; var Res: string): boolean;

   public
    constructor Create;
    destructor  Destroy; override;

    function  GetLangDir: string;                                      override;
    procedure SetLangDir (const aLangDir: string);                     override;
    function  GetLangAutoload: boolean;                                override;
    procedure SetLangAutoload (aLangAutoload: boolean);                override;
    function  GetMainLang: string;                                     override;
    procedure SetMainLang (const aMainLang: string);                   override;
    function  GetReservLang: string;                                   override;
    procedure SetReservLang (const aReservLang: string);               override;
    function  GetOnMissingTranslation: {n} TMissingTranslHandler;      override;
    procedure SetOnMissingTranslation ({n} aMissingTranslHandler: TMissingTranslHandler);
                                                                       override;
    function  GetOnParseError: {n} TParseErrorHandler;                 override;
    procedure SetOnParseError ({n} aOnParseError: TParseErrorHandler); override;
    function  LoadLangData (const aLang, aLangData, aDataSource: string): boolean;
                                                                       override;
    procedure UnloadLang (const aLang: string);                        override;
    procedure UnloadAllLangs;                                          override;
    function  Translate (const aKey, aSection: string; aLang: string; var Res: string): boolean;
                                                                       override;
    function  tr (const aKey, aSection: string; aLang: string = CURRENT_LANG): string;
                                                                       override;
  end; // .class TLangMan

var
{?} LangMan: ALangMan;
    Lock:    Concur.TCritSection;

function IsValidLang (const aLang: string): boolean;
var
  i: integer;

begin
  result := (Length(aLang) >= 1) and (Length(aLang) <= 64);
  i      := 1;

  while ((i < Length(aLang)) and result) do begin
    result := aLang[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_'];
    Inc(i);
  end; // .while
end; // .function IsValidLang

function ALangMan.tr (const aKey, aSection: string; aTemplArgs: array of string): string;
begin
  result := StrLib.BuildStr(tr(aKey, aSection, CURRENT_LANG), aTemplArgs, TEMPLATE_CHAR);
end; // .function ALangMan.tr

constructor TLangMan.Create;
begin
  fLangs                := DataLib.NewDict(Utils.OWNS_ITEMS, not DataLib.CASE_SENSITIVE);
  fLangIsLoaded         := DataLib.NewDict(not Utils.OWNS_ITEMS, not DataLib.CASE_SENSITIVE);
  fScanner              := TextScan.TTextScanner.Create;
  fLangDir              := DEFAULT_LANG_DIR;
  fLangAutoload         := true;
  fMainLang             := NO_LANG;
  fReservLang           := NO_LANG;
  fDataSourceForParsing := '';
  fOnMissingTranslation := nil;
  fOnParseError         := nil;
end; // .constructor TLangMan.Create

destructor TLangMan.Destroy;
begin
  SysUtils.FreeAndNil(fLangs);
  SysUtils.FreeAndNil(fLangIsLoaded);
  SysUtils.FreeAndNil(fScanner);
end; // .destructor TLangMan.Destroy

function TLangMan.GetLangDir: string;
begin
  result := fLangDir;
end; // .function TLangMan.GetLangDir

procedure TLangMan.SetLangDir (const aLangDir: string);
begin
  fLangDir := aLangDir;
end; // .procedure TLangMan.SetLangDir

function TLangMan.GetLangAutoload: boolean;
begin
  result := fLangAutoload;
end; // .function TLangMan.GetLangAutoload

procedure TLangMan.SetLangAutoload (aLangAutoload: boolean);
begin
  fLangAutoload := aLangAutoload;
end; // .procedure TLangMan.SetLangAutoload

function TLangMan.GetMainLang: string;
begin
  result := fMainLang;
end; // .function TLangMan.GetMainLang

procedure TLangMan.SetMainLang (const aMainLang: string);
begin
  fMainLang := aMainLang;
end; // .procedure TLangMan.SetMainLang

function TLangMan.GetReservLang: string;
begin
  result := fReservLang;
end; // .function TLangMan.GetReservLang

procedure TLangMan.SetReservLang (const aReservLang: string);
begin
  fReservLang := aReservLang;
end; // .procedure TLangMan.SetReservLang

function TLangMan.GetOnMissingTranslation: {n} TMissingTranslHandler;
begin
  result := fOnMissingTranslation;
end; // .function TLangMan.GetOnMissingTranslation

procedure TLangMan.SetOnMissingTranslation ({n} aMissingTranslHandler: TMissingTranslHandler);
begin
  fOnMissingTranslation := aMissingTranslHandler;
end; // .procedure TLangMan.SetOnMissingTranslation

function TLangMan.GetOnParseError: {b} TParseErrorHandler;
begin
  result := fOnParseError;
end; // .function TLangMan.GetOnParseError

procedure TLangMan.SetOnParseError ({n} aOnParseError: TParseErrorHandler);
begin
  fOnParseError := aOnParseError;
end; // .procedure TLangMan.SetOnParseError

procedure TLangMan.ParsingError (const Err: string);
begin
  if Assigned(fOnParseError) then begin
    fOnParseError(tr('Trn.Parsing error', '2b', ['error', Err, 'source', fDataSourceForParsing,
                                                 'line', IntToStr(fScanner.LineN),
                                                 'pos', IntToStr(fScanner.Pos)]));
  end;
end; // .procedure TLangMan.ParsingError

function TLangMan.SkipGarbage: boolean;
begin
  while fScanner.c in GARBAGE_CHARS do begin
    if fScanner.c = COMMENT_MARKER then begin
      fScanner.GotoNextLine;
    end else begin
      fScanner.SkipCharset(BLANKS);
    end; // ,else
  end;

  result := not fScanner.Eot;
end; // .function TLangMan.SkipGarbage

function TLangMan.ParseChar (c: char): boolean;
begin
  result := fScanner.c = c;
  
  if result then begin
    fScanner.GotoNextChar;
  end else begin
    ParsingError(tr('Trn.char x expected', '2b', ['char', c]));
  end; // .if
end; // .function TLangMan.ParseChar

function TLangMan.ParseToken (const Charset: Utils.TCharset; const lngTokenName: string;
                              var Token: string): boolean;
begin
  result := fScanner.ReadToken(Charset, Token);

  if not result then begin
    ParsingError(tr('Trn.Token x expected', '2b', ['token', tr(lngTokenName, '2b')]));
  end; // .if
end; // .function TLangMan.ParseToken

function TLangMan.ParseSectionHeader (Sections: TDict; out Section: TDict): boolean;
var
{U} NewSection:  TDict;
    SectionName: string;

begin
  {!} Assert(Sections <> nil);
  {!} Assert(Section = nil);
  NewSection := nil;
  // * * * * * //
  result := ParseChar(SECTION_HEADER_START)                          and
            ParseToken(IDENT_CHARS, 'Trn.section name', SectionName) and
            ParseChar(SECTION_HEADER_END);

  if result then begin
    NewSection := Sections[SectionName];

    if NewSection = nil then begin
      NewSection            := DataLib.NewDict(Utils.OWNS_ITEMS, not DataLib.CASE_SENSITIVE);
      Sections[SectionName] := NewSection;
    end; // .if
    
    Section := NewSection;
  end; // .if
end; // .function TLangMan.ParseSectionHeader

function TLangMan.ParseString (var Str: string): boolean;
var
  StartPos:         integer;
  NeedsPostProcess: boolean;

begin
  result := true;
  fScanner.SkipCharset(INLINE_BLANKS);

  if fScanner.c = STRING_MARKER then begin
    fScanner.GotoNextChar;
    StartPos         := fScanner.Pos;
    NeedsPostProcess := false;

    while fScanner.SkipCharset(INSTRING_CHARS) and (fScanner.c = STRING_MARKER) and
          (fScanner.CharsRel[+1] = STRING_MARKER)
    do begin
      NeedsPostProcess := true;
      fScanner.GotoRelPos(+2);
    end; // .while

    result := not fScanner.Eot;

    if not result then begin
      ParsingError(Tr('Trn.Closing quote expected', '2b'));
    end else begin
      Str := fScanner.GetSubstrAtPos(StartPos, fScanner.Pos - StartPos);
      fScanner.GotoNextChar;

      if NeedsPostProcess then begin
        Str := SysUtils.StringReplace(Str, STRING_MARKER + STRING_MARKER, STRING_MARKER,
                                      [rfReplaceAll]);
      end; // .if
    end; // .else
  end else if not fScanner.Eot then begin
    fScanner.ReadToken(IDENT_CHARS, Str);
    Str := SysUtils.TrimRight(Str);
  end else begin
    Str := '';
  end; // .else
end; // .function TLangMan.ParseString

function TLangMan.ParseItem (Section: TDict): boolean;
var
  ItemKey:   string;
  ItemValue: string;

begin
  {!} Assert(Section <> nil);
  result := ParseToken(IDENT_CHARS, 'Trn.item key', ItemKey) and
            ParseChar(KEY_VALUE_SEPARATOR)                   and
            ParseString(ItemValue);

  if result then begin
    ItemKey := SysUtils.TrimRight(ItemKey);

    if Section[ItemKey] = nil then begin
      Section[ItemKey] := TString.Create(ItemValue);
    end; // .if
  end; // .if
end; // .function TLangMan.ParseItem

function TLangMan.ParseSectionBody (Section: TDict): boolean;
begin
  result := ParseItem(Section);

  while result and SkipGarbage and (fScanner.c in IDENT_CHARS) do begin
    result := ParseItem(Section);
  end; // .while
end; // .function TLangMan.ParseSectionBody

function TLangMan.ParseSection (Sections: TDict): boolean;
var
{U} Section: TDict;

begin
  Section := nil;
  // * * * * * //
  result := ParseSectionHeader(Sections, Section);

  if result and SkipGarbage and (fScanner.c in IDENT_CHARS) then begin
    result := ParseSectionBody(Section);
  end; // .if
end; // .function TLangMan.ParseSection

function TLangMan.ParseLangData (const aLang: string): boolean;
var
{U} Sections: TDict;

begin
  Sections := fLangs[aLang];
  // * * * * * //
  if Sections = nil then begin
    Sections      := DataLib.NewDict(Utils.OWNS_ITEMS, not DataLib.CASE_SENSITIVE);
    fLangs[aLang] := Sections;
  end;

  result := true;

  while result and SkipGarbage do begin
    result := ParseSection(Sections);
  end;
end; // .function TLangMan.ParseLangData

function TLangMan.LoadLangData (const aLang, aLangData, aDataSource: string): boolean;
begin
  {!} Assert(IsValidLang(aLang));
  fScanner.Connect(aLangData, LINE_END);
  fDataSourceForParsing := aDataSource;
  result                := ParseLangData(aLang);
end; // .function TLangMan.LoadLangData

procedure TLangMan.UnloadLang (const aLang: string);
begin
  fLangs.DeleteItem(aLang);
  fLangIsLoaded.DeleteItem(aLang);
end; // .procedure TLangMan.UnloadLang

procedure TLangMan.UnloadAllLangs;
begin
  fLangs.Clear;
  fLangIsLoaded.Clear;
end; // .procedure TLangMan.UnloadAllLangs

procedure TLangMan.LoadLang (const aLang: string);
var
  LangDirPath:      string;
  LangFilePath:     string;
  LangFileContents: string;

begin
  if fLangIsLoaded[aLang] = nil then begin
    fLangIsLoaded[aLang] := Ptr(1);
    LangDirPath          := fLangDir + '\' + aLang + '\';

    with Files.Locate(LangDirPath + '*.' + LANG_FILE_EXT, Files.ONLY_FILES) do begin
      while FindNext do begin
        LangFilePath := LangDirPath + FoundName;

        if Files.ReadFileContents(LangFilePath, LangFileContents) then begin
          LoadLangData(aLang, LangFileContents, LangFilePath);
        end; // .if
      end; // .while
    end; // .with
  end; // .if
end; // .procedure TLangMan.LoadLang

function TLangMan.TranslateIntoLang (const aKey, aSection, aLang: string; var Res: string)
                                     : boolean;
var
{U} Sections: {O} TDict {of Section};
{U} Section:  {O} TDict {of TString};
{U} Str:      TString;

begin
  Sections := fLangs[aLang];
  Section  := nil;
  Str      := nil;
  // * * * * * //
  result := false;

  if aLang <> NO_LANG then begin
    if (Sections = nil) and fLangAutoload then begin
      LoadLang(aLang);
      Sections := fLangs[aLang];
    end;

    if Sections <> nil then begin
      Section := Sections[aSection];

      if Section <> nil then begin
        Str := Section[aKey];

        if Str <> nil then begin
          result := true;
          Res    := Str.Value;
        end;
      end;
    end;
  end;
end; // .function TLangMan.TranslateIntoLang

function TLangMan.Translate (const aKey, aSection: string; aLang: string; var Res: string): boolean;
begin
  if aLang = CURRENT_LANG then begin
    aLang := fMainLang;
  end;

  result := TranslateIntoLang(aKey, aSection, aLang, Res) or
            TranslateIntoLang(aKey, aSection, fReservLang, Res);
end; // .function TLangMan.Translate

function TLangMan.tr (const aKey, aSection: string; aLang: string = CURRENT_LANG): string;
begin
  result := aKey;

  if not Translate(aKey, aSection, aLang, result) and Assigned(fOnMissingTranslation) then begin
    fOnMissingTranslation(aKey, aSection, aLang);
  end;
end; // .function TLangMan.tr

function GetLangDir: string;
begin
  Lock.Enter; result := LangMan.LangDir; Lock.Leave;
end; // .function GetLangDir

procedure SetLangDir (const aLangDir: string);
begin
  Lock.Enter; LangMan.LangDir := aLangDir; Lock.Leave;
end; // .procedure SetLangDir

function GetLangAutoload: boolean;
begin
  Lock.Enter; result := LangMan.LangAutoload; Lock.Leave;
end; // .function GetLangAutoload

procedure SetLangAutoload (aLangAutoload: boolean);
begin
  Lock.Enter; LangMan.LangAutoload := aLangAutoload; Lock.Leave;
end; // .procedure SetLangAutoload

function GetMainLang: string;
begin
  Lock.Enter; result := LangMan.MainLang; Lock.Leave;
end; // .function GetMainLang

procedure SetMainLang (const aMainLang: string);
begin
  Lock.Enter; LangMan.MainLang := aMainLang; Lock.Leave;
end; // .procedure SetMainLang

function GetReservLang: string;
begin
  Lock.Enter; result := LangMan.ReservLang; Lock.Leave;
end; // .function GetReservLang

procedure SetReservLang (const aReservLang: string);
begin
  Lock.Enter; LangMan.ReservLang := aReservLang; Lock.Leave;
end; // .procedure SetReservLang

function GetOnMissingTranslation: {n} TMissingTranslHandler;
begin
  Lock.Enter; result := LangMan.OnMissingTranslation; Lock.Leave;
end; // .function GetOnMissingTranslation

procedure SetOnMissingTranslation ({n} aMissingTranslHandler: TMissingTranslHandler);
begin
  Lock.Enter; LangMan.OnMissingTranslation := aMissingTranslHandler; Lock.Leave;
end; // .procedure SetOnMissingTranslation

function GetOnParseError: {n} TParseErrorHandler;
begin
  Lock.Enter; result := LangMan.OnParseError; Lock.Leave;
end; // .function GetOnParseError

procedure SetOnParseError ({n} aOnParseError: TParseErrorHandler);
begin
  Lock.Enter; LangMan.OnParseError := aOnParseError; Lock.Leave;
end; // .procedure SetOnParseError
  
function LoadLangData (const aLang, aLangData, aDataSource: string): boolean;
begin
  Lock.Enter; result := LangMan.LoadLangData(aLang, aLangData, aDataSource); Lock.Leave;
end; // .function LoadLangData

procedure UnloadLang (const aLang: string);
begin
  Lock.Enter; LangMan.UnloadLang(aLang); Lock.Leave;
end; // .procedure UnloadLang

procedure UnloadAllLangs;
begin
  Lock.Enter; LangMan.UnloadAllLangs; Lock.Leave;
end; // .procedure UnloadAllLangs

function Translate (const aKey, aSection: string; aLang: string; var Res: string): boolean;
begin
  Lock.Enter; result := LangMan.Translate(aKey, aSection, aLang, Res); Lock.Leave;
end; // .function Translate

function tr (const aKey, aSection: string; aLang: string = CURRENT_LANG): string;
begin
  Lock.Enter; result := LangMan.tr(aKey, aSection, aLang); Lock.Leave;
end; // .function tr

function  tr (const aKey, aSection: string; aTemplArgs: array of string): string;
begin
  Lock.Enter; result := LangMan.tr(aKey, aSection, aTemplArgs); Lock.Leave;
end; // .function tr

function InstallLangMan ({?} NewLangMan: ALangMan): {?} ALangMan;
begin
  Lock.Enter;
  result  := LangMan;
  LangMan := NewLangMan;
  Lock.Leave;
end; // .function FuncName

begin
  Lock.Init;
  InstallLangMan(TLangMan.Create);
end.
