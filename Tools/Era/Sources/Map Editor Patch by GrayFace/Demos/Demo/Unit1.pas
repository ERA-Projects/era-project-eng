unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, RSMenus, RSRecent, RSSpeedButton, ExtCtrls,
  RSPanel, RSUtils, StdCtrls, RSSpinEdit, RSButton, RSWinController, XPMan,
  RSGlue, RSGraphics, RSLabel, RSQ, RSComboBox, Themes, RSSysUtils,
  RSListBox, RSMemo, ComCtrls, RSTrackBar, RSLang, RSDebug, AppEvnts;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    ImageList1: TImageList;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    UseUnit1: TMenuItem;
    N3: TMenuItem;
    CloseAll1: TMenuItem;
    Close1: TMenuItem;
    SaveAll1: TMenuItem;
    SaveProjectAs1: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    N4: TMenuItem;
    Reopen1: TMenuItem;
    OpenProject1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Other1: TMenuItem;
    N6: TMenuItem;
    Unit1: TMenuItem;
    Frame1: TMenuItem;
    Form1: TMenuItem;
    DataModule1: TMenuItem;
    CLXApplication1: TMenuItem;
    Application1: TMenuItem;
    File2: TMenuItem;
    Exit2: TMenuItem;
    N7: TMenuItem;
    Print2: TMenuItem;
    N8: TMenuItem;
    UseUnit2: TMenuItem;
    N9: TMenuItem;
    CloseAll2: TMenuItem;
    Close2: TMenuItem;
    SaveAll2: TMenuItem;
    SaveProjectAs2: TMenuItem;
    SaveAs2: TMenuItem;
    Save2: TMenuItem;
    N10: TMenuItem;
    Reopen2: TMenuItem;
    OpenProject2: TMenuItem;
    Open2: TMenuItem;
    New2: TMenuItem;
    Other2: TMenuItem;
    N12: TMenuItem;
    Unit2: TMenuItem;
    Frame2: TMenuItem;
    Form2: TMenuItem;
    DataModule2: TMenuItem;
    CLXApplication2: TMenuItem;
    Application2: TMenuItem;
    Panel1: TRSPanel;
    RSSpinEdit1: TRSSpinEdit;
    RSSpinEdit2: TRSSpinEdit;
    RSGlue1: TRSGlue;
    RSPanel1: TRSPanel;
    RecentSep: TMenuItem;
    N11: TMenuItem;
    RSLabel1: TRSLabel;
    RSLabel3: TRSLabel;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    RSComboBox1: TRSComboBox;
    RSLabel2: TRSLabel;
    RSListBox1: TRSListBox;
    RSLabel4: TRSLabel;
    RSMemo1: TRSMemo;
    RSMemo2: TRSMemo;
    RSTrackBar1: TRSTrackBar;
    Bevel1: TBevel;
    RSButton1: TRSButton;
    RSButton2: TRSButton;
    RSButton3: TRSButton;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure RSPanel1Paint(Sender: TRSCustomControl;
      State: TRSControlState; DefaultPaint: TRSProcedure);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Open1Click(Sender: TObject);
    procedure OpenProject1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure UseUnit1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure RSButton1Click(Sender: TObject);
    procedure RSButton2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RSButton2MouseLeave(Sender: TObject);
    procedure RSButton3Click(Sender: TObject);
    procedure RSButton3ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    Recent1: TRSRecent;
    Recent2: TRSRecent;
    procedure Recent1Click(Sender:TRSRecent; FileName:string);
    procedure Recent2Click(Sender:TRSRecent; FileName:string);
    procedure MenuGetText(Item: TMenuItem; var Result:string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  SNone: string = 'None';
  SNoUnits: string = 'No Units';

procedure TForm1.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WinClassName:='RSPak Demo Main Form';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AssertErrorProc:=RSAssertErrorHandler; // Doesn't display unit path in message
  HintWindowClass:=TRSSimpleHintWindow; // Looks better :)
  RSFixThemesBug; // Application doesn't react when themes get turned on (in D7)
  RSDebugUseDefaults; // Enable dubug logs
  RSDebugHook;
  RSHookFlatBevels(self); // Use flat bevels only when themes are disabled
  with RSLanguage.AddSection('[Main Form]', self) do
  begin
    AddItem('SNone', SNone);
    AddItem('SNoUnits', SNoUnits);
  end;
  //  To generate 'Language.txt':
  // RSSaveTextFile(AppPath+'Language.txt', RSLanguage.MakeLanguage);
  try
    RSLanguage.LoadLanguage(RSLoadTextFile(AppPath+'Language.txt'), false);
  except
  end;
  RSMenu.SeparatorsHints:=true;
  RSMenu.OnGetText:=MenuGetText;
  RSMenu.Add(MainMenu1);
  RSMakeToolBar(Panel1, [Open1, OpenProject1, nil, Save1, SaveAs1,
    SaveProjectAs1, SaveAll1, nil, Close1, CloseAll1, nil, Print1, nil, Exit1],
    2);
  Recent1:=TRSRecent.Create(nil, Reopen1, true);
  Recent1.OnClick:=Recent1Click;
  Recent2:=TRSRecent.Create(nil, RecentSep, false, true);
  Recent2.OnClick:=Recent2Click;
  RSComboBox1.ListBorderColor:=clBtnShadow;
  RSMemo1.WordWrap:=true;
  RSMemo2.WordWrap:=true;
  ClientWidth:=Bevel1.Left;
  ClientHeight:=Bevel1.Top;
end;

procedure TForm1.Recent1Click(Sender:TRSRecent; FileName:string);
begin
  Sender.Add(FileName);
end;

procedure TForm1.Recent2Click(Sender:TRSRecent; FileName:string);
begin
  Sender.Add(FileName);
end;

procedure TForm1.MenuGetText(Item: TMenuItem; var Result:string);
begin
  if Item=RecentSep then
    if Reopen1.Count=1 then
      Result:= SNone
    else
      if Reopen1.Count=Reopen1.IndexOf(Item)+1 then
        Result:= SNoUnits;
end;

procedure TForm1.RSPanel1Paint(Sender: TRSCustomControl;
  State: TRSControlState; DefaultPaint: TRSProcedure);
var r:TRect;
begin
  with Sender, Canvas do
  begin
    r:=Rect(0, 0, Sender.Width, Sender.Height);
    RSGradientV(Sender.Canvas, r, clBtnFace, clBtnShadow);
    Brush.Color:=clBtnShadow;
    FrameRect(r);
  end;
end;

procedure TForm1.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  if odSelected in State then
    State:=State+[odFocused];
  with TComboBox(Control) do
    RSPaintList(Control, Canvas, Items[Index], Rect, State);
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with TListBox(Control) do
    RSPaintList(Control, Canvas, Items[Index], Rect, State);
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then exit;
  Recent2.Add(OpenDialog1.FileName);
end;

procedure TForm1.OpenProject1Click(Sender: TObject);
begin
  if not OpenDialog2.Execute then exit;
  Recent1.Add(OpenDialog2.FileName);
end;

procedure TForm1.Close1Click(Sender: TObject);
begin
  Recent1.StoreLast;
  Recent2.StoreLast;
end;

procedure TForm1.UseUnit1Click(Sender: TObject);
begin
  RSMessageBox(Handle,
               'Unit ''Unit1'' already uses all the units in the project.',
               'Information', MB_ICONINFORMATION);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.File1Click(Sender: TObject);
begin
{
 // Hide 'Reopen' if there are recent files

  with Reopen1 do
    Visible:= Count>1;
}
end;

procedure TForm1.RSButton1Click(Sender: TObject);
begin
  RSErrorHint(RSButton1, GetLongHint(RSButton1.Hint), 3000);
end;

procedure TForm1.RSButton2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var p:TPoint;
begin
  GetCursorPos(p);
  inc(p.Y, RSGetCursorHeightMargin);
  RSShowHint(Format('(%d, %d)', [X,Y]), p, MaxInt, true);
end;

procedure TForm1.RSButton2MouseLeave(Sender: TObject);
begin
  RSHideHint(false);
end;

procedure TForm1.RSButton3Click(Sender: TObject);
begin
  RSHelpHint(Sender);
end;

procedure TForm1.RSButton3ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  Handled:= RSHelpHint(Sender);
end;

procedure TForm1.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
const
  Sep = '===================================================================' +
        '============='#13#10#13#10;
begin
  RSAppendTextFile(AppPath + 'ErrorLog.txt', RSLogExceptions + Sep);
  Application.ShowException(E);
end;

end.
