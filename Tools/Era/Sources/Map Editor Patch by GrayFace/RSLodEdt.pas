unit RSLodEdt;

interface

uses
  SysUtils, Windows, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RSDef, ExtCtrls, RSSysUtils, RSQ, RSPanel, RSTrackBar,
  ComCtrls, RSUtils, RSTimer, Buttons, RSSpeedButton, RSLod, Themes, RSGraphics,
  CommCtrl, Menus, ImgList, RSTreeView, Math, Clipbrd, RSListView, RSMenus,
  RSDialogs, RSMemo, RSPopupMenu, RSLang, RSFileAssociation, RSComboBox,
  RSJvPcx, ShellAPI, Types, RSDefLod, MMSystem, RSRadPlay, IniFiles, RSRecent,
  RSQHelp1, dzlib, RSRegistry;

{
Version 1.0.1:
[-] MMArchive couldn't find palettes for variations of some sprites.
[-] After picking def type filter and opening archive without Def files no files were shown.

Version 1.0.2:
[-] Bitmaps import didn't work for many bitmaps (power of 4 check instead of power of 2)

Version 1.0.3:
[-] Double click on file resulted in an error
[-] Pressing any key while extension filter is focused triggered an exit

Version 1.0.4:
[-] MM Snd or Vid - compression doesn't work (see black phantom ICQ)
[-] File backups were only created for LOD acrhives
[-] Palettes weren't displayed for bitmaps.lod files
[*] Better handling of corrupt files in SND archives

!!! а для тайлов номер палитры в ммархиве не пишется

!!! Баги

 Black Phantom (01:11:15 20/11/2010)
Например, если я в Heroes3.snd добавлю файлы wav длиной 1 байт, то такой архив больше нельзя будет открыть mmarchive

 Black Phantom (01:11:36 20/11/2010)
если я добавлю файлы нулевой длины, архив вырастет в 10 раз!

 Black Phantom (01:11:46 20/11/2010)
нигде нет проверкин

 Black Phantom (01:11:49 20/11/2010)
на нулевой файл

 Black Phantom (01:11:57 20/11/2010)
следующая группа багов

 Black Phantom (01:12:41 20/11/2010)
если я запущу редактор карт или кампаний, а параллельно попытаюсь открыть lod - возникнет необработанное исключение (падение короче)

 Black Phantom (01:12:53 20/11/2010)
+ у меня на нетбуке был баг

 Black Phantom (01:13:16 20/11/2010)
нажатие кнопки добавить, если не выделен ни один файл приводило к диалогу об ошибке

 Black Phantom (01:13:24 20/11/2010)
текст не помню, но могу глянуть

 Black Phantom (01:13:40 20/11/2010)
вот такие дела



Black Phantom (00:13:05 24/10/2011) и далее


Optimize palette, choose color #0 in palette (from AutoLod)

LodCompare, LodMerge

перемещение цвета фона в правильное место при импорте в icons.lod
drag&drop из MMArchive во вне
Возможность выбора номера анимации дефа для показа
other file types
}

//var aDragging:Boolean;

