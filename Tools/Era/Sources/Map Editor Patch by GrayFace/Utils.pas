unit Utils;

interface

uses
  Windows, Messages, SysUtils, RSQ, RSSysUtils, Graphics, Math, Common, Classes;

procedure UpdateObjectSquares(Blk:PGroundBlock; ObjNum:int;
  Exist:Boolean = true); deprecated; // Set Exist to false to delete the object

procedure CopyMap(r:TRect); // Unusual TRect: Right = Left + Width - 1
procedure PasteMap(x1, y1:int; IncludeGround:Boolean = true; IncludeObjects:Boolean = true);

function ValidateMap: PPChar;

function ReadBasicObjectProps(p: PChar; var props: TObjectProps; var def: string): PChar;

var PastingMap: Boolean;

implementation

uses Types;

function GetZOrder(Blk:PGroundBlock; ObjNum:int):int;
begin
  Result:= Blk.ObjData.Positions[ObjNum].ZOrder;
end;

function FindPlace(Blk:PGroundBlock; Data:PGroundSquareObjects; ObjNum, ZLine:int):int;

  function GetLine(var Line:int):int;
  begin
    Result:= ZLine;
    if ZLine >= 0 then  Result:= Line;
    //if Result = 0 then  Result:= MaxInt;
  end;

type
  PMy = ^TMy;
  TMy = packed record
    Obj: int;
    Line: int;
  end;

var
  Size,ZOrder:int; p, p1:PMy;
begin
  ZOrder:= GetZOrder(Blk, ObjNum);
  Result:= 0;
  if Data = nil then  exit;
  Size:= 4;
  if ZLine>=0 then
    Size:= 8;
  ZLine:= GetLine(ZLine);

  p:= Data.ListStart;
  p1:= Data.ListEnd;

  while p<>p1 do
  begin
    case GetLine(p.Line) - ZLine of
      0:
        if GetZOrder(Blk, p.Obj) > ZOrder then
        begin
          Result:= (int(p) - int(Data.ListStart)) div Size;
          exit;
        end;

      1..MaxInt:
      begin
        Result:= (int(p) - int(Data.ListStart)) div Size;
        exit;
      end;
    end;
    inc(PByte(p), Size);
  end;
  Result:= (int(p) - int(Data.ListStart)) div Size;
end;

 // Insert or delete element.
procedure ArrayDo(Arr:ptr; Index:int; Size, Count:int; Delete:boolean);
var
  j:int; p:PChar;
begin
  j:=(Count - 1)*Size;
  Index:=Index*Size;
  p:=PChar(Arr);
  if Delete then
    CopyMemory(p + Index, p + Index + Size, j - Index)
  else
    CopyMemory(p + Index + Size, p + Index, j - Index);
end;

procedure ProcessSquareList(Blk:PGroundBlock; var Data:PGroundSquareObjects;
  Index, ObjNum:int; Exist:Boolean; ZLine:int = -1);
var
  OldList:ptr; OldRef:int; OldData:PGroundSquareObjects;
  i, Size, Count:int;
begin
  Size:= 4;
  if ZLine>=0 then
    Size:= 8;

  if Data<>nil then
  begin
    OldList:= Data.ListStart;
    Count:= (int(Data.ListEnd) - int(Data.ListStart)) div Size;
    OldRef:= Data.RefCount;
    if OldRef > 1 then
    begin
      OldData:= Data;
      dec(OldData.RefCount);
      Data:= NewCopy(OldData, SizeOf(TGroundSquareObjects));
    end;
  end else
  begin
    OldList:= nil;
    Count:= 0;
    OldRef:= MaxInt;
    Data:= _malloc(SizeOf(TGroundSquareObjects));
    FillMemory(Data, SizeOf(TGroundSquareObjects), 0);
  end;
  Data.RefCount:=1;

  i:= Count;
  if Index>=0 then  dec(Count);
  if Exist then  inc(Count);

  if Count = 0 then
  begin
    _free(Data);
    Data:= nil;
  end else
  begin
    Data.ListStart:= _malloc(Size*max(i, Count));
    Data.ListEnd:= PChar(Data.ListStart) + Size*Count;
    Data.ListBufEnd:= Data.ListEnd; //PChar(Data.ListStart) + Size*max(i, Count);
    CopyMemory(Data.ListStart, OldList, i*Size);
    if Index>=0 then
      ArrayDo(Data.ListStart, Index, Size, i, true); // Delete last
  end;

  if OldRef<=1 then
    _free(OldList);

   // Insert 
  if Exist then
  begin
    dec(PChar(Data.ListEnd), Size);
    i:= FindPlace(Blk, Data, ObjNum, ZLine);
    inc(PChar(Data.ListEnd), Size);
    ArrayDo(Data.ListStart, i, Size, Count, false);
    pint(PChar(Data.ListStart) + i*Size)^:= ObjNum;
    if ZLine>=0 then
      pint(PChar(Data.ListStart) + i*Size + 4)^:= ZLine;
  end;
