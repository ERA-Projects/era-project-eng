unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, RSSpeedButton, Common, RSQ, ExtDlgs, RSDef,
  RSSysUtils, RSPanel, Menus, RSLang, Math, RSGraphics, Utils;

type
  TCopyMapMode = (cmmNone = 0, cmmPaste, cmmCopySq, cmmCopyRect);

  TForm4 = class(TForm)
    PanelTemplate: TPanel;
    RSSpeedButton7: TRSSpeedButton;
    RSSpeedButton8: TRSSpeedButton;
    RSSpeedButton9: TRSSpeedButton;
    RSSpeedButton10: TRSSpeedButton;
    RSSpeedButton11: TRSSpeedButton;
    RSSpeedButton12: TRSSpeedButton;
    Panel1: TPanel;
    RSSpeedButton1: TRSSpeedButton;
    Panel3: TPanel;
    ButtonExpandRoads: TRSSpeedButton;
    RSSpeedButton2: TRSSpeedButton;
    ButtonSingleSquares: TRSSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    RSSpeedButton4: TRSSpeedButton;
    ButtonRoads1: TRSSpeedButton;
    Panel2: TPanel;
    ButtonRoads2: TRSSpeedButton;
    ButtonRoads3: TRSSpeedButton;
    EditsPopupMenu1: TPopupMenu;
    Highlight1: TMenuItem;
    Panel6: TPanel;
    ButtonCopyMap: TRSSpeedButton;
    ButtonPasteMap: TRSSpeedButton;
    procedure ButtonCopyMapClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RSSpeedButton1Click(Sender: TObject);
    procedure RSSpeedButton2Click(Sender: TObject);
    procedure ButtonSingleSquaresClick(Sender: TObject);
    procedure RSSpeedButton4Click(Sender: TObject);
    procedure ButtonRoads1Click(Sender: TObject);
    procedure EditsPopupMenu1Popup(Sender: TObject);
  private
    FCurrentPanel:TPanel;
    FRoadsAnywhere: Boolean;
    FCopyMapMode: TCopyMapMode;
    procedure SetCopyMapMode(v: TCopyMapMode);
    procedure SetCurrentPanel(v: TPanel);
    procedure SetRoadsAnywhere(v: Boolean);
  protected
    Panels: array[-6..14] of TPanel;
    FBrushBackup: int;
    FBrushBackupX: int;
    FBrushBackupY: int;
  public
    CopyStartX: int;
    CopyStartY: int;
    procedure OnCommand(v:int);
    procedure Initialize;
    procedure AfterLang;
    property CurrentPanel: TPanel read FCurrentPanel write SetCurrentPanel;
    property RoadsAnywhere: Boolean read FRoadsAnywhere write SetRoadsAnywhere;
    property CopyMapMode: TCopyMapMode read FCopyMapMode write SetCopyMapMode;
    procedure TriggerCopyMap;
  end;

var
  Form4: TForm4;

implementation

uses Types, Unit5;

{$R *.dfm}

var
  // TLogPalette.   First int: (palVersion:$300; palNumEntries:10);
  MapColors: array[0..9] of int = ($83952, $8ccede, $4200, $c6c6b5, $6b844a,
                                   $317384, $3184, $4a4a4a, $945208, 0);
  MapLogPal: TLogPal;
  MapPal: TLogPalette absolute MapLogPal;

procedure TForm4.SetCopyMapMode(v: TCopyMapMode);
begin
  if v = FCopyMapMode then  exit;
  with MainMap^ do
  begin
    CopyStartX:= -1;
    if (FCopyMapMode = cmmNone) or (v = cmmNone) then
    begin
      zSwap(FBrushBackup, BrushType);
      zSwap(FBrushBackupX, SelDX);
      zSwap(FBrushBackupY, SelDY);
      if FCopyMapMode = cmmNone then
      begin
        SelDX:= 1;
        SelDY:= 1;
        with Form5 do
        begin
          ParentWindow:= GetParent(hwnd(Page6Window));
          Form5.Show;
          SetWindowPos(Form5.Handle, HWND_TOP, 3, 5, 0, 0, SWP_NOSIZE or SWP_SHOWWINDOW);
          Page6Window.Visible:= false;
        end;
      end else
      begin
        Form5.Hide;
        Page6Window.Visible:= true;
      end;
    end;
    case v of
      cmmPaste, cmmCopySq: BrushType:= 1;
      cmmCopyRect: BrushType:= 2;
    end;
  end;
  FCopyMapMode:= v;
  Form5.UpdateMode;
end;

