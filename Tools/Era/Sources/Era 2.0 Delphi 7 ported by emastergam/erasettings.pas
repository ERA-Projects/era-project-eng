UNIT EraSettings;
{
DESCRIPTION:  Settings management
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  SysUtils, Utils, Log, Ini,
  VFS, Heroes, GameExt, EraLog, SndVid;

CONST
  ERA_VERSION = '2.0 beta 2 build 1';
  
  
(***) IMPLEMENTATION (***)


FUNCTION GetOptValue (CONST OptionName: STRING): STRING;
CONST
  ERA_SECTION = 'Era';

BEGIN
  IF
    NOT Ini.ReadStrFromIni(OptionName, ERA_SECTION, Heroes.GAME_SETTINGS_FILE, RESULT)
  THEN BEGIN
    RESULT  :=  '';
  END; // .IF
END; // .FUNCTION GetOptValue

PROCEDURE OnEraStart (Event: GameExt.PEvent); STDCALL;
VAR
  DebugOpt:   BOOLEAN;
  LoadCDOpt:  BOOLEAN;

BEGIN
  DebugOpt  :=  GetOptValue('Debug') = '1';
  
  IF DebugOpt THEN BEGIN
    IF GetOptValue('Debug.Destination') = 'File' THEN BEGIN
      Log.InstallLogger(EraLog.TFileLogger.Create(GetOptValue('Debug.File')), Log.FREE_OLD_LOGGER);
    END // .IF
    ELSE BEGIN     
      Log.InstallLogger(EraLog.TConsoleLogger.Create('Era Log'), Log.FREE_OLD_LOGGER);
    END; // .ELSE
  
    VFS.DebugOpt  :=  GetOptValue('Debug.VFS') = '1';
  END; // .IF
  
  Log.Write('Core', 'CheckVersion', 'Result: ' + ERA_VERSION);
  
  LoadCDOpt         :=  GetOptValue('LoadCD') = '1';
  SndVid.LoadCDOpt  :=  LoadCDOpt;
END; // .PROCEDURE OnEraStart

BEGIN
  GameExt.RegisterHandler(OnEraStart, 'OnEraStart');
END.