end;

function FindInList(List:PGroundSquareObjects; var Index:int; ObjNum:int;
  Shadow:Boolean):int; // Returns ZLine
var i:int; p, p1:pint;
begin
  Index:= -1;
  Result:= -1;
  if List = nil then  exit;
  i:=8;
  if Shadow then
    i:=4;
  p:= List^.ListStart;
  p1:= List^.ListEnd;
  while p<>p1 do
  begin
    if p^ = ObjNum then
    begin
      Index:= (int(p) - int(List^.ListStart)) div i;
      Result:= 0;
      if not Shadow then
      begin
        inc(p);
        Result:= p^;
      end;
      exit;
    end;
    inc(PByte(p),i);
  end;
end;

 // Not exectly as Map Editor, but not bad
function GetZLine(const Props:TObjectProps; x,y:int):int;
var i,j:int; b:Boolean;
begin
  Result:= 0;
  if Props.Flat<>0 then  exit;
  j:= 1 shl x;
  b:= false;
  for i:= 5 downto y do
  begin
    inc(Result);
    if b <> (Props.MaskEmpty[i] and j = 0) then
    begin
      b:= not b;
      if b then  Result:=1;
    end;
  end;
  if Result = 0 then  Result:=1;
end;

procedure UpdateObjectSquares(Blk:PGroundBlock; ObjNum:int; Exist:Boolean = true);
var
  i,j, x,y, ax,ay, ZLine:int;
  b,Equal:Boolean; Props:PObjectProps;
begin
  Assert((ObjNum <> 0) and (Blk.RefCount = 1));
  with Blk.ObjData.Positions[ObjNum] do
  begin
    ax:= x;
    ay:= y;
    Props:= @Obj.Obj.Data.Props;
  end;

  for y:= max(ay - 5, 0) to min(ay, MapSize-1) do
    for x:= max(ax - 7, 0) to min(ax, MapSize-1) do
      with Props^, PGroundSquare(GetGroundPtr(Blk, x, y))^ do
      begin
        ZLine:= GetZLine(Props^, 7 + x - ax, 5 + y - ay);

        b:= Exist and TRSBits(@MaskObject[5 + y - ay]).Bit[7 + x - ax];
        j:= FindInList(Objects, i, ObjNum, false);
        Equal:= (i>=0) = b;
        if Equal and b then
          Equal:= j = ZLine;
        if not Equal then
          ProcessSquareList(Blk, EditGroundPtr(Blk,x,y).Objects,
                            i, ObjNum, b, ZLine);

        b:= Exist and TRSBits(@MaskShadow[5 + y - ay]).Bit[7 + x - ax];
        Equal:= (FindInList(Shadows, i, ObjNum, true)>=0) = b;
        if not Equal then
          ProcessSquareList(Blk, EditGroundPtr(Blk,x,y).Shadows,
                            i, ObjNum, b);
      end;
end;

{==============================================================================}

procedure CopyObject(obj:PMapObject; MemFile: PCMemFile);
var
  stream: Tstreambuf;
begin
  _CMemFile_new(0, 0, MemFile);
  _streambuf_new(0, 0, @stream, MemFile);
  _WriteObj(@stream, obj);
  _streambuf_Free(0, 0, @stream);
end;

function PasteObject(MemFile: PCMemFile; x, y: int):Boolean;
const
 // Move objects anywhare
  PatchPtr = pbyte($42013D);
  NewData: byte = $EB;
