Unit Console;

INTERFACE
Uses Windows,GIANT,SysUtils;

Type
TBuffer=Class
 start:pointer;
 size:integer;
 used:integer;
 function Init(_i:integer):pointer;
 procedure Push(_p:pointer;_i:integer);
 procedure Get(_dest:pointer);
 procedure Kill;
 end;

TCharArray=array[1..2000000000] of char;
PCharArray=^TCharArray;

VAR
ConIn,ConOut:HANDLE;
Temp:integer;
col,back,lastcol,lastback,attr,lastattr:byte;
coord,screen:TCoord;
_tcsbi:TConsoleScreenBufferInfo;
_sr:TSmallRect;
_tci:TCharInfo;
_tir:TInputRecord;

procedure SA(_c,_b:byte);
procedure SC(_c:byte);
procedure SB(_b:byte);
procedure GotoXY(_x,_y:integer);
procedure SetConsoleSize(_x,_y:integer);
function  WhereX:integer;
function  WhereY:integer;
procedure ClrScr;
function  ReadKey:char;
function ReadCode:char;
procedure WriteC(_col:byte;_s:string);
procedure WritelnC(_col:byte;_s:string);
procedure Term(_col:byte;_s:string);
{function Pos(_s1:AnsiString;_s:PCharArray):integer;}
procedure StrReplace(_s1,_s2:string;var _s:AnsiString);
procedure InitConsole;


IMPLEMENTATION


Procedure SA(_c,_b:byte);
 begin
 sc(_c);
 sb(_b);
 end;

Procedure SC(_c:byte);
 begin
 lastcol:=col;
 col:=_c;
 lastattr:=attr;
 attr:=PackAttr(_c,back);
 SetConsoleTextAttribute(ConOut,attr);
 end;

Procedure SB(_b:byte);
 begin
 lastback:=back;
 back:=_b;
 lastattr:=attr;
 attr:=PackAttr(col,_b);
 SetConsoleTextAttribute(ConOut,attr);
 end;

Procedure GotoXY(_x,_y:integer);
 begin
 coord.x:=_x;
 coord.y:=_y;
 SetConsoleCursorPosition(ConOut,coord);
 end;

Procedure SetConsoleSize(_x,_y:integer);
 begin
 screen.x:=_x;
 screen.y:=_y;
 SetConsoleScreenBufferSize(ConOut,screen);
 end;

Function  WhereX:integer;
 begin
 GetConsoleScreenBufferInfo(ConOut,_tcsbi);
 WhereX:=_tcsbi.dwCursorPosition.x;
 end;

Function  WhereY:integer;
 begin
 GetConsoleScreenBufferInfo(ConOut,_tcsbi);
 WhereY:=_tcsbi.dwCursorPosition.y;
 end;

Procedure ClrScr;
 begin
 _sr.left:=0;
 _sr.top:=0;
 _sr.right:=screen.x-1;
 _sr.bottom:=screen.y-1;
 coord.x:=screen.x;
 coord.y:=screen.y-1;
 _tci.attributes:=attr;
 _tci.asciichar:=#32;
 ScrollConsoleScreenBuffer(ConOut,_sr,@_sr,coord,_tci);
 GotoXY(0,0);
 end;

function TBuffer.Init(_i:integer):pointer;
 begin
 size:=_i;
 start:=AllocMem(_i);
 used:=0;
 Init:=start;
 end;

procedure TBuffer.Push(_p:pointer;_i:integer);
 begin
 CopyMemory(pointer(integer(start)+used),_p,_i);
 used:=used+_i;
 end;

procedure TBuffer.Get(_dest:pointer);
 begin
 CopyMemory(_dest,start,used);
 end;

procedure TBuffer.Kill;
 begin
 FreeMem(start,size);
 end;

Function  ReadKey:char;
 begin
 repeat
 ReadConsoleInput(ConIn,_tir,1,temp);
 until ((_tir.EventType and 1)=1) and _tir.KeyEvent.bKeyDown;
 ReadKey:=_tir.KeyEvent.AsciiChar;
 end;

Function ReadCode:char;
 begin
 ReadCode:=char(byte(_tir.KeyEvent.wVirtualScanCode));
 end;

procedure WriteC(_col:byte;_s:string);
 begin
 SC(_col);
 Write(_s);
 SC(lastcol);
 end;

procedure WritelnC(_col:byte;_s:string);
 begin
 SC(_col);
 Writeln(_s);
 SC(lastcol);
 end;

procedure Term(_col:byte;_s:string);
 begin
 WriteC(_col,_s);
 ReadKey;
 ExitProcess(0);
 end;

function Pos(_s1:AnsiString;_s:PCharArray):integer;
var _i,_i1,_i2,_l:integer;
 begin
 _i:=0;
 _i1:=1;
 _i2:=-1;
 _l:=length(_s1);
 while _s^[_i]<>#0 do
  begin
  if _s1[_i1]=_s^[_i] then
   begin
   if _i1=1 then _i2:=_i;
   _i1:=_i1+1;
   if _i1>_l then
    begin
    Pos:=_i2;
    Exit;
    end;
   end
  else
   begin
   _i1:=1;
   end;
  _i:=_i+1;
  end;
 Pos:=-1;
 end;

procedure StrReplace(_s1,_s2:string;var _s:AnsiString);
var _c,_x,_i:integer;_pb:TBuffer;_l,_l1,_l2:integer;
//_c - current index of the string
//_x - distance between current and found position
//_i - found posotion
//_l - length of _s
//_l1 - length of _s1
//_l2 - length of _s2
 begin
 _c:=1;
 _l:=length(_s);
 _l1:=length(_s1);
 _l2:=length(_s2);
 new(_pb);
 _pb.Init(65535);
 repeat
  _i:=Pos(_s1,@_s[_c])+_c;
  if _i<_c then
   begin
   _x:=_l-_c+1;
   _pb.Push(@_s[_c],_x);
   _c:=_c+_x;
   end
  else
   begin
   _x:=_i-_c;
   _pb.Push(@_s[_c],_x);
   _pb.Push(@_s2[1],_l2);
   _c:=_c+_x+_l1;
   end;
 until _c>=_l;
 SetLength(_s,_pb.used);
 _pb.Get(@_s[1]);
 _pb.Kill;
 Dispose(_pb);
 end;

Procedure InitConsole;
 begin
 AllocConsole;
 ConIn:=GetStdHandle(STD_INPUT_HANDLE);
 ConOut:=GetStdHandle(STD_OUTPUT_HANDLE);
 asm
 mov eax,OFFSET InPut
 mov ecx,ConIn
 mov [eax],ecx
 mov eax,OFFSET OutPut
 mov ecx,ConOut
 mov [eax],ecx
 end;
 SA(15,0);
 SetConsoleSize(80,25);
 end;

Begin

End.
