unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RSQ, RSSysUtils, RSStrUtils, ExtCtrls, Common, Math,
  Buttons, RSSpeedButton, ShellAPI, RSUtils, RSLang, Menus;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Bevel1: TBevel;
    RSSpeedButton1: TRSSpeedButton;
    RSSpeedButton2: TRSSpeedButton;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    Label3NoAutorefresh: TLabel;
    NTGManu: TPopupMenu;
    procedure Label1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RSSpeedButton1Click(Sender: TObject);
    procedure RSSpeedButton2Click(Sender: TObject);
  protected
    FCanTrack: boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure UpdateEdit;
    procedure CalcSizes;
    procedure ReBind;
    procedure UpdateBinding(var a:TEventRec{; FileName:string});
    procedure TrackingProc;
    procedure SetCanTrack(v:boolean);
    procedure DoStopTracking;
    procedure LanguageLoaded(var Errors:string);
  public
    RelativePath: Boolean;
    function ShowHelp:boolean;
    procedure CheckCreate;
    procedure Start(APanel, AEdit:TRSWnd);
    procedure Stop;
    procedure UpdateBindings;
    procedure StartTracking;
    procedure StopTracking;
    procedure UpdateTracking;
    procedure OpenAllScripts;
    procedure UnbindAll;
    procedure Initialize;
    property CanTrack:boolean read FCanTrack write SetCanTrack;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

const
  FirstDay = '600';

const
  Signature:array[boolean] of string = ('ZVSD BIND TO ', 'ZVSE BIND TO ');
  SignatureLen = length('ZVSE BIND TO '); // 
    // #9 in the end
  ZVSE = 'ZVSE';

var
  BindText: array[boolean] of string = ('Bind', 'Unbind');
  BindHint: array[boolean] of string = ('Bind to a script file', '');
  Label3Text: array[boolean] of string;

var
  Panel, Edit, FLabel: TRSWnd;
  FileName, FileText: string; IsScript:boolean;
  Binded, ShouldTrack: boolean;

function IsThere1(a:string; s:string):boolean;
begin
  if s='' then result:=false
  else Result:=CompareMem(ptr(a), ptr(s), length(s));
end;

function MyShellExecute(Path:string; Params:string=''; Dir:string=''; CmdShow:int=SW_NORMAL):boolean;
begin
  if Dir='' then Dir:=ExtractFilePath(Path);
  Result:=ShellExecute(0, nil, ptr(Path), ptr(Params), ptr(Dir), CmdShow)>32;
  if not Result then RaiseLastOSError;
end;

function MyGetFileTime(const FileName: string): Int64;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      Result:=Int64(FindData.ftLastWriteTime);
      exit;
    end;
  end;
  Result := -1;
end;





function IsBound(const s:string):boolean;
begin
  Result:=(length(s)>=SignatureLen) and
          (IsThere1(s, Signature[true]) or IsThere1(s, Signature[false]));
end;

