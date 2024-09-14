UNIT TextScan;
{
DESCRIPTION:  Provides high-level access to solid text in string
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Math, Utils;

TYPE
  (* IMPORT *)
  TCharSet  = Utils.TCharSet;

  TTextScanner = CLASS
    (***) PROTECTED (***)
      fTextBuf:         STRING;
      fPos:             INTEGER;  // Start from 1
      fLineN:           INTEGER;  // Start from 1
      fEndOfLineMarker: CHAR;
      fLineStartPos:    INTEGER;  // Position of EndOfLineMarker; LinePos = Pos - LineStartPos
      fTextBufLen:      INTEGER;
      fEndOfText:       BOOLEAN;
    
    (***) PUBLIC (***)
      PROPERTY  TextBuf:          STRING READ fTextBuf;
      PROPERTY  Pos:              INTEGER READ fPos;          // Start from 1
      PROPERTY  LineN:            INTEGER READ fLineN;        // Start from 1
      PROPERTY  EndOfLineMarker:  CHAR READ fEndOfLineMarker;
      PROPERTY  LineStartPos:     INTEGER READ fLineStartPos; // Position of EndOfLineMarker; LinePos = Pos - LineStartPos
      PROPERTY  TextBufLen:       INTEGER READ fTextBufLen;
      PROPERTY  EndOfText:        BOOLEAN READ fEndOfText;
    
      CONSTRUCTOR Create;
      FUNCTION  IsValidPos (CheckPos: INTEGER): BOOLEAN;
      FUNCTION  GetCurrChar (OUT Res: CHAR): BOOLEAN;
      FUNCTION  ReadChar (OUT Res: CHAR): BOOLEAN;
      FUNCTION  GetCharAtPos (TargetPos: INTEGER; OUT Res: CHAR): BOOLEAN;
      FUNCTION  GetCharAtRelPos (RelPos: INTEGER; OUT Res: CHAR): BOOLEAN;
      FUNCTION  GetSubstrAtPos (TargetPos, SubstrLen: INTEGER): STRING;
      FUNCTION  GetSubstrAtRelPos (RelPos, SubstrLen: INTEGER): STRING;
      FUNCTION  GotoNextChar: BOOLEAN;
      FUNCTION  GotoPrevChar: BOOLEAN;
      FUNCTION  GotoPos (TargetPos: INTEGER): BOOLEAN;
      FUNCTION  GotoRelPos (RelPos: INTEGER): BOOLEAN;
      FUNCTION  GotoNextLine: BOOLEAN;
      FUNCTION  GotoPrevLine: BOOLEAN;
      FUNCTION  GotoLine (TargetLine: INTEGER): BOOLEAN;
      FUNCTION  GotoRelLine (RelLineN: INTEGER): BOOLEAN;
      FUNCTION  SkipChars (Ch: CHAR): BOOLEAN;
      FUNCTION  SkipCharset (CONST Charset: TCharSet): BOOLEAN;
      FUNCTION  FindChar (Ch: CHAR): BOOLEAN;
      FUNCTION  FindCharset (CONST Charset: TCharSet): BOOLEAN;
      FUNCTION  ReadToken (CONST TokenCharset: TCharSet; OUT Token: STRING): BOOLEAN;
      FUNCTION  ReadTokenTillDelim (CONST DelimCharset: TCharSet; OUT Token: STRING): BOOLEAN;
      PROCEDURE Connect (CONST TextBuf: STRING; EndOfLineMarker: CHAR);
  END; // .class TTextScanner


(***)  IMPLEMENTATION  (***)


CONSTRUCTOR TTextScanner.Create;
CONST
  EMPTY_TEXT          = '';
  END_OF_LINE_MARKER  = #10;

BEGIN
  Self.Connect(EMPTY_TEXT, END_OF_LINE_MARKER);
END; // .CONSTRUCTOR TTextScanner.Create

FUNCTION TTextScanner.IsValidPos (CheckPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Math.InRange(CheckPos, 1, Self.TextBufLen);
END; // .FUNCTION TTextScanner.IsValidPos

FUNCTION TTextScanner.GetCurrChar (OUT Res: CHAR): BOOLEAN;
BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    Res :=  Self.TextBuf[Self.Pos];
  END; // .IF
END; // .FUNCTION TTextScanner.GetCurrChar

FUNCTION TTextScanner.ReadChar (OUT Res: CHAR): BOOLEAN;
BEGIN
  RESULT  :=  Self.GetCurrChar(Res);
  Self.GotoNextChar;
END; // .FUNCTION TTextScanner.ReadChar

FUNCTION TTextScanner.GetCharAtPos (TargetPos: INTEGER; OUT Res: CHAR): BOOLEAN;
BEGIN
  RESULT  :=  Self.IsValidPos(TargetPos);
  IF RESULT THEN BEGIN
    Res :=  Self.TextBuf[TargetPos];
  END; // .IF
END; // .FUNCTION TTextScanner.GetCharAtPos

FUNCTION TTextScanner.GetCharAtRelPos (RelPos: INTEGER; OUT Res: CHAR): BOOLEAN;
BEGIN
  RESULT  :=  Self.GetCharAtPos(Self.Pos + RelPos, Res);
END; // .FUNCTION TTextScanner.GetCharAtRelPos

FUNCTION TTextScanner.GetSubstrAtPos (TargetPos, SubstrLen: INTEGER): STRING;
VAR
  StartPos: INTEGER;
  EndPos:   INTEGER;
  
BEGIN
  StartPos  :=  Math.EnsureRange(TargetPos, 1, Self.TextBufLen + 1);
  EndPos    :=  Math.EnsureRange(TargetPos + SubstrLen, 1, Self.TextBufLen + 1);
  RESULT    :=  Copy(Self.TextBuf, StartPos, EndPos - StartPos);
END; // .FUNCTION TTextScanner.GetSubstrAtPos

FUNCTION TTextScanner.GetSubstrAtRelPos (RelPos, SubstrLen: INTEGER): STRING;
BEGIN
  RESULT  :=  Self.GetSubstrAtPos(Self.Pos + RelPos, SubstrLen);
END; // .FUNCTION TTextScanner.GetSubstrAtRelPos

FUNCTION TTextScanner.GotoNextChar: BOOLEAN;
BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    IF Self.TextBuf[Self.Pos] = Self.EndOfLineMarker THEN BEGIN
      Self.fLineStartPos  :=  Self.Pos;
      INC(Self.fLineN);
    END; // .IF
    INC(Self.fPos);
    IF Self.Pos > Self.TextBufLen THEN BEGIN
      Self.fEndOfText :=  TRUE;
      RESULT          :=  FALSE;
    END; // .IF
  END; // .IF
END; // .FUNCTION TTextScanner.GotoNextChar

FUNCTION TTextScanner.GotoPrevChar: BOOLEAN;
VAR
  i: INTEGER;

BEGIN
  RESULT  :=  Self.Pos > 1;
  IF RESULT THEN BEGIN
    DEC(Self.fPos);
    IF Self.TextBuf[Self.Pos] = Self.EndOfLineMarker THEN BEGIN
      DEC(Self.fLineN);
      i :=  Self.Pos - 1;
      WHILE (i >= 1) AND (Self.TextBuf[i] <> Self.EndOfLineMarker) DO BEGIN
        DEC(i);
      END; // .WHILE
      Self.fLineStartPos  :=  i;
    END; // .IF
    Self.fEndOfText :=  FALSE;
  END; // .IF
END; // .FUNCTION TTextScanner.GotoPrevChar

FUNCTION TTextScanner.GotoPos (TargetPos: INTEGER): BOOLEAN;
VAR
  NumSteps: INTEGER;
  i:        INTEGER;
  
BEGIN
  RESULT  :=  Self.IsValidPos(TargetPos);
  IF RESULT THEN BEGIN
    NumSteps  :=  ABS(TargetPos - Self.Pos);
    IF TargetPos >= Self.Pos THEN BEGIN
      FOR i:=1 TO NumSteps DO BEGIN
        Self.GotoNextChar;
      END; // .FOR
    END // .IF
    ELSE BEGIN
      FOR i:=1 TO NumSteps DO BEGIN
        Self.GotoPrevChar;
      END; // .FOR
    END; // .ELSE
  END; // .IF
END; // .FUNCTION TTextScanner.GotoPos

FUNCTION TTextScanner.GotoRelPos (RelPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Self.GotoPos(Self.Pos + RelPos);
END; // .FUNCTION TTextScanner.GotoRelPos

FUNCTION TTextScanner.GotoNextLine: BOOLEAN;
VAR
  OrigLineN: INTEGER;

BEGIN
  OrigLineN :=  Self.LineN;
  WHILE (Self.LineN = OrigLineN) AND Self.GotoNextChar DO BEGIN END;
  RESULT  :=  Self.LineN > OrigLineN;
END; // .FUNCTION TTextScanner.GotoNextLine

FUNCTION TTextScanner.GotoPrevLine: BOOLEAN;
VAR
  OrigLineN: INTEGER;

BEGIN
  OrigLineN :=  Self.LineN;
  WHILE (Self.LineN = OrigLineN) AND Self.GotoPrevChar DO BEGIN END;
  RESULT  :=  Self.LineN < OrigLineN;
  IF RESULT THEN BEGIN
    Self.GotoPos(Self.LineStartPos + 1);
  END; // .IF
END; // .FUNCTION TTextScanner.GotoPrevLine

FUNCTION TTextScanner.GotoLine (TargetLine: INTEGER): BOOLEAN;
BEGIN
  IF TargetLine > Self.LineN THEN BEGIN
    WHILE (Self.LineN <> TargetLine) AND Self.GotoNextLine DO BEGIN END;
  END // .IF
  ELSE BEGIN
    WHILE (Self.LineN <> TargetLine) AND Self.GotoPrevLine DO BEGIN END;
  END; // .ELSE
  RESULT  :=  Self.LineN = TargetLine;
END; // .FUNCTION TTextScanner.GotoLine

FUNCTION TTextScanner.GotoRelLine (RelLineN: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Self.GotoLine(Self.LineN + RelLineN);
END; // .FUNCTION TTextScanner.GotoRelLine 

FUNCTION TTextScanner.SkipChars (Ch: CHAR): BOOLEAN;
BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    WHILE (Self.TextBuf[Self.Pos] = Ch) AND Self.GotoNextChar DO BEGIN END;
    RESULT  :=  NOT Self.EndOfText;
  END; // .IF
END; // .FUNCTION TTextScanner.SkipChars

FUNCTION TTextScanner.SkipCharset (CONST Charset: TCharSet): BOOLEAN;
BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    WHILE (Self.TextBuf[Self.Pos] IN Charset) AND Self.GotoNextChar DO BEGIN END;
    RESULT  :=  NOT Self.EndOfText;
  END; // .IF
END; // .FUNCTION TTextScanner.SkipCharset

FUNCTION TTextScanner.FindChar (Ch: CHAR): BOOLEAN;
BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    WHILE (Self.TextBuf[Self.Pos] <> Ch) AND Self.GotoNextChar DO BEGIN END;
    RESULT  :=  NOT Self.EndOfText;
  END; // .IF
END; // .FUNCTION TTextScanner.FindChar

FUNCTION TTextScanner.FindCharset (CONST Charset: TCharSet): BOOLEAN;
BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    WHILE NOT (Self.TextBuf[Self.Pos] IN Charset) AND Self.GotoNextChar DO BEGIN END;
    RESULT  :=  NOT Self.EndOfText;
  END; // .IF
END; // .FUNCTION TTextScanner.FindCharset

FUNCTION TTextScanner.ReadToken (CONST TokenCharset: TCharSet; OUT Token: STRING): BOOLEAN;
VAR
  StartPos: INTEGER;

BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    StartPos  :=  Self.Pos;
    Self.SkipCharset(TokenCharset);
    Token :=  Copy(Self.TextBuf, StartPos, Self.Pos - StartPos);
  END; // .IF
END; // .FUNCTION TTextScanner.ReadToken

FUNCTION TTextScanner.ReadTokenTillDelim (CONST DelimCharset: TCharSet; OUT Token: STRING): BOOLEAN;
VAR
  StartPos: INTEGER;

BEGIN
  RESULT  :=  NOT Self.EndOfText;
  IF RESULT THEN BEGIN
    StartPos  :=  Self.Pos;
    Self.FindCharset(DelimCharset);
    Token :=  Copy(Self.TextBuf, StartPos, Self.Pos - StartPos);
  END; // .IF
END; // .FUNCTION TTextScanner.ReadTokenTillDelim

PROCEDURE TTextScanner.Connect (CONST TextBuf: STRING; EndOfLineMarker: CHAR);
CONST
  MIN_STR_POS = 1;

BEGIN
  Self.fTextBuf         :=  TextBuf;
  Self.fTextBufLen      :=  LENGTH(TextBuf);
  Self.fPos             :=  MIN_STR_POS;
  Self.fLineN           :=  1;
  Self.fLineStartPos    :=  MIN_STR_POS - 1;
  Self.fEndOfLineMarker :=  EndOfLineMarker;
  Self.fEndOfText       :=  Self.TextBufLen = 0;
END; // .PROCEDURE Connect

END.
