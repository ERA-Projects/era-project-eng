unit Era;
(*
  Description: Era SDK
  Author:      Alexander Shostak aka Berserker
*)

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}


(***)  interface  (***)


uses Windows;


const
  HOOKTYPE_BRIDGE = 0;
  HOOKTYPE_CALL   = 1;
  HOOKTYPE_JUMP   = 2;

type
  PHookContext = ^THookContext;
  THookContext = packed record
    EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: integer;
    RetAddr:                                pointer;
  end;

  THookHandler = function (Context: PHookContext): longbool; stdcall;

  PEvent = ^TEvent;
  TEvent = packed record
      Name:     pchar;
  {n} Data:     pointer;
      DataSize: integer;
  end;

  TEventHandler = procedure (Event: PEvent) stdcall;

  TPlugin = pointer;

  PErmVVars = ^TErmVVars;
  TErmVVars = array [1..10000] of integer;
  TErmZVar  = array [0..511] of char;
  PErmZVars = ^TErmZVars;
  TErmZVars = array [1..1000] of TErmZVar;
  PErmYVars = ^TErmYVars;
  TErmYVars = array [1..100] of integer;
  PErmXVars = ^TErmXVars;
  TErmXVars = array [1..16] of integer;
  PErmFlags = ^TErmFlags;
  TErmFlags = array [1..1000] of boolean;
  PErmEVars = ^TErmEVars;
  TErmEVars = array [1..100] of single;

  PGameState  = ^TGameState;
  TGameState  = packed record
    RootDlgId:    integer;
    CurrentDlgId: integer;
  end;

  TInt32Bool = integer; // 0 or 1

  (* Stubs *)
  PPcx16Item   = pointer;
  PBattleStack = pointer;

  PMultiPurposeDlgSetup = ^TMultiPurposeDlgSetup;
  TMultiPurposeDlgSetup = packed record
    Title:             pchar;                 // Top dialog title
    InputFieldLabel:   pchar;                 // If specified, user will be able to enter arbitrary text in input field
    ButtonsGroupLabel: pchar;                 // If specified, right buttons group will be displayed
    InputBuf:          pchar;                 // OUT. Field to write a pointer to a temporary buffer with user input. Copy this text to safe location immediately
    SelectedItem:      integer;               // OUT. Field to write selected item index to (0-3 for buttons, -1 for Cancel)
    ImagePaths:        array [0..3] of pchar; // All paths are relative to game root directory or custom absolute paths
    ImageHints:        array [0..3] of pchar;
    ButtonTexts:       array [0..3] of pchar;
    ButtonHints:       array [0..3] of pchar;
    ShowCancelBtn:     TInt32Bool;
  end;

  TIsCommanderIdFunc       = function (MonId: integer): TInt32Bool stdcall;
  TIsElixirOfLifeStackFunc = function (Stack: PBattleStack): TInt32Bool stdcall;
  TShowMultiPurposeDlgFunc = procedure (Setup: PMultiPurposeDlgSetup); stdcall;


{$IFDEF FPC}
var
(* WoG vars *)
  v: TErmVVars absolute $887668;
  z: TErmZVars absolute $9273E8;
  y: TErmYVars absolute $A48D80;
  x: TErmXVars absolute $91DA38;
  f: TErmFlags absolute $91F2E0;
  e: TErmEVars absolute $A48F18;
{$ELSE}
const
  (* WoG vars *)
  v:  PErmVVars = Ptr($887668);
  z:  PErmZVars = Ptr($9273E8);
  y:  PErmYVars = Ptr($A48D80);
  x:  PErmXVars = Ptr($91DA38);
  f:  PErmFlags = Ptr($91F2E0);
  e:  PErmEVars = Ptr($A48F18);
{$ENDIF}

var
{O} Plugin: TPlugin;


