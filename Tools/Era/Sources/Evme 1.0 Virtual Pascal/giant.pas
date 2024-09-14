UNIT GIANT;
{$H-}
{*}  INTERFACE  {*}
USES WINDOWS,VPSYSLOW,STRINGS;

TYPE

TByte=record
 case byte of
  0:(b:byte);
  1:(i:shortint);
  2:(bl:boolean);
  3:(c:char);
 end;

TWord=record
 case byte of
  0:(w:smallword);
  1:(i:smallint);
  2:(l,h:TByte);
 end;

TLongint=record
 case byte of
  0:(l:longint);
  1:(wl,wh:TWord);
  2:(ac:array[0..3] of char);
 end;

TPointer=record
 case byte of
  0:(p:pointer);
  1:(pp:^pointer);
  2:(l:longint);
  3:(pl:^TLongint);
  4:(w32:^TWin32Cell);
  5:(pch:PChar);
  6:(ps:^string);
 end;

TDinArr=record
 is2D:boolean;
 tp:TPointer;
 sz,sx,sa:longint;
 case byte of
  0:(x0,x:longint);
  1:(sy,x1,y1,x2,y2:longint);
 end;

PDinArr=^TDinArr;

TBorder=record
 x1,y1,x2,y2:longint;
 end;

TConsoleWindow=class
  Pos:TBorder;
  Size:TCoord;
  Focus:TBorder;
  WriteArea:TBorder;
  Cur:TCoord;
  Visible:boolean;
  Buffer:PDinArr;
  Col,LastCol,Back,LastBack,Attr,LastAttr:byte;
  Font:byte;
  procedure Init(_Pos:TBorder;
     _Focus:TBorder;
     _WriteArea:TBorder;
     _Cur:TCoord;
     _mx,_my:byte;
     _Vis:boolean;
     _Attr:byte);

  procedure InitDefault(_x,_y:cardinal);
  procedure Move(_x,_y:longint);
  function  WhereX:longint;
  function  WhereY:longint;
  procedure GotoXY(_x,_y:longint);
  procedure SA(_col,_back:byte);
  procedure SC(_col:byte);
  procedure SB(_back:byte);
  procedure Clean(_back:byte);
  procedure Pix(_x,_y,_pix,_attr:longint);
  procedure Line(_x1,_y1,_x2,_y2,_pix,_attr:longint);
  procedure Rectangle(_x1,_y1,_x2,_y2,_pix,_attr:longint;_fill:boolean);
  procedure Show;
  procedure Free(_obj:pointer);
  end;


VAR   Screen:PDinArr;
      TDispCur:TCoord;
      Temp:TLongint;


CONST g1D=FALSE;g2D=TRUE;
      gNew=TRUE;gAdjust=FALSE;
      ScrAttr:byte=15;

Function  Readkey:char;
Function  FlushKey:char;
Procedure Sleep(_msec:longint);
Function  Bit(_l:longint;_n:byte):boolean;
Procedure SetBit(var _l:longint;_n:byte);
Procedure ZeroBit(var _l:longint;_n:byte);
Procedure InvertBit(var _l:longint;_n:byte);
Function  PackAttr(_c,_b:byte):byte;
Procedure UnPackAttr(_a:byte;var _c,_b:byte);
Procedure SetVar(_var,_value:pointer;_sz:longint);
Function  PackRec(_x1,_y1,_x2,_y2:longint):TBorder;
Function  ConvertStringToPchar(_str:string):pchar;
Function  ConvertPcharToString(_pch:pchar):string;
Procedure CreateArray(_x1,_y1,_x2,_y2:longint;
          _sz:cardinal;
          _is2D:boolean;
          var _arr:PDinArr;
          _new:boolean);

Procedure ChangeArray(_x1,_y1,_x2,_y2:longint;
          _sz:cardinal;
          _is2D:boolean;
          var _arr:PDinArr);