procedure TForm4.SetCurrentPanel(v: TPanel);
var LastMode: TCopyMapMode;
begin
  if v=FCurrentPanel then exit;
  if v<>nil then
  begin
    v.Left:=0;
    v.Show;
  end;
  if FCurrentPanel<>nil then
    FCurrentPanel.Hide;
  FCurrentPanel:=v;
  if CopyMapMode <> cmmNone then
    if v = Panel6 then
    begin
      LastMode:= CopyMapMode;
      CopyMapMode:= cmmNone;
      CopyMapMode:= LastMode;
    end else
      Form5.Hide;
end;

procedure TForm4.OnCommand(v:int);
begin
  if ToolbarPages=nil then exit;
  with ToolbarPages^ do
  begin
    if MainPage=5 then
      CurrentPanel:=Panels[ObjPage]
    else
      CurrentPanel:=Panels[-MainPage];
  end;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  Width:= 33;
  Height:= 148;
  CurrentPanel:= Panel1;
  Panels[-1]:= Panel1;
  Panels[-2]:= Panel2;
  Panels[-3]:= Panel3;
  Panels[-6]:= Panel6;
  RSSpeedButton1.Glyph:= LoadPic;
  RSSpeedButton2.Glyph:= SavePic;
  ButtonRoads2.Glyph:= ButtonRoads1.Glyph;
  ButtonRoads3.Glyph:= ButtonRoads1.Glyph;
  ButtonCopyMap.Glyph:= CopyPic;
  ButtonPasteMap.Glyph:= PastePic;
end;

procedure TForm4.AfterLang;
begin
  ButtonRoads2.Hint:=ButtonRoads1.Hint;
  ButtonRoads3.Hint:=ButtonRoads1.Hint;
end;

procedure TForm4.Initialize;
begin
  Application.CreateForm(TForm4, Form4);
  self:=Form4;
  HelpFile:=SHelpFile;
  RSLanguage.AddSection('[WoG Button Bar]', self);
end;

procedure PicToMap(Bitmap:TBitmap; Ground:ptr);
var p:PByte; i,j,dy,w,h:int; p1:pint;
begin
  w:=Bitmap.Width;
  h:=Bitmap.Height;
  p:=Bitmap.ScanLine[h-1];
  dy:= (not w + 1) and 3;
  for j:=h-1 downto 0 do
  begin
    for i:=0 to w-1 do
    begin
      if p^>9 then p^:=9;
      p1:= ptr(EditGroundPtr(Ground, i, j)); // p1:= ptr(GetGroundPtr(Ground, i, j));
      //k:=p1^ and MskGroudType;
      //if k<>p^ then
      p1^:=p1^ and not (MskGroundType or MskGroundSubtype)
                       + p^ + RandomizeTile(p^) shl ShGroundSubtype;
      inc(p);
    end;
    inc(p, dy);
  end;
end;

procedure MapToPic(Bitmap:TBitmap; Ground:ptr);
var p:PByte; i,j,dy,w,h:int;
begin
  w:=Bitmap.Width;
  h:=Bitmap.Height;
  p:=Bitmap.ScanLine[h-1];
  dy:= (not w + 1) and 3;
  for j:=h-1 downto 0 do
  begin
    for i:=0 to w-1 do
    begin
      p^:=GetGroundPtr(Ground, i, j).Bits and MskGroundType;
      inc(p);
    end;
    inc(p, dy);
  end;
end;


procedure TForm4.RSSpeedButton1Click(Sender: TObject);
var
  b, Pic:TBitmap; p:ptr;
begin
  try
    if not OpenPictureDialog1.Execute then exit;
    SetForegroundWindow(hwnd(MainWindow));
    b:= nil;
    Pic:= nil;
    try
      Pic:= RSLoadPic(OpenPictureDialog1.FileName);
      b:=TBitmap.Create;
      with b, Canvas do
      begin
        PixelFormat:= pf8bit;
        Palette:= CreatePalette(MapPal);
        Width:= min(MapSize, Pic.Width);
        Height:= min(MapSize, Pic.Height);
        //Brush.Color:= 0;
        //FillRect(ClipRect);
        Draw(0, 0, Pic);
      end;

      NewUndo;
      p:= UniqueGroundBlock(GroundBlock^[MainMap^.IsUnderground]);

      inc(SupressUndo);
      try
        PicToMap(b, p);
        SmoothMap;
      finally
        dec(SupressUndo);
      end;

      InvalidateMap;
      InvalidateMiniMap;
    finally
      Pic.Free;
      b.Free;
    end;
  finally
    Repaint; // Strange bug
  end;
end;

procedure TForm4.RSSpeedButton2Click(Sender: TObject);
var b:TBitmap;
begin
  try
    if not SavePictureDialog1.Execute then exit;
    b:=TBitmap.Create;
    with b do
      try
        Width:= MapSize;
        Height:= Width;
        PixelFormat:= pf8bit;
        Palette:= CreatePalette(MapPal);
        MapToPic(b, GroundBlock^[MainMap^.IsUnderground]);
        RSCreateDir(ExtractFilePath(SavePictureDialog1.FileName));
        b.SaveToFile(SavePictureDialog1.FileName);
      finally
        Free;
      end;
  finally
    Repaint; // Strange bug
  end;
