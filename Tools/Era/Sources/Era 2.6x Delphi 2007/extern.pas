unit Extern;
{
DESCRIPTION:  API Wrappers for plugins
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)

uses Utils, Core, GameExt, Heroes, Erm, Ini, Rainbow, Stores, EraButtons, Lodman;


procedure FatalError (Err: pchar); stdcall;
procedure RegisterHandler (Handler: TEventHandler; EventName: pchar); stdcall;
procedure FireEvent (EventName: pchar; {n} EventData: pointer; DataSize: integer); stdcall;
procedure ExecErmCmd (CmdStr: pchar); stdcall;
procedure FireErmEvent (EventID: integer); stdcall;
procedure ClearIniCache (FileName: pchar);
function  ReadStrFromIni (Key, SectionName, FilePath, Res: pchar): boolean; stdcall;
function  WriteStrToIni (Key, Value, SectionName, FilePath: pchar): boolean; stdcall;
function  SaveIni (FilePath: pchar): boolean; stdcall;
procedure NameColor (Color32: integer; Name: pchar); stdcall;
procedure WriteSavegameSection (DataSize: integer; {n} Data: pointer; SectionName: pchar); stdcall;

function  ReadSavegameSection
(
      DataSize:     integer;
  {n} Dest:         pointer;
      SectionName:  pchar
): integer; stdcall;

function  GetButtonID (ButtonName: pchar): integer; stdcall;
function  PatchExists (PatchName: pchar): boolean; stdcall;
function  PluginExists (PluginName: pchar): boolean; stdcall;
procedure RedirectFile (OldFileName, NewFileName: pchar); stdcall;
procedure GlobalRedirectFile (OldFileName, NewFileName: pchar); stdcall;


exports
  Core.WriteAtCode,
  Core.Hook,
  Core.ApiHook,
  Core.KillThisProcess,
  FatalError,
  RegisterHandler,
  FireEvent,
  Heroes.LoadTxt,
  Heroes.ForceTxtUnload,
  ExecErmCmd,
  Erm.ReloadErm,
  Erm.ExtractErm,
  FireErmEvent,
  Ini.ClearAllIniCache,
  ClearIniCache,
  ReadStrFromIni,
  WriteStrToIni,
  SaveIni,
  NameColor,
  WriteSavegameSection,
  ReadSavegameSection,
  Heroes.GetGameState,
  GetButtonID,
  PatchExists,
  PluginExists,
  RedirectFile,
  GlobalRedirectFile,
  GameExt.RedirectMemoryBlock,
  GameExt.GetRealAddr,
  GameExt.GenerateDebugInfo;


(***) implementation (***)


procedure NameColor (Color32: integer; Name: pchar);
begin
  Rainbow.NameColor(Color32, Name);
end; // .procedure NameColor

procedure ClearIniCache (FileName: pchar);
begin
  Ini.ClearIniCache(FileName);
end; // .procedure ClearIniCache

function ReadStrFromIni (Key, SectionName, FilePath, Res: pchar): boolean;
var
  ResStr: string;

begin
  result  :=  Ini.ReadStrFromIni(Key, SectionName, FilePath, ResStr);
  Utils.CopyMem(Length(ResStr) + 1, pchar(ResStr), Res);
end; // .function ReadStrFromIni

function WriteStrToIni (Key, Value, SectionName, FilePath: pchar): boolean;
begin
  result  :=  Ini.WriteStrToIni(Key, Value, SectionName, FilePath);
end; // .function WriteStrToIni

function SaveIni (FilePath: pchar): boolean;
begin
  result  :=  Ini.SaveIni(FilePath);
end; // .function SaveIni

procedure WriteSavegameSection (DataSize: integer; {n} Data: pointer; SectionName: pchar);
begin
  Stores.WriteSavegameSection(DataSize, Data, SectionName);
end; // .procedure WriteSavegameSection

function ReadSavegameSection (DataSize: integer; {n} Dest: pointer; SectionName: pchar): integer;
begin
  result  :=  Stores.ReadSavegameSection(DataSize, Dest, SectionName);
end; // .function ReadSavegameSection

procedure ExecErmCmd (CmdStr: pchar);
begin
  Erm.ExecErmCmd(CmdStr);
end; // .procedure ExecErmCmd

procedure FireErmEvent (EventID: integer);
begin
  Erm.FireErmEvent(EventID);
end; // .procedure FireErmEvent

procedure RegisterHandler (Handler: TEventHandler; EventName: pchar);
begin
  GameExt.RegisterHandler(Handler, EventName);
end; // .procedure RegisterHandler

procedure FireEvent (EventName: pchar; {n} EventData: pointer; DataSize: integer);
begin
  GameExt.FireEvent(EventName, EventData, DataSize);
end; // .procedure FireEvent

procedure FatalError (Err: pchar);
begin
  Core.FatalError(Err);
end; // .procedure FatalError

function GetButtonID (ButtonName: pchar): integer; stdcall;
begin
  result  :=  EraButtons.GetButtonID(ButtonName);
end; // .function GetButtonID

function PatchExists (PatchName: pchar): boolean;
begin
  result  :=  GameExt.PatchExists(PatchName);
end; // .function PatchExists

function PluginExists (PluginName: pchar): boolean;
begin
  result  :=  GameExt.PluginExists(PluginName);
end; // .function PluginExists

procedure RedirectFile (OldFileName, NewFileName: pchar);
begin
  Lodman.RedirectFile(OldFileName, NewFileName);
end; // .procedure RedirectFile

procedure GlobalRedirectFile (OldFileName, NewFileName: pchar);
begin
  Lodman.GlobalRedirectFile(OldFileName, NewFileName);
end; // .procedure GlobalRedirectFile

end.