var
  stream: Tstreambuf;
  objLink: array[0..1] of ptr;
  ObjAdder: PPObjAdderVMT;
  r: TRect;
  StdData: byte;
begin
  _CMemFile_Seek(0, 0, MemFile, 0, 0);
  _streambuf_new(0, 0, @stream, MemFile);
  _ReadObj(0, 0, MainMap.UndoBlock, MainMap.ObjLoaderUnk, @stream, @objLink);
  _streambuf_Free(0, 0, @stream);
  // Add to map
  r:= Rect(x, y, x+1, y+1);
  Result:= objLink[1] <> nil;
  if Result then
  begin
    StdData:= PatchPtr^;
    if StdData <> NewData then
      DoPatch1(PatchPtr, NewData);
    PastingMap:= true;
    try
      ObjAdder:= MainMap.ObjAdder;
      ObjAdder^^.AddObject(0, 0, ObjAdder, r, objLink[1], MainMap);
    finally
      PastingMap:= false;
      DoPatch1(PatchPtr, StdData);
    end;
  end;
  // Free
  _FreeLoadedObj(0, 0, @objLink);
end;

procedure FreeObject(MemFile: PCMemFile);
begin
  _CMemFile_Free(0, 0, MemFile);
end;

{==============================================================================}

type
  TObjCopyRec = packed record
    X: int;
    Y: int;
    Data: TCMemFile;
  end;

var
  CopiedGround: array of int;
  CopiedGroundX, CopiedGroundY: int;
  CopiedObjects: array of TObjCopyRec;

procedure CopyGround(const r:TRect);
var
  blk: PGroundBlock;
  x, y, w: int;
begin
  blk:= CurrentGroundBlock;
  with r do
  begin
    w:= Right - Left;
    CopiedGroundX:= w;
    CopiedGroundY:= Bottom - Top;
    CopiedGround:= nil;
    SetLength(CopiedGround, w*CopiedGroundY);
    for y:= 0 to CopiedGroundY - 1 do
      for x:= 0 to w - 1 do
        CopiedGround[y*w + x]:= GetGroundPtr(blk, x + Left, y + Top).Bits;
  end;
end;

procedure NoSmoothing;
asm
  ret 4
end;

procedure PasteGround(x1, y1, x2, y2: int);
var
  //a1, a2: PMapArray;
  blk: PGroundBlock;
  r: TRect;
  //p:ptr;
  x, y, w: int;
begin
  r:= Bounds(x1, y1, x1 + x2, y1 + y2);
  w:= CopiedGroundX;

  UniqueUndoBlock;
  blk:= UniqueGroundBlock(GroundBlock^[MainMap^.IsUnderground]);

  for y:= 0 to y2 - y1 - 1 do
    for x:= 0 to x2 - x1 - 1 do
      EditGroundPtr(blk, x + x1, y + y1).Bits:= CopiedGround[y*w + x];

  SmoothMap;
end;

procedure CopyMap(r:TRect);
var
  a: array of PObjPos;
  i,n: int;

begin
  for i := 0 to length(CopiedObjects) - 1 do
    FreeObject(@CopiedObjects[i].Data);
  CopiedObjects:= nil;

  with r, CurrentGroundBlock.ObjData^ do
  begin
    SetLength(a, (int(PositionsEnd) - int(Positions)) div SizeOf(TObjPos) - 1);
    n:= 0;
    for i := 1 to length(a) do
      if Positions[i].Obj <> nil then
        with Positions[i], Obj.Obj.Data.Props do
          if (x >= Left) and (y >= Top) and (x - Width < Right) and (y - Height < Bottom) then
          begin
            a[ZOrder]:= @Positions[i];
            inc(n);
          end;

    SetLength(CopiedObjects, n);
    for i := length(a) - 1 downto 0 do
      if a[i]<>nil then
        with a[i]^, Obj.Obj.Data.Props do
        begin
          dec(n);
          CopiedObjects[n].X:= x - Width - Left + 1;
          CopiedObjects[n].Y:= y - Height - Top + 1;
          CopyObject(Obj.Obj, @CopiedObjects[n].Data);
        end;
  end;
  inc(r.Right);
  inc(r.Bottom);
  CopyGround(r);
