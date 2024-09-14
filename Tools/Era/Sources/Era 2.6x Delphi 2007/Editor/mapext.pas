unit MapExt;
{
DESCRIPTION:  Editor extension support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, Math, SysUtils, Utils, DataLib, Files, FilesEx, StrLib, Core, PatchApi, DlgMes,
  VFS, BinPatching;

const
  ERA_EDITOR_VERSION        = '2.6.0';
  DEBUG_DIR                 = 'Debug\EraEditor';
  DEBUG_MAPS_DIR            = 'DebugMaps';
  DEBUG_EVENT_LIST_PATH     = DEBUG_DIR + '\event list.txt';
  DEBUG_PATCH_LIST_PATH     = DEBUG_DIR + '\patch list.txt';
  DEBUG_MOD_LIST_PATH       = DEBUG_DIR + '\mod list.txt';
  DEBUG_X86_PATCH_LIST_PATH = DEBUG_DIR + '\x86 patches.txt';

  (* Pathes *)
  PLUGINS_PATH = 'EraEditor';
  PATCHES_PATH = 'EraEditor';


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


var
{O} PluginsList: DataLib.TStrList {OF TDllHandle};
{O} Events:      {O} DataLib.TDict {OF TEventInfo};
    hMe:         integer;
    GameDir:     string;


procedure AsmInit; assembler;
procedure GenerateDebugInfo;
procedure RegisterHandler (Handler: TEventHandler; const EventName: string); stdcall;
procedure FireEvent (const EventName: string; {n} EventData: pointer; DataSize: integer); stdcall;


(***) implementation (***)


destructor TEventInfo.Destroy;
begin
  FreeAndNil(fHandlers);
end;

procedure TEventInfo.AddHandler (Handler: pointer);
begin
  {!} Assert(Handler <> nil);
  if fHandlers = nil then begin
    fHandlers := DataLib.NewList(not Utils.OWNS_ITEMS);
  end; // .if

  fHandlers.Add(Handler);
end;

function TEventInfo.GetNumHandlers: integer;
begin
  if fHandlers = nil then begin
    result := 0;
  end else begin
    result := fHandlers.Count;
  end; // .else
end;

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

procedure LoadPlugins;
var
  DllHandle: THandle;

begin
  with Files.Locate(PLUGINS_PATH + '\*.dll', Files.ONLY_FILES) do begin
    while FindNext do begin
      if
        not FoundRec.IsDir                            and
        (SysUtils.ExtractFileExt(FoundName) = '.dll') and
        (FoundRec.Rec.Size > 0)
      then begin
        
        DllHandle := Windows.LoadLibrary(pchar(FoundPath));
        {!} Assert(DllHandle <> 0, 'Failed to load plugin DLL at "' + FoundPath + '"');
        Windows.DisableThreadLibraryCalls(DllHandle);
        PluginsList.AddObj(FoundPath, Ptr(DllHandle));
      end; // .if
    end; // .while
  end; // .with
end; // .procedure LoadPlugins

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
end;

procedure Init (hDll: integer);
const
  RDATA_SECTION_ADDR = Ptr($530000);
  RDATA_SECTION_SIZE = $4B000;

var
  Buffer:        string;
  OldProtection: integer;

begin
  hMe := hDll;
  Windows.DisableThreadLibraryCalls(hMe);
  Files.ForcePath(DEBUG_DIR);
  FireEvent('OnLoadSettings', nil, 0);
  VFS.Init;
  
  (* Restore default editor constant overwritten by "eramap.dll" *)
  Buffer := 'GetSpreadsheet';
  Core.WriteAtCode(Length(Buffer) + 1, pointer(Buffer), Ptr($596ED4));
  
  (* GrayFace mapedpatch requires .rdata section to have WRITE flag *)
  Windows.VirtualProtect
  (
    RDATA_SECTION_ADDR,
    RDATA_SECTION_SIZE,
    Windows.PAGE_EXECUTE_READWRITE,
    @OldProtection
  );

  FireEvent('OnInit', nil, 0);

  RegisterHandler(OnGenerateDebugInfo, 'OnGenerateDebugInfo');
  
  LoadPlugins;
  BinPatching.ApplyPatches(PATCHES_PATH);
end; // .procedure Init

procedure AsmInit; assembler;
asm
  (* Remove ret addr *)
  POP ECX
  
  CALL Init
  
  (* Default code *)
  PUSH EBP
  MOV EBP, ESP
  PUSH -1
  PUSH $54CA58
  PUSH $4EA77C
  PUSH [FS:0]
  
  (* Place new ret addr *)
  PUSH $4E84EA
  // RET
end; // .procedure AsmInit

begin
  GameDir     := SysUtils.GetCurrentDir;
  PluginsList := DataLib.NewStrList(not Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
  Events      := DataLib.NewDict(Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
  Core.SetDebugMapsDir(DEBUG_MAPS_DIR);
end.