function ParseBind(const s:string):boolean;
var i,j:int;
begin
  j:=length(s);
  i:=pos(#9, s);
  Result:= i>0;
  if not Result then exit;
  IsScript:=IsThere1(s, ZVSE); // Signature[true]);

  SetString(FileName, PChar(@s[SignatureLen+1]), i-SignatureLen-1);
  FileName:=RSStringReplace(FileName, '|', '!');
  SetCurrentDir(FilePath);
  FileName:=ExpandFileName(FileName);

  SetString(FileText, PChar(@s[i+1]), j-i);
  if IsScript and not IsThere1(s, ZVSE) then
    FileText:= ZVSE + FileText;
end;

procedure ParseNoBind(s:string);
begin
  IsScript:=(length(s)>=4) and (pint(s)^=pint(@ZVSE[1])^);
  FileText:=s;
end;

function CheckBind:boolean;
var s:string;
begin
  Result:=false;
  s:=Edit.Text;
  if not IsBound(s) or not ParseBind(s) then exit;
  Result:=FileExists(FileName);
  if not Result then
    Edit.Text:=FileText;
end;

procedure TForm2.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WinClassName:='Events Binding Form';
end;

procedure TForm2.UpdateEdit;
var s:string;
begin
  s:=RSStringReplace(Edit1.Text, '!', '|');
  if RelativePath then
    s:=ExtractRelativePath(FilePath, s);
    
  if Binded then
    Edit.Text:=Signature[IsScript] + s +#9+ FileText
  else
    Edit.Text:=FileText;
end;

var Sized:boolean;

procedure TForm2.CalcSizes;
var j:int; r, r1:TRect;
begin
  if Sized then exit;
  Sized:=true;
  j:=Edit.AbsoluteRect.Top - FLabel.AbsoluteRect.Top + Label1.Top - Edit1.Top;
  with Edit1 do  Top:=Top+j;
  with RSSpeedButton1 do  Top:=Top+j;
  with RSSpeedButton2 do  Top:=Top+j;
  with Label3 do  Top:=Top+j;
  r1:=Edit.BoundsRect;

  r:=Label1.BoundsRect;
  r.Left:=FLabel.BoundsRect.Right;
  r.Right:=r1.Right-2;
  Label1.BoundsRect:=r;

  r:=Edit1.BoundsRect;
  r.Left:=r1.Left;
  r.Right:=r1.Right + r.Right - Bevel1.Left;
  Edit1.BoundsRect:=r;

  Label2.Left:=r1.Left;
  Label2.Width:=FLabel.Width;
  with RSSpeedButton1 do  Left:=Left + r1.Right - Bevel1.Left;
  with RSSpeedButton2 do  Left:=Left + r1.Right - Bevel1.Left;

  r:=Label3.BoundsRect;
  r.Left:=r1.Left;
  r.Right:=r1.Right;
  Label3.BoundsRect:=r;
end;

procedure TForm2.ReBind;
begin
  Label1.Caption:=BindText[Binded];
  Label1.Hint:=BindHint[Binded];
  if Binded then
    Height:=Label3.BoundsRect.Bottom
  else
    Height:=Label1.BoundsRect.Bottom;
  Edit1.Visible:=Binded;
  RSSpeedButton1.Visible:=Binded;
  RSSpeedButton2.Visible:=Binded;
  Label2.Visible:=Binded;
  Label3.Visible:=Binded;
  Edit.Visible:=not Binded;
  FLabel.Visible:=not Binded;
  RSMakeTransparent(self);
end;

function TForm2.ShowHelp:boolean;
begin
  Result:= Binded and Panel.Visible;
  if Result then
    WinHelp(Handle, ptr(HelpFile), HELP_CONTEXT, 262140);
end;

procedure TForm2.CheckCreate;
var s:string;
begin
  if not Binded then exit;
  s:=Edit1.Text;
  if FileExists(s) then exit;
  RSSaveTextFile(s, RSStringReplace(FileText, #13#10, #10));
end;

procedure TForm2.Start(APanel, AEdit:TRSWnd);
var c:TRSWnd;
begin
  Panel:=APanel;
  Edit:=AEdit;

  c:=ptr(GetDlgItem(int(APanel), 1641));
  c.Width:=c.Width div 2;
  FLabel:=c;
  CalcSizes;

  Binded:=CheckBind;

  HandleNeeded;
  ParentWindow:=hwnd(Panel);
  windows.SetParent(Handle, hwnd(Panel));
  Left:=0;
  Top:=Edit.BoundsRect.Top-Edit1.Top;
  ReBind;
  if Binded then
  begin
    Edit1.Text:=FileName;
    OpenDialog1.FileName:=FileName;
  end else
    OpenDialog1.FileName:='';
  Show;
end;

procedure TForm2.Stop;
begin
  Close; //Hide;
  ParentWindow:=0;
  DestroyHandle;
end;

procedure TForm2.UpdateBinding(var a:TEventRec{; FileName:string});
var s,s1:string; p:PChar;
begin
  s:=a.Msg;
  if IsBound(s) and ParseBind(s) then
  try
    s:=RSStringReplace(RSLoadTextFile(FileName), #13, '');
    ParseNoBind(s);
    s1:=RSStringReplace(FileName, '!', '|');
    if RelativePath then
      s1:=ExtractRelativePath(AppPath+'Maps\', s1);
    s:=Signature[IsScript] + s1 +#9+ FileText;
    _free(a.Msg-1);
    p:=_malloc(length(s)+2);
    p^:=#0;
    inc(p);
    a.Msg:=p;
    a.MsgLength:= length(s);
    a.MsgBufLen:= length(s)+1;
    CopyMemory(p, ptr(s), length(s)+1);
  except
  end;
end;

procedure TForm2.UpdateBindings;
var a:PEventArr; i,j:int;
begin
  a:=EventsBlock;
  if a=nil then exit;
  j:=__msize(a) div SizeOf(TEventRec);
  for i:=0 to j-1 do
    UpdateBinding(a[i]);
end;

type
  TTracking = record
    Name: string;
    Time: Int64;
    Index: int;
  end;

const TrackingIntervel = 500;

var
  FTimerHandle:word;
  Tackings: array of TTracking;

procedure TForm2.TrackingProc;
var a:PEventArr; i,j:int; k:Int64; Changed:boolean;
begin
  self:=Form2;
  if MapProps.WasChanged<>0 then
  begin
    StopTracking;
    exit;
  end;
  if not IsWindowEnabled(hwnd(MainWindow)) then exit;
                                     // Don't save during dialogs

  a:=EventsBlock;
  if a=nil then exit;
  j:=length(Tackings);
  Changed:=false;
  for i:=0 to j-1 do
    with Tackings[i] do
    begin
      k:=MyGetFileTime(Name);
      if (k<>-1) and (k<>Time) then
      begin
        Changed:=true;
        UpdateBinding(a[Index]);
      end;
      Time:=k;
    end;

  if Changed then
    SendMessage(hwnd(MainWindow), WM_COMMAND, CmdSave or (1 shl 16), 0);
end;

procedure TForm2.StartTracking;
var a:PEventArr; i,j,k:int; s:string;
begin
  DoStopTracking;

  k:=0;
  Tackings:=nil;
  a:=EventsBlock;
  if a=nil then exit;
  j:=__msize(a) div SizeOf(TEventRec);
  for i:=0 to j-1 do
  begin
    s:=a[i].Msg;
    if IsBound(s) and ParseBind(s) then
    begin
      SetLength(Tackings, k+1);
      with Tackings[k] do
      begin
        Name:=FileName;
        Time:=MyGetFileTime(Name);
        Index:=i;
      end;
      inc(k);
    end;
  end;

  ShouldTrack:=true;
  if not FCanTrack then exit;

  if k<>0 then
    FTimerHandle := SetTimer(0, 0, TrackingIntervel, @TForm2.TrackingProc);
end;

procedure TForm2.DoStopTracking;
begin
  if FTimerHandle <> 0 then
  begin
    KillTimer(0, FTimerHandle);
    FTimerHandle := 0;
  end;
end;

procedure TForm2.StopTracking;
begin
  ShouldTrack:=false;
  DoStopTracking;
end;

procedure TForm2.UpdateTracking;
begin
  if FCanTrack and ShouldTrack then
  begin
    TrackingProc;
    StartTracking;
  end;
end;

procedure TForm2.SetCanTrack(v:boolean);
begin
  if v=FCanTrack then exit;
  FCanTrack:=v;
  if v then
    UpdateTracking
  else
    DoStopTracking;
  Label3.Caption:=Label3Text[v];
end;

procedure TForm2.OpenAllScripts;
var a:PEventArr; i,j:int; s, s1:string;
begin
  s1:='';
  a:=EventsBlock;
  if a=nil then exit;
  j:=__msize(a) div SizeOf(TEventRec);
  for i:=0 to j-1 do
  begin
    s:=a[i].Msg;
    if IsBound(s) and ParseBind(s) then
      s1:=s1+'"'+FileName+'" ';
  end;
  if s1='' then exit;
  MyShellExecute('"'+AppPath+'erm_s\ERM_S.EXE'+'"', s1);
end;

procedure TForm2.UnbindAll;
var a:PEventArr; i,j:int; s:string; p:PChar; was:boolean;
begin
  a:=EventsBlock;
  if a=nil then exit;
  was:=false;
  j:=__msize(a) div SizeOf(TEventRec);
  for i:=0 to j-1 do
  begin
    s:=a[i].Msg;
    if IsBound(s) and ParseBind(s) then
    begin
      if not was and (MessageBox(hwnd(MainWindow), ptr(SUnbindAllQuestion),
                     ZEditr[0], MB_YESNO or MB_ICONQUESTION)<>mrYes) then exit;
      was:=true;
      if FileExists(FileName) then
        s:=RSStringReplace(RSLoadTextFile(FileName), #13, '')
      else
        s:=FileText;
      _free(a[i].Msg-1);
      p:=_malloc(length(s)+2);
      p^:=#0;
      inc(p);
      a[i].Msg:=p;
      a[i].MsgLength:=length(s);
      a[i].MsgBufLen:=length(s)+1;
      CopyMemory(p, ptr(s), length(s)+1);
    end;
  end;
end;




{
  BindText: array[boolean] of string = ('Bind', 'Unbind');
  BindHint: array[boolean] of string = ('Bind to a script file', '');
  Label3Text: array[boolean] of string;
}

procedure TForm2.Initialize;
begin
  Application.CreateForm(TForm2, Form2);
  self:=Form2;
  HelpFile:=SHelpFile;
  DestroyHandle;
  with RSLanguage.AddSection('[Events Binding]', self) do
  begin
    AddItem('BindText', BindText[false]);
    AddItem('UnbindText', BindText[true]);
    AddItem('BindHint', BindHint[false]);
    AddItem('UnbindHint', BindHint[true]);
    AddItem('BoundAutorefresh', Label3Text[true]);
    AddItem('BoundNoAutorefresh', Label3Text[false]);
  end;
end;

procedure TForm2.LanguageLoaded(var Errors:string);
begin
  Label3.Caption:=Label3Text[FCanTrack];
end;

procedure TForm2.Label1Click(Sender: TObject);
var w:hwnd;
begin
  if not Binded then
  begin
    w:=GetDlgItem(hwnd(Panel), 1329);
    if (w<>0) and (OpenDialog1.FileName='') then
      OpenDialog1.FileName:=TRSWnd(w).Text;
    if not OpenDialog1.Execute then exit;
    if TRSWnd(w).Text='' then
    begin
      TRSWnd(w).Text:= ChangeFileExt(ExtractFileName(OpenDialog1.FileName),'');
      w:=GetDlgItem(hwnd(Panel), 1327);
      if TRSWnd(w).Text='1' then
        TRSWnd(w).Text:=FirstDay;
    end;
    ParseNoBind(Edit.Text);
  end;
  Binded:=not Binded;
  ReBind;
  if Binded then
    Edit1.Text:=OpenDialog1.FileName;
  UpdateEdit;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Label3Text[true]:= Label3.Caption;
  Label3Text[false]:= Label3NoAutorefresh.Caption;
  RSSpeedButton1.Glyph:= LoadPic;
    // !!! => Form2.Initialize должен быть после Form1.Initialize;
  Label1.ControlStyle:= Label1.ControlStyle - [csDoubleClicks];  
end;

procedure TForm2.RSSpeedButton1Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then exit;
  Edit1.Text:=OpenDialog1.FileName;
  UpdateEdit;
end;

procedure TForm2.RSSpeedButton2Click(Sender: TObject);
begin
  CheckCreate;
  MyShellExecute('"'+AppPath+'erm_s\ERM_S.EXE'+'"', '"'+Edit1.Text+'"');
//  MyShellExecute(Edit1.Text);
end;

end.
