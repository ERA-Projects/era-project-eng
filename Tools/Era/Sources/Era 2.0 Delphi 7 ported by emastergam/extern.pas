UNIT Extern;
{
DESCRIPTION:  API Wrappers for plugins
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)

USES Utils, Core, GameExt, Heroes, Erm, Ini, Rainbow, Stores;


PROCEDURE FatalError (Err: PCHAR); STDCALL;
PROCEDURE RegisterHandler (Handler: TEventHandler; EventName: PCHAR); STDCALL;
PROCEDURE FireEvent (EventName: PCHAR; {n} EventData: POINTER; DataSize: INTEGER); STDCALL;
PROCEDURE ExecErmCmd (CmdStr: PCHAR); STDCALL;
PROCEDURE FireErmEvent (EventID: INTEGER); STDCALL;
PROCEDURE ClearIniCache (FileName: PCHAR);
FUNCTION  ReadStrFromIni (Key, SectionName, FilePath, Res: PCHAR): BOOLEAN; STDCALL;
FUNCTION  WriteStrToIni (Key, Value, SectionName, FilePath: PCHAR): BOOLEAN; STDCALL;
FUNCTION  SaveIni (FilePath: PCHAR): BOOLEAN; STDCALL;
PROCEDURE NameColor (Color32: INTEGER; Name: PCHAR); STDCALL;
PROCEDURE WriteSavegameSection (DataSize: INTEGER; {n} Data: POINTER; SectionName: PCHAR); STDCALL;

FUNCTION  ReadSavegameSection
(
      DataSize:     INTEGER;
  {n} Dest:         POINTER;
      SectionName:  PCHAR
): INTEGER; STDCALL;


EXPORTS
  Core.WriteAtCode,
  Core.Hook,
  Core.ApiHook,
  Core.KillThisProcess,
  Core.RecallAPI,
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
  Heroes.GetGameState;


(***) IMPLEMENTATION (***)


PROCEDURE NameColor (Color32: INTEGER; Name: PCHAR);
BEGIN
  Rainbow.NameColor(Color32, Name);
END; // .PROCEDURE NameColor

PROCEDURE ClearIniCache (FileName: PCHAR);
BEGIN
  Ini.ClearIniCache(FileName);
END; // .PROCEDURE ClearIniCache

FUNCTION ReadStrFromIni (Key, SectionName, FilePath, Res: PCHAR): BOOLEAN;
VAR
  ResStr: STRING;

BEGIN
  RESULT  :=  Ini.ReadStrFromIni(Key, SectionName, FilePath, ResStr);
  Utils.CopyMem(LENGTH(ResStr) + 1, PCHAR(ResStr), Res);
END; // .FUNCTION ReadStrFromIni

FUNCTION WriteStrToIni (Key, Value, SectionName, FilePath: PCHAR): BOOLEAN;
BEGIN
  RESULT  :=  Ini.WriteStrToIni(Key, Value, SectionName, FilePath);
END; // .FUNCTION WriteStrToIni

FUNCTION SaveIni (FilePath: PCHAR): BOOLEAN;
BEGIN
  RESULT  :=  Ini.SaveIni(FilePath);
END; // .FUNCTION SaveIni

PROCEDURE WriteSavegameSection (DataSize: INTEGER; {n} Data: POINTER; SectionName: PCHAR);
BEGIN
  Stores.WriteSavegameSection(DataSize, Data, SectionName);
END; // .PROCEDURE WriteSavegameSection

FUNCTION ReadSavegameSection (DataSize: INTEGER; {n} Dest: POINTER; SectionName: PCHAR): INTEGER;
BEGIN
  RESULT  :=  Stores.ReadSavegameSection(DataSize, Dest, SectionName);
END; // .FUNCTION ReadSavegameSection

PROCEDURE ExecErmCmd (CmdStr: PCHAR);
BEGIN
  Erm.ExecErmCmd(CmdStr);
END; // .PROCEDURE ExecErmCmd

PROCEDURE FireErmEvent (EventID: INTEGER);
BEGIN
  Erm.FireErmEvent(EventID);
END; // .PROCEDURE FireErmEvent

PROCEDURE RegisterHandler (Handler: TEventHandler; EventName: PCHAR);
BEGIN
  GameExt.RegisterHandler(Handler, EventName);
END; // .PROCEDURE RegisterHandler

PROCEDURE FireEvent (EventName: PCHAR; {n} EventData: POINTER; DataSize: INTEGER);
BEGIN
  GameExt.FireEvent(EventName, EventData, DataSize);
END; // .PROCEDURE FireEvent

PROCEDURE FatalError (Err: PCHAR);
BEGIN
  Core.FatalError(Err);
END; // .PROCEDURE FatalError

END.