function  _Hook (Plugin: TPlugin; Addr: pointer; HandlerFunc: THookHandler; {n} AppliedPatch: ppointer = nil; MinCodeSize: integer = 0; HookType: integer = HOOKTYPE_BRIDGE): {n} pointer; stdcall; external 'era.dll' name 'Hook';
function  _Splice (Plugin: TPlugin; OrigFunc, HandlerFunc: pointer; CallingConv: integer; NumArgs: integer; {n} CustomParam: pinteger; {n} AppliedPatch: ppointer): pointer; stdcall; external 'era.dll' name 'Splice';
function  AllocErmFunc (FuncName: pchar; {i} out FuncId: integer): boolean; stdcall; external 'era.dll' name 'AllocErmFunc';
function  CreatePlugin (Name: pchar) : {On} TPlugin; stdcall; external 'era.dll' name 'CreatePlugin';
function  DecorateInt (Value: integer; Buf: pchar; IgnoreSmallNumbers: integer): integer; stdcall; external 'era.dll' name 'DecorateInt';
function  FindNextObject (ObjType, ObjSubtype: integer; var x, y, z: integer; Direction: integer): integer; stdcall; external 'era.dll' name 'FindNextObject';
function  FormatQuantity (Value: integer; Buf: pchar; BufSize: integer; MaxLen, MaxDigits: integer): integer; stdcall; external 'era.dll' name 'FormatQuantity';
function  GetAppliedPatchSize (AppliedPatch: pointer): integer; stdcall; external 'era.dll' name 'GetAppliedPatchSize';
function  GetArgXVars: PErmXVars; stdcall; external 'era.dll' name 'GetArgXVars';
function  GetAssocVarIntValue (const VarName: pchar): integer; stdcall; external 'era.dll' name 'GetAssocVarIntValue';
function  GetAssocVarStrValue (const VarName: pchar): {O} pchar; stdcall; external 'era.dll' name 'GetAssocVarStrValue';
function  GetButtonID (ButtonName: pchar): integer; stdcall; external 'era.dll' name 'GetButtonID';
function  GetEraRegistryIntValue (const Key: pchar): integer; stdcall; external 'era.dll' name 'GetEraRegistryIntValue';
function  GetEraRegistryStrValue (const Key: pchar): {O} pchar; stdcall; external 'era.dll' name 'GetEraRegistryStrValue';
function  GetProcessGuid: pchar; stdcall; external 'era.dll' name 'GetProcessGuid';
function  GetRealAddr (Addr: pointer): pointer; stdcall; external 'era.dll' name 'GetRealAddr';
function  GetRetXVars: PErmXVars; stdcall; external 'era.dll' name 'GetRetXVars';
function  GetTriggerReadableName (EventId: integer): {O} pchar; stdcall; external 'era.dll' name 'GetTriggerReadableName';
function  GetVersion: pchar; stdcall; external 'era.dll' name 'GetVersion';
function  GetVersionNum: integer; stdcall; external 'era.dll' name 'GetVersionNum';
function  Hash32 (Data: pchar; DataSize: integer): integer; stdcall; external 'era.dll' name 'Hash32';
function  IsCampaign: boolean; stdcall; external 'era.dll' name 'IsCampaign';
function  IsCommanderId (MonId: integer): boolean; stdcall; external 'era.dll' name 'IsCommanderId';
function  IsElixirOfLifeStack (Stack: PBattleStack): boolean; stdcall; external 'era.dll' name 'IsElixirOfLifeStack';
function  IsPatchOverwritten (AppliedPatch: pointer): boolean; stdcall; external 'era.dll' name 'IsPatchOverwritten';
function  LoadImageAsPcx16 (FilePath, PcxName: pchar; Width, Height, MaxWidth, MaxHeight, ResizeAlg: integer): {OU} PPcx16Item; stdcall; external 'era.dll' name 'LoadImageAsPcx16';
function  PatchExists (PatchName: pchar): boolean; stdcall; external 'era.dll' name 'PatchExists';
function  PcxPngExists (const PcxName: pchar): boolean; stdcall; external 'era.dll' name 'PcxPngExists';
function  PersistErmCmd (CmdStr: pchar): {n} pointer; stdcall; external 'era.dll' name 'PersistErmCmd';
function  PluginExists (PluginName: pchar): boolean; stdcall; external 'era.dll' name 'PluginExists';
function  RandomRangeWithFreeParam (MinValue, MaxValue, FreeParam: integer): integer; stdcall; external 'era.dll' name 'RandomRangeWithFreeParam';
function  ReadSavegameSection (DataSize: integer; {n} Dest: pointer; SectionName: pchar ): integer; stdcall; external 'era.dll' name 'ReadSavegameSection';
function  ReadStrFromIni (Key, SectionName, FilePath, Res: pchar): boolean; stdcall; external 'era.dll' name 'ReadStrFromIni';
function  SaveIni (FilePath: pchar): boolean; stdcall; external 'era.dll' name 'SaveIni';
function  SetIsCommanderIdFunc (NewImpl: TIsCommanderIdFunc): {n} TIsCommanderIdFunc; stdcall; external 'era.dll' name 'SetIsCommanderIdFunc';
function  SetIsElixirOfLifeStackFunc (NewImpl: TIsElixirOfLifeStackFunc): {n} TIsElixirOfLifeStackFunc; stdcall; external 'era.dll' name 'SetIsElixirOfLifeStackFunc';
function  SetLanguage (NewLanguage: pchar): boolean; stdcall; external 'era.dll' name 'SetLanguage';
function  SetMultiPurposeDlgHandler (NewImpl: TShowMultiPurposeDlgFunc): {n} TShowMultiPurposeDlgFunc; stdcall; external 'era.dll' name 'SetMultiPurposeDlgHandler';
function  SplitMix32 (var Seed: integer; MinValue, MaxValue: integer): integer; stdcall; external 'era.dll' name 'SplitMix32';
function  TakeScreenshot (FilePath: pchar; Quality: integer; Flags: integer): boolean; stdcall; external 'era.dll' name 'TakeScreenshot';
function  ToStaticStr ({n} Str: pchar): {n} pchar; stdcall; external 'era.dll' name 'ToStaticStr';
function  tr (const Key: pchar; const Params: array of pchar): pchar; stdcall; external 'era.dll' name 'tr';
function  trStatic (const Key: pchar): pchar; stdcall; external 'era.dll' name 'trStatic';
function  trTemp (const Key: pchar; const Params: array of pchar): pchar; stdcall; external 'era.dll' name 'trTemp';
function  WriteAtCode (Plugin: TPlugin; NumBytes: integer; {n} Src, {n} Dst: pointer): boolean; stdcall; external 'era.dll' name 'WriteAtCode';
function  WriteStrToIni (Key, Value, SectionName, FilePath: pchar): boolean; stdcall; external 'era.dll' name 'WriteStrToIni';
procedure ClearAllIniCache; external 'era.dll' name 'ClearAllIniCache';
procedure ClearIniCache (FileName: pchar); stdcall; external 'era.dll' name 'ClearIniCache';
procedure EmptyIniCache (const FileName: pchar); stdcall; external 'era.dll' name 'EmptyIniCache';
procedure ExecErmCmd (CmdStr: pchar); stdcall; external 'era.dll' name 'ExecErmCmd';
procedure ExecPersistedErmCmd (PersistedCmd: pointer); stdcall; external 'era.dll' name 'ExecPersistedErmCmd';
procedure ExtractErm; external 'era.dll' name 'ExtractErm';
procedure FastQuitToGameMenu (TargetScreen: integer); stdcall; external 'era.dll' name 'FastQuitToGameMenu';
procedure FatalError (Err: pchar); stdcall; external 'era.dll' name 'FatalError';
procedure FireErmEvent (EventID: integer); stdcall; external 'era.dll' name 'FireErmEvent';
procedure FireEvent (EventName: pchar; {n} EventData: pointer; DataSize: integer); stdcall; external 'era.dll' name 'FireEvent';
procedure FreeAppliedPatch ({O} AppliedPatch: pointer); stdcall; external 'era.dll' name 'FreeAppliedPatch';
procedure GenerateDebugInfo; external 'era.dll' name 'GenerateDebugInfo';
procedure GetCampaignFileName (Buf: pchar); stdcall; external 'era.dll' name 'GetCampaignFileName';
procedure GetGameState (var GameState: TGameState); stdcall; external 'era.dll' name 'GetGameState';
procedure GetMapFileName (Buf: pchar); stdcall; external 'era.dll' name 'GetMapFileName';
procedure GlobalRedirectFile (OldFileName, NewFileName: pchar); stdcall; external 'era.dll' name 'GlobalRedirectFile';
procedure MemFree ({On} Buf: pointer); stdcall; external 'era.dll' name 'MemFree';
procedure MergeIniWithDefault (TargetPath, SourcePath: pchar); stdcall; external 'era.dll' name 'MergeIniWithDefault';
procedure NameColor (Color32: integer; Name: pchar); stdcall; external 'era.dll' name 'NameColor';
procedure NameTrigger (TriggerId: integer; Name: pchar); stdcall; external 'era.dll' name 'NameTrigger';
procedure NotifyError (Err: pchar); stdcall; external 'era.dll' name 'NotifyError';
procedure RedirectFile (OldFileName, NewFileName: pchar); stdcall; external 'era.dll' name 'RedirectFile';
procedure RedirectMemoryBlock (OldAddr: pointer; BlockSize: integer; NewAddr: pointer); stdcall; external 'era.dll' name 'RedirectMemoryBlock';
procedure RegisterHandler (Handler: TEventHandler; EventName: pchar); stdcall; external 'era.dll' name 'RegisterHandler';
procedure ReloadErm; external 'era.dll' name 'ReloadErm';
procedure ReloadLanguageData; stdcall; external 'era.dll' name 'ReloadLanguageData';
procedure ReportPluginVersion (const VersionLine: pchar); stdcall; external 'era.dll' name 'ReportPluginVersion';
procedure RollbackAppliedPatch ({O} AppliedPatch: pointer); stdcall; external 'era.dll' name 'RollbackAppliedPatch';
procedure SetAssocVarIntValue (const VarName: pchar; NewValue: integer); stdcall; external 'era.dll' name 'SetAssocVarIntValue';
procedure SetAssocVarStrValue (const VarName, NewValue: pchar); stdcall; external 'era.dll' name 'SetAssocVarStrValue';
procedure SetEraRegistryIntValue (const Key: pchar; NewValue: integer); stdcall; external 'era.dll' name 'SetEraRegistryIntValue';
procedure SetEraRegistryStrValue (const Key: pchar; NewValue: pchar); stdcall; external 'era.dll' name 'SetEraRegistryStrValue';
procedure ShowErmError (Error: pchar); stdcall; external 'era.dll' name 'ShowErmError';
procedure ShowMessage (Mes: pchar); stdcall; external 'era.dll' name 'ShowMessage';
procedure ShowMultiPurposeDlg (Setup: PMultiPurposeDlgSetup); stdcall; external 'era.dll' name 'ShowMultiPurposeDlg';
procedure WriteSavegameSection (DataSize: integer; {n} Data: pointer; SectionName: pchar); stdcall; external 'era.dll' name 'WriteSavegameSection';


