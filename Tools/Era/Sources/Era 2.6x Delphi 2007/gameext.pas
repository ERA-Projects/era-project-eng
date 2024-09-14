unit GameExt;
{
DESCRIPTION:  Game extension support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, Math, SysUtils, PatchApi,
  Utils, DataLib, CFiles, Files, FilesEx, Crypto, StrLib, Core,
  VFS, BinPatching;

type
  (* Import *)
  TList       = DataLib.TList;
  TStringList = DataLib.TStrList;

const
  (* Paths *)
  PLUGINS_PATH              = 'EraPlugins';
  PATCHES_PATH              = 'EraPlugins';
  DEBUG_DIR                 = 'Debug\Era';
  DEBUG_MAPS_DIR            = 'DebugMaps';
  DEBUG_EVENT_LIST_PATH     = DEBUG_DIR + '\event list.txt';
  DEBUG_PATCH_LIST_PATH     = DEBUG_DIR + '\patch list.txt';
  DEBUG_MOD_LIST_PATH       = DEBUG_DIR + '\mod list.txt';
  DEBUG_X86_PATCH_LIST_PATH = DEBUG_DIR + '\x86 patches.txt';
  
  CONST_STR = -1;
  
  NO_EVENT_DATA = nil;
  
  ERA_VERSION_STR = '2.6.3';
  ERA_VERSION_INT = 2603;

type
  PEvent  = ^TEvent;
  TEvent  = packed record
      Name:     string;
  {n} Data:     pointer;
      DataSize: integer;
  end; // .record TEvent

  TEventHandler = procedure (Event: PEvent); stdcall;

  TEventInfo = class
   protected
    {On} fHandlers:      TList {of TEventHandler};
         fNumTimesFired: integer;

    function GetNumHandlers: integer;
   public
    destructor Destroy; override;

    procedure AddHandler (Handler: pointer);

    property Handlers:      {n} TList {of TEventHandler} read fHandlers;
    property NumHandlers:   integer                      read GetNumHandlers;
    property NumTimesFired: integer                      read fNumTimesFired write fNumTimesFired;
  end; // .class TEventInfo
  
  PEraEventParams = ^TEraEventParams;
  TEraEventParams = array [0..15] of integer;
  
  PMemRedirection = ^TMemRedirection;
  TMemRedirection = record
    OldAddr:    pointer;
    BlockSize:  integer;
    NewAddr:    pointer;
  end; // .record TMemRedirection


procedure RegisterHandler (Handler: TEventHandler; const EventName: string); stdcall;
procedure FireEvent (const EventName: string; {n} EventData: pointer; DataSize: integer); stdcall;
function  PatchExists (const PatchName: string): boolean; stdcall;
function  PluginExists (const PluginName: string): boolean; stdcall;
procedure RedirectMemoryBlock (OldAddr: pointer; BlockSize: integer; NewAddr: pointer); stdcall;
function  GetRealAddr (Addr: pointer): pointer; stdcall;
function  GetMapFolder: string; stdcall;
procedure SetMapFolder (const NewMapFolder: string);
function  GetMapResourcePath (const OrigResourcePath: string): string; stdcall;
procedure GenerateDebugInfo;


procedure Init (hDll: integer);


var
{O} PluginsList:            DataLib.TStrList {OF TDllHandle};
{O} Events:                 {O} DataLib.TDict {OF TEventInfo};
    hAngel:                 integer;  // Era 1.8x DLL
    hEra:                   integer;  // Era 1.9+ DLL
    (* Compability with Era 1.8x *)
    EraInit:                Utils.TProcedure;
    EraSaveEventParams:     Utils.TProcedure;
    EraRestoreEventParams:  Utils.TProcedure;
{U} EraEventParams:         PEraEventParams;

{O} MemRedirections:        {O} DataLib.TList {OF PMemRedirection};

  MapFolder: string = '';


(***) implementation (***)
uses Heroes;

destructor TEventInfo.Destroy;
begin
  FreeAndNil(fHandlers);
end; // .destructor TEventInfo.Destroy

procedure TEventInfo.AddHandler (Handler: pointer);
begin
  {!} Assert(Handler <> nil);
  if fHandlers = nil then begin
    fHandlers := DataLib.NewList(not Utils.OWNS_ITEMS);
  end; // .if

  fHandlers.Add(Handler);
end; // .procedure TEventInfo.AddHandler

function TEventInfo.GetNumHandlers: integer;
begin
  if fHandlers = nil then begin
    result := 0;
  end else begin
    result := fHandlers.Count;
  end; // .else
end; // .function TEventInfo.GetNumHandlers

procedure LoadPlugins;
const
  ERM_V_1 = $887668;

var
{O} Locator:    Files.TFileLocator;
{O} ItemInfo:   Files.TFileItemInfo;
    DllName:    string;
    DllHandle:  integer;
  
begin
  Locator  := Files.TFileLocator.Create;
  ItemInfo := nil;
  // * * * * * //
  Locator.DirPath := PLUGINS_PATH;
  Locator.InitSearch('*.era');
  
  while Locator.NotEnd do begin
    // Providing Era Handle in v1
    PINTEGER(ERM_V_1)^ := hEra;
    DllName            := SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(ItemInfo)));
    if
      not ItemInfo.IsDir                          and
      (SysUtils.ExtractFileExt(DllName) = '.era') and
      ItemInfo.HasKnownSize                       and
      (ItemInfo.FileSize > 0)
    then begin
      DllHandle := Windows.LoadLibrary(pchar(PLUGINS_PATH + '\' + DllName));
      {!} Assert(DllHandle <> 0, 'Failed to load DLL at "' + PLUGINS_PATH + '\' + DllName + '"');
      Windows.DisableThreadLibraryCalls(DllHandle);
      PluginsList.AddObj(DllName, Ptr(DllHandle));
    end; // .if
    
    SysUtils.FreeAndNil(ItemInfo);
  end; // .while
  
  Locator.FinitSearch;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
end; // .procedure LoadPlugins

procedure InitWoG; ASSEMBLER;
asm
  MOV EAX, $70105A
  CALL EAX
  MOV EAX, $774483
  CALL EAX
  MOV ECX, $28AAFD0
  MOV EAX, $706CC0
  CALL EAX
  MOV EAX, $701215
  CALL EAX
end; // .procedure InitWoG

procedure RegisterHandler (Handler: TEventHandler; const EventName: string);
var
{U} EventInfo: TEventInfo;
  
begin
  {!} Assert(@Handler <> nil);
  EventInfo := Events[EventName];
  // * * * * * //
  if EventInfo = nil then begin
    EventInfo         := TEventInfo.Create;
    Events[EventName] := EventInfo;
  end; // .if

  EventInfo.AddHandler(@Handler);
end; // .procedure RegisterHandler

procedure FireEvent (const EventName: string; {n} EventData: pointer; DataSize: integer);
var
    Event:     TEvent;
{U} EventInfo: TEventInfo;
    i:         integer;

begin
  {!} Assert(Utils.IsValidBuf(EventData, DataSize));
  EventInfo := Events[EventName];
  // * * * * * //
  Event.Name     := EventName;
  Event.Data     := EventData;
  Event.DataSize := DataSize;

  if EventInfo = nil then begin
    EventInfo         := TEventInfo.Create;
    Events[EventName] := EventInfo;
  end; // .if
  
  EventInfo.NumTimesFired := EventInfo.NumTimesFired + 1;

  if EventInfo.Handlers <> nil then begin
    for i := 0 to EventInfo.Handlers.Count - 1 do begin
      TEventHandler(EventInfo.Handlers[i])(@Event);
    end; // .for
  end; // .if
end; // .procedure FireEvent

function PatchExists (const PatchName: string): boolean;
var
  PatchInd: integer;

begin
  result := BinPatching.PatchList.Find(PatchName, PatchInd);
end; // .function PatchExists

function PluginExists (const PluginName: string): boolean;
var
  FileSize: integer;

begin
  result  :=
    (Files.GetFileSize(PLUGINS_PATH + '\' + PluginName + '.dll', FileSize) and (FileSize > 0))  or
    (Files.GetFileSize(PLUGINS_PATH + '\' + PluginName + '.era', FileSize) and (FileSize > 0));
end; // .function PluginExists

function CompareMemoryBlocks
(
  Addr1:  pointer;
  Size1:  integer;
  Addr2:  pointer;
  Size2:  integer
): integer;

begin
  {!} Assert(Size1 > 0);
  {!} Assert(Size2 > 0);
  if
    (
      Math.Max(cardinal(Addr1) + cardinal(Size1), cardinal(Addr2) + cardinal(Size2)) -
      Math.Min(cardinal(Addr1), cardinal(Addr2))
    ) < (cardinal(Size1) + cardinal(Size2))
  then begin
    result := 0;
  end // .if
  else if cardinal(Addr1) < cardinal(Addr2) then begin
    result := -1;
  end // .ELSEIF
  else begin
    result := +1;
  end; // .else
end; // .function CompareMemoryBlocks

function FindMemoryRedirection (Addr: pointer; Size: integer; out {i} BlockInd: integer): boolean;
var
{U} Redirection:    PMemRedirection;
    LeftInd:        integer;
    RightInd:       integer;
    ComparisonRes:  integer; 
  
begin
  {!} Assert(Size >= 0);
  Redirection := nil;
  
  // * * * * * //
  result   := false;
  LeftInd  := 0;
  RightInd := MemRedirections.Count - 1;
  
  while (LeftInd <= RightInd) and not result do begin
    BlockInd      := LeftInd + (RightInd - LeftInd) div 2;
    Redirection   := MemRedirections[BlockInd];
    ComparisonRes := CompareMemoryBlocks(Addr, Size, Redirection.OldAddr, Redirection.BlockSize);
    result        := ComparisonRes = 0;
    
    if ComparisonRes < 0 then begin
      RightInd := BlockInd - 1;
    end // .if
    else if ComparisonRes > 0 then begin
      LeftInd  := BlockInd + 1;
    end; // .ELSEIF
  end; // .while

  if not result then begin
    BlockInd := LeftInd;
  end; // .if
end; // .function FindMemoryRedirection

procedure RedirectMemoryBlock (OldAddr: pointer; BlockSize: integer; NewAddr: pointer);
var
{U} OldRedirection: PMemRedirection;
{O} NewRedirection: PMemRedirection;
    BlockInd:       integer;
   
begin
  {!} Assert(OldAddr <> nil);
  {!} Assert(BlockSize > 0);
  {!} Assert(NewAddr <> nil);
  OldRedirection := nil;
  NewRedirection := nil;
  // * * * * * //
  if not FindMemoryRedirection(OldAddr, BlockSize, BlockInd) then begin
    New(NewRedirection);
    NewRedirection.OldAddr   := OldAddr;
    NewRedirection.BlockSize := BlockSize;
    NewRedirection.NewAddr   := NewAddr;
    MemRedirections.Insert(NewRedirection, BlockInd); NewRedirection := nil;
  end // .if
  else begin
    OldRedirection := MemRedirections[BlockInd];
    Core.FatalError
    (
      'Cannot redirect block at address $' +
      SysUtils.Format('%x', [integer(OldAddr)]) +
      ' of size ' + SysUtils.IntToStr(BlockSize) +
      ' to address $' + SysUtils.Format('%x', [integer(NewAddr)]) +
      #13#10' because there already exists a redirection from address ' +
      SysUtils.Format('%x', [integer(OldRedirection.OldAddr)]) +
      ' of size ' + SysUtils.IntToStr(OldRedirection.BlockSize) +
      ' to address $' + SysUtils.Format('%x', [integer(OldRedirection.NewAddr)])
    );
  end; // .else
  // * * * * * //
  FreeMem(NewRedirection);
end; // .procedure RedirectMemoryBlock

function GetRealAddr (Addr: pointer): pointer;
var
{U} Redirection:  PMemRedirection;
    BlockInd:     integer;

begin
  Redirection := nil;
  // * * * * * //
  result := Addr;
  
  if FindMemoryRedirection(Addr, sizeof(byte), BlockInd) then begin
    Redirection := MemRedirections[BlockInd];
    result      := Utils.PtrOfs(Redirection.NewAddr, integer(Addr) - integer(Redirection.OldAddr));
  end; // .if
end; // .function GetRealAddr

function GetMapFolder: string;
begin
  if MapFolder = '' then begin
    if Heroes.IsCampaign then begin
      MapFolder := 'Maps\' + SysUtils.ChangeFileExt(Heroes.GetCampaignFileName, '')
                   + '_' + SysUtils.IntToStr(Heroes.GetCampaignMapInd);
    end // .if
    else begin
      MapFolder := 'Maps\' + SysUtils.ChangeFileExt(Heroes.GetMapFileName, '');
    end; // .else
  end; // .if
  
  result := MapFolder;
end; // .function GetMapFolder

procedure SetMapFolder (const NewMapFolder: string);
begin
  MapFolder := NewMapFolder;
end; // .procedure SetMapFolder

function GetMapResourcePath (const OrigResourcePath: string): string;
begin
  result := GetMapFolder + '\' + OrigResourcePath;
  
  if not SysUtils.FileExists(result) then begin
    result := OrigResourcePath;
  end; // .if
end; // .function GetMapResourcePath

procedure GenerateDebugInfo;
begin
  FireEvent('OnGenerateDebugInfo', nil, 0);
end; // .procedure GenerateDebugInfo

procedure DumpEventList;
var
{O} EventList: TStrList {of TEventInfo};
{U} EventInfo: TEventInfo;
    i, j:      integer;

begin
  EventList := nil;
  EventInfo := nil;
  // * * * * * //
  {!} Core.ModuleContext.Lock;

  with FilesEx.WriteFormattedOutput(DEBUG_EVENT_LIST_PATH) do begin
    Line('> Format: [Event name] ([Number of handlers], [Fired N times])');
    EmptyLine;

    EventList := DataLib.DictToStrList(Events, DataLib.CASE_INSENSITIVE);
    EventList.Sort;

    for i := 0 to EventList.Count - 1 do begin
      EventInfo := TEventInfo(EventList.Values[i]);
      Line(Format('%s (%d, %d)', [EventList[i], EventInfo.NumHandlers, EventInfo.NumTimesFired]));
    end; // .for

    EmptyLine; EmptyLine;
    Line('> Event handlers');
    EmptyLine;
    
    for i := 0 to EventList.Count - 1 do begin
      EventInfo := TEventInfo(EventList.Values[i]);
      
      if EventInfo.NumHandlers > 0 then begin
        Line(EventList[i] + ':');
      end; // .if
      
      Indent;

      for j := 0 to EventInfo.NumHandlers - 1 do begin
        Line(Core.ModuleContext.AddrToStr(EventInfo.Handlers[j]));
      end; // .for

      Unindent;
    end; // .for
  end; // .with

  {!} Core.ModuleContext.Unlock;
  // * * * * * //
  FreeAndNil(EventList);
end; // .procedure DumpEventList

procedure DumpPatchList;
var
  i: integer;

begin
  BinPatching.PatchList.Sort;

  with FilesEx.WriteFormattedOutput(DEBUG_PATCH_LIST_PATH) do begin
    Line('> Format: [Patch name] (Patch size)');
    EmptyLine;

    for i := 0 to BinPatching.PatchList.Count - 1 do begin
      Line(Format('%s (%d)', [BinPatching.PatchList[i], integer(BinPatching.PatchList.Values[i])]));
    end; // .for
  end; // .with
end; // .procedure DumpPatchList

procedure DumpModList;
begin
  Files.WriteFileContents(VFS.ModList.ToText(#13#10), DEBUG_MOD_LIST_PATH);
end;

procedure OnGenerateDebugInfo (Event: PEvent); stdcall;
begin
  DumpModList;
  DumpEventList;
  DumpPatchList;
  PatchApi.GetPatcher().SaveDump(DEBUG_X86_PATCH_LIST_PATH);
end; // .procedure OnGenerateDebugInfo

procedure Init (hDll: integer);
begin
  hEra := hDll;
  Windows.DisableThreadLibraryCalls(hEra);
  Files.ForcePath(DEBUG_DIR);
  
  FireEvent('OnEraStart', NO_EVENT_DATA, 0);
  VFS.Init;
  
  (* Era 1.8x integration *)
  hAngel                :=  Windows.LoadLibrary('angel.dll');
  {!} Assert(hAngel <> 0, 'Failed to load angel.dll');
  EraInit               :=  Windows.GetProcAddress(hAngel, 'InitEra');
  {!} Assert(@EraInit <> nil, 'Missing angel.dll:EraInit function');
  EraSaveEventParams    :=  Windows.GetProcAddress(hAngel, 'SaveEventParams');
  {!} Assert(@EraSaveEventParams <> nil, 'Missing angel.dll:SaveEventParams function');
  EraRestoreEventParams :=  Windows.GetProcAddress(hAngel, 'RestoreEventParams');
  {!} Assert(@EraRestoreEventParams <> nil, 'Missing angel.dll:RestoreEventParams function');
  EraEventParams        :=  Windows.GetProcAddress(hAngel, 'EventParams');
  {!} Assert(EraEventParams <> nil, 'Missing angel.dll:EventParams variable');
  
  LoadPlugins;
  FireEvent('OnBeforeWoG', NO_EVENT_DATA, 0);
  BinPatching.ApplyPatches(PATCHES_PATH + '\BeforeWoG');
  
  InitWoG;
  EraInit;
  
  FireEvent('OnAfterWoG', NO_EVENT_DATA, 0);
  BinPatching.ApplyPatches(PATCHES_PATH + '\AfterWoG');

  RegisterHandler(OnGenerateDebugInfo, 'OnGenerateDebugInfo');
end; // .procedure Init

begin
  PluginsList     := DataLib.NewStrList(not Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
  Events          := DataLib.NewDict(Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
  MemRedirections := DataLib.NewList(not Utils.OWNS_ITEMS);
  Core.SetDebugMapsDir(DEBUG_MAPS_DIR);
end.
