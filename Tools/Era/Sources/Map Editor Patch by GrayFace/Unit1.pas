unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RSCommon, StdCtrls, Buttons, RSSpeedButton, ExtCtrls, RSSysUtils,
  RSQ, RSLod, RSDef, Clipbrd, RSGraphics, Common, Math, RSLodEdt, Themes,
  RSWinController, RSUtils, Menus, RSLang, RSEdit,
  RSComboBox, Utils;

type
  TMyListInfo = record
    Address: int;
    Size: int;
    Count: int;
  end;

  TForm1 = class(TForm)
    ComboBox1: TRSComboBox;
    Edit2: TRSEdit;
    RSSpeedButton1: TRSSpeedButton;
    RSSpeedButton2: TRSSpeedButton;
    RSSpeedButton3: TRSSpeedButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label13: TLabel;
    CheckNone: TImage;
    CheckAll: TImage;
    Label6: TLabel;
    Image10: TImage;
    Image11: TImage;
    Label8: TLabel;
    Image12: TImage;
    Label9: TLabel;
    Image15: TImage;
    Label11: TLabel;
    Image16: TImage;
    Label12: TLabel;
    CheckBox1: TCheckBox;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Bevel1: TBevel;
    PaintBox1: TPaintBox;
    ComboType: TRSComboBox;
    Image13: TImage;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure CheckAllClick(Sender: TObject);
    procedure CheckNoneClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RSSpeedButton2Click(Sender: TObject);
    procedure RSSpeedButton3Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image10ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RSSpeedButton1Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure RSSpeedButton1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure ComboTypeChange(Sender: TObject);
    procedure CheckAllMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckAllMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image10MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    {U} Lod:  RSLod.TRSLod;
    H3Sprite: TRSLod;
    CheckY: TBitmap;
    LandBmp: array[0..8] of TBitmap;
    LandControl: array[0..8] of TImage;
    Props: TObjectProps;
    LandBits: TRSBits;
    FActivating: boolean;
    FClipboard: string;
    PicParts: array[0..7, 0..5] of TBitmap;
    FullPic: TBitmap;
    FullPicName: string;
    MouseLeft: int;
    MouseRight: int;
    MouseMiddle: int;
    LastPressed: int;
    Pressed: int;
    SubTypesList: TMyListInfo;
    LastType: int;
    HintsInited: boolean;
    MskFile: TMsk;
    InvalidPic: boolean;
    WasChanged: Boolean;
    OldObjData: PObjectData;
  protected
    procedure WMActivate(var Msg:TWMActivate); message WM_Activate;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure UpdateLand(i:int);
    procedure FillSubTypes;
    procedure MakeListInfo(Num:int);
    procedure FillType(t:int);
    procedure CheckType;
    procedure LoadProps;
    procedure CorrectSize;
    procedure SetEnter;
    procedure ErrorHint(c:TControl; s:string);
    procedure DoCheckAll(b:boolean);
    procedure PaintPicParts(x1, y1, x2, y2:int);
    procedure PaintPicState(b:TBitmap; Empty, Enter:boolean);
    function EmptyPicState(b:TBitmap; State:int):TBitmap;
    procedure RefreshPicPart(x, y:int);
    procedure SetFullPic(s:string);
    procedure PreparePal(Sender: TRSDefWrapper; Pal:PLogPal);
    procedure SetMouseLeft(i:int);
    procedure SetMouseRight(i:int);
    procedure SetMouseMiddle(i:int);
    function SpecFilter(Sender:TRSLodEdit; Index:int; var Str:string):boolean;
    procedure InitHints;
    procedure ChangeGround;
    function SaveProps:boolean;
  public
    procedure Edit;
    procedure NoStdProps;
    procedure Initialize;
    function StoreProps(edx, Obj, a1, a2, a3, a4:pptr):Boolean;
  end;
  
  TEra  = CLASS
    PUBLIC
      {O} Lods: {n} Classes.TStringList {OF RSLod.TRSLod};
    
      CONSTRUCTOR Create;
      CLASS FUNCTION FileIsInLod (CONST FileName: STRING; RawLod: POINTER): BOOLEAN; STDCALL;
      CLASS FUNCTION FindFileLod (CONST FileName: STRING; OUT LodPath: STRING): BOOLEAN; STDCALL;
      
      FUNCTION  GetFileLod (CONST FileName: STRING): {n} RSLod.TRSLod;
  END; // .CLASS TEra
  

var
    Form1:  TForm1;
{O} Era:    TEra;

implementation

{$R *.dfm}

var
  StdPropsText: array[boolean] of string =
                   ('No Standard Properties', 'Standard Properties');

  TypeGroup: array[byte] of byte;

const
  LandNames = $5448B0;
  LandIndex: array[0..8] of int = (21, 0, 50, 50, 50, 50, 50, 50, 20);

const
  _MakeObjectData: procedure(n1, n2, ECX:int; Props, Result:ptr) = ptr($43731E);
    // Result: @ two dwords
    // Result1: PObjectData
    // Result2: Bool - NewOne


