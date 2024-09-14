unit CLngPack;
{
DESCRIPTION:  Working with language packages
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Math, Classes, Utils, CLang, CLngUnit;

const
  LNGPACK_SIGNATURE = 'LPK';


type
  TUnicodeFlag  = boolean;

  PLngPackExtHeader = ^TLngPackExtHeader;
  TLngPackExtHeader = packed record
    NumLngUnits:  integer;
  end; // .record TLngPackExtHeader
  
  PLngPack = ^TLngPack;
  TLngPack = packed record (* FORMAT *)
    Header:     TLngStructHeader;
    ExtHeader:  TLngPackExtHeader;
    (*
    LngUnits:   array ExtHeader.NumLngUnits of TLngUnit
    *)
    LngUnits:   TEmptyRec;
  end; // .record TLngPack
      
  TLngPackReader = class
    (***) protected (***)
                fConnected:             boolean;
      (* Un *)  fLngPack:               PLngPack;
                fStructMemoryBlockSize: integer;
                fCurrLngUnitInd:        integer;
      (* Un *)  fCurrLngUnit:           CLngUnit.PLngUnit;
                fSearchIndexCreated:    boolean;
      (* O *)   fSearchIndex:           array [TUnicodeFlag] of Classes.TStringList;

      function  GetStructSize: integer;
      function  GetNumLngUnits: integer;
      procedure CreateSearchIndex;

    (***) public (***)
      procedure Connect (LngPack: PLngPack; StructMemoryBlockSize: integer);
      procedure Disconnect;
      function  Validate (out Error: string): boolean;
      function  SeekLngUnit (SeekLngUnitInd: integer): boolean;
      function  ReadLngUnit ((* n *) var LngUnitReader: CLngUnit.TLngUnitReader): boolean;
      function  FindLngUnit (const UnitName: string; Unicode: boolean; out LngUnitReader: CLngUnit.TLngUnitReader): boolean;

      constructor Create;
      destructor  Destroy; override;

      property  Connected:              boolean read fConnected;
      property  LngPack:                PLngPack read fLngPack;
      property  StructMemoryBlockSize:  integer read fStructMemoryBlockSize;
      property  StructSize:             integer read GetStructSize;
      property  NumLngUnits:            integer read GetNumLngUnits;
      property  CurrLngUnitInd:         integer read fCurrLngUnitInd;
  end; // .class TLngPackReader


(***)  implementation  (***)


constructor TLngPackReader.Create;
var
  Unicode:  boolean;

begin
  Self.fConnected :=  FALSE;
  for Unicode:=FALSE to TRUE do begin
    Self.fSearchIndex[Unicode]                :=  Classes.TStringList.Create;
    Self.fSearchIndex[Unicode].CaseSensitive  :=  TRUE;
    Self.fSearchIndex[Unicode].Duplicates     :=  Classes.dupError;
    Self.fSearchIndex[Unicode].Sorted         :=  TRUE;
  end; // .for
end; // .constructor TLngPackReader.Create

destructor TLngPackReader.Destroy;
var
  Unicode:  boolean;

begin
  for Unicode:=FALSE to TRUE do begin
    SysUtils.FreeAndNil(Self.fSearchIndex[Unicode]);
  end; // .for
end; // .destructor TLngPackReader.Destroy

procedure TLngPackReader.Connect (LngPack: PLngPack; StructMemoryBlockSize: integer);
var
  Unicode:  boolean;

begin
  {!} Assert((LngPack <> nil) or (StructMemoryBlockSize = 0));
  {!} Assert(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fLngPack               :=  LngPack;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fCurrLngUnitInd        :=  0;
  Self.fCurrLngUnit           :=  nil;
  Self.fSearchIndexCreated    :=  FALSE;
  for Unicode:=FALSE to TRUE do begin
    Self.fSearchIndex[Unicode].Clear;
  end; // .for
end; // .procedure TLngPackReader.Connect

procedure TLngPackReader.Disconnect;
begin
  Self.fConnected :=  FALSE;
end; // .procedure TLngPackReader.Disconnect

function TLngPackReader.Validate (out Error: string): boolean;
var
        NumLngUnits:    integer;
        Unicode:        boolean;
(* O *) UnitNames:      array [TUnicodeFlag] of Classes.TStringList;
        RealStructSize: integer;
(* U *) LngUnit:        CLngUnit.PLngUnit;
(* O *) LngUnitReader:  CLngUnit.TLngUnitReader;
        i:              integer;

  function ValidateNumLngUnitsFields: boolean;
  begin
    NumLngUnits :=  Self.NumLngUnits;
    result  :=  (NumLngUnits >= 0) and ((NumLngUnits * sizeof(TLngUnit) + sizeof(TLngPack)) <= Self.StructMemoryBlockSize);
    if not result then begin
      Error :=  'Invalid NumLngUnits field: ' + SysUtils.IntToStr(NumLngUnits);
    end; // .if
  end; // .function ValidateNumLngUnitsFields
  
begin
  {!} Assert(Self.Connected);
  {!} Assert(Error = '');
  RealStructSize        :=  -1;
  UnitNames[FALSE]      :=  Classes.TStringList.Create;
  UnitNames[TRUE]       :=  Classes.TStringList.Create;
  LngUnit               :=  nil;
  LngUnitReader         :=  CLngUnit.TLngUnitReader.Create;
  result                :=  CLang.ValidateLngStructHeader(@Self.LngPack.Header, Self.StructMemoryBlockSize, sizeof(TLngPack), LngPack_SIGNATURE, Error);
  // * * * * * //
  for Unicode:=FALSE to TRUE do begin
    UnitNames[Unicode].CaseSensitive  :=  TRUE;
    UnitNames[Unicode].Duplicates     :=  Classes.dupError;
    UnitNames[Unicode].Sorted         :=  TRUE;
  end; // .for
  result  :=  result and ValidateNumLngUnitsFields;
  if result then begin
    RealStructSize  :=  sizeof(TLngPack);
    if NumLngUnits > 0 then begin
      i       :=  0;
      LngUnit :=  @Self.LngPack.LngUnits;
      while result and (i < NumLngUnits) do begin
        LngUnitReader.Connect(LngUnit, Self.StructMemoryBlockSize - RealStructSize);
        result  :=  LngUnitReader.Validate(Error);
        if result then begin
          try
            UnitNames[LngUnitReader.Unicode].Add(LngUnitReader.UnitName);
          except
            Error   :=  'Duplicate (UnitName && Unicode) combination in child structure: ' + LngUnitReader.UnitName +
                        '.'#13#10'Unicode: ' + SysUtils.IntToStr(byte(LngUnitReader.Unicode));
            result  :=  FALSE;
          end; // .try
        end; // .if
        if result then begin
          RealStructSize  :=  RealStructSize + LngUnitReader.StructSize;
          Inc(integer(LngUnit), LngUnitReader.StructSize);
        end; // .if
        Inc(i);
      end; // .while
    end; // .if
  end; // .if
  result  :=  result and CLang.ValidateStructSize(Self.LngPack.Header.StructSize, RealStructSize, Error);
  // * * * * * //
  for Unicode:=FALSE to TRUE do begin
    SysUtils.FreeAndNil(UnitNames[Unicode]);
  end; // .for
  SysUtils.FreeAndNil(LngUnitReader);
end; // .function TLngPackReader.Validate

function TLngPackReader.GetStructSize: integer;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.LngPack.Header.StructSize;
end; // .function TLngPackReader.GetStructSize

function TLngPackReader.GetNumLngUnits: integer;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.LngPack.ExtHeader.NumLngUnits;
end; // .function TLngPackReader.GetNumLngUnits

procedure TLngPackReader.CreateSearchIndex;
var
          SavedLngUnitInd:  integer;
(* on *)  LngUnitReader:    CLngUnit.TLngUnitReader;
  
begin
  {!} Assert(Self.Connected);
  LngUnitReader :=  nil;
  // * * * * * //
  if not Self.fSearchIndexCreated then begin
    SavedLngUnitInd :=  Self.CurrLngUnitInd;
    Self.SeekLngUnit(0);
    while Self.ReadLngUnit(LngUnitReader) do begin
      Self.fSearchIndex[LngUnitReader.Unicode].AddObject(LngUnitReader.UnitName, pointer(LngUnitReader.LngUnit));
    end; // .while
    Self.SeekLngUnit(SavedLngUnitInd);
  end; // .if
  // * * * * * //
  SysUtils.FreeAndNil(LngUnitReader);
end; // .procedure TLngPackReader.CreateSearchIndex

function TLngPackReader.SeekLngUnit (SeekLngUnitInd: integer): boolean;
var
(* on *)  LngUnitReader: CLngUnit.TLngUnitReader;

begin
  {!} Assert(Self.Connected);
  {!} Assert(SeekLngUnitInd >= 0);
  LngUnitReader :=  nil;
  // * * * * * //
  result  :=  SeekLngUnitInd < Self.NumLngUnits;
  if result then begin
    if Self.fCurrLngUnitInd > SeekLngUnitInd then begin
      Self.fCurrLngUnitInd  :=  0;
    end; // .if
    while Self.fCurrLngUnitInd < SeekLngUnitInd do begin
      Self.ReadLngUnit(LngUnitReader);
    end; // .while
  end; // .if
  // * * * * * //
  SysUtils.FreeAndNil(LngUnitReader);
end; // .function TLngPackReader.SeekLngUnit

function TLngPackReader.ReadLngUnit ((* n *) var LngUnitReader: CLngUnit.TLngUnitReader): boolean;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.fCurrLngUnitInd < Self.NumLngUnits;
  if result then begin
    if LngUnitReader = nil then begin
      LngUnitReader :=  CLngUnit.TLngUnitReader.Create;
    end; // .if
    if Self.fCurrLngUnitInd = 0 then begin
      Self.fCurrLngUnit :=  @Self.LngPack.LngUnits;
    end; // .if
    LngUnitReader.Connect(Self.fCurrLngUnit, Self.StructMemoryBlockSize - (integer(Self.fCurrLngUnit) - integer(Self.LngPack)));
    Inc(integer(Self.fCurrLngUnit), LngUnitReader.StructSize);
    Inc(Self.fCurrLngUnitInd);
  end; // .if
end; // .function TLngPackReader.ReadLngUnit 

function TLngPackReader.FindLngUnit (const UnitName: string; Unicode: boolean; out LngUnitReader: CLngUnit.TLngUnitReader): boolean;
var
          LngUnitInd: integer;
(* Un *)  LngUnit:    CLngUnit.PLngUnit;

begin
  {!} Assert(Self.Connected);
  {!} Assert(LngUnitReader = nil);
  LngUnit :=  nil;
  result  :=  FALSE;
  // * * * * * //
  Self.CreateSearchIndex;
  LngUnitInd  :=  Self.fSearchIndex[Unicode].IndexOf(UnitName);
  result      :=  LngUnitInd <> -1;
  if result then begin
    LngUnit       :=  pointer(Self.fSearchIndex[Unicode].Objects[LngUnitInd]);
    LngUnitReader :=  CLngUnit.TLngUnitReader.Create;
    LngUnitReader.Connect(LngUnit, Self.StructMemoryBlockSize - (integer(LngUnit) - integer(Self.LngPack)));
  end; // .if
end; // .function TLngPackReader.FindLngUnit

end.
