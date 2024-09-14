UNIT Triggers;
{
DESCRIPTION:  Extends ERM with new triggers
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  Windows, SysUtils, Utils,
  Core, GameExt, Heroes, Erm;

CONST
  NO_STACK  = -1;
  
  STACK_POS_OFS = $38;


(***) IMPLEMENTATION (***)


CONST
  (* Extended MM Trigger *)
  ATTACKER_STACK_N_PARAM  = 0;
  DEFENDER_STACK_N_PARAM  = 1;
  MIN_DAMAGE_PARAM        = 2;
  MAX_DAMAGE_PARAM        = 3;

  
VAR
  PrevWndProc:  Heroes.TWndProc;
  
  (* Calculate damage delayed parameters *)
  AttackerId:           INTEGER;
  DefenderId:           INTEGER;
  BasicDamage:          INTEGER;
  DamageBonus:          INTEGER;
  IsDistantAttack:      INTEGER;
  IsTheoreticalAttack:  INTEGER;
  Distance:             INTEGER;
  
  (* AI Calculate stack attack effect delayed parameters *)
  AIAttackerId: INTEGER;
  AIDefenderId: INTEGER;
  
  
FUNCTION Hook_BattleHint_GetAttacker (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  GameExt.EraSaveEventParams;
  GameExt.EraEventParams[ATTACKER_STACK_N_PARAM]  :=  Context.EAX;
  GameExt.EraEventParams[DEFENDER_STACK_N_PARAM]  :=  NO_STACK;
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_BattleHint_GetAttacker

FUNCTION Hook_BattleHint_GetDefender (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  GameExt.EraEventParams[DEFENDER_STACK_N_PARAM]  :=  Context.EAX;
  RESULT                                          :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_BattleHint_GetDefender

FUNCTION Hook_BattleHint_CalcMinMaxDamage (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  GameExt.EraEventParams[MIN_DAMAGE_PARAM]  :=  Context.EDI;
  GameExt.EraEventParams[MAX_DAMAGE_PARAM]  :=  Context.EAX;
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_BattleHint_CalcMinMaxDamage

FUNCTION Hook_MMTrigger (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  GameExt.EraRestoreEventParams;
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_MMTrigger

PROCEDURE OnBeforeTrigger (Event: GameExt.PEvent); STDCALL;
VAR
{U} EventArgs:      Erm.POnBeforeTriggerArgs;
    EventName:      STRING;
    BaseEventName:  STRING;
    EventID:        INTEGER;
    
    x:              INTEGER;
    y:              INTEGER;
    z:              INTEGER;
    
    ObjType:        INTEGER;
    ObjSubtype:     INTEGER;

BEGIN
  {!} ASSERT(Event <> NIL);
  EventArgs :=  Erm.POnBeforeTriggerArgs(Event.Data);
  // * * * * * //
  EventName :=  '';
  EventID   :=  EventArgs.TriggerID;
  
  CASE EventID OF
    {*} Erm.TRIGGER_FU1..Erm.TRIGGER_FU30000:
      EventName :=  'OnErmFunction ' + SysUtils.IntToStr(EventID - Erm.TRIGGER_FU1 + 1);
    {*} Erm.TRIGGER_TM1..Erm.TRIGGER_TM100:
      EventName :=  'OnErmTimer ' + SysUtils.IntToStr(EventID - Erm.TRIGGER_TM1 + 1); 
    {*} Erm.TRIGGER_HE0..Erm.TRIGGER_HE198:
      EventName :=  'OnHeroInteraction ' + SysUtils.IntToStr(EventID - Erm.TRIGGER_HE0);
    {*} Erm.TRIGGER_BA0:      EventName :=  'OnBeforeBattle';
    {*} Erm.TRIGGER_BA1:      EventName :=  'OnAfterBattle';
    {*} Erm.TRIGGER_BR:       EventName :=  'OnBattleRound';
    {*} Erm.TRIGGER_BG0:      EventName :=  'OnBeforeBattleAction';
    {*} Erm.TRIGGER_BG1:      EventName :=  'OnAfterBattleAction';
    {*} Erm.TRIGGER_MW0:      EventName :=  'OnWanderingMonsterReach';
    {*} Erm.TRIGGER_MW1:      EventName :=  'OnWanderingMonsterDeath';
    {*} Erm.TRIGGER_MR0:      EventName :=  'OnMagicBasicResistance';
    {*} Erm.TRIGGER_MR1:      EventName :=  'OnMagicCorrectedResistance';
    {*} Erm.TRIGGER_MR2:      EventName :=  'OnDwarfMagicResistance';
    {*} Erm.TRIGGER_CM0:      EventName :=  'OnAdventureMapRightMouseClick';
    {*} Erm.TRIGGER_CM1:      EventName :=  'OnTownMouseClick';
    {*} Erm.TRIGGER_CM2:      EventName :=  'OnHeroScreenMouseClick';
    {*} Erm.TRIGGER_CM3:      EventName :=  'OnHeroesMeetScreenMouseClick';
    {*} Erm.TRIGGER_CM4:      EventName :=  'OnAdventureMapMouseClick';
    {*} Erm.TRIGGER_AE0:      EventName :=  'OnEquipArt';
    {*} Erm.TRIGGER_AE1:      EventName :=  'OnUnequipArt';
    {*} Erm.TRIGGER_MM0:      EventName :=  'OnBattleMouseHint';
    {*} Erm.TRIGGER_MM1:      EventName :=  'OnTownMouseHint';
    {*} Erm.TRIGGER_CM5:      EventName :=  'OnAdventureMapLeftMouseClick';
    {*} Erm.TRIGGER_MP:       EventName :=  'OnMp3MusicChange';
    {*} Erm.TRIGGER_SN:       EventName :=  'OnSoundPlay';
    {*} Erm.TRIGGER_MG0:      EventName :=  'OnBeforeAdventureMagic';
    {*} Erm.TRIGGER_MG1:      EventName :=  'OnAfterAdventureMagic';
    {*} Erm.TRIGGER_TH0:      EventName :=  'OnEnterTown';
    {*} Erm.TRIGGER_TH1:      EventName :=  'OnLeaveTown';
    {*} Erm.TRIGGER_IP0:      EventName :=  'OnBeforeBattleBeforeDataSend';
    {*} Erm.TRIGGER_IP1:      EventName :=  'OnBeforeBattleAfterDataReceived';
    {*} Erm.TRIGGER_IP2:      EventName :=  'OnAfterBattleBeforeDataSend';
    {*} Erm.TRIGGER_IP3:      EventName :=  'OnAfterBattleAfterDataReceived';
    {*} Erm.TRIGGER_CO0:      EventName :=  'OnOpenCommanderWindow';
    {*} Erm.TRIGGER_CO1:      EventName :=  'OnCloseCommanderWindow';
    {*} Erm.TRIGGER_CO2:      EventName :=  'OnAfterCommanderBuy';
    {*} Erm.TRIGGER_CO3:      EventName :=  'OnAfterCommanderResurrect';
    {*} Erm.TRIGGER_BA50:     EventName :=  'OnBeforeBattleForThisPcDefender';
    {*} Erm.TRIGGER_BA51:     EventName :=  'OnAfterBattleForThisPcDefender';
    {*} Erm.TRIGGER_BA52:     EventName :=  'OnBeforeBattleUniversal';
    {*} Erm.TRIGGER_BA53:     EventName :=  'OnAfterBattleUniversal';
    {*} Erm.TRIGGER_GM0:      EventName :=  'OnAfterLoadGame';
    {*} Erm.TRIGGER_GM1:      EventName :=  'OnBeforeSaveGame';
    {*} Erm.TRIGGER_PI:       EventName :=  'OnAfterErmInstructions';
    {*} Erm.TRIGGER_DL:       EventName :=  'OnCustomDialogEvent';
    {*} Erm.TRIGGER_HM:       EventName :=  'OnHeroMove';
    {*} Erm.TRIGGER_HM0..Erm.TRIGGER_HM198:
      EventName :=  'OnHeroMove ' + SysUtils.IntToStr(EventID - Erm.TRIGGER_HM0);
    {*} Erm.TRIGGER_HL:   EventName :=  'OnHeroGainLevel';
    {*} Erm.TRIGGER_HL0..Erm.TRIGGER_HL198:
      EventName :=  'OnHeroGainLevel ' + SysUtils.IntToStr(EventID - Erm.TRIGGER_HL0);
    {*} Erm.TRIGGER_BF:       EventName :=  'OnSetupBattlefield';
    {*} Erm.TRIGGER_MF1:      EventName :=  'OnMonsterPhysicalDamage';
    {*} Erm.TRIGGER_TL0:      EventName :=  'OnEverySecond';
    {*} Erm.TRIGGER_TL1:      EventName :=  'OnEvery2Seconds';
    {*} Erm.TRIGGER_TL2:      EventName :=  'OnEvery5Seconds';
    {*} Erm.TRIGGER_TL3:      EventName :=  'OnEvery10Seconds';
    {*} Erm.TRIGGER_TL4:      EventName :=  'OnEveryMinute';
    (* Era Triggers *)
    {*  Erm.TRIGGER_BEFORE_SAVE_GAME:           EventName :=  'OnBeforeSaveGameEx';}
    {*} Erm.TRIGGER_SAVEGAME_WRITE:             EventName :=  'OnSavegameWrite';
    {*} Erm.TRIGGER_SAVEGAME_READ:              EventName :=  'OnSavegameRead';
    {*} Erm.TRIGGER_KEYPRESS:                   EventName :=  'OnKeyPressed';
    {*} Erm.TRIGGER_OPEN_HEROSCREEN:            EventName :=  'OnOpenHeroScreen';
    {*} Erm.TRIGGER_CLOSE_HEROSCREEN:           EventName :=  'OnCloseHeroScreen';
    {*} Erm.TRIGGER_STACK_OBTAINS_TURN:         EventName :=  'OnBattleStackObtainsTurn';
    {*} Erm.TRIGGER_REGENERATE_PHASE:           EventName :=  'OnBattleRegeneratePhase';
    {*} Erm.TRIGGER_AFTER_SAVE_GAME:            EventName :=  'OnAfterSaveGame';
    {*  Erm.TRIGGER_SKEY_SAVEDIALOG:            EventName :=  'OnSKeySaveDialog';}
    {*} Erm.TRIGGER_BEFOREHEROINTERACT:         EventName :=  'OnBeforeHeroInteraction';
    {*} Erm.TRIGGER_AFTERHEROINTERACT:          EventName :=  'OnAfterHeroInteraction';
    {*} Erm.TRIGGER_ONSTACKTOSTACKDAMAGE:       EventName :=  'OnStackToStackDamage';
    {*} Erm.TRIGGER_ONAICALCSTACKATTACKEFFECT:  EventName :=  'OnAICalcStackAttackEffect';
    {*} Erm.TRIGGER_ONCHAT:                     EventName :=  'OnChat';
    (* End Era Triggers *)
  ELSE
    IF EventID >= Erm.TRIGGER_OB_POS THEN BEGIN
      IF ((EventID AND Erm.TRIGGER_OB_POS) OR (EventID AND Erm.TRIGGER_LE_POS)) <> 0 THEN BEGIN
        x :=  EventID AND 1023;
        y :=  (EventID SHR 16) AND 1023;
        z :=  (EventID SHR 26) AND 1;
        
        IF (EventID AND Erm.TRIGGER_LE_POS) <> 0 THEN BEGIN
          BaseEventName :=  'OnLocalEvent ';
        END // .IF
        ELSE BEGIN
          IF (EventID AND Erm.TRIGGER_OB_LEAVE) <> 0 THEN BEGIN
            BaseEventName :=  'OnAfterVisitObject ';
          END // .IF
          ELSE BEGIN
            BaseEventName :=  'OnBeforeVisitObject ';
          END; // .ELSE
        END; // .ELSE
        
        EventName :=
          BaseEventName + SysUtils.IntToStr(x) + '/' +
          SysUtils.IntToStr(y) + '/' + SysUtils.IntToStr(z);
      END // .IF
      ELSE BEGIN
        ObjType     :=  (EventID SHR 12) AND 255;
        ObjSubtype  :=  (EventID AND 255) - 1;
        
        IF (EventID AND Erm.TRIGGER_OB_LEAVE) <> 0 THEN BEGIN
          BaseEventName :=  'OnAfterVisitObject ';
        END // .IF
        ELSE BEGIN
          BaseEventName :=  'OnBeforeVisitObject ';
        END; // .ELSE
        
        EventName :=
          BaseEventName + SysUtils.IntToStr(ObjType) + '/' + SysUtils.IntToStr(ObjSubtype);
      END; // .ELSE
    END; // .IF
  END; // .SWITCH
  
  IF EventName <> '' THEN BEGIN
    GameExt.FireEvent(EventName, @EventArgs.BlockErmExecution, SIZEOF(EventArgs.BlockErmExecution));
  END; // .IF
END; // .PROCEDURE OnBeforeTrigger

FUNCTION MainWndProc (hWnd, Msg, wParam, lParam: INTEGER): LONGBOOL; STDCALL;
CONST
  WM_KEYDOWN          = $100;
  KEY_F11             = 122;
  KEY_F12             = 123;
  ENABLE_DEF_REACTION = 0;

VAR
  GameState:  Heroes.TGameState;
  
BEGIN
  RESULT  :=  FALSE;
  
  IF Msg = WM_KEYDOWN THEN BEGIN
    Heroes.GetGameState(GameState);
    
    IF
      (GameState.RootDlgId = Heroes.ADVMAP_DLGID) AND
      (wParam IN [KEY_F11, KEY_F12])
    THEN BEGIN
      CASE wParam OF 
        KEY_F12:  Erm.ReloadErm;
        KEY_F11:  Erm.ExtractErm;
      END; // .SWITCH
    END // .IF
    ELSE BEGIN
      GameExt.EraSaveEventParams;
      
      GameExt.EraEventParams[0] :=  wParam;
      GameExt.EraEventParams[1] :=  ENABLE_DEF_REACTION;
      
      IF GameState.RootDlgId = Heroes.ADVMAP_DLGID THEN BEGIN
        Erm.FireErmEvent(Erm.TRIGGER_KEYPRESS);
      END // .IF
      ELSE BEGIN
        GameExt.FireEvent('OnKeyPressed', GameExt.NO_EVENT_DATA, 0);
      END; // .ELSE
      
      RESULT  :=  GameExt.EraEventParams[1] = ENABLE_DEF_REACTION;
      
      GameExt.EraRestoreEventParams;
      
      IF RESULT THEN BEGIN
        PrevWndProc(hWnd, Msg, wParam, lParam);
      END; // .IF
    END; // .ELSE
  END // .IF
  ELSE BEGIN
    RESULT  :=  PrevWndProc(hWnd, Msg, wParam, lParam);
  END; // .ELSE
END; // .FUNCTION MainWndProc

FUNCTION Hook_CreateWindow (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  PrevWndProc :=  Ptr
  (
    Windows.SetWindowLong(Heroes.hWnd^, Windows.GWL_WNDPROC, INTEGER(@MainWndProc))
  );
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_CreateWindow

FUNCTION Hook_BeforeErmInstructions (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  IF NOT Erm.ZvsIsGameLoading^ THEN BEGIN
    GameExt.EraSaveEventParams;
    GameExt.FireEvent('OnBeforeErmInstructions', GameExt.NO_EVENT_DATA, 0);
    GameExt.EraRestoreEventParams;
  END; // .IF
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_BeforeErmInstructions

FUNCTION Hook_StartCalcDamage (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  AttackerId  :=  Heroes.GetBattleCellStackId
    (Heroes.GetBattleCellByPos(PINTEGER(Context.EBX + STACK_POS_OFS)^));
  DefenderId  :=  Heroes.GetBattleCellStackId
    (Heroes.GetBattleCellByPos(PINTEGER(Context.ESI + STACK_POS_OFS)^));
  
  BasicDamage         :=  PINTEGER(Context.EBP + 12)^;
  IsDistantAttack     :=  PINTEGER(Context.EBP + 16)^;
  IsTheoreticalAttack :=  PINTEGER(Context.EBP + 20)^;
  Distance            :=  PINTEGER(Context.EBP + 24)^;
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_StartCalcDamage

FUNCTION Hook_CalcDamage_GetDamageBonus (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  DamageBonus :=  Context.EAX;
  RESULT      :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_CalcDamage_GetDamageBonus

FUNCTION Hook_EndCalcDamage (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  ATTACKER            = 0;
  DEFENDER            = 1;
  FINAL_DAMAGE_CONST  = 2;
  FINAL_DAMAGE        = 3;
  BASIC_DAMAGE        = 4;
  DAMAGE_BONUS        = 5;
  IS_DISTANT          = 6;
  DISTANCE_ARG        = 7;
  IS_THEORETICAL      = 8;

BEGIN
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
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_EndCalcDamage

FUNCTION Hook_AI_CalcStackAttackEffect_Start (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  AIAttackerId  :=  Heroes.GetBattleCellStackId
    (Heroes.GetBattleCellByPos(PINTEGER(PINTEGER(Context.ESP + 8)^ + STACK_POS_OFS)^));
  AIDefenderId  :=  Heroes.GetBattleCellStackId
    (Heroes.GetBattleCellByPos(PINTEGER(PINTEGER(Context.ESP + 16)^ + STACK_POS_OFS)^));
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_AI_CalcStackAttackEffect_Start

FUNCTION Hook_AI_CalcStackAttackEffect_End (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  ATTACKER            = 0;
  DEFENDER            = 1;
  EFFECT_VALUE        = 2;
  EFFECT_VALUE_CONST  = 3;

BEGIN
  GameExt.EraSaveEventParams;

  GameExt.EraEventParams[ATTACKER]            :=  AIAttackerId;
  GameExt.EraEventParams[DEFENDER]            :=  AIDefenderId;
  GameExt.EraEventParams[EFFECT_VALUE]        :=  Context.EAX;
  GameExt.EraEventParams[EFFECT_VALUE_CONST]  :=  Context.EAX;

  Erm.FireErmEvent(Erm.TRIGGER_ONAICALCSTACKATTACKEFFECT);
  Context.EAX :=  GameExt.EraEventParams[EFFECT_VALUE];
  
  GameExt.EraRestoreEventParams;
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_AI_CalcStackAttackEffect_End

FUNCTION Hook_EnterChat (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS  = 0;
  
  (* Event parameters *)
  EVENT_SUBTYPE = 0;
  BLOCK_CHAT    = 1;
  
  ON_ENTER_CHAT = 0;

BEGIN
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[EVENT_SUBTYPE] :=  ON_ENTER_CHAT;
  GameExt.EraEventParams[BLOCK_CHAT]    :=  0;
  
  Erm.FireErmEvent(Erm.TRIGGER_ONCHAT);
  RESULT  :=  NOT LONGBOOL(GameExt.EraEventParams[BLOCK_CHAT]);
  
  GameExt.EraRestoreEventParams;
  
  IF NOT RESULT THEN BEGIN
    Context.RetAddr :=  Core.Ret(NUM_ARGS);
  END; // .IF
END; // .FUNCTION Hook_EnterChat

PROCEDURE ClearChatBox; ASSEMBLER;
ASM
  PUSH ESI
  MOV ESI, ECX
  MOV EAX, [ESI + $38]
  PUSH $5547A0
  // RET
END; // .PROCEDURE ClearChatBox

FUNCTION Hook_ChatInput (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST 
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

VAR
  Action: INTEGER;
  Obj:    INTEGER;
  
BEGIN
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[ARG_EVENT_SUBTYPE] :=  ON_CHAT_INPUT;
  GameExt.EraEventParams[ARG_CHAT_INPUT]    :=  PINTEGER(Context.ECX + $34)^;
  GameExt.EraEventParams[ARG_ACTION]        :=  ACTION_DEFAULT;
  
  Erm.FireErmEvent(Erm.TRIGGER_ONCHAT);
  Action  :=  GameExt.EraEventParams[ARG_ACTION];
  Obj     :=  Context.ECX;
  
  GameExt.EraRestoreEventParams;
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
  
  CASE Action OF 
    ACTION_CLEAR_BOX: Context.RetAddr :=  @ClearChatBox;
    ACTION_CLOSE_BOX: BEGIN
      Context.RetAddr :=  @ClearChatBox;
    
      ASM
        MOV ECX, Obj
        MOV EDX, [ECX]
        MOV EAX, [EDX + $64]
        CALL EAX
      END; // .ASM
    END; // .CASE ACTION_CLOSE_BOX    
  ELSE
    RESULT  :=  Core.EXEC_DEF_CODE;
  END; // .SWITCH Action
END; // .FUNCTION Hook_ChatInput

FUNCTION Hook_LeaveChat (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  (* Event parameters *)
  EVENT_SUBTYPE = 0;
  
  ON_LEAVE_CHAT = 2;

BEGIN
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[EVENT_SUBTYPE] :=  ON_LEAVE_CHAT;
  Erm.FireErmEvent(Erm.TRIGGER_ONCHAT);
  
  GameExt.EraRestoreEventParams;
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_LeaveChat

PROCEDURE OnAfterWoG (Event: GameExt.PEvent); STDCALL;
BEGIN
  (* Extended MM Trigger *)
  Core.Hook(@Hook_BattleHint_GetAttacker, Core.HOOKTYPE_BRIDGE, 7, Ptr($492409));
  Core.Hook(@Hook_BattleHint_GetDefender, Core.HOOKTYPE_BRIDGE, 7, Ptr($492442));
  Core.Hook(@Hook_BattleHint_CalcMinMaxDamage, Core.HOOKTYPE_BRIDGE, 5, Ptr($493053));
  Core.Hook(@Hook_MMTrigger, Core.HOOKTYPE_BRIDGE, 5, Ptr($74FD34));
  
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
END; // .PROCEDURE OnAfterWoG

BEGIN
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
  GameExt.RegisterHandler(OnBeforeTrigger, 'OnBeforeTrigger');
END.
