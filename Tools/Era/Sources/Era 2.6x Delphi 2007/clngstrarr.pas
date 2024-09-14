unit CLngStrArr;
{
DESCRIPTION:  Working with arrays of language strings
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Math, Utils, StrLib, CLang, CBinString;

const
  LNGSTRARR_SIGNATURE = 'LAR';


type
  TLangName = packed record
    Name:     array [0..CLang.LANGNAME_LEN - 1] of AnsiChar;
    _Align4:  array [1..(4 - CLang.LANGNAME_LEN mod 4)] of byte;
  end; // .record TLangName

  PLngStrArrExtHeader = ^TLngStrArrExtHeader;
  TLngStrArrExtHeader = packed record
    NumBinStrings:  integer;
    LangName:       TLangName;  // !Assert LangName is unique in parent structure
    Unicode:        LONGBOOL;   // !Assert Unicode = Parent.Unicode
  end; // .record TLngStrArrExtHeader
  
  PLngStrArr = ^TLngStrArr;
  TLngStrArr = packed record (* FORMAT *)
    Header:     CLang.TLngStructHeader;
    ExtHeader:  TLngStrArrExtHeader;
    (*
    BinStrings: array ExtHeader.NumBinStrings of TBinString;
    *)
    BinStrings: Utils.TEmptyRec;
  end; // .record TLngStrArr
      
  TLngStrArrReader = class
    (***) protected (***)
                fConnected:             boolean;
      (* Un *)  fLngStrArr:             PLngStrArr;
                fStructMemoryBlockSize: integer;
                fCurrBinStringInd:      integer;
      (* Un *)  fCurrBinString:         CBinString.PBinString;

      function  GetUnicode: boolean;
      function  GetLangName: string;
      function  GetStructSize: integer;
      function  GetNumBinStrings: integer;

    (***) public (***)
      procedure Connect (LngStrArr: PLngStrArr; StructMemoryBlockSize: integer);
      procedure Disconnect;
      function  Validate (out Error: string): boolean;
      function  SeekBinString (SeekBinStringInd: integer): boolean;
      function  ReadBinString ((* n *) var BinStringReader: CBinString.TBinStringReader): boolean;

      constructor Create;

      property  Connected:              boolean read fConnected;
      property  LngStrArr:              PLngStrArr read fLngStrArr;
      property  StructMemoryBlockSize:  integer read fStructMemoryBlockSize;
      property  LangName:               string read GetLangName;
      property  StructSize:             integer read GetStructSize;
      property  NumBinStrings:          integer read GetNumBinStrings;
      property  Unicode:                boolean read GetUnicode;
  end; // .class TLngStrArrReader


(***)  implementation  (***)


constructor TLngStrArrReader.Create;
begin
  Self.fConnected :=  FALSE;
end; // .constructor TLngStrArrReader.Create

procedure TLngStrArrReader.Connect (LngStrArr: PLngStrArr; StructMemoryBlockSize: integer);
begin
  {!} Assert((LngStrArr <> nil) or (StructMemoryBlockSize = 0));
  {!} Assert(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fLngStrArr             :=  LngStrArr;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fCurrBinStringInd      :=  0;
  Self.fCurrBinString         :=  nil;
end; // .procedure TLngStrArrReader.Connect

procedure TLngStrArrReader.Disconnect;
begin
  Self.fConnected :=  FALSE;
end; // .procedure TLngStrArrReader.Disconnect

function TLngStrArrReader.Validate (out Error: string): boolean;
var
        NumBinStrings:    integer;
        Unicode:          boolean;
        RealStructSize:   integer;
(* U *) BinString:        CBinString.PBinString;
(* O *) BinStringReader:  CBinString.TBinStringReader;
        i:                integer;

  function ValidateNumBinStringsField: boolean;
  begin
    NumBinStrings :=  Self.NumBinStrings;
    result        :=  (NumBinStrings >= 0) and ((NumBinStrings * sizeof(TBinString) + sizeof(TLngStrArr)) <= Self.StructMemoryBlockSize);
    if not result then begin
      Error :=  'Invalid NumBinStrings field: ' + SysUtils.IntToStr(NumBinStrings);
    end; // .if
  end; // .function ValidateNumBinStringsField  
  
  function ValidateLangNameField: boolean;
  var
    LangName: string;

  begin
    LangName  :=  Self.LangName;
    result    :=  CLang.IsValidLangName(LangName);
    if not result then begin
      Error :=  'Invalid LangName field: ' + LangName;
    end; // .if
  end; // .function ValidateLangNameField 

begin
  {!} Assert(Self.Connected);
  {!} Assert(Error = '');
  RealStructSize  :=  -1;
  BinString       :=  nil;
  BinStringReader :=  CBinString.TBinStringReader.Create;
  result          :=  CLang.ValidateLngStructHeader(@Self.LngStrArr.Header, Self.StructMemoryBlockSize, sizeof(TLngStrArr), LNGSTRARR_SIGNATURE, Error);
  // * * * * * //
  result  :=  result and
    ValidateNumBinStringsField and
    ValidateLangNameField;
  if result then begin
    Unicode         :=  Self.Unicode;
    RealStructSize  :=  sizeof(TLngStrArr);
    if NumBinStrings > 0 then begin
      i         :=  0;
      BinString :=  @Self.LngStrArr.BinStrings;
      while result and (i < NumBinStrings) do begin
        BinStringReader.Connect(BinString, Self.StructMemoryBlockSize - RealStructSize, Unicode);
        result  :=  BinStringReader.Validate(Error);
        if result then begin
          RealStructSize  :=  RealStructSize + BinStringReader.StructSize;
          Inc(integer(BinString), BinStringReader.StructSize);
        end; // .if
        Inc(i);
      end; // .while
    end; // .if
  end; // .if
  result  :=  result and CLang.ValidateStructSize(Self.LngStrArr.Header.StructSize, RealStructSize, Error);
  // * * * * * //
  SysUtils.FreeAndNil(BinStringReader);
end; // .function TLngStrArrReader.Validate

function TLngStrArrReader.GetUnicode: boolean;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.LngStrArr.ExtHeader.Unicode;
end; // .function TLngStrArrReader.GetStructSize

function TLngStrArrReader.GetLangName: string;
begin
  {!} Assert(Self.Connected);
  result  :=  StrLib.BytesToAnsiString(@Self.LngStrArr.ExtHeader.LangName.Name[0], CLang.LANGNAME_LEN);
end; // .function TLngStrArrReader.GetLangName

function TLngStrArrReader.GetStructSize: integer;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.LngStrArr.Header.StructSize;
end; // .function TLngStrArrReader.GetStructSize

function TLngStrArrReader.GetNumBinStrings: integer;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.LngStrArr.ExtHeader.NumBinStrings;
end; // .function TLngStrArrReader.GetNumBinStrings

function TLngStrArrReader.SeekBinString (SeekBinStringInd: integer): boolean;
var
(* on *)  BinStringReader: CBinString.TBinStringReader;

begin
  {!} Assert(Self.Connected);
  {!} Assert(SeekBinStringInd >= 0);
  BinStringReader :=  nil;
  // * * * * * //
  result  :=  SeekBinStringInd < Self.NumBinStrings;
  if result then begin
    if Self.fCurrBinStringInd > SeekBinStringInd then begin
      Self.fCurrBinStringInd  :=  0;
    end; // .if
    while Self.fCurrBinStringInd < SeekBinStringInd do begin
      Self.ReadBinString(BinStringReader);
    end; // .while
  end; // .if
  // * * * * * //
  SysUtils.FreeAndNil(BinStringReader);
end; // .function TLngStrArrReader.SeekBinString

function TLngStrArrReader.ReadBinString ((* n *) var BinStringReader: CBinString.TBinStringReader): boolean;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.fCurrBinStringInd < Self.NumBinStrings;
  if result then begin
    if BinStringReader = nil then begin
      BinStringReader :=  CBinString.TBinStringReader.Create;
    end; // .if
    if Self.fCurrBinStringInd = 0 then begin
      Self.fCurrBinString :=  @Self.LngStrArr.BinStrings;
    end; // .if
    BinStringReader.Connect(Self.fCurrBinString, Self.StructMemoryBlockSize - (integer(Self.fCurrBinString) - integer(Self.LngStrArr)), Self.Unicode);
    Inc(integer(Self.fCurrBinString), BinStringReader.StructSize);
    Inc(Self.fCurrBinStringInd);
  end; // .if
end; // .function TLngStrArrReader.ReadBinString 

end.