end;

procedure PasteMap(x1, y1:int; IncludeGround:Boolean = true; IncludeObjects:Boolean = true);
var
  i, x2, y2: int;
begin
  x2:= min(x1 + CopiedGroundX, MapSize);
  y2:= min(y1 + CopiedGroundY, MapSize);

  _MapProps_NewUndo(0, 0, MapProps);

  inc(SupressUndo);
  try
    if IncludeGround then
      PasteGround(x1, y1, x2, y2);

    if IncludeObjects then
      for i := 0 to length(CopiedObjects) - 1 do
        with CopiedObjects[i] do
          if (X + x1 < x2) and (Y + y1 < y2) then
            PasteObject(@Data, X + x1, Y + y1);
  finally
    dec(SupressUndo);
  end;

  InvalidateMap;
  InvalidateMiniMap;
end;

{==============================================================================}

var ValidationString:string;

procedure AddValidationStr(const s: string);
begin
  if ValidationString <> '' then
    ValidationString:= ValidationString + #10 + s
  else
    ValidationString:= ValidationString + s;
end;


var
  ValidateEnterArray: array[0..255] of array[0..255] of byte;

procedure ValidateEnterGroundBlock(blk: PGroundBlock; z: int);
var
  x1, y1, i, j: int;
  p, p1: PObjPos;
  sq: pbyte;
begin
  if blk.ObjData.Positions = nil then  exit;
  FillChar(ValidateEnterArray, SizeOf(ValidateEnterArray), 0);
  p:= @blk.ObjData.Positions[1];
  p1:= blk.ObjData.PositionsEnd;
  while p<>p1 do
    with p^ do
    begin
      inc(p);
      if Obj = nil then  continue;
      x1:= x; // - 7;
      y1:= y; // - 5;
      with Obj.Obj.Data.Props do
      begin
        for j := 0 to 5 do
          for i := 0 to 7 do
          begin
            sq:= @ValidateEnterArray[x1 + i, y1 + j];
            if TRSBits(@MaskEnter[j])[i] then
              if sq^ <> 0 then
                sq^:= 3
              else
                sq^:= 2
            else
              if not TRSBits(@MaskEmpty[j])[i] then
                sq^:= sq^ or 1;
          end;
      end;
    end;

  for j := 0 to 255 do
    for i := 0 to 255 do
      if ValidateEnterArray[i, j] = 3 then
        AddValidationStr(Format(SValidationEnterOverlap, [i - 7, j - 5, z]));
end;


procedure ValidateEnterOverlap;
begin
  with MapProps.UndoBlock^^ do
  begin
    ValidateEnterGroundBlock(GroundBlock[0], 0);
    if int(GroundBlockEnd) - int(GroundBlock) > 4 then
      ValidateEnterGroundBlock(GroundBlock[1], 1);
  end;
end;

function ValidateMap: PPChar;
begin
  ValidationString:= '';

  ValidateEnterOverlap;

  if ValidationString <> '' then
    Result:= @ValidationString
  else
    Result:= nil;
end;

{==============================================================================}

function ReadBasicObjectProps(p: PChar; var props: TObjectProps; var def: string): PChar;

  function Token:string;
  var p1: PChar;
  begin
    p1:= p;
    while (p1^<>' ') and (p1^<>#0) do  inc(p1);
    SetString(Result, p, int(p1) - int(p));
    while p1^=' ' do  inc(p1);
    p:= p1;
  end;

  procedure ReadMask(var mask; count:int);
  var i:int;
  begin
    for i := count - 1 downto 0 do
    begin
      TRSBits(@mask)[i]:= (p^ = '1');
      inc(p);
    end;
    while p^ = ' ' do  inc(p);
  end;

begin
  def:= Token;
  ReadMask(props.MaskEmpty, 8*6);
  ReadMask(props.MaskEnter, 8*6);
  ReadMask(props.Land, 8*6);
  ReadMask(props.LandPage, 8*6);
  Result:= p;
  props.Typ:= StrToInt(Token);
  props.SubTyp:= StrToInt(Token);
  props.Page:= StrToInt(Token);
  props.Flat:= StrToInt(Token);
end;

end.
