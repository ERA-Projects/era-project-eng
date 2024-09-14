unit EraLog;
{
DESCRIPTION:  Logging support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Utils, Files, ConsoleAPI, Log, StrLib;

type
  TLogger = class (Log.TLogger)
    function  Read (out LogRec: TLogRec): boolean; override;
    function  IsLocked: boolean; override;
    procedure Lock; override;
    procedure Unlock; override;
    function  GetPos (out Pos: integer): boolean; override;
    function  Seek (NewPos: integer): boolean; override;
    function  GetCount (out Count: integer): boolean; override;
  end; // .class TLogger

  TMemoryLogger  = class (TLogger)
    function  Write (const EventSource, Operation, Description: string): boolean; override;
  end; // .class TMemoryLogger
  
  TConsoleLogger  = class (TLogger)
    (***) protected (***)
      {O} fCon: ConsoleAPI.TConsole;
    
    (***) public (***)
      constructor Create (const Title: string);
      destructor  Destroy; override;
      
      function  Write (const EventSource, Operation, Description: string): boolean; override;
  end; // .class TConsoleLogger
  
  TFileLogger = class (TLogger)
    (***) protected (***)
      {O} fFile:  Files.TFile;
      
    (***) public (***)
      constructor Create (const FilePath: string);
      destructor  Destroy; override;
      
      function  Write (const EventSource, Operation, Description: string): boolean; override;
  end; // .class TFileLogger


(***) implementation (***)


const
  BR                     = #13#10;
  RECORD_BEGIN_SEPARATOR = '>> ';
  RECORD_END_SEPARATOR   = BR + BR;
  OPERATION_SEPARATOR    = ': ';
  DESCRIPTION_SEPARATOR  = BR;
  DESCR_LINES_PREFIX     = '   ';
  DESCR_LINES_GLUE       = BR + DESCR_LINES_PREFIX;


function TLogger.Read (out LogRec: TLogRec): boolean;
begin
  result := false;
end; // .function TLogger.Read

function TLogger.IsLocked: boolean;
begin
  result := false;
end; // .function TLogger.IsLocked

procedure TLogger.Lock;
begin
end; // .procedure TLogger.Lock

procedure TLogger.Unlock;
begin
end; // .procedure TLogger.Unlock

function TLogger.GetPos (out Pos: integer): boolean;
begin
  Pos    := -1;
  result := false;
end; // .function TLogger.GetPos

function TLogger.Seek (NewPos: integer): boolean;
begin
  result := false;
end; // .function TLogger.Seek

function TLogger.GetCount (out Count: integer): boolean;
begin
  Count  := -1;
  result := false;
end; // .function TLogger.GetCount

function TMemoryLogger.Write (const EventSource, Operation, Description: string): boolean;
begin
  result := true;
end; // .function TMemoryLogger.Write

constructor TConsoleLogger.Create (const Title: string);
begin
  Self.fCon := ConsoleAPI.TConsole.Create(Title, 80, 50, 80, 1000);
end; // .constructor TConsoleLogger.Create

destructor TConsoleLogger.Destroy;
begin
  SysUtils.FreeAndNil(Self.fCon);
end; // .destructor TConsoleLogger.Destroy

function TConsoleLogger.Write (const EventSource, Operation, Description: string): boolean;
begin
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
  
  result := true;
end; // .function TConsoleLogger.Write

constructor TFileLogger.Create (const FilePath: string);
begin
  Self.fFile := Files.TFile.Create;
  {!} Assert(Self.fFile.CreateNew(FilePath), 'Failed to create log file at "' + FilePath + '". Probably another Heroes 3 instance is running');
end; // .constructor TFileLogger.Create

destructor TFileLogger.Destroy;
begin
  SysUtils.FreeAndNil(Self.fFile);
end; // .destructor TFileLogger.Destroy

function TFileLogger.Write (const EventSource, Operation, Description: string): boolean;
begin
  result := Self.fFile.WriteStr(StrLib.Concat([
    RECORD_BEGIN_SEPARATOR,
    EventSource,
    OPERATION_SEPARATOR,
    Operation,
    DESCRIPTION_SEPARATOR,
    DESCR_LINES_PREFIX,
    StrLib.Join(StrLib.Explode(Description, BR), DESCR_LINES_GLUE),
    RECORD_END_SEPARATOR
  ]));
end; // .function TFileLogger.Write

end.
