unit Common;

interface

uses
  Windows, Messages, SysUtils, SysConst, RSQ, RSSysUtils, Graphics, RSLang,
  RSDebug, Math, Clipbrd, Forms;

var
  ExceptionMapSaved: Boolean;

procedure MakeLog;
procedure MyShowException(ExceptObject:TObject; ExceptAddr:ptr; Soft:boolean);
procedure OnException(Soft:boolean);
procedure LogMessage(const s:string);
procedure DoPatch(p, Data:ptr; Size:int);
procedure BoolPatch(p, OldData, NewData:ptr; Size:int; New:boolean);
procedure DoHook(p:ptr; Size:int; HookProc:ptr);
procedure DoPatch1(p:ptr; Data:byte);
procedure DoPatch2(p:ptr; Data:word);
procedure DoPatch4(p:ptr; Data:dword);
procedure CallHook(p, Proc:ptr);

type
  TDefRec = packed record
    Chain: array[0..2] of int;
    Unk1: int; //0 or 30303000
    Str: PChar;
    StrLen: int; // 0c or 0b or 0a
    StrBufLen: int; // 1f
    Number: int; // Number in list
    Unk4:  int; // 0 or 1
    Unk5: int; // 0 or 30303030
    Unk6: int; // 31
    Unk7: int; // 31
  end;
  PDefRec = ^TDefRec;

  TObjectProps = packed record
    Def: int;                          // 00
    MaskEmpty: array[0..7] of Byte;    // 04
    MaskEnter: array[0..7] of Byte;    // 0C
    Land: int;                         // 14
    LandPage: int;                     // 18
    Typ: int;                          // 1C (Type is a reserved word)
    SubTyp: int;                       // 20
    Page: int;                         // 24
    Flat: byte;                        // 28
     // Enter stuff and something unknown
    HasEnter: byte;                    // 29
    Unk1: array[0..1] of byte;         // 2A
    EnterX: int;                       // 2C (Reversed) (counted from the right side)
    EnterY: int;                       // 30 (Reversed)
     // Info from .MSK:
    Width: int;                        // 34
    Height: int;                       // 38
    MaskObject: array[0..7] of byte;   // 3C
    MaskShadow: array[0..7] of byte;   // 44
  end;                                 // 4C
  PObjectProps = ^TObjectProps;

  TObjectData = packed record
    Chain: array[0..2] of ptr;
           // On adding: Point to a zeroed obj
           // On adding: Last
           // On adding: Point to a zeroed obj
    Props: TObjectProps;
    RefCount: int;
    Unk1: int;
  end;
  PObjectData = ^TObjectData;
  PPObjectData = ^PObjectData;

  TMonRec = packed record
    Town: int;
    Level: int;
    SoundName: PChar;
    DefName: PChar;
    Flags: int;
    Name: PChar;
    PluralName: PChar;
    Features: PChar; // e.g. Fearsome
    CostWood: int;
    CostMercury: int;
    CostOre: int;
    CostSulfor: int;
    CostCrystal: int;
    CostGems: int;
    CostGold: int;
    FightValue: int;
    AIValue: int;
    Growth: int;
    HordeGrowth: int;
    HitPoints: int;
    Speed: int;
    Attack: int;
    Defence: int;
    DamageLow: int;
    DamageHigh: int;
    Shots: int;
    Spells: int;
    AdvLow: int;  // ?
    AdvHigh: int; // ?
  end;
  PMonRec = ^TMonRec;

  TArtRec = packed record
    ArTraits: array[0..6] of DWord;
    CantAdd: byte;
    Unknown: array[0..2] of byte;
  end;
  PArtRec = ^TArtRec;

  TDwellRec = packed record
    Unknown: Dword;
    Name: PChar;
  end;
  PDwellRec = ^TDwellRec;

  TEventRec = packed record
    NameUnk1: int; // ???
    Name: PChar;
    NameLength: int;
    NameBufLen: int; // ($1F)
    MsgUnk1: int;  // ???
    Msg: PChar;
    MsgLength: int;
    MsgBufLen: int;  // ($1F)
    Resources: array[0..6] of int;
    Players:int;
    AllowHuman: byte;
    AllowComputer: byte;
    Unk1: word;    // Not 0 sometimes
    FirstDay: int; // First day -1
    Interval: int; // 0 for never
  end;
  PEventRec = ^TEventRec;

  TEventArr = array[0..MaxInt div SizeOf(TEventRec) - 1] of TEventRec;
  PEventArr = ^TEventArr;

  TCWnd = packed record
    ClassPtr: ptr;
    Unk1: array[1..$18] of byte;
    Wnd: TRSWnd;
  end;
  PCWnd = ^TCWnd;
  
  TToolbarPages = packed record
    ClassPtr: ptr;
    Unk1: array[1..$18] of byte;
    Wnd: TRSWnd;
    Unk2: array[1..$78] of byte;
    MainPage: int;
    ObjPage: int;
    GroundBrush: int;
    GroundType: int;
    RiverType: int;
    RoadType: int;
    EraserBrush: int;
    ObstacleBrush: int;
  end;
  PToolbarPages = ^TToolbarPages;

  TPaletteInfo = packed record
    Unk1: int; // 0
    Unk2: int; // 1
    Start: ptr; // Ptr to a list of ptrs on objects
    Stop: ptr;
    Unk3: ptr;
  end;

  PObjectPalette = ^TObjectPalette;
  TObjectPalette = packed record
    ClassPtr: ptr;
    Unk1: array[1..$18] of byte;
    Wnd: TRSWnd;
    Unk2: array[1..$7C] of byte;
    ObjCount: int; // Get only
    Unk3: array[1..$2C] of byte;
    Palette: int;
    PaletteInfos: array[0..14] of TPaletteInfo;
  end;

  TObjAdderVMT = packed record
    Unk: array[0..9] of ptr;
    AddObject: procedure(a1, a2:int; this:ptr; var Rect:TRect; Obj, MainMap: ptr);
  end;
  PObjAdderVMT = ^TObjAdderVMT;
  PPObjAdderVMT = ^PObjAdderVMT;

  PMainMap = ^TMainMap;
  TMainMap = packed record
    ClassPtr: ptr;                // 00
    Unk1: array[1..$18] of byte;  // 04
    Wnd: TRSWnd;                  // 1C
    Unk2: array[1..$20] of byte;  // 20
    ObjAdder: PPObjAdderVMT;      // 40
    ObjLoaderUnk: ptr;            // 44
    UndoBlock: ptr;               // 48
    Unk2b: int;                   // 4C
    IsUnderground: byte;          // 50
    Unk3: array[1..$3F] of byte;  // 51
    Unk3a: int;                   // 90
    Unk3b: int;                   // 94
    Unk4: array[1..$30] of byte;  // 98
    BrushType: int;               // C8 (0 - object, 1 - point, 2 - rect)
    Zoom: int;                    // CC
    Unk5: int;                    // D0
    SelObj: int;                  // D4
    Unk6: array[1..$24] of byte;  // D8
    SelX: int;                    // FC
    SelY: int;                    // 100
    SelDX: int;                   // 104
    SelDY: int;                   // 108
    Selection: TRect;             // 10C  Right = Left + Width - 1
  end;                            // 11C

  PMapScrollBar = ^TMapScrollBar;
  TMapScrollBar = packed record
    ClassPtr: ptr;
    Unk1: array[1..$18] of byte;
    Wnd: TRSWnd;
    Unk2: array[1..$20] of byte;
    Value: int;
    MaxValue: int;
    MaxValueClone: int;
  end;

  PFullMap = ^TFullMap;
  TFullMap = packed record
    ClassPtr: ptr;                // 00
    Unk1: array[1..$18] of byte;  // 04
    Wnd: TRSWnd;                  // 1C
    Unk2: array[1..$28] of byte;  // 20
    ScrollBarX: PMapScrollBar;    // 48
    ScrollBarY: PMapScrollBar;    // 4C
  end;

  TSeerAddCreature = packed record
    ClassPtr: ptr;
    Unk1: array[1..$18] of byte;
    Wnd: TRSWnd;
    Unk2: array[1..$30] of byte;
    CreaturesTab: PCWnd; // ListBox id = 1769
  end;

  PGroundSquareObjList = ^TGroundSquareObjList;
  TGroundSquareObjList = array[0..MaxInt div 8 - 1] of array[0..1] of int;

  PGroundSquareObjects = ^TGroundSquareObjects;
  TGroundSquareObjects = packed record
    RefCount: int;
    Unk2: ptr; // Almost always nil
    ListStart: ptr; // List Start
    ListEnd: ptr; // List End
    ListBufEnd: ptr; // List End 1 >= List End
    { List:
      array of
        case Object:
        (
          4 bytes - Object Number
          4 bytes - "Высота" клетки - расстояние до земли
                    0, если A part of ground
        )
        case Shadow:
        (
          4 bytes - Object Number
        )
      All in the draw order
    }
  end;

  PGroundSquare = ^TGroundSquare;
  TGroundSquare = packed record
    Bits: int;
    Objects: PGroundSquareObjects;
    Shadows: PGroundSquareObjects;
  end;

  PSurfaceSquares = ^TSurfaceSquares;
  TSurfaceSquares = packed record
    RefCount: int;
    Squares: array[0..5] of array[0..5] of TGroundSquare;
  end;

  TSurfaceSquaresArray = array[0..MaxInt div SizeOf(TSurfaceSquares) - 1] of PSurfaceSquares;

  PSurfaceData = ^TSurfaceData;
  TSurfaceData = packed record
    RefCount: int;
    LineLength: int;
    Unk2: ptr; // 0 or something in TObjectPalette object
    Data: ^TSurfaceSquaresArray;  // Data[((y div 6)*LineLength + (x div 6))]
    DataEnd: ptr;
    DataBufEnd: ptr;
  end;

  PMapObject = ^TMapObject;
  TMapObject = packed record // Подмешивается в AVTGUIGameObject
    ClassPtr: ptr;
    Data: PObjectData;
     // Class specific Data...
  end;

  TObjPtr = packed record
    RefCount: int;
    Unk1: int;
    Obj: PMapObject;
  end;
  PObjPtr = ^TObjPtr;

  TObjPos = packed record
    Unk1: int;     // 0
    ZOrder: int;   // 4
    x: int;        // 8
    y: int;        // C
    Obj: PObjPtr;  // 10
  end;             // 14
  PObjPos = ^TObjPos;

   // Starts with 5 integers of other nature
  TObjPositions = array[0..(MaxInt div 20)-1] of TObjPos;
  PObjPositions = ^TObjPositions;

  TObjectsData = packed record
    RefCount: int;
    Unk1: ptr;
    Positions: PObjPositions;
    PositionsEnd: ptr;
    PositionsBufferEnd: ptr;
  end;
  PObjectsData = ^TObjectsData;

  TGroundBlock = packed record
    RefCount: int;
    SizeIndex: int; // MapSizes[SizeIndex] is the size
    Data: PSurfaceData; // Ground
    Unk2: int;
    ObjData: PObjectsData;
    Unk3: int;
  end;
  PGroundBlock = ^TGroundBlock;

  TGroundBlocks = array[0..1] of PGroundBlock;
  PGroundBlocks = ^TGroundBlocks;

  TEventsBlock = packed record
    RefCount: int;
    Unk1: int;
    EventsArr: PEventArr;
    EventsArrEnd: ptr;
    EventsArrBufferEnd: ptr;
  end;
  PEventsBlock = ^TEventsBlock;

  TGameData = packed record
    RefCount: int;
    Unk1: int;
    Name: PChar;
    NameLength: int;
    NameUnk: int;
    Description: PChar;
    DescriptionLength: int;
    DescriptionUnk: int; // 1F
    Difficulty: int;
    ExpLimit: int;
    Unk2: array[1..$10] of byte;
    EventsBlock: PEventsBlock;
     // ... Size = $80
  end;
  PGameData = ^TGameData;

  PCountsBlock = ^TCountsBlock;
  TCountsBlock = packed record
    RefCount: int;
    Unk1: int;
    TownsCount: int;
    Unk3: int;
    GrailsCount: int;
    Unk4: int;
    List: ptr;    //  4C: Seers Count   54: Signs Count   5C: Mines Count
    ListEnd: ptr;
    ListBufEnd: ptr;
    Unk5: int;
    Unk6: int;
  end; // Size = $3C

  TUndoBlock = packed record
    RefCount: int;                // 00
    Unk1: int;                    // 04
    GameVersion: int;             // 08 (0 - RoE, 1 - SoD, 2 - WoG)
    Unk2: array[1..8] of byte;    // 0C
    GameData: PGameData;          // 14
    Unk3: int;                    // 18
    GroundBlock: PGroundBlocks;   // 1C
    GroundBlockEnd: ptr;          // 20
    GroundBlockBufferEnd: ptr;    // 24
    CountsBlock: PCountsBlock;    // 28
    Unk4: array[1..$24] of byte;  // 2C
  end;                            // 50
  PUndoBlock = ^TUndoBlock;
  PPUndoBlock = ^PUndoBlock;

  TMapProps = packed record
    ClassPtr: ptr;                // 00
    Unk1: array[1..$18] of byte;  // 04
    SmallFileName: PChar;         // 1C
    FileName: PChar;              // 20
    Unk2: array[1..$20] of byte;  // 24
    WasChanged: int;              // 44
    Unk3: array[1..$C] of byte;   // 48
    UndoBlock: PPUndoBlock;       // 54
    Unk4: array[1..$14] of byte;  // 58
    UndoList: ptr;                // 6C (0 if map wasn't changed)
    Unk5: array[1..$1C] of byte;  // 70
    UndoCount: int;               // 8C
    CurrentUndo: int;             // 90
    Unk6: array[1..$B8] of byte;  // 94
  end;                            // 14C
  PMapProps = ^TMapProps;

  PCMemFile = ^TCMemFile;
  TCMemFile = packed record
    Unk: array[1..$28] of byte;
  end;

  Pstreambuf = ^Tstreambuf;
  Tstreambuf = packed record
    Unk: array[1..$40] of byte;
  end;

  TPCharArray = array[0..(MaxInt div 4)-1] of PChar;
  PPCharArray = ^TPCharArray;

  TMyStringArray = array of string;

  TIntArray = array[0..(MaxInt div 4)-1] of int;
  PIntArray = ^TIntArray;