Function  DinAddr(_x,_y:longint;var _arr:PDinArr):pointer;
Procedure SetDinInt(_x,_y:longint;var _arr:PDinArr;_value:longint);
Function  GetDinInt(_x,_y:longint;var _arr:PDinArr):longint;
Procedure SetDinVal(_x,_y:longint;var _arr:PDinArr;_val:pointer);
Procedure MoveArray(_rect1,_rect2:TBorder;var _arr1,_arr2:PDinArr);
Procedure FreeArray(var _arr:PDinArr);
Procedure FillMem(_p:pointer;_b:byte;_c:longint);
Procedure TakeSnapshot(_x1,_y1,_x2,_y2:longint;var _source,_img:PDinArr);
Procedure ScrGotoXY(_x,_y:longint);
Procedure InitScreen(col,row:smallword);
Procedure ScreenRedraw;
Procedure ScreenDone;
Function Min(_v1,_v2:integer):integer;
Function Max(_v1,_v2:integer):integer;


{*}  IMPLEMENTATION  {*}


Function  Readkey:char;
 begin
 ReadKey:=SysReadKey;
 end;

Function  FlushKey:char;
 begin
 SysFlushKeyBuf;
 FlushKey:=SysReadKey;
 end;

Procedure Sleep(_msec:longint);
 begin
 SysCtrlSleep(_msec);
 end;

Function  Bit(_l:longint;_n:byte):boolean;
 begin
 if ((_l shr _n)and 1)=1 then Bit:=true
 else Bit:=false;
 end;

Procedure SetBit(var _l:longint;_n:byte);
 begin
 _l:=_l or (1 shl _n);
 end;

Procedure ZeroBit(var _l:longint;_n:byte);
var _t:longint;
 begin
 _l:=_l and not(1 shl _n+1);
 end;

Procedure InvertBit(var _l:longint;_n:byte);
 begin
 _l:=_l xor (1 shl _n);
 end;

Function  PackAttr(_c,_b:byte):byte;
 begin
 PackAttr:=(_b shl 4) or _c;
 end;

Procedure UnPackAttr(_a:byte;var _c,_b:byte);
 begin
 _c:=_a and $F;
 _b:=(_a and $F0)shr 4;
 end;

Procedure SetVar(_var,_value:pointer;_sz:longint);
var _l:longint;_p1,_p2:TPointer;
 begin
 _p1.p:=_var;
 _p2.p:=_value;
 for _l:=1 to (_sz div 4) do
  begin
  _p1.pl^.l:=_p2.pl^.l;
  inc(_p1.l,4);
  inc(_p2.l,4);
  end;
 for _l:=1 to (_sz mod 4) do
  begin
  _p1.pl^.wl.l.b:=_p2.pl^.wl.l.b;
  inc(_p1.l);
  inc(_p2.l);
  end;
 end;

Function  PackRec(_x1,_y1,_x2,_y2:longint):TBorder;
var _tb:TBorder;
 begin
 _tb.x1:=_x1;
 _tb.y1:=_y1;
 _tb.x2:=_x2;
 _tb.y2:=_y2;
 PackRec:=_tb;
 end;

Function  ConvertStringToPchar(_str:string):pchar;
var _p,_pbegin:TPointer;_l,_sz:longint;
 begin
 _sz:=ord(_Str[0]);
 GetMem(_p.p,_sz+1);
 _pbegin.p:=_p.p;
 for _l:=1 to _sz do
  begin
  _p.pl^.wl.l.b:=ord(_Str[_l]);
  inc(_p.l);
  end;
 _p.pl^.wl.l.b:=0;
 ConvertStringToPchar:=_pbegin.pch;
 end;

Function  ConvertPcharToString(_pch:pchar):string;
var _s:string;_l,_sz:longint;
 begin
 _sz:=StrLen(_pch);
 if _sz<=255 then
  begin
  for _l:=1 to _sz do
   begin
   _s[_l]:=_pch^;
   inc(_pch);
   end;
  _s[0]:=chr(_sz);
  ConvertPcharToString:=_s;
  end;
 end;

Procedure CreateArray(_x1,_y1,_x2,_y2:longint;
          _sz:cardinal;
          _is2D:boolean;
          var _arr:PDinArr;
          _new:boolean);

 begin
 New(_arr);
 _arr^.sz:=_sz;
 _arr^.sx:=_x2-_x1+1;
 _arr^.is2D:=_is2D;
 case _is2D of
  g1D:
   with _arr^ do
    begin
    sy:=1;
    x0:=_x1;
    x:=_x2;
    sa:=sx*sz;
    end;
  g2D:
   with _arr^ do
    begin
    sy:=(_y2-_y1+1);
    x1:=_x1;
    y1:=_y1;
    x2:=_x2;
    y2:=_y2;
    sa:=sx*sy*sz;
    end;
 end;
 if _new then GetMem(_arr^.tp.p,_arr^.sa);
 end;

