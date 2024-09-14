UNIT Era;
{
DESCRIPTION:  Era SDK
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Windows;

CONST
  (* Hooks *)
  HOOKTYPE_JUMP   = 0;  // jmp, 5 bytes
  HOOKTYPE_CALL   = 1;  // call, 5 bytes
  {
  Opcode: call, 5 bytes.
  Automatically creates safe bridge to high-level function "F".
  FUNCTION  F (Context: PHookHandlerArgs): TExecuteDefaultCodeFlag; STDCALL;
  If default code should be executed, it can contain any commands except jumps.
  }
  HOOKTYPE_BRIDGE = 2;
  
  OPCODE_JUMP     = $E9;
  OPCODE_CALL     = $E8;
  OPCODE_RET      = $C3;
  
  EXEC_DEF_CODE   = TRUE;
  
  (* Erm triggers *)
  TRIGGER_FU1       = 0;
  TRIGGER_FU30000   = 29999;
  TRIGGER_TM1       = 30000;
  TRIGGER_TM100     = 30099;
  TRIGGER_HE0       = 30100;
  TRIGGER_HE198     = 30298;
  TRIGGER_BA0       = 30300;
  TRIGGER_BA1       = 30301;
  TRIGGER_BR        = 30302;
  TRIGGER_BG0       = 30303;
  TRIGGER_BG1       = 30304;
  TRIGGER_MW0       = 30305;
  TRIGGER_MW1       = 30306;
  TRIGGER_MR0       = 30307;
  TRIGGER_MR1       = 30308;
  TRIGGER_MR2       = 30309;
  TRIGGER_CM0       = 30310;
  TRIGGER_CM1       = 30311;
  TRIGGER_CM2       = 30312;
  TRIGGER_CM3       = 30313;
  TRIGGER_CM4       = 30314;
  TRIGGER_AE0       = 30315;
  TRIGGER_AE1       = 30316;
  TRIGGER_MM0       = 30317;
  TRIGGER_MM1       = 30318;
  TRIGGER_CM5       = 30319;
  TRIGGER_MP        = 30320;
  TRIGGER_SN        = 30321;
  TRIGGER_MG0       = 30322;
  TRIGGER_MG1       = 30323;
  TRIGGER_TH0       = 30324;
  TRIGGER_TH1       = 30325;
  TRIGGER_IP0       = 30330;
  TRIGGER_IP1       = 30331;
  TRIGGER_IP2       = 30332;
  TRIGGER_IP3       = 30333;
  TRIGGER_CO0       = 30340;
  TRIGGER_CO1       = 30341;
  TRIGGER_CO2       = 30342;
  TRIGGER_CO3       = 30343;
  TRIGGER_BA50      = 30350;
  TRIGGER_BA51      = 30351;
  TRIGGER_BA52      = 30352;
  TRIGGER_BA53      = 30353;
  TRIGGER_GM0       = 30360;
  TRIGGER_GM1       = 30361;
  TRIGGER_PI        = 30370;
  TRIGGER_DL        = 30371;
  TRIGGER_HM        = 30400;
  TRIGGER_HM0       = 30401;
  TRIGGER_HM198     = 30599;
  TRIGGER_HL        = 30600;
  TRIGGER_HL0       = 30601;
  TRIGGER_HL198     = 30799;
  TRIGGER_BF        = 30800;
  TRIGGER_MF1       = 30801;
  TRIGGER_TL0       = 30900;
  TRIGGER_TL1       = 30901;
  TRIGGER_TL2       = 30902;
  TRIGGER_TL3       = 30903;
  TRIGGER_TL4       = 30904;
  TRIGGER_OB_POS    = INTEGER($10000000);
  TRIGGER_LE_POS    = INTEGER($20000000);
  TRIGGER_OB_LEAVE  = INTEGER($08000000);
  
  (* Era Triggers *)
  TRIGGER_BEFORE_SAVE_GAME      = 77000;  // DEPRECATED;
  TRIGGER_SAVEGAME_WRITE        = 77001;
  TRIGGER_SAVEGAME_READ         = 77002;
  TRIGGER_KEYPRESS              = 77003;
  TRIGGER_OPEN_HEROSCREEN       = 77004;
  TRIGGER_CLOSE_HEROSCREEN      = 77005;
  TRIGGER_STACK_OBTAINS_TURN    = 77006;
  TRIGGER_REGENERATE_PHASE      = 77007;
  TRIGGER_AFTER_SAVE_GAME       = 77008;
  TRIGGER_SKEY_SAVEDIALOG       = 77009;  // DEPRECATED;
  TRIGGER_HEROESMEET            = 77010;  // DEPRECATED;
  TRIGGER_BEFOREHEROINTERACT    = 77010;
  TRIGGER_AFTERHEROINTERACT     = 77011;
  TRIGGER_ONSTACKTOSTACKDAMAGE  = 77012;


TYPE
  PTxtFile  = ^TTxtFile;
  TTxtFile  = PACKED RECORD
    Dummy:    ARRAY [0..$17] OF BYTE;
    RefCount: INTEGER;
    (* Dummy *)
  END; // .RECORD TTxtFile

  PHookHandlerArgs  = ^THookHandlerArgs;
  THookHandlerArgs  = PACKED RECORD
    EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: INTEGER;
    RetAddr:                                POINTER;
  END; // .RECORD THookHandlerArgs

  PEvent  = ^TEvent;
  TEvent  = PACKED RECORD
      Name:     PCHAR;
  {n} Data:     POINTER;
      DataSize: INTEGER;
  END; // .RECORD TEvent

  PEventParams  = ^TEventParams;
  TEventParams  = ARRAY[0..15] OF INTEGER;
  TEventHandler = PROCEDURE (Event: PEvent) STDCALL;

  PErmVVars = ^TErmVVars;
  TErmVVars = ARRAY [0..10000] OF INTEGER;
  TErmZVar  = ARRAY [0..511] OF CHAR;
  PErmZVars = ^TErmZVars;
  TErmZVars = ARRAY [0..1000] OF TErmZVar;
  PErmYVars = ^TErmYVars;
  TErmYVars = ARRAY [0..100] OF INTEGER;
  PErmXVars = ^TErmXVars;
  TErmXVars = ARRAY [0..16] OF INTEGER;
  PErmFlags = ^TErmFlags;
  TErmFlags = ARRAY [0..1000] OF BOOLEAN;
  PErmEVars = ^TErmEVars;
  TErmEVars = ARRAY [0..100] OF SINGLE;
  
  PGameState  = ^TGameState;
  TGameState  = PACKED RECORD
    RootDlgId:    INTEGER;
    CurrentDlgId: INTEGER;
  END; // .RECORD TGameState


CONST
  (* WoG vars *)
  v:  PErmVVars = Ptr($887664);
  z:  PErmZVars = Ptr($9271E8);
  y:  PErmYVars = Ptr($A48D7C);
  x:  PErmXVars = Ptr($91DA34);
  f:  PErmFlags = Ptr($91F2DF);
  e:  PErmEVars = Ptr($A48F14);


PROCEDURE WriteAtCode (Count: INTEGER; Src, Dst: POINTER); STDCALL;

PROCEDURE Hook
(
  HandlerAddr:  POINTER;
  HookType:     INTEGER;
  PatchSize:    INTEGER;
  CodeAddr:     POINTER
); STDCALL;

PROCEDURE ApiHook (HandlerAddr: POINTER; HookType: INTEGER; CodeAddr: POINTER); STDCALL;
PROCEDURE KillThisProcess;
PROCEDURE FatalError (Err: PCHAR); STDCALL;
FUNCTION  RecallAPI (Context: PHookHandlerArgs; NumArgs: INTEGER): INTEGER; STDCALL;
PROCEDURE RegisterHandler (Handler: TEventHandler; EventName: PCHAR); STDCALL;
PROCEDURE FireEvent (EventName: PCHAR; {n} EventData: POINTER; DataSize: INTEGER); STDCALL;
FUNCTION  LoadTxt (Name: PCHAR): {n} PTxtFile; STDCALL;
PROCEDURE ForceTxtUnload (Name: PCHAR); STDCALL;
PROCEDURE ExecErmCmd (CmdStr: PCHAR); STDCALL;
PROCEDURE ReloadErm;
PROCEDURE ExtractErm;
PROCEDURE FireErmEvent (EventID: INTEGER); STDCALL;
PROCEDURE ClearAllIniCache;
PROCEDURE ClearIniCache (FileName: PCHAR); STDCALL;
FUNCTION  ReadStrFromIni (Key, SectionName, FilePath, Res: PCHAR): BOOLEAN; STDCALL;
FUNCTION  WriteStrToIni (Key, Value, SectionName, FilePath: PCHAR): BOOLEAN; STDCALL;
PROCEDURE NameColor (Color32: INTEGER; Name: PCHAR); STDCALL;
PROCEDURE WriteSavegameSection (DataSize: INTEGER; {n} Data: POINTER; SectionName: PCHAR); STDCALL;

FUNCTION  ReadSavegameSection
(
      DataSize:     INTEGER;
  {n} Dest:         POINTER;
      SectionName:  PCHAR
): INTEGER; STDCALL;

PROCEDURE GetGameState (VAR GameState: TGameState); STDCALL;
PROCEDURE SaveEventParams;
PROCEDURE RestoreEventParams;


VAR
  EventParams:  PEventParams;


(***) IMPLEMENTATION (***)


PROCEDURE WriteAtCode;          EXTERNAL 'Era.dll' NAME 'WriteAtCode';
PROCEDURE Hook;                 EXTERNAL 'Era.dll' NAME 'Hook';
PROCEDURE ApiHook;              EXTERNAL 'Era.dll' NAME 'ApiHook';
PROCEDURE KillThisProcess;      EXTERNAL 'Era.dll' NAME 'KillThisProcess';
PROCEDURE FatalError;           EXTERNAL 'Era.dll' NAME 'FatalError';
FUNCTION  RecallAPI;            EXTERNAL 'Era.dll' NAME 'RecallAPI';
PROCEDURE RegisterHandler;      EXTERNAL 'Era.dll' NAME 'RegisterHandler';
PROCEDURE FireEvent;            EXTERNAL 'Era.dll' NAME 'FireEvent';
FUNCTION  LoadTxt;              EXTERNAL 'Era.dll' NAME 'LoadTxt';
PROCEDURE ForceTxtUnload;       EXTERNAL 'Era.dll' NAME 'ForceTxtUnload';
PROCEDURE ExecErmCmd;           EXTERNAL 'Era.dll' NAME 'ExecErmCmd';
PROCEDURE ReloadErm;            EXTERNAL 'Era.dll' NAME 'ReloadErm';
PROCEDURE ExtractErm;           EXTERNAL 'Era.dll' NAME 'ExtractErm';
PROCEDURE FireErmEvent;         EXTERNAL 'Era.dll' NAME 'FireErmEvent';
PROCEDURE ClearAllIniCache;     EXTERNAL 'Era.dll' NAME 'ClearAllIniCache';
PROCEDURE ClearIniCache;        EXTERNAL 'Era.dll' NAME 'ClearIniCache';
FUNCTION  ReadStrFromIni;       EXTERNAL 'Era.dll' NAME 'ReadStrFromIni';
FUNCTION  WriteStrToIni;        EXTERNAL 'Era.dll' NAME 'WriteStrToIni';
PROCEDURE NameColor;            EXTERNAL 'Era.dll' NAME 'NameColor';
PROCEDURE WriteSavegameSection; EXTERNAL 'Era.dll' NAME 'WriteSavegameSection';
FUNCTION  ReadSavegameSection;  EXTERNAL 'Era.dll' NAME 'ReadSavegameSection';
PROCEDURE GetGameState;         EXTERNAL 'Era.dll' NAME 'GetGameState';
PROCEDURE SaveEventParams;      EXTERNAL 'Angel.dll' NAME 'SaveEventParams';
PROCEDURE RestoreEventParams;   EXTERNAL 'Angel.dll' NAME 'RestoreEventParams';

BEGIN
  EventParams :=  Windows.GetProcAddress(Windows.LoadLibrary('Angel.dll'), 'EventParams');
END.