function Hook (Addr: pointer; HandlerFunc: THookHandler; {n} AppliedPatch: ppointer = nil; MinCodeSize: integer = 0; HookType: integer = HOOKTYPE_BRIDGE): {n} pointer;
function Splice (OrigFunc, HandlerFunc: pointer; CallingConv: integer; NumArgs: integer; {n} CustomParam: pinteger; {n} AppliedPatch: ppointer): pointer;


(***)  implementation  (***)


function GetModuleFileName (hMod: HMODULE): string;
const
  INITIAL_BUF_SIZE = 1000;

begin
  SetLength(result, INITIAL_BUF_SIZE);
  SetLength(result, Windows.GetModuleFileName(hMod, @result[1], Length(result)));

  if (Length(result) > INITIAL_BUF_SIZE) and
     (Windows.GetModuleFileName(hMod, @result[1], Length(result)) <> cardinal(Length(result)))
  then begin
    result := '';
  end;
end;

function Hook (Addr: pointer; HandlerFunc: THookHandler; {n} AppliedPatch: ppointer = nil; MinCodeSize: integer = 0; HookType: integer = HOOKTYPE_BRIDGE): {n} pointer;
begin
  result := _Hook(Plugin, Addr, @HandlerFunc, AppliedPatch, MinCodeSize, HookType);
end;

function Splice (OrigFunc, HandlerFunc: pointer; CallingConv: integer; NumArgs: integer; {n} CustomParam: pinteger; {n} AppliedPatch: ppointer): pointer;
begin
  result := _Splice(Plugin, OrigFunc, HandlerFunc, CallingConv, NumArgs, CustomParam, AppliedPatch);
end;

begin
  Plugin := CreatePlugin(pchar(GetModuleFileName(hInstance)));

  if Plugin = nil then begin
    FatalError(pchar('Duplicate registered plugin: ' + GetModuleFileName(hInstance)));
  end;
end.