Procedure ChangeArray(_x1,_y1,_x2,_y2:longint;
          _sz:cardinal;
          _is2D:boolean;
          var _arr:PDinArr);

 begin
 with _arr^ do
  begin
  sz:=_sz;
  sx:=(_x2-_x1+1);
  is2D:=_is2D;
  if is2D then
   begin
   sy:=(_y2-_y1+1);
   x1:=_x1;
   y1:=_y1;
   x2:=_x2;
   y2:=_y2;
   sa:=sx*sz;
   end
  else
   begin
   sy:=1;
   x0:=_x1;
   x:=_x2;
   sa:=sx*sz;
   end;
  end;
 end;

Function  DinAddr(_x,_y:longint;var _arr:PDinArr):pointer;
var _p:TPointer;
 begin
 case _arr^.is2D of
  g1D:_p.l:=_arr^.tp.l+(_x-_arr^.x0)*4;
  g2D:_p.l:=_arr^.tp.l+((_x-_arr^.x1)+(_y-_arr^.y1)*_arr^.sx)*4;
 end;
 DinAddr:=_p.p;
 end;

Procedure SetDinInt(_x,_y:longint;var _arr:PDinArr;_value:longint);
var _p:TPointer;_l:TLongint;
 begin
 _p.p:=DinAddr(_x,_y,_arr);
 _l.l:=_value;
 case _arr^.sz of
  1:_p.pl^.wl.l.b:=_l.wl.l.b;
  2:_p.pl^.wl.w:=_l.wl.w;
  4:_p.pl^.l:=_l.l;
 end;
 end;

Function  GetDinInt(_x,_y:longint;var _arr:PDinArr):longint;
var _p:TPointer;
 begin
 _p.p:=DinAddr(_x,_y,_arr);
 GetDinInt:=_p.pl^.l;
 end;

Procedure SetDinVal(_x,_y:longint;var _arr:PDinArr;_val:pointer);
var _p:TPointer;_l:TLongint;
 begin
 _p.p:=DinAddr(_x,_y,_arr);
 SetVar(_p.p,_val,_arr^.sz);
 end;

Procedure MoveArray(_rect1,_rect2:TBorder;var _arr1,_arr2:PDinArr);
var _x,_y:longint;
 begin
 _x:=(_rect1.x2-_rect1.x1+1)*_arr1^.sz;
 for _y:=0 to (_rect1.y2-_rect1.y1) do
  begin
  SetVar(DinAddr(_rect2.x1,_rect2.y1,_arr2),DinAddr(_rect1.x1,_rect1.y1,_arr1),_x);
  inc(_rect1.y1);
  inc(_rect2.y1);
  end;
 end;

Procedure FreeArray(var _arr:PDinArr);
 begin
 if (_arr=nil) then Exit;
 FreeMem(_arr^.tp.p,_arr^.sa);
 Dispose(_arr);
 _arr:=nil;
 end;

Procedure FillMem(_p:pointer;_b:byte;_c:longint);
var _l:longint;_tp:TPointer;_l1:TLongint;
 begin
 _tp.p:=_p;
 for _l:=1 to _c do
  begin
  _tp.pl^.wl.l.b:=_b;
  inc(_tp.l);
  end;
 end;

Procedure TakeSnapshot(_x1,_y1,_x2,_y2:longint;var _source,_img:PDinArr);
 begin
 CreateArray(0,0,_x2-_x1,_y2-_y1,4,g2D,_img,gNew);
 MoveArray(PackRec(_x1,_y1,_x2,_y2),PackRec(_img^.x1,_img^.y1,
  _img^.x2,_img^.y2),_source,_img);
 end;

Procedure ScrGotoXY(_x,_y:longint);
 begin
 TDispCur.x:=_x;
 TDispCur.y:=_y;
 SysTVSetCurPos(_x,_y);
 end;