const
  ObjList = pint($5A33BC); ZeroObj = pptr($59F3C4);
  DefList = pint($5A32DC); DefCount = pint($5A32D4);
  DefListLast = ppptr($5A32E0); DefListEnd = ppptr($5A32E4);
  ZEditr = PPCharArray($5A1E38);
  GameVersions =  PIntArray($542460);

const
  _realloc: function(p:ptr; size:int):ptr cdecl = ptr($4E8C56);
  _malloc: function(size:int):ptr cdecl = ptr($4E814E);
  __msize: function(p:ptr):int cdecl = ptr($4E9B19);
  _free: procedure(p:ptr) cdecl = ptr($4E7888);
  _GetMem: function(p:ptr):ptr cdecl = ptr($504A8E); // A little wrapper around _malloc
  HwndToObj: function(h:hwnd):ptr stdcall = ptr($501463);
  _rand: function: int = ptr($4E7866);
  ___RTDynamicCast: function(Obj, Zero1, CastFrom, CastTo, Zero2:ptr):ptr cdecl = ptr($4E7392);

  _CMemFile_new: function(a1, a2:int; this:ptr; AllocSize:int = 4096):ptr = ptr($50F168);
  _CMemFile_Seek: function(a1, a2:int; this:ptr; Origin:int; Pos:int):int = ptr($50F3A2);
  _CMemFile_Free: procedure(a1, a2:int; this:ptr) = ptr($50F202);
  _streambuf_new: function(a1, a2:int; this:ptr; StreamFile:ptr):ptr = ptr($486885);
  _streambuf_Free: procedure(a1, a2:int; this:ptr) = ptr($48695C);
  _ReadObj: function(a1, a2:int; UndoBlock, ObjLoaderUnk, stream, objLink:ptr):ptr = ptr($429FB0);
  _FreeLoadedObj: procedure(a1, a2:int; objLink:ptr) = ptr($42BBEE);
  _WriteObj: procedure(stream:ptr; obj:PMapObject) cdecl = ptr($429622);
  _CreateObjectPrototype: function(var results; props: PObjectProps):ptr stdcall = ptr($442725);
  // AddObjectPrototype: 480B5B

  _MapProps_NewUndo: procedure(a1, a2:int; this:ptr) = ptr($45F580);

  _PlantObject: procedure(a1, a2:int; gb: ptr; objIndex: int; var pos; obj: PMapObject) = ptr($42A841);
  _UnplantObject: procedure(a1, a2:int; gb: ptr; objIndex: int) = ptr($42AD56);


  _TMainMap = ptr($53AD24);
  _TObjectPalette = ptr($5407DC);
  _TToolbarPages = ptr(5503968);
  _TFullMap = ptr($53AFB4);
  _TMiniMap = ptr($54002C);
  _TMapSpecGeneral = ptr($53B4A4);
  _TSeerAddCreature = ptr($533014);
  _TPage6 = ptr($540A6C);

  DecorFreq = pint($58C910); // Chance is Freq/16, cond: random(16)<DecorFreq
    // 0058E298 - Trackbar Pos

