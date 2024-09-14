UNIT StrLib;
{
DESCRIPTION:  Strings processing
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Windows, Math, SysUtils, Classes, StrUtils, Utils;

CONST
  (* ExplodeEx *)
  INCLUDE_DELIM = TRUE;
  LIMIT_TOKENS  = TRUE;


TYPE
  (* IMPORT *)
  TArrayOfString  = Utils.TArrayOfString;
  
  PListItem = ^TListItem;
  TListItem = RECORD
          Data:     ARRAY OF CHAR;
          DataSize: INTEGER;
    {On}  NextItem: PListItem;
  END; // .RECORD TListItem
  
  TStrBuilder = CLASS
    (***) PROTECTED (***)
      {On}  fRootItem:  PListItem;
      {Un}  fCurrItem:  PListItem;
            fSize:      INTEGER;
{#}         MIN_BLOCK_SIZE : Integer;
    (***) PUBLIC (***)
      constructor Create;
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE Append (CONST Str: STRING);
      PROCEDURE AppendBuf (BufSize: INTEGER; {n} Buf: POINTER);
      FUNCTION  BuildStr: STRING;
      PROCEDURE Clear;
      
      PROPERTY  Size: INTEGER READ fSize;
  END; // .CLASS TStrBuilder


FUNCTION  InStrBounds (Pos: INTEGER; CONST Str: STRING): BOOLEAN;
FUNCTION  BytesToAnsiString (PBytes: PBYTE; NumBytes: INTEGER): AnsiString;
FUNCTION  BytesToWideString (PBytes: PBYTE; NumBytes: INTEGER): WideString;
FUNCTION  FindCharEx
(
        Ch:       CHAR;
  CONST Str:      STRING;
        StartPos: INTEGER;
  OUT   CharPos:  INTEGER
): BOOLEAN;

FUNCTION  ReverseFindCharEx
(
        Ch:       CHAR;
  CONST Str:      STRING;
        StartPos: INTEGER;
  OUT   CharPos:  INTEGER
): BOOLEAN;

FUNCTION  FindChar (Ch: CHAR; CONST Str: STRING; OUT CharPos: INTEGER): BOOLEAN;
FUNCTION  ReverseFindChar (Ch: CHAR; CONST Str: STRING; OUT CharPos: INTEGER): BOOLEAN;

FUNCTION  FindCharsetEx
(
        Charset:  Utils.TCharSet;
  CONST Str:      STRING;
        StartPos: INTEGER;
  OUT   CharPos:  INTEGER
): BOOLEAN;

FUNCTION  FindCharset (Charset: Utils.TCharSet; CONST Str: STRING; OUT CharPos: INTEGER): BOOLEAN;
FUNCTION  FindSubstrEx (CONST Substr, Str: STRING; StartPos: INTEGER; OUT SubstrPos: INTEGER): BOOLEAN;
FUNCTION  FindSubstr (CONST Substr, Str: STRING; OUT SubstrPos: INTEGER): BOOLEAN;
{
f('') => NIL
f(Str, '') => [Str]
}
FUNCTION  ExplodeEx (CONST Str, Delim: STRING; InclDelim: BOOLEAN; LimitTokens: BOOLEAN; MaxTokens: INTEGER): TArrayOfString;
FUNCTION  Explode (CONST Str: STRING; CONST Delim: STRING): TArrayOfString;
FUNCTION  Join (CONST Arr: TArrayOfString; CONST Glue: STRING): STRING;
{
TemplArgs - pairs of (ArgName, ArgValue).
Example: f('Hello, ~UserName~. You are ~Years~ years old.', ['Years', '20', 'UserName', 'Bob'], '~') =>
=> 'Hello, Bob. You are 20 years old'.
}
FUNCTION  BuildStr (CONST Template: STRING; TemplArgs: ARRAY OF STRING; TemplChar: CHAR): STRING;
FUNCTION  CharsetToStr (CONST Charset: Utils.TCharSet): STRING;
FUNCTION  IntToRoman (Value: INTEGER): STRING;
FUNCTION  CharToLower (c: CHAR): CHAR;
FUNCTION  HexCharToByte (HexChar: CHAR): BYTE;
FUNCTION  ByteToHexChar (ByteValue: BYTE): CHAR;
FUNCTION  Concat (CONST Strings: ARRAY OF STRING): STRING;


(***) IMPLEMENTATION (***)


DESTRUCTOR TStrBuilder.Destroy;
BEGIN
  Self.Clear;
END; // .DESTRUCTOR TStrBuilder.Destroy

PROCEDURE TStrBuilder.Append (CONST Str: STRING);
BEGIN
  Self.AppendBuf(LENGTH(Str), POINTER(Str));
END; // .PROCEDURE TStrBuilder.Append

PROCEDURE TStrBuilder.AppendBuf (BufSize: INTEGER; {n} Buf: POINTER);
VAR
  LeftPartSize:   INTEGER;
  RightPartSize:  INTEGER;
  
BEGIN
  {!} ASSERT(BufSize >= 0);
  {!} ASSERT((Buf <> NIL) OR (BufSize = 0));
  IF BufSize > 0 THEN BEGIN
    IF Self.fRootItem = NIL THEN BEGIN
      NEW(Self.fRootItem);
      Self.fCurrItem  :=  Self.fRootItem;
      SetLength(Self.fCurrItem.Data, Math.Max(BufSize, Self.MIN_BLOCK_SIZE));
      Self.fCurrItem.DataSize :=  0;
      Self.fCurrItem.NextItem :=  NIL;
    END; // .IF
    LeftPartSize  :=  Math.Min(BufSize, LENGTH(Self.fCurrItem.Data) - Self.fCurrItem.DataSize);
    RightPartSize :=  BufSize - LeftPartSize;
    IF LeftPartSize > 0 THEN BEGIN
      Utils.CopyMem(LeftPartSize, Buf, @Self.fCurrItem.Data[Self.fCurrItem.DataSize]);
    END; // .IF
    Self.fCurrItem.DataSize :=  Self.fCurrItem.DataSize + LeftPartSize;
    IF RightPartSize > 0 THEN BEGIN
      NEW(Self.fCurrItem.NextItem);
      Self.fCurrItem  :=  Self.fCurrItem.NextItem;
      SetLength(Self.fCurrItem.Data, Math.Max(RightPartSize, Self.MIN_BLOCK_SIZE));
      Self.fCurrItem.DataSize :=  RightPartSize;
      Self.fCurrItem.NextItem :=  NIL;
      Utils.CopyMem
      (
        RightPartSize,
        Utils.PtrOfs(Buf, LeftPartSize),
        @Self.fCurrItem.Data[0]
      );
    END; // .IF
    Self.fSize  :=  Self.fSize + BufSize;
  END; // .IF
END; // .PROCEDURE TStrBuilder.AppendBuf

FUNCTION TStrBuilder.BuildStr: STRING;
VAR
{U} Res:      POINTER;
{U} CurrItem: PListItem;
    Pos:      INTEGER;

BEGIN
  Res       :=  NIL;
  CurrItem  :=  Self.fRootItem;
  // * * * * * //
  SetLength(RESULT, Self.fSize);
  Res :=  POINTER(RESULT);
  Pos :=  0;
  WHILE CurrItem <> NIL DO BEGIN
    Utils.CopyMem(CurrItem.DataSize, @CurrItem.Data[0], Utils.PtrOfs(Res, Pos));
    Pos       :=  Pos + CurrItem.DataSize;
    CurrItem  :=  CurrItem.NextItem;
  END; // .WHILE
END; // .FUNCTION TStrBuilder.BuildStr

PROCEDURE TStrBuilder.Clear;
VAR
{Un}  CurrItem: PListItem;
{Un}  NextItem: PListItem;
  
BEGIN
  CurrItem  :=  Self.fRootItem;
  NextItem  :=  NIL;
  // * * * * * //
  WHILE CurrItem <> NIL DO BEGIN
    NextItem  :=  CurrItem.NextItem;
    DISPOSE(CurrItem);
    CurrItem  :=  NextItem;
  END; // .WHILE
  Self.fRootItem  :=  NIL;
  Self.fCurrItem  :=  NIL;
  Self.fSize      :=  0;
END; // .PROCEDURE TStrBuilder.Clear

FUNCTION InStrBounds (Pos: INTEGER; CONST Str: STRING): BOOLEAN;
BEGIN
  RESULT  :=  Math.InRange(Pos, 1, LENGTH(Str));
END; // .FUNCTION InStrBounds

FUNCTION BytesToAnsiString (PBytes: PBYTE; NumBytes: INTEGER): AnsiString;
BEGIN
  {!} ASSERT(PBytes <> NIL);
  {!} ASSERT(NumBytes >= 0);
  SetLength(RESULT, NumBytes);
  Utils.CopyMem(NumBytes, PBytes, POINTER(RESULT));
END; // .FUNCTION BytesToAnsiString

FUNCTION BytesToWideString (PBytes: PBYTE; NumBytes: INTEGER): WideString;
BEGIN
  {!} ASSERT(PBytes <> NIL);
  {!} ASSERT(NumBytes >= 0);
  {!} ASSERT(Utils.EVEN(NumBytes));
  SetLength(RESULT, NumBytes SHR 1);
  Utils.CopyMem(NumBytes, PBytes, POINTER(RESULT));
END; // .FUNCTION BytesToWideString

FUNCTION FindCharEx (Ch: CHAR; CONST Str: STRING; StartPos: INTEGER; OUT CharPos: INTEGER): BOOLEAN;
VAR
  StrLen: INTEGER;
  i:      INTEGER;

BEGIN
  StrLen  :=  LENGTH(Str);
  RESULT  :=  Math.InRange(StartPos, 1, StrLen);
  IF RESULT THEN BEGIN
    i :=  StartPos;
    WHILE (i <= StrLen) AND (Str[i] <> Ch) DO BEGIN
      INC(i);
    END; // .WHILE
    RESULT  :=  i <= StrLen;
    IF RESULT THEN BEGIN
      CharPos :=  i;
    END; // .IF
  END; // .IF
END; // .FUNCTION FindCharEx  

FUNCTION ReverseFindCharEx
(
        Ch:       CHAR;
  CONST Str:      STRING;
        StartPos: INTEGER;
  OUT   CharPos:  INTEGER
): BOOLEAN;

VAR
  StrLen: INTEGER;
  i:      INTEGER;

BEGIN
  StrLen  :=  LENGTH(Str);
  RESULT  :=  Math.InRange(StartPos, 1, StrLen);
  IF RESULT THEN BEGIN
    i :=  StartPos;
    WHILE (i >= 1) AND (Str[i] <> Ch) DO BEGIN
      DEC(i);
    END; // .WHILE
    RESULT  :=  i >= 1;
    IF RESULT THEN BEGIN
      CharPos :=  i;
    END; // .IF
  END; // .IF
END; // .FUNCTION ReverseFindCharEx

FUNCTION FindChar (Ch: CHAR; CONST Str: STRING; OUT CharPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  FindCharEx(Ch, Str, 1, CharPos);
END; // .FUNCTION FindChar

FUNCTION ReverseFindChar (Ch: CHAR; CONST Str: STRING; OUT CharPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  ReverseFindCharEx(Ch, Str, LENGTH(Str), CharPos);
END; // .FUNCTION ReverseFindChar

FUNCTION FindCharsetEx (Charset: Utils.TCharSet; CONST Str: STRING; StartPos: INTEGER; OUT CharPos: INTEGER): BOOLEAN;
VAR
  StrLen: INTEGER;
  i:      INTEGER;

BEGIN
  {!} ASSERT(StartPos >= 1);
  StrLen  :=  LENGTH(Str);
  RESULT  :=  StartPos <= StrLen;
  IF RESULT THEN BEGIN
    i :=  StartPos;
    WHILE (i <= StrLen) AND NOT (Str[i] IN Charset) DO BEGIN
      INC(i);
    END; // .WHILE
    RESULT  :=  i <= StrLen;
    IF RESULT THEN BEGIN
      CharPos :=  i;
    END; // .IF
  END; // .IF
END; // .FUNCTION FindCharsetEx

FUNCTION FindCharset (Charset: Utils.TCharSet; CONST Str: STRING; OUT CharPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  FindCharsetEx(Charset, Str, 1, CharPos);
END; // .FUNCTION FindCharset

FUNCTION FindSubstrEx (CONST Substr, Str: STRING; StartPos: INTEGER; OUT SubstrPos: INTEGER): BOOLEAN;
BEGIN
  SubstrPos :=  StrUtils.PosEx(Substr, Str, StartPos);
  RESULT    :=  SubstrPos <> 0;
END; // .FUNCTION FindSubstrEx

FUNCTION FindSubstr (CONST Substr, Str: STRING; OUT SubstrPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  FindSubstrEx(Substr, Str, 1, SubstrPos);
END; // .FUNCTION FindSubstr

FUNCTION ExplodeEx (CONST Str, Delim: STRING; InclDelim: BOOLEAN; LimitTokens: BOOLEAN; MaxTokens: INTEGER): TArrayOfString;
VAR
(* O *) DelimPosList:   Classes.TList {OF INTEGER};
        StrLen:         INTEGER;
        DelimLen:       INTEGER;
        DelimPos:       INTEGER;
        DelimsLimit:    INTEGER;
        NumDelims:      INTEGER;
        TokenStartPos:  INTEGER;
        TokenEndPos:    INTEGER;
        TokenLen:       INTEGER;
        i:              INTEGER;

BEGIN
  {!} ASSERT(NOT LimitTokens OR (MaxTokens > 0));
  DelimPosList  :=  Classes.TList.Create;
  // * * * * * //
  StrLen    :=  LENGTH(Str);
  DelimLen  :=  LENGTH(Delim);
  IF StrLen > 0 THEN BEGIN
    IF NOT LimitTokens THEN BEGIN
      MaxTokens :=  MAXLONGINT;
    END; // .IF
    IF DelimLen = 0 THEN BEGIN
      SetLength(RESULT, 1);
      RESULT[0] :=  Str;
    END // .IF
    ELSE BEGIN
      DelimsLimit :=  MaxTokens - 1;
      NumDelims   :=  0;
      DelimPos    :=  1;
      WHILE (NumDelims < DelimsLimit) AND FindSubstrEx(Delim, Str, DelimPos, DelimPos) DO BEGIN
        DelimPosList.Add(POINTER(DelimPos));
        INC(DelimPos);
        INC(NumDelims);
      END; // .WHILE
      DelimPosList.Add(POINTER(StrLen + 1));
      SetLength(RESULT, NumDelims + 1);
      TokenStartPos :=  1;
      FOR i:=0 TO NumDelims DO BEGIN
        TokenEndPos   :=  INTEGER(DelimPosList[i]);
        TokenLen      :=  TokenEndPos - TokenStartPos;
        IF InclDelim AND (i < NumDelims) THEN BEGIN
          TokenLen    :=  TokenLen + DelimLen;
        END; // .IF
        RESULT[i]     :=  Copy(Str, TokenStartPos, TokenLen);
        TokenStartPos :=  TokenStartPos + DelimLen + TokenLen;
      END; // .FOR
    END; // .ELSE
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(DelimPosList);
END; // .FUNCTION ExplodeEx

FUNCTION Explode (CONST Str: STRING; CONST Delim: STRING): TArrayOfString;
BEGIN
  RESULT  :=  ExplodeEx(Str, Delim, NOT INCLUDE_DELIM, NOT LIMIT_TOKENS, 0);
END; // .FUNCTION Explode

FUNCTION Join (CONST Arr: TArrayOfString; CONST Glue: STRING): STRING;
VAR
(* U *) Mem:        POINTER;
        ArrLen:     INTEGER;
        GlueLen:    INTEGER;
        NumPairs:   INTEGER;
        ResultSize: INTEGER;
        i:          INTEGER;

BEGIN
  Mem :=  NIL;
  // * * * * * //
  ArrLen  :=  LENGTH(Arr);
  GlueLen :=  LENGTH(Glue);
  IF ArrLen > 0 THEN BEGIN
    NumPairs    :=  ArrLen - 1;
    ResultSize  :=  0;
    FOR i:=0 TO ArrLen - 1 DO BEGIN
      ResultSize  :=  ResultSize + LENGTH(Arr[i]);
    END; // .FOR
    ResultSize  :=  ResultSize + NumPairs * GlueLen;
    SetLength(RESULT, ResultSize);
    Mem :=  POINTER(RESULT);
    IF GlueLen = 0 THEN BEGIN
      FOR i:=0 TO NumPairs - 1 DO BEGIN
        Utils.CopyMem(LENGTH(Arr[i]), POINTER(Arr[i]), Mem);
        Mem :=  Utils.PtrOfs(Mem, LENGTH(Arr[i]));
      END; // .FOR
    END // .IF
    ELSE BEGIN
      FOR i:=0 TO NumPairs - 1 DO BEGIN
        Utils.CopyMem(LENGTH(Arr[i]), POINTER(Arr[i]), Mem);
        Mem :=  Utils.PtrOfs(Mem, LENGTH(Arr[i]));
        Utils.CopyMem(LENGTH(Glue), POINTER(Glue), Mem);
        Mem :=  Utils.PtrOfs(Mem, LENGTH(Glue));
      END; // .FOR
    END; // .ELSE
    Utils.CopyMem(LENGTH(Arr[NumPairs]), POINTER(Arr[NumPairs]), Mem);
  END; // .IF
END; // .FUNCTION Join

FUNCTION BuildStr (CONST Template: STRING; TemplArgs: ARRAY OF STRING; TemplChar: CHAR): STRING;
VAR
  TemplTokens:    TArrayOfString;
  NumTemplTokens: INTEGER;
  NumTemplVars:   INTEGER;
  NumTemplArgs:   INTEGER;
  TemplTokenInd:  INTEGER;
  i:              INTEGER;
  
  FUNCTION FindTemplVar (CONST TemplVarName: STRING; OUT Ind: INTEGER): BOOLEAN;
  BEGIN
    Ind :=  1;
    WHILE (Ind < NumTemplTokens) AND (TemplTokens[Ind] <> TemplVarName) DO BEGIN
      INC(Ind, 2);
    END; // .WHILE
    RESULT  :=  Ind < NumTemplTokens;
  END; // .FUNCTION FindTemplVar

BEGIN
  NumTemplArgs  :=  LENGTH(TemplArgs);
  {!} ASSERT(Utils.EVEN(NumTemplArgs));
  // * * * * * //
  TemplTokens     :=  Explode(Template, TemplChar);
  NumTemplTokens  :=  LENGTH(TemplTokens);
  NumTemplVars    :=  (NumTemplTokens - 1) DIV 2;
  IF (NumTemplVars = 0) OR (NumTemplArgs = 0) THEN BEGIN
    RESULT  :=  Template;
  END // .IF
  ELSE BEGIN
    i :=  0;
    WHILE (i < NumTemplArgs) DO BEGIN
      IF FindTemplVar(TemplArgs[i], TemplTokenInd) THEN BEGIN
        TemplTokens[TemplTokenInd]  :=  TemplArgs[i + 1];
      END; // .IF
      INC(i, 2);
    END; // .WHILE
    RESULT  :=  StrLib.Join(TemplTokens, '');
  END; // .ELSE
END; // .FUNCTION BuildStr

FUNCTION CharsetToStr (CONST Charset: Utils.TCharSet): STRING;
CONST
  CHARSET_CAPACITY  = 256;
  SPACE_PER_ITEM    = 3;
  DELIMETER         = ', ';
  DELIM_LEN         = LENGTH(DELIMETER);

VAR
(* U *) BufPos:       ^CHAR;
        Buffer:       ARRAY [0..(SPACE_PER_ITEM * CHARSET_CAPACITY + DELIM_LEN * (CHARSET_CAPACITY - 1)) - 1] OF CHAR;
        BufSize:      INTEGER;
        StartItemInd: INTEGER;
        FinitItemInd: INTEGER;
        RangeLen:     INTEGER;
        
  PROCEDURE WriteItem (c: CHAR);
  BEGIN
    IF ORD(c) < ORD(' ') THEN BEGIN
      BufPos^ :=  '#';                            INC(BufPos);
      BufPos^ :=  CHR(ORD(c) DIV 10 + ORD('0'));  INC(BufPos);
      BufPos^ :=  CHR(ORD(c) MOD 10 + ORD('0'));  INC(BufPos);
    END // .IF
    ELSE BEGIN
      BufPos^ :=  '"';  INC(BufPos);
      BufPos^ :=  c;    INC(BufPos);
      BufPos^ :=  '"';  INC(BufPos);
    END; // .ELSE
    INC(BufSize, SPACE_PER_ITEM);
  END; // .PROCEDURE WriteItem

BEGIN
  BufPos  :=  @Buffer[0];
  // * * * * * //
  BufSize       :=  0;
  StartItemInd  :=  0;
  WHILE StartItemInd < CHARSET_CAPACITY DO BEGIN
    IF CHR(StartItemInd) IN Charset THEN BEGIN
      IF BufSize > 0 THEN BEGIN
        BufPos^ :=  DELIMETER[1]; INC(BufPos);
        BufPos^ :=  DELIMETER[2]; INC(BufPos);
        INC(BufSize, DELIM_LEN);
      END; // .IF
      FinitItemInd  :=  StartItemInd + 1;
      WHILE (FinitItemInd < CHARSET_CAPACITY) AND (CHR(FinitItemInd) IN Charset) DO BEGIN
        INC(FinitItemInd);
      END; // .WHILE
      RangeLen  :=  FinitItemInd - StartItemInd;
      WriteItem(CHR(StartItemInd));
      IF RangeLen > 1 THEN BEGIN
        IF RangeLen > 2 THEN BEGIN
          BufPos^ :=  '-';
          INC(BufPos);
          INC(BufSize);
        END; // .IF
        WriteItem(CHR(FinitItemInd - 1));
      END; // .IF
      StartItemInd  :=  FinitItemInd;
    END // .IF
    ELSE BEGIN
      INC(StartItemInd);
    END; // .ELSE
  END; // .WHILE
  SetLength(RESULT, BufSize);
  Utils.CopyMem(BufSize, @Buffer[0], POINTER(RESULT));
END; // .FUNCTION CharsetToStr

FUNCTION IntToRoman (Value: INTEGER): STRING;
CONST
  Arabics:  ARRAY [0..12] OF INTEGER  = (1,4,5,9,10,40,50,90,100,400,500,900,1000);
  Romans:   ARRAY [0..12] OF STRING   = ('I','IV','V','IX','X','XL','L','XC','C','CD','D','CM','M');

VAR
  i:  INTEGER;

BEGIN
  {!} ASSERT(Value > 0);
  RESULT  :=  '';
  FOR i:=12 DOWNTO 0 DO BEGIN
    WHILE Value >= Arabics[i] DO BEGIN
      Value   :=  Value - Arabics[i];
      RESULT  :=  RESULT + Romans[i];
    END; // .WHILE
  END; // .FOR
END; // .FUNCTION IntToRoman

FUNCTION CharToLower (c: CHAR): CHAR;
BEGIN
  RESULT  :=  CHR(INTEGER(Windows.CharLower(Ptr(ORD(c)))));
END; // .FUNCTION CharToLower

FUNCTION HexCharToByte (HexChar: CHAR): BYTE;
BEGIN
  HexChar :=  CharToLower(HexChar);
  IF HexChar IN ['0'..'9'] THEN BEGIN
    RESULT  :=  ORD(HexChar) - ORD('0');
  END // .IF
  ELSE IF HexChar IN ['a'..'f'] THEN BEGIN
    RESULT  :=  ORD(HexChar) - ORD('a') + 10;
  END // .ELSEIF
  ELSE BEGIN
    RESULT  :=  0;
    {!} ASSERT(FALSE);
  END; // .ELSE
END; // .FUNCTION HexCharToByte

FUNCTION ByteToHexChar (ByteValue: BYTE): CHAR;
BEGIN
  {!} ASSERT(Math.InRange(ByteValue, $00, $0F));
  IF ByteValue < 10 THEN BEGIN
    RESULT  :=  CHR(ByteValue + ORD('0'));
  END // .IF
  ELSE BEGIN
    RESULT  :=  CHR(ByteValue - 10 + ORD('A'));
  END; // .ELSE
END; // .FUNCTION ByteToHexChar

FUNCTION Concat (CONST Strings: ARRAY OF STRING): STRING;
VAR
  ResLen: INTEGER;
  Offset: INTEGER;
  StrLen: INTEGER;
  i:      INTEGER;

BEGIN
  ResLen  :=  0;
  FOR i:=0 TO HIGH(Strings) DO BEGIN
    ResLen  :=  ResLen + LENGTH(Strings[i]);
  END; // .FOR
  
  SetLength(RESULT, ResLen);
  
  Offset  :=  0;
  FOR i:=0 TO HIGH(Strings) DO BEGIN
    StrLen  :=  LENGTH(Strings[i]);
    IF StrLen > 0 THEN BEGIN
      Utils.CopyMem(StrLen, POINTER(Strings[i]), Utils.PtrOfs(POINTER(RESULT), Offset));
      Offset  :=  Offset + StrLen;
    END; // .IF
  END; // .FOR
END; // .FUNCTION Concat

{#}constructor TStrBuilder.Create;
{#}begin
{#}  inherited;
{#}  MIN_BLOCK_SIZE := 65536;
{#}end;

END.