type
  TRSLodEdit = class(TForm)
    OpenDialog1: TRSOpenSaveDialog;
    Panel2: TRSPanel;
    Panel3: TRSPanel;
    Panel1: TRSPanel;
    Image1: TImage;
    RSSpeedButton1: TRSSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ListView1: TRSListView;
    RSSpeedButton2: TRSSpeedButton;
    Timer1: TRSTimer;
    TreeView1: TRSTreeView;
    PopupMenu1: TRSPopupMenu;
    AddFolder1: TMenuItem;
    AddFile1: TMenuItem;
    ImageList1: TImageList;
    Rename1: TMenuItem;
    N1: TMenuItem;
    PopupMenu2: TRSPopupMenu;
    Extract1: TMenuItem;
    AddtoFavorites1: TMenuItem;
    ExtractTo1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    MergeFavorites1: TMenuItem;
    N2: TMenuItem;
    Delete1: TMenuItem;
    Copy1: TMenuItem;
    Panel4: TRSPanel;
    Panel5: TRSPanel;
    Button1: TButton;
    Button2: TButton;
    Select1: TMenuItem;
    OpenDialog2: TRSOpenSaveDialog;
    Timer2: TRSTimer;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    N3: TMenuItem;
    RecentFiles1: TMenuItem;
    N4: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Extract2: TMenuItem;
    ExtractTo2: TMenuItem;
    AddtoFavorites2: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Rebuild1: TMenuItem;
    N7: TMenuItem;
    Delete2: TMenuItem;
    SaveDialogExport: TSaveDialog;
    RSMemo1: TRSMemo;
    TrackBar1: TRSTrackBar;
    Add1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    Delete3: TMenuItem;
    Options1: TMenuItem;
    Help1: TMenuItem;
    TreeTimer1: TRSTimer;
    Associate1: TMenuItem;
    RSComboBox1: TRSComboBox;
    OpenDialogImport: TOpenDialog;
    N10: TMenuItem;
    SaveDialogNew: TSaveDialog;
    Associate3: TMenuItem;
    Associate2: TMenuItem;
    Sortbyextension1: TMenuItem;
    OpenDialogBitmapsLod: TOpenDialog;
    TmpRecent1: TMenuItem;
    Def1: TMenuItem;
    OriginalPalette1: TMenuItem;
    NormalPalette1: TMenuItem;
    TransparentBackground1: TMenuItem;
    N11: TMenuItem;
    Backup1: TMenuItem;
    Language1: TMenuItem;
    English1: TMenuItem;
    Label1: TLabel;
    Palette1: TMenuItem;
    Default1: TMenuItem;
    FirstKind1: TMenuItem;
    SecondKind1: TMenuItem;
    ThirdKind1: TMenuItem;
    IgnoreUnpackingErrors1: TMenuItem;
    N12: TMenuItem;
    ShowAll1: TMenuItem;
    Spells1: TMenuItem;
    ShowMapObjects1: TMenuItem;
    ShowHeroes1: TMenuItem;
    ShowTerrain1: TMenuItem;
    ShowCursors1: TMenuItem;
    ShowInterface1: TMenuItem;
    ShowCombatHeroes1: TMenuItem;
    ShowCreatures1: TMenuItem;
    MergeWith1: TMenuItem;
    procedure MergeWith1Click(Sender: TObject);
    procedure RSComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RSComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ShowCombatHeroes1Click(Sender: TObject);
    procedure ShowInterface1Click(Sender: TObject);
    procedure ShowCursors1Click(Sender: TObject);
    procedure ShowTerrain1Click(Sender: TObject);
    procedure ShowHeroes1Click(Sender: TObject);
    procedure ShowCreatures1Click(Sender: TObject);
    procedure ShowMapObjects1Click(Sender: TObject);
    procedure Spells1Click(Sender: TObject);
    procedure ShowAll1Click(Sender: TObject);
    procedure IgnoreUnpackingErrors1Click(Sender: TObject);
    procedure Default1Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure Language1Click(Sender: TObject);
    procedure English1Click(Sender: TObject);
    procedure Backup1Click(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure Sortbyextension1Click(Sender: TObject);
    procedure Rebuild1Click(Sender: TObject);
    procedure Associate3Click(Sender: TObject);
    procedure Associate2Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Add1Click(Sender: TObject);
    procedure RSComboBox1Select(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Associate1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure ListView1Editing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure RSSpeedButton1Click(Sender: TObject);
    procedure RSSpeedButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure TreeView1Collapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure TreeView1Editing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure TreeView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure AddFolder1Click(Sender: TObject);
    procedure AddFile1Click(Sender: TObject);
    procedure TreeView1Edited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure TreeView1CancelEdit(Sender: TObject; Node: TTreeNode);
    procedure Delete1Click(Sender: TObject);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Rename1Click(Sender: TObject);
    procedure TreeView1KeyPress(Sender: TObject; var Key: Char);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure TreeView1Compare(Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer);
    procedure AddtoFavorites1Click(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure ListView1CreateItemClass(Sender: TCustomListView;
      var ItemClass: TListItemClass);
    procedure TreeView1CreateNodeClass(Sender: TCustomTreeView;
      var NodeClass: TTreeNodeClass);
    procedure Button1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MergeFavorites1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure RSSpeedButton3Click(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure Open1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure ListView1DataFind(Sender: TObject; Find: TItemFind;
      const FindString: String; const FindPosition: TPoint;
      FindData: Pointer; StartIndex: Integer; Direction: TSearchDirection;
      Wrap: Boolean; var Index: Integer);
    procedure Delete2Click(Sender: TObject);
    procedure Extract1Click(Sender: TObject);
    procedure ExtractTo1Click(Sender: TObject);
    procedure Panel1Paint(Sender: TRSCustomControl; State: TRSControlState;
      DefaultPaint: TRSProcedure);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure TrackBar1AdjustClickRect(Sender: TRSTrackBar; var r: TRect);
    procedure ListView1WndProc(Sender: TObject; var Msg: TMessage;
      var Handled: Boolean; const NextWndProc: TWndMethod);
    procedure Exit1Click(Sender: TObject);
    procedure TreeTimer1Timer(Sender: TObject);
    procedure TreeView1EndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PopupMenu1AfterPopup(Sender: TObject);
    procedure DefaultPalette1Click(Sender: TObject);
  private
    FLanguage: string;
    FDefFilter: int;
    FAppCaption: string;
    procedure SetAppCaption(const v: string);
    procedure SetLanguage(const v: string);
    procedure SetDefFilter(v: int);
  protected
    FLightLoad: boolean;
    FEditing: Boolean;
    Recent: TRSRecent;
    ItemIndexes: array of int;
    ItemCaptions: array of string;
    ArchiveIndexes: array of int;
    LastSel: int;
    Toolbar: TRSControlArray;
    FirstActivate: Boolean;
    FileBuffer: TRSByteArray;
    FileBitmap: TBitmap;
    PalFixList: TStringList;
    VideoPlayer: TRSRADPlayer;
    VideoStream: TStream;
    VideoPlayers: array[0..2] of TRSRADPlayer;
    FileTime: int64;
    LastPalString: string;
    FSFT: TMemoryStream;
    FSFTNotFound: Boolean;
    FSFTKind: int;
    FSFTLod: TRSLod;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMActivate(var Msg:TWMActivate); message WM_Activate;
    procedure WMSysCommand(var Msg:TWMSysCommand); message WM_SysCommand;
    procedure WMThemeChanged(var Msg:TMessage); message WM_ThemeChanged;
    procedure WMDropFiles(var m: TWMDropFiles); message WM_DropFiles;
    procedure PreparePal(Sender: TRSDefWrapper; Pal:PLogPal);
    procedure ReStretch(w:int=-1; h:int=-1);
    function SelCaption:string;
    procedure ThemeChanged;
    procedure MenuShortCut(Item: TMenuItem; var Result:string);
    procedure UpdateToolbarState;
    procedure UpdateRecent;
    procedure RecentClick(Sender:TRSRecent; FileName:string);
    function DialogToFolder(dlg: TOpenDialog): string;
    function DefFilterProc(Sender: TRSLodEdit; i: int; var Str: string): Boolean;

    procedure LoadIni;
    procedure SaveIni;

    function AddTreeNode(s:string; Image:integer; EditName:boolean; Select:boolean=true):TTreeNode;
    procedure DoLoadTree(const a:TRSByteArray; Node:TTreeNode=nil);
    function SaveNodes(Nodes:array of TTreeNode):TRSByteArray;
    function GetTreePath(FileName:string):string;
    procedure LoadTree(FileName:string);
    procedure SaveTree(FileName:string);

    procedure PrepareLoad;
    function BeginLoad(FileName, Filter:string):boolean;
    procedure EndLoad;
    procedure ExtQSort(L, R: int);
    procedure ExtSort;

    procedure CreateArchive(FileName: string);
    function ArchiveFileName: string;
    procedure DoExtract(Choose:boolean);
    procedure DoAdd(Files:TStrings);
    procedure LoadFile(Index: int);
    procedure NeedBitmapsLod(Sender: TObject);
    procedure NeedPalette(Sender: TRSLod; Bitmap: TBitmap; var Palette: int);
    procedure SpritePaletteFixup(Sender: TRSLod; Name: string; var pal: int2; var Data);
    procedure FindSpritePal(name: string; var pal: int2; Kind: int = 1);
    procedure PlayVideo;
    procedure FreeVideo;
    property Language: string read FLanguage write SetLanguage;
    property DefFilter: int read FDefFilter write SetDefFilter;
  public
    Favorites: string;
    ExtractPath: string;
    EmulatePopupShortCuts: boolean;
    Archive: TRSMMArchive;
    SpecFilter: function(Sender:TRSLodEdit; Index:int; var Str:string):boolean of object;
    ShowOneGroup: Boolean;
    function LoadShowModal(Filter, DefSel:string; FileName:string=''):TModalResult;
    procedure Load(FileName:string);
    procedure Initialize(Editing:boolean=false; UseRSMenus:boolean=true);
    property AppCaption: string read FAppCaption write SetAppCaption;
  end;

var
  RSLodEdit: TRSLodEdit;
  RSLodResult: string;

implementation

uses Registry;

{$R *.dfm}

type
  TMyFileType = (aNone, aDef, aBmp, aTxt, aMsk, aWav, aVideo, aPal, aPcx);

const
  AnimTime = 80;
  AnyExt = '*.*';
  LangDir = 'Language\';

var
  FilterExt: string = AnyExt; DefaultSel:string;
  SelectingIndex:pint; LastSelIndex:int;
  TreeDeleteNeedeed:boolean=true; CanSelectListView:boolean=true;
  DragNode:TTreeNode; DragPoint:TPoint=(x:MaxInt);
  ClipboardFormat:DWord; ClipboardBackup:TRSByteArray;
  Association1, Association2, Association3: TRSFileAssociation;
  VideoPrepared: Boolean;
  DefColumnWidth: int = -1;

var
  Errors:array of Boolean; TrackBarChanging:boolean; Def:TRSDefWrapper;
  LastBmp:int;
  FileType: TMyFileType;

var
  EnterReaderModeHelper: function(Wnd: HWND): BOOL; stdcall;
  
var
  SDeleteQuestion: string = 'Are you sure you want to delete the file "%s" from archive?';
  SDeleteManyQuestion: string = 'Are you sure you want to delete the selected files from archive?';
  SNewFolder: string = 'New Folder';
  SExtractAs: string = 'Extract As...';
  SExtractTo: string;
  SEPaletteNotFound: string = 'Failed to find matching palette in bitmaps.lod';
  SEPaletteMustExist: string = 'Image must be in 256 colors mode and palette must be added to bitmaps.lod';
  SPalette: string = 'Palette: %d';
  SPaletteChanged: string = 'Palette: %d (shown: %d)';

type
  PPalFix = ^TPalFix;
  TPalFix = record
    Name: string;
    Pal: int;
    Data: string;
  end;

const
  PalFix: array[1..53] of TPalFix = (
    (Name: 'BATATA0'; Pal: 156; Data: #211#26#0#0#226#0#226#0#166#1#0#0#60#0#255#255#75#101#0#0),
    (Name: 'BATATB0'; Pal: 156; Data: #188#37#0#0#254#0#17#1#166#1#0#0#0#0#255#255#218#113#0#0),
    (Name: 'BATATC0'; Pal: 156; Data: #75#51#0#0#62#1#44#1#166#1#0#0#1#0#255#255#169#148#0#0),
    (Name: 'BATATD0'; Pal: 156; Data: #212#50#0#0#23#1#29#1#166#1#0#0#1#0#255#255#209#145#0#0),
    (Name: 'BATATE0'; Pal: 156; Data: #167#27#0#0#114#1#176#0#166#1#0#0#1#0#255#255#236#107#0#0),
    (Name: 'BATATF0'; Pal: 156; Data: #225#22#0#0#114#1#85#0#166#1#0#0#1#0#255#255#41#55#0#0),
    (Name: 'BATDEA0'; Pal: 156; Data: #173#74#0#0#202#0#200#0#166#1#0#0#0#0#255#255#101#103#0#0),
    (Name: 'BATDEB0'; Pal: 156; Data: #34#47#0#0#13#1#119#0#166#1#0#0#0#0#255#255#155#64#0#0),
    (Name: 'BATDEC0'; Pal: 156; Data: #179#54#0#0#40#1#152#0#166#1#0#0#1#0#255#255#83#94#0#0),
    (Name: 'BATDED0'; Pal: 156; Data: #29#70#0#0#3#1#219#0#166#1#0#0#35#0#255#255#40#95#0#0),
    (Name: 'BATDEE0'; Pal: 156; Data: #219#28#0#0#197#0#110#0#166#1#0#0#7#0#255#255#155#33#0#0),
    (Name: 'BATDEF0'; Pal: 156; Data: #73#19#0#0#201#0#100#0#166#1#0#0#1#0#255#255#215#25#0#0),
    (Name: 'BATWAA0'; Pal: 156; Data: #40#25#0#0#45#1#228#0#166#1#0#0#69#0#255#255#202#91#0#0),
    (Name: 'BATWAA1'; Pal: 156; Data: #207#61#0#0#60#1#12#1#166#1#0#0#91#0#255#255#137#98#0#0),
    (Name: 'BATWAA2'; Pal: 156; Data: #69#53#0#0#184#0#22#1#166#1#0#0#93#0#255#255#68#69#0#0),
    (Name: 'BATWAA3'; Pal: 156; Data: #80#53#0#0#18#1#6#1#166#1#0#0#77#0#255#255#246#102#0#0),
    (Name: 'BATWAA4'; Pal: 156; Data: #28#22#0#0#84#1#234#0#166#1#0#0#54#0#255#255#247#105#0#0),
    (Name: 'BATWAB0'; Pal: 156; Data: #19#26#0#0#45#1#228#0#166#1#0#0#67#0#255#255#56#79#0#0),
    (Name: 'BATWAB1'; Pal: 156; Data: #91#53#0#0#60#1#12#1#166#1#0#0#90#0#255#255#251#87#0#0),
    (Name: 'BATWAB2'; Pal: 156; Data: #85#49#0#0#184#0#22#1#166#1#0#0#92#0#255#255#100#60#0#0),
    (Name: 'BATWAB3'; Pal: 156; Data: #181#58#0#0#18#1#6#1#166#1#0#0#76#0#255#255#149#97#0#0),
    (Name: 'BATWAB4'; Pal: 156; Data: #43#24#0#0#84#1#234#0#166#1#0#0#53#0#255#255#123#96#0#0),
    (Name: 'BATWAC0'; Pal: 156; Data: #104#21#0#0#45#1#228#0#166#1#0#0#68#0#255#255#25#71#0#0),
    (Name: 'BATWAC1'; Pal: 156; Data: #48#39#0#0#60#1#12#1#166#1#0#0#90#0#255#255#71#75#0#0),
    (Name: 'BATWAC2'; Pal: 156; Data: #52#39#0#0#184#0#22#1#166#1#0#0#93#0#255#255#143#47#0#0),
    (Name: 'BATWAC3'; Pal: 156; Data: #176#46#0#0#18#1#6#1#166#1#0#0#76#0#255#255#109#82#0#0),
    (Name: 'BATWAC4'; Pal: 156; Data: #72#22#0#0#84#1#234#0#166#1#0#0#53#0#255#255#168#89#0#0),
    (Name: 'BATWAD0'; Pal: 156; Data: #51#21#0#0#45#1#228#0#166#1#0#0#35#0#255#255#108#76#0#0),
    (Name: 'BATWAD1'; Pal: 156; Data: #250#40#0#0#60#1#12#1#166#1#0#0#47#0#255#255#48#71#0#0),
    (Name: 'BATWAD2'; Pal: 156; Data: #207#30#0#0#184#0#22#1#166#1#0#0#45#0#255#255#132#38#0#0),
    (Name: 'BATWAD3'; Pal: 156; Data: #98#33#0#0#18#1#6#1#166#1#0#0#34#0#255#255#186#69#0#0),
    (Name: 'BATWAD4'; Pal: 156; Data: #223#24#0#0#84#1#234#0#166#1#0#0#20#0#255#255#74#91#0#0),
    (Name: 'BATWAE0'; Pal: 156; Data: #237#48#0#0#45#1#228#0#166#1#0#0#56#0#255#255#239#76#0#0),
    (Name: 'BATWAE1'; Pal: 156; Data: #240#46#0#0#60#1#12#1#166#1#0#0#78#0#255#255#96#69#0#0),
    (Name: 'BATWAE2'; Pal: 156; Data: #213#20#0#0#184#0#22#1#166#1#0#0#80#0#255#255#137#25#0#0),
    (Name: 'BATWAE3'; Pal: 156; Data: #181#39#0#0#18#1#6#1#166#1#0#0#64#0#255#255#8#62#0#0),
    (Name: 'BATWAE4'; Pal: 156; Data: #235#55#0#0#84#1#234#0#166#1#0#0#40#0#255#255#189#89#0#0),
    (Name: 'BATWAF0'; Pal: 156; Data: #182#27#0#0#45#1#228#0#166#1#0#0#61#0#255#255#18#61#0#0),
    (Name: 'BATWAF1'; Pal: 156; Data: #139#43#0#0#60#1#12#1#166#1#0#0#83#0#255#255#167#65#0#0),
    (Name: 'BATWAF2'; Pal: 156; Data: #142#40#0#0#184#0#22#1#166#1#0#0#85#0#255#255#18#50#0#0),
    (Name: 'BATWAF3'; Pal: 156; Data: #162#43#0#0#18#1#6#1#166#1#0#0#69#0#255#255#92#62#0#0),
    (Name: 'BATWAF4'; Pal: 156; Data: #63#34#0#0#84#1#234#0#166#1#0#0#45#0#255#255#82#73#0#0),
    (Name: 'BATWIA0'; Pal: 156; Data: #130#23#0#0#223#0#205#0#166#1#0#0#47#0#255#255#240#89#0#0),
    (Name: 'BATWIB0'; Pal: 156; Data: #225#95#0#0#78#1#180#0#166#1#0#0#1#0#255#255#16#142#0#0),
    (Name: 'BATWIC0'; Pal: 156; Data: #231#108#0#0#56#1#208#0#166#1#0#0#1#0#255#255#134#161#0#0),
    (Name: 'BATWID0'; Pal: 156; Data: #157#101#0#0#82#1#217#0#166#1#0#0#2#0#255#255#13#151#0#0),
    (Name: 'BATWIE0'; Pal: 156; Data: #70#45#0#0#61#1#155#0#166#1#0#0#1#0#255#255#146#72#0#0),
    (Name: 'BATWIF0'; Pal: 156; Data: #130#28#0#0#193#0#251#0#166#1#0#0#1#0#255#255#238#61#0#0),
    (Name: 'swptree1'; Pal: 120; Data: #217#34#0#0#112#0#211#0#172#3#0#0#0#0#18#0#203#50#0#0),
    (Name: 'swptree2'; Pal: 120; Data: #184#71#0#0#136#0#73#1#172#3#0#0#0#0#18#0#220#105#0#0),
    (Name: 'swptree3'; Pal: 120; Data: #98#76#0#0#210#0#193#0#172#3#0#0#0#0#18#0#137#122#0#0),
    (Name: 'swptree4'; Pal: 120; Data: #30#68#0#0#25#1#71#1#172#3#0#0#0#0#18#0#163#213#0#0),
    ()
  );


type
    // Hiddens partly implemented
  TMyTreeNode = class(TTreeNode)
  private
    FHiddenItems: array of TMyTreeNode;
    function GetItem(Index: Integer): TTreeNode;
    function GetFullCount:int;
    procedure SetItem(Index: Integer; Value: TTreeNode);
  public
    Hidden:boolean;
    FileName:string;
    Param2:string;
    destructor Destroy; override;
    function AddHiddenItem(s:string):TMyTreeNode; overload;
    function AddHiddenItem(it:TMyTreeNode):TMyTreeNode; overload;
    procedure MoveChildren(Target:TMyTreeNode);
    procedure DeleteChildren;
    property Item[Index: Integer]: TTreeNode read GetItem write SetItem; default;
    property FullCount:int read GetFullCount;
  end;
  TMyNode = TMyTreeNode;

destructor TMyTreeNode.Destroy;
var i:int;
begin
  for i:= length(FHiddenItems)-1 downto 0 do
    FHiddenItems[i].Free;
  inherited Destroy;
end;

procedure TMyTreeNode.DeleteChildren;
var i:int;
begin
  inherited DeleteChildren;
  for i:= length(FHiddenItems)-1 downto 0 do
    FHiddenItems[i].Free;
  FHiddenItems:= nil;
end;

function TMyTreeNode.GetItem(Index: Integer): TTreeNode;
var i:int;
begin
  i:=Count;
  if Index>=i then
  begin
    dec(Index, i);
    Result:=FHiddenItems[Index];
  end else
    Result:=inherited Item[Index];
end;

procedure TMyTreeNode.SetItem(Index: Integer; Value: TTreeNode);
begin
  inherited Item[Index]:=Value;
end;

function TMyTreeNode.GetFullCount:int;
begin
  Result:=Count+length(FHiddenItems);
end;

function TMyTreeNode.AddHiddenItem(s:string):TMyTreeNode;
begin
  Result:=AddHiddenItem(TMyTreeNode.Create(Owner));
  Result.Text:=s;
end;

function TMyTreeNode.AddHiddenItem(it:TMyTreeNode):TMyTreeNode;
var i:int;
begin
  i:=length(FHiddenItems);
  SetLength(FHiddenItems, i+1);
  FHiddenItems[i]:=it;
  Result:=it;
  it.Hidden:=true;
end;

procedure TMyTreeNode.MoveChildren(Target:TMyTreeNode);
var i:int;
begin
  for i:=Count-1 downto 0 do
    Item[i].MoveTo(Target, naAddChildFirst);
  for i:=0 to length(FHiddenItems)-1 do
    Target.AddHiddenItem(FHiddenItems[i]);
end;




procedure LoadBmp(i:integer; Bitmap:TBitmap);
begin
  if FileType<>aDef then exit;
  LastBmp:=i;
  if (length(Errors)>i) and not Errors[i] then
    try
{      if RSLodEdit.ShowOneGroup and (length(Def.Groups)>2) then
        Def.ExtractBmp(2, i, Bitmap, RSFullBmp)
      else
}
        Def.ExtractBmp(i, Bitmap, RSFullBmp);
    except
      on e:Exception do
      begin
        Errors[i]:=true;
        RSErrorHint(RSLodEdit.TrackBar1, e.Message, MaxInt);
      end;
    end
  else
    Bitmap.Assign(nil);
end;

procedure DoReStretch(Image:TImage; Stretch:boolean; w,h,w1,h1:int);
begin
  {
  //w1:=Image.Picture.Width;
  //h1:=Image.Picture.Height;
  //Stretch:= Stretch or (w1>w) or (h1>h);
  Image.Stretch:= Stretch;
  //Image.Proportional:= Stretch;
  }
  if (w1=0) or (h1=0) then
  begin
    Image.Width:=1;
    Image.Height:=1;
    exit;
  end;
  if Stretch or (w1>w) or (h1>h) then
    if w1*h>w*h1 then
      h:=(w*h1 + w1 div 2) div w1
    else
      w:=(h*w1 + h1 div 2) div h1
  else
  begin
    w:=w1;
    h:=h1;
  end;
  if w=0 then w:=1;
  if h=0 then h:=1;
  if Image.Width<>w then Image.Width:=w;
  if Image.Height<>h then Image.Height:=h;
end;

function MyGetFileTime(const name: string): int64;
var
  d: TWin32FindData;
  h: THandle;
begin
  Result:= 0;
  if zSet(h, FindFirstFile(ptr(name), d)) <> INVALID_HANDLE_VALUE then
    try
      Result:= int64(d.ftLastWriteTime);
    finally
      FindClose(h);
    end;
end;

procedure TRSLodEdit.WMActivate(var Msg:TWMActivate);
var
  t: int64;
begin
  inherited;
  Timer1.Enabled:= (Msg.Active<>WA_INACTIVE) and not Msg.Minimized;
  Timer2.Enabled:= false;
  if (VideoPlayer <> nil) and (Timer1.Interval <> 0) then
    VideoPlayer.Pause:= not Timer1.Enabled;

  if FirstActivate then
  begin
    RSSetFocus(ListView1);
    ListView_EnsureVisible(ListView1.Handle, LastSel, false);
    FirstActivate:= false;
  end;
  if Archive <> nil then
  begin
    t:= MyGetFileTime(Archive.RawFiles.FileName);
    if (Msg.Active <> WA_INACTIVE) and (FileTime <> 0) and (FileTime <> t) then
    begin
      if ListView1.Selected<>nil then
        DefaultSel:= SelCaption;
      CreateArchive(Archive.RawFiles.FileName);
      EndLoad;
    end;
    FileTime:= t;
  end;
end;

procedure TRSLodEdit.WMDropFiles(var m: TWMDropFiles);
var
  i,n: int;
  s: string;
  sl: TStringList;
begin
  if not FEditing or (Archive = nil) then
    exit;
  sl:= TStringList.Create;
  try
    m.Result:= 0;
    n:= DragQueryFile(m.Drop, $FFFFFFFF, nil, 0);
    try
      for i := 0 to n - 1 do
      begin
        SetLength(s, DragQueryFile(m.Drop, i, nil, 0));
        if (s<>'') and (int(DragQueryFile(m.Drop, i, ptr(s), length(s)+1)) = length(s)) then
          sl.Add(s);
      end;
    finally
      DragFinish(m.Drop);
    end;
    DoAdd(sl);

  finally
    sl.Free;
  end;
end;

{
procedure TRSLodEdit.WMClose(var Msg:TWMClose);
begin
  Closing:=true;
  inherited;
end;
}

procedure TRSLodEdit.WMSysCommand(var Msg:TWMSysCommand);
begin
  if Msg.CmdType=SC_MINIMIZE then
  begin
    Msg.Result:=0;
    Application.Minimize;
  end else inherited;
end;

procedure TRSLodEdit.WMThemeChanged(var Msg:TMessage);
begin
  inherited;
  ThemeChanged;
end;

procedure TRSLodEdit.Backup1Click(Sender: TObject);
begin
  Backup1.Checked:= not Backup1.Checked;
  if Archive <> nil then
    Archive.BackupOnAdd:= Backup1.Checked;
end;

function TRSLodEdit.BeginLoad(FileName, Filter:string):boolean;
begin
  //s:=Lod.LodFileName;
  Result:=true;
  PrepareLoad;
  if (Archive <> nil) and (Archive.RawFiles.FileName = FileName) then
  begin
    FLightLoad:= Filter = FilterExt;
    exit;
  end else
    FLightLoad:=false;
  CreateArchive(FileName);
  OpenDialog1.FileName:= FileName;
end;

procedure TRSLodEdit.EndLoad;

  function FindDefs: Boolean;
  var
    i: int;
  begin
    Result:= true;
    with Archive.RawFiles do
      for i:=0 to Count-1 do
        if SameText(ExtractFileExt(Name[i]), '.def') then
          exit;
    Result:= false;
  end;

const
  ColPadding = 28;
var
  i, j, ColW: int;
  s, s1: string;
  sl: TStringList;
begin
  Def1.Visible:= (Archive is TRSLod) and (TRSLod(Archive).Version = RSLodHeroes) and FindDefs;
  if DefFilter <> 0 then
    if Def1.Visible then
      SpecFilter:= DefFilterProc
    else
      SpecFilter:= nil;

  Add1.Enabled:=true;
  TreeView1.Enabled:=true;

  try
    TMyNode(TreeView1.Items[0]).DeleteChildren;
  except
  end;
  LoadTree(ArchiveFileName);

  if not FLightLoad then
  begin
    sl:= TStringList.Create;
    with Archive do
    try
      Timer1.Interval:=0;
      Timer2.Enabled:=false;

      sl.Sorted:= true;
      sl.Duplicates:= dupIgnore;
      Image1.Picture.Bitmap:=nil;
      TrackBar1.Hide;
      RSSpeedButton1.Hide;
      RSSpeedButton2.Hide;
      ListView1.Items.Clear;
      ItemCaptions:=nil;
      SetLength(ItemCaptions, RawFiles.Count);
      ItemIndexes:=nil;
      SetLength(ItemIndexes, RawFiles.Count);
      SetLength(ArchiveIndexes, RawFiles.Count);

      if DefColumnWidth < 0 then
        DefColumnWidth:= ListView_GetColumnWidth(ListView1.Handle, 0);
      ColW:= DefColumnWidth;
      j:=0;
      for i:=0 to RawFiles.Count-1 do
      begin
        s:= RawFiles.Name[i];
        s1:= ExtractFileExt(s);
        sl.Add(LowerCase(s1));
        if (FilterExt <> AnyExt) and not SameText(s1, FilterExt) or
           (@SpecFilter <> nil) and not SpecFilter(self, i, s) then
        begin
          ArchiveIndexes[i]:=-1
        end else
        begin
          ItemCaptions[j]:=s;
          ItemIndexes[j]:=i;
          ArchiveIndexes[i]:=j;
          inc(j);
          ColW:= max(ColW, ListView_GetStringWidth(ListView1.Handle, ptr(s)) + ColPadding);
        end;
      end;
      ListView_SetColumnWidth(ListView1.Handle, 0, ColW);

      SetLength(ItemCaptions, j);
      SetLength(ItemIndexes, j);

      ListView1.Items.Count:=j;
      j:= sl.Add(AnyExt);
      if (FilterExt <> AnyExt) and not sl.Find(FilterExt, j) then
        j:= -1;

      if Sortbyextension1.Checked then
        ExtSort;

      RSComboBox1.Items:= sl;
      RSComboBox1.ItemIndex:= j
    finally
      sl.Free;
    end;
  end;


(*
      try
        Timer1.Interval:=0;
        Timer2.Enabled:=false;

        Image1.Picture.Bitmap:=nil;
        TrackBar1.Hide;
        RSSpeedButton2.Hide;
        RSSpeedButton3.Hide;
        ProgressBar1.Show;
        ProgressBar1.Position:=0;
        ProgressBar1.Max:=Lod.Count;
        Clear;
        for i:=0 to Lod.Count-1 do
        begin
          s:=GetFileName(i);
          if (FilterExt<>'') and not SameText(ExtractFileExt(s), FilterExt) or
             (@SpecFilter<>nil) and not SpecFilter(self, i, s) then

            PInt(Lod.UserData[i])^:=-1
          else
            with Add do
            begin
              Data:=ptr(i);
              Caption:=s;
              PInt(Lod.UserData[i])^:=Index;
            end;
  {          with it do
            begin
              mask:=LVIF_TEXT;
              iItem:=0;
              iSubItem:=0;
              state:=0;
              stateMask:=uint(-1);
              pszText:=ptr(s);
              ListView_InsertItem(ListView1.Handle, it);
              //Lod.FFilesStruct[i].Unk:=Index;
            end }
          if i mod 64 = 0 then
          begin
            ProgressBar1.Position:=i;
            Application.ProcessMessages;
            if Closing then exit;
          end;
        end;

        BeginUpdate;

            Add.Index:=i;
            ListView1.Items.Count:=5;
      finally
        ProgressBar1.Hide;
        if Closing then
        begin
          Lod.LodFileName:='';
          Clear;
        end;
        EndUpdate;
      end;
*)

  if (DefaultSel <> '') and Archive.RawFiles.FindFile(DefaultSel, i) then
  begin
    i:= ArchiveIndexes[i];
    if i>=0 then
    begin
      ListView_SetItemState(ListView1.Handle, i, LVIS_SELECTED or LVIS_FOCUSED,
                                              LVIS_SELECTED or LVIS_FOCUSED);
      ListView_EnsureVisible(ListView1.Handle, i, false);
    end;
  end;
  FirstActivate:= true;
end;

procedure TRSLodEdit.English1Click(Sender: TObject);
begin
  with TMenuItem(Sender) do
    if not Checked then
      Language:= StripHotkey(Caption);
end;

function TRSLodEdit.LoadShowModal(Filter, DefSel:string;
  FileName:string=''):TModalResult;
begin
  Result:=mrCancel;
  if FileName<>'' then
    OpenDialog1.FileName:= FileName
  else
    if not OpenDialog1.Execute then  exit;

  if not BeginLoad(OpenDialog1.FileName, Filter) then exit;
  FilterExt:=Filter;
  DefaultSel:=DefSel;
  EndLoad;
  Result:=ShowModal;
  DestroyHandle;
//  Closing:=false;
end;

procedure TRSLodEdit.Load(FileName:string);
begin
  if (FileName<>'') and BeginLoad(FileName, AnyExt) then
  begin
    FilterExt:= AnyExt;
    EndLoad;
  end;
end;

function TRSLodEdit.SelCaption:string;
begin
  Result:= Archive.RawFiles.Name[ItemIndexes[LastSel]];
end;

procedure TRSLodEdit.SetAppCaption(const v: string);
begin
  FAppCaption:= v;
  Caption:= ExtractFileName(ArchiveFileName);
  if AppCaption <> '' then
    if Caption <> '' then
      Caption:= Caption + ' - ' + AppCaption
    else
      Caption:= AppCaption;
  if FEditing then
    Application.Title:= Caption;
end;

procedure TRSLodEdit.SetDefFilter(v: int);
begin
  if v = FDefFilter then  exit;
  FDefFilter:= v;
  if v = 0 then
    SpecFilter:= nil
  else
    SpecFilter:= DefFilterProc;
  if ListView1.Selected<>nil then
    DefaultSel:= SelCaption;
  if Archive <> nil then
    EndLoad;
end;

procedure TRSLodEdit.SetLanguage(const v: string);
var
  s: string;
  i: int;
begin
  s:= AppPath + LangDir + v + '.txt';
  if not FileExists(s) then
  begin
    if SameText(FLanguage, 'English') then  exit;
    FLanguage:= 'English';
    s:= AppPath + LangDir + 'English.txt';
  end else
    FLanguage:= v;
  RSLanguage.LoadLanguage(RSLanguage.LanguageBackup, true);
  try
    RSLanguage.LoadLanguage(RSLoadTextFile(s), true);
  except
  end;

  for i := 0 to length(Toolbar) - 1 do
    if Toolbar[i] is TRSSpeedButton then
      with TRSSpeedButton(Toolbar[i]) do
        Hint:= StripHotkey(TMenuItem(Tag).Caption);

  UpdateToolbarState;
end;

procedure TRSLodEdit.ShowAll1Click(Sender: TObject);
begin
  DefFilter:= 0;
end;

procedure TRSLodEdit.ShowCombatHeroes1Click(Sender: TObject);
begin
  DefFilter:= $49;
end;

procedure TRSLodEdit.ShowCreatures1Click(Sender: TObject);
begin
  DefFilter:= $42;
end;

procedure TRSLodEdit.ShowCursors1Click(Sender: TObject);
begin
  DefFilter:= $46;
end;

procedure TRSLodEdit.ShowHeroes1Click(Sender: TObject);
begin
  DefFilter:= $44;
end;

procedure TRSLodEdit.ShowInterface1Click(Sender: TObject);
begin
  DefFilter:= $47;
end;

procedure TRSLodEdit.ShowMapObjects1Click(Sender: TObject);
begin
  DefFilter:= $43;
end;

procedure TRSLodEdit.ShowTerrain1Click(Sender: TObject);
begin
  DefFilter:= $45;
end;

procedure TRSLodEdit.Sortbyextension1Click(Sender: TObject);
begin
  Sortbyextension1.Checked:= not Sortbyextension1.Checked;
  TRSSpeedButton(Sortbyextension1.Tag).Down:= Sortbyextension1.Checked;
  if ListView1.Selected<>nil then
    DefaultSel:= SelCaption;
  if Archive <> nil then
    EndLoad;
end;

procedure TRSLodEdit.Spells1Click(Sender: TObject);
begin
  DefFilter:= $40;
end;

procedure TRSLodEdit.SpritePaletteFixup(Sender: TRSLod; Name: string;
  var pal: int2; var Data);
var
  a: PPalFix;
  i: int;
  last: int2;
begin
  last:= pal;
  if PalFixList.Find(Name, i) then
  begin
    a:= PPalFix(PalFixList.Objects[i]);
    if CompareMem(@Data, ptr(a.Data), length(a.Data)) then
      pal:= a.Pal;
  end;
  if FSFTKind > 0 then
    FindSpritePal(Name, pal, FSFTKind);
  if pal <> last then
    LastPalString:= Format(SPaletteChanged, [last, pal])
  else
    LastPalString:= Format(SPalette, [last]);
end;

procedure TRSLodEdit.LoadFile(Index: int);
var
  ft: TMyFileType;
  s: string;
  a: TStream;
  WasPlayed: Boolean;
  j: int;
begin
  ft:= aNone;
  if Archive is TRSLod then
    with TRSLod(Archive) do
    begin
      s:= LowerCase(ExtractFileExt(Archive.Names[ItemIndexes[Index]]));
      if Version = RSLodHeroes then
      begin
        if s = '.def' then
          ft:= aDef
        else if s = '.pcx' then
          ft:= aBmp
        else if s = '.txt' then
          ft:= aTxt
        //else if (s = '.msk') or (s = '.msg') then
        //  ft:= aMsk;
      end
      else if Version = RSLodSprites then
        ft:= aBmp
      else if (s = '.txt') or (s = '.str') then
        ft:= aTxt
      else if s = '.pcx' then
        ft:= aPcx
      else if s = '.wav' then
        ft:= aWav
      else if (s = '') and (Version in [RSLodBitmaps, RSLodIcons, RSLodMM8]) then
        ft:= aBmp;
    end
  else if Archive is TRSSnd then
    ft:= aWav
  else if Archive is TRSVid then
    ft:= aVideo
  else
    Assert(false);

  if FileType = aWav then
    sndPlaySound(nil, SND_ASYNC or SND_MEMORY or SND_NODEFAULT);
  FreeAndNil(FileBitmap);
  WasPlayed:= VideoPlayer <> nil;
  FreeVideo;
  FileBuffer:= nil;
  LastPalString:= '';
  if (ft <> aNone) and (ft <> aVideo) then
  begin
    Index:= ItemIndexes[Index];
    a:= nil;
    try
      if ft = aPcx then
      begin
        a:= TMemoryStream.Create;
        Archive.Extract(Index, a);
        a.Seek(0, 0);
        FileBitmap:= TJvPcx.Create;
        FileBitmap.LoadFromStream(a);
        ft:= aBmp;
      end else
      begin
        FileBitmap:= Archive.ExtractArrayOrBmp(Index, FileBuffer);
        if (ft = aBmp) and (FileBitmap = nil) then
          ft:= aPal;
      end;
    except
      ft:= aNone;
      a.Free;
    end;
  end;
  if ft = aBmp then
    if (LastPalString = '') and (Archive is TRSLod) and (TRSLod(Archive).LastPalette <> 0) then
      Label1.Caption:= Format(SPalette, [TRSLod(Archive).LastPalette])
    else
      Label1.Caption:= LastPalString
  else
    Label1.Caption:= '';

  Timer1.Interval:=0;
  Timer2.Enabled:=false;
  //RSSpeedButton2.Hide;
  //RSSpeedButton3.Hide;
  Def.Free;
  Def:=nil;
  Errors:=nil;

  j:=0;
  FileType:= ft;
  try
    case ft of
      aDef:
      begin
        Def:=TRSDefWrapper.Create(FileBuffer);
        Def.OnPreparePalette:=PreparePal;
        if not ShowOneGroup then
          j:=Def.PicturesCount
        else
{          if length(Def.Groups)>2 then
            j:=Def.Groups[2].ItemsCount
          else}
            if length(Def.Groups)>0 then
              j:=Def.Groups[0].ItemsCount;
        // RSSpeedButton3.Show; // !!!
      end;
      aBmp:
      begin
        j:=1;
        Image1.Picture.Bitmap:= FileBitmap;
        FreeAndNil(FileBitmap);
        {
        Image1.Picture.Bitmap.PixelFormat:=pf15bit;
        Lod.FBuffer:=Lod.PackBitmap(Image1.Picture.Bitmap);
        Lod.ConvPCXDump2Bitmap(Image1.Picture.Bitmap);
        }
      end;
      aTxt:
      begin
        j:=0;
        SetString(s, PChar(FileBuffer), length(FileBuffer));
        RSMemo1.Text:=s;
      end;
      aWav:
      begin
        if RSSpeedButton2.Down then
          sndPlaySound(@FileBuffer[0], SND_ASYNC or SND_MEMORY or SND_NODEFAULT);
      end;
      aVideo:
        if RSSpeedButton2.Down then
        begin
          if WasPlayed then
            Sleep(1); // Avoid Bink and Smack thread synchronization bug in most cases
                      // RSSetSilentExceptionsFiter is used to handle other cases
          PlayVideo;
          if VideoPlayer <> nil then
            j:= 1;
        end;
    end;
  except
    j:=0;
  end;
  if RSMemo1.Visible <> (ft = aTxt) then
  begin
    RSMemo1.Visible:= ft = aTxt;
    Panel1.Invalidate;
  end;
  SetLength(Errors, j);
  if j=0 then
    Image1.Hide;
  RSSpeedButton1.Visible:= (ft <> aWav) and (ft <> aNone);
  RSSpeedButton2.Visible:= (ft = aDef) or (ft = aWav) or (ft = aVideo);
  RSSpeedButton2.Enabled:= (ft <> aDef) or (j > 1);
  TrackBar1.Visible:=j>1;
  TrackBar1.Max:=j-1;
  TrackBar1.Position:=0;
  if j>0 then
    if Def<>nil then
    begin
      with Def.Header^ do
        ReStretch(Width, Height);
      TrackBar1Change(nil);
      Image1.Show;
    end else
    begin
      ReStretch;
      Image1.Show;
    end;
  if RSSpeedButton2.Down and (j>1) then
    Timer1.Interval:=AnimTime;
end;

procedure TRSLodEdit.LoadIni;
begin
  //RSSaveTextFile(AppPath + 'Lang.txt', RSLanguage.MakeLanguage);
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
    try
      Recent.AsString:= ReadString('General', 'Recent Files', '');
      Language:= ReadString('General', 'Language', 'English');
      Sortbyextension1.Checked:= ReadBool('General', 'Sort By Extension', false);
      TRSSpeedButton(Sortbyextension1.Tag).Down:= Sortbyextension1.Checked;
      Backup1.Checked:= ReadBool('General', 'Backup Original Files', true);
      OpenDialog1.InitialDir:= ReadString('General', 'Open Path', '');
      SaveDialogExport.InitialDir:= ReadString('General', 'Export Path', '');
      OpenDialogImport.InitialDir:= ReadString('General', 'Import Path', '');
      OpenDialogBitmapsLod.FileName:= ReadString('General', 'BitmapsLod Path', '');
    finally
      Free;
    end;
  UpdateRecent;
end;

procedure TRSLodEdit.TrackBar1Change(Sender: TObject);
begin
  if TrackBarChanging then  exit;
  TrackBarChanging:=true;
  try
    Application.ProcessMessages;
    if TrackBar1.Position>=length(Errors) then
      TrackBar1.Position:=0;
    LoadBmp(TrackBar1.Position, Image1.Picture.Bitmap);
  finally
    TrackBarChanging:=false;
  end;
end;

procedure TRSLodEdit.PreparePal(Sender: TRSDefWrapper; Pal:PLogPal);
const
  DefColors: array[0..7] of int =
    ($FFFF00, $FF96FF, $FF64FF, $FF32FF, $FF00FF, $00FFFF, $FF00B4, $00FF00);

  ColorMasks: array[0..9] of int =
    (0, $1111111{-}, $1111001, $11001, $11001, $1111, 0, $1001, $1111111{-}, $1001);

var i,j,k:int;
begin
  if NormalPalette1.Checked then
  begin
    for i:=0 to 7 do
      int(Pal.palPalEntry[i]):=DefColors[i];
    for i:=8 to 255 do
      int(Pal.palPalEntry[i]):=DefColors[0];
  end else
    if TransparentBackground1.Checked then
    begin
      int(Pal.palPalEntry[0]):=ColorToRGB(clBtnFace);
      int(Pal.palPalEntry[1]):=RSMixColors(clBtnFace, 0, 182);
      int(Pal.palPalEntry[2]):=RSMixColors(clBtnFace, 0, 163);
      int(Pal.palPalEntry[3]):=RSMixColors(clBtnFace, 0, 143);
      int(Pal.palPalEntry[4]):=RSMixColors(clBtnFace, 0, 124);

      int(Pal.palPalEntry[5]):=clYellow;
      int(Pal.palPalEntry[6]):=RSMixColors(clYellow, 0, 170); //clYellow;
      int(Pal.palPalEntry[7]):=RSMixColors(clYellow, 0, 210);// clYellow;
      //for i:=5 to 7 do
      //  int(Pal.palPalEntry[i]):=DefColors[i];
      k:=int(Pal.palPalEntry[0]);
      for i:=8 to 255 do
        int(Pal.palPalEntry[i]):=k;
      j:=Sender.Header^.TypeOfDef - $40;
      if (j>=0) and (j<=9) then
      begin
        j:= ColorMasks[j];
        k:= 1;
        for i:= 1 to 7 do
        begin
          if j and k = 0 then
            int(Pal.palPalEntry[i]):=int(Pal.palPalEntry[0]);
          k:=k shl 4;
        end;
      end;
    end;
//  exit;
//  if Def.GetPicHeader(0)^.Compression=0 then exit;
{
  if RSSpeedButton3.Down then
  begin
    int(Pal.palPalEntry[0]):=ColorToRGB(clBtnFace);
    int(Pal.palPalEntry[4]):=RSMixColorsNorm(clBtnFace, 0, 124);
    int(Pal.palPalEntry[1]):=RSMixColorsNorm(clBtnFace, 0, 182);
//    int(Pal.palPalEntry[5]):=clYellow;
//    int(Pal.palPalEntry[6]):=RSMixColorsNorm(clYellow, 0, 170); //clYellow;
//    int(Pal.palPalEntry[7]):=RSMixColorsNorm(clYellow, 0, 210);// clYellow;
  end;
}
end;

procedure TRSLodEdit.ReStretch(w:int=-1; h:int=-1);
begin
  //DoReStretch(Image1, RSSpeedButton1.Down, Image1.Width, Image1.Height);

  if h=-1 then
  begin
    w:=Image1.Picture.Width;
    h:=Image1.Picture.Height;
  end;
  DoReStretch(Image1, RSSpeedButton1.Down, Panel1.Width - Image1.Left - 1,
              RSSpeedButton1.Top - Image1.Left, w, h);

{
  DoReStretch(Image1, RSSpeedButton1.Down, Panel1.Width-Image1.Left*2,
              RSSpeedButton1.Top-Image1.Top*2);
{}
end;

procedure TRSLodEdit.ThemeChanged;
begin
  if ThemeServices.ThemesEnabled then
  begin
    TreeView1.BorderWidth:=0;
    with RSMemo1 do
    begin
      Align:=alNone;
      BorderStyle:=bsSingle;
      Top:=0;
      Left:=0;
      Width:=Panel1.Width;
      Height:=Panel1.Height;
    end;
    //ListView1.BorderWidth:=2; // Глючит - текст залазит за границу
  end else
    RSMemo1.Align:=alClient;
end;

procedure TRSLodEdit.FormCreate(Sender: TObject);
var
  a: PPalFix;
  s: string;
begin
  RSHookFlatBevels(self);
  if not ThemeServices.ThemesEnabled then
    RSComboBox1.BevelKind:= bkFlat;
  ThemeChanged;
  SExtractTo:=ExtractTo1.Caption;
  Image1.ControlStyle:=Image1.ControlStyle+[csOpaque];

  ClipboardFormat:=RegisterClipboardFormat('RSLodEdit Favorites');

  s:= RSGetModuleFileName(0);
  Association1:= TRSFileAssociation.Create('.lod', 'MMArchive.Lod',
         'MMArchive Backup', '"' + s + '" "%1"', s + ',0');
  Association2:= TRSFileAssociation.Create('.snd', 'MMArchive.Snd',
         'MMArchive Backup', '"' + s + '" "%1"', s + ',0');
  Association3:= TRSFileAssociation.Create('.vid', 'MMArchive.Vid',
         'MMArchive Backup', '"' + s + '" "%1"', s + ',0');

  PalFixList:= TStringList.Create;
  PalFixList.Sorted:= true;
  PalFixList.CaseSensitive:= false;
  a:= @PalFix[1];
  while a.Name <> '' do
  begin
    PalFixList.AddObject(a.Name, TObject(a));
    inc(a);
  end;

{
  with RSMemo1 do
  begin
    Width:=Panel1.Width-10;
    Height:=Panel1.Height-10;
  end;
}
//  Panel1.FullRepaint:=false;
//  Panel2.FullRepaint:=false;
end;

procedure TRSLodEdit.Panel1Resize(Sender: TObject);
begin
  ReStretch;
end;

procedure TRSLodEdit.ListView1Editing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit:=false;
end;

procedure TRSLodEdit.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  i:int;
begin
  UpdateToolbarState;
  if not Selected then  exit;
//  if Item=nil then  exit;
  i:=Item.Index;
  if ListView_GetItemState(ListView1.Handle, i, LVIS_FOCUSED) = 0 then  exit;
{
  i:=ListView_GetNextItem(ListView1.Handle, -1, LVNI_ALL or LVNI_FOCUSED);
  if i<0 then exit;
}
  LastSel:=i;

  if SelectingIndex<>nil then
  begin
    SelectingIndex^:=i;
    exit;
  end;

  SelectingIndex:=@i;
  try
    Application.ProcessMessages;
  finally
    SelectingIndex:=nil;
  end;
  LastSelIndex:=i;

  // !!! LoadFile не должен вызывать Application.ProcessMessages и т.п.
  LoadFile(i);
end;

procedure TRSLodEdit.RSComboBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  if odSelected in State then
    State:= State + [odFocused];
  with TComboBox(Control) do
    RSPaintList(Control, Canvas, Items[Index], Rect, State);
end;

procedure TRSLodEdit.RSComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  w: HWND;
begin
  w:= TRSComboBox(Sender).ListBoxHandle;
  if (Key = VK_ESCAPE) and ((w = 0) or not IsWindowVisible(w)) then
  begin
    Button2Click(nil);
    Key:=0;
  end;
end;

procedure TRSLodEdit.RSComboBox1Select(Sender: TObject);
var
  s:string;
begin
  if ListView1.Selected<>nil then
    DefaultSel:= SelCaption;
  s:= RSComboBox1.Text;
  if (s<>FilterExt) and BeginLoad(ArchiveFileName, s) then
  begin
    FilterExt:= s;
    EndLoad;
  end;
end;

procedure TRSLodEdit.RSSpeedButton1Click(Sender: TObject);
begin
  ReStretch;
  //Image1.Stretch:=RSSpeedButton1.Down;
end;

procedure TRSLodEdit.RSSpeedButton2Click(Sender: TObject);
begin
  case FileType of
    aDef:
      if RSSpeedButton2.Down and (length(Errors)>1) then
        Timer1.Interval:= AnimTime
      else
        Timer1.Interval:= 0;
    aWav:
      if RSSpeedButton2.Down then
        sndPlaySound(@FileBuffer[0], SND_ASYNC or SND_MEMORY or SND_NODEFAULT)
      else
        sndPlaySound(nil, SND_ASYNC or SND_MEMORY or SND_NODEFAULT);
    aVideo:
      if not RSSpeedButton2.Down then
      begin
        Timer1.Interval:= 0;
        if VideoPlayer <> nil then
          VideoPlayer.Pause:= true;
      end else
        PlayVideo;
  end
end;

procedure TRSLodEdit.Timer1Timer(Sender: TObject);
var
  i:int;
begin
  case FileType of
    aDef:
    begin
      i:=TrackBar1.Position;
      inc(i);
      if i>=length(Errors) then
        i:=0;
      TrackBar1.Position:=i;
    end;
    aVideo:
    begin
      if (VideoPlayer = nil) or VideoPlayer.Wait then  exit;
      VideoPlayer.NextFrame;
      VideoPlayer.ExtractFrame(Image1.Picture.Bitmap);
      Image1.Invalidate;
    end;
  end;
end;

procedure TRSLodEdit.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift=[ssCtrl] then
    case Key of
      VK_LEFT:
        if TrackBar1.Visible then
          TrackBar1.Position:= TrackBar1.Position - 1
        else
          exit;
      VK_RIGHT:
        if TrackBar1.Visible then
          TrackBar1.Position:= TrackBar1.Position + 1
        else
          exit;
      VK_RETURN:
        if EmulatePopupShortCuts then
          AddtoFavorites1Click(nil)
        else
          exit;
      ord('A'):
        ListView1.SelectAll;
      else
        exit;
    end
  else
    if EmulatePopupShortCuts and (Key=VK_RETURN) and (Shift=[]) then
      Button1Click(nil)
    else
      if (Key=VK_ESCAPE) and (Shift=[]) then //and not FEditing then
        Button2Click(nil)
      else
        exit;
  Key:=0;
end;

procedure TRSLodEdit.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button=mbMiddle) and (@EnterReaderModeHelper<>nil) then
    EnterReaderModeHelper(ListView1.Handle);
end;

procedure TRSLodEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    SaveTree(ArchiveFileName);
  except
    on e:Exception do
      Application.ShowException(e);
  end;
end;

procedure TRSLodEdit.FormDestroy(Sender: TObject);
begin
  if FEditing then
    SaveIni;
  // !!!
  //PPtr(@ListView1.Items.Owner)^:=self; // Чтоб не тормозило
  FreeAndNil(Archive);
  FreeAndNil(FileBitmap);
  FreeAndNil(Def);
  if FileType = aWav then
    sndPlaySound(nil, SND_ASYNC or SND_MEMORY or SND_NODEFAULT);
  FileBuffer:= nil;
  FreeAndNil(PalFixList);
  FreeAndNil(VideoPlayers[0]);
  FreeAndNil(VideoPlayers[1]);
  FreeAndNil(VideoPlayers[2]);
end;

procedure TRSLodEdit.FreeVideo;
begin
  if VideoPlayer <> nil then
  begin
    VideoPlayer.Close;
    VideoPlayer:= nil;
  end;
  if VideoStream <> nil then
    Archive.RawFiles.FreeAsIsFileStream(0, VideoStream);
  VideoStream:= nil;
end;

procedure TRSLodEdit.TreeView1Collapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  AllowCollapse:= Node.Level<>0;
end;

procedure TRSLodEdit.TreeView1Editing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
//  AllowEdit:= Node.ImageIndex = 1;
  AllowEdit:= Node.Parent <> nil;
end;

procedure TRSLodEdit.TreeView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  with TreeView1 do
    if (Selected=nil) or not PtInRect(Selected.DisplayRect(false),
                                        ScreenToClient(Mouse.CursorPos)) then
    begin
      mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);
      mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);
    end;
  Application.ProcessMessages;
  with Mouse.CursorPos do
    PopupMenu1.Popup(x, y);
end;

function TRSLodEdit.AddTreeNode(s:string; Image:integer; EditName:boolean; Select:boolean=true):TTreeNode;
var Node, Sel, it:TTreeNode;
begin
  Sel:=TreeView1.Selected;
  if Sel=nil then Sel:=TreeView1.Items[0];
  if Sel.ImageIndex=0 then
    Node:=Sel.Parent
  else
    Node:=Sel;
  TreeDeleteNeedeed:=false;
  it:=TreeView1.Items.AddChild(Node, s);
  Result:=it;
  if not EditName then
  begin
    Node.CustomSort(nil, 0, false);
    if TreeDeleteNeedeed then
    begin
      it.Delete;
      exit;
    end;
  end;
  if Image=0 then
    (it as TMyNode).FileName:=s;
  Node.Expand(false);
  with it do
  begin
    ImageIndex:=Image;
    SelectedIndex:=Image;
    Application.ProcessMessages;
    if Select then
      TreeView1.Select(it);
    if EditName then
      EditText;
  end;
end;

function TRSLodEdit.ArchiveFileName: string;
begin
  if Archive <> nil then
    Result:= Archive.RawFiles.FileName
  else
    Result:= '';
end;

procedure TRSLodEdit.Associate1Click(Sender: TObject);
begin
  Association1.Associated:= not Associate1.Checked;
end;

procedure TRSLodEdit.Associate2Click(Sender: TObject);
begin
  Association2.Associated:= not Associate2.Checked;
end;

procedure TRSLodEdit.Associate3Click(Sender: TObject);
begin
  Association3.Associated:= not Associate3.Checked;
end;

procedure TRSLodEdit.AddFolder1Click(Sender: TObject);
begin
  AddTreeNode(SNewFolder, 1, true);
end;

procedure TRSLodEdit.Add1Click(Sender: TObject);
begin
  if OpenDialogImport.Execute then
    DoAdd(OpenDialogImport.Files);
end;

procedure TRSLodEdit.AddFile1Click(Sender: TObject);
begin
  if ListView1.Selected=nil then exit;
  AddTreeNode(SelCaption, 0, false);
end;

procedure TRSLodEdit.TreeView1Edited(Sender: TObject; Node: TTreeNode;
  var S: String);
begin
  if s='' then
    Node.Delete
  else
  begin
    Node.Data:=nil;
    Node.Text:=s;
    Node.Parent.CustomSort(nil, 0);
  end;
end;

procedure TRSLodEdit.TreeView1CancelEdit(Sender: TObject; Node: TTreeNode);
begin
  if Node.Text='' then
    Node.Delete
  else
    Node.Parent.CustomSort(nil, 0);
end;

procedure TRSLodEdit.Delete1Click(Sender: TObject);
var i:uint;
begin
  with TreeView1 do
  begin
    if Items[0].Selected then exit;
    for i:=SelectionCount-1 downto 0 do
      Selections[i].Delete;
  end;
end;

procedure TRSLodEdit.TreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DELETE:
      if not TreeView1.IsEditing then
      begin
        Delete1Click(nil);
        Key:=0;
      end;
    VK_RIGHT:
      if ssCtrl in Shift then
      begin
        AddFolder1Click(nil);
        Key:=0;
      end;
    VK_RETURN:
      if ssCtrl in Shift then
      begin
        AddFile1Click(nil);
        Key:=0;
      end else
        if Shift=[] then
        begin
          Rename1Click(nil);
          Key:=0;
        end;
    VK_ESCAPE:
      if not TreeView1.IsEditing then
      begin
        Button2Click(nil);
        Key:=0;
      end;
  end;
end;

procedure TRSLodEdit.Rebuild1Click(Sender: TObject);
var
  WasPlaying: Boolean;
begin
  WasPlaying:= (FileType = aVideo) and (Timer1.Interval <> 0);
  FreeVideo;
  Archive.RawFiles.Rebuild;
  MessageBeep(MB_ICONINFORMATION);
  if WasPlaying then
    PlayVideo;
end;

procedure TRSLodEdit.RecentClick(Sender: TRSRecent; FileName: string);
begin
  FilterExt:= AnyExt;

  CreateArchive(FileName);
  FLightLoad:= false;
  EndLoad;
end;

procedure TRSLodEdit.Rename1Click(Sender: TObject);
var Node:TTreeNode;
begin
  Node:=TreeView1.Selected;
  if (Node=nil) {or (Node.ImageIndex<>1)} then exit;
  Node.EditText;
end;

procedure TRSLodEdit.TreeView1KeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13, #10, #27:
    begin
      Key:=#0;
      exit;
    end;
  end;
  if not TreeView1.IsEditing then
    case Key of
      #24: Cut1Click(nil);
      #3: Copy1Click(nil);
      #22: Paste1Click(nil);
      else
        exit;
    end
  else
    exit;
  Key:=#0;
end;


function TRSLodEdit.GetTreePath(FileName:string):string;
const MyExt='.lf';
begin
  if ExtractFileExt(FileName)<>MyExt then
    if Favorites<>'' then
      Result:= Favorites + ChangeFileExt(ExtractFileName(FileName), MyExt)
    else
      Result:= AppPath + 'Favorites\' +
                 ChangeFileExt(ExtractFileName(FileName), MyExt)
  else
    Result:=FileName;
end;

procedure TRSLodEdit.Help1Click(Sender: TObject);
begin
  RSHelpShow([], 600, 600);
end;

type
  TMyTreeHeader = packed record
    Size: word;
    Version: byte;
  end;
  PMyTreeHeader = ^TMyTreeHeader;

(*

Format: <Header> {File}

File: <Text> <End Byte> <Number In Lod (if not a folder!)> <FileName> <Reserved>

End Byte bits:

1 - Folder
2 - Has items
4 - Last in folder

Reserved String: Here may be a Hint string 

*)

procedure ReadNode(Items:TTreeNodes; var p:PByte; Node:TMyNode);
var p1:Ptr; i:Byte; j:int; it:TMyNode; s:string;
begin
  i:=0;
  while i < 4 do
  begin
    p1:=p;
    while p^>=8 do
      inc(p);
    SetString(s, PChar(p1), int(p)-int(p1));
    i:=p^;
    j:=i and 1;
    if not Node.Hidden and ((FilterExt = AnyExt) or (j=1) or
                (AnsiCompareText(ExtractFileExt(s), FilterExt)=0)) then
      it:=TMyNode(Items.AddChild(Node, s))
    else
      it:=Node.AddHiddenItem(s);
    inc(p);
    with it do
    begin
      ImageIndex:= j;
      SelectedIndex:= j;
      if j = 0 then
      begin
        Data:=ptr(DWord(PWord(p)^));
        inc(p, 2);
      end;
      p1:=p;
      while p^<>0 do // FileName
        inc(p);
      SetString(s, PChar(p1), int(p)-int(p1));
      it.FileName:=s;
      inc(p);
      p1:=p;
      while p^<>0 do // Reserved
        inc(p);
      SetString(s, PChar(p1), int(p)-int(p1));
      it.Param2:=s;
      inc(p);
      if it.FileName='' then
        it.FileName:=it.Text;
      if i and 2 <> 0 then
        ReadNode(Items, p, it);
    end;
  end;
end;

procedure TRSLodEdit.DoLoadTree(const a:TRSByteArray; Node:TTreeNode=nil);
var p:PByte;
begin
  if (length(a)<3) or (length(a)=PMyTreeHeader(a).Size) then exit;

  if Node=nil then
    Node:=TreeView1.Items[0];
  with TreeView1.Items do
  begin
    BeginUpdate;
    try
      p:=ptr(a);
      inc(p, PMyTreeHeader(a).Size);
      ReadNode(TreeView1.Items, p, TMyNode(Node));
      Node.CustomSort(nil, 0);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TRSLodEdit.LoadTree(FileName:string);
var a:TRSByteArray;
begin
  a:=nil;
  if FileName='' then exit;
  FileName:=GetTreePath(FileName);
  if not FileExists(FileName) then exit;
  a:=RSLoadFile(FileName);
  if (length(a)<=3) or (length(a)<=PMyTreeHeader(a).Size) then exit;

  DoLoadTree(a);
  TreeView1.Items[0].Expand(false);
end;

function SingleNodeSize(Node:TMyNode):int;
begin
  if Node.Text=Node.FileName then
    Result:=length(Node.Text) + length(Node.Param2) + 3
  else
    Result:=length(Node.Text) + length(Node.FileName) + length(Node.Param2) + 3;
  if Node.ImageIndex=0 then
    inc(Result, 2);
end;

function CountNodeSize(Node:TMyNode):int;
var i:int;
begin
  Result:=0;
  for i:=Node.FullCount-1 downto 0 do
  begin
    inc(Result, SingleNodeSize(TMyNode(Node[i]))
                                   + CountNodeSize(TMyNode(Node[i])));
  end;
end;

procedure WriteSingleNode(var p:PByte; it:TMyNode; Last:boolean);
var j:int; s:string;
begin
  s:=it.Text;
  CopyMemory(p, ptr(s), length(s));
  inc(p, length(s));
  j:=it.ImageIndex;
  if it.FullCount>0 then
    j:= j or 2;
  if Last then
    j:= j or 4;
  p^:=Byte(j);
  inc(p);
  if j and 1 = 0 then // if file
  begin
    PWord(p)^:=word(it.Data);
    inc(p,2);
  end;

  s:=it.FileName;
  if s=it.Text then
    s:='';
  CopyMemory(p, ptr(s), length(s));
  inc(p, length(s));
  p^:=0;
  inc(p);

  s:=it.Param2; // Reserved
  CopyMemory(p, ptr(s), length(s));
  inc(p, length(s));
  p^:=0;
  inc(p);
end;

procedure WriteNode(var p:PByte; Node:TMyNode);
var i:int; it:TMyNode;
begin
  for i:=0 to Node.FullCount-1 do
  begin
    it:=TMyNode(Node[i]);
    WriteSingleNode(p, it, i=Node.FullCount-1);
    WriteNode(p, it);
  end;
end;

procedure TRSLodEdit.SaveIni;
begin
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
    try
      WriteString('General', 'Recent Files', Recent.AsString);
      WriteString('General', 'Language', Language);
      WriteBool('General', 'Sort By Extension', Sortbyextension1.Checked);
      WriteBool('General', 'Backup Original Files', Backup1.Checked);
      WriteString('General', 'Open Path', DialogToFolder(OpenDialog1));
      WriteString('General', 'Export Path', DialogToFolder(SaveDialogExport));
      WriteString('General', 'Import Path', DialogToFolder(OpenDialogImport));
      WriteString('General', 'BitmapsLod Path', OpenDialogBitmapsLod.FileName);
    finally
      Free;
    end;
end;

function TRSLodEdit.SaveNodes(Nodes:array of TTreeNode):TRSByteArray;
var i, j:int; p:PByte;
begin
  j:=SizeOf(TMyTreeHeader);
  if Nodes[0].Level=0 then
    inc(j, CountNodeSize(TMyNode(Nodes[0])))
  else
    for i:=0 to high(Nodes) do
      inc(j, SingleNodeSize(TMyNode(Nodes[i])) + CountNodeSize(TMyNode(Nodes[i])));

  SetLength(Result, j);
  with PMyTreeHeader(Result)^ do
  begin
    Size:=SizeOf(TMyTreeHeader);
    Version:=0;
  end;
  p:=ptr(Result);
  inc(p, SizeOf(TMyTreeHeader));
  if Nodes[0].Level=0 then
    WriteNode(p, TMyNode(Nodes[0]))
  else
    for i:=0 to high(Nodes) do
    begin
      WriteSingleNode(p, TMyNode(Nodes[i]), i=high(Nodes));
      WriteNode(p, TMyNode(Nodes[i]));
    end;
end;

procedure TRSLodEdit.SaveTree(FileName:string);
var a,a1:TRSByteArray; s:string;
begin
  a:=nil; a1:=nil;
  if (FileName='') then exit;
  FileName:=GetTreePath(FileName);
  if not FileExists(FileName) and (TMyNode(TreeView1.Items[0]).FullCount=0) then
    exit;
  s:=ChangeFileExt(FileName, '.bak');
  a:=SaveNodes([TreeView1.Items[0]]);

  if FileExists(FileName) then
  try
    a1:=RSLoadFile(FileName); // !!! надо вначале сравнивать размер
    if (length(a)=length(a1)) and CompareMem(ptr(a), ptr(a1), length(a)) then
      exit;
    a1:=nil;
  except
  end;
  DeleteFile(ptr(s));
  MoveFile(ptr(FileName), ptr(s));
  RSSaveFile(FileName, a);
end;

procedure TRSLodEdit.TreeView1Change(Sender: TObject; Node: TTreeNode);
var i,j:int; s:string; // r:TRect;
begin
  if not CanSelectListView or (Node<>TreeView1.Selected) or
                                             (Node.ImageIndex<>0) then exit;
  s:=(Node as TMyNode).FileName;
  if (ListView1.Selected<>nil) and (s=SelCaption) then
  begin
    Node.Data:=ptr(ItemIndexes[LastSel]+1);
    exit;
  end;

  i:= int(Node.Data) - 1;
  if ((i < 0) or (i >= Archive.RawFiles.Count)
     or not SameText(Archive.RawFiles.Name[i], s)) and not Archive.RawFiles.FindFile(s, i) then
    exit;

  Node.Data:= ptr(i + 1);
  i:= ArchiveIndexes[i];

  j:=ListView1.SelCount;
  if j>=1 then
    if j=1 then
      ListView1.Selected.Selected:=false
    else
      for j:=0 to ListView1.Items.Count-1 do
        ListView1.Items[j].Selected:=false;

  //ListView_EnsureVisible(ListView1.Handle, i, false);
  ListView_SetItemState(ListView1.Handle, i, LVIS_SELECTED or LVIS_FOCUSED,
                                              LVIS_SELECTED or LVIS_FOCUSED);
  Timer2.Enabled:=true;
end;

procedure TRSLodEdit.TreeView1Compare(Sender: TObject; Node1, Node2: TTreeNode;
  Data: Integer; var Compare: Integer);
var Temp:TTreeNode;
begin
  if Node1.ImageIndex<>Node2.ImageIndex then
    Compare:=Node2.ImageIndex-Node1.ImageIndex
  else
    Compare:=AnsiCompareText(Node1.Text, Node2.Text);

  if Compare=0 then
    if TreeDeleteNeedeed then
    begin
      if TMyNode(Node2).FullCount=0 then Node1:=Node2;
      if TMyNode(Node1).FullCount=0 then
        PostMessage(TreeView1.Handle, TVM_DELETEITEM, 0, int(Node1.ItemId))
      else
      begin
        // Collapse items
        if Node1.Count>Node2.Count then
        begin
          Temp:=Node1;
          Node1:=Node2;
          Node2:=Temp;
        end;
        if Node2.ImageIndex=0 then
          Node2:=Node2.Parent;
        TMyNode(Node1).MoveChildren(TMyNode(Node2));
        Node2.CustomSort(nil, 0);
        PostMessage(TreeView1.Handle, TVM_DELETEITEM, 0, int(Node1.ItemId))
      end;
    end else
      TreeDeleteNeedeed:=true;
end;

procedure TRSLodEdit.AddtoFavorites1Click(Sender: TObject);
var i:int;
begin
  CanSelectListView:=false;
  try
    with ListView1.Items do
      for i:=0 to Count-1 do
        if Item[i].Selected then
        begin
          AddTreeNode(Archive.Names[ItemIndexes[i]], 0, false);
        end;
  finally
    CanSelectListView:=true;
  end;
end;

procedure TRSLodEdit.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  Handled:=ListView1.Selected=nil;
  {
  with MousePos do
    a:=ListView1.GetItemAt(X, Y);
  if (a=nil) or not a.Selected then
  begin
    mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);
    mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);
    Application.ProcessMessages;
    Handled:=ListView1.Selected=nil;
  end;
  }
{  with Mouse.CursorPos do
    PopupMenu1.Popup(x, y);}
end;

procedure TRSLodEdit.TreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:= Sender=Source;
end;

procedure TRSLodEdit.TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
var Node:TTreeNode;
begin
  Node:=TreeView1.GetNodeAt(x, y);
  if Node=nil then
    Node:=TreeView1.Items[0]
  else
    if Node.ImageIndex=0 then
      Node:=Node.Parent;

  if Node=DragNode.Parent then exit;
  DragNode.MoveTo(Node, naAddChild);

  Node.CustomSort(nil, 0);
end;

procedure TRSLodEdit.TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Node:TTreeNode;
begin
  if (Button=mbMiddle) and (@EnterReaderModeHelper<>nil) then
  begin
    EnterReaderModeHelper(TreeView1.Handle);
    exit;
  end;

  Node:=TreeView1.GetNodeAt(x, y);
  if (Node<>nil) and (Node.Level>0) then
  begin
    DragNode:=Node;
    DragPoint:=Point(x, y);
  end;
end;

procedure TRSLodEdit.TreeView1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var h:int;
begin
  if TreeView1.IsEditing then  DragPoint.X:=MaxInt;
  if DragPoint.X = MaxInt then  exit;
  h:=max(Mouse.DragThreshold, 2);
  if (abs(x-DragPoint.X)>h) or (abs(y-DragPoint.Y)>h) then
  begin
    TreeTimer1.Interval:=100;
    TreeView1.BeginDrag(true);
  end;
end;

procedure TRSLodEdit.TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DragPoint.X:=MaxInt;
end;

procedure TRSLodEdit.UpdateRecent;
begin
  TRSSpeedButton(Open1.Tag).DropDownDisabled:= (RecentFiles1.Count = 0);
end;

procedure TRSLodEdit.UpdateToolbarState;
var
  b: Boolean;
begin
  if not FEditing then
    exit;
  if ListView1.SelCount=1 then
    TRSSpeedButton(ExtractTo2.Tag).Hint:= SExtractAs
  else
    TRSSpeedButton(ExtractTo2.Tag).Hint:= SExtractTo;
  b:= ListView1.SelCount<>0;
  TRSSpeedButton(Extract2.Tag).Enabled:= b;
  TRSSpeedButton(ExtractTo2.Tag).Enabled:= b;
  TRSSpeedButton(Add1.Tag).Enabled:= b;
  TRSSpeedButton(Rebuild1.Tag).Enabled:= Archive <> nil;
end;

procedure TRSLodEdit.Cut1Click(Sender: TObject);
var Node:TTreeNode;
begin
  Node:=TreeView1.Selected;
  if Node=nil then exit;
  Copy1Click(nil);
  if Node.Level=0 then
    TMyNode(Node).DeleteChildren
  else
    Delete1Click(nil);
end;

procedure SetClipboardBuffer(Format: Word; var Buffer; Size: Integer);
var
  Data: THandle;
  DataPtr: Pointer;
begin
  Clipboard.Open;
  try
    Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
    try
      DataPtr := GlobalLock(Data);
      try
        Move(Buffer, DataPtr^, Size);
        //Adding;
        SetClipboardData(Format, Data);
      finally
        GlobalUnlock(Data);
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    Clipboard.Close;
  end;
end;

procedure SaveClipboard(Data:TRSByteArray; Format:DWord);
begin
  if Data=nil then exit;
  SetClipboardBuffer(Format, Data[0], length(Data));
end;

procedure TRSLodEdit.Copy1Click(Sender: TObject);
var i:int; Nodes:array of TTreeNode;
begin
  with TreeView1 do
  begin
    SetLength(Nodes, SelectionCount);
    for i:=length(Nodes)-1 downto 0 do
      Nodes[i]:=Selections[i];
  end;
  if length(Nodes)=0 then
  begin
    ClipboardBackup:=nil;
    exit;
  end;  
  ClipboardBackup:=SaveNodes(Nodes);
  SaveClipboard(ClipboardBackup, ClipboardFormat);
end;

procedure TRSLodEdit.CreateArchive(FileName: string);
begin
  FreeVideo;
  FreeAndNil(Archive);
  FreeAndNil(FSFT);
  FreeAndNil(FSFTLod);
  FSFTNotFound:= false;
  ListView1.Items.Count:= 0;
  Palette1.Visible:= false;
//  AppCaption:= AppCaption;

  Archive:= RSLoadMMArchive(FileName);
  AppCaption:= AppCaption;
  Archive.RawFiles.IgnoreUnzipErrors:= IgnoreUnpackingErrors1.Checked;
  Archive.BackupOnAdd:= Backup1.Checked;
  if Archive is TRSLod then
    with TRSLod(Archive) do
    begin
      OnNeedBitmapsLod:= NeedBitmapsLod;
      OnNeedPalette:= NeedPalette;
      OnSpritePalette:= SpritePaletteFixup;
      if Version = RSLodSprites then
        Palette1.Visible:= true;
    end;
  if Recent <> nil then
  begin
    Recent.Add(ArchiveFileName);
    UpdateRecent;
  end;
  Edit1.Visible:= true;
  UpdateToolbarState;
  FileTime:= 0;
end;

procedure TRSLodEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WinClassName:='MMArchive Main Form';
end;

function LoadClipboard(Format:DWord):TRSByteArray;
var h:THandle; DataPtr:pointer; Size:DWord;
begin
  if not IsClipboardFormatAvailable(Format) then
    exit;

  DataPtr:=nil;
  h:=0; // Чтоб копиллятор не ругался
  Clipboard.Open;
  try
    h:=Clipboard.GetAsHandle(Format);
    if h=0 then RSRaiseLastOSError;
    DataPtr:=GlobalLock(h);
    if DataPtr=nil then RSRaiseLastOSError;
    Size:=GlobalSize(h);
    SetLength(Result, Size);
    CopyMemory(ptr(Result), DataPtr, Size);
  finally
    if DataPtr<>nil then
      GlobalUnlock(h);
    Clipboard.Close;
  end;
end;

procedure TRSLodEdit.Paste1Click(Sender: TObject);
var a:TRSByteArray; Node:TTreeNode;
begin
  with TreeView1 do
  begin
    Node:=TreeView1.Selected;
    if Node=nil then
      Node:=TreeView1.Items[0]
    else
      if Node.ImageIndex=0 then
        Node:=Node.Parent;
    a:=LoadClipboard(ClipboardFormat);
    if a=nil then
      a:=ClipboardBackup;
    DoLoadTree(a, Node);
  end;
end;

type
  TBinkHeaderPart = record
    Signature: array[0..2] of char;
    Version: byte;
  end;

procedure TRSLodEdit.PlayVideo;
var
  hdr: TBinkHeaderPart;
  i: int;
begin
  if not VideoPrepared then
    RSSetSilentExceptionsFiter;
  VideoPrepared:= true;
  if VideoStream = nil then
  begin
    VideoStream:= Archive.RawFiles.GetAsIsFileStream(ItemIndexes[LastSel]);
    try
      VideoStream.ReadBuffer(hdr, 4);
      VideoStream.Seek(-4, soCurrent);
      if hdr.Signature = 'SMK' then
        i:= 0
      else
        if hdr.Version > $62 then
          i:= 1
        else
          i:= 2;

      VideoPlayer:= VideoPlayers[i];
      if VideoPlayer = nil then
      begin
        case i of
          0: VideoPlayer:= TRSSmackPlayer.Create(AppPath + 'SmackW32.DLL');
          1: VideoPlayer:= TRSBinkPlayer.Create(AppPath + 'BinkW32.dll');
          2: VideoPlayer:= TRSBinkPlayer.Create(AppPath + 'BinkW32old.dll');
        end;
        VideoPlayers[i]:= VideoPlayer;
      end;
      VideoPlayer.Open((VideoStream as TFileStream).Handle);
    except
      Archive.RawFiles.FreeAsIsFileStream(ItemIndexes[LastSel], VideoStream);
      VideoStream:= nil;
      VideoPlayer:= nil;
      raise;
    end;
    with Image1.Picture do
    begin
      Bitmap.Assign(nil);
      VideoPlayer.PreparePic(Bitmap);
      VideoPlayer.ExtractFrame(Bitmap);
    end;
    Image1.Visible:= true;
    if not Timer1.Enabled then  // if inactive
      VideoPlayer.Pause:= true;
  end else
    if VideoPlayer <> nil then
      VideoPlayer.Pause:= false;
  Timer1.Interval:= 10;
end;

{
var Node:TTreeNode; i:int;
begin
  if length(CutNodes)=0 then exit;
  with TreeView1 do
  begin
    Node:=TreeView1.Selected;
    if Node=nil then
      Node:=TreeView1.Items[0]
    else
      if Node.ImageIndex=0 then
        Node:=Node.Parent;
    if Node=CutNodes[0].Parent then exit;
    for i:=length(CutNodes)-1 downto 0 do
      CutNodes[i].MoveTo(Node, naAddChild);
    Node.CustomSort(nil, 0);
  end;
end;
}

type
  TMyListItem = class(TListItem)
  public
    constructor Create(AOwner: TListItems);
  end;

constructor TMyListItem.Create(AOwner: TListItems);
begin
  PPtr(@Owner)^ := AOwner;
   // !!! SubItems не нужен.
  PInt(@OverlayIndex)^ := -1;
  PInt(@StateIndex)^ := -1;
end;


procedure TRSLodEdit.ListView1CreateItemClass(Sender: TCustomListView;
  var ItemClass: TListItemClass);
begin
  ItemClass:=TMyListItem;
end;

procedure TRSLodEdit.TreeView1CreateNodeClass(Sender: TCustomTreeView;
  var NodeClass: TTreeNodeClass);
begin
  NodeClass:=TMyTreeNode;
end;

procedure TRSLodEdit.Button1Click(Sender: TObject);
begin
  if ListView1.Selected=nil then exit;
  RSLodResult:=SelCaption;
  ModalResult:=mrOk;
end;

procedure TRSLodEdit.ListView1DblClick(Sender: TObject);
begin
  if not FEditing then
    Button1.Click;
end;

procedure TRSLodEdit.IgnoreUnpackingErrors1Click(Sender: TObject);
begin
  if Archive <> nil then
  begin
    Archive.RawFiles.IgnoreUnzipErrors:= IgnoreUnpackingErrors1.Checked;
    if Archive.RawFiles.IgnoreUnzipErrors and (FileType = aNone) and (ListView1.SelCount <> 0) then
      LoadFile(LastSel);
  end;
end;

procedure TRSLodEdit.Image1DblClick(Sender: TObject);
begin
  Panel2.Width:= max(Panel2.Width, min(Image1.Picture.Bitmap.Width + Image1.Left + 1, ClientWidth - 30));
  Panel1.Height:= max(Panel1.Height, min(Image1.Picture.Bitmap.Height + (Panel1.Height - RSSpeedButton1.Top + Image1.Left), Panel2.Height - 30));
  if ListView1.SelCount <> 0 then
    ListView_EnsureVisible(ListView1.Handle, LastSel, false);
end;

procedure TRSLodEdit.Initialize(Editing:boolean=false; UseRSMenus:boolean=true);
begin
  {
  self:=ptr(TRSLodEdit.NewInstance);
  RSLodEdit:=self;
  self.Create(Application);
  }
  Application.CreateForm(TRSLodEdit, RSLodEdit);
  self:=RSLodEdit;
  if UseRSMenus then
  begin
    RSMenu.Add(PopupMenu1);
    RSMenu.Add(PopupMenu2);
    if Editing then
    begin
      RSMenu.Add(MainMenu1);
      RSMenu.OnGetShortCut:= MenuShortCut;
    end;
  end;
  with RSLanguage.AddSection('[TRSLodEdt]', self) do
  begin
    AddItem('SDeleteQuestion', SDeleteQuestion);
    AddItem('SDeleteManyQuestion', SDeleteManyQuestion);
    AddItem('SNewFolder', SNewFolder);
    AddItem('SExtractAs', SExtractAs);
    AddItem('SExtractTo', SExtractTo);
    AddItem('SEPaletteNotFound', SEPaletteNotFound);
    AddItem('SEPaletteMustExist', SEPaletteMustExist);
    AddItem('SPalette', SPalette);
    AddItem('SPaletteChanged', SPaletteChanged);
  end;
  FEditing:= Editing;
  if not Editing then
  begin
    Panel3.Hide;
    Panel4.Show;
    ListView1.MultiSelect:=false;
    //ProgressBar1.Top:=ProgressBar1.Top-Panel3.Height;
     // temp
    Extract1.Visible:=false;
    Extractto1.Visible:=false;
    Delete2.Visible:=false;
    Menu:=nil;
  end else
  begin
    Application.Title:= AppCaption;
    Select1.Visible:=false;
    RSBindToolBar:= true;
    RSComboBox1.Left:= 1 + RSMakeToolBar(Panel3, [New1, Open1, RecentFiles1, N3, Add1, Extract2, ExtractTo2, N6, Rebuild1, N6, Sortbyextension1], Toolbar, 1);
    UpdateToolbarState;
    DragAcceptFiles(Handle, true);
    TmpRecent1.Free;
    Recent:= TRSRecent.Create(RecentClick, RecentFiles1, true);
    RSHelpCreate(AppCaption + ' Help Form');
    LoadIni;
  end;

  if not Editing then
    DestroyHandle;
end;

procedure TRSLodEdit.Button2Click(Sender: TObject);
begin
//  Closing:=true;
  Close;
end;

procedure TRSLodEdit.MenuShortCut(Item: TMenuItem; var Result: string);
begin
  if Item = Delete3 then
    Result:= 'Del'
  else if Item = AddtoFavorites2 then
    Result:= 'Ctrl+Enter';
end;

procedure TRSLodEdit.MergeFavorites1Click(Sender: TObject);
begin
  if not OpenDialog2.Execute then exit;
  LoadTree(OpenDialog2.FileName);
end;

procedure TRSLodEdit.MergeWith1Click(Sender: TObject);
begin
  //
end;

procedure TRSLodEdit.Timer2Timer(Sender: TObject);
begin
  ListView_EnsureVisible(ListView1.Handle, LastSel, false);
  Timer2.Enabled:=false;
end;

procedure TRSLodEdit.Language1Click(Sender: TObject);
var
  s: string;
  m: TMenuItem;
  i: int;
begin
  for i := Language1.Count - 1 downto 1 do
    Language1.Items[i].Free;

  English1.Checked:= SameText(FLanguage, 'English');
  with TRSFindFile.Create(AppPath + LangDir + '*.txt') do
    try
      while FindAttributes(0, FILE_ATTRIBUTE_DIRECTORY) do
      begin
        s:= ChangeFileExt(Data.cFileName, '');
        if not SameText(s, 'English') then
        begin
          m:= TMenuItem.Create(self);
          m.RadioItem:= true;
          m.Caption:= s;
          m.OnClick:= English1Click;
          m.OnDrawItem:= English1.OnDrawItem;
          m.OnAdvancedDrawItem:= English1.OnAdvancedDrawItem;
          m.OnMeasureItem:= English1.OnMeasureItem;
          Language1.Add(m);
          m.Checked:= SameText(FLanguage, s);
        end;
        FindNext;
      end;
    finally
      Free;
    end;
end;

procedure TRSLodEdit.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  Timer2.Enabled:=false;
end;

procedure TRSLodEdit.RSSpeedButton3Click(Sender: TObject);
begin
  if Def=nil then exit;
  Def.RebuildPal;
  LoadBmp(LastBmp, Image1.Picture.Bitmap);
end;

procedure TRSLodEdit.ListView1Data(Sender: TObject; Item: TListItem);
begin
  with Item do
  begin
    Caption:= ItemCaptions[Index];
    Data:= ptr(ItemIndexes[Index]);
  end;
end;

procedure TRSLodEdit.Open1Click(Sender: TObject);
begin
  if ListView1.Selected<>nil then
    DefaultSel:= SelCaption;
  PrepareLoad;
  if not OpenDialog1.Execute then exit;

  FilterExt:= AnyExt;

  CreateArchive(OpenDialog1.FileName);
  FLightLoad:=false;
  EndLoad;
end;

procedure TRSLodEdit.Options1Click(Sender: TObject);
begin
  Associate1.Checked := Association1.Associated;
  Associate2.Checked := Association2.Associated;
  Associate3.Checked := Association3.Associated;
end;

procedure TRSLodEdit.File1Click(Sender: TObject);
begin
  RecentFiles1.Visible:= RecentFiles1.Count > 0;
end;

procedure TRSLodEdit.FindSpritePal(name: string; var pal: int2; Kind: int);
const
  size6 = $38;
  size7 = $3C;
  OffName = 12;
  OffPal6 = 48;
  OffPal7 = 50;

  function DoFindPal(const name: string): Boolean;
  var
    Kinds: array[1..3] of int2;
    size, n, i, j: int;
    p, p1: PChar;
  begin
    n:= pint(FSFT.Memory)^;

    size:= (FSFT.Size - pint(PChar(FSFT.Memory) + 4)^*2) div n;

    p:= PChar(FSFT.Memory) + 8 + OffName;
    for i := 0 to n - 1 do
    begin
      StrLower(p);
      inc(p, size);
    end;

    p:= PChar(FSFT.Memory) + 8 + OffName;
    if size = size7 then
      p1:= PChar(FSFT.Memory) + 8 + OffPal7
    else
      p1:= PChar(FSFT.Memory) + 8 + OffPal6;

    Result:= true;
    for i := 1 to 3 do
      Kinds[i]:= 0;
    for i := 0 to n - 1 do
    begin
      if (pint2(p1)^ <> 0) and (StrComp(p, ptr(name)) = 0) then
      begin
        for j := 1 to 3 do
        begin
          if Kinds[j] = pint2(p1)^ then  break;
          if Kinds[j] = 0 then
          begin
            if Kind = j then
            begin
              pal:= pint2(p1)^;
              exit;
            end;
            Kinds[j]:= pint2(p1)^;
            break;
          end;
        end;
      end;
      inc(p, size);
      inc(p1, size);
    end;
    for i := Kind downto 1 do
      if Kinds[i] <> 0 then
      begin
        pal:= Kinds[i];
        exit;
      end;
    Result:= false;
  end;

var
  s, name1: string;
  size, i, j: int;
  p: PChar;
begin
  if FSFT = nil then
  begin
    if FSFTNotFound then  exit;
    FSFTNotFound:= true;
    name1:= ExtractFilePath(TRSLod(Archive).BitmapsLod.RawFiles.FileName);
    s:= 'english';
    with TRSRegistry.Create do
      try
        RootKey:= HKEY_LOCAL_MACHINE;
        if OpenKeyReadOnly('SOFTWARE\New World Computing\Might and Magic Day of the Destroyer\1.0') then
          Read('language_file', s);
      finally
        Free;
      end;
    s:= s + 'T.lod';

    if FileExists(name1 + s) then
      FSFTLod:= TRSLod.Create(name1 + s)
    else if FileExists(name1 + 'EnglishT.lod') then
      FSFTLod:= TRSLod.Create(name1 + 'EnglishT.lod')
    else if FileExists(name1 + 'events.lod') then
      FSFTLod:= TRSLod.Create(name1 + 'events.lod')
    else if FileExists(name1 + 'icons.lod') then
      FSFTLod:= TRSLod.Create(name1 + 'icons.lod')
    else
      exit; // !!! show dialog

    try
      if not FSFTLod.RawFiles.FindFile('dsft.bin', j) then  exit;
      FSFT:= TMemoryStream.Create;
      FSFTLod.Extract(j, FSFT);
    finally
      FreeAndNil(FSFTLod);
    end;

    size:= (FSFT.Size - pint(PChar(FSFT.Memory) + 4)^*2) div pint(FSFT.Memory)^;

    p:= PChar(FSFT.Memory) + 8 + OffName;
    for i := 0 to pint(FSFT.Memory)^ - 1 do
    begin
      StrLower(p);
      inc(p, size);
    end;
  end;

  name:= LowerCase(name);
  if not DoFindPal(name) and (name[length(name)] in ['0'..'7']) then
    if not DoFindPal(copy(name, 1, length(name) - 1)) and (name[length(name)] <> '0') then
    begin
      name[length(name)]:= '0';
      DoFindPal(name);
    end;
end;

procedure TRSLodEdit.PrepareLoad;
begin
  with OpenDialog1 do
  begin
    Title:='';
    Options:=[ofHideReadOnly,ofPathMustExist,ofFileMustExist,ofEnableSizing];
    SaveDialog:=false;
    if Archive <> nil then
      FileName:= Archive.RawFiles.FileName;
  end;
end;

procedure TRSLodEdit.NeedBitmapsLod(Sender: TObject);
var
  s: string;
begin
  with TRSLod(Sender) do
  begin
    s:= ExtractFilePath(RawFiles.FileName) + 'Bitmaps.lod';
    if not FileExists(s) then
      if OpenDialogBitmapsLod.Execute then
        s:= OpenDialogBitmapsLod.FileName
      else
        exit;
    BitmapsLod:= TRSLod.Create(s);
    OwnBitmapsLod:= true;
  end;
end;

procedure TRSLodEdit.NeedPalette(Sender: TRSLod; Bitmap: TBitmap;
  var Palette: int);
var
  PalData: array[0..767] of Byte;
  pal: int;
begin
  if Bitmap.PixelFormat <> pf8bit then
    raise Exception.Create(SEPaletteMustExist);
  RSWritePalette(@PalData, Bitmap.Palette);
  if Sender.BitmapsLod = nil then
    if Sender.Version <> RSLodBitmaps then
    begin
      NeedBitmapsLod(Sender);
      if Sender.BitmapsLod = nil then
        exit;
    end else
      Sender.BitmapsLod:= Sender;

  if Sender.BitmapsLod.FindSamePalette(PalData, pal) then
    Palette:= pal
  else
    raise Exception.Create(SEPaletteNotFound);
end;

procedure TRSLodEdit.New1Click(Sender: TObject);
var
  s: string;
begin
  SaveDialogNew.InitialDir:= DialogToFolder(OpenDialog1);
  SaveDialogNew.FileName:= '';
  if not SaveDialogNew.Execute then exit;
  OpenDialog1.FileName:= SaveDialogNew.FileName;
  RSCreateDir(ExtractFilePath(SaveDialogNew.FileName));
  s:= ExtractFileExt(SaveDialogNew.FileName);
  if SameText(s, '.snd') then
  begin
    Archive:= TRSSnd.Create;
    TRSSnd(Archive).New(SaveDialogNew.FileName, false);
  end else
  if SameText(s, '.vid') then
  begin
    Archive:= TRSVid.Create;
    TRSVid(Archive).New(SaveDialogNew.FileName, false);
  end else
  begin
    Archive:= TRSLod.Create;
    TRSLod(Archive).New(SaveDialogNew.FileName, RSLodHeroes);
  end;
  EndLoad;
end;

function IsThere(s1, s2: string): Boolean;
var
  i: int;
begin
  RSLodCompareStr(PChar(s1), PChar(s2), i);
  Result:= i >= length(s2);
end;

procedure TRSLodEdit.ListView1DataFind(Sender: TObject; Find: TItemFind;
  const FindString: String; const FindPosition: TPoint; FindData: Pointer;
  StartIndex: Integer; Direction: TSearchDirection; Wrap: Boolean;
  var Index: Integer);
var
  i, j, m: int;
begin
  if StartIndex >= length(ItemIndexes) then
    StartIndex:= 0;
  m:= -1;
  if Archive.RawFiles.Sorted then
  begin
    if (StartIndex > 0) and IsThere(Archive.Names[ItemIndexes[StartIndex]], FindString) then
    begin
      Index:= StartIndex;
      exit;
    end;
    Archive.RawFiles.FindFile(FindString, i);
    while IsThere(Archive.RawFiles.Name[i], FindString) do
    begin
      j:= ArchiveIndexes[i];
      if j >= 0 then
      begin
        if (j < m) and ((j >= StartIndex) or (m < StartIndex)) or (j >= StartIndex) and (m < StartIndex) or (m < 0) then
          m:= j;
      end;
      inc(i);
    end;
    Index:= m;
  end else
  begin
    for i := StartIndex to length(ItemIndexes) - 1 do
      if IsThere(Archive.Names[ItemIndexes[i]], FindString) then
      begin
        Index:= i;
        exit;
      end;
    for i := 0 to StartIndex - 1 do
      if IsThere(Archive.Names[ItemIndexes[i]], FindString) then
      begin
        Index:= i;
        exit;
      end;
  end;
end;

procedure TRSLodEdit.Delete2Click(Sender: TObject);
var i,j,k:int; s:string;
begin
  i:=ListView1.SelCount;
  if i=0 then exit;
  if i=1 then
    s:=Format(SDeleteQuestion, [SelCaption])
  else
    s:=SDeleteManyQuestion;
    
  if RSMessageBox(Handle, s, 'Confirmation', MB_OKCANCEL or MB_ICONQUESTION)
      <> mrOk then
    exit;

  if FileType = aVideo then
    FreeVideo;

  with ListView1.Items do
    for i:=Count-1 downto 0 do
      if Item[i].Selected then
      begin
        Item[i].Selected:=false;
        k:= ItemIndexes[i];
        Archive.BackupFile(k, false);
        Archive.RawFiles.Delete(k);

        ArrayDelete(ArchiveIndexes, k, 4);
        SetLength(ArchiveIndexes, high(ArchiveIndexes));
        for j:= 0 to high(ArchiveIndexes) do
          if ArchiveIndexes[j] > i then
            dec(ArchiveIndexes[j]);

        ArrayDelete(ItemIndexes, i, 4);
        SetLength(ItemIndexes, high(ItemIndexes));
        for j:= 0 to high(ItemIndexes) do
          if ItemIndexes[j] > k then
            dec(ItemIndexes[j]);

        ArrayDelete(ItemCaptions, i, 4);
        SetLength(ItemCaptions, high(ItemCaptions));

        Count:= Count - 1;
        if i < LastSel then
          dec(LastSel);
      end;

  ListView_SetItemState(ListView1.Handle, LastSel,
     LVIS_SELECTED or LVIS_FOCUSED, LVIS_SELECTED or LVIS_FOCUSED);
  ListView1.Invalidate;
end;

function TRSLodEdit.DialogToFolder(dlg: TOpenDialog): string;
begin
  Result:= ExtractFilePath(dlg.FileName);
  if Result = '' then
    Result:= dlg.InitialDir;
end;

procedure TRSLodEdit.DoExtract(Choose:boolean);
var
  a: TStream;
  s, s1, err: string;
  i, j: int;
begin
  j:=ListView1.SelCount;
  if j=0 then
    exit;

  if Choose or (ExtractPath = '') then
  begin
    if j=1 then
      s:= ExtractPath + Archive.GetExtractName(ItemIndexes[LastSel])
    else
      s:= ExtractPath + 'Extract Here';

    SaveDialogExport.FileName:= s;
    if not SaveDialogExport.Execute then  exit;
    s:= SaveDialogExport.FileName;
    ExtractPath:= ExtractFilePath(s);
    RSCreateDir(ExtractPath);
    if j<>1 then
      s:='';
  end else
    s:='';

  s1:= '';
  with ListView1, Items do
    for i:=0 to Count-1 do
      if Item[i].Selected then
      try
        s1:= Archive.Names[ItemIndexes[i]];
        if s <> '' then
        begin
          a:= TRSFileStreamProxy.Create(s, fmCreate);
          try
            Archive.Extract(ItemIndexes[i], a);
          finally
            s:='';
            a.Free;
          end;
        end else
          Archive.Extract(ItemIndexes[i], ExtractPath);
      except
        on e: Exception do
        begin
          s:='';
          if j<>1 then
            err:= err + s1 + ' : ' + e.Message + #13#10
          else
            raise;
        end;
      end;

  if err <> '' then
    RSMessageBox(Handle, err, '', MB_ICONERROR);
end;

procedure TRSLodEdit.Extract1Click(Sender: TObject);
begin
  DoExtract(false);
end;

procedure TRSLodEdit.ExtractTo1Click(Sender: TObject);
begin
  DoExtract(true);
end;

procedure TRSLodEdit.ExtSort;
var
  i: int;
begin
  if length(ItemIndexes) <= 1 then  exit;
  ExtQSort(0, high(ItemIndexes));
  for i := 0 to high(ItemIndexes) do
    ArchiveIndexes[ItemIndexes[i]]:= i;
end;

procedure TRSLodEdit.ExtQSort(L, R: int);

  function FindExt(const s: string): PChar;
  var
    i: int;
  begin
    for i := length(s) downto 1 do
      if s[i] = '.' then
      begin
        Result:= @s[i];
        exit;
      end;
    Result:= '';
  end;

  function CompareExt(const s1, s2: string): int;
  begin
    Result:= RSLodCompareStr(FindExt(s1), FindExt(s2));
    if Result = 0 then
      Result:= RSLodCompareStr(PChar(s1), PChar(s2));
  end;

var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while CompareExt(ItemCaptions[I], ItemCaptions[P]) < 0 do  Inc(I);
      while CompareExt(ItemCaptions[J], ItemCaptions[P]) > 0 do  Dec(J);
      if I <= J then
      begin
        //ExchangeItems(I, J);
        zSwap(ItemCaptions[I], ItemCaptions[J]);
        zSwap(ItemIndexes[I], ItemIndexes[J]);

        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then  ExtQSort(L, J);
    L := I;
  until I >= R;
end;

procedure TRSLodEdit.DoAdd(Files:TStrings);
var
  WasAdded, WasPlaying: Boolean;

  procedure Added(i:int);
  begin
    WasAdded:= true;
    DefaultSel:= Archive.RawFiles.Name[i];
  end;

var
  i:int; s:string; b:TBitmap;
  err: string;
begin
  WasPlaying:= (FileType = aVideo) and (Timer1.Interval <> 0);
  FreeVideo;
  for i:= 0 to Files.Count-1 do
    try
      s:= Files[i];
      if (Archive is TRSLod) and (TRSLod(Archive).Version = RSLodHeroes) and
         (SameText(ExtractFileExt(s), '.pcx')) then
      begin
        b:= TJvPcx.Create;
        try
          b.LoadFromFile(s);
          Added(TRSLod(Archive).Add(ExtractFileName(s), b));
        finally
          b.Free;
        end;
      end else
        Added(Archive.Add(s));

{
      if SameText(s1, '.def') then
      begin
        df:=TRSDefWrapper.Create(RSLoadFile(s));
        with df do
          try
            s:= ExtractFileName(s);
            Added(Lod.Add(Data, s), s);
            if MakeMasks<>0 then
            begin
              // !! if MakeMasks=-1 then (dialog)
              SetLength(a, SizeOf(TMsk));
              RSMakeMsk(df, PMsk(a)^);
              s:= ChangeFileExt(s, '.msk');
              Added(Lod.Add(a, s), s);
              s:= ChangeFileExt(s, '.msg');
              Added(Lod.Add(a, s), s);
            end;
          finally
            Free;
          end;
        goto CaseEnd;
      end;

      }
    except
      on e:Exception do
      begin
        if Files.Count > 1 then
          err:= err + ExtractFileName(Files[i]) + ' : ' + e.Message + #13#10
        else
          raise;
      end;
    end;

  if err <> '' then
    RSMessageBox(Handle, err, '', MB_ICONERROR);

  if WasAdded then
    EndLoad
  else if WasPlaying then
    PlayVideo;
end;

procedure TRSLodEdit.Panel1Paint(Sender: TRSCustomControl;
  State: TRSControlState; DefaultPaint: TRSProcedure);
begin
  with Sender, Canvas do
  begin
    Brush.Color:=clBtnFace;
    if RSMemo1.Visible and not ThemeServices.ThemesEnabled then
      Pen.Color:=clBtnShadow
    else
      Pen.Color:=clBtnFace;
    Rectangle(0, 0, Width, Height);  
    {
    with ThemeServices do
      if ThemesEnabled then
      begin
        a.Element:=teListView;
        a.Part:=0;
        a.State:=0;
        DrawEdge(Handle, a, Rect(0,0,Width,Height), EDGE_SUNKEN, BF_SOFT or BF_FLAT or BF_TOPLEFT or BF_BOTTOMRIGHT);
      end else
    }
    //    FrameRect(Rect(0,0,Width,Height));
    //Pen.Color:=c
  end;
end;

procedure TRSLodEdit.PopupMenu2Popup(Sender: TObject);
begin
  if ListView1.SelCount=1 then
    ExtractTo1.Caption:=SExtractAs
  else
    ExtractTo1.Caption:=SExtractTo;
end;

procedure TRSLodEdit.Edit1Click(Sender: TObject);
var b:Boolean;
begin
  if ListView1.SelCount=1 then
    ExtractTo2.Caption:=SExtractAs
  else
    ExtractTo2.Caption:=SExtractTo;
  b:= ListView1.SelCount<>0;
  Extract2.Enabled:= b;
  ExtractTo2.Enabled:= b;
  Delete3.Enabled:= b;
  AddtoFavorites2.Enabled:= b;
end;

procedure TRSLodEdit.TrackBar1AdjustClickRect(Sender: TRSTrackBar;
  var r: TRect);
begin
  dec(r.Top, 5);
end;

procedure TRSLodEdit.ListView1WndProc(Sender: TObject; var Msg: TMessage;
  var Handled: Boolean; const NextWndProc: TWndMethod);
//var k:DWord; s:string;
begin
(*
  if Msg.Msg=CN_NOTIFY then
    with TWMNotify(Msg).NMHdr^, PNMListView(TWMNotify(Msg).NMHdr)^ do
      if (code = LVN_ITEMCHANGED) and (uChanged = LVIF_STATE) and (iItem>=0) then
      begin
        if (uOldState and (LVNI_FOCUSED + LVNI_SELECTED) = 0) and
           (uNewState and (LVNI_FOCUSED + LVNI_SELECTED) = LVNI_FOCUSED) then
        begin
          ListView1SelectItem(ListView1, ListView1.Items[iItem], true);
        end;
        {
        msgz(uOldState);
        msgz(uNewState);
        }
      end;
*)

   // !!! Ровно на 100-м KEYDOWN с шифтом затыкается

{
  if Msg.Msg=WM_KEYDOWN then
  begin

    s:=SelCaption;

 //k:=GetTickCount;

  //if (s='ArC_SeOr.pcx') then msgz(LastSel);

{
    if LastSel=99 then
    begin
      Msg.Msg:=WM_KEYUP;
      NextWndProc(Msg);
      Msg.Msg:=WM_KEYDOWN;
    end;
}
//    if LastSel=99 then msgh(Msg.lParam);
//    if LastSel>=99 then Msg.lParamLo:=LastSel;

{
    Handled:=true;
    NextWndProc(Msg);
}
 //if (GetTickCount-k>100) and (s='ArC_SeOr.pcx') then  zD;
//  end;
 {
 WM_KEYDOWN

 k:=GetTickCount;
  Handled:=true;
  NextWndProc(Msg);
 if GetTickCount-k>100 then  // zD;
 begin
   msgh(Msg.Msg);
 end;
 }
end;

procedure TRSLodEdit.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TRSLodEdit.TreeTimer1Timer(Sender: TObject);
const
  Step=20;
var p:TPoint;
begin
  if DragNode=nil then  exit;
  p:=Treeview1.ScreenToClient(Mouse.CursorPos);
  if p.Y>TreeView1.Height then
    dec(p.Y, TreeView1.Height-1)
  else
    if p.Y>=0 then  exit;

  if p.Y>0 then
    TreeView1.Perform(WM_VSCROLL, SB_LINEDOWN, 0)
  else
    TreeView1.Perform(WM_VSCROLL, SB_LINEUP, 0);

  TreeTimer1.Interval:=max(10, round(100*Step/(abs(p.Y) + Step)));
end;

procedure TRSLodEdit.TreeView1EndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  DragNode:=nil;
  TreeTimer1.Interval:=0;
end;

procedure TRSLodEdit.PopupMenu1Popup(Sender: TObject);
var i:int;
begin
  i:=TreeView1.SelectionCount;
  if TreeView1.Items[0].Selected then
    dec(i);
  Cut1.Enabled:= i<>0;
  Copy1.Enabled:= i<>0;
  Paste1.Enabled:= i<>0;
  Delete1.Enabled:= i<>0;
  Rename1.Enabled:= i<>0;
end;

procedure TRSLodEdit.PopupMenu1AfterPopup(Sender: TObject);
var i:int;
begin
  with Sender as TPopupMenu, Items do
    for i:=0 to Count-1 do
      Items[i].Enabled:=true;
end;

procedure TRSLodEdit.Default1Click(Sender: TObject);
begin
  if Sender = FirstKind1 then
    FSFTKind:= 1
  else if Sender = SecondKind1 then
    FSFTKind:= 2
  else if Sender = ThirdKind1 then
    FSFTKind:= 3
  else
    FSFTKind:= 0;

  if (Image1.Visible) and (Image1.Picture.Bitmap.Height <> 0) then
    LoadFile(LastSel);
end;

procedure TRSLodEdit.DefaultPalette1Click(Sender: TObject);
begin
  if Def<>nil then
  begin
    Def.RebuildPal;
    TrackBar1Change(nil);
  end;
end;

function TRSLodEdit.DefFilterProc(Sender: TRSLodEdit; i: int;
  var Str: string): Boolean;
var
  a, c: TStream;
  b: Byte;
begin
  Result:= false;
  if not SameText(ExtractFileExt(Str), '.def') then
  begin
    Result:= (FDefFilter in [$43, $44]) and (SameText(ExtractFileExt(Str), '.msk')
                                              or SameText(ExtractFileExt(Str), '.msg'));
    exit;
  end;

  with Archive.RawFiles do
  begin
    if Size[i] = 0 then  exit;
    c:= nil;
    a:= GetAsIsFileStream(i, true);
    try
      if IsPacked[i] then
      begin
        c:= TDecompressionStream.Create(a);
        c.ReadBuffer(b, 1);
      end else
        a.ReadBuffer(b, 1);
    finally
      c.Free;
      FreeAsIsFileStream(i, a);
    end;
    Result:= b = FDefFilter;
  end;
end;

initialization
  RSLoadProc(@EnterReaderModeHelper, user32, 'EnterReaderModeHelper');

end.
