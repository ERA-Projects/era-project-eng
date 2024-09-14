UNIT Ini;
{
DESCRIPTION:  Memory cached ini files management
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  SysUtils, Utils, Log,
  TypeWrappers, AssocArrays, Lists, Files, TextScan, StrLib;

TYPE
  (* IMPORT *)
  TString     = TypeWrappers.TString;
  TAssocArray = AssocArrays.TAssocArray;


PROCEDURE ClearIniCache (CONST FileName: STRING);
PROCEDURE ClearAllIniCache;

FUNCTION  ReadStrFromIni
(
  CONST Key:          STRING;
  CONST SectionName:  STRING;
        FilePath:     STRING;
  OUT   Res:          STRING
): BOOLEAN;

FUNCTION  WriteStrToIni (CONST Key, Value, SectionName: STRING; FilePath: STRING): BOOLEAN;
FUNCTION  SaveIni (FilePath: STRING): BOOLEAN;

(***) IMPLEMENTATION (***)


VAR
{O} CachedIniFiles: {O} TAssocArray {OF TAssocArray};


PROCEDURE ClearIniCache (CONST FileName: STRING);
BEGIN
  CachedIniFiles.DeleteItem(SysUtils.ExpandFileName(FileName));
END; // .PROCEDURE ClearIniCache

PROCEDURE ClearAllIniCache;
BEGIN
  CachedIniFiles.Clear;
END; // .PROCEDURE ClearAllIniCache

FUNCTION LoadIni (FilePath: STRING): BOOLEAN;
CONST
  LINE_END_MARKER     = #10;
  LINE_END_MARKERS    = [#10, #13];
  BLANKS              = [#0..#32];
  DEFAULT_DELIMS      = [';'] + LINE_END_MARKERS;
  SECTION_NAME_DELIMS = [']'] + DEFAULT_DELIMS;
  KEY_DELIMS          = ['='] + DEFAULT_DELIMS;

VAR
{O} TextScanner:  TextScan.TTextScanner;
{O} Sections:     {O} TAssocArray {OF TAssocArray};
{U} CurrSection:  {O} TAssocArray {OF TString};
    FileContents: STRING;
    SectionName:  STRING;
    Key:          STRING;
    Value:        STRING;
    c:            CHAR;

 PROCEDURE GotoNextLine;
 BEGIN
   TextScanner.FindChar(LINE_END_MARKER);
   TextScanner.GotoNextChar;
 END; // .PROCEDURE GotoNextLine  
    
BEGIN
  TextScanner :=  TextScan.TTextScanner.Create;
  Sections    :=  NIL;
  CurrSection :=  NIL;
  // * * * * * //
  FilePath  :=  SysUtils.ExpandFileName(FilePath);
  RESULT    :=  Files.ReadFileContents(FilePath, FileContents);
  
  IF RESULT AND (LENGTH(FileContents) > 0) THEN BEGIN
    Sections  :=  AssocArrays.NewStrictAssocArr(TAssocArray);
    TextScanner.Connect(FileContents, LINE_END_MARKER);
    
    WHILE RESULT AND (NOT TextScanner.EndOfText) DO BEGIN
      TextScanner.SkipCharset(BLANKS);
      
      IF TextScanner.GetCurrChar(c) THEN BEGIN
        IF c = ';' THEN BEGIN
          GotoNextLine;
        END // .IF
        ELSE BEGIN
          IF c = '[' THEN BEGIN
            TextScanner.GotoNextChar;
            
            RESULT  :=
              TextScanner.ReadTokenTillDelim(SECTION_NAME_DELIMS, SectionName)  AND
              TextScanner.GetCurrChar(c)                                        AND
              (c = ']');
            
            IF RESULT THEN BEGIN
              SectionName :=  SysUtils.Trim(SectionName);
              GotoNextLine;
              CurrSection :=  Sections[SectionName];
              
              IF CurrSection = NIL THEN BEGIN
                CurrSection           :=  AssocArrays.NewStrictAssocArr(TString);
                Sections[SectionName] :=  CurrSection;
              END; // .IF
            END; // .IF
          END // .IF
          ELSE BEGIN
            TextScanner.ReadTokenTillDelim(KEY_DELIMS, Key);
            RESULT  :=  TextScanner.GetCurrChar(c) AND (c = '=');
            
            IF RESULT THEN BEGIN
              Key :=  SysUtils.Trim(Key);
              TextScanner.GotoNextChar;
              
              IF NOT TextScanner.ReadTokenTillDelim(DEFAULT_DELIMS, Value) THEN BEGIN
                Value :=  '';
              END // .IF
              ELSE BEGIN
                Value :=  Trim(Value);
              END; // .ELSE
              
              IF CurrSection = NIL THEN BEGIN
                CurrSection   :=  AssocArrays.NewStrictAssocArr(TString);
                Sections['']  :=  CurrSection;
              END; // .IF
              
              CurrSection[Key]  :=  TString.Create(Value);
            END; // .IF
          END; // .ELSE
        END; // .ELSE
      END; // .IF
    END; // .WHILE
    
    IF RESULT THEN BEGIN
      CachedIniFiles[FilePath]  :=  Sections; Sections  := NIL;
    END // .IF
    ELSE BEGIN
      Log.Write
      (
        'Ini',
        'LoadIni',
        StrLib.Concat
        ([
          'The file "', FilePath, '" has invalid format.'#13#10,
          'Scanner stopped at position ', SysUtils.IntToStr(TextScanner.Pos)
        ])
      );
    END; // .ELSE
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(TextScanner);
  SysUtils.FreeAndNil(Sections);
END; // .FUNCTION LoadIni

FUNCTION SaveIni (FilePath: STRING): BOOLEAN;
VAR
{O} StrBuilder:   StrLib.TStrBuilder;
{O} SectionNames: Lists.TStringList {OF TAssocArray};
{O} SectionKeys:  Lists.TStringList {OF TString};

{U} CachedIni:    {O} TAssocArray {OF TAssocArray};
{U} Section:      {O} TAssocArray {OF TString};
{U} Value:        TString;
    SectionName:  STRING;
    Key:          STRING;
    i:            INTEGER;
    j:            INTEGER;

BEGIN
  StrBuilder    :=  StrLib.TStrBuilder.Create;
  SectionNames  :=  Lists.NewSimpleStrList;
  SectionKeys   :=  Lists.NewSimpleStrList;
  CachedIni     :=  NIL;
  Section       :=  NIL;
  Value         :=  NIL;
  // * * * * * //
  FilePath  :=  SysUtils.ExpandFileName(FilePath);
  CachedIni :=  CachedIniFiles[FilePath];
  
  IF CachedIni <> NIL THEN BEGIN
    CachedIni.BeginIterate;
    
    WHILE CachedIni.IterateNext(SectionName, POINTER(Section)) DO BEGIN
      SectionNames.AddObj(SectionName, Section);
      Section :=  NIL;
    END; // .WHILE
    
    CachedIni.EndIterate;
    
    SectionNames.Sorted :=  TRUE;
    
    FOR i:=0 TO SectionNames.Count - 1 DO BEGIN
      IF SectionNames[i] <> '' THEN BEGIN
        StrBuilder.Append('[');
        StrBuilder.Append(SectionNames[i]);
        StrBuilder.Append(']'#13#10);
      END; // .IF
      
      Section :=  SectionNames.Values[i];
      
      Section.BeginIterate;
      
      WHILE Section.IterateNext(Key, POINTER(Value)) DO BEGIN
        SectionKeys.AddObj(Key, Value);
        Value :=  NIL;
      END; // .WHILE
      
      Section.EndIterate;
      
      SectionKeys.Sorted :=  TRUE;
      
      FOR j:=0 TO SectionKeys.Count - 1 DO BEGIN
        StrBuilder.Append(SectionKeys[j]);
        StrBuilder.Append('=');
        StrBuilder.Append(TString(SectionKeys.Values[j]).Value);
        StrBuilder.Append(#13#10);
      END; // .FOR
      
      SectionKeys.Clear;
      SectionKeys.Sorted :=  FALSE;
    END; // .FOR
  END; // .IF
  
  RESULT  :=  Files.WriteFileContents(StrBuilder.BuildStr, FilePath);
  // * * * * * //
  SysUtils.FreeAndNil(StrBuilder);
  SysUtils.FreeAndNil(SectionNames);
  SysUtils.FreeAndNil(SectionKeys);
END; // .FUNCTION SaveIni

FUNCTION ReadStrFromIni
(
  CONST Key:          STRING;
  CONST SectionName:  STRING;
        FilePath:     STRING;
  OUT   Res:          STRING
): BOOLEAN;

VAR
{U} CachedIni:  {O} TAssocArray {OF TAssocArray};
{U} Section:    {O} TAssocArray {OF TString};
{U} Value:      TString;

BEGIN
  CachedIni :=  NIL;
  Section   :=  NIL;
  Value     :=  NIL;
  // * * * * * //
  FilePath  :=  SysUtils.ExpandFileName(FilePath);
  CachedIni :=  CachedIniFiles[FilePath];
  
  IF CachedIni = NIL THEN BEGIN
    LoadIni(FilePath);
    CachedIni :=  CachedIniFiles[FilePath];
  END; // .IF
  
  RESULT  :=  CachedIni <> NIL;
  
  IF RESULT THEN BEGIN
    Section :=  CachedIni[SectionName];
    RESULT  :=  Section <> NIL;
    
    IF RESULT THEN BEGIN
      Value   :=  Section[Key];
      RESULT  :=  Value <> NIL;
      
      IF RESULT THEN BEGIN
        Res :=  Value.Value;
      END; // .IF
    END; // .IF
  END; // .IF
END; // .FUNCTION ReadStrFromIni

FUNCTION WriteStrToIni (CONST Key, Value, SectionName: STRING; FilePath: STRING): BOOLEAN;
VAR
{U} CachedIni:      {O} TAssocArray {OF TAssocArray};
{U} Section:        {O} TAssocArray {OF TString};
    InvalidCharPos: INTEGER;

BEGIN
  CachedIni :=  NIL;
  Section   :=  NIL;
  // * * * * * //
  FilePath  :=  SysUtils.ExpandFileName(FilePath);
  CachedIni :=  CachedIniFiles[FilePath];
  
  IF (CachedIni = NIL) AND LoadIni(FilePath) THEN BEGIN
    CachedIni :=  CachedIniFiles[FilePath];
  END; // .IF
  
  RESULT  :=
    NOT StrLib.FindCharset([';', #10, #13, ']'], SectionName, InvalidCharPos) AND
    NOT StrLib.FindCharset([';', #10, #13, '='], Key, InvalidCharPos)         AND
    NOT StrLib.FindCharset([';', #10, #13], Value, InvalidCharPos)            AND
    ((CachedIni <> NIL) OR (NOT SysUtils.FileExists(FilePath)));
  
  IF RESULT THEN BEGIN
    IF CachedIni = NIL THEN BEGIN
      CachedIni                 :=  AssocArrays.NewStrictAssocArr(TAssocArray);
      CachedIniFiles[FilePath]  :=  CachedIni;
    END; // .IF
    
    Section :=  CachedIni[SectionName];
    
    IF Section = NIL THEN BEGIN
      Section                 :=  AssocArrays.NewStrictAssocArr(TString);
      CachedIni[SectionName]  :=  Section;
    END; // .IF
    
    Section[Key]  :=  TString.Create(Value);
  END; // .IF
END; // .FUNCTION WriteStrToIni

BEGIN
  CachedIniFiles  :=  AssocArrays.NewStrictAssocArr(TAssocArray);
END.
