UNIT Triggers;
{!INFO
MODULENAME = 'Triggers'
VERSION = '3.0'
AUTHOR = 'Berserker'
DESCRIPTION = '���������� ����� ������� ��� ���'
}

(***)  INTERFACE  (***)
USES Win, Utils, General;

PROCEDURE Init;


(***)  IMPLEMENTATION  (***)


PROCEDURE Hook_SaveGame_Pack; ASSEMBLER; {$FRAME-}
ASM
  PUSHAD
  // ������ �������� CustomSaveGameHandler
  MOV EAX, General.CustomSaveGameHandler
  TEST EAX, EAX
  JZ @@CallErmTrigger
    CALL EAX
  @@CallErmTrigger:
  // �������� ���-�������
  PUSH General.C_ERA_EVENT_SAVEGAME_PACK
  CALL General.GenerateCustomErmEvent
  // ��������� ���������� ������������ ZVS
  POPAD
  // ��������� ������ ���
  CMP DWORD [EBP-4],0
  JNZ @@1
  PUSH $704EF2
  RET
@@1:
  PUSH $704F10
END; // .procedure Hook_SaveGame_Pack

PROCEDURE Hook_LoadGame_Unpack; ASSEMBLER; {$FRAME-}
ASM
  PUSHAD
  //������ �������� CustomLoadGameHandler
  MOV EAX, General.CustomLoadGameHandler
  TEST EAX, EAX
  JZ @@CallErmEvent
    CALL EAX
  @@CallErmEvent:
  // ���������� ���-�������
  PUSH General.C_ERA_EVENT_LOADGAME_UNPACK
  CALL General.GenerateCustomErmEvent
  // � ������ ���������� ��������� ���
  POPAD
  CMP DWORD [EBP-$14],0
  JNZ @@2
  PUSH $7051BE
  RET
@@2:
  PUSH $7051DC
  RET
END; // .procedure Hook_LoadGame_Unpack

PROCEDURE Hook_HeroScreen_Enter; ASSEMBLER; {$FRAME-}
ASM
  // ��������� �������� � ����
  PUSHAD
  // ������������� �������� �������� ����� ��� ���
  PUSH ECX
  MOV EAX, General.C_FUNC_ZVS_GETHEROPTR
  CALL EAX
  ADD ESP, 4
  MOV DWORD [General.C_VAR_ERM_PTR_CURRHERO], EAX
  // ������������� ���-�������
  PUSH General.C_ERA_EVENT_HEROSCREEN_ENTER
  CALL General.GenerateCustomErmEvent
  // ������������ ��������
  POPAD
  // ��������� �������� ��� � �����������
  PUSH EBP
  MOV EBP, ESP
  PUSH -1
  PUSH $4E1A75
  // RET
END; // .procedure Hook_HeroScreen_Enter

PROCEDURE Hook_HeroScreen_Exit; ASSEMBLER; {$FRAME-}
ASM
  // ��������� �������� � ����
  PUSHAD
  // ������������� ���-�������
  PUSH General.C_ERA_EVENT_HEROSCREEN_EXIT
  CALL General.GenerateCustomErmEvent
  // ������������ ��������
  POPAD
  // ��������� �������� ��� � ����������� ����� �� � �������, ��������� HeroScreenDialog
  MOV ESP, EBP
  POP EBP
  RET 8
END; // .procedure Hook_HeroScreen_Exit

PROCEDURE Hook_Battle_WhoMoves; ASSEMBLER; {$FRAME-}
ASM
  // ������������� ���������� ����
  PUSH EBP
  MOV EBP,ESP
  PUSH -1
  // ���������� ��� �������
  PUSHAD
  MOV EAX, [EBP+$8]
  MOV DWORD [General.EventParams], EAX
  MOV EAX, [EBP+$C]
  MOV DWORD [General.EventParams+4], EAX
  PUSH General.C_ERA_EVENT_BATTLE_WHOMOVES
  CALL General.GenerateCustomErmEvent
  POPAD
  // ������������� ����������� �� ��� ��������
  MOV EAX, DWORD [General.EventParams]
  MOV [EBP+$8], EAX
  MOV EAX, DWORD[General.EventParams+4]
  MOV [EBP+$C], EAX
  PUSH $464F15
  // RET
END; // .procedure Hook_Battle_WhoMoves

PROCEDURE Hook_Battle_BeforeAction; ASSEMBLER; {$FRAME-}
ASM
  // ��������� ��������� �� TBattleMonster
  PUSH ECX
  // ������������� ������ �������� ������� - ��������� �� TBattleMonster
  MOV DWORD [General.EventParams+4], ECX
  // �������� ����� ����
  MOV EAX, [$699420]
  ADD EAX, $54CC
  XCHG EAX, ECX
  SUB EAX, ECX
  MOV ECX, 1352 // SIZEOF(TBattleMonster)
  XOR EDX, EDX
  DIV ECX
  MOV DWORD [General.EventParams], EAX
  // �� ��������� ����������� �������, ����� � �.�. ���������
  MOV DWORD [General.EventParams+8], 0
  // ���������� ��� �������
  PUSH General.C_ERA_EVENT_BATTLE_BEFOREACTION
  CALL General.GenerateCustomErmEvent
  // ��������������� �������� � �������
  POP ECX
  PUSH EBP
  MOV EBP,ESP
  PUSH -1
  PUSH $446B55
  // RET
END; // .procedure Hook_Battle_BeforeAction

PROCEDURE Hook_Battle_TrollsRegen; ASSEMBLER; {$FRAME-}
ASM
  CMP DWORD [General.EventParams+8], 0
  JZ @@DontBlock
  XOR EAX, EAX
  PUSH $446BDB
  RET
  @@DontBlock:
  PUSH $446BDB
  PUSH $75DE4F
END; // .procedure Hook_Battle_TrollsRegen

PROCEDURE Init;
BEGIN
  // ������ ����� ��������� ������ ������ ZVS � ����
  General.HookCode(Ptr($704EEC), @Hook_SaveGame_Pack, C_HOOKTYPE_JUMP, 5);
  // ������ ����� ��������� �������� ������ ZVS �� �����
  General.HookCode(Ptr($7051B8), @Hook_LoadGame_Unpack, C_HOOKTYPE_JUMP, 5);
  // ������ ���� � ���� �����
  General.HookCode(Ptr($4E1A70), @Hook_HeroScreen_Enter, C_HOOKTYPE_JUMP, 5);
  // ������ ������ �� ���� �����
  General.HookCode(Ptr($4E1C7F), @Hook_HeroScreen_Exit, C_HOOKTYPE_JUMP, 6);
  General.HookCode(Ptr($4E1CB9), @Hook_HeroScreen_Exit, C_HOOKTYPE_JUMP, 6);
  // ������ ����� �������, ��� ������ �����
  General.HookCode(Ptr($464F10), @Hook_Battle_WhoMoves, C_HOOKTYPE_JUMP, 5);
  // ������ ������� �� ��������
  General.HookCode(Ptr($446B50), @Hook_Battle_BeforeAction, C_HOOKTYPE_JUMP, 5);
  // ������ ����������� �������, �����...
  General.HookCode(Ptr($446BD6), @Hook_Battle_TrollsRegen, C_HOOKTYPE_JUMP, 5);
END; // .procedure Init

END.
