UNIT MapSettings;
{
DESCRIPTION:  Settings management
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  Utils, Log, Ini,
  VFS, EraLog;

CONST
  GAME_SETTINGS_FILE  = 'heroes3.ini';
  
  
TYPE
  TDebugDestination = (DEST_CONSOLE, DEST_FILE);


VAR
  DebugOpt: BOOLEAN;
  
  DebugDestination: TDebugDestination;
  DebugFile:        STRING;


(***) IMPLEMENTATION (***)


FUNCTION GetOptValue (CONST OptionName: STRING): STRING;
CONST
  ERA_SECTION = 'Era';

BEGIN
  IF
    NOT Ini.ReadStrFromIni(OptionName, ERA_SECTION, GAME_SETTINGS_FILE, RESULT)
  THEN BEGIN
    RESULT  :=  '';
  END; // .IF
END; // .FUNCTION GetOptValue

PROCEDURE LoadSettings;
BEGIN
  DebugOpt  :=  GetOptValue('Debug') = '1';

  IF DebugOpt THEN BEGIN
    IF GetOptValue('Debug.Destination') = 'File' THEN BEGIN
      DebugDestination  :=  DEST_FILE;
      DebugFile         :=  GetOptValue('Debug.File');
      
      Log.InstallLogger(EraLog.TFileLogger.Create(DebugFile), Log.FREE_OLD_LOGGER);
    END // .IF
    ELSE BEGIN
      DebugDestination  :=  DEST_CONSOLE;
      
      Log.InstallLogger(EraLog.TConsoleLogger.Create('Era Log'), Log.FREE_OLD_LOGGER);
    END; // .ELSE
  
    VFS.DebugOpt  :=  GetOptValue('Debug.VFS') = '1';
  END; // .IF
END; // .PROCEDURE LoadSettings

BEGIN
  LoadSettings;
END.
