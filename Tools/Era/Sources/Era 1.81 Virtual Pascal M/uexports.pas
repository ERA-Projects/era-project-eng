UNIT UExports;
{!INFO
MODULENAME = 'UExports'
VERSION = '3.0'
AUTHOR = 'Berserker'
DESCRIPTION = 'Реализация всех экспортируемых процедур и функций проекта Era'
}

(***)  INTERFACE  (***)
USES Windows, SysUtils, Strings, General;

CONST
	C_SAVEGAME_NAME_MAX_LENGTH = 127;
	{C_STR_SETOPTION_ERROR = 'Procedure Era -> SetOption: Invalid option was specified = ';}

	
{VAR
	Patch_ErmTimers_OnOff: ARRAY[0..9] OF BYTE = ($E8, $C6, $A1, $06, $00, $E8, $E6, $8B, $28, $00);} 
	

(* ResetEra *) {Устанавливает дефолтные значения нужным переменным и структурам. Следует вызывать на старте карты и при загрузке игры}
PROCEDURE ResetEra; (* DEPRECATED *)
(* SaveGame *) {Сохраняет игру в сейв с указанным именем и параметрами}
(*
Name - имя сейва
AddExt - добавлять ли расширение GM%, GMC
ShowDialog - показывать ли диалог выбора файла из списка
SaveToData - сохранять ли в папку Data (в противном случае - в Games)
MarkInList - помечать ли как последний сейв (в списке выделяется жёлтым)
P.S Благодарность за информацию asm-у.
*)
PROCEDURE SaveGame(Name: PCHAR; AddExt: LONGBOOL; ShowDialog: LONGBOOL; SaveToData: LONGBOOL; MarkInList: LONGBOOL);	
(* SetOption *) {Устанавливает новое значение опции Эры}
PROCEDURE SetOption(ID: INTEGER; Value: INTEGER); (* DEPRECATED *)

PROCEDURE Init;
	

(***)  IMPLEMENTATION  (***)


PROCEDURE ResetEra;
BEGIN
	General.ServiceCallStack.Pos:=-1;
END; // .procedure ResetEra

PROCEDURE SaveGame(Name: PCHAR; AddExt: LONGBOOL; ShowDialog: LONGBOOL; SaveToData: LONGBOOL; MarkInList: LONGBOOL);
CONST
	PACK_WB0_PLUS = 0; // тип сжатия wb0+
	PACK_WB6_PLUS = 1; // тип сжатия wb6+
	
BEGIN
	ASM
		MOV ECX, DWORD PTR [$699538] // ссылка на объект (ThisCall)
		PUSH SaveToData
		PUSH PACK_WB6_PLUS
		PUSH ShowDialog
		PUSH AddExt
		PUSH Name
		MOV EAX, General.C_FUNC_SAVEGAME
		CALL EAX
		MOV DWORD [General.C_VAR_ERM_V], EAX
	END; // .asm
	IF MarkInList THEN BEGIN
		CopyMemory(Ptr(General.C_PCHAR_LASTSAVEGAME_NAME), Name, Strings.StrLen(Name)+1);
	END; // .if 
END; // .procedure SaveGame

(*
PROCEDURE Hook_SaveGame_Before(SaveName: PCHAR);
CONST
	C_MAX_ERM_STR_LEN = 511; // максимальный размер ЕРМ строки без символа #0

VAR
	Len: INTEGER; // размер строки SaveName

BEGIN
	// Сохраняем в z1 имя сейва, max - 511 символов
	Len:=Strings.StrLen(SaveName);
	IF Len>C_MAX_ERM_STR_LEN THEN BEGIN
		CopyMemory(Ptr(General.C_VAR_ERM_Z), SaveName, C_MAX_ERM_STR_LEN);
		PBYTE(Ptr(General.C_VAR_ERM_Z + C_MAX_ERM_STR_LEN))^:=0;
	END // .if 
	ELSE BEGIN
		CopyMemory(Ptr(General.C_VAR_ERM_Z), SaveName, Len+1);
	END; // .else 
	ASM
		CALL General.SaveEventParams
		// По умолчанию не нужно делать подмены сейва
		MOV DWORD [General.EventParams], 0
		// Генерируем ЕРМ-событие C_ERA_EVENT_SAVEGAME_BEFORE
		PUSH General.C_ERA_EVENT_SAVEGAME_BEFORE
		CALL General.GenerateCustomErmEvent
	END; // .asm 
	// Если нужно, заменяем имя сейва на пользовательское (в z1)
	IF General.EventParams[0]<>0 THEN BEGIN
		Len:=Strings.StrLen(POINTER(General.EventParams[0]));
		CopyMemory(SaveName, POINTER(General.EventParams[0]), Len+1);
	END; // .if
	ASM
		CALL General.RestoreEventParams
	END; // .ASM
END; // .procedure Hook_SaveGame_Before

PROCEDURE AsmHook_SaveGame_Before; ASSEMBLER; {$FRAME-}
ASM
	// Помещаем в EAX адрес строки, содержащей имя сейва
	MOV EAX, DWORD [ESP+4]
	// Сохраняем регистры
	PUSHAD
	// Вызываем Hook_SaveGame_Before
	PUSH EAX
	CALL Hook_SaveGame_Before
	// Восстанавливаем регистры
	POPAD
	// Выполняем старый код
	PUSH EBP
	MOV EBP, ESP
	PUSH -1
	// Возвращаем управление
	PUSH $4BEB65
	// RET
END; // .procedure AsmHook_SaveGame_Before
*)