var
  EnterReaderModeHelper: function(Wnd: HWND): BOOL; stdcall;

var
  MonList: array of TMonRec;

  ArtCount: int;
  ArtList: array of TArtRec;

  DwellCount: int;
  DwellList: array of TDwellRec;

  BankList: array of PChar;
  ObjNames: array[0..255] of PChar;

  NewObjList: TMyStringArray;
  ChestsList: TMyStringArray;

  MainWindow: TRSWnd;
  MinimapWindow: TRSWnd;
  Page6Window: TRSWnd;
  ObjectPalette: PObjectPalette;
  ToolbarPages: PToolbarPages;
  MainMap: PMainMap;
  FullMap: PFullMap;

  EventsTemp: PEventArr;

  MapProps: PMapProps;

  LoadPic, SavePic, CopyPic, PastePic: TBitmap;

  SavingAdvancedProps: Boolean;

  SupressUndo: int;
    
procedure NeedObjNames;

function GroundBlock:PGroundBlocks;
function CurrentGroundBlock:PGroundBlock;

function MenuWindow:hwnd;

function EventsBlock:PEventArr;

function EventsBlockPtr:pptr;
function EventsBlockEndPtr:pptr;
function EventsBlockEndPtr1:pptr;

function GetGroundPtr(Blk:PGroundBlock; x,y:int):PGroundSquare;
  // Хранится кусками 6x6

    // Bits:
    // 4     Ground Type
    // 3     River Type
    // 3     Road Type
    // 8     Ground Subtype
    // 4     River Subtype
    // 4     Road Subtype
    // 6     Mirror:
    //    GroundH
    //    GroundV
    //    RiverH
    //    RiverV
    //    RoadH
    //    RoadV

