unit ErmDebug;
{
DESCRIPTION:  Erm debugging and tracking
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Utils, Erm;

type
  TCmdId = Erm.TErmCmdId;
  TEventContext = TObject;

  PEventRec = ^TEventRec;
  TEventRec = record
        EventId:  integer;
        EventN:   integer;
    {O} Context:  TEventContext
  end; // .record TEventRec

  PCmdRec = ^TCmdRec;
  TCmdRec = record
    CmdId:  TCmdId;
    CmdPtr: pchar;  // set for commands from scripts, CmdStr = ''
    CmdStr: string; // set for deleted or temp commands, CmdPtr = nil
    EventN: integer;
  end; // .record TCmdRec
  
  TTracker = class
   private
    fEventRecs:           array of TEventRec;
    fCmdRecs:             array of TCmdRec;
    fLastEventN:          integer;
    fEventRecsPos:        integer;
    fCmdRecsPos:          integer;
    fEventRecsIsCircBuf:  boolean; // Becomes true when New records start overwriting the old ones
    fCmdRecsIsCircBuf:    boolean; // Becomes true when New records start overwriting the old ones
    
   public
    constructor Create (aNumEventRecs, aNumCmdRecs: integer);
    procedure Reset;
    procedure TrackEvent (EventId: integer);
    procedure TrackCmd (CmdId: TCmdId; CmdPtr: pchar; IsTempCmd: boolean);
    function  GenerateReport: string;
  end; // .class TTracker
  
  TAddrRange = record
    StartAddr: pointer;
    EndAddr:   pointer;
  end; // .record TAddrRange
  
  TScriptsLineKeeper = class
   private
    ScriptsBounds: array of TAddrRange;
  end; // .class TScriptsLineKeeper
  

var
{O} Tracker: TTracker;
    
    (* Options *)
    EnableDebuggerOpt:  boolean = false;
    EnableTracingOpt:   boolean = false;
    NumTracedEventsOpt: integer = 0;
    NumTracedCmdsOpt:   integer = 0;
  
  
(***) implementation (***)

constructor TTracker.Create (aNumEventRecs, aNumCmdRecs: integer);
begin
  {!} Assert(aNumEventRecs >= 0);
  {!} Assert(aNumCmdRecs >= 0);
  SetLength(fEventRecs, aNumEventRecs);
  SetLength(fCmdRecs, aNumCmdRecs);
  Reset;
end; // .constructor TTracker.Create

procedure TTracker.Reset;
begin
  fLastEventN         := 0;
  fEventRecsPos       := 0;
  fCmdRecsPos         := 0;
  fEventRecsIsCircBuf := false;
  fCmdRecsIsCircBuf   := false;
end; // .procedure TTracker.Reset

procedure TrackEvent (EventId: integer);
var
   
begin
  
end; // .procedure TrackEvent

procedure OnBeforeWoG (Event: GameExt.PEvent); stdcall;
begin
  Tracker := TTracker.Create(NumTracedEventsOpt, NumTracedCmdsOpt);
end; // .procedure OnBeforeWoG

begin
  GameExt.RegisterHandler('OnBeforeWoG', OnBeforeWoG);
end.