PROCEDURE Hook_SaveGame_After; ASSEMBLER; {$FRAME-}
ASM
	// Сохраняем регистры
	PUSHAD
	// Генерируем ЕРМ-событие C_ERA_EVENT_SAVEGAME_AFTER
	CALL General.SaveEventParams
	PUSH General.C_ERA_EVENT_SAVEGAME_AFTER
	CALL General.GenerateCustomErmEvent
	CALL General.RestoreEventParams
	// Восстанавливаем регистры
	POPAD
	// Выполняем старый код
	POP EDI
	POP ESI
	POP EBX
	MOV ESP, EBP
	POP EBP
	// Возвращаем управление
	RET $14
END; // .procedure Hook_SaveGame_After

(*
PROCEDURE Hook_EraOption_LoadGame_Question; ASSEMBLER; {$FRAME-}
ASM
	MOV EAX, General.Options
	MOV EAX, [EAX+4]
	TEST EAX, EAX
	JZ @@DontShow
		// Дефолтный код
		MOV ECX, DWORD [$6A5DC4]
		PUSH $409342
		RET
	@@DontShow:
		PUSH $40937C
END; // .procedure Hook_EraOption_LoadGame_Question
*)

{PROCEDURE Option_ErmTimer_OnOff(NewValue: LongBool);
BEGIN
	IF NewValue THEN BEGIN
		General.WriteAtCode(Ptr($4EDCC5), @Patch_ErmTimers_OnOff[5], 5);
	END // .if 
	ELSE BEGIN
		General.WriteAtCode(Ptr($4EDCC5), @Patch_ErmTimers_OnOff[0], 5);
	END; // .else 
END; // .procedure Option_ErmTimer_Disable

PROCEDURE Option_CorfluxGrailAllSpells_OnOff(NewValue: LongBool);
BEGIN
	IF NewValue THEN BEGIN
		PBYTE($5BE4F6)^:=General.C_GAME_TOWN_CONFLUX;
		PBYTE($5D743E)^:=General.C_GAME_TOWN_CONFLUX;
	END // .if 
	ELSE BEGIN
		PBYTE($5BE4F6)^:=General.C_GAME_TOWN_CONFLUX+1;
		PBYTE($5D743E)^:=General.C_GAME_TOWN_CONFLUX+1;
	END; // .else 
END; // .procedure Option_ConfluxGrailAllSpells_OnOff}

PROCEDURE SetOption (ID: INTEGER; Value: INTEGER);
BEGIN
	{IF (ID>=0) AND (ID<General.C_ERA_OPTIONSNUM) THEN BEGIN
		ASM
			MOV EAX, General.Options
			MOV ECX, ID
			LEA EAX, [EAX+ECX*8] // ВНИМАНИЕ! Здесь 8 = SIZEOF (TOption)
			MOV EDX, Value
			MOV [EAX+4], EDX
			MOV EAX, [EAX]
			TEST EAX, EAX
			JZ @@DontCall
			PUSH EDX
			CALL EAX
			@@DontCall:
		END; // .asm 
	END // .if 
	ELSE BEGIN
		General.ErmMessage(PCHAR(C_STR_SETOPTION_ERROR+Utils.IntToStr(ID)), General.C_ERMMESSAGE_MES);
	END; // .else}
END; // .procedure SetOption

(*
PROCEDURE AsmHook_SaveGame_Dialog; ASSEMBLER; {$FRAME-}
ASM
	CALL General.SaveEventParams
	// По умолчанию стандартная реакция
	MOV DWORD [General.EventParams], 0
	// Генерируем событие C_ERA_EVENT_SAVEGAME_DIALOG
	PUSH General.C_ERA_EVENT_SAVEGAME_DIALOG
	CALL General.GenerateCustomErmEvent
	// Смотрим ответ
	MOV EAX, DWORD [General.EventParams]
	PUSH EAX
	CALL General.RestoreEventParams
	POP EAX
	CMP EAX, 0
	JNZ @@Block
@@Default:
	XOR ECX, ECX
	MOV EAX, $4180C0
	CALL EAX
@@Block:
	PUSH $409408
	// RET
END; // .procedure AsmHook_SaveGame_Dialog

FUNCTION Hook_OpenResource (PPath: PCHAR): INTEGER;
VAR
	Path: STRING;	// Оригинальный путь к файлу
	Ext: STRING;	// Расширение файла
	Res: INTEGER;	// Результат FOpen
	
BEGIN
	Path:=General.PCharToAnsi(PPath);
	General.StrReplace(Path, '.82M', '.wav');
	Ext:=SysUtils.LowerCase(SysUtils.ExtractFileExt(Path));
	Path:='.\Data\ERA\'+Ext+'\'+ExtractFileName(Path);
	ASM
		PUSH DWORD [EBP+20]
		PUSH Path
		MOV EAX, General.C_FUNC_FOPEN
		CALL EAX
		ADD ESP, 8
		MOV Res, EAX
	END; // .asm
	RESULT:=Res;
END; // .function Hook_OpenResource

PROCEDURE AsmHook_OpenResource; ASSEMBLER; {$FRAME-}
ASM
	PUSH DWORD [ESP+4]
	CALL Hook_OpenResource
	// RET
END; // .procedure AsmHook_OpenResource

FUNCTION Hook_OpenFile (PPath: PCHAR; PtrOfs: POINTER): INTEGER;
VAR
	Path: STRING;	// Оригинальный путь к файлу
	Ext: STRING;	// Расширение файла
	Res: INTEGER;	// Результат FOpen
	
BEGIN
	Path:=General.PCharToAnsi(PPath);
	General.StrReplace(Path, '.82M', '.wav');
	Ext:=SysUtils.LowerCase(SysUtils.ExtractFileExt(Path));
	Path:='.\Data\ERA\'+Ext+'\'+ExtractFileName(Path);
	RESULT:=Windows.OpenFile(PCHAR(Path), TOFStruct(PtrOfs^), $20);
END; // .function Hook_OpenFile

PROCEDURE AsmHook_OpenFile; ASSEMBLER; {$FRAME-}
ASM
	PUSH DWORD [ESP+4]
	PUSH DWORD [ESP+12]
	CALL Hook_OpenFile
	RET 12
END; // .procedure AsmHook_OpenFile

*)

PROCEDURE Init;
VAR
	// Структура патча для строк Data\s
	Patch: PACKED RECORD
		Opcode: BYTE;
		Addr: POINTER;
	END; // .record 

BEGIN
	// Патчим начало функции SaveGame для реализации нового события
	(*General.HookCode(Ptr(General.C_FUNC_SAVEGAME), @AsmHook_SaveGame_Before, General.C_HOOKTYPE_JUMP, 5);*)
	// Патчим конец функции SaveGame для реализации нового события
	General.HookCode(Ptr($4BEDBE), @Hook_SaveGame_After, General.C_HOOKTYPE_JUMP, 5);
	// Патчим вопрос, действительно ли мы хотим бросить текущую игру и что-то загрузить
	(* General.HookCode(Ptr($40933C), @Hook_EraOption_LoadGame_Question, General.C_HOOKTYPE_JUMP, 5); *)
	// Патчим показ диалога сохранения игры по клавише "S"
	(* General.HookCode(Ptr($409403), @AsmHook_SaveGame_Dialog, General.C_HOOKTYPE_JUMP, 5); *)
	{$IFDEF ERA2}
	// Патчим GetBitmap816
	General.HookCode(Ptr($55AA9A), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим GetBitmap16
	General.HookCode(Ptr($55AE96), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим GetPalette
	General.HookCode(Ptr($55B2BC), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим GetFont
	General.HookCode(Ptr($55BB27), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим GetText
	General.HookCode(Ptr($55BDE7), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим GetSample
	General.HookCode(Ptr($55C61F), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим OpenFile для GetSample
	General.HookCode(Ptr($604881), @AsmHook_OpenFile, General.C_HOOKTYPE_CALL, 6);
	General.HookCode(Ptr($604403), @AsmHook_OpenFile, General.C_HOOKTYPE_CALL, 6);
	General.HookCode(Ptr($604A17), @AsmHook_OpenFile, General.C_HOOKTYPE_CALL, 6);
	// Патчим GetSpreadsheet
	General.HookCode(Ptr($55C0B7), @AsmHook_OpenResource, General.C_HOOKTYPE_CALL, 5);
	// Патчим ссылки на Data\s
	Patch.Opcode:=$68;
	Patch.Addr:=@General.ErmPath[1];
	General.WriteAtCode(Ptr($72C2EB), @Patch, 5);
	General.WriteAtCode(Ptr($773EB9), @Patch, 5);
	General.WriteAtCode(Ptr($777E6F), @Patch, 5);
	Patch.Addr:=@General.ErtPath[1];
	General.WriteAtCode(Ptr($72C34C), @Patch, 5);
	Patch.Addr:=@General.ErsPath[1];
	General.WriteAtCode(Ptr($7B3800), @Patch.Addr, 4);
	{$ENDIF}
END; // .procedure Init

END.