const
  ShGroundType = 0;
  MskGroundType = (1 shl 4 - 1);
  ShRiverType = 4;
  MskRiverType = (1 shl 3 - 1) shl ShRiverType;
  ShRoadType = 7;
  MskRoadType = (1 shl 3 - 1) shl ShRoadType;
  ShGroundSubtype = 10;
  MskGroundSubtype = (1 shl 7 - 1) shl ShGroundSubtype;
  ShRiverSubtype = 17;
  MskRiverSubtype = (1 shl 4 - 1) shl ShRiverSubtype;
  ShRoadSubtype = 21;
  MskRoadSubtype = (1 shl 5 - 1) shl ShRoadSubtype;
  MirGroundH = $04000000;
  MirGroundV = $08000000;
  MirRiverH = $10000000;
  MirRiverV = $20000000;
  MirRoadH = $40000000;
  MirRoadV = int($80000000);


function RandomizeTile(Typ:int):int;

type
  TMapArray = array[0..255, 0..255] of int;
  PMapArray = ^TMapArray;

var
  SavedRoads:TMapArray;

procedure MapStore(Store:Boolean; Block:ptr; var OldMap:TMapArray; Mask:int = -1; MakeUniq:Boolean = false);

const
  SmoothingProc = pptr($53A72C);
  DefaultSmoothing = ptr($45E0A4);

procedure DoMapFillRect(var r:TRect);
procedure MapFillRect(var r:TRect; SaveRoads:Boolean);
procedure FillMap(SaveRoads:Boolean);
procedure SmoothMap(KeepUndo:Boolean = true);

