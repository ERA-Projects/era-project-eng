UNIT CLngStrArr;
{
DESCRIPTION:  Working with arrays of language strings
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES SysUtils, Math, Utils, StrLib, CLang, CBinString;

CONST
  LNGSTRARR_SIGNATURE = 'LAR';


TYPE
  TLangName = PACKED RECORD
    Name:     ARRAY [0..CLang.LANGNAME_LEN - 1] OF AnsiChar;
    _Align4:  ARRAY [1..(4 - CLang.LANGNAME_LEN MOD 4)] OF BYTE;
  END; // .RECORD TLangName

  PLngStrArrExtHeader = ^TLngStrArrExtHeader;
  TLngStrArrExtHeader = PACKED RECORD
    NumBinStrings:  INTEGER;
    LangName:       TLangName;  // !ASSERT LangName is unique in parent structure
    Unicode:        LONGBOOL;   // !ASSERT Unicode = Parent.Unicode
  END; // .RECORD TLngStrArrExtHeader
  
  PLngStrArr = ^TLngStrArr;
  TLngStrArr = PACKED RECORD (* FORMAT *)
    Header:     CLang.TLngStructHeader;
    ExtHeader:  TLngStrArrExtHeader;
    (*
    BinStrings: ARRAY ExtHeader.NumBinStrings OF TBinString;
    *)
    BinStrings: Utils.TEmptyRec;
  END; // .RECORD TLngStrArr
      
  TLngStrArrReader = CLASS
    (***) PROTECTED (***)
                fConnected:             BOOLEAN;
      (* Un *)  fLngStrArr:             PLngStrArr;
                fStructMemoryBlockSize: INTEGER;
                fCurrBinStringInd:      INTEGER;
      (* Un *)  fCurrBinString:         CBinString.PBinString;

      FUNCTION  GetUnicode: BOOLEAN;
      FUNCTION  GetLangName: STRING;
      FUNCTION  GetStructSize: INTEGER;
      FUNCTION  GetNumBinStrings: INTEGER;

    (***) PUBLIC (***)
      PROCEDURE Connect (LngStrArr: PLngStrArr; StructMemoryBlockSize: INTEGER);
      PROCEDURE Disconnect;
      FUNCTION  Validate (OUT Error: STRING): BOOLEAN;
      FUNCTION  SeekBinString (SeekBinStringInd: INTEGER): BOOLEAN;
      FUNCTION  ReadBinString ((* n *) VAR BinStringReader: CBinString.TBinStringReader): BOOLEAN;

      CONSTRUCTOR Create;

      PROPERTY  Connected:              BOOLEAN READ fConnected;
      PROPERTY  LngStrArr:              PLngStrArr READ fLngStrArr;
      PROPERTY  StructMemoryBlockSize:  INTEGER READ fStructMemoryBlockSize;
      PROPERTY  LangName:               STRING READ GetLangName;
      PROPERTY  StructSize:             INTEGER READ GetStructSize;
      PROPERTY  NumBinStrings:          INTEGER READ GetNumBinStrings;
      PROPERTY  Unicode:                BOOLEAN READ GetUnicode;
  END; // .CLASS TLngStrArrReader


(***)  IMPLEMENTATION  (***)


CONSTRUCTOR TLngStrArrReader.Create;
BEGIN
  Self.fConnected :=  FALSE;
END; // .CONSTRUCTOR TLngStrArrReader.Create

PROCEDURE TLngStrArrReader.Connect (LngStrArr: PLngStrArr; StructMemoryBlockSize: INTEGER);
BEGIN
  {!} ASSERT((LngStrArr <> NIL) OR (StructMemoryBlockSize = 0));
  {!} ASSERT(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fLngStrArr             :=  LngStrArr;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fCurrBinStringInd      :=  0;
  Self.fCurrBinString         :=  NIL;
END; // .PROCEDURE TLngStrArrReader.Connect

PROCEDURE TLngStrArrReader.Disconnect;
BEGIN
  Self.fConnected :=  FALSE;
END; // .PROCEDURE TLngStrArrReader.Disconnect

FUNCTION TLngStrArrReader.Validate (OUT Error: STRING): BOOLEAN;
VAR
        NumBinStrings:    INTEGER;
        Unicode:          BOOLEAN;
        RealStructSize:   INTEGER;
(* U *) BinString:        CBinString.PBinString;
(* O *) BinStringReader:  CBinString.TBinStringReader;
        i:                INTEGER;

  FUNCTION ValidateNumBinStringsField: BOOLEAN;
  BEGIN
    NumBinStrings :=  Self.NumBinStrings;
    RESULT        :=  (NumBinStrings >= 0) AND ((NumBinStrings * SIZEOF(TBinString) + SIZEOF(TLngStrArr)) <= Self.StructMemoryBlockSize);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid NumBinStrings field: ' + SysUtils.IntToStr(NumBinStrings);
    END; // .IF
  END; // .FUNCTION ValidateNumBinStringsField  
  
  FUNCTION ValidateLangNameField: BOOLEAN;
  VAR
    LangName: STRING;

  BEGIN
    LangName  :=  Self.LangName;
    RESULT    :=  CLang.IsValidLangName(LangName);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid LangName field: ' + LangName;
    END; // .IF
  END; // .FUNCTION ValidateLangNameField 

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(Error = '');
  RealStructSize  :=  -1;
  BinString       :=  NIL;
  BinStringReader :=  CBinString.TBinStringReader.Create;
  RESULT          :=  CLang.ValidateLngStructHeader(@Self.LngStrArr.Header, Self.StructMemoryBlockSize, SIZEOF(TLngStrArr), LNGSTRARR_SIGNATURE, Error);
  // * * * * * //
  RESULT  :=  RESULT AND
    ValidateNumBinStringsField AND
    ValidateLangNameField;
  IF RESULT THEN BEGIN
    Unicode         :=  Self.Unicode;
    RealStructSize  :=  SIZEOF(TLngStrArr);
    IF NumBinStrings > 0 THEN BEGIN
      i         :=  0;
      BinString :=  @Self.LngStrArr.BinStrings;
      WHILE RESULT AND (i < NumBinStrings) DO BEGIN
        BinStringReader.Connect(BinString, Self.StructMemoryBlockSize - RealStructSize, Unicode);
        RESULT  :=  BinStringReader.Validate(Error);
        IF RESULT THEN BEGIN
          RealStructSize  :=  RealStructSize + BinStringReader.StructSize;
          INC(INTEGER(BinString), BinStringReader.StructSize);
        END; // .IF
        INC(i);
      END; // .WHILE
    END; // .IF
  END; // .IF
  RESULT  :=  RESULT AND CLang.ValidateStructSize(Self.LngStrArr.Header.StructSize, RealStructSize, Error);
  // * * * * * //
  SysUtils.FreeAndNil(BinStringReader);
END; // .FUNCTION TLngStrArrReader.Validate

FUNCTION TLngStrArrReader.GetUnicode: BOOLEAN;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngStrArr.ExtHeader.Unicode;
END; // .FUNCTION TLngStrArrReader.GetStructSize

FUNCTION TLngStrArrReader.GetLangName: STRING;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  StrLib.BytesToAnsiString(@Self.LngStrArr.ExtHeader.LangName.Name[0], CLang.LANGNAME_LEN);
END; // .FUNCTION TLngStrArrReader.GetLangName

FUNCTION TLngStrArrReader.GetStructSize: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngStrArr.Header.StructSize;
END; // .FUNCTION TLngStrArrReader.GetStructSize

FUNCTION TLngStrArrReader.GetNumBinStrings: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.LngStrArr.ExtHeader.NumBinStrings;
END; // .FUNCTION TLngStrArrReader.GetNumBinStrings

FUNCTION TLngStrArrReader.SeekBinString (SeekBinStringInd: INTEGER): BOOLEAN;
VAR
(* On *)  BinStringReader: CBinString.TBinStringReader;

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(SeekBinStringInd >= 0);
  BinStringReader :=  NIL;
  // * * * * * //
  RESULT  :=  SeekBinStringInd < Self.NumBinStrings;
  IF RESULT THEN BEGIN
    IF Self.fCurrBinStringInd > SeekBinStringInd THEN BEGIN
      Self.fCurrBinStringInd  :=  0;
    END; // .IF
    WHILE Self.fCurrBinStringInd < SeekBinStringInd DO BEGIN
      Self.ReadBinString(BinStringReader);
    END; // .WHILE
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(BinStringReader);
END; // .FUNCTION TLngStrArrReader.SeekBinString

FUNCTION TLngStrArrReader.ReadBinString ((* n *) VAR BinStringReader: CBinString.TBinStringReader): BOOLEAN;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.fCurrBinStringInd < Self.NumBinStrings;
  IF RESULT THEN BEGIN
    IF BinStringReader = NIL THEN BEGIN
      BinStringReader :=  CBinString.TBinStringReader.Create;
    END; // .IF
    IF Self.fCurrBinStringInd = 0 THEN BEGIN
      Self.fCurrBinString :=  @Self.LngStrArr.BinStrings;
    END; // .IF
    BinStringReader.Connect(Self.fCurrBinString, Self.StructMemoryBlockSize - (INTEGER(Self.fCurrBinString) - INTEGER(Self.LngStrArr)), Self.Unicode);
    INC(INTEGER(Self.fCurrBinString), BinStringReader.StructSize);
    INC(Self.fCurrBinStringInd);
  END; // .IF
END; // .FUNCTION TLngStrArrReader.ReadBinString 

END.