Procedure InitScreen(col,row:smallword);
var _p1:^TWord;_p2:TPointer;_l:longint;
 begin
 SysSetVideoMode(col,row);
 CreateArray(0,0,79,49,4,g2D,Screen,gNew);
 TDispCur.x:=0;
 TDispCur.y:=0;
 _p1:=SysTVGetSrcBuf;
 _p2.p:=Screen^.tp.p;
 for _l:=1 to (col*row) do
  begin
  _p2.pl^.wl.w:=_p1^.l.b;
  _p2.pl^.wh.w:=_p1^.h.b;
  inc(_p1);
  inc(_p2.l,4);
  end;
 end;

Procedure ScreenRedraw;
var _bs,_bc:TCoord;_wr:TSmallRect;
 begin
 with _bs do
  begin
  x:=Screen^.sx;
  y:=Screen^.sy;
  end;
 with _bc do
  begin
  x:=0;
  y:=0;
  end;
 with _wr do
  begin
  _wr.left:=Screen^.x1;
  _wr.top:=Screen^.y1;
  _wr.right:=Screen^.x2;
  _wr.bottom:=Screen^.y2;
  end;
 WriteConsoleOutPut(SysFileStdOut,Screen^.tp.p,_bs,_bc,_wr);
 ScrGotoXY(TDispCur.x,TDispCur.y);
 end;

Procedure ScreenDone;
 begin
 FreeArray(Screen);
 end;

Function Min(_v1,_v2:integer):integer;
 begin
 if _v1<_v2 then Min:=_v1
 else Min:=_v2;
 end;

Function Max(_v1,_v2:integer):integer;
 begin
 if _v1>_v2 then Max:=_v1
 else Max:=_v2;
 end;

Procedure TConsoleWindow.Init(_Pos:TBorder;
            _Focus:TBorder;
            _WriteArea:TBorder;
            _Cur:TCoord;
            _mx,_my:byte;
            _Vis:boolean;
            _Attr:byte);

 begin
 Pos:=_Pos;
 Size.x:=Pos.x2-Pos.x1+1;
 Size.y:=Pos.y2-Pos.y1+1;
 Focus:=_Focus;
 WriteArea:=_WriteArea;
 Cur:=_Cur;
 Visible:=_Vis;
 Attr:=_Attr;
 LastAttr:=Attr;
 UnPackAttr(Attr,Col,Back);
 UnPackAttr(Attr,LastCol,LastBack);
 Font:=3;
 CreateArray(Pos.x1,Pos.y1,Pos.x2,Pos.y2,4,g2D,Buffer,gNew);
 end;

Procedure TConsoleWindow.InitDefault(_x,_y:cardinal);
var _Pos:TBorder;_Cur:TCoord;
 begin
 with _Pos do
  begin
  x1:=0;
  y1:=0;
  x2:=_x-1;
  y2:=_y-1;
  end;
 with _Cur do
  begin
  x:=0;
  y:=0;
  end;
 Init(_Pos,_Pos,_Pos,_Cur,_x,_y,TRUE,15);
 end;

Procedure TConsoleWindow.Move(_x,_y:longint);
 begin
 Pos.x1:=_x;
 Pos.y1:=_y;
 Pos.x2:=_x+Size.x-1;
 Pos.y2:=_y+Size.y-1;
 end;

Function  TConsoleWindow.WhereX:longint;
 begin
 WhereX:=Cur.x;
 end;

Function  TConsoleWindow.WhereY:longint;
 begin
 WhereY:=Cur.y;
 end;

Procedure TConsoleWindow.GotoXY(_x,_y:longint);
 begin
 with Cur do
  begin
  x:=_x;
  y:=_y;
  end;
 end;

Procedure TConsoleWindow.SA(_col,_back:byte);
 begin
 LastCol:=Col;
 LastBack:=Back;
 LastAttr:=Attr;
 Col:=_col;
 Back:=_back;
 Attr:=PackAttr(_col,_back);
 end;

Procedure TConsoleWindow.SC(_col:byte);
 begin
 LastCol:=Col;
 LastAttr:=Attr;
 Col:=_col;
 Attr:=PackAttr(_col,Back);
 end;