end;

procedure MySmoothing; forward;

var LastSmooth:ptr = @MySmoothing;

{
procedure MySmoothing;
asm
  mov eax, ToolbarPages
  test eax, eax
  jz @normal
  cmp [eax].TToolbarPages.MainPage, 1
  jnz @normal

  xor eax, eax
  call SmoothMap
  ret 8
@normal:
  push LastSmooth
end;
}

procedure MySmoothing;
asm
  xor eax, eax
  call SmoothMap
  ret 4
end;

procedure bbb;
asm
  ret
end;

//  pptr($53AF78)^:=@aaa; // Disable (?)
//  pptr($53AF7C)^:=@aaa; // Disable (?)
//  pptr($53AF80)^:=@aaa; // Disable (?)
//  pptr($53AF84)^:=@aaa; // Disable (?)
//  pptr($53AF88)^:=@aaa; // Disable (?)
//  pptr($53AF8C)^:=@aaa; // Disable (?)
//  pptr($53AF90)^:=@aaa; // Disable (?)
//  pptr($53AF94)^:=@aaa; // Disable objects copying
//  pptr($53AF98)^:=@aaa; // Disable start of normal brush
//  pptr($53AF9C)^:=@aaa; // Disable Smoothing (end) of normal brush
//  pptr($53AFA0)^:=@aaa; // Disable middle of normal brush
//  pptr($53AFA4)^:=@aaa; // Disable (?)
//  pptr($53AFA8)^:=@aaa; // Disable (?)
//  pptr($53AFAC)^:=@aaa; // Disable Rect brush
{
  pptr($53AF78)^:=@aaa; // Disable
  pptr($53AF78)^:=@aaa; // Disable
}

procedure TForm4.ButtonSingleSquaresClick(Sender: TObject);
begin
  zSwap(pint(SmoothingProc)^, int(LastSmooth)); // Change Smoothing of any brush

//  zSwap(pint($53AF9C)^, int(LastSmooth)); // Change Smoothing of normal brush
end;

// Roads:
  //pptr($53A554)^:=@bbb; // Disable ?
  //pptr($53A7B4)^:=@bbb; // Disable ?
  //pptr($53A7D4)^:=@bbb; // Disable ?
  //pptr($53AF98)^:=@bbb; // Disable Brushes

procedure TForm4.RSSpeedButton4Click(Sender: TObject);
begin
  FillMap(true);
end;

procedure TForm4.SetRoadsAnywhere(v: Boolean);
begin
  if FRoadsAnywhere = v then  exit;
  FRoadsAnywhere:=v;
  ButtonRoads1.Down:=v;
  ButtonRoads2.Down:=v;
  ButtonRoads3.Down:=v;
end;

procedure TForm4.TriggerCopyMap;
begin
  case CopyMapMode of
    cmmNone:
      Assert(false);

    cmmPaste:
    begin
      PasteMap(MainMap.SelX, MainMap.SelY, Form5.ButtonGround.Down, Form5.ButtonObjects.Down);
      exit;
    end;

    cmmCopyRect:
      CopyMap(MainMap.Selection);

    cmmCopySq:
      if CopyStartX >= 0 then
      begin
        CopyMap(Rect(CopyStartX, CopyStartY, MainMap.SelX, MainMap.SelY));
        ButtonPasteMap.Visible:= true;
      end else
      begin
        CopyStartX:= MainMap.SelX;
        CopyStartY:= MainMap.SelY;
        Form5.UpdateMode;
        exit;
      end;
  end;
  CopyMapMode:= cmmNone;
  ButtonCopyMap.Down:= false;
  ButtonPasteMap.Down:= false;
  InvalidateMap;
end;

procedure TForm4.ButtonCopyMapClick(Sender: TObject);
begin
  if ButtonCopyMap.Down then
    CopyMapMode:= cmmCopySq
  else if ButtonPasteMap.Down then
    CopyMapMode:= cmmPaste
  else
    CopyMapMode:= cmmNone;
end;

procedure TForm4.ButtonRoads1Click(Sender: TObject);
begin
  RoadsAnywhere:=TRSSpeedButton(Sender).Down;
end;

procedure TForm4.EditsPopupMenu1Popup(Sender: TObject);
begin
  keybd_event(VK_DOWN, 0, 0, 0);
  keybd_event(VK_DOWN, 0, 0, KEYEVENTF_KEYUP);
end;

initialization
  Randomize;
  with MapLogPal do
  begin
    palVersion:=$300;
    palNumEntries:=256;
    Move(MapColors, palPalEntry, SizeOf(MapColors));
  end;
end.
