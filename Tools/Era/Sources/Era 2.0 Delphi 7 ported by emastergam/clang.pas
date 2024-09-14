UNIT CLang;
{
DESCRIPTION:  Auxiliary unit for Lang
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES SysUtils, Math, Utils, Crypto;

CONST
  (* Names sizes restrictions *)
  CLIENTNAME_MAXLEN = 64;
  LANGNAME_LEN      = 3;


TYPE
  PLngStructHeader = ^TLngStructHeader;
  TLngStructHeader = PACKED RECORD
    Signature:    ARRAY [0..3] OF AnsiChar;
    StructSize:   INTEGER;
    BodyCRC32Sum: INTEGER;
    Body:         Utils.TEmptyRec;
  END; // .RECORD TLngStructHeader


FUNCTION  GetCharSize (Unicode: BOOLEAN): INTEGER;
FUNCTION  IsValidLangName (CONST LangName: STRING): BOOLEAN;
FUNCTION  IsValidClientName (CONST ClientName: STRING): BOOLEAN;
FUNCTION  ValidateLngStructHeader
(
  (* n *)       Header:                 PLngStructHeader;
                StructMemoryBlockSize:  INTEGER;
                MinStructSize:          INTEGER;
          CONST Signature:              STRING;
          OUT   Error:                  STRING
): BOOLEAN;
FUNCTION  ValidateStructSize (FormalSize, RealSize: INTEGER; OUT Error: STRING): BOOLEAN;
FUNCTION  GetEncodingPrefix (Unicode: BOOLEAN): STRING;


(***)  IMPLEMENTATION  (***)


FUNCTION GetCharSize (Unicode: BOOLEAN): INTEGER;
BEGIN
  IF Unicode THEN BEGIN
    RESULT  :=  2;
  END // .IF
  ELSE BEGIN
    RESULT  :=  1;
  END; // .ELSE
END; // .FUNCTION GetCharSize

FUNCTION IsValidLangName (CONST LangName: STRING): BOOLEAN;
CONST
  ALLOWED = ['a'..'z'];

VAR
  i:            INTEGER;
  LangNameLen:  INTEGER;
  
BEGIN
  LangNameLen :=  LENGTH(LangName);
  RESULT      :=  LangNameLen = LANGNAME_LEN;
  // * * * * * //
  i :=  1;
  WHILE (i <= LANGNAME_LEN) AND RESULT DO BEGIN
    RESULT  :=  LangName[i] IN ALLOWED;
    INC(i);
  END; // .WHILE
END; // .FUNCTION IsValidLangName

FUNCTION IsValidClientName (CONST ClientName: STRING): BOOLEAN;
CONST
  NO_DOTS_ALLOWED = FALSE;

BEGIN
{#}  RESULT  :=  (LENGTH(ClientName) <= CLIENTNAME_MAXLEN) AND SysUtils.IsValidIdent(ClientName{, NO_DOTS_ALLOWED});
END; // .FUNCTION IsValidClientName

FUNCTION ValidateLngStructHeader
(
  (* Un *)        Header:                 PLngStructHeader;
                  StructMemoryBlockSize:  INTEGER;
                  MinStructSize:          INTEGER;
            CONST Signature:              STRING;
            OUT   Error:                  STRING
): BOOLEAN;

VAR
  StructSize: INTEGER;
  
  FUNCTION ValidateMinStructSize: BOOLEAN;
  BEGIN
    RESULT  :=  StructMemoryBlockSize >= MinStructSize;
    IF NOT RESULT THEN BEGIN
      Error :=  'The size of structure is too small: ' + SysUtils.IntToStr(StructMemoryBlockSize) + '/' + SysUtils.IntToStr(MinStructSize);
    END; // .IF
  END; // .FUNCTION ValidateMinStructSize

  FUNCTION ValidateSignatureField: BOOLEAN;
  BEGIN
    RESULT  :=  Header.Signature = Signature;
    IF NOT RESULT THEN BEGIN
      Error :=  'Structure signature is invalid: ' + Header.Signature + #13#10'. Expected: ' + Signature;
    END; // .IF
  END; // .FUNCTION ValidateSignatureField
  
  FUNCTION ValidateStructSizeField: BOOLEAN;
  BEGIN
    StructSize  :=  Header.StructSize;
    RESULT      :=  Math.InRange(StructSize, MinStructSize, StructMemoryBlockSize);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid StructSize field: ' + SysUtils.IntToStr(StructSize);
    END; // .IF
  END; // .FUNCTION ValidateStructSizeField
  
  FUNCTION ValidateBodyCrc32Field: BOOLEAN;
  VAR
    RealCRC32:  INTEGER;
  
  BEGIN
    RealCRC32 :=  Crypto.CRC32(@Header.Body, StructSize - SIZEOF(TLngStructHeader));
    RESULT    :=  Header.BodyCRC32Sum = RealCRC32;
    IF NOT RESULT THEN BEGIN
      Error :=  'CRC32 check failed. Original: ' + SysUtils.IntToStr(Header.BodyCRC32Sum) + '. Current: ' + SysUtils.IntToStr(RealCRC32);
    END; // .IF
  END; // .FUNCTION ValidateBodyCrc32Field

BEGIN
  {!} ASSERT((Header <> NIL) OR (StructMemoryBlockSize = 0));
  {!} ASSERT(StructMemoryBlockSize >= 0);
  {!} ASSERT(MinStructSize >= SIZEOF(TLngStructHeader));
  {!} ASSERT(Error = '');
  RESULT  :=
    ValidateMinStructSize AND
    ValidateSignatureField AND
    ValidateStructSizeField AND
    ValidateBodyCrc32Field;
END; // .FUNCTION ValidateLngStructHeader

FUNCTION ValidateStructSize (FormalSize, RealSize: INTEGER; OUT Error: STRING): BOOLEAN;
BEGIN
  {!} ASSERT(FormalSize > 0);
  {!} ASSERT(RealSize >= 0);
  {!} ASSERT(Error = '');
  RESULT  :=  FormalSize = RealSize;
  IF NOT RESULT THEN BEGIN
    Error :=  'Invalid StructSize field: ' + SysUtils.IntToStr(FormalSize) + '. Real size: ' + SysUtils.IntToStr(RealSize);
  END; // .IF
END; // .FUNCTION ValidateStructSize

FUNCTION GetEncodingPrefix (Unicode: BOOLEAN): STRING;
BEGIN
  IF Unicode THEN BEGIN
    RESULT  :=  'wide';
  END // .IF
  ELSE BEGIN
    RESULT  :=  'ansi';
  END; // .ELSE
END; // .FUNCTION GetEncodingPrefix

END.