Procedure TConsoleWindow.SB(_back:byte);
 begin
 LastBack:=Back;
 LastAttr:=Attr;
 Back:=_back;
 Attr:=PackAttr(Col,_back);
 end;

Procedure TConsoleWindow.Clean(_back:byte);
var _l:TLongint;_i:longint;_p:TPointer;
 begin
 SB(_back);
 _l.wl.w:=32;
 _l.wh.w:=PackAttr(15,Back);
 _p.p:=Buffer^.tp.p;
 for _i:=1 to (Buffer^.sa div 4) do
  begin
  _p.pl^.l:=_l.l;
  inc(_p.l,4);
  end;
 end;

Procedure TConsoleWindow.Pix(_x,_y,_pix,_attr:longint);
var _l:TLongint;
 begin
 _l.wl.w:=_pix;
 _l.wh.w:=_attr;
 SetDinInt(_x,_y,Buffer,_l.l);
 end;

Procedure TConsoleWindow.Line(_x1,_y1,_x2,_y2,_pix,_attr:longint);
var _x,_xx,_y,_yy:longint;
 begin
 _xx:=_x2-_x1;
 if (_xx>0) then _x:=1;
 if (_xx<0) then _x:=-1;
 if (_xx=0) then _x:=0;
 _yy:=_y2-_y1;
 if (_yy>0) then _y:=1;
 if (_yy<0) then _y:=-1;
 if (_yy=0) then _y:=0;
 Pix(_x1,_y1,_pix,_attr);
 repeat
 _x1:=_x1+_x;
 _y1:=_y1+_y;
 Pix(_x1,_y1,_pix,_attr);
 until (_x1=_x2)and(_y1=_y2);
 end;

Procedure TConsoleWindow.Rectangle(_x1,_y1,_x2,_y2,_pix,_attr:longint;_fill:boolean);
var _i:longint;
 begin
 case _fill of
  FALSE:
   begin
   Line(_x1,_y1,_x2,_y1,_pix,_attr);
   Line(_x1,_y2,_x2,_y2,_pix,_attr);
   Line(_x1,_y1,_x1,_y2,_pix,_attr);
   Line(_x2,_y1,_x2,_y2,_pix,_attr);
   end;
  TRUE:for _i:=_y1 to _y2 do
   begin
   Line(_x1,_i,_x2,_i,_pix,_attr);
   end;
 end;
 end;

Procedure TConsoleWindow.Show;
var _Pos,_Focus:TBorder;_visible:boolean;_dx1,_dy1,_dx2,_dy2:longint;
 begin
 if Visible then
  begin
  _dx1:=0;_dy1:=0;_dx2:=0;_dy2:=0;
  _visible:=true;
  _Pos:=Pos;
  if (_Pos.x1>Screen^.x2) then _visible:=false;
  if (_Pos.x1<0) then
   begin
   _Pos.x1:=0;
   _dx1:=0-Pos.x1;
   end;
  if (_Pos.x2<0) then _visible:=false;
  if (_Pos.x2>Screen^.x2) then
   begin
   _Pos.x2:=Screen^.x2;
   _dx2:=_Pos.x2-Pos.x2;
   end;
  if (_Pos.y1>Screen^.y2) then _visible:=false;
  if (_Pos.y1<0) then
   begin
   _Pos.y1:=0;
   _dy1:=0-Pos.y1;
   end;
  if (_Pos.y2<0) then _visible:=false;
  if (_Pos.y2>Screen^.y2) then
   begin
   _Pos.y2:=Screen^.y2;
   _dy2:=_Pos.y2-Pos.y2;
   end;
  if _visible then
   begin
   _Focus:=Focus;
   with _Focus do
    begin
    x1:=x1+_dx1;
    x2:=x2+_dx2;
    y1:=y1+_dy1;
    y2:=y2+_dy2;
    end;
   MoveArray(_Focus,_Pos,Buffer,Screen);
   end;
  end;
 end;

Procedure TConsoleWindow.Free(_obj:pointer);
var _p:TPointer;
 begin
 if (Self<>nil) then
  begin
  FreeArray(Buffer);
  Dispose(Self);
  _p.p:=_obj;
  _p.pl^.l:=0;
  end;
 end;

BEGIN

END.
