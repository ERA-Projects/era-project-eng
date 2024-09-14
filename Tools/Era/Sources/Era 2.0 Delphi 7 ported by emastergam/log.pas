UNIT Log;
{
DESCRIPTION:  Logging support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(*
Log is viewed as abstract list of records with sequential access. Every record contains time stamp.
There is a possibility to turn off/on logging functions which may be useful, for example, in protection unit.
All operations may return error because log storage usually depends on environment.
*)

(***) INTERFACE (***)
USES SysUtils, Classes;

CONST
  FREE_OLD_LOGGER = TRUE;


TYPE
  PLogRec = ^TLogRec;
  TLogRec = RECORD
    TimeStamp:    TDateTime;
    EventSource:  STRING;
    Operation:    STRING;
    Description:  STRING;
  END; // .RECORD TLogRec
  
{#}TLogger = CLASS // ABSTRACT
    FUNCTION  Write (CONST EventSource, Operation, Description: STRING): BOOLEAN; VIRTUAL; ABSTRACT;
    FUNCTION  Read (OUT LogRec: TLogRec): BOOLEAN; VIRTUAL; ABSTRACT;
    FUNCTION  IsLocked: BOOLEAN; VIRTUAL; ABSTRACT;
    PROCEDURE Lock; VIRTUAL; ABSTRACT;
    PROCEDURE Unlock; VIRTUAL; ABSTRACT;
    FUNCTION  GetPos (OUT Pos: INTEGER): BOOLEAN; VIRTUAL; ABSTRACT;
    FUNCTION  Seek (NewPos: INTEGER): BOOLEAN; VIRTUAL; ABSTRACT;
    FUNCTION  GetCount (OUT Count: INTEGER): BOOLEAN; VIRTUAL; ABSTRACT;
  END; // .CLASS TLogger

  TMemLogger = CLASS (TLogger)
    (***) PROTECTED (***)
      (* O *) fListOfRecords: Classes.TList;
              fPos:           INTEGER;
              fLocked:        BOOLEAN;
    
    (***) PUBLIC (***)
      FUNCTION  Write (CONST EventSource, Operation, Description: STRING): BOOLEAN; OVERRIDE;
      FUNCTION  Read (OUT LogRec: TLogRec): BOOLEAN; OVERRIDE;    
      FUNCTION  IsLocked: BOOLEAN; OVERRIDE;
      PROCEDURE Lock; OVERRIDE;
      PROCEDURE Unlock; OVERRIDE;
      FUNCTION  GetPos (OUT Pos: INTEGER): BOOLEAN; OVERRIDE;
      FUNCTION  Seek (NewPos: INTEGER): BOOLEAN; OVERRIDE;
      FUNCTION  GetCount(OUT Count: INTEGER): BOOLEAN; OVERRIDE;
      
      CONSTRUCTOR Create;
  END; // .CLASS TMemLogger

  
(*-----------------  UNIT WRAPPERS FOR TLOGGER METHODS  ----------------------*)

FUNCTION  Write (CONST EventSource, Operation, Description: STRING): BOOLEAN;
FUNCTION  Read (OUT LogRec: TLogRec): BOOLEAN;
FUNCTION  IsLocked: BOOLEAN;
PROCEDURE Lock;
PROCEDURE Unlock;
FUNCTION  GetPos (OUT Pos: INTEGER): BOOLEAN;
FUNCTION  Seek (NewPos: INTEGER): BOOLEAN;
FUNCTION  GetCount(OUT Count: INTEGER): BOOLEAN;

(*----------------------------------------------------------------------------*)


PROCEDURE InstallLogger (NewLogger: TLogger; FreeOldLogger: BOOLEAN);


(***)  IMPLEMENTATION  (***)


VAR
(* OU *)  Logger: TLogger;


CONSTRUCTOR TMemLogger.Create;
BEGIN
  Self.fListOfRecords :=  Classes.TList.Create;
  Self.fPos           :=  0;
  Self.fLocked        :=  FALSE;
END; // .CONSTRUCTOR TMemLogger.Create
  
FUNCTION TMemLogger.Write (CONST EventSource, Operation, Description: STRING): BOOLEAN;
VAR
(* U *) LogRec: PLogRec;
  
BEGIN
  LogRec  :=  NIL;
  // * * * * * //
  RESULT  :=  NOT Self.fLocked;
  IF RESULT THEN BEGIN
    NEW(LogRec);
    LogRec.TimeStamp    :=  SysUtils.Now;
    LogRec.EventSource  :=  EventSource;
    LogRec.Operation    :=  Operation;
    LogRec.Description  :=  Description;
    Self.fListOfRecords.Add(LogRec);
  END; // .IF
END; // .FUNCTION TMemLogger.Write

FUNCTION TMemLogger.Read (OUT LogRec: TLogRec): BOOLEAN;
BEGIN
  RESULT  :=  Self.fPos < Self.fListOfRecords.Count;
  IF RESULT THEN BEGIN
    LogRec  :=  PLogRec(Self.fListOfRecords[Self.fPos])^;
  END; // .IF
END; // .FUNCTION TMemLogger.Read

FUNCTION TMemLogger.IsLocked: BOOLEAN;
BEGIN
  RESULT  :=  Self.fLocked;
END; // .FUNCTION TMemLogger.IsLocked

PROCEDURE TMemLogger.Lock;
BEGIN
  Self.fLocked  :=  TRUE;
END; // .PROCEDURE TMemLogger.Lock

PROCEDURE TMemLogger.Unlock;
BEGIN
  Self.fLocked  :=  FALSE;
END; // .PROCEDURE TMemLogger.Unlock

FUNCTION TMemLogger.GetPos (OUT Pos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  TRUE;
  Pos     :=  Self.fPos;
END; // .FUNCTION TMemLogger.GetPos

FUNCTION TMemLogger.Seek (NewPos: INTEGER): BOOLEAN;
BEGIN
  {!} ASSERT(NewPos >= 0);
  RESULT  :=  NewPos < Self.fListOfRecords.Count;
  IF RESULT THEN BEGIN
    Self.fPos :=  NewPos;
  END; // .IF
END; // .FUNCTION TMemLogger.Seek

FUNCTION TMemLogger.GetCount (OUT Count: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  TRUE;
  Count   :=  Self.fListOfRecords.Count;
END; // .FUNCTION TMemLogger.GetCount

FUNCTION Write (CONST EventSource, Operation, Description: STRING): BOOLEAN;
BEGIN
  RESULT  :=  Logger.Write(EventSource, Operation, Description);
END; // .FUNCTION Write

FUNCTION Read (OUT LogRec: TLogRec): BOOLEAN;
BEGIN
  RESULT  :=  Logger.Read(LogRec);
END; // .FUNCTION Read

FUNCTION IsLocked: BOOLEAN;
BEGIN
  RESULT  :=  Logger.IsLocked;
END; // .FUNCTION IsLocked

PROCEDURE Lock;
BEGIN
  Logger.Lock;
END; // .PROCEDURE Lock

PROCEDURE Unlock;
BEGIN
  Logger.Unlock;
END; // .PROCEDURE Unlock

FUNCTION GetPos (OUT Pos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Logger.GetPos(Pos);
END; // .FUNCTION GetPos

FUNCTION Seek ({!} NewPos: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Logger.Seek(NewPos);
END; // .FUNCTION Seek

FUNCTION GetCount (OUT Count: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Logger.GetCount(Count);
END; // .FUNCTION GetCount

PROCEDURE InstallLogger (NewLogger: TLogger; FreeOldLogger: BOOLEAN);
BEGIN
  {!} ASSERT(NewLogger <> NIL);
  IF FreeOldLogger THEN BEGIN
    SysUtils.FreeAndNil(Logger);
  END; // .IF
  Logger  :=  NewLogger;
END; // .PROCEDURE InstallLogger

BEGIN
  Logger  :=  TMemLogger.Create;
END.
