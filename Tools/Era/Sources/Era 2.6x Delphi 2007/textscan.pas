unit TextScan;
{
DESCRIPTION:  Provides high-level access to solid text in string
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Math, Utils;

type
  (* IMPORT *)
  TCharSet  = Utils.TCharSet;

  TTextScanner = class
    (***) protected (***)
      fTextBuf:         string;
      fPos:             integer;  // Start from 1
      fLineN:           integer;  // Start from 1
      fEndOfLineMarker: char;
      fLineStartPos:    integer;  // Position of EndOfLineMarker; LinePos = Pos - LineStartPos
      fTextBufLen:      integer;
      fEndOfText:       boolean;
    
    (***) public (***)
      property  TextBuf:          string read fTextBuf;
      property  Pos:              integer read fPos;          // Start from 1
      property  LineN:            integer read fLineN;        // Start from 1
      property  EndOfLineMarker:  char read fEndOfLineMarker;
      property  LineStartPos:     integer read fLineStartPos; // Position of EndOfLineMarker; LinePos = Pos - LineStartPos
      property  TextBufLen:       integer read fTextBufLen;
      property  EndOfText:        boolean read fEndOfText;
      property  Eot:              boolean read fEndOfText;
    
      constructor Create;
      function  IsValidPos (CheckPos: integer): boolean;
      (* Returns #0 for EndOfText *)
      function  c: char;
      function  GetCurrChar (out Res: char): boolean;
      function  ReadChar (out Res: char): boolean;
      function  GetCharAtPos (TargetPos: integer; out Res: char): boolean;
      function  GetCharAtRelPos (RelPos: integer; out Res: char): boolean;
      function  CharAtPos (TargetPos: integer): char;
      function  CharAtPosRel (RelPos: integer): char;
      function  GetSubstrAtPos (TargetPos, SubstrLen: integer): string;
      function  GetSubstrAtRelPos (RelPos, SubstrLen: integer): string;
      function  GotoNextChar: boolean;
      function  GotoPrevChar: boolean;
      function  GotoPos (TargetPos: integer): boolean;
      function  GotoRelPos (RelPos: integer): boolean;
      function  GotoNextLine: boolean;
      function  GotoPrevLine: boolean;
      function  GotoLine (TargetLine: integer): boolean;
      function  GotoRelLine (RelLineN: integer): boolean;
      function  PosToLine (TargetPos: integer; out LineN, LinePos: integer): boolean;
      function  SkipChars (Ch: char): boolean;
      function  SkipCharset (const Charset: TCharSet): boolean;
      function  FindChar (Ch: char): boolean;
      function  FindCharset (const Charset: TCharSet): boolean;
      function  ReadToken (const TokenCharset: TCharSet; out Token: string): boolean;
      function  ReadTokenTillDelim (const DelimCharset: TCharSet; out Token: string): boolean;
      procedure Connect (const TextBuf: string; EndOfLineMarker: char);
      
      property Chars[CharPos: integer]: char read CharAtPos; default;
      property CharsRel[RelCharPos: integer]: char read CharAtPosRel;
  end; // .class TTextScanner


(***)  implementation  (***)


constructor TTextScanner.Create;
const
  EMPTY_TEXT          = '';
  END_OF_LINE_MARKER  = #10;

begin
  Self.Connect(EMPTY_TEXT, END_OF_LINE_MARKER);
end; // .constructor TTextScanner.Create

function TTextScanner.IsValidPos (CheckPos: integer): boolean;
begin
  result  :=  Math.InRange(CheckPos, 1, Self.TextBufLen + 1);
end; // .function TTextScanner.IsValidPos

function TTextScanner.c: char;
begin
  if Self.EndOfText then begin
    result := #0;
  end // .if
  else begin
    result := Self.TextBuf[Self.Pos];
  end; // .else
end; // .function TTextScanner.c

function TTextScanner.GetCurrChar (out Res: char): boolean;
begin
  result  :=  not Self.EndOfText;
  
  if result then begin
    Res :=  Self.TextBuf[Self.Pos];
  end; // .if
end; // .function TTextScanner.GetCurrChar

function TTextScanner.ReadChar (out Res: char): boolean;
begin
  result  :=  Self.GetCurrChar(Res);
  Self.GotoNextChar;
end; // .function TTextScanner.ReadChar

function TTextScanner.GetCharAtPos (TargetPos: integer; out Res: char): boolean;
begin
  result  :=  Self.IsValidPos(TargetPos) and (TargetPos <= Self.TextBufLen);
  if result then begin
    Res :=  Self.TextBuf[TargetPos];
  end; // .if
end; // .function TTextScanner.GetCharAtPos

function TTextScanner.GetCharAtRelPos (RelPos: integer; out Res: char): boolean;
begin
  result  :=  Self.GetCharAtPos(Self.Pos + RelPos, Res);
end; // .function TTextScanner.GetCharAtRelPos

function TTextScanner.CharAtPos (TargetPos: integer): char;
begin
  if not GetCharAtPos(TargetPos, result) then begin
    result := #0;
  end; // .if
end; // .function TTextScanner.CharAtPos.CharAtPos

function TTextScanner.CharAtPosRel (RelPos: integer): char;
begin
  result := CharAtPos(Self.Pos + RelPos);
end; // .function TTextScanner.CharAtPosRel

function TTextScanner.GetSubstrAtPos (TargetPos, SubstrLen: integer): string;
var
  StartPos: integer;
  EndPos:   integer;
  
begin
  {!} Assert(SubstrLen >= 0);
  StartPos := TargetPos;
  
  if StartPos < 1 then begin
    StartPos  := 1;
    SubstrLen := Math.Max(0, SubstrLen + TargetPos - 1);
  end else if StartPos > Self.TextBufLen + 1 then begin
    StartPos := Self.TextBufLen + 1;
  end; // .elseif

  EndPos := Math.EnsureRange(TargetPos + SubstrLen, 1, Self.TextBufLen + 1);
  result := Copy(Self.TextBuf, StartPos, EndPos - StartPos);
end; // .function TTextScanner.GetSubstrAtPos

function TTextScanner.GetSubstrAtRelPos (RelPos, SubstrLen: integer): string;
begin
  result  :=  Self.GetSubstrAtPos(Self.Pos + RelPos, SubstrLen);
end; // .function TTextScanner.GetSubstrAtRelPos

function TTextScanner.GotoNextChar: boolean;
begin
  result  :=  not Self.EndOfText;
  if result then begin
    if Self.TextBuf[Self.Pos] = Self.EndOfLineMarker then begin
      Self.fLineStartPos  :=  Self.Pos;
      Inc(Self.fLineN);
    end; // .if
    Inc(Self.fPos);
    if Self.Pos > Self.TextBufLen then begin
      Self.fEndOfText :=  TRUE;
      result          :=  FALSE;
    end; // .if
  end; // .if
end; // .function TTextScanner.GotoNextChar

function TTextScanner.GotoPrevChar: boolean;
var
  i: integer;

begin
  result  :=  Self.Pos > 1;
  if result then begin
    Dec(Self.fPos);
    if Self.TextBuf[Self.Pos] = Self.EndOfLineMarker then begin
      Dec(Self.fLineN);
      i :=  Self.Pos - 1;
      while (i >= 1) and (Self.TextBuf[i] <> Self.EndOfLineMarker) do begin
        Dec(i);
      end; // .while
      Self.fLineStartPos  :=  i;
    end; // .if
    Self.fEndOfText :=  FALSE;
  end; // .if
end; // .function TTextScanner.GotoPrevChar

function TTextScanner.GotoPos (TargetPos: integer): boolean;
var
  NumSteps: integer;
  i:        integer;
  
begin
  result  :=  Self.IsValidPos(TargetPos);
  if result then begin
    NumSteps  :=  ABS(TargetPos - Self.Pos);
    if TargetPos >= Self.Pos then begin
      for i:=1 to NumSteps do begin
        Self.GotoNextChar;
      end; // .for
    end // .if
    else begin
      for i:=1 to NumSteps do begin
        Self.GotoPrevChar;
      end; // .for
    end; // .else
  end; // .if
end; // .function TTextScanner.GotoPos

function TTextScanner.GotoRelPos (RelPos: integer): boolean;
begin
  result  :=  Self.GotoPos(Self.Pos + RelPos);
end; // .function TTextScanner.GotoRelPos

function TTextScanner.GotoNextLine: boolean;
var
  OrigLineN: integer;

begin
  OrigLineN :=  Self.LineN;
  while (Self.LineN = OrigLineN) and Self.GotoNextChar do begin end;
  result  :=  Self.LineN > OrigLineN;
end; // .function TTextScanner.GotoNextLine

function TTextScanner.GotoPrevLine: boolean;
var
  OrigLineN: integer;

begin
  OrigLineN :=  Self.LineN;
  while (Self.LineN = OrigLineN) and Self.GotoPrevChar do begin end;
  result  :=  Self.LineN < OrigLineN;
  if result then begin
    Self.GotoPos(Self.LineStartPos + 1);
  end; // .if
end; // .function TTextScanner.GotoPrevLine

function TTextScanner.GotoLine (TargetLine: integer): boolean;
begin
  if TargetLine > Self.LineN then begin
    while (Self.LineN <> TargetLine) and Self.GotoNextLine do begin end;
  end // .if
  else begin
    while (Self.LineN <> TargetLine) and Self.GotoPrevLine do begin end;
  end; // .else
  result  :=  Self.LineN = TargetLine;
end; // .function TTextScanner.GotoLine

function TTextScanner.GotoRelLine (RelLineN: integer): boolean;
begin
  result  :=  Self.GotoLine(Self.LineN + RelLineN);
end; // .function TTextScanner.GotoRelLine

function TTextScanner.PosToLine (TargetPos: integer; out LineN, LinePos: integer): boolean;
var
  CurrPos: integer;

begin
  CurrPos := Self.Pos;
  result  := Self.GotoPos(TargetPos);

  if result then begin
    LineN   := Self.LineN;
    LinePos := Self.Pos - Self.LineStartPos;
    Self.GotoPos(CurrPos);
  end; // .if
end; // .function TTextScanner.PosToLine 

function TTextScanner.SkipChars (Ch: char): boolean;
begin
  result  :=  not Self.EndOfText;
  if result then begin
    while (Self.TextBuf[Self.Pos] = Ch) and Self.GotoNextChar do begin end;
    result  :=  not Self.EndOfText;
  end; // .if
end; // .function TTextScanner.SkipChars

function TTextScanner.SkipCharset (const Charset: TCharSet): boolean;
begin
  result  :=  not Self.EndOfText;
  if result then begin
    while (Self.TextBuf[Self.Pos] in Charset) and Self.GotoNextChar do begin end;
    result  :=  not Self.EndOfText;
  end; // .if
end; // .function TTextScanner.SkipCharset

function TTextScanner.FindChar (Ch: char): boolean;
begin
  result  :=  not Self.EndOfText;
  if result then begin
    while (Self.TextBuf[Self.Pos] <> Ch) and Self.GotoNextChar do begin end;
    result  :=  not Self.EndOfText;
  end; // .if
end; // .function TTextScanner.FindChar

function TTextScanner.FindCharset (const Charset: TCharSet): boolean;
begin
  result  :=  not Self.EndOfText;
  if result then begin
    while not (Self.TextBuf[Self.Pos] in Charset) and Self.GotoNextChar do begin end;
    result  :=  not Self.EndOfText;
  end; // .if
end; // .function TTextScanner.FindCharset

function TTextScanner.ReadToken (const TokenCharset: TCharSet; out Token: string): boolean;
var
  StartPos: integer;

begin
  result  :=  not Self.EndOfText;
  if result then begin
    StartPos  :=  Self.Pos;
    Self.SkipCharset(TokenCharset);
    Token :=  Copy(Self.TextBuf, StartPos, Self.Pos - StartPos);
  end; // .if
end; // .function TTextScanner.ReadToken

function TTextScanner.ReadTokenTillDelim (const DelimCharset: TCharSet; out Token: string): boolean;
var
  StartPos: integer;

begin
  result  :=  not Self.EndOfText;
  if result then begin
    StartPos  :=  Self.Pos;
    Self.FindCharset(DelimCharset);
    Token :=  Copy(Self.TextBuf, StartPos, Self.Pos - StartPos);
  end; // .if
end; // .function TTextScanner.ReadTokenTillDelim

procedure TTextScanner.Connect (const TextBuf: string; EndOfLineMarker: char);
const
  MIN_STR_POS = 1;

begin
  Self.fTextBuf         :=  TextBuf;
  Self.fTextBufLen      :=  Length(TextBuf);
  Self.fPos             :=  MIN_STR_POS;
  Self.fLineN           :=  1;
  Self.fLineStartPos    :=  MIN_STR_POS - 1;
  Self.fEndOfLineMarker :=  EndOfLineMarker;
  Self.fEndOfText       :=  Self.TextBufLen = 0;
end; // .procedure Connect

end.
