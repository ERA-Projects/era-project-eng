unit Log;
{
DESCRIPTION:  Logging support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(*
Log is viewed as abstract list of records with sequential access. Every record contains time stamp.
There is a possibility to turn off/on logging functions which may be useful, for example, in protection unit.
All operations may return error because log storage usually depends on environment.
Accessing log through module global functions is thread-safe.
*)

(***) interface (***)
uses Windows, SysUtils, Classes;

const
  FREE_OLD_LOGGER = TRUE;


type
  PLogRec = ^TLogRec;
  TLogRec = record
    TimeStamp:    TDateTime;
    EventSource:  string;
    Operation:    string;
    Description:  string;
  end; // .record TLogRec
  
  TLogger = class abstract
    function  Write (const EventSource, Operation, Description: string): boolean; virtual; abstract;
    function  Read (out LogRec: TLogRec): boolean; virtual; abstract;
    function  IsLocked: boolean; virtual; abstract;
    procedure Lock; virtual; abstract;
    procedure Unlock; virtual; abstract;
    function  GetPos (out Pos: integer): boolean; virtual; abstract;
    function  Seek (NewPos: integer): boolean; virtual; abstract;
    function  GetCount (out Count: integer): boolean; virtual; abstract;
  end; // .class TLogger

  TMemLogger = class (TLogger)
    (***) protected (***)
      (* O *) fListOfRecords: Classes.TList;
              fPos:           integer;
              fLocked:        boolean;
    
    (***) public (***)
      function  Write (const EventSource, Operation, Description: string): boolean; override;
      function  Read (out LogRec: TLogRec): boolean; override;    
      function  IsLocked: boolean; override;
      procedure Lock; override;
      procedure Unlock; override;
      function  GetPos (out Pos: integer): boolean; override;
      function  Seek (NewPos: integer): boolean; override;
      function  GetCount(out Count: integer): boolean; override;
      
      constructor Create;
  end; // .class TMemLogger

  
(*-----------------  unit WRAPPERS for TLOGGER METHODS  ----------------------*)

function  Write (const EventSource, Operation, Description: string): boolean;
function  Read (out LogRec: TLogRec): boolean;
function  IsLocked: boolean;
procedure Lock;
procedure Unlock;
function  GetPos (out Pos: integer): boolean;
function  Seek (NewPos: integer): boolean;
function  GetCount(out Count: integer): boolean;

(*----------------------------------------------------------------------------*)


procedure InstallLogger (NewLogger: TLogger; FreeOldLogger: boolean);


(***)  implementation  (***)


var
{OU} Logger: TLogger;
     LogMutex: Windows.TRTLCriticalSection;


constructor TMemLogger.Create;
begin
  Self.fListOfRecords :=  Classes.TList.Create;
  Self.fPos           :=  0;
  Self.fLocked        :=  FALSE;
end; // .constructor TMemLogger.Create
  
function TMemLogger.Write (const EventSource, Operation, Description: string): boolean;
var
(* U *) LogRec: PLogRec;
  
begin
  LogRec  :=  nil;
  // * * * * * //
  result  :=  not Self.fLocked;
  if result then begin
    New(LogRec);
    LogRec.TimeStamp    :=  SysUtils.Now;
    LogRec.EventSource  :=  EventSource;
    LogRec.Operation    :=  Operation;
    LogRec.Description  :=  Description;
    Self.fListOfRecords.Add(LogRec);
  end; // .if
end; // .function TMemLogger.Write

function TMemLogger.Read (out LogRec: TLogRec): boolean;
begin
  result  :=  Self.fPos < Self.fListOfRecords.Count;
  if result then begin
    LogRec  :=  PLogRec(Self.fListOfRecords[Self.fPos])^;
    Inc(Self.fPos);
  end; // .if
end; // .function TMemLogger.Read

function TMemLogger.IsLocked: boolean;
begin
  result  :=  Self.fLocked;
end; // .function TMemLogger.IsLocked

procedure TMemLogger.Lock;
begin
  Self.fLocked  :=  TRUE;
end; // .procedure TMemLogger.Lock

procedure TMemLogger.Unlock;
begin
  Self.fLocked  :=  FALSE;
end; // .procedure TMemLogger.Unlock

function TMemLogger.GetPos (out Pos: integer): boolean;
begin
  result  :=  TRUE;
  Pos     :=  Self.fPos;
end; // .function TMemLogger.GetPos

function TMemLogger.Seek (NewPos: integer): boolean;
begin
  {!} Assert(NewPos >= 0);
  result  :=  NewPos < Self.fListOfRecords.Count;
  if result then begin
    Self.fPos :=  NewPos;
  end; // .if
end; // .function TMemLogger.Seek

function TMemLogger.GetCount (out Count: integer): boolean;
begin
  result  :=  TRUE;
  Count   :=  Self.fListOfRecords.Count;
end; // .function TMemLogger.GetCount

function Write (const EventSource, Operation, Description: string): boolean;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  result := Logger.Write(EventSource, Operation, Description);
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .function Write

function Read (out LogRec: TLogRec): boolean;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  result := Logger.Read(LogRec);
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .function Read

function IsLocked: boolean;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  result := Logger.IsLocked;
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .function IsLocked

procedure Lock;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  Logger.Lock;
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .procedure Lock

procedure Unlock;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  Logger.Unlock;
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .procedure Unlock

function GetPos (out Pos: integer): boolean;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  result := Logger.GetPos(Pos);
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .function GetPos

function Seek ({!} NewPos: integer): boolean;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  result := Logger.Seek(NewPos);
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .function Seek

function GetCount (out Count: integer): boolean;
begin
  {!} Windows.EnterCriticalSection(LogMutex);
  result := Logger.GetCount(Count);
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .function GetCount

procedure InstallLogger (NewLogger: TLogger; FreeOldLogger: boolean);
begin
  {!} Assert(NewLogger <> nil);
  {!} Windows.EnterCriticalSection(LogMutex);
  
  if FreeOldLogger then begin
    SysUtils.FreeAndNil(Logger);
  end; // .if
  
  Logger := NewLogger;
  {!} Windows.LeaveCriticalSection(LogMutex);
end; // .procedure InstallLogger

begin
  Windows.InitializeCriticalSection(LogMutex);
  Logger := TMemLogger.Create;
end.
