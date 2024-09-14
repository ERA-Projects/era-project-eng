UNIT Erm;
{
DESCRIPTION:  Native ERM support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  SysUtils, Utils, Crypto, TextScan, AssocArrays, CFiles, Files, Ini, Lists, StrLib,
  Core, Heroes, GameExt;

CONST
  (* Erm command conditions *)
  LEFT_COND   = 0;
  RIGHT_COND  = 1;
  COND_AND    = 0;
  COND_OR     = 1;

  ERM_CMD_MAX_PARAMS_NUM  = 16;
  MAX_ERM_SCRIPTS_NUM     = 100;

  (* Erm script state*)
  SCRIPT_NOT_USED = 0;
  SCRIPT_IS_USED  = 1;
  SCRIPT_IN_MAP   = 2;

  EXTRACTED_SCRIPTS_PATH        = 'Data\ExtractedScripts';
  EXTRACTED_SCRIPTS_PATH_PREFIX = EXTRACTED_SCRIPTS_PATH + '\script';

  AltScriptsPath: PCHAR     = Ptr($2730F68);
  CurrErmEventID: PINTEGER  = Ptr($27C1950);

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
  TRIGGER_INVALID   = -1;
  
  (* Era Triggers *)
  TRIGGER_BEFORE_SAVE_GAME          = 77000;  // DEPRECATED;
  TRIGGER_SAVEGAME_WRITE            = 77001;
  TRIGGER_SAVEGAME_READ             = 77002;
  TRIGGER_KEYPRESS                  = 77003;
  TRIGGER_OPEN_HEROSCREEN           = 77004;
  TRIGGER_CLOSE_HEROSCREEN          = 77005;
  TRIGGER_STACK_OBTAINS_TURN        = 77006;
  TRIGGER_REGENERATE_PHASE          = 77007;
  TRIGGER_AFTER_SAVE_GAME           = 77008;
  TRIGGER_SKEY_SAVEDIALOG           = 77009;  // DEPRECATED;
  TRIGGER_HEROESMEET                = 77010;  // DEPRECATED;
  TRIGGER_BEFOREHEROINTERACT        = 77010;
  TRIGGER_AFTERHEROINTERACT         = 77011;
  TRIGGER_ONSTACKTOSTACKDAMAGE      = 77012;
  TRIGGER_ONAICALCSTACKATTACKEFFECT = 77013;
  TRIGGER_ONCHAT                    = 77014;
  
  ZvsProcessErm:  Utils.TProcedure  = Ptr($74C816);


TYPE
  (* IMPORT *)
  TAssocArray = AssocArrays.TAssocArray;

  TErmValType   = (ValNum, ValF, ValQuick, ValV, ValW, ValX, ValY, ValZ);
  TErmCheckType =
  (
    NO_CHECK,
    CHECK_GET,
    CHECK_EQUAL,
    CHECK_NOTEQUAL,
    CHECK_MORE,
    CHECK_LESS,
    CHECK_MOREEUQAL,
    CHECK_LESSEQUAL
  );

  TErmCmdParam = PACKED RECORD
    Value:    INTEGER;
    {
    [4 bits]  Type:             TErmValType;  // ex: y5;  y5 - type
    [4 bits]  IndexedPartType:  TErmValType;  // ex: vy5; y5 - indexed part;
    [3 bits]  CheckType:        TErmCheckType;
    }
    ValType:  INTEGER;
  END; // .RECORD TErmCmdParam

  TErmString = PACKED RECORD
    Value:  PCHAR;
    Len:    INTEGER;
  END; // .RECORD TErmString
  
  TGameString = PACKED RECORD
    Value:  PCHAR;
    Len:    INTEGER;
    Dummy:  INTEGER;
  END; // .RECORD TGameString
  
  TErmScriptInfo  = PACKED RECORD
    State:  INTEGER;
    Size:   INTEGER;
  END; // .RECORD TErmScriptInfo

  PErmScriptsInfo = ^TErmScriptsInfo;
  TErmScriptsInfo = ARRAY [0..MAX_ERM_SCRIPTS_NUM - 1] OF TErmScriptInfo;
  
  PScriptsPointers  = ^TScriptsPointers;
  TScriptsPointers  = ARRAY [0..MAX_ERM_SCRIPTS_NUM - 1] OF PCHAR;
  
  PErmCmdConditions = ^TErmCmdConditions;
  TErmCmdConditions = ARRAY [COND_AND..COND_OR, 0..15, LEFT_COND..RIGHT_COND] OF TErmCmdParam;

  PErmCmdParams = ^TErmCmdParams;
  TErmCmdParams = ARRAY [0..ERM_CMD_MAX_PARAMS_NUM - 1] OF TErmCmdParam;

  PErmCmd = ^TErmCmd;
  TErmCmd = PACKED RECORD
    Name:         ARRAY [0..1] OF CHAR;
    Disabled:     BOOLEAN;
    PrevDisabled: BOOLEAN;
    Conditions:   TErmCmdConditions;
    Structure:    POINTER;
    Params:       TErmCmdParams;
    NumParams:    INTEGER;
    CmdHeader:    TErmString; // ##:...
    CmdBody:      TErmString; // #^...^/...
  END; // .RECORD TErmCmd
  
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

  TZvsLoadErmScript = FUNCTION (ScriptId: INTEGER): INTEGER; CDECL;
  TZvsLoadErmTxt    = FUNCTION (IsNewLoad: INTEGER): INTEGER; CDECL;
  TZvsShowMessage   = FUNCTION (Mes: PCHAR; MesType: INTEGER; DummyZero: INTEGER): INTEGER; CDECL;
  TFireErmEvent     = FUNCTION (EventId: INTEGER): INTEGER; CDECL;
  
  POnBeforeTriggerArgs  = ^TOnBeforeTriggerArgs;
  TOnBeforeTriggerArgs  = PACKED RECORD
    TriggerID:          INTEGER;
    BlockErmExecution:  LONGBOOL;
  END; // .RECORD TOnBeforeTriggerArgs


CONST
  (* WoG vars *)
  v:  PErmVVars = Ptr($887664);
  z:  PErmZVars = Ptr($9271E8);
  y:  PErmYVars = Ptr($A48D7C);
  x:  PErmXVars = Ptr($91DA34);
  f:  PErmFlags = Ptr($91F2DF);
  e:  PErmEVars = Ptr($A48F14);

  ZvsIsGameLoading: PBOOLEAN          = Ptr($A46BC0);
  ErmScriptsInfo:   PErmScriptsInfo   = Ptr($A49270);
  ErmScripts:       PScriptsPointers  = Ptr($A468A0);
  IsWoG:            PLONGBOOL         = Ptr($803288);
  ErmDlgCmd:        PINTEGER          = Ptr($887658);

  (* WoG funcs *)
  ZvsFindErm:         Utils.TProcedure  = Ptr($749955);
  ZvsClearErtStrings: Utils.TProcedure  = Ptr($7764F2);
  ZvsClearErmScripts: Utils.TProcedure  = Ptr($750191);
  ZvsLoadErmScript:   TZvsLoadErmScript = Ptr($72C297);
  ZvsLoadErmTxt:      TZvsLoadErmTxt    = Ptr($72C8B1);
  ZvsShowMessage:     TZvsShowMessage   = Ptr($70FB63);
  FireErmEvent:       TFireErmEvent     = Ptr($74CE30);


PROCEDURE ZvsProcessCmd (Cmd: PErmCmd);
PROCEDURE ExecErmCmd (CONST CmdStr: STRING); STDCALL;
PROCEDURE ReloadErm; STDCALL;
PROCEDURE ExtractErm; STDCALL;
  
  
(***) IMPLEMENTATION (***)


CONST
  ERM_CMD_CACH_LIMIT  = 16384;


VAR
{O} ErmScanner:           TextScan.TTextScanner;
{O} ErmCmdCach:           {O} TAssocArray {OF PErmCmd};
    SavedYVars:           ARRAY [0..99] OF INTEGER;
    ShouldPreserveYVars:  BOOLEAN;
    ErmTriggerDepth:      INTEGER = 0;
    NumArtsToDelete:      INTEGER;


PROCEDURE ShowMessage (Mes: STRING);
CONST
  MSG_OK  = 1;

BEGIN
  ZvsShowMessage(PCHAR(Mes), MSG_OK, 0);
END; // .PROCEDURE ShowMessage
    
FUNCTION GetErmValType (c: CHAR; OUT ValType: TErmValType): BOOLEAN;
BEGIN
  RESULT  :=  TRUE;
  
  CASE c OF
    '+', '-': ValType :=  ValNum;
    '0'..'9': ValType :=  ValNum;
    'f'..'t': ValType :=  ValQuick;
    'v':      ValType :=  ValV;
    'w':      ValType :=  ValW;
    'x':      ValType :=  ValX;
    'y':      ValType :=  ValY;
    'z':      ValType :=  ValZ;
  ELSE
    RESULT  :=  FALSE;
    ShowMessage('Invalid ERM value type: "' + c + '"');
  END; // .SWITCH
END; // .FUNCTION GetErmValType

PROCEDURE ZvsProcessCmd (Cmd: PErmCmd); ASSEMBLER;
ASM
  // Push parameters
  MOV EAX, Cmd
  PUSH 0
  PUSH 0
  PUSH EAX
  // Push return address
  LEA EAX, @@Ret
  PUSH EAX
  // Execute initial function code
  PUSH EBP
  MOV EBP, ESP
  SUB ESP, $544
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV EAX, [EBP + $8]
  MOV CX, [EAX]
  MOV [EBP - $314], CX
  MOV EDX, [EBP + $8]
  MOV EAX, [EDX + $294]
  MOV [EBP - $2FC], EAX
  // Give control to code after logging area
  PUSH $741E3F
  RET
  @@Ret:
  ADD ESP, $0C
END; // .PROCEDURE ZvsProcessCmd

PROCEDURE ClearErmCmdCach;
VAR
{U} Cmd:  PErmCmd;
    Key:  STRING;
  
BEGIN
  Cmd :=  NIL;
  // * * * * * //
  ErmCmdCach.BeginIterate;
  
  WHILE ErmCmdCach.IterateNext(Key, POINTER(Cmd)) DO BEGIN
    FreeMem(Cmd.CmdHeader.Value);
    DISPOSE(Cmd); Cmd :=  NIL;
  END; // .WHILE
  
  ErmCmdCach.EndIterate;

  ErmCmdCach.Clear;
END; // .PROCEDURE ClearErmCmdCach

PROCEDURE ExecErmCmd (CONST CmdStr: STRING);
CONST
  LETTERS = ['A'..'Z'];
  DIGITS  = ['0'..'9'];
  SIGNS   = ['+', '-'];
  NUMBER  = DIGITS + SIGNS;
  DELIMS  = ['/', ':'];

VAR
{U} Cmd:      PErmCmd;
    CmdName:  STRING;
    NumArgs:  INTEGER;
    Res:      BOOLEAN;
    c:        CHAR;
    
  FUNCTION ReadNum (OUT Num: INTEGER): BOOLEAN;
  VAR
    StartPos: INTEGER;
    Token:    STRING;
    c:        CHAR;
  
  BEGIN
    RESULT  :=  ErmScanner.GetCurrChar(c) AND (c IN NUMBER);
    
    IF RESULT THEN BEGIN
      IF c IN SIGNS THEN BEGIN
        StartPos  :=  ErmScanner.Pos;
        ErmScanner.GotoNextChar;
        ErmScanner.SkipCharset(DIGITS);
        Token :=  ErmScanner.GetSubstrAtPos(StartPos, ErmScanner.Pos - StartPos);
      END // .IF
      ELSE BEGIN
        ErmScanner.ReadToken(DIGITS, Token);
      END; // .ELSE
      
      RESULT  :=
        SysUtils.TryStrToInt(Token, Num)  AND
        ErmScanner.GetCurrChar(c)         AND
        (c IN DELIMS);
    END; // .IF
  END; // .FUNCTION ReadNum
  
  FUNCTION ReadArg (OUT Arg: TErmCmdParam): BOOLEAN;
  VAR
    ValType:  TErmValType;
    IndType:  TErmValType;
  
  BEGIN
    RESULT  :=  ErmScanner.GetCurrChar(c) AND GetErmValType(c, ValType);
    
    IF RESULT THEN BEGIN
      IndType :=  ValNum;
      
      IF ValType <> ValNum THEN BEGIN
        RESULT  :=
          ErmScanner.GotoNextChar   AND
          ErmScanner.GetCurrChar(c) AND
          GetErmValType(c, IndType);
        
        IF RESULT AND (IndType <> ValNum) THEN BEGIN
          ErmScanner.GotoNextChar;
        END; // .IF
      END; // .IF
      IF RESULT THEN BEGIN
        RESULT  :=  ReadNum(Arg.Value);
        
        IF RESULT THEN BEGIN
          Arg.ValType :=  ORD(IndType) SHL 4 + ORD(ValType);
        END; // .IF
      END; // .IF
    END; // .IF
  END; // .FUNCTION ReadArg
  
BEGIN
  Cmd :=  ErmCmdCach[CmdStr];
  // * * * * * //
  Res :=  TRUE;
  
  IF Cmd = NIL THEN BEGIN
    NEW(Cmd);
    FillChar(Cmd^, SIZEOF(Cmd^), 0);
    ErmScanner.Connect(CmdStr, #10);
    Res     :=  ErmScanner.ReadToken(LETTERS, CmdName) AND (LENGTH(CmdName) = 2);
    NumArgs :=  0;
    
    WHILE
      Res                                 AND
      ErmScanner.GetCurrChar(c)           AND
      (c <> ':')                          AND
      (NumArgs < ERM_CMD_MAX_PARAMS_NUM)
    DO BEGIN
      Res :=  ReadArg(Cmd.Params[NumArgs]) AND ErmScanner.GetCurrChar(c);
      
      IF Res THEN BEGIN
        INC(NumArgs);
        
        IF c = '/' THEN BEGIN
          ErmScanner.GotoNextChar;
        END; // .IF
      END; // .IF
    END; // .WHILE
    
    Res :=  Res AND ErmScanner.GotoNextChar;
    
    IF Res THEN BEGIN
      GetMem(Cmd.CmdHeader.Value, LENGTH(CmdStr) + 1);
      Utils.CopyMem(LENGTH(CmdStr) + 1, POINTER(CmdStr), Cmd.CmdHeader.Value);
      
      Cmd.CmdBody.Value   :=  Utils.PtrOfs(Cmd.CmdHeader.Value, ErmScanner.Pos - 1);
      Cmd.Name[0]         :=  CmdName[1];
      Cmd.Name[1]         :=  CmdName[2];
      Cmd.NumParams       :=  NumArgs;
      Cmd.CmdHeader.Len   :=  ErmScanner.Pos - 1;
      Cmd.CmdBody.Len     :=  LENGTH(CmdStr) - ErmScanner.Pos + 1;
      
      IF ErmCmdCach.ItemCount = ERM_CMD_CACH_LIMIT THEN BEGIN
        ClearErmCmdCach;
      END; // .IF
      
      ErmCmdCach[CmdStr]  :=  Cmd;
    END; // .IF
  END; // .IF
  
  IF NOT Res THEN BEGIN
    ShowMessage('Invalid erm command "' + CmdStr + '"');
  END // .IF
  ELSE BEGIN
    ZvsProcessCmd(Cmd);
  END; // .ELSE
END; // .PROCEDURE ExecErmCmd

PROCEDURE ReloadErm;
CONST
  SUCCESS_MES:  STRING  = '{~white}ERM is updated{~}';

VAR
  LocalizationPath: STRING;
  i:                INTEGER;

BEGIN
  IF ErmTriggerDepth = 0 THEN BEGIN
    ZvsClearErtStrings;
    ZvsClearErmScripts;
    
    IF Ini.ReadStrFromIni
    (
      'Alternate_Script_Location',
      'WoGification',
      'wog.ini',
      LocalizationPath
    )
    THEN BEGIN
      Utils.CopyMem(LENGTH(LocalizationPath) + 1, POINTER(LocalizationPath), AltScriptsPath);
    END; // .IF
    
    FOR i:=0 TO MAX_ERM_SCRIPTS_NUM - 1 DO BEGIN
      ZvsLoadErmScript(i);
    END; // .FOR
    
    ZvsIsGameLoading^ :=  TRUE;
    ZvsFindErm;
    Utils.CopyMem(LENGTH(SUCCESS_MES) + 1, POINTER(SUCCESS_MES), @z[1]);
    ExecErmCmd('IF:Lz1;');
  END; // .IF
END; // .PROCEDURE ReloadErm

PROCEDURE ExtractErm;
VAR
  Res:        BOOLEAN;
  Mes:        STRING;
  ScriptPath: STRING;
  i:          INTEGER;
  
BEGIN
  Files.DeleteDir(EXTRACTED_SCRIPTS_PATH);
  Res :=  SysUtils.CreateDir(EXTRACTED_SCRIPTS_PATH);
  
  IF NOT Res THEN BEGIN
    Mes :=  '{~red}Cannot recreate directory "' + EXTRACTED_SCRIPTS_PATH + '"{~}';
  END // .IF
  ELSE BEGIN
    i :=  0;
    
    WHILE Res AND (i < MAX_ERM_SCRIPTS_NUM) DO BEGIN
      IF ErmScripts[i] <> NIL THEN BEGIN
        ScriptPath  :=  EXTRACTED_SCRIPTS_PATH_PREFIX + SysUtils.Format('%.2d.erm', [i]);
        Res         :=  Files.WriteFileContents(ErmScripts[i] + #13#10, ScriptPath);
        IF NOT Res THEN BEGIN
          Mes :=  '{~red}Error writing to file "' + ScriptPath + '"{~}';
        END; // .IF
      END; // .IF
      
      INC(i);
    END; // .WHILE
  END; // .ELSE
  
  IF Res THEN BEGIN
    Mes :=  '{~white}Scripts were successfully extracted{~}';
  END; // .IF
  
  Utils.CopyMem(LENGTH(Mes) + 1, POINTER(Mes), @z[1]);
  ExecErmCmd('IF:Lz1;');
END; // .PROCEDURE ExtractErm

FUNCTION Hook_ProcessErm (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
  EventArgs:  TOnBeforeTriggerArgs;

BEGIN
  ShouldPreserveYVars :=  CurrErmEventID^ >= Erm.TRIGGER_FU30000;
  
  IF ShouldPreserveYVars THEN BEGIN
    Utils.CopyMem(SIZEOF(SavedYVars), @Erm.y[1], @SavedYVars[0]);
  END; // .IF
  
  INC(ErmTriggerDepth);
  EventArgs.TriggerID         :=  CurrErmEventID^;
  EventArgs.BlockErmExecution :=  FALSE;
  GameExt.FireEvent('OnBeforeTrigger', @EventArgs, SIZEOF(EventArgs));
  
  IF EventArgs.BlockErmExecution THEN BEGIN
    CurrErmEventID^ :=  TRIGGER_INVALID;
  END; // .IF
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ProcessErm_End

FUNCTION Hook_ProcessErm_End (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  GameExt.FireEvent('OnAfterTrigger', CurrErmEventID, SIZEOF(CurrErmEventID^));
  
  IF ShouldPreserveYVars THEN BEGIN
    Utils.CopyMem(SIZEOF(SavedYVars), @SavedYVars[0], @Erm.y[1]);
  END; // .IF
  
  DEC(ErmTriggerDepth);
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ProcessErm_End

{$W-}
PROCEDURE Hook_ErmCastleBuilding; ASSEMBLER;
ASM
  MOVZX EDX, BYTE [ECX + $150]
  MOVZX EAX, BYTE [ECX + $158]
  OR EDX, EAX
  PUSH $70E8A9
  // RET
END; // .PROCEDURE Hook_ErmCastleBuilding
{$W+}

FUNCTION Hook_ErmHeroArt (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  RESULT  :=  ((PINTEGER(Context.EBP - $E8)^ SHR 8) AND 7) = 0;
  
  IF NOT RESULT THEN BEGIN
    Context.RetAddr :=  Ptr($744B85);
  END; // .IF
END; // .FUNCTION Hook_ErmHeroArt

FUNCTION Hook_ErmHeroArt_FindFreeSlot (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  f[1]    :=  FALSE;
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ErmHeroArt_FindFreeSlot

FUNCTION Hook_ErmHeroArt_FoundFreeSlot (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  f[1]    :=  TRUE;
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ErmHeroArt_FoundFreeSlot

FUNCTION Hook_ErmHeroArt_BeforeDeleteMany (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  NumArtsToDelete :=  PINTEGER(Context.EBP - $3D4)^;
  RESULT          :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ErmHeroArt_BeforeDeleteMany

FUNCTION Hook_ErmHeroArt_AfterDeleteMany (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  IN_HE_A4_BLOCK  = 1;

BEGIN
  RESULT  :=  (Context.EAX AND 255) = IN_HE_A4_BLOCK;
  
  IF RESULT THEN BEGIN
    Context.EAX :=  PINTEGER(Context.EBP - $3D0)^;
  END // .IF
  ELSE BEGIN
    INC
    (
      PINTEGER(PINTEGER(Context.EBP - $380)^ + $3D4)^,  // Num arts
      PINTEGER(Context.EBP - $3D4)^ - NumArtsToDelete
    );
    Context.RetAddr :=  Ptr($745338); // Break
  END; // .ELSE
END; // .FUNCTION Hook_ErmHeroArt_AfterDeleteMany

FUNCTION Hook_DlgCallback (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NO_CMD  = 0;

BEGIN
  ErmDlgCmd^  :=  NO_CMD;
  RESULT      :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_DlgCallback

PROCEDURE OnAfterWoG (Event: GameExt.PEvent); STDCALL;
CONST
  HeA3Patch:  STRING  = #$04#$B0#$01#$EB#$02#$B0#$00;

BEGIN
  (* ERM OnAnyTrigger *)
  Core.Hook(@Hook_ProcessErm, Core.HOOKTYPE_BRIDGE, 6, Ptr($74C819));
  Core.Hook(@Hook_ProcessErm_End, Core.HOOKTYPE_BRIDGE, 5, Ptr($74CE2A));
  
  (* Fix ERM CA:B3 bug *)
  Core.Hook(@Hook_ErmCastleBuilding, Core.HOOKTYPE_JUMP, 7, Ptr($70E8A2));
  
  (* Fix HE:A art get syntax bug *)
  Core.Hook(@Hook_ErmHeroArt, Core.HOOKTYPE_BRIDGE, 9, Ptr($744B13));
  
  (* Fix HE:A# - set flag 1 as success *)
  Core.Hook(@Hook_ErmHeroArt_FindFreeSlot, Core.HOOKTYPE_BRIDGE, 10, Ptr($7454B2));
  Core.Hook(@Hook_ErmHeroArt_FoundFreeSlot, Core.HOOKTYPE_BRIDGE, 6, Ptr($7454EC));
  
  (* Fix HE:A3 artifacts delete - update art number *)
  {
    JMP L001
    MOV AL,1
    JMP L002
  L001:
    MOV AL,0
  L002:
  }
  Core.WriteAtCode(LENGTH(HeA3Patch), POINTER(HeA3Patch), Ptr($7452FF));
  Core.Hook(@Hook_ErmHeroArt_BeforeDeleteMany, Core.HOOKTYPE_BRIDGE, 10, Ptr($744F80));
  Core.Hook(@Hook_ErmHeroArt_AfterDeleteMany, Core.HOOKTYPE_BRIDGE, 7, Ptr($745306));
  
  (* Fix DL:C close all dialogs bug *)
  Core.Hook(@Hook_DlgCallback, Core.HOOKTYPE_BRIDGE, 6, Ptr($729774));
END; // .PROCEDURE OnAfterWoG

BEGIN
  ErmScanner  :=  TextScan.TTextScanner.Create;
  ErmCmdCach  :=  AssocArrays.NewSimpleAssocArr
  (
    Crypto.AnsiCRC32,
    AssocArrays.NO_KEY_PREPROCESS_FUNC
  );
  IsWoG^      :=  TRUE;
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
END.
