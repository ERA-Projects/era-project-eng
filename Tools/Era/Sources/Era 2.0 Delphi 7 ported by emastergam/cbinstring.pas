UNIT CBinString;
{
DESCRIPTION:  Working with binary strings
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES SysUtils, Utils, StrLib, CLang;

(*
Binary string is an atom in language system. It is either unicode or ansi string.
*)

TYPE
  PBinStringHeader = ^TBinStringHeader;
  TBinStringHeader = RECORD
    StrSize:  INTEGER;
  END; // .RECORD TBinStringHeader
  
  PBinString = ^TBinString;
  TBinString = PACKED RECORD (* FORMAT *)
    Header:   TBinStringHeader;
    (*
    Chars:    ARRAY Header.StrSize OF BYTE;
    *)
    Chars:    Utils.TEmptyRec;
  END; // .RECORD TBinString

  TBinStringReader = CLASS
    (***) PROTECTED (***)
                fConnected:             BOOLEAN;
      (* Un *)  fBinString:             PBinString;
                fStructMemoryBlockSize: INTEGER;
                fUnicode:               BOOLEAN;
      
      FUNCTION  GetStrSize: INTEGER;
      FUNCTION  GetStructSize: INTEGER;
    
    (***) PUBLIC (***)
      PROCEDURE Connect (BinString: PBinString; StructMemoryBlockSize: INTEGER; Unicode: BOOLEAN);
      PROCEDURE Disconnect;
      FUNCTION  Validate (OUT Error: STRING): BOOLEAN;
      FUNCTION  GetAnsiString:  AnsiString;
      FUNCTION  GetWideString:  WideString;

      CONSTRUCTOR Create;
      
      PROPERTY  Connected:              BOOLEAN READ fConnected;
      PROPERTY  BinString:              PBinString READ fBinString;
      PROPERTY  StructMemoryBlockSize:  INTEGER READ fStructMemoryBlockSize;
      PROPERTY  Unicode:                BOOLEAN READ fUnicode;
      PROPERTY  StrSize:                INTEGER READ GetStrSize;
      PROPERTY  StructSize:             INTEGER READ GetStructSize;
  END; // .CLASS TBinStringReader


(***)  IMPLEMENTATION  (***)
  
  
CONSTRUCTOR TBinStringReader.Create;
BEGIN
  Self.fConnected :=  FALSE;
END; // .CONSTRUCTOR TBinStringReader.Create

PROCEDURE TBinStringReader.Connect (BinString: PBinString; StructMemoryBlockSize: INTEGER; Unicode: BOOLEAN);
BEGIN
  {!} ASSERT((BinString <> NIL) OR (StructMemoryBlockSize = 0));
  {!} ASSERT(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fBinString             :=  BinString;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fUnicode               :=  Unicode;
END; // .PROCEDURE TBinStringReader.Connect

PROCEDURE TBinStringReader.Disconnect;
BEGIN
  Self.fConnected :=  FALSE;
END; // .PROCEDURE TBinStringReader.Disconnect

FUNCTION TBinStringReader.Validate (OUT Error: STRING): BOOLEAN;
  FUNCTION ValidateMinStructSize: BOOLEAN;
  BEGIN
    RESULT  :=  Self.StructMemoryBlockSize >= SIZEOF(TBinString);
    IF NOT RESULT THEN BEGIN
      Error :=  'The size of structure is too small: ' + SysUtils.IntToStr(Self.StructMemoryBlockSize) + '/' + SysUtils.IntToStr(SIZEOF(TBinString));
    END; // .IF
  END; // .FUNCTION ValidateMinStructSize

  FUNCTION ValidateStrSizeField: BOOLEAN;
  VAR
    StrSize:  INTEGER;

  BEGIN
    StrSize :=  Self.StrSize;
    RESULT  :=  (StrSize >= 0) AND ((SIZEOF(TBinString) + StrSize) <= Self.StructMemoryBlockSize);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid StrSize field: ' + SysUtils.IntToStr(StrSize);
    END; // .IF
  END; // .FUNCTION ValidateStrSizeField

BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(Error = '');
  RESULT  :=
    ValidateMinStructSize AND
    ValidateStrSizeField;
END; // .FUNCTION TBinStringReader.Validate

FUNCTION TBinStringReader.GetStrSize: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  Self.BinString.Header.StrSize;
END; // .FUNCTION TBinStringReader.GetStrSize

FUNCTION TBinStringReader.GetStructSize: INTEGER;
BEGIN
  {!} ASSERT(Self.Connected);
  RESULT  :=  SIZEOF(TBinString) + Self.StrSize;
END; // .FUNCTION TBinStringReader.GetStructSize

FUNCTION TBinStringReader.GetAnsiString: AnsiString;
BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(NOT Self.Unicode);
  RESULT  :=  StrLib.BytesToAnsiString(@Self.fBinString.Chars, Self.StrSize);
END; // .FUNCTION TBinStringReader.GetAnsiString

FUNCTION TBinStringReader.GetWideString: WideString;
BEGIN
  {!} ASSERT(Self.Connected);
  {!} ASSERT(Self.Unicode);
  RESULT  :=  StrLib.BytesToWideString(@Self.fBinString.Chars, Self.StrSize);
END; // .FUNCTION TBinStringReader.GetWideString
  
END.
