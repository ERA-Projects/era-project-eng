UNIT GameExt;
{
DESCRIPTION:  Game extension support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  Windows, SysUtils, Utils, Lists, CFiles, Files, Crypto, AssocArrays,
  Core;

CONST
  (* Pathes *)
  ERA_DLL_NAME  = 'era.dll';
  PLUGINS_PATH  = 'EraPlugins';
  PATCHES_PATH  = 'EraPlugins';
  
  CONST_STR = -1;
  
  NO_EVENT_DATA = NIL;


TYPE
  PPatchFile  = ^TPatchFile;
  TPatchFile  = PACKED RECORD (* FORMAT *)
    NumPatches: INTEGER;
    (*
    Patches:    ARRAY NumPatches OF TBinPatch;
    *)
    Patches:    Utils.TEmptyRec;
  END; // .RECORD TPatchFile

  PBinPatch = ^TBinPatch;
  TBinPatch = PACKED RECORD (* FORMAT *)
    Addr:     POINTER;
    NumBytes: INTEGER;
    (*
    Bytes:    ARRAY NumBytes OF BYTE;
    *)
    Bytes:    Utils.TEmptyRec;
  END; // .RECORD TBinPatch

  PEvent  = ^TEvent;
  TEvent  = PACKED RECORD
      Name:     STRING;
  {n} Data:     POINTER;
      DataSize: INTEGER;
  END; // .RECORD TEvent

  TEventHandler = PROCEDURE (Event: PEvent); STDCALL;
  
  PEraEventParams = ^TEraEventParams;
  TEraEventParams = ARRAY [0..15] OF INTEGER;


PROCEDURE RegisterHandler (Handler: TEventHandler; CONST EventName: STRING); STDCALL;
PROCEDURE FireEvent (CONST EventName: STRING; {n} EventData: POINTER; DataSize: INTEGER); STDCALL;
PROCEDURE Init (hDll: INTEGER);


VAR
{O} PluginsList:            Lists.TStringList {OF TDllHandle};
{O} Events:                 {O} AssocArrays.TAssocArray {OF Lists.TList};
    hAngel:                 INTEGER;  // Era 1.8x DLL
    hEra:                   INTEGER;  // Era 1.9+ DLL
    (* Compability with Era 1.8x *)
    EraInit:                Utils.TProcedure;
    EraSaveEventParams:     Utils.TProcedure;
    EraRestoreEventParams:  Utils.TProcedure;
{U} EraEventParams:         PEraEventParams;


(***) IMPLEMENTATION (***)


PROCEDURE LoadPlugins;
CONST
  ERM_V_1 = $887668;

VAR
{O} Locator:    Files.TFileLocator;
{O} ItemInfo:   Files.TFileItemInfo;
    DllName:    STRING;
    DllHandle:  INTEGER;
  
BEGIN
  Locator   :=  Files.TFileLocator.Create;
  ItemInfo  :=  NIL;
  // * * * * * //
  Locator.DirPath :=  PLUGINS_PATH;
  Locator.InitSearch('*.era');
  
  WHILE Locator.NotEnd DO BEGIN
    // Providing Era Handle in v1
    PINTEGER(ERM_V_1)^  :=  hEra;
    DllName             :=  SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(ItemInfo)));
    IF NOT ItemInfo.IsDir AND (SysUtils.ExtractFileExt(DllName) = '.era') THEN BEGIN
      DllHandle :=  Windows.LoadLibrary(PCHAR(PLUGINS_PATH + '\' + DllName));
      {!} ASSERT(DllHandle <> 0);
      Windows.DisableThreadLibraryCalls(DllHandle);
      PluginsList.AddObj(DllName, Ptr(DllHandle));
    END; // .IF
    
    SysUtils.FreeAndNil(ItemInfo);
  END; // .WHILE
  
  Locator.FinitSearch;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .PROCEDURE LoadPlugins

PROCEDURE ApplyBinPatch (CONST FilePath: STRING);
VAR
{U} Patch:      PBinPatch;
    FileData:   STRING;
    NumPatches: INTEGER;
    i:          INTEGER;  
  
BEGIN
  IF NOT Files.ReadFileContents(FilePath, FileData) THEN BEGIN
    Core.FatalError('Cannot open binary patch file "' + FilePath + '"');
  END // .IF
  ELSE BEGIN
    NumPatches  :=  PPatchFile(FileData).NumPatches;
    Patch       :=  @PPatchFile(FileData).Patches;
    TRY
      FOR i:=1 TO NumPatches DO BEGIN
        Core.WriteAtCode(Patch.NumBytes, @Patch.Bytes, Patch.Addr);
        Patch :=  Utils.PtrOfs(Patch, SIZEOF(Patch^) + Patch.NumBytes);
      END; // .FOR 
    EXCEPT
      Core.FatalError('Cannot apply binary patch file "' + FilePath + '"'#13#10'Access violation');
    END; // .TRY
  END; // .ELSE
END; // .PROCEDURE ApplyBinPatch

PROCEDURE ApplyPatches (CONST SubFolder: STRING);
VAR
{O} Locator:  Files.TFileLocator;
{O} ItemInfo: Files.TFileItemInfo;
    FileName: STRING;
  
BEGIN
  Locator   :=  Files.TFileLocator.Create;
  ItemInfo  :=  NIL;
  // * * * * * //
  Locator.DirPath :=  PATCHES_PATH + '\' + SubFolder;
  Locator.InitSearch('*.bin');
  
  WHILE Locator.NotEnd DO BEGIN
    FileName  :=  SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(ItemInfo)));
    IF NOT ItemInfo.IsDir AND (SysUtils.ExtractFileExt(FileName) = '.bin') THEN BEGIN
      ApplyBinPatch(Locator.DirPath + '\' + FileName);
    END; // .IF
    
    SysUtils.FreeAndNil(ItemInfo);
  END; // .WHILE
  
  Locator.FinitSearch;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .PROCEDURE ApplyPatches

PROCEDURE InitWoG; ASSEMBLER;
ASM
  MOV EAX, $70105A
  CALL EAX
  MOV EAX, $774483
  CALL EAX
  MOV ECX, $28AAFD0
  MOV EAX, $706CC0
  CALL EAX
  MOV EAX, $701215
  CALL EAX
END; // .PROCEDURE InitWoG

PROCEDURE RegisterHandler (Handler: TEventHandler; CONST EventName: STRING);
VAR
{U} Handlers: {U} Lists.TList {OF TEventHandler};
  
BEGIN
  {!} ASSERT(@Handler <> NIL);
  Handlers  :=  Events[EventName];
  // * * * * * //
  IF Handlers = NIL THEN BEGIN
    Handlers          :=  Lists.NewSimpleList;
    Events[EventName] :=  Handlers;
  END; // .IF
  
  Handlers.Add(@Handler);
END; // .PROCEDURE RegisterHandler

PROCEDURE FireEvent (CONST EventName: STRING; {n} EventData: POINTER; DataSize: INTEGER);
VAR
{O} Event:    PEvent;
{U} Handlers: {U} Lists.TList {OF TEventHandler};
    i:        INTEGER;

BEGIN
  {!} ASSERT(DataSize >= 0);
  {!} ASSERT((EventData <> NIL) OR (DataSize = 0));
  NEW(Event);
  Handlers  :=  Events[EventName];
  // * * * * * //
  Event.Name      :=  EventName;
  Event.Data      :=  EventData;
  Event.DataSize  :=  DataSize;
  
  IF Handlers <> NIL THEN BEGIN
    FOR i:=0 TO Handlers.Count - 1 DO BEGIN
      TEventHandler(Handlers[i])(Event);
    END; // .FOR
  END; // .IF
  // * * * * * //
  DISPOSE(Event);
END; // .PROCEDURE FireEvent

PROCEDURE Init (hDll: INTEGER);
BEGIN
  hEra  :=  hDll;
  Windows.DisableThreadLibraryCalls(hEra);
  
  FireEvent('OnEraStart', NO_EVENT_DATA, 0);
  
  (* Era 1.8x integration *)
  hAngel                :=  Windows.LoadLibrary('angel.dll');
  {!} ASSERT(hAngel <> 0);
  EraInit               :=  Windows.GetProcAddress(hAngel, 'InitEra');
  {!} ASSERT(@EraInit <> NIL);
  EraSaveEventParams    :=  Windows.GetProcAddress(hAngel, 'SaveEventParams');
  {!} ASSERT(@EraSaveEventParams <> NIL);
  EraRestoreEventParams :=  Windows.GetProcAddress(hAngel, 'RestoreEventParams');
  {!} ASSERT(@EraRestoreEventParams <> NIL);
  EraEventParams        :=  Windows.GetProcAddress(hAngel, 'EventParams');
  {!} ASSERT(EraEventParams <> NIL);
  
  LoadPlugins;
  FireEvent('OnBeforeWoG', NO_EVENT_DATA, 0);
  ApplyPatches('BeforeWoG');
  
  InitWoG;
  EraInit;
  
  FireEvent('OnAfterWoG', NO_EVENT_DATA, 0);
  ApplyPatches('AfterWoG');
END; // .PROCEDURE Init

BEGIN
  PluginsList :=  Lists.NewSimpleStrList;
  Events      :=  AssocArrays.NewStrictAssocArr(Lists.TList);
END.
