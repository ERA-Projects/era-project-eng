UNIT EraLog;
{
DESCRIPTION:  Logging support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES SysUtils, Utils, Files, ConsoleAPI, Log, StrLib;

TYPE
  TLogger = CLASS (Log.TLogger)
    FUNCTION  Read (OUT LogRec: TLogRec): BOOLEAN; OVERRIDE;
    FUNCTION  IsLocked: BOOLEAN; OVERRIDE;
    PROCEDURE Lock; OVERRIDE;
    PROCEDURE Unlock; OVERRIDE;
    FUNCTION  GetPos (OUT Pos: INTEGER): BOOLEAN; OVERRIDE;
    FUNCTION  Seek (NewPos: INTEGER): BOOLEAN; OVERRIDE;
    FUNCTION  GetCount (OUT Count: INTEGER): BOOLEAN; OVERRIDE;
  END; // .CLASS TLogger

  TConsoleLogger  = CLASS (TLogger)
    (***) PROTECTED (***)
      {O} fCon: ConsoleAPI.TConsole;
    
    (***) PUBLIC (***)
      CONSTRUCTOR Create (CONST Title: STRING);
      DESTRUCTOR  Destroy; OVERRIDE;
      
      FUNCTION  Write (CONST EventSource, Operation, Description: STRING): BOOLEAN; OVERRIDE;
  END; // .CLASS TConsoleLogger
  
  TFileLogger = CLASS (TLogger)
    (***) PROTECTED (***)
      {O} fFile:  Files.TFile;
      
    (***) PUBLIC (***)
      CONSTRUCTOR Create (CONST FilePath: STRING);
      
      FUNCTION  Write (CONST EventSource, Operation, Description: STRING): BOOLEAN; OVERRIDE;
  END; // .CLASS TFileLogger


(***) IMPLEMENTATION (***)


CONST
  BR                      = #13#10;
  RECORD_BEGIN_SEPARATOR  = '>> ';
  RECORD_END_SEPARATOR    = BR + BR;
  OPERATION_SEPARATOR     = ': ';
  DESCRIPTION_SEPARATOR   = BR;
  DESCR_LINES_PREFIX      = '   ';
  DESCR_LINES_GLUE        = BR + DESCR_LINES_PREFIX;


FUNCTION TLogger.Read (OUT LogRec: TLogRec): BOOLEAN;
BEGIN
  RESULT  :=  FALSE;
END; // .FUNCTION TLogger.Read

FUNCTION TLogger.IsLocked: BOOLEAN;
BEGIN
  RESULT  :=  FALSE;
END; // .FUNCTION TLogger.IsLocked

PROCEDURE TLogger.Lock;
BEGIN
END; // .PROCEDURE TLogger.Lock

PROCEDURE TLogger.Unlock;
BEGIN
END; // .PROCEDURE TLogger.Unlock

FUNCTION TLogger.GetPos (OUT Pos: INTEGER): BOOLEAN;
BEGIN
  Pos     :=  -1;
  RESULT  :=  FALSE;
END; // .FUNCTION TLogger.GetPos

FUNCTION TLogger.Seek (NewPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  FALSE;
END; // .FUNCTION TLogger.Seek

FUNCTION TLogger.GetCount (OUT Count: INTEGER): BOOLEAN;
BEGIN
  Count   :=  -1;
  RESULT  :=  FALSE;
END; // .FUNCTION TLogger.GetCount

CONSTRUCTOR TConsoleLogger.Create (CONST Title: STRING);
BEGIN
  Self.fCon :=  ConsoleAPI.TConsole.Create(Title, 80, 50, 80, 1000);
END; // .CONSTRUCTOR TConsoleLogger.Create

DESTRUCTOR TConsoleLogger.Destroy;
BEGIN
  SysUtils.FreeAndNil(Self.fCon);
END; // .DESTRUCTOR TConsoleLogger.Destroy

FUNCTION TConsoleLogger.Write (CONST EventSource, Operation, Description: STRING): BOOLEAN;
BEGIN
  Writeln
  (
    RECORD_BEGIN_SEPARATOR,
    EventSource,
    OPERATION_SEPARATOR,
    Operation,
    DESCRIPTION_SEPARATOR,
    DESCR_LINES_PREFIX,
    StrLib.Join(StrLib.Explode(Description, BR), DESCR_LINES_GLUE),
    RECORD_END_SEPARATOR
  );
  
  RESULT  :=  TRUE;
END; // .FUNCTION TConsoleLogger.Write

CONSTRUCTOR TFileLogger.Create (CONST FilePath: STRING);
BEGIN
  Self.fFile  :=  Files.TFile.Create;
  {!} ASSERT(Self.fFile.CreateNew(FilePath));
END; // .CONSTRUCTOR TFileLogger.Create

FUNCTION TFileLogger.Write (CONST EventSource, Operation, Description: STRING): BOOLEAN;
BEGIN
  RESULT  :=  Self.fFile.WriteStr(StrLib.Concat([
    RECORD_BEGIN_SEPARATOR,
    EventSource,
    OPERATION_SEPARATOR,
    Operation,
    DESCRIPTION_SEPARATOR,
    DESCR_LINES_PREFIX,
    StrLib.Join(StrLib.Explode(Description, BR), DESCR_LINES_GLUE),
    RECORD_END_SEPARATOR
  ]));
END; // .FUNCTION TFileLogger.Write

END.
