unit Triggers;
{
DESCRIPTION:  Extends ERM with new triggers
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, SysUtils, Utils,
  Core, PatchApi, GameExt, Heroes, Erm;

const
  NO_STACK  = -1;
  
  STACK_POS_OFS = $38;


(***) implementation (***)


const
  (* extended MM Trigger *)
  ATTACKER_STACK_N_PARAM  = 0;
  DEFENDER_STACK_N_PARAM  = 1;
  MIN_DAMAGE_PARAM        = 2;
  MAX_DAMAGE_PARAM        = 3;

  
var
  PrevWndProc:  Heroes.TWndProc;
  
  (* Calculate damage delayed parameters *)
  AttackerId:           integer;
  DefenderId:           integer;
  BasicDamage:          integer;
  DamageBonus:          integer;
  IsDistantAttack:      integer;
  IsTheoreticalAttack:  integer;
  Distance:             integer;
  
  (* AI Calculate stack attack effect delayed parameters *)
  AIAttackerId: integer;
  AIDefenderId: integer;
  
  (* Controlling OnGameEnter and OnGameLeave events *)
  MainGameLoopDepth: integer = 0;
  
  
function Hook_BattleHint_GetAttacker (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  GameExt.EraSaveEventParams;
  GameExt.EraEventParams[ATTACKER_STACK_N_PARAM]  :=  Context.EAX;
  GameExt.EraEventParams[DEFENDER_STACK_N_PARAM]  :=  NO_STACK;
  GameExt.EraEventParams[MIN_DAMAGE_PARAM]        :=  -1;
  GameExt.EraEventParams[MAX_DAMAGE_PARAM]        :=  -1;
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_BattleHint_GetAttacker

function Hook_BattleHint_GetDefender (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  GameExt.EraEventParams[DEFENDER_STACK_N_PARAM]  :=  Context.EAX;
  result                                          :=  Core.EXEC_DEF_CODE;
end; // .function Hook_BattleHint_GetDefender

function Hook_BattleHint_CalcMinMaxDamage (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  GameExt.EraEventParams[MIN_DAMAGE_PARAM]  :=  Context.EDI;
  GameExt.EraEventParams[MAX_DAMAGE_PARAM]  :=  Context.EAX;
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_BattleHint_CalcMinMaxDamage

function Hook_MMTrigger (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  GameExt.EraRestoreEventParams;
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_MMTrigger

procedure OnBeforeTrigger (Event: GameExt.PEvent); stdcall;
var
{U} EventArgs: Erm.POnBeforeTriggerArgs;
    TriggerId: integer;

begin
  {!} Assert(Event <> nil);
  EventArgs :=  Erm.POnBeforeTriggerArgs(Event.Data);
  // * * * * * //
  TriggerId := EventArgs.TriggerId;
  
  GameExt.FireEvent('OnTrigger ' + SysUtils.IntToStr(TriggerId), @EventArgs.BlockErmExecution, sizeof(EventArgs.BlockErmExecution));

  if not EventArgs.BlockErmExecution then begin
    GameExt.FireEvent(Erm.GetTriggerReadableName(TriggerId), @EventArgs.BlockErmExecution, sizeof(EventArgs.BlockErmExecution));
  end;
end; // .procedure OnBeforeTrigger

function MainWndProc (hWnd, Msg, wParam, lParam: integer): LONGBOOL; stdcall;
const
  WM_KEYDOWN          = $100;
  KEY_F11             = 122;
  KEY_F12             = 123;
  ENABLE_DEF_REACTION = 0;

var
  GameState: Heroes.TGameState;
  SavedV:    array [1..10] of integer;
  SavedZ:    Erm.TErmZVar;
  
begin
  result := false;
  
  if Msg = WM_KEYDOWN then begin
    Heroes.GetGameState(GameState);
    
    if wParam = KEY_F11 then begin
      GameExt.GenerateDebugInfo;

      if GameState.RootDlgId = Heroes.ADVMAP_DLGID then begin
        Erm.PrintChatMsg('{~white}Debug information was dumped to ' + GameExt.DEBUG_DIR +'{~}');
      end; // .if
    end else if (wParam = KEY_F12) and (GameState.RootDlgId = Heroes.ADVMAP_DLGID) then begin
      Erm.ReloadErm;
    end // .else
    else begin
      GameExt.EraSaveEventParams;
      
      GameExt.EraEventParams[0] := wParam;
      GameExt.EraEventParams[1] := ENABLE_DEF_REACTION;
      
      if GameState.RootDlgId = Heroes.ADVMAP_DLGID then begin
        Utils.CopyMem(sizeof(SavedV), @Erm.v[1], @SavedV);
        Utils.CopyMem(sizeof(SavedZ), @Erm.z[1], @SavedZ);
        
        Erm.FireErmEvent(Erm.TRIGGER_KEYPRESS);

        Utils.CopyMem(sizeof(SavedV), @SavedV, @Erm.v[1]);
        Utils.CopyMem(sizeof(SavedZ), @SavedZ, @Erm.z[1]);
      end // .if
      else begin
        GameExt.FireEvent('OnKeyPressed', GameExt.NO_EVENT_DATA, 0);
      end; // .else
      
      result := GameExt.EraEventParams[1] = ENABLE_DEF_REACTION;
      
      GameExt.EraRestoreEventParams;
      
      if result then begin
        PrevWndProc(hWnd, Msg, wParam, lParam);
      end; // .if
    end; // .else
  end // .if
  else begin
    result := PrevWndProc(hWnd, Msg, wParam, lParam);
  end; // .else
end; // .function MainWndProc

function Hook_CreateWindow (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  PrevWndProc := Ptr
  (
    Windows.SetWindowLong(Heroes.hWnd^, Windows.GWL_WNDPROC, integer(@MainWndProc))
  );
  
  result := Core.EXEC_DEF_CODE;
end; // .function Hook_CreateWindow

function Hook_BeforeErmInstructions (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  GameExt.EraSaveEventParams;
  GameExt.FireEvent('OnBeforeErm', GameExt.NO_EVENT_DATA, 0);
  GameExt.EraRestoreEventParams;

  if not Erm.ZvsIsGameLoading^ then begin
    GameExt.EraSaveEventParams;
    GameExt.FireEvent('OnBeforeErmInstructions', GameExt.NO_EVENT_DATA, 0);
    GameExt.EraRestoreEventParams;
  end; // .if
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_BeforeErmInstructions

function Hook_StartCalcDamage (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  AttackerId  :=  Heroes.GetStackIdByPos(PINTEGER(Context.EBX + STACK_POS_OFS)^);
  DefenderId  :=  Heroes.GetStackIdByPos(PINTEGER(Context.ESI + STACK_POS_OFS)^);
  
  BasicDamage         :=  PINTEGER(Context.EBP + 12)^;
  IsDistantAttack     :=  PINTEGER(Context.EBP + 16)^;
  IsTheoreticalAttack :=  PINTEGER(Context.EBP + 20)^;
  Distance            :=  PINTEGER(Context.EBP + 24)^;
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_StartCalcDamage

function Hook_CalcDamage_GetDamageBonus (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  DamageBonus :=  Context.EAX;
  result      :=  Core.EXEC_DEF_CODE;
end; // .function Hook_CalcDamage_GetDamageBonus

function Hook_EndCalcDamage (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  ATTACKER            = 0;
  DEFENDER            = 1;
  FINAL_DAMAGE_CONST  = 2;
  FINAL_DAMAGE        = 3;
  BASIC_DAMAGE        = 4;
  DAMAGE_BONUS        = 5;
  IS_DISTANT          = 6;
  DISTANCE_ARG        = 7;
  IS_THEORETICAL      = 8;

begin
  GameExt.EraSaveEventParams;

  GameExt.EraEventParams[ATTACKER]            :=  AttackerId;
  GameExt.EraEventParams[DEFENDER]            :=  DefenderId;
  GameExt.EraEventParams[FINAL_DAMAGE_CONST]  :=  Context.EAX;
  GameExt.EraEventParams[FINAL_DAMAGE]        :=  Context.EAX;
  GameExt.EraEventParams[BASIC_DAMAGE]        :=  BasicDamage;
  GameExt.EraEventParams[DAMAGE_BONUS]        :=  DamageBonus;
  GameExt.EraEventParams[IS_DISTANT]          :=  IsDistantAttack;
  GameExt.EraEventParams[DISTANCE_ARG]        :=  Distance;
  GameExt.EraEventParams[IS_THEORETICAL]      :=  IsTheoreticalAttack;

  Erm.FireErmEvent(Erm.TRIGGER_ONSTACKTOSTACKDAMAGE);
  Context.EAX :=  GameExt.EraEventParams[FINAL_DAMAGE];
  
  GameExt.EraRestoreEventParams;
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_EndCalcDamage

function Hook_AI_CalcStackAttackEffect_Start (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  AIAttackerId  :=  Heroes.GetBattleCellStackId
    (Heroes.GetBattleCellByPos(PINTEGER(PINTEGER(Context.ESP + 8)^ + STACK_POS_OFS)^));
  AIDefenderId  :=  Heroes.GetBattleCellStackId
    (Heroes.GetBattleCellByPos(PINTEGER(PINTEGER(Context.ESP + 16)^ + STACK_POS_OFS)^));
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_AI_CalcStackAttackEffect_Start

function Hook_AI_CalcStackAttackEffect_End (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  ATTACKER            = 0;
  DEFENDER            = 1;
  EFFECT_VALUE        = 2;
  EFFECT_VALUE_CONST  = 3;

begin
  GameExt.EraSaveEventParams;

  GameExt.EraEventParams[ATTACKER]            :=  AIAttackerId;
  GameExt.EraEventParams[DEFENDER]            :=  AIDefenderId;
  GameExt.EraEventParams[EFFECT_VALUE]        :=  Context.EAX;
  GameExt.EraEventParams[EFFECT_VALUE_CONST]  :=  Context.EAX;

  Erm.FireErmEvent(Erm.TRIGGER_ONAICALCSTACKATTACKEFFECT);
  Context.EAX :=  GameExt.EraEventParams[EFFECT_VALUE];
  
  GameExt.EraRestoreEventParams;
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_AI_CalcStackAttackEffect_End

function Hook_EnterChat (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  NUM_ARGS  = 0;
  
  (* Event parameters *)
  EVENT_SUBTYPE = 0;
  BLOCK_CHAT    = 1;
  
  ON_ENTER_CHAT = 0;

begin
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[EVENT_SUBTYPE] :=  ON_ENTER_CHAT;
  GameExt.EraEventParams[BLOCK_CHAT]    :=  0;
  
  Erm.FireErmEvent(Erm.TRIGGER_ONCHAT);
  result  :=  not LONGBOOL(GameExt.EraEventParams[BLOCK_CHAT]);
  
  GameExt.EraRestoreEventParams;
  
  if not result then begin
    Context.RetAddr :=  Core.Ret(NUM_ARGS);
  end; // .if
end; // .function Hook_EnterChat

procedure ClearChatBox; ASSEMBLER;
asm
  PUSH ESI
  MOV ESI, ECX
  MOV EAX, [ESI + $38]
  PUSH $5547A0
  // RET
end; // .procedure ClearChatBox

function Hook_ChatInput (Context: Core.PHookContext): LONGBOOL; stdcall;
const 
  (* Event parameters *)
  ARG_EVENT_SUBTYPE = 0;
  ARG_CHAT_INPUT    = 1;
  ARG_ACTION        = 2;
  
  (* Event subtype *)
  ON_CHAT_INPUT = 1;
  
  (* Action flags *)
  ACTION_CLEAR_BOX  = 0;
  ACTION_CLOSE_BOX  = 1;
  ACTION_DEFAULT    = 2;

var
  Action: integer;
  Obj:    integer;
  
begin
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[ARG_EVENT_SUBTYPE] :=  ON_CHAT_INPUT;
  GameExt.EraEventParams[ARG_CHAT_INPUT]    :=  PINTEGER(Context.ECX + $34)^;
  GameExt.EraEventParams[ARG_ACTION]        :=  ACTION_DEFAULT;
  
  Erm.FireErmEvent(Erm.TRIGGER_ONCHAT);
  Action  :=  GameExt.EraEventParams[ARG_ACTION];
  Obj     :=  Context.ECX;
  
  GameExt.EraRestoreEventParams;
  
  result  :=  not Core.EXEC_DEF_CODE;
  
  case Action of 
    ACTION_CLEAR_BOX: Context.RetAddr :=  @ClearChatBox;
    ACTION_CLOSE_BOX: begin
      Context.RetAddr :=  @ClearChatBox;
    
      asm
        MOV ECX, Obj
        MOV EDX, [ECX]
        MOV EAX, [EDX + $64]
        CALL EAX
      end; // .asm
    end; // .case ACTION_CLOSE_BOX    
  else
    result  :=  Core.EXEC_DEF_CODE;
  end; // .switch Action
end; // .function Hook_ChatInput

function Hook_LeaveChat (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  (* Event parameters *)
  EVENT_SUBTYPE = 0;
  
  ON_LEAVE_CHAT = 2;

begin
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[EVENT_SUBTYPE] := ON_LEAVE_CHAT;
  Erm.FireErmEvent(Erm.TRIGGER_ONCHAT);
  
  GameExt.EraRestoreEventParams;
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_LeaveChat

procedure Hook_MainGameLoop (h: PatchApi.THiHook; This: pointer); stdcall;
begin
  if MainGameLoopDepth = 0 then begin
    Erm.FireErmEventEx(Erm.TRIGGER_ONGAMEENTER, []);
  end; // .if
  
  Inc(MainGameLoopDepth);
  PatchApi.Call(PatchApi.THISCALL_, h.GetDefaultFunc(), [This]);
  Dec(MainGameLoopDepth);
  
  if MainGameLoopDepth = 0 then begin
    Erm.FireErmEventEx(Erm.TRIGGER_ONGAMELEAVE, []);
    GameExt.SetMapFolder('');
  end; // .if
end; // .procedure Hook_MainGameLoop

procedure OnAfterWoG (Event: GameExt.PEvent); stdcall;
begin
  (* extended MM Trigger *)
  Core.Hook(@Hook_BattleHint_GetAttacker, Core.HOOKTYPE_BRIDGE, 7, Ptr($492409));
  Core.Hook(@Hook_BattleHint_GetDefender, Core.HOOKTYPE_BRIDGE, 7, Ptr($492442));
  Core.Hook(@Hook_BattleHint_CalcMinMaxDamage, Core.HOOKTYPE_BRIDGE, 5, Ptr($493053));
  Core.Hook(@Hook_MMTrigger, Core.HOOKTYPE_BRIDGE, 5, Ptr($74FD3B));
  
  (* Key handling trigger *)
  Core.Hook(@Hook_CreateWindow, Core.HOOKTYPE_BRIDGE, 6, Ptr($4F8239));
  
  (* Erm before instructions trigger *)
  Core.Hook(@Hook_BeforeErmInstructions, Core.HOOKTYPE_BRIDGE, 6, Ptr($749BBA));
  
  (* Stack to stack damage calculation *)
  Core.Hook(@Hook_StartCalcDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($443C88));
  Core.Hook(@Hook_CalcDamage_GetDamageBonus, Core.HOOKTYPE_BRIDGE, 5, Ptr($443CA1));
  Core.Hook(@Hook_EndCalcDamage, Core.HOOKTYPE_BRIDGE, 5, Ptr($443DA7));
  
  (* AI Target attack effect *)
  Core.Hook(@Hook_AI_CalcStackAttackEffect_Start, Core.HOOKTYPE_BRIDGE, 6, Ptr($4357E0));
  Core.Hook(@Hook_AI_CalcStackAttackEffect_End, Core.HOOKTYPE_BRIDGE, 5, Ptr($4358AA));
  
  (* OnChat trigger *)
  Core.Hook(@Hook_EnterChat, Core.HOOKTYPE_BRIDGE, 5, Ptr($4022B0));
  Core.Hook(@Hook_ChatInput, Core.HOOKTYPE_BRIDGE, 6, Ptr($554780));
  Core.Hook(@Hook_LeaveChat, Core.HOOKTYPE_BRIDGE, 6, Ptr($402298));
  Core.Hook(@Hook_LeaveChat, Core.HOOKTYPE_BRIDGE, 6, Ptr($402240));
  
  (* MainGameCycle: OnEnterGame, OnLeaveGame and MapFolder settings*)
  Core.p.WriteHiHook(Ptr($4B0BA0), PatchApi.SPLICE_, PatchApi.EXTENDED_, PatchApi.THISCALL_,
                     @Hook_MainGameLoop);
end; // .procedure OnAfterWoG

begin
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
  GameExt.RegisterHandler(OnBeforeTrigger, 'OnBeforeTrigger');
end.