function MapSize:int;
procedure InvalidateMap;
procedure InvalidateMiniMap;

function FilePath:string;

procedure SetDir(s:string);
procedure RestoreDir;


function NewCopy(Old:ptr; Size:int):ptr;

 // Blk.RefCount must be 1 (call Unique?? prior)
function EditGroundPtr(Blk:PGroundBlock; x,y:int):PGroundSquare;

procedure UniqueUndoBlock;
function UniqueGroundBlock(var Blk: PGroundBlock):PGroundBlock;
function UniqueSurfaceData(var Blk: PSurfaceData):PSurfaceData;
function UniqueSurfaceSquares(var Blk: PSurfaceSquares):PSurfaceSquares;
function UniqueObjectsData(var Blk: PObjectsData):PObjectsData;
function UniqueObjPtr(pos: PObjPos):PObjPtr;

procedure NewUndo;


const
  CmdProps = 32871;
  CmdHint = 32903;
  CmdSaveAs = 57604;
  CmdSave = word(-7933);
  CmdMapProps = word(-32729);
  CmdUndo = word(-7893);
  CmdRedo = word(-7892);
  CmdHelp = word(-7869);

  VerText = 'Patch Version 3.3.0.0';

var
  SWrong: string = 'H3WMAPED.exe file is invalid';
  SInvalid: string = '"%s" is invalid';
  SMiss: string = '"%s" not found';
  SMissIncorrect: string = '"%s" is missing or incorrect';
  SInvalidNumber: string = '"%s" is not a valid positive integer';

  SMenuAdvProps: string = 'Advanced Properties...';
  SMenuWogTools: string = 'WoG Tools';

//  SHelpAdvProps: string = 'Show Advanced Properties dialog box';

  SHelpFile: string;

  SExceptQuestion: string =
    #13#10+'Do you want to save the map before terminating?'+#13#10+
    '(Press Cancel to continue execution)';
  SUnbindAllQuestion: string = 'Are you sure you want to unbind all events?';

  SEditHighlight: string = 'Highlight';

  SSaveMapFilter: string = 'Heroes 3 WoG Map Files (*.h3m)|*.h3m|Heroes 3 SoD Map Files (*.h3m)|*.h3m|All Files (*.*)|*.*|';

  SValidationEnterOverlap: string = '"Enter overlap at (%d, %d, %d)."'#10'Entrance of one object is overlapped by another object. This usually causes bugs and even crashes in the game.'#10;

  PatchPath: string;

procedure msgze(s: string);
procedure msghe(i: int); overload;
procedure msghe(i: ptr); overload;

implementation

type
  TObjNamesItem = packed record
    Name: PChar;
    Index: int;
    Decorative: Bool;
    Unk1: int;
  end;
  PTObjNamesList = ^TObjNamesList;
  TObjNamesList = array[0..232] of TObjNamesItem;

const
  ObjNamesList = PTObjNamesList($599334);

