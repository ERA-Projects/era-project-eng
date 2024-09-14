UNIT CLngUnit;
{
DESCRIPTION:  Working with language units
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES SysUtils, Math, Classes, Utils, StrLib, CLang, CLngStrArr;

CONST
  LNGUNIT_SIGNATURE = 'LUN';


TYPE
  PLngUnitExtHeader = ^TLngUnitExtHeader;
  TLngUnitExtHeader = PACKED RECORD (* FORMAT *)
    NumLngStrArrays:  INTEGER;
    Unicode:          LONGBOOL;
    UnitNameLen:      INTEGER;
    (*
    UnitName: ARRAY UnitNameLen OF AnsiChar;  // !ASSERT UnitName is unique in parent structure
    *)
    UnitName:         TEmptyRec;
  END; // .RECORD TLngUnitExtHeader
  
  PLngUnit = ^TLngUnit;
  TLngUnit = PACKED RECORD (* FORMAT *)
    Header:       TLngStructHeader;
    ExtHeader:    TLngUnitExtHeader;
    (*
    LngStrArrays: ARRAY ExtHeader.NumLngStrArrays OF TLngStrArr;
    *)
  END; // .RECORD TLngUnit
      
  TLngUnitReader = CLASS
    (***) PROTECTED (***)
                fConnected:             BOOLEAN;
      (* Un *)  fLngUnit:               PLngUnit;
                fStructMemoryBlockSize: INTEGER;
                fCurrLngStrArrInd:      INTEGER;
      (* Un *)  fCurrLngStrArr:         CLngStrArr.PLngStrArr;

      FUNCTION  GetUnitName: STRING;
      FUNCTION  GetStructSize: INTEGER;
      FUNCTION  GetNumLngStrArrays: INTEGER;
      FUNCTION  GetUnicode: BOOLEAN;

    (***) PUBLIC (***)
      PROCEDURE Connect (LngUnit: PLngUnit; StructMemoryBlockSize: INTEGER);
      PROCEDURE Disconnect;
      FUNCTION  Validate (OUT Error: STRING): BOOLEAN;
      FUNCTION  SeekLngStrArr (SeekLngStrArrInd: INTEGER): BOOLEAN;
      FUNCTION  ReadLngStrArr ((* n *) VAR LngStrArrReader: CLngStrArr.TLngStrArrReader): BOOLEAN;
      FUNCTION  FindLngStrArr (CONST LangName: STRING; OUT LngStrArrReader: CLngStrArr.TLngStrArrReader): BOOLEAN;

      CONSTRUCTOR Create;

      PROPERTY  Connected:              BOOLEAN READ fConnected;
      PROPERTY  LngUnit:                PLngUnit READ fLngUnit;
      PROPERTY  StructMemoryBlockSize:  INTEGER READ fStructMemoryBlockSize;
      PROPERTY  Unicode:                BOOLEAN READ GetUnicode;
      PROPERTY  UnitName:               STRING READ GetUnitName;
      PROPERTY  StructSize:             INTEGER READ GetStructSize;
      PROPERTY  NumLngStrArrays:        INTEGER READ GetNumLngStrArrays;
      PROPERTY  CurrLngStrArrInd:       INTEGER READ fCurrLngStrArrInd;
  END; // .CLASS TLngUnitReader


(***)  IMPLEMENTATION  (***)


CONSTRUCTOR TLngUnitReader.Create;
BEGIN
  Self.fConnected :=  FALSE;
END; // .CONSTRUCTOR TLngUnitReader.Create

PROCEDURE TLngUnitReader.Connect (LngUnit: PLngUnit; StructMemoryBlockSize: INTEGER);
BEGIN
  {!} ASSERT((LngUnit <> NIL) OR (StructMemoryBlockSize = 0));
  {!} ASSERT(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fLngUnit               :=  LngUnit;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fCurrLngStrArrInd      :=  0;
  Self.fCurrLngStrArr         :=  NIL;
END; // .PROCEDURE TLngUnitReader.Connect

PROCEDURE TLngUnitReader.Disconnect;
BEGIN
  Self.fConnected :=  FALSE;
END; // .PROCEDURE TLngUnitReader.Disconnect

FUNCTION TLngUnitReader.Validate (OUT Error: STRING): BOOLEAN;
VAR
        MinStructSize:    INTEGER;
        RealStructSize:   INTEGER;
        NumLngStrArrays:  INTEGER;
        UnitNameLen:      INTEGER;
        UnitName:         STRING;
        Unicode:          LONGBOOL;
(* O *) LangNames:        Classes.TStringList;
(* U *) LngStrArr:        CLngStrArr.PLngStrArr;
(* O *) LngStrArrReader:  CLngStrArr.TLngStrArrReader;
        i:                INTEGER;

  FUNCTION ValidateNumLngStrArraysField: BOOLEAN;
  BEGIN
    NumLngStrArrays :=  Self.NumLngStrArrays;
    MinStructSize   :=  MinStructSize + NumLngStrArrays * SIZEOF(TLngStrArr);
    RESULT          :=  (NumLngStrArrays >= 0) AND (MinStructSize <= Self.StructMemoryBlockSize);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid NumLngStrArrays field: ' + SysUtils.IntToStr(NumLngStrArrays);
    END; // .IF
  END; // .FUNCTION ValidateNumLngStrArraysField
  
  FUNCTION ValidateUnitNameLenField: BOOLEAN;
  BEGIN
    UnitNameLen   :=  Self.LngUnit.ExtHeader.UnitNameLen;
    MinStructSize :=  MinStructSize + UnitNameLen;
    RESULT        :=  (UnitNameLen >= 0) AND (MinStructSize <= Self.StructMemoryBlockSize);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid UnitNameLen field: ' + SysUtils.IntToStr(UnitNameLen);
    END; // .IF
  END; // .FUNCTION ValidateUnitNameLenField

  FUNCTION ValidateUnitNameField: BOOLEAN;
  BEGIN
    UnitName  :=  Self.UnitName;
    RESULT    :=  CLang.IsValidClientName(UnitName);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid UnitName field: ' + UnitName;
    END; // .IF
  END; // .FUNCTION ValidateUnitNameField

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(Error = '');
  RealStructSize  :=  -1;
  LangNames       :=  Classes.TStringList.Create;
  LngStrArr       :=  NIL;
  LngStrArrReader :=  CLngStrArr.TLngStrArrReader.Create;
  MinStructSize   :=  SIZEOF(TLngUnit);
  RESULT          :=  CLang.ValidateLngStructHeader(@Self.LngUnit.Header, Self.StructMemoryBlockSize, MinStructSize, LNGUNIT_SIGNATURE, Error);
  // * * * * * //
  LangNames.CaseSensitive :=  TRUE;
  LangNames.Duplicates    :=  Classes.dupError;
  LangNames.Sorted        :=  TRUE;
  RESULT                  :=  RESULT AND
    ValidateNumLngStrArraysField AND
    ValidateUnitNameLenField AND
    ValidateUnitNameField;
  IF RESULT THEN BEGIN
    Unicode         :=  Self.Unicode;
    RealStructSize  :=  SIZEOF(TLngUnit) + UnitNameLen;
    IF NumLngStrArrays > 0 THEN BEGIN
      i         :=  0;
      LngStrArr :=  POINTER(INTEGER(@Self.LngUnit.Header) + RealStructSize);
      WHILE RESULT AND (i < NumLngStrArrays) DO BEGIN
        LngStrArrReader.Connect(LngStrArr, Self.StructMemoryBlockSize - RealStructSize);
        RESULT  :=  LngStrArrReader.Validate(Error);
        IF RESULT THEN BEGIN
          TRY
            LangNames.Add(LngStrArrReader.LangName);
          EXCEPT
            Error   :=  'Duplicate LangName field in child structure: ' + LngStrArrReader.LangName;
            RESULT  :=  FALSE;
          END; // .TRY
        END; // .IF
        IF RESULT THEN BEGIN
          RESULT  :=  LngStrArrReader.Unicode = Unicode;
          IF NOT RESULT THEN BEGIN
            Error :=  'Child structure has different encoding: Unicode = ' + SysUtils.IntToStr(BYTE(Unicode));
          END; // .IF
        END; // .IF
        IF RESULT THEN BEGIN
          RealStructSize  :=  RealStructSize + LngStrArrReader.StructSize;
          INC(INTEGER(LngStrArr), LngStrArrReader.StructSize);
        END; // .IF
        INC(i);
      END; // .WHILE
    END; // .IF
  END; // .IF
  RESULT  :=  RESULT AND CLang.ValidateStructSize(Self.LngUnit.Header.StructSize, RealStructSize, Error);
  // * * * * * //
  SysUtils.FreeAndNil(LangNames);
  SysUtils.FreeAndNil(LngStrArrReader);
END; // .FUNCTION TLngUnitReader.Validate

FUNCTION TLngUnitReader.GetUnitName: STRING;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  StrLib.BytesToAnsiString(@Self.LngUnit.ExtHeader.UnitName, Self.LngUnit.ExtHeader.UnitNameLen);
END; // .FUNCTION TLngUnitReader.GetUnitName

FUNCTION TLngUnitReader.GetStructSize: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngUnit.Header.StructSize;
END; // .FUNCTION TLngUnitReader.GetStructSize

FUNCTION TLngUnitReader.GetNumLngStrArrays: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngUnit.ExtHeader.NumLngStrArrays;
END; // .FUNCTION TLngUnitReader.GetNumLngStrArrays

FUNCTION TLngUnitReader.GetUnicode: BOOLEAN;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngUnit.ExtHeader.Unicode;
END; // .FUNCTION TLngUnitReader.GetUnicode

FUNCTION TLngUnitReader.SeekLngStrArr (SeekLngStrArrInd: INTEGER): BOOLEAN;
VAR
(* On *)  LngStrArrReader: CLngStrArr.TLngStrArrReader;

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(SeekLngStrArrInd >= 0);
  LngStrArrReader :=  NIL;
  // * * * * * //
  RESULT  :=  SeekLngStrArrInd < Self.NumLngStrArrays;
  IF RESULT THEN BEGIN
    IF Self.fCurrLngStrArrInd > SeekLngStrArrInd THEN BEGIN
      Self.fCurrLngStrArrInd  :=  0;
    END; // .IF
    WHILE Self.fCurrLngStrArrInd < SeekLngStrArrInd DO BEGIN
      Self.ReadLngStrArr(LngStrArrReader);
    END; // .WHILE
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(LngStrArrReader);
END; // .FUNCTION TLngUnitReader.SeekLngStrArr

FUNCTION TLngUnitReader.ReadLngStrArr ((* n *) VAR LngStrArrReader: CLngStrArr.TLngStrArrReader): BOOLEAN;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.fCurrLngStrArrInd < Self.NumLngStrArrays;
  IF RESULT THEN BEGIN
    IF LngStrArrReader = NIL THEN BEGIN
      LngStrArrReader :=  CLngStrArr.TLngStrArrReader.Create;
    END; // .IF
    IF Self.fCurrLngStrArrInd = 0 THEN BEGIN
      Self.fCurrLngStrArr :=  POINTER(INTEGER(@Self.LngUnit.ExtHeader.UnitName) + Self.LngUnit.ExtHeader.UnitNameLen);
    END; // .IF
    LngStrArrReader.Connect(Self.fCurrLngStrArr, Self.StructMemoryBlockSize - (INTEGER(Self.fCurrLngStrArr) - INTEGER(Self.LngUnit)));
    INC(INTEGER(Self.fCurrLngStrArr), LngStrArrReader.StructSize);
    INC(Self.fCurrLngStrArrInd);
  END; // .IF
END; // .FUNCTION TLngUnitReader.ReadLngStrArr 

FUNCTION TLngUnitReader.FindLngStrArr (CONST LangName: STRING; OUT LngStrArrReader: CLngStrArr.TLngStrArrReader): BOOLEAN;
VAR
    SavedLngStrArrInd:  INTEGER;

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(LngStrArrReader = NIL);
  RESULT  :=  FALSE;
  // * * * * * //
  SavedLngStrArrInd :=  Self.CurrLngStrArrInd;
  Self.SeekLngStrArr(0);
  WHILE Self.ReadLngStrArr(LngStrArrReader) AND NOT RESULT DO BEGIN
    RESULT  :=  LngStrArrReader.LangName = LangName;
  END; // .WHILE
  Self.SeekLngStrArr(SavedLngStrArrInd);
  // * * * * * //
  IF NOT RESULT THEN BEGIN
    SysUtils.FreeAndNil(LngStrArrReader);
  END; // .IF
END; // .FUNCTION TLngUnitReader.FindLngStrArr

END.
