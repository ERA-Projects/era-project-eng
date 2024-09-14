unit CLang;
{
DESCRIPTION:  Auxiliary unit for Lang
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Math, Utils, Crypto;

const
  (* Names sizes restrictions *)
  CLIENTNAME_MAXLEN = 64;
  LANGNAME_LEN      = 3;


type
  PLngStructHeader = ^TLngStructHeader;
  TLngStructHeader = packed record
    Signature:    array [0..3] of AnsiChar;
    StructSize:   integer;
    BodyCRC32Sum: integer;
    Body:         Utils.TEmptyRec;
  end; // .record TLngStructHeader


function  GetCharSize (Unicode: boolean): integer;
function  IsValidLangName (const LangName: string): boolean;
function  IsValidClientName (const ClientName: string): boolean;
function  ValidateLngStructHeader
(
  (* n *)       Header:                 PLngStructHeader;
                StructMemoryBlockSize:  integer;
                MinStructSize:          integer;
          const Signature:              string;
          out   Error:                  string
): boolean;
function  ValidateStructSize (FormalSize, RealSize: integer; out Error: string): boolean;
function  GetEncodingPrefix (Unicode: boolean): string;


(***)  implementation  (***)


function GetCharSize (Unicode: boolean): integer;
begin
  if Unicode then begin
    result  :=  2;
  end // .if
  else begin
    result  :=  1;
  end; // .else
end; // .function GetCharSize

function IsValidLangName (const LangName: string): boolean;
const
  ALLOWED = ['a'..'z'];

var
  i:            integer;
  LangNameLen:  integer;
  
begin
  LangNameLen :=  Length(LangName);
  result      :=  LangNameLen = LANGNAME_LEN;
  // * * * * * //
  i :=  1;
  while (i <= LANGNAME_LEN) and result do begin
    result  :=  LangName[i] in ALLOWED;
    Inc(i);
  end; // .while
end; // .function IsValidLangName

function IsValidClientName (const ClientName: string): boolean;
const
  NO_DOTS_ALLOWED = FALSE;

begin
  result  :=  (Length(ClientName) <= CLIENTNAME_MAXLEN) and SysUtils.IsValidIdent(ClientName, NO_DOTS_ALLOWED);
end; // .function IsValidClientName

function ValidateLngStructHeader
(
  (* Un *)        Header:                 PLngStructHeader;
                  StructMemoryBlockSize:  integer;
                  MinStructSize:          integer;
            const Signature:              string;
            out   Error:                  string
): boolean;

var
  StructSize: integer;
  
  function ValidateMinStructSize: boolean;
  begin
    result  :=  StructMemoryBlockSize >= MinStructSize;
    if not result then begin
      Error :=  'The size of structure is too small: ' + SysUtils.IntToStr(StructMemoryBlockSize) + '/' + SysUtils.IntToStr(MinStructSize);
    end; // .if
  end; // .function ValidateMinStructSize

  function ValidateSignatureField: boolean;
  begin
    result  :=  Header.Signature = Signature;
    if not result then begin
      Error :=  'Structure signature is invalid: ' + Header.Signature + #13#10'. Expected: ' + Signature;
    end; // .if
  end; // .function ValidateSignatureField
  
  function ValidateStructSizeField: boolean;
  begin
    StructSize  :=  Header.StructSize;
    result      :=  Math.InRange(StructSize, MinStructSize, StructMemoryBlockSize);
    if not result then begin
      Error :=  'Invalid StructSize field: ' + SysUtils.IntToStr(StructSize);
    end; // .if
  end; // .function ValidateStructSizeField
  
  function ValidateBodyCrc32Field: boolean;
  var
    RealCRC32:  integer;
  
  begin
    RealCRC32 :=  Crypto.CRC32(@Header.Body, StructSize - sizeof(TLngStructHeader));
    result    :=  Header.BodyCRC32Sum = RealCRC32;
    if not result then begin
      Error :=  'CRC32 check failed. Original: ' + SysUtils.IntToStr(Header.BodyCRC32Sum) + '. Current: ' + SysUtils.IntToStr(RealCRC32);
    end; // .if
  end; // .function ValidateBodyCrc32Field

begin
  {!} Assert((Header <> nil) or (StructMemoryBlockSize = 0));
  {!} Assert(StructMemoryBlockSize >= 0);
  {!} Assert(MinStructSize >= sizeof(TLngStructHeader));
  {!} Assert(Error = '');
  result  :=
    ValidateMinStructSize and
    ValidateSignatureField and
    ValidateStructSizeField and
    ValidateBodyCrc32Field;
end; // .function ValidateLngStructHeader

function ValidateStructSize (FormalSize, RealSize: integer; out Error: string): boolean;
begin
  {!} Assert(FormalSize > 0);
  {!} Assert(RealSize >= 0);
  {!} Assert(Error = '');
  result  :=  FormalSize = RealSize;
  if not result then begin
    Error :=  'Invalid StructSize field: ' + SysUtils.IntToStr(FormalSize) + '. Real size: ' + SysUtils.IntToStr(RealSize);
  end; // .if
end; // .function ValidateStructSize

function GetEncodingPrefix (Unicode: boolean): string;
begin
  if Unicode then begin
    result  :=  'wide';
  end // .if
  else begin
    result  :=  'ansi';
  end; // .else
end; // .function GetEncodingPrefix

end.
