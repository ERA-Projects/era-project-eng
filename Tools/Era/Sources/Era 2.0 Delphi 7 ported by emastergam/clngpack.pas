UNIT CLngPack;
{
DESCRIPTION:  Working with language packages
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES SysUtils, Math, Classes, Utils, CLang, CLngUnit;

CONST
  LNGPACK_SIGNATURE = 'LPK';


TYPE
  TUnicodeFlag  = BOOLEAN;

  PLngPackExtHeader = ^TLngPackExtHeader;
  TLngPackExtHeader = PACKED RECORD
    NumLngUnits:  INTEGER;
  END; // .RECORD TLngPackExtHeader
  
  PLngPack = ^TLngPack;
  TLngPack = PACKED RECORD (* FORMAT *)
    Header:     TLngStructHeader;
    ExtHeader:  TLngPackExtHeader;
    (*
    LngUnits:   ARRAY ExtHeader.NumLngUnits OF TLngUnit
    *)
    LngUnits:   TEmptyRec;
  END; // .RECORD TLngPack
      
  TLngPackReader = CLASS
    (***) PROTECTED (***)
                fConnected:             BOOLEAN;
      (* Un *)  fLngPack:               PLngPack;
                fStructMemoryBlockSize: INTEGER;
                fCurrLngUnitInd:        INTEGER;
      (* Un *)  fCurrLngUnit:           CLngUnit.PLngUnit;
                fSearchIndexCreated:    BOOLEAN;
      (* O *)   fSearchIndex:           ARRAY [TUnicodeFlag] OF Classes.TStringList;

      FUNCTION  GetStructSize: INTEGER;
      FUNCTION  GetNumLngUnits: INTEGER;
      PROCEDURE CreateSearchIndex;

    (***) PUBLIC (***)
      PROCEDURE Connect (LngPack: PLngPack; StructMemoryBlockSize: INTEGER);
      PROCEDURE Disconnect;
      FUNCTION  Validate (OUT Error: STRING): BOOLEAN;
      FUNCTION  SeekLngUnit (SeekLngUnitInd: INTEGER): BOOLEAN;
      FUNCTION  ReadLngUnit ((* n *) VAR LngUnitReader: CLngUnit.TLngUnitReader): BOOLEAN;
      FUNCTION  FindLngUnit (CONST UnitName: STRING; Unicode: BOOLEAN; OUT LngUnitReader: CLngUnit.TLngUnitReader): BOOLEAN;

      CONSTRUCTOR Create;
      DESTRUCTOR  Destroy; OVERRIDE;

      PROPERTY  Connected:              BOOLEAN READ fConnected;
      PROPERTY  LngPack:                PLngPack READ fLngPack;
      PROPERTY  StructMemoryBlockSize:  INTEGER READ fStructMemoryBlockSize;
      PROPERTY  StructSize:             INTEGER READ GetStructSize;
      PROPERTY  NumLngUnits:            INTEGER READ GetNumLngUnits;
      PROPERTY  CurrLngUnitInd:         INTEGER READ fCurrLngUnitInd;
  END; // .CLASS TLngPackReader


(***)  IMPLEMENTATION  (***)


CONSTRUCTOR TLngPackReader.Create;
VAR
  Unicode:  BOOLEAN;

BEGIN
  Self.fConnected :=  FALSE;
  FOR Unicode:=FALSE TO TRUE DO BEGIN
    Self.fSearchIndex[Unicode]                :=  Classes.TStringList.Create;
    Self.fSearchIndex[Unicode].CaseSensitive  :=  TRUE;
    Self.fSearchIndex[Unicode].Duplicates     :=  Classes.dupError;
    Self.fSearchIndex[Unicode].Sorted         :=  TRUE;
  END; // .FOR
END; // .CONSTRUCTOR TLngPackReader.Create

DESTRUCTOR TLngPackReader.Destroy;
VAR
  Unicode:  BOOLEAN;

BEGIN
  FOR Unicode:=FALSE TO TRUE DO BEGIN
    SysUtils.FreeAndNil(Self.fSearchIndex[Unicode]);
  END; // .FOR
END; // .DESTRUCTOR TLngPackReader.Destroy

PROCEDURE TLngPackReader.Connect (LngPack: PLngPack; StructMemoryBlockSize: INTEGER);
VAR
  Unicode:  BOOLEAN;

BEGIN
  {!} ASSERT((LngPack <> NIL) OR (StructMemoryBlockSize = 0));
  {!} ASSERT(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fLngPack               :=  LngPack;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fCurrLngUnitInd        :=  0;
  Self.fCurrLngUnit           :=  NIL;
  Self.fSearchIndexCreated    :=  FALSE;
  FOR Unicode:=FALSE TO TRUE DO BEGIN
    Self.fSearchIndex[Unicode].Clear;
  END; // .FOR
END; // .PROCEDURE TLngPackReader.Connect

PROCEDURE TLngPackReader.Disconnect;
BEGIN
  Self.fConnected :=  FALSE;
END; // .PROCEDURE TLngPackReader.Disconnect

FUNCTION TLngPackReader.Validate (OUT Error: STRING): BOOLEAN;
VAR
        NumLngUnits:    INTEGER;
        Unicode:        BOOLEAN;
(* O *) UnitNames:      ARRAY [TUnicodeFlag] OF Classes.TStringList;
        RealStructSize: INTEGER;
(* U *) LngUnit:        CLngUnit.PLngUnit;
(* O *) LngUnitReader:  CLngUnit.TLngUnitReader;
        i:              INTEGER;

  FUNCTION ValidateNumLngUnitsFields: BOOLEAN;
  BEGIN
    NumLngUnits :=  Self.NumLngUnits;
    RESULT  :=  (NumLngUnits >= 0) AND ((NumLngUnits * SIZEOF(TLngUnit) + SIZEOF(TLngPack)) <= Self.StructMemoryBlockSize);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid NumLngUnits field: ' + SysUtils.IntToStr(NumLngUnits);
    END; // .IF
  END; // .FUNCTION ValidateNumLngUnitsFields
  
BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(Error = '');
  RealStructSize        :=  -1;
  UnitNames[FALSE]      :=  Classes.TStringList.Create;
  UnitNames[TRUE]       :=  Classes.TStringList.Create;
  LngUnit               :=  NIL;
  LngUnitReader         :=  CLngUnit.TLngUnitReader.Create;
  RESULT                :=  CLang.ValidateLngStructHeader(@Self.LngPack.Header, Self.StructMemoryBlockSize, SIZEOF(TLngPack), LngPack_SIGNATURE, Error);
  // * * * * * //
  FOR Unicode:=FALSE TO TRUE DO BEGIN
    UnitNames[Unicode].CaseSensitive  :=  TRUE;
    UnitNames[Unicode].Duplicates     :=  Classes.dupError;
    UnitNames[Unicode].Sorted         :=  TRUE;
  END; // .FOR
  RESULT  :=  RESULT AND ValidateNumLngUnitsFields;
  IF RESULT THEN BEGIN
    RealStructSize  :=  SIZEOF(TLngPack);
    IF NumLngUnits > 0 THEN BEGIN
      i       :=  0;
      LngUnit :=  @Self.LngPack.LngUnits;
      WHILE RESULT AND (i < NumLngUnits) DO BEGIN
        LngUnitReader.Connect(LngUnit, Self.StructMemoryBlockSize - RealStructSize);
        RESULT  :=  LngUnitReader.Validate(Error);
        IF RESULT THEN BEGIN
          TRY
            UnitNames[LngUnitReader.Unicode].Add(LngUnitReader.UnitName);
          EXCEPT
            Error   :=  'Duplicate (UnitName && Unicode) combination in child structure: ' + LngUnitReader.UnitName +
                        '.'#13#10'Unicode: ' + SysUtils.IntToStr(BYTE(LngUnitReader.Unicode));
            RESULT  :=  FALSE;
          END; // .TRY
        END; // .IF
        IF RESULT THEN BEGIN
          RealStructSize  :=  RealStructSize + LngUnitReader.StructSize;
          INC(INTEGER(LngUnit), LngUnitReader.StructSize);
        END; // .IF
        INC(i);
      END; // .WHILE
    END; // .IF
  END; // .IF
  RESULT  :=  RESULT AND CLang.ValidateStructSize(Self.LngPack.Header.StructSize, RealStructSize, Error);
  // * * * * * //
  FOR Unicode:=FALSE TO TRUE DO BEGIN
    SysUtils.FreeAndNil(UnitNames[Unicode]);
  END; // .FOR
  SysUtils.FreeAndNil(LngUnitReader);
END; // .FUNCTION TLngPackReader.Validate

FUNCTION TLngPackReader.GetStructSize: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngPack.Header.StructSize;
END; // .FUNCTION TLngPackReader.GetStructSize

FUNCTION TLngPackReader.GetNumLngUnits: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngPack.ExtHeader.NumLngUnits;
END; // .FUNCTION TLngPackReader.GetNumLngUnits

PROCEDURE TLngPackReader.CreateSearchIndex;
VAR
          SavedLngUnitInd:  INTEGER;
(* On *)  LngUnitReader:    CLngUnit.TLngUnitReader;
  
BEGIN
  {!} ASSERT(Self.Connected);
  LngUnitReader :=  NIL;
  // * * * * * //
  IF NOT Self.fSearchIndexCreated THEN BEGIN
    SavedLngUnitInd :=  Self.CurrLngUnitInd;
    Self.SeekLngUnit(0);
    WHILE Self.ReadLngUnit(LngUnitReader) DO BEGIN
      Self.fSearchIndex[LngUnitReader.Unicode].AddObject(LngUnitReader.UnitName, POINTER(LngUnitReader.LngUnit));
    END; // .WHILE
    Self.SeekLngUnit(SavedLngUnitInd);
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(LngUnitReader);
END; // .PROCEDURE TLngPackReader.CreateSearchIndex

FUNCTION TLngPackReader.SeekLngUnit (SeekLngUnitInd: INTEGER): BOOLEAN;
VAR
(* On *)  LngUnitReader: CLngUnit.TLngUnitReader;

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(SeekLngUnitInd >= 0);
  LngUnitReader :=  NIL;
  // * * * * * //
  RESULT  :=  SeekLngUnitInd < Self.NumLngUnits;
  IF RESULT THEN BEGIN
    IF Self.fCurrLngUnitInd > SeekLngUnitInd THEN BEGIN
      Self.fCurrLngUnitInd  :=  0;
    END; // .IF
    WHILE Self.fCurrLngUnitInd < SeekLngUnitInd DO BEGIN
      Self.ReadLngUnit(LngUnitReader);
    END; // .WHILE
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(LngUnitReader);
END; // .FUNCTION TLngPackReader.SeekLngUnit

FUNCTION TLngPackReader.ReadLngUnit ((* n *) VAR LngUnitReader: CLngUnit.TLngUnitReader): BOOLEAN;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.fCurrLngUnitInd < Self.NumLngUnits;
  IF RESULT THEN BEGIN
    IF LngUnitReader = NIL THEN BEGIN
      LngUnitReader :=  CLngUnit.TLngUnitReader.Create;
    END; // .IF
    IF Self.fCurrLngUnitInd = 0 THEN BEGIN
      Self.fCurrLngUnit :=  @Self.LngPack.LngUnits;
    END; // .IF
    LngUnitReader.Connect(Self.fCurrLngUnit, Self.StructMemoryBlockSize - (INTEGER(Self.fCurrLngUnit) - INTEGER(Self.LngPack)));
    INC(INTEGER(Self.fCurrLngUnit), LngUnitReader.StructSize);
    INC(Self.fCurrLngUnitInd);
  END; // .IF
END; // .FUNCTION TLngPackReader.ReadLngUnit 

FUNCTION TLngPackReader.FindLngUnit (CONST UnitName: STRING; Unicode: BOOLEAN; OUT LngUnitReader: CLngUnit.TLngUnitReader): BOOLEAN;
VAR
          LngUnitInd: INTEGER;
(* Un *)  LngUnit:    CLngUnit.PLngUnit;

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(LngUnitReader = NIL);
  LngUnit :=  NIL;
  RESULT  :=  FALSE;
  // * * * * * //
  Self.CreateSearchIndex;
  LngUnitInd  :=  Self.fSearchIndex[Unicode].IndexOf(UnitName);
  RESULT      :=  LngUnitInd <> -1;
  IF RESULT THEN BEGIN
    LngUnit       :=  POINTER(Self.fSearchIndex[Unicode].Objects[LngUnitInd]);
    LngUnitReader :=  CLngUnit.TLngUnitReader.Create;
    LngUnitReader.Connect(LngUnit, Self.StructMemoryBlockSize - (INTEGER(LngUnit) - INTEGER(Self.LngPack)));
  END; // .IF
END; // .FUNCTION TLngPackReader.FindLngUnit

END.