CONSTRUCTOR TEra.Create;
BEGIN
  Self.Lods               :=  Classes.TStringList.Create;
  Self.Lods.CaseSensitive :=  FALSE;
  Self.Lods.Sorted        :=  TRUE;
END; // .CONSTRUCTOR TEra.Create   

CLASS FUNCTION TEra.FileIsInLod (CONST FileName: STRING; RawLod: POINTER): BOOLEAN; 
BEGIN
  RESULT  :=  FALSE;
  
  IF FileName <> '' THEN BEGIN
    ASM
      MOV ECX, RawLod
      ADD ECX, 4
      PUSH FileName
      MOV EAX, $4E48F0
      CALL EAX
      MOV RESULT, AL
    END; // .ASM
  END; // .IF
END; // .FUNCTION TEra.FileIsInLod  

CLASS FUNCTION TEra.FindFileLod (CONST FileName: STRING; OUT LodPath: STRING): BOOLEAN;
CONST
  MAX_LOD_COUNT = 100;
  
TYPE
  PLod  = ^TLod;
  TLod  = PACKED RECORD
    Dummy:  ARRAY [0..399] OF BYTE;
  END; // .RECORD TLod

VAR
  Lod:  PLod;
  i:    INTEGER;
  
BEGIN
  Lod :=  Ptr(INTEGER(PPOINTER($4DACE6)^) + SIZEOF(TLod) * (MAX_LOD_COUNT - 1));
  // * * * * * //
  RESULT  :=  FALSE;
  i       :=  MAX_LOD_COUNT - 1;
   
  WHILE NOT RESULT AND (i >= 0) DO BEGIN
    IF PPOINTER(Lod)^ <> NIL THEN BEGIN
      RESULT  :=  Self.FileIsInLod(FileName, Lod);
    END; // .IF
    
    IF NOT RESULT THEN BEGIN
      DEC(Lod);
      DEC(i);
    END; // .IF
  END; // .WHILE

  IF RESULT THEN BEGIN
    LodPath :=  PCHAR(INTEGER(Lod) + 8);
  END; // .IF
END; // .FUNCTION TEra.FindFileLod

FUNCTION TEra.GetFileLod (CONST FileName: STRING): {n} RSLod.TRSLod;
VAR
  LodInd:   INTEGER;
  LodPath:  STRING;

BEGIN
  RESULT  :=  NIL;
  
  IF Self.FindFileLod(FileName, LodPath) THEN BEGIN
    LodInd  :=  Self.Lods.IndexOf(FileName);
    
    IF LodInd = -1 THEN BEGIN
      LodInd  :=  Self.Lods.AddObject
      (
        LodPath,
        RSLod.TRSLod.Create(LodPath)
      );
    END; // .IF
    
    RESULT  :=  RSLod.TRSLod(Self.Lods.Objects[LodInd]);
  END; // .IF
END; // .FUNCTION TEra.GetFileLod

function MakeObjectData(var Props:TObjectProps):PObjectData;
var a:array[0..1] of ptr;
begin
  _MakeObjectData(0, 0, $59f440, @Props, @a);
  Result:=a[0];
  if byte(a[1])<>0 then
    Result.RefCount:=0;
end;

function AddDef(const s:string):int;
var a, last: PDefRec;
begin
  if DefListLast^=DefListEnd^ then
  begin
    Result:= int(DefListEnd^) - DefList^ + $1000;
    ptr(DefList^):= _realloc(ptr(DefList^), Result);
    int(DefListEnd^):= int(DefList^) + Result;
  end;
  GetMem(a, SizeOf(TDefRec));
  DefListLast^^:=a;
  Result:=DefCount^;
  last:=pptr(DefList^+(Result-1)*4)^;
  CopyMemory(a, last, SizeOf(TDefRec));
  with a^ do
  begin
    Str:= _malloc(length(s)+2);
    Str^:= #0;
    inc(Str);
    CopyMemory(Str, ptr(s), length(s)+1);
    StrLen:= length(s);
    StrBufLen:= length(s)+1;
    Number:= Result;
  end;
  DefCount^:= Result + 1;
  int(DefListLast^):= DefList^ + (Result+1)*4;
end;

function GetDefNumber(const s:string):int;
var i:int; a:^PDefRec;
begin
  a:=ptr(DefList^);
  for i:=0 to DefCount^-1 do
  begin
    if AnsiStrIComp(a^.Str, ptr(s))=0 then
    begin
      Result:=i;
      exit;
    end;
    inc(a);
  end;
  Result:=AddDef(s);
end;

function GetDefName(i:int):PChar;
var a:PDefRec;
begin
  a:=pptr(DefList^+i*4)^;
  Result:=a.Str;
end;

function MyVal(s:string; var Num:int):boolean;
label over;
var i,j,k:int;
begin
  j:=0;
  i:=1;
  while i<=length(s) do
  begin
    k:=ord(s[i])-ord('0');
    if (k>=0) and (k<10) then
    begin
      j:=j*10;
      asm
        jo over
      end;
      j:=j+k;
      asm
        jo over
      end;
    end else
      break;
    inc(i);
  end;
  Result:=i>1;
  Num:=j;
  exit;

over:
  Result:=false;
end;

