unit StrLib;
{
DESCRIPTION:  Strings processing
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Windows, Math, SysUtils, Classes, StrUtils, Utils;

const
  (* ExplodeEx *)
  INCLUDE_DELIM = TRUE;
  LIMIT_TOKENS  = TRUE;

  BINARY_CHARACTERS: set of char = [#0..#8, #11..#12, #14..#31];

type
  (* IMPORT *)
  TArrayOfStr  = Utils.TArrayOfStr;

  TTrimSide  = (LEFT_SIDE, RIGHT_SIDE);
  TTrimSides = set of LEFT_SIDE..RIGHT_SIDE;

  PListItem = ^TListItem;
  TListItem = record
          Data:     array of char;
          DataSize: integer;
    {On}  NextItem: PListItem;
  end; // .record TListItem
  
  IStrBuilder = interface
    procedure Append (const Str: string);
    procedure AppendBuf (BufSize: integer; {n} Buf: pointer);
    procedure WriteByte (Value: byte);
    procedure WriteWord (Value: word);
    procedure WriteInt (Value: integer);
    function  BuildStr: string;
    function  BuildBuf: TArrayOfByte;
    procedure Clear;
  end; // .interface IStrBuilder

  TStrBuilder = class (TInterfacedObject, IStrBuilder)
   protected
    const
      MIN_BLOCK_SIZE = 65536;

    var
      {On} fRootItem: PListItem;
      {Un} fCurrItem: PListItem;
           fSize:     integer;

   public
    destructor  Destroy; override;
    procedure Append (const Str: string);
    procedure AppendBuf (BufSize: integer; {n} Buf: pointer);
    procedure WriteByte (Value: byte);
    procedure WriteWord (Value: word);
    procedure WriteInt (Value: integer);
    function  BuildStr: string;
    function  BuildBuf: TArrayOfByte;
    procedure Clear;

    property  Size: integer read fSize;
  end; // .class TStrBuilder

  IByteSource = interface
    (* Reads up to specified number of bytes to buffer. Returns number of actually read bytes *)
    function Read (Count: integer; {Un} Buf: pointer): integer;
  end;

  TStrByteSource = class (TInterfacedObject, IByteSource)
   protected
    fData:    string;
    fDataLen: integer;
    fPos:     integer;

   public
    constructor Create (const Data: string);
    
    function Read (Count: integer; {Un} Buf: pointer): integer;
  end; // .TStrByteSource

  TBufByteSource = class (TInterfacedObject, IByteSource)
   protected
    {Un} fBuf:     pointer;
         fBufSize: integer;
         fPos:     integer;

   public
    constructor Create ({Un} Buf: pointer; BufSize: integer);
    
    function Read (Count: integer; {Un} Buf: pointer): integer;
  end; // .TBufByteSource

  IByteMapper = interface
    function GetSource: IByteSource;
    function ReadInt: integer;
    function ReadStr (StrLen: integer): string;
    function ReadStrWithLenField (StrLenFieldSize: integer): string;
  end;

  (* All methods assert reading success *)
  TByteMapper = class (TInterfacedObject, IByteMapper)
   protected
    fByteSource: IByteSource;

   public
    constructor Create (ByteSource: IByteSource);

    function GetSource: IByteSource;
    function ReadInt: integer;
    function ReadStr (StrLen: integer): string;
    function ReadStrWithLenField (StrLenFieldSize: integer): string;
  end; // .TByteMapper

function  MakeStr: IStrBuilder;
function  StrAsByteSource (const Str: string): IByteSource;
function  BufAsByteSource ({Un} Buf: pointer; BufSize: integer): IByteSource;
function  MapBytes (ByteSource: IByteSource): IByteMapper;
function  InStrBounds (Pos: integer; const Str: string): boolean;
function  BytesToAnsiString (PBytes: PBYTE; NumBytes: integer): AnsiString;
function  BytesToWideString (PBytes: PBYTE; NumBytes: integer): WideString;
function  FindCharEx
(
        Ch:       char;
  const Str:      string;
        StartPos: integer;
  out   CharPos:  integer
): boolean;

function  ReverseFindCharEx
(
        Ch:       char;
  const Str:      string;
        StartPos: integer;
  out   CharPos:  integer
): boolean;

function  FindChar (Ch: char; const Str: string; out CharPos: integer): boolean;
function  ReverseFindChar (Ch: char; const Str: string; out CharPos: integer): boolean;

function  FindCharsetEx
(
        Charset:  Utils.TCharSet;
  const Str:      string;
        StartPos: integer;
  out   CharPos:  integer
): boolean;

function  FindCharset (Charset: Utils.TCharSet; const Str: string; out CharPos: integer): boolean;
// Both FindSubstr routines are wrappers around Delphi Pos function
function  FindSubstrEx (const Substr, Str: string; StartPos: integer; out SubstrPos: integer): boolean;
function  FindSubstr (const Substr, Str: string; out SubstrPos: integer): boolean;
// Knuth-Morris-Pratt stable speed fast search algorithm.
// F('', Haystack, StartPos in range of Haystack) => true, StartPos
// F('', Haystack, StartPos out of range of Haystack) => false
function  FindStr (const Needle, Haystack: string; out FoundPos: integer): boolean;
function  FindStrEx (const Needle, Haystack: string; Pos: integer; out FoundPos: integer): boolean;
{
f('') => NIL
f(Str, '') => [Str]
}
function  ExplodeEx (const Str, Delim: string; InclDelim: boolean; LimitTokens: boolean; MaxTokens: integer): TArrayOfStr;
function  Explode (const Str: string; const Delim: string): TArrayOfStr;
function  Join (const Arr: TArrayOfStr; const Glue: string): string;
{
TemplArgs - pairs of (ArgName, ArgValue).
Example: f('Hello, ~UserName~. You are ~Years~ years old.', ['Years', '20', 'UserName', 'Bob'], '~') =>
=> 'Hello, Bob. You are 20 years old'.
}
function  BuildStr (const Template: string; TemplArgs: array of string; TemplChar: char): string;
function  CharsetToStr (const Charset: Utils.TCharSet): string;
function  IntToRoman (Value: integer): string;
function  CharToLower (c: char): char;
function  CharToUpper (c: char): char;
function  Capitalize (const Str: string): string;
function  HexCharToByte (HexChar: char): byte;
function  ByteToHexChar (ByteValue: byte): char;
function  Concat (const Strings: array of string): string;
{
Base file name does not include extension.
}
function  TrimEx (const Str: string; const TrimCharSet: Utils.TCharSet; TrimSides: TTrimSides = [LEFT_SIDE, RIGHT_SIDE]): string;
function  ExtractBaseFileName (const FilePath: string): string;
function  SubstrBeforeChar (const Str: string; Ch: char): string;
function  Match (const Str, Pattern: string): boolean;
function  ExtractFromPchar (Str: pchar; Count: integer): string;
function  BufToStr ({n} Buf: pointer; BufSize: integer): string;
// Detects characters in the BINARY_CHARACTERS set
function  IsBinaryStr (const Str: string): boolean;
function  Utf8ToAnsi (const Str: string): string;


(***) implementation (***)


destructor TStrBuilder.Destroy;
begin
  Self.Clear;
end; // .destructor TStrBuilder.Destroy

procedure TStrBuilder.Append (const Str: string);
begin
  Self.AppendBuf(Length(Str), pointer(Str));
end; // .procedure TStrBuilder.Append

procedure TStrBuilder.AppendBuf (BufSize: integer; {n} Buf: pointer);
var
  LeftPartSize:  integer;
  RightPartSize: integer;
  
begin
  {!} Assert(Utils.IsValidBuf(Buf, BufSize));
  if BufSize > 0 then begin
    if Self.fRootItem = nil then begin
      New(Self.fRootItem);
      Self.fCurrItem := Self.fRootItem;
      SetLength(Self.fCurrItem.Data, Math.Max(BufSize, Self.MIN_BLOCK_SIZE));
      Self.fCurrItem.DataSize := 0;
      Self.fCurrItem.NextItem := nil;
    end; // .if
    
    LeftPartSize  := Math.Min(BufSize, Length(Self.fCurrItem.Data) - Self.fCurrItem.DataSize);
    RightPartSize := BufSize - LeftPartSize;
    
    if LeftPartSize > 0 then begin
      Utils.CopyMem(LeftPartSize, Buf, @Self.fCurrItem.Data[Self.fCurrItem.DataSize]);
    end; // .if
    
    Self.fCurrItem.DataSize := Self.fCurrItem.DataSize + LeftPartSize;
    
    if RightPartSize > 0 then begin
      New(Self.fCurrItem.NextItem);
      Self.fCurrItem := Self.fCurrItem.NextItem;
      SetLength(Self.fCurrItem.Data, Math.Max(RightPartSize, Self.MIN_BLOCK_SIZE));
      Self.fCurrItem.DataSize := RightPartSize;
      Self.fCurrItem.NextItem := nil;
      Utils.CopyMem(RightPartSize, Utils.PtrOfs(Buf, LeftPartSize), @Self.fCurrItem.Data[0]);
    end; // .if
    
    Self.fSize := Self.fSize + BufSize;
  end; // .if
end; // .procedure TStrBuilder.AppendBuf

procedure TStrBuilder.WriteByte (Value: byte);
begin
  Self.AppendBuf(sizeof(Value), @Value);
end; // .procedure TStrBuilder.WriteByte

procedure TStrBuilder.WriteWord (Value: word);
begin
  Self.AppendBuf(sizeof(Value), @Value);
end; // .procedure TStrBuilder.WriteWord

procedure TStrBuilder.WriteInt (Value: integer);
begin
  Self.AppendBuf(sizeof(Value), @Value);
end; // .procedure TStrBuilder.WriteInt

function TStrBuilder.BuildStr: string;
var
{U} CurrItem: PListItem;
    Pos:      integer;

begin
  CurrItem := Self.fRootItem;
  // * * * * * //
  SetLength(result, Self.fSize);
  Pos := 0;
  
  while CurrItem <> nil do begin
    Utils.CopyMem(CurrItem.DataSize, @CurrItem.Data[0], Utils.PtrOfs(pointer(result), Pos));
    Pos      := Pos + CurrItem.DataSize;
    CurrItem := CurrItem.NextItem;
  end; // .while
end; // .function TStrBuilder.BuildStr

function TStrBuilder.BuildBuf: TArrayOfByte;
var
{U} CurrItem: PListItem;
    Pos:      integer;

begin
  CurrItem := Self.fRootItem;
  // * * * * * //
  SetLength(result, Self.fSize);
  Pos := 0;
  
  while CurrItem <> nil do begin
    Utils.CopyMem(CurrItem.DataSize, @CurrItem.Data[0], Utils.PtrOfs(pointer(result), Pos));
    Pos      := Pos + CurrItem.DataSize;
    CurrItem := CurrItem.NextItem;
  end; // .while
end; // .function TStrBuilder.BuildBuf

procedure TStrBuilder.Clear;
var
{Un}  CurrItem: PListItem;
{Un}  NextItem: PListItem;
  
begin
  CurrItem := Self.fRootItem;
  NextItem := nil;
  // * * * * * //
  while CurrItem <> nil do begin
    NextItem := CurrItem.NextItem;
    Dispose(CurrItem);
    CurrItem := NextItem;
  end; // .while
  
  Self.fRootItem := nil;
  Self.fCurrItem := nil;
  Self.fSize     := 0;
end; // .procedure TStrBuilder.Clear

constructor TStrByteSource.Create (const Data: string);
begin
  inherited Create;
  fData    := Data;
  fDataLen := length(Data);
  fPos     := 0;
end;

function TStrByteSource.Read (Count: integer; {Un} Buf: pointer): integer;
begin
  {!} Assert(Utils.IsValidBuf(Buf, Count));

  if Count = 0 then begin
    result := 0;
  end else begin
    result := Min(Count, fDataLen - fPos);

    if result > 0 then begin
      Utils.CopyMem(Count, @fData[fPos + 1], Buf);
      inc(fPos, result);
    end;
  end;
end; // .function TStrByteSource.Read

constructor TBufByteSource.Create ({Un} Buf: pointer; BufSize: integer);
begin
  {!} Assert(Utils.IsValidBuf(Buf, BufSize));
  
  inherited Create;
  
  fBuf     := Buf;
  fBufSize := BufSize;
  fPos     := 0;
end;

function TBufByteSource.Read (Count: integer; {Un} Buf: pointer): integer;
begin
  {!} Assert(Utils.IsValidBuf(Buf, Count));

  if Count = 0 then begin
    result := 0;
  end else begin
    result := Min(Count, fBufSize - fPos);

    if result > 0 then begin
      Utils.CopyMem(Count, Utils.PtrOfs(fBuf, fPos), Buf);
      inc(fPos, result);
    end;
  end;
end; // .function TBufByteSource.Read

constructor TByteMapper.Create (ByteSource: IByteSource);
begin
  inherited Create;
  fByteSource := ByteSource;
end;

function TByteMapper.GetSource: IByteSource;
begin
  result := fByteSource;
end;

function TByteMapper.ReadInt: integer;
begin
  {!} Assert(fByteSource.Read(sizeof(integer), @result) = sizeof(integer));
end;

function TByteMapper.ReadStr (StrLen: integer): string;
begin
  {!} Assert(StrLen >= 0);
  SetLength(result, StrLen);

  if StrLen > 0 then begin
    {!} Assert(fByteSource.Read(StrLen, @result[1]) = StrLen);
  end;
end;

function TByteMapper.ReadStrWithLenField (StrLenFieldSize: integer): string;
var
  StrLen: integer;

begin
  {!} Assert(StrLenFieldSize in [1, 2, 4, sizeof(integer)]);
  StrLen := 0;
  result := '';
  {!} Assert(fByteSource.Read(StrLenFieldSize, @StrLen) = StrLenFieldSize);
  {!} Assert(StrLen >= 0);

  if StrLen > 0 then begin
    SetLength(result, StrLen);
    {!} Assert(fByteSource.Read(StrLen, @result[1]) = StrLen);
  end;
end; // .function TByteMapper.ReadStrWithLenField

function MakeStr: IStrBuilder;
begin
  result := TStrBuilder.Create;
end; // .function MakeStr

function StrAsByteSource (const Str: string): IByteSource;
begin
  result := TStrByteSource.Create(Str);
end;

function BufAsByteSource ({Un} Buf: pointer; BufSize: integer): IByteSource;
begin
  result := TBufByteSource.Create(Buf, BufSize);
end;

function MapBytes (ByteSource: IByteSource): IByteMapper;
begin
  result := TByteMapper.Create(ByteSource);
end;

function InStrBounds (Pos: integer; const Str: string): boolean;
begin
  result := Math.InRange(Pos, 1, Length(Str));
end; // .function InStrBounds

function BytesToAnsiString (PBytes: PBYTE; NumBytes: integer): AnsiString;
begin
  {!} Assert(PBytes <> nil);
  {!} Assert(NumBytes >= 0);
  SetLength(result, NumBytes);
  Utils.CopyMem(NumBytes, PBytes, pointer(result));
end; // .function BytesToAnsiString

function BytesToWideString (PBytes: PBYTE; NumBytes: integer): WideString;
begin
  {!} Assert(PBytes <> nil);
  {!} Assert(NumBytes >= 0);
  {!} Assert(Utils.EVEN(NumBytes));
  SetLength(result, NumBytes shr 1);
  Utils.CopyMem(NumBytes, PBytes, pointer(result));
end; // .function BytesToWideString

function FindCharEx (Ch: char; const Str: string; StartPos: integer; out CharPos: integer): boolean;
var
  StrLen: integer;
  i:      integer;

begin
  StrLen := Length(Str);
  result := Math.InRange(StartPos, 1, StrLen);
  if result then begin
    i :=  StartPos;
    while (i <= StrLen) and (Str[i] <> Ch) do begin
      Inc(i);
    end; // .while
    result := i <= StrLen;
    if result then begin
      CharPos :=  i;
    end; // .if
  end; // .if
end; // .function FindCharEx  

function ReverseFindCharEx
(
        Ch:       char;
  const Str:      string;
        StartPos: integer;
  out   CharPos:  integer
): boolean;

var
  StrLen: integer;
  i:      integer;

begin
  StrLen := Length(Str);
  result := Math.InRange(StartPos, 1, StrLen);
  if result then begin
    i :=  StartPos;
    while (i >= 1) and (Str[i] <> Ch) do begin
      Dec(i);
    end; // .while
    result := i >= 1;
    if result then begin
      CharPos :=  i;
    end; // .if
  end; // .if
end; // .function ReverseFindCharEx

function FindChar (Ch: char; const Str: string; out CharPos: integer): boolean;
begin
  result := FindCharEx(Ch, Str, 1, CharPos);
end; // .function FindChar

function ReverseFindChar (Ch: char; const Str: string; out CharPos: integer): boolean;
begin
  result := ReverseFindCharEx(Ch, Str, Length(Str), CharPos);
end; // .function ReverseFindChar

function FindCharsetEx (Charset: Utils.TCharSet; const Str: string; StartPos: integer; out CharPos: integer): boolean;
var
  StrLen: integer;
  i:      integer;

begin
  {!} Assert(StartPos >= 1);
  StrLen := Length(Str);
  result := StartPos <= StrLen;
  if result then begin
    i :=  StartPos;
    while (i <= StrLen) and not (Str[i] in Charset) do begin
      Inc(i);
    end; // .while
    result := i <= StrLen;
    if result then begin
      CharPos :=  i;
    end; // .if
  end; // .if
end; // .function FindCharsetEx

function FindCharset (Charset: Utils.TCharSet; const Str: string; out CharPos: integer): boolean;
begin
  result := FindCharsetEx(Charset, Str, 1, CharPos);
end; // .function FindCharset

function FindSubstrEx (const Substr, Str: string; StartPos: integer; out SubstrPos: integer): boolean;
var
  Pos: integer;

begin
  Pos := StrUtils.PosEx(Substr, Str, StartPos);

  if Pos <> 0 then begin
    SubstrPos := Pos;
    result    := true;
  end else begin
    result    := false;
  end; // .else
end; // .function FindSubstrEx

function FindSubstr (const Substr, Str: string; out SubstrPos: integer): boolean;
begin
  result := FindSubstrEx(Substr, Str, 1, SubstrPos);
end; // .function FindSubstr

function FindStrEx (const Needle, Haystack: string; Pos: integer; out FoundPos: integer): boolean;
const
  MAX_STATIC_FALLBACK_TABLE_LEN = 255;
  START_STRING_POS              = 1;

var
{O} FallbackTableBuf:          PEndlessIntArr;
    FallbackTableStackStorage: array [0..MAX_STATIC_FALLBACK_TABLE_LEN] of integer;
{U} FallbackTable:             PEndlessIntArr;
  
    NeedleLen:               integer;
    HaystackLen:             integer;
    FirstNeedleChar:         char;
    FirstFourNeedleChars:    integer;
    FarthestStartPos:        integer; // Last pos where there is any sense to start searching
    FallbackPos:             integer;
    HaystackPtr:             pinteger;
    HaystackEndMinusFourPtr: pinteger;
    i:                       integer;

  procedure GenerateFallbackTable;
  var
    k: integer;

  begin
    // Initialize fallback table pointer to either stack storage or memory buffer
    if NeedleLen <= MAX_STATIC_FALLBACK_TABLE_LEN then begin
      FallbackTable := @FallbackTableStackStorage[0];
    end else begin
      GetMem(FallbackTableBuf, (NeedleLen + 1) * sizeof(integer));
      FallbackTable := FallbackTableBuf;
    end; // .else

    // First not matched char always redirect to start, starting analysis from the the second one
    FallbackTable[START_STRING_POS] := START_STRING_POS;
    k                               := START_STRING_POS + 1;

    while k <= NeedleLen do begin
      // Search for the next occurense of needle prefix in the needle itself
      repeat
        FallbackTable[k] := START_STRING_POS;
        Inc(k);
      until (k > NeedleLen) or (Needle[k - 1] = FirstNeedleChar);

      // First char is already checked, starting from the second one
      i := START_STRING_POS + 1;

      if k <= NeedleLen then begin
        // While characters match needle prefix, fallback offsets grow
        // ab[abababab]c[ab]d
        // 11[12345678]1[12]1
        repeat
          FallbackTable[k] := i;
          Inc(i);
          Inc(k);
        until (k > NeedleLen) or (Needle[i] <> Needle[k]);
      end; // .if
    end; // .while
  end; // .procedure GenerateFallbackTable

  procedure FindFirstNeedleChars;
  begin
    if Pos <= FarthestStartPos then begin
      HaystackPtr := @Haystack[Pos];

      while (cardinal(HaystackPtr) <= cardinal(HaystackEndMinusFourPtr)) and
            (HaystackPtr^ <> FirstFourNeedleChars)
      do begin
        Inc(pbyte(HaystackPtr));
      end; // .while

      i := START_STRING_POS + sizeof(integer);

      if cardinal(HaystackPtr) <= cardinal(HaystackEndMinusFourPtr) then begin
        Pos := Pos + (integer(HaystackPtr) - integer(@Haystack[Pos])) + sizeof(integer);
      end else begin
        Pos := MAXINT;
      end; // .else
    end; // .if
  end; // .procedure FindFirstNeedleChars

begin
  FallbackTableBuf := nil;
  FallbackTable    := nil;
  // * * * * * //
  if Pos < START_STRING_POS then begin
    Pos := START_STRING_POS;
  end; // .if

  NeedleLen        := Length(Needle);
  HaystackLen      := Length(Haystack);
  FarthestStartPos := HaystackLen - NeedleLen + 1;
  result           := (Pos <= FarthestStartPos) and (HaystackLen > 0);
  
  if result then begin
    if NeedleLen = 0 then begin
      FoundPos := START_STRING_POS;
    end else if NeedleLen <= sizeof(integer) then begin
      result := FindSubstrEx(Needle, Haystack, Pos, FoundPos);
    end else begin
      FirstNeedleChar         := Needle[START_STRING_POS];
      FirstFourNeedleChars    := pinteger(@Needle[START_STRING_POS])^;
      HaystackEndMinusFourPtr := @Haystack[HaystackLen - sizeof(integer) + 1];
      GenerateFallbackTable;

      i := START_STRING_POS;
      FindFirstNeedleChars;

      while (Pos <= HaystackLen) and (i <= NeedleLen) do begin
        if Haystack[Pos] = Needle[i] then begin
          Inc(Pos);
          Inc(i);
        end else begin
          FallbackPos := FallbackTable[i];

          if FallbackPos = START_STRING_POS then begin
            FindFirstNeedleChars;
          end else begin
            i := FallbackPos;
          end; // .else
        end; // .else
      end; // .while

      result := i > NeedleLen;

      if result then begin
        FoundPos := Pos - NeedleLen;
      end; // .if
    end; // .else
  end; // .if
  // * * * * * //
  FreeMem(FallbackTableBuf);
end; // .function FindStrEx

function FindStr (const Needle, Haystack: string; out FoundPos: integer): boolean;
begin
  result := FindStrEx(Needle, Haystack, 1, FoundPos);
end; // .function FindStr

function ExplodeEx (const Str, Delim: string; InclDelim: boolean; LimitTokens: boolean; MaxTokens: integer): TArrayOfStr;
var
(* O *) DelimPosList:   Classes.TList {OF INTEGER};
        StrLen:         integer;
        DelimLen:       integer;
        DelimPos:       integer;
        DelimsLimit:    integer;
        NumDelims:      integer;
        TokenStartPos:  integer;
        TokenEndPos:    integer;
        TokenLen:       integer;
        i:              integer;

begin
  {!} Assert(not LimitTokens or (MaxTokens > 0));
  DelimPosList := Classes.TList.Create;
  // * * * * * //
  StrLen   := Length(Str);
  DelimLen := Length(Delim);
  if StrLen > 0 then begin
    if not LimitTokens then begin
      MaxTokens :=  MAXLONGINT;
    end; // .if
    if DelimLen = 0 then begin
      SetLength(result, 1);
      result[0] :=  Str;
    end // .if
    else begin
      DelimsLimit :=  MaxTokens - 1;
      NumDelims  := 0;
      DelimPos   := 1;
      while (NumDelims < DelimsLimit) and FindSubstrEx(Delim, Str, DelimPos, DelimPos) do begin
        DelimPosList.Add(pointer(DelimPos));
        Inc(DelimPos);
        Inc(NumDelims);
      end; // .while
      DelimPosList.Add(pointer(StrLen + 1));
      SetLength(result, NumDelims + 1);
      TokenStartPos :=  1;
      for i:=0 to NumDelims do begin
        TokenEndPos  := integer(DelimPosList[i]);
        TokenLen     := TokenEndPos - TokenStartPos;
        if InclDelim and (i < NumDelims) then begin
          TokenLen   := TokenLen + DelimLen;
        end; // .if
        result[i]    := Copy(Str, TokenStartPos, TokenLen);
        TokenStartPos :=  TokenStartPos + DelimLen + TokenLen;
      end; // .for
    end; // .else
  end; // .if
  // * * * * * //
  SysUtils.FreeAndNil(DelimPosList);
end; // .function ExplodeEx

function Explode (const Str: string; const Delim: string): TArrayOfStr;
begin
  result := ExplodeEx(Str, Delim, not INCLUDE_DELIM, not LIMIT_TOKENS, 0);
end; // .function Explode

function Join (const Arr: TArrayOfStr; const Glue: string): string;
var
(* U *) Mem:        pointer;
        ArrLen:     integer;
        GlueLen:    integer;
        NumPairs:   integer;
        ResultSize: integer;
        i:          integer;

begin
  Mem :=  nil;
  // * * * * * //
  ArrLen := Length(Arr);
  GlueLen :=  Length(Glue);
  if ArrLen > 0 then begin
    NumPairs   := ArrLen - 1;
    ResultSize := 0;
    for i:=0 to ArrLen - 1 do begin
      ResultSize := ResultSize + Length(Arr[i]);
    end; // .for
    ResultSize := ResultSize + NumPairs * GlueLen;
    SetLength(result, ResultSize);
    Mem :=  pointer(result);
    if GlueLen = 0 then begin
      for i:=0 to NumPairs - 1 do begin
        Utils.CopyMem(Length(Arr[i]), pointer(Arr[i]), Mem);
        Mem :=  Utils.PtrOfs(Mem, Length(Arr[i]));
      end; // .for
    end // .if
    else begin
      for i:=0 to NumPairs - 1 do begin
        Utils.CopyMem(Length(Arr[i]), pointer(Arr[i]), Mem);
        Mem :=  Utils.PtrOfs(Mem, Length(Arr[i]));
        Utils.CopyMem(Length(Glue), pointer(Glue), Mem);
        Mem :=  Utils.PtrOfs(Mem, Length(Glue));
      end; // .for
    end; // .else
    Utils.CopyMem(Length(Arr[NumPairs]), pointer(Arr[NumPairs]), Mem);
  end; // .if
end; // .function Join

function BuildStr (const Template: string; TemplArgs: array of string; TemplChar: char): string;
var
  TemplTokens:    TArrayOfStr;
  NumTemplTokens: integer;
  NumTemplSlots:  integer;
  NumTemplArgs:   integer;
  TemplTokenInd:  integer;
  i:              integer;

  function GetParam (const ParamName: string): string;
  var
    j: integer;

  begin
    j := 0;

    while (j < NumTemplArgs) do begin
      if TemplArgs[j] = ParamName then begin
        result := TemplArgs[j + 1];
        exit;
      end;

      inc(j, 2);
    end;
    
    result := TemplChar + ParamName + TemplChar;
  end; // .function GetParam

begin
  NumTemplArgs := Length(TemplArgs);
  {!} Assert(Utils.Even(NumTemplArgs));
  // * * * * * //
  if NumTemplArgs = 0 then begin
    result := Template;
  end else begin
    TemplTokens    := Explode(Template, TemplChar);
    NumTemplTokens := Length(TemplTokens);
    NumTemplSlots  := (NumTemplTokens - 1) div 2;

    if NumTemplSlots = 0 then begin
      result := Template;
    end else begin
      i := 1;

      while (i < NumTemplTokens) do begin
        TemplTokens[i] := GetParam(TemplTokens[i]);
        inc(i, 2);
      end;
      
      result := StrLib.Join(TemplTokens, '');
    end; // .else
  end; // .else
end; // .function BuildStr

function CharsetToStr (const Charset: Utils.TCharSet): string;
const
  CHARSET_CAPACITY  = 256;
  SPACE_PER_ITEM    = 3;
  DELIMETER         = ', ';
  DELIM_LEN         = Length(DELIMETER);

var
(* U *) BufPos:       ^char;
        Buffer:       array [0..(SPACE_PER_ITEM * CHARSET_CAPACITY + DELIM_LEN * (CHARSET_CAPACITY - 1)) - 1] of char;
        BufSize:      integer;
        StartItemInd: integer;
        FinitItemInd: integer;
        RangeLen:     integer;
        
  procedure WriteItem (c: char);
  begin
    if ORD(c) < ORD(' ') then begin
      BufPos^ :=  '#';                            Inc(BufPos);
      BufPos^ :=  CHR(ORD(c) div 10 + ORD('0'));  Inc(BufPos);
      BufPos^ :=  CHR(ORD(c) mod 10 + ORD('0'));  Inc(BufPos);
    end // .if
    else begin
      BufPos^ :=  '"';  Inc(BufPos);
      BufPos^ :=  c;    Inc(BufPos);
      BufPos^ :=  '"';  Inc(BufPos);
    end; // .else
    Inc(BufSize, SPACE_PER_ITEM);
  end; // .procedure WriteItem

begin
  BufPos := @Buffer[0];
  // * * * * * //
  BufSize      := 0;
  StartItemInd := 0;
  while StartItemInd < CHARSET_CAPACITY do begin
    if CHR(StartItemInd) in Charset then begin
      if BufSize > 0 then begin
        BufPos^ :=  DELIMETER[1]; Inc(BufPos);
        BufPos^ :=  DELIMETER[2]; Inc(BufPos);
        Inc(BufSize, DELIM_LEN);
      end; // .if
      FinitItemInd := StartItemInd + 1;
      while (FinitItemInd < CHARSET_CAPACITY) and (CHR(FinitItemInd) in Charset) do begin
        Inc(FinitItemInd);
      end; // .while
      RangeLen := FinitItemInd - StartItemInd;
      WriteItem(CHR(StartItemInd));
      if RangeLen > 1 then begin
        if RangeLen > 2 then begin
          BufPos^ :=  '-';
          Inc(BufPos);
          Inc(BufSize);
        end; // .if
        WriteItem(CHR(FinitItemInd - 1));
      end; // .if
      StartItemInd := FinitItemInd;
    end // .if
    else begin
      Inc(StartItemInd);
    end; // .else
  end; // .while
  SetLength(result, BufSize);
  Utils.CopyMem(BufSize, @Buffer[0], pointer(result));
end; // .function CharsetToStr

function IntToRoman (Value: integer): string;
const
  Arabics:  array [0..12] of integer  = (1,4,5,9,10,40,50,90,100,400,500,900,1000);
  Romans:   array [0..12] of string   = ('I','IV','V','IX','X','XL','L','XC','C','CD','D','CM','M');

var
  i:  integer;

begin
  {!} Assert(Value > 0);
  result := '';
  for i:=12 downto 0 do begin
    while Value >= Arabics[i] do begin
      Value  := Value - Arabics[i];
      result := result + Romans[i];
    end; // .while
  end; // .for
end; // .function IntToRoman

function CharToLower (c: char): char;
begin
  result := CHR(integer(Windows.CharLower(Ptr(ORD(c)))));
end; // .function CharToLower

function CharToUpper (c: char): char;
begin
  result := CHR(integer(Windows.CharUpper(Ptr(ORD(c)))));
end; // .function CharToUpper

function Capitalize (const Str: string): string;
begin
  result := Str;

  if result <> '' then begin
    result[1] := CharToUpper(result[1]);
  end; // .if
end; // .function Capitalize

function HexCharToByte (HexChar: char): byte;
begin
  HexChar :=  CharToLower(HexChar);
  if HexChar in ['0'..'9'] then begin
    result := ORD(HexChar) - ORD('0');
  end // .if
  else if HexChar in ['a'..'f'] then begin
    result := ORD(HexChar) - ORD('a') + 10;
  end // .ELSEIF
  else begin
    result := 0;
    {!} Assert(FALSE);
  end; // .else
end; // .function HexCharToByte

function ByteToHexChar (ByteValue: byte): char;
begin
  {!} Assert(Math.InRange(ByteValue, $00, $0F));
  if ByteValue < 10 then begin
    result := CHR(ByteValue + ORD('0'));
  end // .if
  else begin
    result := CHR(ByteValue - 10 + ORD('A'));
  end; // .else
end; // .function ByteToHexChar

function Concat (const Strings: array of string): string;
var
  ResLen: integer;
  Offset: integer;
  StrLen: integer;
  i:      integer;

begin
  ResLen := 0;
  for i:=0 to High(Strings) do begin
    ResLen := ResLen + Length(Strings[i]);
  end; // .for
  
  SetLength(result, ResLen);
  
  Offset := 0;
  for i:=0 to High(Strings) do begin
    StrLen := Length(Strings[i]);
    if StrLen > 0 then begin
      Utils.CopyMem(StrLen, pointer(Strings[i]), Utils.PtrOfs(pointer(result), Offset));
      Offset := Offset + StrLen;
    end; // .if
  end; // .for
end; // .function Concat

function TrimEx (const Str: string; const TrimCharSet: Utils.TCharSet; TrimSides: TTrimSides = [LEFT_SIDE, RIGHT_SIDE]): string;
var
  StrLen: integer;
  Left:   integer;
  Right:  integer;

begin
  result := '';

  if Str <> '' then begin
    StrLen := length(Str);
    Left   := 1;
    Right  := StrLen;

    if LEFT_SIDE in TrimSides then begin
      while (Left <= Right) and (Str[Left] in TrimCharSet) do begin
        inc(Left);
      end;
    end; // .if

    if (RIGHT_SIDE in TrimSides) and (Left <= Right) then begin
      while (Right >= 1) and (Str[Right] in TrimCharSet) do begin
        dec(Right);
      end;
    end;

    if Left <= Right then begin
      result := Copy(Str, Left, Right - Left + 1);
    end;
  end; // .if
end; // .function TrimEx

function ExtractBaseFileName (const FilePath: string): string;
var
  DotPos: integer;

begin
  result := SysUtils.ExtractFileName(FilePath);
  
  if ReverseFindChar('.', result, DotPos) then begin
    SetLength(result, DotPos - 1);
  end; // .if
end; // .function ExtractBaseFileName

function SubstrBeforeChar (const Str: string; Ch: char): string;
var
  CharPos:  integer;

begin
  if FindChar(Ch, Str, CharPos) then begin
    result := COPY(Str, 1, CharPos - 1);
  end // .if
  else begin
    result := Str;
  end; // .else
end; // .function SubstrBeforeChar

function Match (const Str, Pattern: string): boolean;
const
  ONE_SYM_WILDCARD  = '?';
  ANY_SYMS_WILDCARD = '*';
  WILDCARDS         = [ONE_SYM_WILDCARD, ANY_SYMS_WILDCARD];

type
  TState  =
  (
    STATE_STRICT_COMPARE,       // [abc]*?*?**cde?x*
    STATE_SKIP_WILDCARDS,       // abc[*?*?**]cde?x*
    STATE_FIRST_LETTER_SEARCH,  // abc*?*?**[c]de?x*
    STATE_MATCH_SUBSTR_TAIL,    // abc*?*?**c[de?x]*
    STATE_EXIT
  );

(*
  Non-greedy algorithm tries to treat ANY_SYMS_WILLCARD as the shortest possible string.
  Token is a substring between Base position and ANY_SYMS_WILLCARD or end of string in the template
  and corresponding matching substring in the string.
  
  Match "abcecd78e" against "a*cd*e": (Token is wrapped in parenthesis)
  
  (abcecd78e)
  (a*cd*e)
  
  => STRICT_COMPARE until * (success)
  
  (a  )(bcecd78e)
  (a* )(cd*e)
  
  => FIRST_LETTER_SEARCH "c" (success)
  
  (ab )(cecd78e)
  (a* )(cd*e)
  
  => MATCH_SUBSTR_TAIL "d" (fail)
  
  (abc)(ecd78e)
  (a* )(cd*e)
  
  => FIND_FIRST_LETTER "c" (success)
  
  (abce)(cd78e)
  (a*  )(cd*e)
  
  => MATCH_SUBSTR_TAIL "d" (success)
  
  (abce)(cd  )(78e)
  (a*  )(cd* )(e)
  
  => FIND_FIRST_LETTER "e" (success)
  
  (abce)(cd78)(e)
  (a*  )(cd* )(e)
  
  => exit
*)

(*
  Contracts for states:
    STATE_STRICT_COMPARE:
      - Entry state, not-reenterable
      - Matches character-to-character, including ONE_SYM_WILLCARD
      - Exits on mismatch
      - => STATE_SKIP_WILDCARDS
    STATE_SKIP_WILDCARDS:
      - Skips sequence of WILDCARDS
      - Increases position in the string for each ONE_SYM_WILDCARD
      - Exits on end of pattern
      - Initializes character "c" to current pattern character
      - => STATE_FIRST_LETTER_SEARCH
    STATE_FIRST_LETTER_SEARCH
      - Character [c] must be initialized before entering
      - Searches for character [c] in the string
      - Exits on end of string
      - Sets New token positions for string and token to current positions
      - => STATE_MATCH_SUBSTR_TAIL
    STATE_MATCH_SUBSTR_TAIL:
      - Matches character-to-character, including ONE_SYM_WILLCARD
      - Exits on end of string
      - Increases current token position in string by 1 and roll-backs to tokens positions in
        string and template on end of template or last character mismatch
      - => STATE_SKIP_WILDCARDS
*)
  
var
  State:          TState;
  StrLen:         integer;
  PatternLen:     integer;
  StrBasePos:     integer;  // Start position of current token
  PatternBasePos: integer;  // Start position of current token
  s:              integer;  // Pos in Pattern
  p:              integer;  // Pos in Str
  c:              char;     // First letter to search for
  
  
  procedure SkipMatchingSubstr;
  begin
    while
      (p <= PatternLen)                 and
      (s <= StrLen)                     and
      (Pattern[p] <> ANY_SYMS_WILDCARD) and
      (
        (Str[s]     = Pattern[p]) or
        (Pattern[p] = ONE_SYM_WILDCARD)
      )
    do begin
      Inc(p);
      Inc(s);
    end; // .while
  end; // .procedure SkipMatchingSubstr

begin
  StrLen         := Length(Str);
  PatternLen     := Length(Pattern);
  StrBasePos     := 1;
  PatternBasePos := 1;
  s              := 1;
  p              := 1;
  c              := #0;
  State          := STATE_STRICT_COMPARE;
  result         := FALSE;
  
  while State <> STATE_EXIT do begin
    case State of 
      STATE_STRICT_COMPARE:
        begin
          SkipMatchingSubstr;
          
          if (p > PatternLen) or (Pattern[p] <> ANY_SYMS_WILDCARD) then begin
            State :=  STATE_EXIT;
          end // .if
          else begin
            STATE :=  STATE_SKIP_WILDCARDS;
          end; // .else
        end; // .case STATE_STRICT_COMPARE
        
      STATE_SKIP_WILDCARDS:
        begin
          while (p <= PatternLen) and (Pattern[p] in WILDCARDS) do begin
            if Pattern[p] = ONE_SYM_WILDCARD then begin
              Inc(s);
            end; // .if
            
            Inc(p);
          end; // .while
          
          if p <= PatternLen then begin
            c    := Pattern[p];
            State :=  STATE_FIRST_LETTER_SEARCH;
          end // .if
          else begin
            if s <= StrLen then begin
              s :=  StrLen + 1;
            end; // .if
          
            State :=  STATE_EXIT;
          end; // .else
        end; // .case STATE_SKIP_WILDCARDS
        
      STATE_FIRST_LETTER_SEARCH:
        begin
          while (s <= StrLen) and (Str[s] <> c) do begin
            Inc(s);
          end; // .while
          
          if s > StrLen then begin
            State :=  STATE_EXIT;
          end // .if
          else begin
            StrBasePos     := s;
            PatternBasePos := p;
            Inc(p);
            Inc(s);
            State          := STATE_MATCH_SUBSTR_TAIL;
          end; // .else
        end; // .case STATE_FIRST_LETTER_SEARCH
        
      STATE_MATCH_SUBSTR_TAIL:
        begin
          SkipMatchingSubstr;
          
          if (p > PatternLen) or (Pattern[p] = ANY_SYMS_WILDCARD) then begin
            State :=  STATE_STRICT_COMPARE;
          end // .if
          else if ((PAttern[p]) = ONE_SYM_WILDCARD) or (s > StrLen) then begin
            STATE := STATE_EXIT;
          end // .ELSEIF
          else begin
            Inc(StrBasePos);
            p    := PatternBasePos;
            s    := StrBasePos;
            State :=  STATE_FIRST_LETTER_SEARCH;
          end; // .else
        end; // .case STATE_MATCH_SUBSTR_TAIL
    end; // .SWITCH State
  end; // .while
  
  result := (s = (StrLen + 1)) and (p = (PatternLen + 1));
end; // .function Match

function ExtractFromPchar (Str: pchar; Count: integer): string;
var
  Buf:    pchar;
  StrLen: integer;

begin
  {!} Assert(Str <> nil);
  {!} Assert(Count >= 0);
  Buf := Str;
  // * * * * * //
  if Count > 0 then begin
    while (Count > 0) and (Str^ <> #0) do begin
      Dec(Count);
      Inc(Str);
    end; // .while
    
    StrLen := Str - Buf;
    SetLength(result, StrLen);
    Utils.CopyMem(StrLen, Buf, pointer(result));
  end; // .if
end; // .function ExtractFromPchar

function BufToStr ({n} Buf: pointer; BufSize: integer): string;
begin
  {!} Assert(Utils.IsValidBuf(Buf, BufSize));
  SetLength(result, BufSize);

  if BufSize > 0 then begin
    Utils.CopyMem(BufSize, Buf, @result[1]);
  end; // .if
end; // .function BufToStr

function IsBinaryStr (const Str: string): boolean;
var
  i: integer;

begin
  i := 1;
  
  while (i <= Length(Str)) and not (Str[i] in BINARY_CHARACTERS) do begin
    Inc(i);
  end; // .while

  result := i <= Length(Str);
end; // .function IsBinaryStr

function Utf8ToAnsi (const Str: string): string;
var
  TempBuf:    string;
  TempBufLen: integer;
  ResBufLen:  integer;

begin
  result := '';

  if Str <> '' then begin
    TempBufLen := Windows.MultiByteToWideChar(Windows.CP_UTF8, 0, pointer(Str), length(Str), nil, 0);

    if TempBufLen <> 0 then begin
      SetLength(TempBuf, TempBufLen * sizeof(WideChar));
      TempBufLen := Windows.MultiByteToWideChar(Windows.CP_UTF8, 0, pointer(Str), length(Str), @TempBuf[1], TempBufLen);
      ResBufLen  := Windows.WideCharToMultiByte(Windows.CP_ACP, 0, pointer(TempBuf), TempBufLen, nil, 0, nil, nil);
      SetLength(result, ResBufLen * sizeof(char));
      ResBufLen  := Windows.WideCharToMultiByte(Windows.CP_ACP, 0, pointer(TempBuf), TempBufLen, @result[1], ResBufLen, nil, nil);

      if length(result) <> ResBufLen then begin
        SetLength(result, ResBufLen);
      end;
    end;
  end; // .if
end; // .function Utf8ToAnsi

end.
