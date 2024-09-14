UNIT Triggers;
{!INFO
MODULENAME = 'Triggers'
VERSION = '3.0'
AUTHOR = 'Berserker'
DESCRIPTION = 'Реализация новых событий для Эры'
}

(***)  INTERFACE  (***)
USES Win, Utils, General;

PROCEDURE Init;


(***)  IMPLEMENTATION  (***)


PROCEDURE Hook_SaveGame_Pack; ASSEMBLER; {$FRAME-}
ASM
  PUSHAD
  // Сперва вызываем CustomSaveGameHandler
  MOV EAX, General.CustomSaveGameHandler
  TEST EAX, EAX
  JZ @@CallErmTrigger
    CALL EAX
  @@CallErmTrigger:
  // Вызываем ерм-триггер
  PUSH General.C_ERA_EVENT_SAVEGAME_PACK
  CALL General.GenerateCustomErmEvent
  // Возвращем управление перехватчику ZVS
  POPAD
  // Выполняем старый код
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
  //Сперва вызываем CustomLoadGameHandler
  MOV EAX, General.CustomLoadGameHandler
  TEST EAX, EAX
  JZ @@CallErmEvent
    CALL EAX
  @@CallErmEvent:
  // Генерируем ЕРМ-событие
  PUSH General.C_ERA_EVENT_LOADGAME_UNPACK
  CALL General.GenerateCustomErmEvent
  // А теперь продолжаем дефолтный код
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
  // Сохранили регистры в стёке
  PUSHAD
  // Устанавливаем значение текущего героя для ЕРМ
  PUSH ECX
  MOV EAX, General.C_FUNC_ZVS_GETHEROPTR
  CALL EAX
  ADD ESP, 4
  MOV DWORD [General.C_VAR_ERM_PTR_CURRHERO], EAX
  // Сгенерировали ЕРМ-событие
  PUSH General.C_ERA_EVENT_HEROSCREEN_ENTER
  CALL General.GenerateCustomErmEvent
  // Восстановили регистры
  POPAD
  // Выполнили исходный код и возратились
  PUSH EBP
  MOV EBP, ESP
  PUSH -1
  PUSH $4E1A75
  // RET
END; // .procedure Hook_HeroScreen_Enter

PROCEDURE Hook_HeroScreen_Exit; ASSEMBLER; {$FRAME-}
ASM
  // Сохранили регистры в стёке
  PUSHAD
  // Сгенерировали ЕРМ-событие
  PUSH General.C_ERA_EVENT_HEROSCREEN_EXIT
  CALL General.GenerateCustomErmEvent
  // Восстановили регистры
  POPAD
  // Выполнили исходный код и возратились сразу же к функции, вызвавшей HeroScreenDialog
  MOV ESP, EBP
  POP EBP
  RET 8
END; // .procedure Hook_HeroScreen_Exit

PROCEDURE Hook_Battle_WhoMoves; ASSEMBLER; {$FRAME-}
ASM
  // Инициализация дефолтного кода
  PUSH EBP
  MOV EBP,ESP
  PUSH -1
  // Генерируем ЕРМ событие
  PUSHAD
  MOV EAX, [EBP+$8]
  MOV DWORD [General.EventParams], EAX
  MOV EAX, [EBP+$C]
  MOV DWORD [General.EventParams+4], EAX
  PUSH General.C_ERA_EVENT_BATTLE_WHOMOVES
  CALL General.GenerateCustomErmEvent
  POPAD
  // Устанавливаем возращённые из ЕРМ значения
  MOV EAX, DWORD [General.EventParams]
  MOV [EBP+$8], EAX
  MOV EAX, DWORD[General.EventParams+4]
  MOV [EBP+$C], EAX
  PUSH $464F15
  // RET
END; // .procedure Hook_Battle_WhoMoves

PROCEDURE Hook_Battle_BeforeAction; ASSEMBLER; {$FRAME-}
ASM
  // Сохраняем указатель на TBattleMonster
  PUSH ECX
  // Устанавливаем второй параметр события - указатель на TBattleMonster
  MOV DWORD [General.EventParams+4], ECX
  // Получаем номер стёка
  MOV EAX, [$699420]
  ADD EAX, $54CC
  XCHG EAX, ECX
  SUB EAX, ECX
  MOV ECX, 1352 // SIZEOF(TBattleMonster)
  XOR EDX, EDX
  DIV ECX
  MOV DWORD [General.EventParams], EAX
  // По умолчанию регенерация троллей, духов и т.д. разрешена
  MOV DWORD [General.EventParams+8], 0
  // Генерируем ЕРМ событие
  PUSH General.C_ERA_EVENT_BATTLE_BEFOREACTION
  CALL General.GenerateCustomErmEvent
  // Восстанавливаем регистры и выходим
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
  // Патчим конец процедуры записи данных ZVS в сейв
  General.HookCode(Ptr($704EEC), @Hook_SaveGame_Pack, C_HOOKTYPE_JUMP, 5);
  // Патчим конец процедуры загрузки данных ZVS из сейва
  General.HookCode(Ptr($7051B8), @Hook_LoadGame_Unpack, C_HOOKTYPE_JUMP, 5);
  // Патчим вход в Окно Героя
  General.HookCode(Ptr($4E1A70), @Hook_HeroScreen_Enter, C_HOOKTYPE_JUMP, 5);
  // Патчим выходы из Окна Героя
  General.HookCode(Ptr($4E1C7F), @Hook_HeroScreen_Exit, C_HOOKTYPE_JUMP, 6);
  General.HookCode(Ptr($4E1CB9), @Hook_HeroScreen_Exit, C_HOOKTYPE_JUMP, 6);
  // Патчим место решения, кто сейчас ходит
  General.HookCode(Ptr($464F10), @Hook_Battle_WhoMoves, C_HOOKTYPE_JUMP, 5);
  // Патчим событие До Действия
  General.HookCode(Ptr($446B50), @Hook_Battle_BeforeAction, C_HOOKTYPE_JUMP, 5);
  // Патчим регенерацию троллей, духов...
  General.HookCode(Ptr($446BD6), @Hook_Battle_TrollsRegen, C_HOOKTYPE_JUMP, 5);
END; // .procedure Init

END.
