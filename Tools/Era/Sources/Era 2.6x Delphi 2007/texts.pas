unit Texts;
{
DESCRIPTION:  Text model implementation
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Math, Utils, Lists, StrLib, ATexts;

type
  TTextLinesSettings  = class
    LineEndMarker:  char;
  end; // .class TTextLinesSettings

  {
    Line end markers are members of lines which they terminate.
    Default line end marker is #10.
  }
  TTextLines  = class (ATexts.ATextLines)
    (***) protected (***)
      {O} fLines: Lists.TStringList {OF line contents => text position of first line character};
      
      function  IsValidPos (Pos: integer): boolean;
      function  IsValidLineN (LineN: integer): boolean;
      function  GetLineLength (LineN: integer): integer;
      function  GetLineTextPos (LineN: integer): integer;
      function  IsValidLinePos (LineN, LinePos: integer): boolean;
      procedure DeleteFromLine (LineN, LinePos, Count: integer);
      procedure ShiftTextPositionsOfLines (StartFromN, ShiftBy: integer);
      
    (***) public (***)
    const
      DEF_LINE_END_MARKER = #10;
    
      constructor Create;
      destructor  Destroy; override;
      procedure Assign (Source: Utils.TCloneable); override;
      
      (* Character navigation *)
      function  GotoNextPos: boolean; override;
      function  GotoPrevPos: boolean; override;
      function  GotoPos (NewPos: integer): boolean; override;
      
      (* Line navigation *)
      function  GotoNextLine: boolean; override;
      function  GotoPrevLine: boolean; override;
      function  GotoLine (NewLineN: integer): boolean; override;
      
      (* Reading operations *)
      function  GetCurrChar (out c: char): boolean; override;
      function  GetStr (StrLen: integer): string; override;
      
      (* Writing operations *)
      function  SetCurrChar (c: char): boolean; override;
      procedure Insert (const Str: string); override;
      procedure Delete (DelCount: integer); override;
      procedure Replace (ReplCount: integer; const ReplWith: string); override;
      
      (* Position conversions *)
      function  PosToLinePos (Pos: integer; out LineN, LinePos: integer): boolean; override;
      function  LinePosToPos (LineN, LinePos: integer; out Pos: integer): boolean; override;
      
      (* Getting metrics *)
      function  GetLineLen (LineN: integer; out LineLen: integer): boolean; override;
      
      (* Generic *)
      procedure Connect (const Source: string; {IN} var {n} Settings: TObject); override;
      procedure Clear; override;
  end; // .class TTextLines
  
  TDirection = (TO_THE_LEFT, TO_THE_RIGHT);

  PTextBlock  = ^TTextBlock;
  TTextBlock  = record
          Data:       string;
          StartPos:   integer;
          Len:        integer;
    {Un}  PrevBlock:  PTextBlock;
    {On}  NextBlock:  PTextBlock;
  end; // .record TTextBlock

  TTextBlocks = class (ATexts.AText)
    (***) protected (***)
      {O} fRoot:          PTextBlock;
      {U} fCurrBlock:     PTextBlock;
          fCurrBlockPos:  integer;
            
      procedure DeleteBlock ({IN} var DelBlock: PTextBlock);
      function  InsertBlock (InsDir: TDirection; ParentBlock: PTextBlock): {O} PTextBlock;
          
    (***) public (***)
      constructor Create;
      destructor  Destroy; override;
      procedure Assign (Source: Utils.TCloneable); override;
      
      (* Character navigation *)
      function  GotoNextPos: boolean; override;
      function  GotoPrevPos: boolean; override;
      function  GotoPos (NewPos: integer): boolean; override;
      
      (* Reading operations *)
      function  GetCurrChar (out c: char): boolean; override;
      function  GetStr (StrLen: integer): string; override;
      
      (* Writing operations *)
      function  SetCurrChar (c: char): boolean; override;
      procedure Insert (const Str: string); override;
      procedure Delete (DelCount: integer); override;
      procedure Replace (ReplCount: integer; const ReplWith: string); override;
      
      (* Generic *)
      procedure Connect (const Source: string; {IN} var {n} Settings: TObject); override;
      procedure Clear; override;
  end; // .class TTextBlocks


(***) implementation (***)


// TTextLines //

function TTextLines.IsValidPos (Pos: integer): boolean;
begin
  result  :=  Math.InRange(Pos, 1, Self.Len + 1);
end; // .function TTextLines.IsValidPos

function TTextLines.IsValidLineN (LineN: integer): boolean;
begin
  result  :=  Math.InRange(LineN, 1, Self.fLines.Count);
end; // .function TTextLines.IsValidLineN

function TTextLines.GetLineLength (LineN: integer): integer;
begin
  {!} Assert(IsValidLineN(LineN));
  result  :=  Length(Self.fLines[LineN - 1]);
end; // .function TTextLines.GetLineLength

function TTextLines.GetLineTextPos (LineN: integer): integer;
begin
  {!} Assert(Self.IsValidLineN(LineN));
  result  :=  integer(Self.fLines.Values[LineN - 1]);
end; // .function TTextLines.GetLineTextPos

function TTextLines.IsValidLinePos (LineN, LinePos: integer): boolean;
begin
  result  :=  Self.IsValidLineN(LineN) and Math.InRange(LinePos, 1, Self.GetLineLength(LineN) + 1);
end; // .function IsValidLinePos

procedure TTextLines.DeleteFromLine (LineN, LinePos, Count: integer);
var
  Str:  string;
  
begin
  {!} Assert(Self.IsValidLinePos(LineN, LinePos));
  {!} Assert(Count >= 0);
  Str :=  Self.fLines[LineN - 1];
  System.DELETE(Str, LinePos, Count);
  Self.fLines[LineN - 1]  :=  Str;
end; // .procedure TTextLines.DeleteFromLine

procedure TTextLines.ShiftTextPositionsOfLines (StartFromN, ShiftBy: integer);
var
  i:  integer;
  
begin
  for i:=StartFromN - 1 to Self.fLines.Count - 1 do begin
    Self.fLines.Values[i] :=  Ptr(integer(Self.fLines.Values[i]) + ShiftBy);
  end; // .for
end; // .procedure TTextLines.ShiftTextPositionsOfLines

constructor TTextLines.Create;
begin
  Self.fLineEndMarker :=  Self.DEF_LINE_END_MARKER;
  Self.fLines         :=  Lists.NewSimpleStrList;
  Self.Clear;
end; // .constructor TTextLines.Create

destructor TTextLines.Destroy;
begin
  SysUtils.FreeAndNil(Self.fLines);
end; // .destructor TTextLines.Destroy

procedure TTextLines.Assign (Source: Utils.TCloneable);
var
(* U *) SrcText:  TTextLines;
  
begin
  {!} Assert(Source <> nil);
  SrcText :=  Source AS TTextLines;
  // * * * * * //
  Self.fPos           :=  SrcText.Pos;
  Self.fLineN         :=  SrcText.LineN;
  Self.fLinePos       :=  SrcText.LinePos;
  Self.fLen           :=  SrcText.Len;
  Self.fNumLines      :=  SrcText.NumLines;
  Self.fLineEndMarker :=  SrcText.LineEndMarker;
  Self.fTextEnd       :=  SrcText.TextEnd;
  SysUtils.FreeAndNil(Self.fLines);
  Self.fLines         :=  Lists.TStringList(SrcText.fLines.Clone);
end; // .procedure TTextLines.Assign


(* Character navigation *)


function TTextLines.GotoNextPos: boolean;
begin
  result  :=  Self.GotoPos(Self.Pos + 1);
end; // .function TTextLines.GotoNextPos

function TTextLines.GotoPrevPos: boolean;
begin
  result  :=  Self.GotoPos(Self.Pos - 1);
end; // .function TTextLines.GotoPrevPos

function TTextLines.GotoPos (NewPos: integer): boolean;
var
  LineN:    integer;
  LinePos:  integer;

begin
  result  :=  Self.PosToLinePos(NewPos, LineN, LinePos);
  if result then begin
    Self.fPos     :=  NewPos;
    Self.fLineN   :=  LineN;
    Self.fLinePos :=  LinePos;
    Self.fTextEnd :=  Self.Pos > Self.Len;
  end; // .if
end; // .function TTextLines.GotoPos


(* Line navigation *)


function TTextLines.GotoNextLine: boolean;
begin
  result  :=  Self.GotoLine(Self.LineN + 1);
end; // .function TTextLines.GotoNextLine

function TTextLines.GotoPrevLine: boolean;
begin
  result  :=  Self.GotoLine(Self.LineN - 1);
end; // .function TTextLines.GotoPrevLine

function TTextLines.GotoLine (NewLineN: integer): boolean;
begin
  result  :=  Self.IsValidLineN(NewLineN);
  if result then begin
    Self.fPos     :=  Self.GetLineTextPos(NewLineN);
    Self.fLineN   :=  NewLineN;
    Self.fLinePos :=  1;
    Self.fTextEnd :=  Self.Pos > Self.Len;
  end; // .if
end; // .function TTextLines.GotoLine


(* Reading operations *)


function TTextLines.GetCurrChar (out c: char): boolean;
begin
  result  :=  not Self.TextEnd;
  if result then begin
    if Self.LinePos <= Self.GetLineLength(Self.LineN) then begin
      c :=  Self.fLines[Self.LineN - 1][Self.LinePos];
    end // .if
    else begin
      c :=  Self.LineEndMarker;
    end; // .else
  end; // .if
end; // .function TTextLines.GetCurrChar

function TTextLines.GetStr (StrLen: integer): string;
var
  LineN:        integer;
  LinePos:      integer;
  NumCharsLeft: integer;
  ChunkLen:     integer;
  Dest:         pointer;

begin
  {!} Assert(StrLen >= 0);
  Dest  :=  nil;
  // * * * * * //
  StrLen  :=  Math.Min(StrLen, Self.Len - Self.Pos + 1);
  SetLength(result, StrLen);
  if StrLen > 0 then begin
    LineN         :=  Self.LineN;
    LinePos       :=  Self.LinePos;
    Dest          :=  pointer(result);
    NumCharsLeft  :=  StrLen;
    while NumCharsLeft > 0 do begin
      ChunkLen  :=  Math.Min(LinePos + NumCharsLeft, Self.GetLineLength(LineN) + 1) - LinePos;
      if ChunkLen > 0 then begin
        Utils.CopyMem
        (
          ChunkLen,
          pointer(@Self.fLines[LineN - 1][LinePos]), Utils.PtrOfs(Dest, StrLen - NumCharsLeft)
        );
        NumCharsLeft  :=  NumCharsLeft - ChunkLen;
      end; // .if
      if NumCharsLeft > 0 then begin
        pchar(Utils.PtrOfs(Dest, StrLen - NumCharsLeft))^ :=  Self.LineEndMarker;
        Dec(NumCharsLeft);
        Inc(LineN);
        LinePos :=  1;
      end; // .if
    end; // .while
  end; // .if
end; // .function TTextLines.GetStr


(* Writing operations *)


function TTextLines.SetCurrChar (c: char): boolean;
var
  LineLen:  integer;

begin
  result  :=  not Self.TextEnd;
  if result then begin
    LineLen :=  Self.GetLineLength(Self.LineN);
    if Self.LinePos <= LineLen then begin
      if c <> Self.LineEndMarker then begin
        pchar(@Self.fLines[Self.LineN - 1][Self.LinePos])^  :=  c;
      end // .if
      else begin
        Self.fLines.InsertObj
        (
          System.COPY(Self.fLines[Self.LineN - 1], Self.LinePos + 1, LineLen - Self.LinePos),
          Ptr(Self.Pos + 1),
          Self.LineN
        );
        Self.fLines[Self.LineN - 1] :=  System.COPY(Self.fLines[Self.LineN - 1], 1, Self.LinePos - 1);
      end; // .else
    end // .if
    else if c <> Self.LineEndMarker then begin
      Self.fLines[Self.LineN - 1] :=  Self.fLines[Self.LineN - 1] + c + Self.fLines[Self.LineN];
      Self.fLines.Delete(Self.LineN);
      Dec(Self.fNumLines);
    end; // .ELSEIF
  end; // .if
end; // .function TTextLines.SetCurrChar

procedure TTextLines.Insert (const Str: string);
var
  InsLines:         Utils.TArrayOfStr;
  BeforeBreak:      string;
  AfterBreak:       string;
  NumNewLines:      integer;
  NumLinesToShift:  integer;
  LineInd:          integer;
  i:                integer;

begin
  if Length(Str) > 0 then begin
    InsLines    :=  StrLib.Explode(Str, Self.LineEndMarker);
    NumNewLines :=  Length(InsLines) - 1;
    BeforeBreak :=  System.COPY(Self.fLines[Self.LineN - 1], 1, Self.LinePos - 1);
    AfterBreak  :=  System.COPY(Self.fLines[Self.LineN - 1], Self.LinePos, Self.GetLineLength(Self.LineN) - Self.LinePos + 1);
    Self.fLines[Self.LineN - 1] :=  BeforeBreak + InsLines[0];
    if NumNewLines > 0 then begin
      NumLinesToShift :=  Self.fLines.Count - Self.LineN;
      Self.fLines.SetCount(Self.fLines.Count + NumNewLines);
      Self.fNumLines  :=  Self.fNumLines + NumNewLines;
      Self.fLines.Shift(Self.LineN, NumLinesToShift, NumNewLines);
      LineInd :=  Self.LineN - 1;
      for i:=1 to NumNewLines do begin
        Self.fLines[LineInd + i]  :=  InsLines[i];
      end; // .for
    end; // .if
    LineInd               :=  Self.LineN + NumNewLines - 1;
    Self.fLines[LineInd]  :=  Self.fLines[LineInd] + AfterBreak;
    Self.fPos             :=  Self.fPos + Length(Str);
    Self.fLinePos         :=  Self.fPos - Self.GetLineTextPos(LineInd + 1) + 1;
    Self.fLen             :=  Self.fLen + Length(Str);
    Self.ShiftTextPositionsOfLines(Self.LineN + 1, Length(Str));
  end; // .if
end; // .procedure TTextLines.Insert

procedure TTextLines.Delete (DelCount: integer);
var
  LineN:        integer;
  LineLen:      integer;
  BeforeDel:    string;
  NumDelLines:  integer;
  NumDelLeft:   integer;
  
begin
  {!} Assert(DelCount >= 0);
  DelCount  :=  Math.Min(DelCount, Self.Len - Self.Pos + 1);
  if DelCount > 0 then begin
    LineN   :=  Self.LineN;
    LineLen :=  Self.GetLineLength(LineN);
    if (Self.LinePos + DelCount - 1) <= LineLen then begin
      Self.DeleteFromLine(LineN, Self.LinePos, DelCount);
    end // .if
    else begin
      BeforeDel   :=  System.COPY(Self.fLines[LineN - 1], 1, Self.LinePos - 1);
      NumDelLines :=  0;
      NumDelLeft  :=  DelCount + Self.LinePos - 1;
      while NumDelLeft > LineLen do begin
        NumDelLeft  :=  NumDelLeft - LineLen - 1;
        Inc(NumDelLines);
        Inc(LineN);
        LineLen :=  Self.GetLineLength(LineN);
      end; // .while
      Self.fLines.Shift(Self.LineN - 1 + NumDelLines, Self.fLines.Count - Self.LineN - NumDelLines + 1, -NumDelLines);
      Self.fNumLines  :=  Self.fNumLines - NumDelLines;
      Self.fLines.SetCount(Self.NumLines);
      Self.fLines[Self.LineN - 1] :=  BeforeDel +
        System.COPY(Self.fLines[Self.LineN - 1], NumDelLeft + 1, Self.GetLineLength(Self.LineN) - NumDelLeft);
      Self.ShiftTextPositionsOfLines(Self.LineN + 1, -DelCount);
    end; // .else
    Self.fLen     :=  Self.fLen - DelCount;
    Self.fTextEnd :=  Self.Pos > Self.Len;
  end; // .if
end; // .procedure TTextLines.Delete

procedure TTextLines.Replace (ReplCount: integer; const ReplWith: string);
begin
  Self.Delete(ReplCount);
  Self.Insert(ReplWith);
end; // .procedure TTextLines.Replace


(* Position conversions *)


function TTextLines.PosToLinePos (Pos: integer; out LineN, LinePos: integer): boolean;
var
  LeftLineN:          integer;
  RightLineN:         integer;
  MiddleLineN:        integer;
  MiddleLineStartPos: integer;

begin
  result  :=  Self.IsValidPos(Pos);
  if result then begin
    if Pos = 1 then begin
      LineN   :=  1;
      LinePos :=  1;
    end // .if
    else if Pos > Self.Len then begin
      LineN   :=  Self.fLines.Count;
      LinePos :=  Self.GetLineLength(LineN) + 1;
    end // .ELSEIF
    else begin
      LeftLineN   :=  1;
      RightLineN  :=  Self.fLines.Count;
      MiddleLineN :=  Self.LineN;
      LineN       :=  -1;
      while (LeftLineN <= RightLineN) and (LineN = -1) do begin
        MiddleLineStartPos  :=  Self.GetLineTextPos(MiddleLineN);
        if Math.InRange(Pos, MiddleLineStartPos, MiddleLineStartPos + Self.GetLineLength(MiddleLineN)) then begin
          LineN   :=  MiddleLineN;
          LinePos :=  Pos - MiddleLineStartPos + 1;
        end // .if
        else begin
          if Pos < MiddleLineStartPos then begin
            RightLineN  :=  MiddleLineN - 1;
          end // .if
          else begin
            LeftLineN   :=  MiddleLineN + 1;
          end; // .else
          MiddleLineN :=  (RightLineN - LeftLineN) div 2 + LeftLineN;
        end; // .else
      end; // .while
    end; // .else
  end; // .if
end; // .function TTextLines.PosToLinePos

function TTextLines.LinePosToPos (LineN, LinePos: integer; out Pos: integer): boolean;
begin
  result  :=  Self.IsValidLinePos(LineN, LinePos);
  if result then begin
    Pos :=  Self.GetLineTextPos(LineN) + LinePos - 1;
  end; // .if
end; // .function TTextLines.LinePosToPos


(* Getting metrics *)


function TTextLines.GetLineLen (LineN: integer; out LineLen: integer): boolean;
begin
  result  :=  Self.IsValidLineN(LineN);
  if result then begin
    LineLen :=  Self.GetLineLength(LineLen);
  end; // .if
end; // .function TTextLines.GetLineLen


(* Generic *)


procedure TTextLines.Connect (const Source: string; {IN} var {n} Settings: TObject);
var
  CurrLineTextPos:  integer;
  i:                integer;

begin
  {!} Assert((Settings = nil) or (Settings IS TTextLinesSettings));
  Self.Clear;
  if Settings = nil then begin
    Self.fLineEndMarker :=  Self.DEF_LINE_END_MARKER;
  end // .if
  else begin
    Self.fLineEndMarker :=  TTextLinesSettings(Settings).LineEndMarker;
  end; // .else
  SysUtils.FreeAndNil(Settings);
  Self.fLines.LoadFromText(Source, Self.LineEndMarker);
  Self.fLen       :=  Length(Source);
  Self.fTextEnd   :=  Self.Len = 0;
  Self.fNumLines  :=  Self.fLines.Count;
  CurrLineTextPos :=  1;
  for i:=0 to Self.NumLines - 1 do begin
    Self.fLines.Values[i] :=  Ptr(CurrLineTextPos);
    CurrLineTextPos       :=  CurrLineTextPos + Length(Self.fLines[i]) + 1;
  end; // .for
end; // .procedure TTextLines.Connect

procedure TTextLines.Clear;
begin
  Self.fLines.Clear;
  Self.fLines.AddObj('', Ptr(1));
  Self.fPos       :=  1;
  Self.fLineN     :=  1;
  Self.fLinePos   :=  1;
  Self.fLen       :=  0;
  Self.fNumLines  :=  1;
  Self.fTextEnd   :=  TRUE;
end; // .procedure TTextLines.Clear


// TTextBlocks //


procedure TTextBlocks.DeleteBlock ({IN} var DelBlock: PTextBlock);
begin
  {!} Assert(DelBlock <> nil);
  {!} Assert(DelBlock.Len > 0);
  if DelBlock.PrevBlock <> nil then begin
    DelBlock.PrevBlock.NextBlock  :=  DelBlock.NextBlock;
  end // .if
  else begin
    Self.fRoot  :=  DelBlock.NextBlock;
  end; // .else
  if DelBlock.NextBlock <> nil then begin
    DelBlock.NextBlock.PrevBlock  :=  DelBlock.PrevBlock;
  end; // .if
  Dispose(DelBlock); DelBlock :=  nil;
end; // .procedure TTextBlocks.DeleteBlock

function TTextBlocks.InsertBlock (InsDir: TDirection; ParentBlock: PTextBlock): {O} PTextBlock;
begin
  {!} Assert(ParentBlock <> nil);
  New(result);
  FillChar(result^, sizeof(result^), #0);
  if InsDir = TO_THE_LEFT then begin
    if ParentBlock.PrevBlock <> nil then begin
      ParentBlock.PrevBlock.NextBlock :=  result;
      result.PrevBlock                :=  ParentBlock.PrevBlock;
      result.NextBlock                :=  ParentBlock;
    end // .if
    else begin
      Self.fRoot        :=  result;
      result.NextBlock  :=  ParentBlock;
    end; // .else
    ParentBlock.PrevBlock :=  result;
  end // .if
  else begin
    if ParentBlock.NextBlock <> nil then begin
      ParentBlock.NextBlock.PrevBlock :=  result;
      result.NextBlock                :=  ParentBlock.NextBlock;
    end; // .if
    ParentBlock.NextBlock :=  result;
    result.PrevBlock      :=  ParentBlock;
  end; // .else
end; // .function TTextBlocks.InsertBlock

constructor TTextBlocks.Create;
begin
  Self.Clear;
end; // .constructor TTextBlocks.Create

destructor TTextBlocks.Destroy;
begin
  Self.Clear;
  Dispose(Self.fRoot);
end; // .destructor TTextBlocks.Destroy

procedure TTextBlocks.Assign (Source: Utils.TCloneable);
var
{U} SrcBlocks:  TTextBlocks;
    OldSrcPos:  integer;
  
begin
  {!} Assert(Source <> nil);
  SrcBlocks :=  Source AS TTextBlocks;
  // * * * * * //
  Self.Clear;
  if SrcBlocks.Len > 0 then begin
    OldSrcPos :=  SrcBlocks.Pos;
    SrcBlocks.GotoPos(1);
    Self.Insert(SrcBlocks.GetStr(SrcBlocks.Len));
    SrcBlocks.GotoPos(OldSrcPos);
    Self.GotoPos(OldSrcPos);    
  end; // .if
end; // .procedure TTextBlocks.Assign


(* Character navigation *)


function TTextBlocks.GotoNextPos: boolean;
begin
  result  :=  not Self.TextEnd;
  if result then begin
    Self.fTextEnd :=  Self.Pos = Self.Len;
    Inc(Self.fPos);
    Inc(Self.fCurrBlockPos);
    if Self.fCurrBlockPos = Self.fCurrBlock.Len then begin
      Self.fCurrBlock     :=  Self.fCurrBlock.NextBlock;
      Self.fCurrBlockPos  :=  0;
    end; // .if 
  end; // .if
end; // .function TTextBlocks.GotoNextPos

function TTextBlocks.GotoPrevPos: boolean;
begin
  result  :=  Self.Pos > 1;
  if result then begin
    Self.fTextEnd :=  FALSE;
    Dec(Self.fPos);
    Dec(Self.fCurrBlockPos);
    if Self.fCurrBlockPos = -1 then begin
      Self.fCurrBlock     :=  Self.fCurrBlock.PrevBlock;
      Self.fCurrBlockPos  :=  Self.fCurrBlock.Len - 1;
    end; // .if 
  end; // .if
end; // .function TTextBlocks.GotoPrevPos

function TTextBlocks.GotoPos (NewPos: integer): boolean;
var
  FinishDist:     integer;
  NextBlockDist:  integer;
  PrevBlockDist:  integer;

begin
  result  :=  Math.InRange(NewPos, 1, Self.Len + 1);
  if result and (NewPos <> Self.Pos) then begin
    FinishDist  :=  ABS(NewPos - Self.Pos);
    while FinishDist > 0 do begin
      if Self.Pos < NewPos then begin
        NextBlockDist :=  Self.fCurrBlock.Len - Self.fCurrBlockPos;
        if NextBlockDist <= FinishDist then begin
          FinishDist          :=  FinishDist - NextBlockDist;
          Self.fCurrBlock     :=  Self.fCurrBlock.NextBlock;
          Self.fCurrBlockPos  :=  0;
        end // .if
        else begin
          Self.fCurrBlockPos  :=  Self.fCurrBlockPos + FinishDist;
          FinishDist          :=  0;
        end; // .else
      end // .if
      else begin
        PrevBlockDist :=  Self.fCurrBlockPos + 1;
        if PrevBlockDist <= FinishDist then begin
          FinishDist          :=  FinishDist - PrevBlockDist;
          Self.fCurrBlock     :=  Self.fCurrBlock.PrevBlock;
          Self.fCurrBlockPos  :=  Self.fCurrBlock.Len - 1;
        end // .if
        else begin
          Self.fCurrBlockPos  :=  Self.fCurrBlockPos - FinishDist;
          FinishDist          :=  0;
        end; // .else
      end; // .else
    end; // .while
    Self.fPos     :=  NewPos;
    Self.fTextEnd :=  NewPos > Self.Len;
  end; // .if
end; // .function TTextBlocks.GotoPos


(* Reading operations *)


function TTextBlocks.GetCurrChar (out c: char): boolean;
begin
  result  :=  not Self.TextEnd;
  if result then begin
    c :=  Self.fCurrBlock.Data[Self.fCurrBlock.StartPos + Self.fCurrBlockPos];
  end; // .if
end; // .function TTextBlocks.GetCurrChar

function TTextBlocks.GetStr (StrLen: integer): string;
var
{U} ThisBlock:    PTextBlock; 
{U} Dest:         pointer;
    ThisBlockPos: integer;
    NumCharsLeft: integer;
    ChunkLen:     integer;

begin
  {!} Assert(StrLen >= 0);
  ThisBlock :=  Self.fCurrBlock;
  Dest      :=  nil;
  // * * * * * //
  StrLen  :=  Math.Min(StrLen, Self.Len - Self.Pos + 1);
  SetLength(result, StrLen);
  if StrLen > 0 then begin
    ThisBlockPos  :=  Self.fCurrBlockPos;
    Dest          :=  pointer(result);
    NumCharsLeft  :=  StrLen;
    while NumCharsLeft > 0 do begin
      ChunkLen  :=  Math.Min(NumCharsLeft, ThisBlock.Len - ThisBlockPos);
      Utils.CopyMem
      (
        ChunkLen,
        pointer(@ThisBlock.Data[ThisBlock.StartPos + ThisBlockPos]),
        Utils.PtrOfs(Dest, StrLen - NumCharsLeft)
      );
      NumCharsLeft  :=  NumCharsLeft - ChunkLen;
      if NumCharsLeft > 0 then begin
        ThisBlock     :=  ThisBlock.NextBlock;
        ThisBlockPos  :=  0;
      end; // .if
    end; // .while
  end; // .if
end; // .function TTextBlocks.GetStr


(* Writing operations *)


function TTextBlocks.SetCurrChar (c: char): boolean;
begin
  result  :=  not Self.TextEnd;
  if result then begin
    Self.Replace(1, c);
  end; // .if
end; // .function TTextBlocks.SetCurrChar

procedure TTextBlocks.Delete (DelCount: integer);
var
{U} BlockToDel:         PTextBlock;
{U} NewBlock:           PTextBlock;
    NumBlockCharsLeft:  integer;

begin
  {!} Assert(DelCount >= 0);
  BlockToDel  :=  nil;
  NewBlock    :=  nil;
  // * * * * * //
  DelCount  :=  Math.Min(DelCount, Self.Len - Self.Pos + 1);
  while DelCount > 0 do begin
    Self.fLen :=  Self.Len - DelCount;
    if Self.fCurrBlockPos = 0 then begin
      if Self.fCurrBlock.Len <= DelCount then begin
        DelCount        :=  DelCount - Self.fCurrBlock.Len;
        BlockToDel      :=  Self.fCurrBlock;
        Self.fCurrBlock :=  Self.fCurrBlock.NextBlock;
        Self.DeleteBlock(BlockToDel);
      end // .if
      else begin
        Self.fCurrBlock.StartPos  :=  Self.fCurrBlock.StartPos + DelCount;
        Self.fCurrBlock.Len       :=  Self.fCurrBlock.Len - DelCount;
        DelCount                  :=  0;
      end; // .else
    end // .if
    else begin
      NumBlockCharsLeft   :=  Self.fCurrBlock.Len - Self.fCurrBlockPos;
      Self.fCurrBlock.Len :=  Self.fCurrBlock.Len - NumBlockCharsLeft;
      if NumBlockCharsLeft <= DelCount then begin
        DelCount            :=  DelCount - NumBlockCharsLeft;
        Self.fCurrBlock     :=  Self.fCurrBlock.NextBlock;
        Self.fCurrBlockPos  :=  0;
      end // .if
      else begin
        NewBlock            :=  Self.InsertBlock(TO_THE_RIGHT, Self.fCurrBlock);
        NewBlock.Data       :=  Self.fCurrBlock.Data;
        NewBlock.Len        :=  NumBlockCharsLeft - DelCount;
        NewBlock.StartPos   :=  Self.fCurrBlock.StartPos + Self.fCurrBlockPos + DelCount;
        Self.fCurrBlock     :=  NewBlock;
        Self.fCurrBlockPos  :=  0;
        DelCount            :=  0;
      end; // .else
    end; // .else
  end; // .while
  Self.fTextEnd :=  Self.Pos > Self.Len;
end; // .procedure TTextBlocks.Delete

procedure TTextBlocks.Insert (const Str: string);
var
{U} NewBlock: PTextBlock;
    InsDir:   TDirection;
    StrLen:   integer;
  
begin
  NewBlock  :=  nil;
  // * * * * * //
  StrLen  :=  Length(Str);
  if StrLen > 0 then begin
    if Self.fCurrBlockPos = 0 then begin
      InsDir  :=  TO_THE_LEFT;
    end // .if
    else begin
      InsDir  :=  TO_THE_RIGHT;
    end; // .else
    NewBlock          :=  Self.InsertBlock(InsDir, Self.fCurrBlock);
    NewBlock.Data     :=  Str;
    NewBlock.StartPos :=  1;
    NewBlock.Len      :=  StrLen;
    if Self.fCurrBlockPos > 0 then begin
      NewBlock            :=  Self.InsertBlock(TO_THE_RIGHT, NewBlock);
      NewBlock.Data       :=  Self.fCurrBlock.Data;
      NewBlock.StartPos   :=  Self.fCurrBlock.StartPos + Self.fCurrBlockPos;
      NewBlock.Len        :=  Self.fCurrBlock.Len - Self.fCurrBlockPos;
      Self.fCurrBlock.Len :=  Self.fCurrBlockPos;
      Self.fCurrBlock     :=  NewBlock;
      Self.fCurrBlockPos  :=  0;
    end; // .if
    Self.fLen :=  Self.Len + StrLen;
    Self.fPos :=  Self.Pos + StrLen;
  end; // .if
end; // .procedure TTextBlocks.Insert

procedure TTextBlocks.Replace (ReplCount: integer; const ReplWith: string);
begin
  Self.Delete(ReplCount);
  Self.Insert(ReplWith);
end; // .procedure TTextBlocks.Replace


(* Generic *)


procedure TTextBlocks.Connect (const Source: string; {IN} var {n} Settings: TObject);
begin
  {!} Assert(Settings = nil);
  Self.Clear;
  Self.Insert(Source);
  Self.GotoPos(1);
end; // .procedure TTextBlocks.Connect

procedure TTextBlocks.Clear;
var
{Un}  ThisBlock:  PTextBlock;
{Un}  NextBlock:  PTextBlock;

begin
  ThisBlock :=  Self.fRoot;
  NextBlock :=  nil;
  // * * * * * //
  while ThisBlock <> nil do begin
    NextBlock :=  ThisBlock.NextBlock;
    Dispose(ThisBlock);
    ThisBlock :=  NextBlock;
  end; // .while
  New(Self.fRoot);
  FillChar(Self.fRoot^, sizeof(Self.fRoot^), #0);
  Self.fRoot.StartPos :=  1;
  Self.fCurrBlock     :=  Self.fRoot;
  Self.fCurrBlockPos  :=  0;
  Self.fPos           :=  1;
  Self.fLen           :=  0;
  Self.fTextEnd       :=  TRUE;
end; // .procedure TTextBlocks.Clear

end.