procedure NeedObjNames;
var i:int;
begin
  for i:=0 to high(TObjNamesList) do
    ObjNames[i]:= ObjNamesList^[i].Name;

  if (ObjNames[217] = nil) or (ObjNames[217]^ = #0) then
    ObjNames[217]:= ObjNames[216];
  if (ObjNames[218] = nil) or (ObjNames[218]^ = #0) then
    ObjNames[218]:= ObjNames[216];
end;

function GroundBlock:PGroundBlocks;
begin
  Result:=MapProps.UndoBlock^^.GroundBlock;
end;

function CurrentGroundBlock:PGroundBlock;
begin
  Result:= GroundBlock^[MainMap^.IsUnderground];
end;

function MenuWindow:hwnd;
const MenuObj = pint($5A0D2C);
begin
  Result:=pint(MenuObj^+$1c)^;
end;

function EventsBlock:PEventArr;
begin
  Result:=MapProps.UndoBlock^.GameData.EventsBlock.EventsArr;
end;

function EventsBlockPtr:pptr;
begin
  Result:=@MapProps.UndoBlock^.GameData.EventsBlock.EventsArr;
end;

function EventsBlockEndPtr:pptr;
begin
  Result:=@MapProps.UndoBlock^.GameData.EventsBlock.EventsArrEnd;
end;

function EventsBlockEndPtr1:pptr;
begin
  Result:=@MapProps.UndoBlock^.GameData.EventsBlock.EventsArrBufferEnd;
end;

var GroundSquarePtr:ptr = ptr($42A453); // (ecx=Block, push y, push x)

function GetGroundPtr(Blk:PGroundBlock; x,y:int):PGroundSquare;
asm
  push y
  push x
  lea ecx, [Blk+4]
  call GroundSquarePtr
end;

const
  TilesDirtyCount = 16;
  TilesStart: array[0..9] of byte = (21, 0, 49, 49, 49, 49, 49, 49, 20, 0);
  TilesClearCount: array[0..9] of byte = (8, 8, 8, 8, 8, 8, 8, 8, 13, 8);

var
  HasDirtyTiles: array[0..9] of boolean; // = (1, 1, 1, 1, 1, 1, 1, 1, 0, 0);

function RandomizeTile(Typ:int):int;
begin
  if HasDirtyTiles[Typ] and (random(16)<DecorFreq^) then
    Result:= Random(TilesDirtyCount) + TilesStart[Typ] + TilesClearCount[Typ]
  else
    Result:= Random(TilesClearCount[Typ]) + TilesStart[Typ];
end;

var FillMapRectProc:int = $46F89F;

procedure DoMapFillRect(var r:TRect);
asm
  mov ecx, FullMap
  add ecx, $3C
  mov edx, [ecx + 4]
  push [edx + 88] // Preserve page
  mov [edx + 88], 1

  push eax
  push MainMap
  call FillMapRectProc

  mov ecx, FullMap // Restore page
  mov edx, [ecx + $40]
  pop [edx + 88]
end;

procedure MapFillRect(var r:TRect; SaveRoads:Boolean);
const
  Mask:int = MskRoadType or MskRoadSubtype or MskRiverType or MskRiverSubtype or
             MirRiverH or MirRiverV or MirRoadH or MirRoadV;
var p:ptr;
begin
  p:=SmoothingProc^;
  SmoothingProc^:=DefaultSmoothing;
  try
    if SaveRoads then
    begin
      MapStore(true, GroundBlock^[MainMap.IsUnderground], SavedRoads, Mask);
      DoMapFillRect(r);
      MapStore(false, GroundBlock^[MainMap.IsUnderground], SavedRoads, Mask);
    end else
      DoMapFillRect(r);
  finally
    SmoothingProc^:=p;
  end;
end;

procedure FillMap(SaveRoads:Boolean);
var r:TRect;
begin
  with r do
  begin
    Left:= 0;
    Top:= 0;
    Right:= MapSize;
    Bottom:= Right;
  end;

  MapFillRect(r, SaveRoads);
end;

{
var DoSmoothMap:int = $46F84F;

procedure SmoothMap;
asm
  mov ecx, FullMap
  add ecx, $3C
  push MainMap
  push MainMap
  call DoSmoothMap
end;
}

procedure SmoothMap(KeepUndo:Boolean = true);
var
  r: TRect;
begin
  with r do
  begin
    Left:=0;
    Top:=0;
    Right:=0;
    Bottom:=0;
  end;

  if not KeepUndo then
    try
      inc(SupressUndo);
      MapFillRect(r, false);
    finally
      dec(SupressUndo);
    end
  else
    MapFillRect(r, false);
end;

procedure MapStore(Store:Boolean; Block:ptr; var OldMap:TMapArray; Mask:int = -1; MakeUniq:Boolean = false);
var
  x, y, Size, v1:int; v:pint;
begin
  Size:=FullMap.ScrollBarX.MaxValue;
  for y:=0 to Size-1 do
    for x:=0 to Size-1 do
    begin
      v:= ptr(GetGroundPtr(Block, x, y));
      if not Store then
      begin
        v1:= (v^ and not Mask) or (OldMap[x,y] and Mask);
        if v1 <> v^ then
          if MakeUniq then
            EditGroundPtr(Block, x, y).Bits:= v1
          else
            v^:= v1;
      end else
        OldMap[x,y]:=v^;
  end;
end;

function MapSize:int;
begin
  Result:= FullMap.ScrollBarX.MaxValue;
end;

procedure InvalidateMap;
begin
  InvalidateRect(hwnd(MainMap.Wnd), nil, false);
end;

procedure InvalidateMiniMap;
begin
  InvalidateRect(hwnd(MinimapWindow), nil, false);
end;

function FilePath:string;
begin
  Result:=MapProps.FileName;
  if length(Result)=0 then
    Result:=AppPath+'Maps\'
  else
    Result:=ExtractFilePath(Result);
end;

var LastDir:string;

procedure SetDir(s:string);
begin
  LastDir:=GetCurrentDir;
  SetCurrentDir(s);
end;

procedure RestoreDir;
begin
  SetCurrentDir(LastDir);
end;

{==============================================================================}

function NewCopy(Old:ptr; Size:int):ptr;
begin
  Result:= _malloc(Size);
  CopyMemory(Result, Old, Size);
end;

{
procedure SingleSurfaceData(var New:PSurfaceData);
var
  Old:PSurfaceData; p, p1:^PSurfaceSquares;
begin
  Old:= New;
  if Old.RefCount<=1 then  exit;
  dec(Old.RefCount);
  New:= NewCopy(Old, SizeOf(TSurfaceData));
  New.RefCount:= 1;
  New.Data:= NewCopy(Old.Data, int(Old.DataBufEnd) - int(Old.Data));
  New.DataEnd:= ptr(int(Old.DataEnd) - int(Old.Data) + int(New.Data));
  New.DataBufEnd:= ptr(int(Old.DataBufEnd) - int(Old.Data) + int(New.Data));
  p:= ptr(New.Data);
  p1:= ptr(New.DataEnd);
  while p<>p1 do
  begin
    inc(p^.RefCount);
    inc(p);
  end;
end;

procedure SingleSurfaceSquares(var New: PSurfaceSquares);
var
  Old: PSurfaceSquares; x,y:int;
begin
  Old:= New;
  if Old.RefCount<=1 then  exit;
  dec(Old.RefCount);
  New:= NewCopy(Old, SizeOf(TSurfaceSquares));
  for y:=0 to 5 do
    for x:=0 to 5 do
    begin
      if New.Squares[y][x].Objects<>nil then
        inc(New.Squares[y][x].Objects.RefCount);
      if New.Squares[y][x].Shadows<>nil then
        inc(New.Squares[y][x].Shadows.RefCount);
    end;
end;

function EditGroundPtr(Blk:PGroundBlock; x,y:int):PGroundSquare;
var i:int;
begin
  SingleSurfaceData(Blk.Data);
  i:= (y div 6)*Blk.Data.LineLength + (x div 6);
  SingleSurfaceSquares(Blk.Data.Data[i]);
  Result:= @Blk.Data.Data[i].Squares[y mod 6][x mod 6];
end;
}

procedure UniqueUndoBlock;
const
  DoUnique: procedure(a1, a2:int; ppUndoBlock:ptr) = ptr($4327F3);
begin
  if MapProps.UndoBlock^.RefCount > 1 then
  begin
    DoUnique(0, 0, MapProps.UndoBlock);
    MapProps.UndoBlock^.RefCount:= 1;
  end;
end;

procedure NewUndo;
begin
  _MapProps_NewUndo(0, 0, MapProps);
  UniqueUndoBlock;
end;

function UniqueGroundBlock(var Blk:PGroundBlock):PGroundBlock;
const
  DoUnique: procedure(a1, a2:int; ppBlock:ptr) = ptr($432922);
begin
  if Blk.RefCount > 1 then
  begin
    DoUnique(0, 0, @Blk);
    Blk.RefCount:= 1;
  end;
  Result:= Blk;
end;

function UniqueSurfaceData(var Blk:PSurfaceData):PSurfaceData;
const
  DoUnique: procedure(a1, a2:int; ppBlock:ptr) = ptr($434665);
begin
  if Blk.RefCount > 1 then
  begin
    DoUnique(0, 0, @Blk);
    Blk.RefCount:= 1;
  end;
  Result:= Blk;
end;

function UniqueSurfaceSquares(var Blk:PSurfaceSquares):PSurfaceSquares;
const
  DoUnique: procedure(a1, a2:int; ppBlock:pptr) = ptr($434879);
begin
  if Blk.RefCount > 1 then
  begin
    DoUnique(0, 0, @Blk);
    Blk.RefCount:= 1;
  end;
  Result:= Blk;
end;

function EditGroundPtr(Blk:PGroundBlock; x,y:int):PGroundSquare;
var i:int;
begin
  UniqueSurfaceData(Blk.Data);
  i:= (y div 6)*Blk.Data.LineLength + (x div 6);
  Result:= @UniqueSurfaceSquares(Blk.Data.Data[i]).Squares[y mod 6][x mod 6];
end;

function UniqueObjectsData(var Blk: PObjectsData):PObjectsData;
const
  DoUnique: procedure(a1, a2:int; ppBlock:pptr) = ptr($434766);
begin
  if Blk.RefCount > 1 then
  begin
    DoUnique(0, 0, @Blk);
    Blk.RefCount:= 1;
  end;
  Result:= Blk;
end;

function UniqueObjPtr(pos: PObjPos):PObjPtr;
const
  DoUnique: procedure(a1, a2:int; pos:ptr) = ptr($42A389);
begin
  if (pos.Obj <> nil) and (pos.Obj.RefCount > 1) then
    DoUnique(0, 0, pos);

  Result:= pos.Obj;
end;

{==============================================================================}

procedure MakeLog;
const FileName='Data\MapEdPatchLogs\Log%d.txt';
var i:integer; s,s1:string;
begin
  i:=0;
  s1:=AppPath+FileName;
  s:=Format(s1, [i]);
  while FileExists(s) do
  begin
    inc(i);
    s:=Format(s1, [i]);
  end;
  RSSaveTextFile(s, RSLogExceptions);
end;

var
  LastException: PChar; BigErrorShown: Boolean;

procedure MyShowException(ExceptObject:TObject; ExceptAddr:ptr; Soft:boolean);
var
  Title: array[0..63] of Char;
  Buffer: array[0..1023] of Char;
begin
  ExceptionErrorMessage(ExceptObject, ExceptAddr, Buffer, SizeOf(Buffer));
  LoadString(FindResourceHInstance(HInstance),
    PResStringRec(@SExceptTitle).Identifier,
    Title, SizeOf(Title));

  if AnsiStrComp(LastException, @Buffer) = 0 then
  begin
    if BigErrorShown then
      exit;
    try
      BigErrorShown:=true;
      case MessageBox(0, PChar(Buffer+SExceptQuestion), Title,
                      MB_YESNOCANCEL or MB_ICONSTOP or MB_APPLMODAL) of
        IDYES:
        begin
          ExceptionMapSaved:=false;
          SendMessage(hwnd(MainWindow), WM_COMMAND, CmdSaveAs or (1 shl 16), 0);
          if ExceptionMapSaved then
            Halt;
        end;
        IDNO:
          Halt;
      end;
    finally
      BigErrorShown:=false;
    end;
  end else
    try
      LastException:=@Buffer;
      MessageBox(0, Buffer, Title, MB_OK or MB_ICONSTOP or MB_APPLMODAL);
    finally
      LastException:=nil;
    end;
end;

procedure OnException(Soft:boolean);
var o, p:pointer;
begin
  o:=ExceptObject;
  p:=ExceptAddr;
  try
    MakeLog;
  except
  end;
  MyShowException(o, p, Soft);
end;

procedure LogMessage(const s:string);
var i:int;
begin
  try
    raise Exception.Create(s);
  except
    i:= RSStackTraceOptions.StackFramesCount;
    RSStackTraceOptions.StackFramesCount:= MaxInt;
    MakeLog;
    RSStackTraceOptions.StackFramesCount:= i;
  end;
end;

procedure DoPatch(p, Data:ptr; Size:int);
var OldProtect:DWord;
begin
  Win32Check(VirtualProtect(p, Size, PAGE_EXECUTE_READWRITE, @OldProtect));
  CopyMemory(p, Data, Size);
  OldProtect:=OldProtect and not PAGE_GUARD;
  Win32Check(VirtualProtect(p, Size, OldProtect, @OldProtect));
end;

procedure BoolPatch(p, OldData, NewData:ptr; Size:int; New:boolean);
begin
  if New then
  begin
    Assert(CompareMem(p, OldData, Size), SWrong);
    DoPatch(p, NewData, Size);
  end else
  begin
    Assert(CompareMem(p, NewData, Size), SWrong);
    DoPatch(p, OldData, Size);
  end;
end;

procedure DoHook(p:ptr; Size:int; HookProc:ptr);
type
  THookRec = packed record
    Push:Byte;
    Ptr:Pointer;
    Ret:Byte;
  end;
  PHookRec = ^THookRec;
var OldProtect:DWord;
begin
  Win32Check(VirtualProtect(p, Size, PAGE_EXECUTE_READWRITE, @OldProtect));

  PHookRec(p).Push:=$68;
  PHookRec(p).Ptr:=HookProc;
  PHookRec(p).Ret:=$C3;
  FillMemory(PChar(p)+6, Size-6, $90);

  OldProtect:=OldProtect and not PAGE_GUARD;
  Win32Check(VirtualProtect(p, Size, OldProtect, @OldProtect));
end;

procedure DoPatch1(p:ptr; Data:byte);
var OldProtect:DWord;
begin
  Win32Check(VirtualProtect(p, 1, PAGE_EXECUTE_READWRITE, @OldProtect));
  PByte(p)^:=Data;
  OldProtect:=OldProtect and not PAGE_GUARD;
  Win32Check(VirtualProtect(p, 1, OldProtect, @OldProtect));
end;

procedure DoPatch2(p:ptr; Data:word);
var OldProtect:DWord;
begin
  Win32Check(VirtualProtect(p, 2, PAGE_EXECUTE_READWRITE, @OldProtect));
  PWord(p)^:=Data;
  OldProtect:=OldProtect and not PAGE_GUARD;
  Win32Check(VirtualProtect(p, 2, OldProtect, @OldProtect));
end;

procedure DoPatch4(p:ptr; Data:dword);
var OldProtect:DWord;
begin
  Win32Check(VirtualProtect(p, 4, PAGE_EXECUTE_READWRITE, @OldProtect));
  PDWord(p)^:=Data;
  OldProtect:=OldProtect and not PAGE_GUARD;
  Win32Check(VirtualProtect(p, 4, OldProtect, @OldProtect));
end;

procedure CallHook(p, Proc:ptr);
begin
  DoPatch4(p, int(Proc)-int(p)-4);
end;

procedure InitDirtyTiles;
var i:int;
begin
  for i:=0 to 7 do
    HasDirtyTiles[i]:=true;
  HasDirtyTiles[8]:=false;
  HasDirtyTiles[9]:=false;
end;


procedure msgze(s: string);
var i:HWND;
begin
  i:= Application.Handle;
  try
    Application.Handle:= 0;
    Clipboard.AsText:= s;
  finally
    Application.Handle:= i;
  end;
  msgz(s);
end;

procedure msghe(i: int); overload;
begin
  msgze(IntToHex(i, 0));
end;

procedure msghe(i: ptr); overload;
begin
  msghe(int(i));
end;

initialization
  InitDirtyTiles;
  SHelpFile:=AppPath+'H3WMapEdPatch.hlp';
  RSLoadProc(@EnterReaderModeHelper, user32, 'EnterReaderModeHelper');
  with RSLanguage.AddSection('[Common]', nil) do
  begin
    AddItem('Invalid exe', SWrong);
    AddItem('"%s" is invalid', SInvalid);
    AddItem('"%s" not found', SMiss);
    AddItem('"%s" is missing or incorrect', SMissIncorrect);
    AddItem('"%s" is not a valid positive integer', SInvalidNumber);
    AddItem('Advanced Properties Menu', SMenuAdvProps);
    AddItem('WoG Tools', SMenuWogTools);
    AddItem('Exception Question', SExceptQuestion);
    AddItem('Unbind All Question', SUnbindAllQuestion);
    AddItem('Save Map Filter', SSaveMapFilter);
    AddItem('Validation: Enter Overlap', SValidationEnterOverlap);
  end;
end.