procedure TForm1.UpdateLand(i:int);
begin
  LandControl[i].Picture.Bitmap:=LandBmp[i];
  if LandBits[i] then
    with LandControl[i].Picture.Bitmap.Canvas do
      Draw(12, 11, CheckY);
end;

procedure TForm1.FillSubTypes;
var i:int; p:PChar;
begin
  with ComboBox1, Items, SubTypesList do
  begin
    if Count=0 then
      Style:=csSimple
    else
      Style:=csDropDown;
    Clear;
    for i:=0 to Count-1 do
    begin
      p:=pptr(Address+i*Size)^;
      if (p=nil) or (p^=#0) then
        Add(IntToStr(i))
      else
        Add(IntToStr(i)+'  '+p);
    end;
  end;
end;

procedure TForm1.MakeListInfo(Num:int);
begin
  FillChar(SubTypesList, SizeOf(SubTypesList), 0);
  with SubTypesList do
    case Num of
      5: // Artifact
      begin
        Count:=length(ArtList);
        Size:=SizeOf(TArtRec);
        Address:=int(@ArtList[0].ArTraits[0]);
      end;
      9, 10, 212: // Borderguard
      begin
        Count:=8;
        Size:=4;
        Address:=$5A3238;
      end;
      16: // Creature Bank
      begin
        Count:=length(BankList);
        Size:=4;
        Address:=int(BankList);
      end;
      17: // Creature Generator 1
      begin
        Count:=length(DwellList);
        Size:=SizeOf(TDwellRec);
        Address:=int(@DwellList[0].Name);
      end;
      20: // Creature Generator 4
      begin
        Count:=2;
        Size:=8;
        Address:=$585444;
      end;
      33, 219: // Garrison
      begin
        Count:=2;
        Size:=4;
        Address:=$5A3230;
      end;
      34: // Hero (subtype doesn't metter)
      begin
        Count:=18;
        Size:=$40;
        Address:=$58A29C;
        { // Hero names:
        Count:=156;
        Size:=$5C;
        Address:=$586840; }
      end;
      53: // Mine
      begin
        Count:=8;
        Size:=4;
        Address:=$5A3210;
      end;
      54: // Monster
      begin
        Count:=length(MonList);
        Size:=SizeOf(TMonRec);
        Address:=int(@MonList[0].Name);
      end;
      63: // Pyramid
      begin
        Count:=length(NewObjList);
        Size:=4;
        Address:=int(NewObjList);
      end;
      79: // Resource
      begin
        Count:=8;
        Size:=4;
        Address:=$59F460;
      end;
      98: // Town
      begin
        Count:=9;
        Size:=12;
        Address:=$5A7568;
      end;
      217: // Random leveled dwelling
      begin
        Count:=7;
        Size:=4;
        Address:=$59F4D4;
      end;
      218: // Random dwelling of a certain castle
      begin
        Count:=9;
        Size:=4;
        Address:=$59F4F0;
      end;
      101: // Chests
      begin
        Count:=length(ChestsList);
        Size:=4;
        Address:=int(ChestsList);
      end;
    end;
end;

procedure TForm1.FillType(t:int);
var i,j,k:int;
begin
  NeedObjNames;
  j:=TypeGroup[t];
  with ComboType, Items do
  begin
    Clear;
    for i:=0 to 231 do
      if TypeGroup[i]=j then
      begin
        k:=AddObject(IntToStr(i) + '  ' + ObjNames[i],
                     ptr(i));
        if i=t then
          ItemIndex:=k;
      end;
    if t>231 then
      ItemIndex:=AddObject(IntToStr(t), ptr(t));
  end;
end;

procedure TForm1.CheckType;
var Typ, SubTyp: int; s:string;
begin
  Typ:= int(ComboType.Items.Objects[ComboType.ItemIndex]);

  s:=ComboBox1.Text;
  if not MyVal(s, SubTyp) then
    SubTyp:=Props.SubTyp;

  if Typ<>LastType then
  begin
    MakeListInfo(Typ);
    FillSubTypes;
  end;
  LastType:=Typ;
  if SubTyp>=ComboBox1.Items.Count then
    ComboBox1.Text:=IntToStr(SubTyp)
  else
    ComboBox1.ItemIndex:=SubTyp; // !!!
end;

procedure TForm1.LoadProps;
var i:int; s:string;
begin
  with Props do
  begin
    for i:=0 to 8 do
      UpdateLand(i);
    FillType(Typ);
    ComboBox1.Text:='';
    LastType:= -1;
    CheckType;
    s:=GetDefName(Def);
    Edit2.Text:=s;
    CheckBox1.Checked:=Flat<>0;
  end;
  SetFullPic(s);
end;

procedure TForm1.CorrectSize;
var h,i,j:int;
begin
  with Props do
  begin
    for i:=0 to 5 do
    begin
      MaskEmpty[i]:=MaskEmpty[i] or not MskFile.MaskObject[i];
      MaskEnter[i]:=MaskEnter[i] and MskFile.MaskObject[i];
    end;
    i:=0;
    while (i<6) and (MaskObject[i]=0) and (MaskEmpty[i]=$ff) do  inc(i);
    h:=i;
    Height:=max(Height, 6-i);
    for i:=0 to 7-Width do
      for j:=h to 5 do
        if (MaskEmpty[j] and (1 shl i) = 0) or
           (MaskObject[j] and (1 shl i) <> 0) then
        begin
          Width:=8-i;
          exit;
        end;
  end;
end;

procedure TForm1.SetEnter;
var i,j:int;
begin
  with Props do
  begin
    for j:=5 downto 0 do
    begin
      if MaskEnter[j]=0 then continue;
      for i:=7 downto 0 do
        if MaskEnter[j] and (1 shl i) <> 0 then
        begin
          HasEnter:=1;
          EnterX:=7-i;
          EnterY:=5-j;
          exit;
        end;
    end;
    HasEnter:=0;
  end;
end;

procedure TForm1.ErrorHint(c:TControl; s:string);
var p:TPoint;
begin
  p.X:=c.Left;
  p.Y:=c.BoundsRect.Bottom;
  p:=ClientToScreen(p);
  if c is TWinControl then
    RSSetFocus(TWinControl(c));
  MessageBeep(MB_ICONWARNING);
  RSShowHint(s, p);
end;

function TForm1.SaveProps:boolean;
var
  s:string; i:int; MskBuf: TRSByteArray;
begin
  Result:= false;
  WasChanged:= false;
  with Props do
  begin
    s:=ComboBox1.Text;
    if not MyVal(s, SubTyp) then
    begin
      ErrorHint(ComboBox1, Format(SInvalidNumber, [s]));
      exit;
    end;

    MskBuf:= nil;
    s:=ChangeFileExt(Edit2.Text, '.msg');
    
    Self.Lod :=  Era.GetFileLod(s);
  
    IF Self.Lod = NIL THEN BEGIN
      Self.Lod  :=  H3Sprite;
    END; // .IF
    
    with Lod do
      if RawFiles.FindFile(s, i) then
        MskBuf:= ExtractArray(i);

    if length(MskBuf)>=SizeOf(TMsk) then
    begin
      Width:=MskBuf[0];
      Height:=MskBuf[1];
       // This is the cause of ChangeGround and the routins it uses
      WasChanged:= not CompareMem(@MaskObject, @MskBuf[2], 6) or
                   not CompareMem(@MaskShadow, @MskBuf[2+6], 6) or
                   (Flat <> BoolToInt[CheckBox1.Checked]);
      for i:=0 to 5 do
        MaskObject[i]:=MskBuf[i+2];
      for i:=0 to 5 do
        MaskShadow[i]:=MskBuf[i+2+6];
    end else
    begin
      ErrorHint(Edit2, Format(SMissIncorrect, [s]));
      exit;
    end;

    s:=Edit2.Text;
    
    Self.Lod :=  Era.GetFileLod(s);
  
    IF Self.Lod = NIL THEN BEGIN
      Self.Lod  :=  H3Sprite;
    END; // .IF
    
    if not Lod.RawFiles.FindFile(s, i) then
    begin
      ErrorHint(Edit2, Format(SMiss, [s]));
      exit;
    end;
    if InvalidPic then
    begin
      ErrorHint(Edit2, Format(SInvalid, [s]));
      exit;
    end;

    Flat:=BoolToInt[CheckBox1.Checked];
    Typ:= int(ComboType.Items.Objects[ComboType.ItemIndex]);
    Def:= GetDefNumber(s);

    CorrectSize;
    SetEnter;
  end;
  Result:=true;

  SavingAdvancedProps:= true;
  try
    SendMessage(MenuWindow, WM_COMMAND, CmdProps, 0);
  finally
    SavingAdvancedProps:= false;
  end;

  if WasChanged then
    ChangeGround;
end;

function TForm1.StoreProps(edx, Obj, a1, a2, a3, a4:pptr):Boolean;
var
  Old:PObjectData;
begin
  Obj:= ___RTDynamicCast(Obj, nil, ptr($5857B0){AVTGUIGameObject},
                                   ptr($57D8C8){AVTGameObject}, nil);
  inc(Obj);

  Old:= Obj^;
  OldObjData:= Old;
  PPObjectData(Obj)^:=MakeObjectData(Props);
  Result:= WasChanged or (Obj^ <> Old);
  if Result then
  begin
    dec(Old.RefCount);
    inc(PPObjectData(Obj)^.RefCount);
  end;
end;

procedure TForm1.Edit;
var i:int;
begin
  i:=MainMap.SelObj;
  if HandleAllocated or (i=0) then exit;
  Move(CurrentGroundBlock.ObjData.Positions[i].Obj.Obj.Data.Props, Props, SizeOf(Props));
  LoadProps;

  Application.Handle:=0; // Bugs
  ParentWindow:=0;
  Application.Handle:=hwnd(MainWindow);
  ParentWindow:=hwnd(MainWindow);
  Pressed:=0;
  LastPressed:=0;
  InitHints;

  if TypeGroup[Props.Typ]=0 then
    NoStdProps
  else
    with Label4 do
    begin
      Caption:=StdPropsText[true];
      Cursor:=crHandPoint;
      OnClick:=Label4Click;
    end;
  
  ShowModal;

  DestroyHandle;
{
  ThemeServices.UpdateThemes; // !!! На соплях
}
  FullPicName:='';
end;

procedure TForm1.NoStdProps;
begin
  with Label4 do
  begin
    Caption:=StdPropsText[false];
    Cursor:=crDefault;
    OnClick:=nil;
  end;
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  Hide;
  SendMessage(MenuWindow, WM_COMMAND, CmdProps, 0);
  Show;
end;

procedure TForm1.InitHints;
var i:int; p:PPChar;
begin
  if HintsInited then exit;
  HintsInited:=true;
  p:=ptr($5A25F0);
  for i:=0 to 8 do
  begin
    LandControl[i].Hint:=StripHotkey(p^);
    inc(p);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
const w=16;
var
  b:TBitmap; h:int; back:TColor; i,j:int;
  DefBuf: TRSByteArray;
begin
  RSHintHideAnimationTime:=300;
  ClientWidth:=Bevel1.Left;
  ClientHeight:=Bevel1.Top;
  b:=TBitmap.Create;
  try
    b.Handle:=LoadBitmap($400000, ptr(128));
    h:=b.Height;
    back:=b.Canvas.Pixels[0,0];
    with RSSpeedButton1.Glyph, Canvas do
    begin
      Width:=w+2;
      Height:=h;
      Brush.Color:=back;
      FillRect(ClipRect);
      CopyRect(Bounds(0, 0, w, h), b.Canvas, Bounds(w, 0, w, h));
    end;
    LoadPic:=RSSpeedButton1.Glyph;
    SavePic:=TBitmap.Create;
    with SavePic, Canvas do
    begin
      Width:=w+2;
      Height:=h;
      Brush.Color:=back;
      FillRect(ClipRect);
      CopyRect(Bounds(0, 0, w, h), b.Canvas, Bounds(w*2, 0, w, h));
    end;
    with RSSpeedButton2.Glyph, Canvas do
    begin
      Width:=w+2;
      Height:=h;
      Brush.Color:=back;
      FillRect(ClipRect);
      CopyRect(Bounds(0, 0, w, h), b.Canvas, Bounds(w*4, 0, w, h));
    end;
    CopyPic:=RSSpeedButton2.Glyph;
    with RSSpeedButton3.Glyph, Canvas do
    begin
      Width:=w+2;
      Height:=h;
      Brush.Color:=back;
      FillRect(ClipRect);
      CopyRect(Bounds(0, 0, w, h), b.Canvas, Bounds(w*5, 0, w, h));
    end;
    PastePic:=RSSpeedButton3.Glyph;
  finally
    b.Free;
  end;

  H3Sprite:= TRSLod.Create(AppPath + 'Data\h3sprite.lod');
  with H3Sprite do
    for i:=0 to high(LandBmp) do
    begin
      Assert(RawFiles.FindFile(PPChar(LandNames+i*4)^, j));
      DefBuf:= ExtractArray(j);
      with TRSDefWrapper.Create(DefBuf) do
      try
        LandBmp[i]:=ExtractBmp(LandIndex[i]);
        //LandBmp[i].Height:=31;
        LandBmp[i].PixelFormat:=pf32bit;
      finally
        Free;
      end;
    end;

  CheckY:=CheckAll.Picture.Bitmap;
  CheckY.Transparent:=true;

  for i:=0 to 8 do
  begin
    LandControl[i]:=(FindComponent('Image'+IntToStr(i+1)) as TImage);
    LandControl[i].Tag:=i;
  end;

  LandBits:=TRSBits(@Props.Land);

  Icon:=nil;

  for j:=0 to 5 do
    for i:=0 to 7 do
    begin
      PicParts[i,j]:=TBitmap.Create;
      with PicParts[i,j] do
      begin
        Width:=32;
        Height:=32;
        HandleType:=bmDIB;
      end;
    end;

  FullPic:=TBitmap.Create;
  FullPic.Width:=32*8;
  FullPic.Height:=32*6;
  Image10.Picture.Bitmap:=EmptyPicState(nil, 2);
  Image11.Picture.Bitmap:=EmptyPicState(nil, 0);
  Image12.Picture.Bitmap:=EmptyPicState(nil, 1);
  MouseLeft:=0;
  Image15.Picture.Bitmap:=EmptyPicState(nil, 0);
  MouseRight:=2;
  Image16.Picture.Bitmap:=EmptyPicState(nil, 2);
  MouseMiddle:=1;
  Image13.Picture.Bitmap:=EmptyPicState(nil, 1);
{
  ThemeServices.UpdateThemes;
  if ThemeServices.ThemesEnabled then
  begin
    RSSpeedButton1.Flat:=true;
    RSSpeedButton2.Flat:=true;
    RSSpeedButton3.Flat:=true;
  end;
}
end;

procedure InitTypeGroups;
var i:int;
begin
  for i:=255 downto 0 do
    case i of
      34:
        TypeGroup[i]:= 1;
      62:
        TypeGroup[i]:= 22;
      70:
        TypeGroup[i]:= 23;
      54, 71, 72, 73, 74, 75, 162, 163, 164:
        TypeGroup[i]:= 2;    // Monster, Random Monsters
      98:
        TypeGroup[i]:= 3;
      77:
        TypeGroup[i]:= 25;
      26:
        TypeGroup[i]:= 4;
      91, 59:
        TypeGroup[i]:= 5;    // Sign, Bottle
      88, 89, 90:
        TypeGroup[i]:= 6;    // Shrines
      87:
        TypeGroup[i]:= 6;    // Shipyard
      113:
        TypeGroup[i]:= 27;   // Witch Hut
      17, 20:
        TypeGroup[i]:= 26;   // Creature Generator 1, 4
      255, 220, 53, 42:
        TypeGroup[i]:= 24;   // Mine, Lighthouse
      81:
        TypeGroup[i]:= 7;
      33, 219:
        TypeGroup[i]:= 8;    // Garrisons
      83:
        TypeGroup[i]:= 9;
      215:
        TypeGroup[i]:= 10;
      79, 76:
        TypeGroup[i]:= 12;   // Resourse, Random Resourse
      216:
        TypeGroup[i]:= 14;
      217:
        TypeGroup[i]:= 15;
      218:
        TypeGroup[i]:= 16;
      214:
        TypeGroup[i]:= 17;
      36:
        TypeGroup[i]:= 18;
      6:
        TypeGroup[i]:= 19;
      5, 65, 66, 67, 68, 69:
        TypeGroup[i]:= 20;   // Artifact, Random Artifacts
      93:
        TypeGroup[i]:= 21;
    end;
end;

{
  Based on props in map file only: 

      62, 34, 70:
        TypeGroup[i]:= 1;
      54, 71, 72, 73, 74, 75, 162, 163, 164:
        TypeGroup[i]:= 2;
      98, 77:
        TypeGroup[i]:= 3;
      26:
        TypeGroup[i]:= 4;
      91, 59:
        TypeGroup[i]:= 5;
      255, 53, 220, 113, 42, 88, 89, 90, 87, 17, 20:
        TypeGroup[i]:= 6;
      81:
        TypeGroup[i]:= 7;
      33, 219:
        TypeGroup[i]:= 8;
      83:
        TypeGroup[i]:= 9;
      215:
        TypeGroup[i]:= 10;
      79, 76:
        TypeGroup[i]:= 12;
      216:
        TypeGroup[i]:= 14;
      217:
        TypeGroup[i]:= 15;
      218:
        TypeGroup[i]:= 16;
      214:
        TypeGroup[i]:= 17;
      36:
        TypeGroup[i]:= 18;
      6:
        TypeGroup[i]:= 19;
      5, 65, 66, 67, 68, 69:
        TypeGroup[i]:= 20;
      93:
        TypeGroup[i]:= 21;
}

procedure TForm1.Initialize;
begin
  InitTypeGroups;
  Application.CreateForm(TForm1, Form1);
  self:=Form1;
  HelpFile:=SHelpFile;
  DestroyHandle;
  with RSLodEdit do
  begin
    Initialize(false, false);
    BorderIcons:=[biSystemMenu,biMaximize];
    SpecFilter:=self.SpecFilter;
    EmulatePopupShortCuts:=true;
    ShowOneGroup:=true;
    Favorites:=PatchPath+'Favorites\';
    Icon.Handle:=LoadIcon($400000, ptr(128));
  end;
  with RSLanguage.AddSection('[Advanced Properties]', self) do
  begin
    AddItem('StdPropsText', StdPropsText[true]);
    AddItem('NoStdPropsText', StdPropsText[false]);
  end;
end;

function TForm1.SpecFilter(Sender:TRSLodEdit; Index:int; var Str:string):boolean;
var i,j:int; s:string;
begin
  s:=ChangeFileExt(Str, '.msg');
  Result:=false;
  with Sender.Archive do
    for i:=Index+1 to Count-1 do
    begin
      j:=AnsiStrIComp(Names[i], ptr(s));
      if j=0 then Result:=true;
      if j>=0 then exit;
    end;
end;

procedure TForm1.Image1Click(Sender: TObject);
var i:int;
begin
  i:=TControl(Sender).Tag;
  LandBits[i]:=not LandBits[i];
  UpdateLand(i);
end;

procedure TForm1.DoCheckAll(b:boolean);
var i:int;
begin
  for i:=0 to high(LandBmp) do
    if LandBits[i]<>b then
    begin
      LandBits[i]:=b;
      UpdateLand(i);
    end;
end;

procedure TForm1.CheckAllClick(Sender: TObject);
begin
  DoCheckAll(true);
end;

procedure TForm1.CheckNoneClick(Sender: TObject);
begin
  DoCheckAll(false);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if SaveProps then
    ModalResult:=mrOk;
end;

procedure TForm1.WMActivate(var Msg:TWMActivate);
begin
  if not FActivating and (Msg.Active<>WA_INACTIVE) then
  begin
    FActivating:=true;
    BringWindowToTop(Handle);
    FActivating:=false;
  end;
  inherited;
end;

procedure TForm1.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WinClassName:='Advanced Properties Form';
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      if ComboType.DroppedDown or
         ComboBox1.DroppedDown and (ComboBox1.Style<>csSimple) then
        exit
      else
        Close;
    else exit;
  end;
  Key:=0;
end;

procedure TForm1.FormShow(Sender: TObject);
var r:TRect;
begin
  r:=MainWindow.AbsoluteRect;
  Left:=(r.Left+r.Right-Width) div 2;
  Top:=(r.Top+r.Bottom-Height) div 2;
end;

procedure TForm1.RSSpeedButton2Click(Sender: TObject);
begin
  if Edit2.Text='' then exit;
  Clipboard.AsText:=Edit2.Text;
  FClipboard:=Edit2.Text;
end;

procedure TForm1.RSSpeedButton3Click(Sender: TObject);
var s:string;
begin
  if IsClipboardFormatAvailable(CF_TEXT) then
    s:=Clipboard.AsText
  else
    s:=FClipboard;
  if s='' then exit;
  Edit2.Text:=s;
  SetFullPic(s);
end;

procedure TForm1.PaintPicState(b:TBitmap; Empty, Enter:boolean);
var c:TColor; i:int;
begin
  if Empty then
  begin
    c:=clBtnShadow;
    i:=0;
  end else
    if Enter then
    begin
      c:=clYellow;
      i:=64;
    end else
    begin
      c:=clRed;
      i:=64;
    end;

  if i<>0 then
    RSMixPicColor32(b, b, c, 256-i, i);

  with b.Canvas do
  begin
    Pen.Color:=c;
    Brush.Style:=bsClear;
    Rectangle(ClipRect);
  end;

end;

function TForm1.EmptyPicState(b:TBitmap; State:int):TBitmap;
begin
  if b=nil then
  begin
    b:=TBitmap.Create;
    with b do
    begin
      Width:=17;
      Height:=17;
      PixelFormat:=pf32bit;
    end;
  end;
  Result:=b;
  with b.Canvas do
  begin
    Brush.Color:=clBtnFace;
    Brush.Style:=bsSolid;
    FillRect(ClipRect);
  end;
  PaintPicState(b, State and 2 <> 0, State and 1 <> 0);
end;

procedure TForm1.RefreshPicPart(x, y:int);
begin
  with PicParts[x,y].Canvas do
    CopyRect(ClipRect, FullPic.Canvas, Bounds(32*x, 32*y, 32, 32));

  if MskFile.MaskObject[y] and (1 shl x) <>0 then
    PaintPicState(PicParts[x,y], Props.MaskEmpty[y] and (1 shl x) <> 0,
                  Props.MaskEnter[y] and (1 shl x) <> 0);

  if Visible then PaintPicParts(x, y, x, y);
end;

procedure TForm1.PreparePal(Sender: TRSDefWrapper; Pal:PLogPal);
begin
  int(Pal.palPalEntry[0]):=ColorToRGB(clBtnFace);
  int(Pal.palPalEntry[4]):=RSMixColors(clBtnFace, 0, 124);
  int(Pal.palPalEntry[1]):=RSMixColors(clBtnFace, 0, 182);
end;

procedure TForm1.SetFullPic(s:string);
var
  i,j:int; b:TBitmap; Buf: TRSByteArray;
  
begin
  if s=FullPicName then exit;
  FullPicName:=s;
  b:=nil;
  InvalidPic:=false;
  
  Self.Lod :=  Era.GetFileLod(s);
  
  IF Self.Lod = NIL THEN BEGIN
    Self.Lod  :=  H3Sprite;
  END; // .IF
  
  with Lod do
    if RawFiles.FindFile(s, j)  then
    try
      Buf:= ExtractArray(j);
      with TRSDefWrapper.Create(Buf) do
      try
        OnPreparePalette:=PreparePal;
        b:=ExtractBmp(0);
      finally
        Free;
      end;
    except
      InvalidPic:=true;
    end;

  try
    with FullPic.Canvas do
    begin
      Brush.Color:=clBtnFace;
      FillRect(ClipRect);
      if b<>nil then
        CopyRect(Rect(32*8-b.Width, 32*6-b.Height, 32*8, 32*6), b.Canvas,
                 b.Canvas.ClipRect);
    end;
  finally
    b.Free;
  end;

  FillChar(MskFile, SizeOf(MskFile), 0);
  
  Self.Lod :=  Era.GetFileLod(ChangeFileExt(s, '.msg'));
  
  IF Self.Lod = NIL THEN BEGIN
    Self.Lod  :=  H3Sprite;
  END; // .IF
  
  with Lod do
    if RawFiles.FindFile(ChangeFileExt(s, '.msg'), j) then
    begin
      Buf:= ExtractArray(j);
      CopyMemory(@MskFile, ptr(Buf),
                  min(length(Buf), SizeOf(TMsk)));
    end;

  for j:=0 to 5 do
    for i:=0 to 7 do
      RefreshPicPart(i, j);
end;

procedure TForm1.PaintPicParts(x1, y1, x2, y2:int);
const r: TRect = (Left:0; Top:0; Right:32; Bottom:32);
var i,j:int;
begin
  for j:=y1 to y2 do
    for i:=x1 to x2 do
      with PaintBox1.Canvas do
      begin
        CopyRect(Bounds(i*32, j*32, 32, 32), PicParts[i,j].Canvas, r);
      end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var r:TRect;
begin
  r:=PaintBox1.Canvas.ClipRect;
  PaintPicParts(r.Left div 32, r.Top div 32,
               (r.Right-1) div 32, (r.Bottom-1) div 32);
end;

procedure TForm1.SetMouseLeft(i:int);
begin
  if i=MouseLeft then exit;
  MouseLeft:=i;
  EmptyPicState(Image15.Picture.Bitmap, i);
end;

procedure TForm1.SetMouseRight(i:int);
begin
  if i=MouseRight then exit;
  MouseRight:=i;
  EmptyPicState(Image16.Picture.Bitmap, i);
end;

procedure TForm1.SetMouseMiddle(i:int);
begin
  if i=MouseMiddle then exit;
  MouseMiddle:=i;
  EmptyPicState(Image13.Picture.Bitmap, i);
end;

procedure TForm1.Image10Click(Sender: TObject);
begin
  SetMouseLeft(TControl(Sender).Tag);
end;

procedure TForm1.Image10ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  SetMouseRight(TControl(Sender).Tag);
end;

procedure TForm1.Image10MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with TControl(Sender) do
    if (Button=mbMiddle) and (x>=0) and (y>=0) and (x<Width) and (y<Height) then
      SetMouseMiddle(Tag);
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i:int;
begin
  i:=byte(Button)+1;
  LastPressed:=Pressed;
  Pressed:=i;
  PaintBox1MouseMove(Sender, [], x, y);
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i:int;
begin
  i:=byte(Button)+1;
  if i=Pressed then
    Pressed:=LastPressed;
  LastPressed:=0;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var Last, i:int;
begin
  case Pressed of
    1:  i:=VK_LBUTTON;
    2:  i:=VK_RBUTTON;
    3:  i:=VK_MBUTTON;
    else exit;
  end;

  if GetKeyState(i)>=0 then
    Pressed:=0;

  case Pressed of
    1:  i:=MouseLeft;
    2:  i:=MouseRight;
    3:  i:=MouseMiddle;
    else exit;
  end;

  x:=x div 32;
  y:=y div 32;
  if (x<0) or (y<0) or (x>7) or (y>5) or
     (MskFile.MaskObject[y] and (1 shl x) = 0) then  exit;

  Last:=0;
  if Props.MaskEmpty[y] and (1 shl x) <> 0 then Last:=Last or 2;
  if Props.MaskEnter[y] and (1 shl x) <> 0 then Last:=Last or 1;

  if Last=i then exit;

  TRSBits(@Props.MaskEmpty[y])[x]:= i and 2 <> 0;
  TRSBits(@Props.MaskEnter[y])[x]:= i and 1 <> 0;

  RefreshPicPart(x, y);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RSHideHint(false);
end;

procedure TForm1.RSSpeedButton1Click(Sender: TObject);
begin
  with RSLodEdit do
  begin
    //PPtr(@ListView1.Items.Owner)^:=ListView1;
    if LoadShowModal('.def', Edit2.Text, AppPath+'Data\H3sprite.lod') = mrOk then
    begin
      Edit2.Text:=RSLodResult;
      SetFullPic(Edit2.Text);
    end;
    //PPtr(@ListView1.Items.Owner)^:=self; // Чтоб не тормозило
  end;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  SetFullPic(Edit2.Text);
end;

function TForm1.FormHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
  Result:=true;
  WinHelp(Handle, ptr(HelpFile), Command, Data);
end;

procedure TForm1.RSSpeedButton1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var b:boolean;
begin
  if TControl(Sender).HelpContext<>0 then
    FormHelp(HELP_CONTEXTPOPUP, TControl(Sender).HelpContext, b);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, HelpContext);
end;

procedure TForm1.ComboTypeChange(Sender: TObject);
begin
  CheckType;
end;

procedure TForm1.CheckAllMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button<>mbLeft then exit;
  (Sender as TControl).Top:= (Sender as TControl).Top + 1;
end;

procedure TForm1.CheckAllMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button<>mbLeft then exit;
  (Sender as TControl).Top:= (Sender as TControl).Top - 1;
end;

procedure TForm1.ChangeGround;
var
  i: int;
  o: PMapObject;
  data: PObjectData;
  gb: PGroundBlock;
  pos: array[0..1] of int;
begin
  // UnplantObject, PlantObject
  i:= MainMap.SelObj;
  gb:= CurrentGroundBlock;
  with gb.ObjData.Positions[i] do
  begin
    o:= Obj.Obj;
    pos[0]:= x;
    pos[1]:= y;
  end;
  data:= o.Data;
  o.Data:= OldObjData;
  _UnplantObject(0, 0, @gb.SizeIndex, i);
  o.Data:= data;
  _PlantObject(0, 0, @gb.SizeIndex, i, pos, o);
  //UpdateObjectSquares(CurrentGroundBlock, MainMap.SelObj);
  InvalidateMap;
end;

begin
  Era :=  TEra.Create;
end.
