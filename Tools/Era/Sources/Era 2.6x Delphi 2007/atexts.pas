unit ATexts;
{
DESCRIPTION:  Text model interface
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Utils;

const
  NO_SETTINGS = nil;


type
  {
    First character position is 1.
  }
  AText = class (Utils.TCloneable)
    (***) protected (***)
      fLen:     integer;
      fPos:     integer;
      fTextEnd: boolean;
    
    (***) public (***)
      (* Character navigation *)
      function  GotoNextPos: boolean; virtual; abstract;
      function  GotoPrevPos: boolean; virtual; abstract;
      function  GotoPos (NewPos: integer): boolean; virtual; abstract;
      
      (* Reading operations *)
      function  GetCurrChar (out c: char): boolean; virtual; abstract;
      function  GetStr (StrLen: integer): string; virtual; abstract;
      
      (* Writing operations *)
      function  SetCurrChar (c: char): boolean; virtual; abstract;
      procedure Insert (const Str: string); virtual; abstract;
      procedure Delete (DelCount: integer); virtual; abstract;
      {The same as Delete + Insert}
      procedure Replace (ReplCount: integer; const ReplWith: string); virtual; abstract;
      
      (* Generic *)
      procedure Connect (const Source: string; {IN} var {n} Settings: TObject); virtual; abstract;
      procedure Clear; virtual; abstract;
      
      property  Pos:      integer read fPos;
      property  Len:      integer read fLen;
      property  TextEnd:  boolean read fTextEnd;
  end; // .class AText
  
  {
    "Text over lines".
    Position of first character in line is 1.
    First line number is 1.
    Minimal line count is 1.
  }
  ATextLines  = class (AText)
    (***) protected (***)
      fLineN:         integer;
      fLinePos:       integer;
      fNumLines:      integer;
      fLineEndMarker: char;
    
    (***) public (***)
      (* Line navigation *)
      function  GotoNextLine: boolean; virtual; abstract;
      function  GotoPrevLine: boolean; virtual; abstract;
      function  GotoLine (NewLineN: integer): boolean; virtual; abstract;
      
      (* Position conversions *)
      function  PosToLinePos (Pos: integer; out LineN, LinePos: integer): boolean; virtual; abstract;
      function  LinePosToPos (LineN, LinePos: integer; out Pos: integer): boolean; virtual; abstract;
      
      (* Getting metrics *)
      function  GetLineLen (LineN: integer; out LineLen: integer): boolean; virtual; abstract;
      
      property  LineN:          integer read fLineN;
      property  LinePos:        integer read fLinePos;
      property  NumLines:       integer read fNumLines;
      property  LineEndMarker:  char read fLineEndMarker;
  end; // .class ATextLines


(***) implementation (***)

end.
