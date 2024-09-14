UNIT General;
{!INFO
MODULENAME = 'General'
VERSION = '3.0'
AUTHOR = 'Berserker'
DESCRIPTION = '����� ���������, ���������� � ������� ��� ���� ������� ���������� Era'
}

(***)  INTERFACE	(***)
USES Windows, SysUtils, Strings, Lang;

CONST
	(* �����: ������ *)
	C_PCHAR_SAVEGAME_NAME = $69FC88; // ��� ����������� ���� (�����)
	C_PCHAR_LASTSAVEGAME_NAME = $68338C; // ��� ���������� �����������/������������ �����
	(* �����: ������� *)
	C_FUNC_PLAYSOUND = $59A890; // ������� PlaySound
	C_FUNC_ZVS_TRIGGERS_PLAYSOUND = $774F0A; // ����������� PlaySound �� ZVS
	C_FUNC_ZVS_ERMMESSAGE = $70FB63; // ������� IF:M
	C_FUNC_ZVS_PROCESSCMD = $741DF0; // ProcessCmd
	C_FUNC_SAVEGAME_HANDLER = $4180C0; // ����������: ����-> ���������
	C_FUNC_SAVEGAME = $4BEB60; // ������� ���������� ����
	C_FUNC_ZVS_GZIPWRITE = $704062; // ������� GZipWrite(Address: POINTER; Count: INTEGER); CDECL;
	C_FUNC_ZVS_GZIPREAD = $7040A7; // ������� GZipRead(Address: POINTER; Count: INTEGER); CDECL;
	C_FUNC_ZVS_GETHEROPTR = $71168D; // ������� GetHeroPtr(HeroNum: INTEGER); CDECL;
	C_FUNC_ZVS_CALLFU = $74CE30; // void FUCall(int n)
	C_FUNC_FOPEN = $619691; // FOpen
	(* �����: ���������� *)
	C_VAR_ERM_V = $887668; // ���-���������� v1
	C_VAR_ERA_COMMAND = C_VAR_ERM_V + 4*9949; // ������� ��� ��� ��� ���������� v9950
	C_VAR_ERA_APIRESULT = C_VAR_ERM_V + 4*9998; // ��������� ���������� ������� API ����� ������ ���
	C_VAR_ERM_Z = $9273E8; // ���-���������� z1
	C_VAR_ERM_Y = $A48D80; // ERM-���������� y1
	C_VAR_ERM_X = $91DA38; // ERM-���������� x1
	C_VAR_ERM_F	=	$27718D0;	// Erm temp vars f..t
	C_VAR_ERM_HEAP = $27F9548; // ��������� �� ������ ������� (_Cmd_)
	C_VAR_ERM_PTR_CURRHERO = $27F9970; // ������� �����
	C_VAR_HWND = $699650; // ���������� ���� ������
	(* ���������� � ��������� ��� *)
	C_ERA_DLLNAME = 'Angel.dll'; // �� �������� ���������!!!
	C_ERA_PLUGINS_FOLDER = 'EraPlugins\'; // ����� � ��������� ��� ���
	(*	������ ������, �������������� Era  *)
	C_ERA_CMD_NONE = 0;
	C_ERA_CMD_LOADLIBRARY = 1;
	C_ERA_CMD_GETPROCADDRESS = 2;
	C_ERA_CMD_CALLAPI = 3;
	C_ERA_CMD_JUSTPLAYSOUND = 4;
	// ����������: ��������� ID - ��� �������������� ����� �������/���������
	(* ������ ���������� API, �������������� Era *)
	C_ERA_CALLCONV_PASCAL = 0;
	C_ERA_CALLCONV_CDECL_OR_STDCALL = 1;
	C_ERA_CALLCONV_THISCALL = 2;
	C_ERA_CALLCONV_FASTCALL = 3;
	CONVENTION_FLOAT				=	4;
	(* HookCode constants *)
	C_HOOKTYPE_JUMP = FALSE;
	C_HOOKTYPE_CALL = TRUE;
	C_OPCODE_JUMP = $E9;
	C_OPCODE_CALL = $E8;
	C_UNIHOOK_SIZE = 5;
	(* Erm Message *)
	C_ERMMESSAGE_MES = 1; // ������� ���������
	C_ERMMESSAGE_QUESTION = 2; // ������ (��/���)
	C_ERMMESSAGE_RMBINFO = 4; // ������ popup �� ������ ������
	C_ERMMESSAGE_CHOOSE = 7; // ����� �� ����
	C_ERMMESSAGE_CHOOSEORCANCEL = 10; // ����� �� ���� � ������������ ������
	(* Era Events *)
	C_ERA_EVENT_SAVEGAME_BEFORE = 77000; // ������� �� ���������� SaveGame
	C_ERA_EVENT_SAVEGAME_PACK = 77001; // �������, ������ ����������� �������� GZipWrite
	C_ERA_EVENT_LOADGAME_UNPACK = 77002; //  �������, ������ ����������� �������� GZipRead
	C_ERA_EVENT_WNDPROC_KEYDOWN = 77003; //  ������� ������� �� �������
	C_ERA_EVENT_HEROSCREEN_ENTER = 77004; //	������� �������� ���� �����
	C_ERA_EVENT_HEROSCREEN_EXIT = 77005; //  ������� ������ �� ���� �����
	C_ERA_EVENT_BATTLE_WHOMOVES = 77006; //  �������: ��� ������ ����� � �����
	C_ERA_EVENT_BATTLE_BEFOREACTION = 77007; //  �������: �� �������� (�� ���� ���)
	C_ERA_EVENT_SAVEGAME_AFTER = 77008; // ������� ����� ���������� SaveGame
	C_ERA_EVENT_SAVEGAME_DIALOG = 77009; // ������� ������ ������� ���������� ���� �� ������� "S"
	TRIGGER_BEFORE_HEROINTERACTION	=	77010;
	TRIGGER_AFTER_HEROINTERACTION		=	77011;
	(* Era Options *)
	C_ERA_OPTIONSNUM = 4; // ���-�� ����� ���
	C_ERA_OPTION_LOADGAME_QUESTION = 0; // ����� ���������� ������� � �������� ����
	C_ERA_OPTION_ERMTIMER_ONOFF = 1; // ����� ���������� ERM ������� ��� ��������� ����
	C_ERA_OPTION_CONFLUXGRAILALLSPELLS_ONOFF = 2; // ����� ���������� �������� ������ � ���������� �� �������� ���� ������
	C_ERA_OPTION_COLORFUL_DIALOGS = 3; // ����� ������������ ��������
	(* Heroes Constants *)
	C_GAME_TOWN_CONFLUX = 8;
	(* EraHtml *)
	C_ERAHTML_MAX_TEXT_LEN = 1048575; // ������������ ������ ������, ������� ����� ���������� � ������ EraHtml


TYPE
	(* ������, ����������� ��� ������ � ��������� �������� *)
	THookRec = RECORD
		Opcode: BYTE;
		Ofs: INTEGER;
	END; // .record THookRec

	TIntArr = ARRAY[0..MAXLONGINT DIV 4] OF INTEGER;
	PIntArr = ^TIntArr;
	TPtrArr = ARRAY[0..MAXLONGINT DIV 4] OF POINTER;
	PPtrArr = ^TPtrArr;
	PCharArr	=	^TCharArr;
	TCharArr	=	ARRAY [0..MAXLONGINT DIV 4 - 1] OF CHAR;

	(* ������ ����� ��� *)
	TOption = RECORD
		Handler: POINTER;
		Value: LongBool;
	END; // .record TOption

	TOptions = ARRAY[0..MAXLONGINT DIV SIZEOF(TOption)] OF TOption;
	POptions = ^TOptions;

	ZIndex = INTEGER; // ������ ���-���������� z

	TEraHtmlBuf = OBJECT
		Len: INTEGER; // ���-�� �������������� ����
		Buffer: ARRAY [0..C_ERAHTML_MAX_TEXT_LEN] OF BYTE; // ����� ��� ����� = 1 ��
		(* Clear *) {������� �����}
		PROCEDURE Clear;
		(* Push *) {�������� � ����� ��������� ������ ������}
		PROCEDURE Push(Addr: POINTER; Num: INTEGER);
	END; // .object  TEraHtmlBuf

	// ������ ��������� ���������� (Main.CallProc)
	TServiceParam = PACKED RECORD
		IsString:	BOOLEAN; // �������� �� �������� ������� ��� ������ z
		Get:			BOOLEAN; // ��� �� ������ �� ��������� ��������
		_0:				ARRAY[0..1] OF BYTE; // ������������
		Value:		INTEGER; // ��� ����� - ��������, ����� - �����
		StrValue:	STRING;
	END; // .record TServiceParam

	PServiceParams = ^TServiceParams;
	TServiceParams = ARRAY[0..23] OF TServiceParam;

	TServiceRet = RECORD
		Trigger: INTEGER; // ��������� �� ��������� ��������
		CmdN: INTEGER; // ����� ������� � ��������
	END; // .record TServiceRet

	TServiceCallStack = RECORD
		Pos: INTEGER; // ������� � ���� ��� -1
		Stack: ARRAY [0..127] OF TServiceRet; // ������ ��������� ��� ��������
	END; // .record TServiceCallStack
	
	TEventParams = ARRAY[0..15] OF INTEGER; // ��������� ����� �������
	
	PEventParamsStack	=	^TEventParamsStack;
	TEventParamsStack	=	PACKED RECORD
				Params:			TEventParams;
	{Un}	PrevParams:	PEventParamsStack;
	END; // .RECORD TEventParamsStack
	
	TZVar   = ARRAY [0..511] OF CHAR;
  
  PWVars	=	^TWVars;
	TWVars	=	ARRAY [0..255, 1..200] OF INTEGER;
	
  PEVars	=	^TEVars;
	TEVars	=	ARRAY [0..100] OF SINGLE;
  
  PNZVars = ^TNZVars;
  TNZVars = ARRAY [1..10] OF TZVar;
  
  PNYVars = ^TNYVars;
  TNYVars = ARRAY [1..100] OF INTEGER;
  
  PNEVars = ^TNEVars;
  TNEVars = ARRAY [1..100] OF SINGLE;
	

CONST
	w:	PWVars	=	Ptr($A4AB10);
	e:	PEVars	=	Ptr($A48F14);
  nz: PNZVars = Ptr($A46D28);
  ny: PNYVars = Ptr($A46A30);
  ne: PNEVars = Ptr($27F93B8);


VAR
	Temp: INTEGER; // ������������� ��������� ����������
	hEra: Windows.THandle; // ���������� ����������
	(* SaveGame *)
	InSaveGame: LongBool = FALSE; // �� � �������������� ��������� SaveGame ��� ��� ������� ����������
	MarkSaveGame: LongBool = FALSE; // ����� �� �������� ���������� �� ������� ���������� ������������/����������� �����
	SaveGameName: PCHAR = NIL; // ��� ����������� ����
	{
	CustomSaveGameHandler: POINTER = NIL; // ����� ���������, ����������� �������������� ������ ������ � ���� �� �������� ���������� ������� ���
	CustomLoadGameHandler: POINTER = NIL; // ����� ���������, ����������� �������������� �������� ������ �� ����� �� �������� ���������� ������� ���
	(* Era Options Table *)
	Options: STRING; // ������� � ������� ���
	}
	(* Colorful Dialogs *)
	PalInd: INTEGER = -1; // ������ ����� � �������
	Palette: ARRAY[0..1023] OF SMALLWORD; // �������
	EraHtml: TEraHtmlBuf; // ������, ����������� ��� ���������� ������� ��������
	(* Service *)
	PtrLastTriggerCall: POINTER = NIL; // ��������� �� �������, ������� ��������� ��������� ����� ������ ���
	ServiceCallStack: TServiceCallStack; // ��� ��������� �� ������� ������������ ��������� �������
	EventParams: TEventParams; // ��������� ����� �������
	(* Data\s Patch*)
	ErmPath: STRING = '..\Data\ERA\.erm\';          // ���� � �������� �� Map
	ErsPath: STRING = 'Data\ERA\.ers\script00.ers'; // ������ ��� �������� ers
	ErtPath: STRING = 'Data\ERA\.ert\';             // ���� � ������ ert

(* WriteAtCode *) {���������� ������ �� ������ � ��������� �����}
PROCEDURE WriteAtCode(P: POINTER; Buf: POINTER; Count: INTEGER);
(* HookCode *) {������ ��������� ����� 5-�������� ����� �� �����, ����� �������� ����������� � ���������. ��� ����� ���� ������� ��� �������. ��������� ���������� ������}
PROCEDURE HookCode(P: POINTER; NewAddr: POINTER; UseCall: BOOLEAN; PatchSize: INTEGER);
(*KillProcess *) {����������� ������� ������� �������. ������� ������, ������� ����. PS. SEH ��������, ������ ����� � ��������� ����}
PROCEDURE KillProcess;
(* FatalError *) {������� ��������� �� ������ � ��������� ��������� �������}
PROCEDURE FatalError(Msg: STRING);
(* ErmMessage *) {���������� ����������� ��������� ���������. ���������� � ������� ZVS}
FUNCTION ErmMessage(Mes: PCHAR; MesType: INTEGER): INTEGER;
(* ErmMessageEx *) {���������� ����������� ��������� ��������� � ���������� ���-���������� ����� ������������ ��������� � ���������� �������� IF:M.
������ ������: 'IF:M^�����^;'}
PROCEDURE ErmMessageEx(Mes: PCHAR; MesLen: INTEGER);
(* ErmJoinedMessage *) {! UNSAFE !; ! HACKS USED ! ��������� ������� ����������� ������������ ���-��������� ����� ������ �����.
���������: Strings..., Count;}
PROCEDURE ErmJoinedMessage;
(* FatalErrorErmMessage *) {! UNSAFE !; ! HACKS USED ! ���������� � ErmJoinedMessage, ���������� � ��������� ����� ������ Lang.
������ ������: PUSH Str_A, PUSH Str_B, PUSH 2, CALL ... }
PROCEDURE FatalErrorErmMessage;
(* HexColor2Int *) {����������� ����� �� 4 ����-�������� � ��� ������������ �������� ����������}
FUNCTION HexColor2Int(PHexCol: PINTEGER): INTEGER;
(* HexParam2Int *) {��������� ����-������ �� 8 �������� � ������ ������� � ���������� � �������� ����������}
{FUNCTION HexParam2Int(PHexStr: POINTER; HexSize: INTEGER): INTEGER;}
(* GetServiceParams *) {������ ��������� ���, ������� �� � ����� � ���������� �������� ������ �������}
FUNCTION	GetServiceParams (Cmd: PCHAR; VAR NumParams: INTEGER; VAR Params: TServiceParams): INTEGER;
(* CheckServiceParams *) {��������� ���������, ���������� ��� ������� !!SN:... � ���������� ���� �����}
FUNCTION	CheckServiceParams
(
				NumParams:		INTEGER;
	VAR		Params:				TServiceParams;
	CONST	ParamsChecks:	ARRAY OF BOOLEAN
): BOOLEAN;
PROCEDURE	SaveEventParams;
PROCEDURE	RestoreEventParams;
(* GenerateCustomErmEvent *) {���������� ������� � ��������� ID}
PROCEDURE GenerateCustomErmEvent(ID: INTEGER);
(* PCharToAnsi *) {������������ ����-��������������� ������ � ����-������ � ���������� ���������}
FUNCTION PCharToAnsi (PStr: PCHAR): STRING;
(* StrReplace *) {�������� ��������� � ������ ������ ������� ��� �� �����}
PROCEDURE StrReplace (VAR Str: STRING; CONST SWhat, SWith: STRING);


(***)  IMPLEMENTATION  (***)


VAR
{On}	EventParamsStack:	PEventParamsStack;


PROCEDURE WriteAtCode(P: POINTER; Buf: POINTER; Count: INTEGER);
BEGIN
	Windows.VirtualProtect(P, Count, PAGE_EXECUTE_READWRITE, @Temp);
	Windows.CopyMemory(P, Buf, Count);
	Windows.VirtualProtect(P, Count, Temp, @Temp);
END; // .procedure WriteAtCode

PROCEDURE HookCode(P: POINTER; NewAddr: POINTER; UseCall: BOOLEAN; PatchSize: INTEGER);
VAR
	HookRec: THookRec;
	NopCount: INTEGER;
	NopBuf: STRING;

BEGIN
	IF UseCall THEN BEGIN
		HookRec.Opcode:=C_OPCODE_CALL;
	END // .if
	ELSE BEGIN
		HookRec.Opcode:=C_OPCODE_JUMP;
	END; // .else
	HookRec.Ofs:=INTEGER(NewAddr)-INTEGER(P)-C_UNIHOOK_SIZE;
	WriteAtCode(P, @HookRec, 5);
	NopCount:=PatchSize-5;
	IF NopCount>0 THEN BEGIN
		SetLength(NopBuf, NopCount);
		FillChar(NopBuf[1], NopCount, CHR($90));
		General.WriteAtCode(Ptr(INTEGER(P)+5), @NopBuf[1], NopCount);
	END; // .if
END; // .procedure HookCode

PROCEDURE KillProcess; ASSEMBLER;
ASM
	XOR EAX, EAX
	MOV ESP, EAX
	MOV EAX, [EAX]
END; // .procedure KillProcess

PROCEDURE FatalError(Msg: STRING);
BEGIN
	Windows.MessageBox(0, PCHAR(Msg), PCHAR(Lang.Str[Str_FatalError_Init_Title]), Windows.MB_ICONSTOP);
	KillProcess;
END; // .procedure FatalError

FUNCTION ErmMessage(Mes: PCHAR; MesType: INTEGER): INTEGER; ASSEMBLER; {$FRAME+}
ASM
	PUSH 0
	PUSH MesType
	PUSH Mes
	MOV EAX, C_FUNC_ZVS_ERMMESSAGE
	CALL EAX
	ADD ESP, $0C
END; // .function ErmMessage

PROCEDURE ErmMessageEx(Mes: PCHAR; MesLen: INTEGER);
TYPE
	TStr = RECORD
		PText: PCHAR;
		Len: INTEGER;
	END; // .record

	TCommand = RECORD
		Name: ARRAY[0..1] OF CHAR; // IF
		Disabled: BOOLEAN; // FALSE
		PrevDisabled: BOOLEAN; // FALSE
		_1: ARRAY[0..511] OF BYTE;
		_2: POINTER;
		_3: ARRAY[0..127] OF BYTE;
		ParamsCount: INTEGER; // 0
		PCmdHeader: TStr; // IF:M
		PCmdBody: TStr; // M^...^;
	END; // .record

VAR
	Cmd: TCommand;

BEGIN
	Cmd.Name:='IF';
	Cmd.Disabled:=FALSE;
	Cmd.PrevDisabled:=FALSE;
	Cmd.ParamsCount:=0;
	Cmd.PCmdHeader.PText:=Mes;
	Cmd.PCmdHeader.Len:=MesLen;
	Cmd.PCmdBody.PText:=POINTER(INTEGER(Mes)+3);
	Cmd.PCmdBody.Len:=MesLen-3;
	ASM
		// �������� ProcessCmd ��� ���� ��������� ���-�������.
		// ����������� ��������� � ���
		PUSH 0
		PUSH 0
		LEA EAX, Cmd
		PUSH EAX
		// ����������� ProcessCmd
		// ����������� ����� ��������
		LEA EAX, @@Ret
		PUSH EAX
		// ��������� ��������� ��� ��� ����
		PUSH EBP
		MOV EBP, ESP
		SUB ESP, $544
		PUSH EBX
		PUSH ESI
		PUSH EDI
		MOV EAX,[EBP+8]
		MOV CX,[EAX]
		MOV [EBP-$314], CX
		MOV EDX, [EBP+8]
		MOV EAX,[EDX+$294]
		MOV [EBP-$2FC], EAX
		// � ������ ������� ���������� ���� ����� ����
		PUSH $741E3F
		RET
		@@Ret:
	END; // .asm
END; // .procedure ErmMessageEx

PROCEDURE ErmJoinedMessage;
TYPE
	TStrArray = ARRAY[0..MAXLONGINT DIV 4] OF STRING;
	PStrArray = ^TStrArray;

VAR
	i: INTEGER;
	JoinedLen: INTEGER; // ������ ����������� ������
	Len: INTEGER; // ������ ��������� ���������� ������
	BufPos: INTEGER; // ������� ������� �  ������ ������������ ������
	Count: INTEGER; // ���-�� �����
	Strings: PStrArray; // ��������� �� ������ �����
	Str: STRING; // ����������� ������

BEGIN
	ASM
		// �������� ���-�� ����������
		MOV EAX, [EBP+8]
		MOV Count, EAX
		// �������� ��������� �� ������ �����
		LEA EAX, [EBP+12]
		MOV Strings, EAX
	END; // .asm
	// ������������ ����� ����� �����
	JoinedLen:=0;
	FOR i:=0 TO Count-1 DO BEGIN
		INC(JoinedLen, Length(Strings^[i]));
	END; // .for
	// �������� ����� ������ �����
	SetLength(Str, JoinedLen);
	// ��������� �������� ������ � �����
	BufPos:=1;
	FOR i:=Count-1 DOWNTO 0 DO BEGIN
		Len:=Length(Strings^[i]);
		IF Len>0 THEN BEGIN
			CopyMemory(@Str[BufPos], @Strings^[i][1], Len);
			INC(BufPos, Len);
		END; // .if
	END; // .for
	General.ErmMessageEx(PCHAR(Str), JoinedLen);
	// ���������� ������� ������
	ASM
		// ���� ������� ������ ��������
		MOV EAX, [EBP+4]
		MOV [EBP+12], EAX
		LEA EAX, @@Garbage
		MOV [EBP+4], EAX
		JMP @@Exit
			@@Garbage:
			// ���� ������ ������
			MOV EAX, [ESP]
			MOV ECX, [ESP+4]
			LEA ESP, [ESP+EAX*4+4]
			JMP ECX
		@@Exit:
	END; // .asm
END; // .procedure ErmJoinedMessage

PROCEDURE FatalErrorErmMessage; ASSEMBLER; {$FRAME-}
ASM
	// �������������� ����� ��������
	LEA EAX, @@Continue
	MOV [ESP], EAX
	// ECX = ParamsCount
	MOV ECX, [ESP+4]
	// ������ ������� ����� �� �������� ������ �� ������ Lang
	// EDX = @Params[Count]
	LEA EDX, [ESP+8]
	@@Loop:
		MOV EAX, [EDX]
		MOV EAX, [OFFSET Lang.Str+EAX*4]
		MOV [EDX], EAX
		ADD EDX, 4
		DEC ECX
		JNZ @@Loop
	JMP ErmJoinedMessage
	@@Continue:
		// �������� ����������
		XOR EAX, EAX
		MOV [EAX], EAX
END; // .procedure FatalErrorErmMessage

PROCEDURE TEraHtmlBuf.Clear;
BEGIN
	Self.Len:=0;
END; // .procedure TEraHtmlBuf.Clear

PROCEDURE TEraHtmlBuf.Push(Addr: POINTER; Num: INTEGER);
BEGIN
	CopyMemory(@Self.Buffer[Self.Len], Addr, Num);
	INC(Self.Len, Num);
END; // .procedure TEraHtmlBuf.Push

FUNCTION HexColor2Int(PHexCol: PINTEGER): INTEGER; ASSEMBLER; {$FRAME-}
ASM
	XOR EAX, EAX
	MOV EDX, PHexCol
	MOV EDX, [EDX]
	PUSH ESI
	MOV ECX, 4
@@Cycle:
	SUB DL, $40
	JS @@BelowTen
@@AboveTen:
	ADD DL, $9
	JMP @@AddHalfByte
@@BelowTen:
	ADD DL, $10
@@AddHalfByte:
	MOVZX ESI, DL
	OR EAX, ESI
	SHL EAX, 4
	SHR EDX, 8
	DEC ECX
	JNZ @@Cycle
	SHR EAX, 4
	POP ESI
	// RET
END; // .function HexColor2Int

{ NOT USED ANY MORE
FUNCTION HexParam2Int(PHexStr: POINTER; HexSize: INTEGER): INTEGER; ASSEMBLER; {$FRAME+}
{ASM
	XOR EAX, EAX // �������� ���������
	MOV ECX, HexSize // �������� ������ ����-������
	PUSH ESI // ��������� ESI
@@Loop:
	MOV EDX, PHexStr
	MOVZX EDX, BYTE [EDX]
	INC PHexStr
	SUB DL, $60
	JS @@BelowTen
@@AboveTen:
	ADD DL, $9
	JMP @@AddHalfByte
@@BelowTen:
	ADD DL, $30
@@AddHalfByte:
	MOVZX ESI, DL
	OR EAX, ESI
	ROL EAX, 4
	DEC ECX
	JNZ @@Loop
	ROR EAX, 4
	POP ESI
	// RET
END; // .function HexParam2Int
}}

FUNCTION StrToIntFast(Str: PCHAR; StrLen: INTEGER): INTEGER; ASSEMBLER; {$FRAME+}
ASM
	XOR EAX, EAX // �������� ���������
	MOV ECX, StrLen // �������� ������ ������
	JMP @@LoopStart
@@Loop:
	MOV EDX, EAX
	ROL EAX, 3
	ADD EAX, EDX
	ADD EAX, EDX
@@LoopStart:
	MOV EDX, Str
	MOVZX EDX, BYTE [EDX]
	INC Str
	SUB DL, $30
	MOVZX EDX, DL
	ADD EAX, EDX
	DEC ECX
	JNZ @@Loop
END; // .function StrToIntFast

FUNCTION GetErtStr (StrInd: INTEGER): PCHAR; ASSEMBLER; {$FRAME+}
ASM
	PUSH StrInd
	MOV EAX, $776620
	CALL EAX
	ADD ESP, 4
END; // .FUNCTION GetErtStr

FUNCTION GetVarStrValue (VarType: CHAR; Ind: INTEGER; VAR Res: STRING): BOOLEAN;
BEGIN
	RESULT	:=	TRUE;
	CASE VarType OF 
		'V':
			BEGIN
				RESULT	:=	(Ind >= 1) AND (Ind <= 10000);
				IF RESULT THEN BEGIN
					Res	:=	SysUtils.IntToStr(PINTEGER(C_VAR_ERM_V - 4 + Ind * 4)^);
				END; // .IF
			END; // .CASE 'V'
		'W':
			BEGIN
				RESULT	:=	(Ind >= 1) AND (Ind <= 200);
				IF RESULT THEN BEGIN
					Res	:=	SysUtils.IntToStr(w^[PINTEGER(PINTEGER(C_VAR_ERM_PTR_CURRHERO)^ + $1A)^, Ind]);
				END; // .IF
			END; // .CASE 'W'
		'X':
			BEGIN
				RESULT	:=	(Ind >= 1) AND (Ind <= 16);
				IF RESULT THEN BEGIN
					Res	:=	SysUtils.IntToStr(PINTEGER(C_VAR_ERM_X - 4 + Ind * 4)^);
				END; // .IF
			END; // .CASE 'X'
		'Y':
			BEGIN
				RESULT	:=	(Ind >= -100) AND (Ind <= 100) AND (Ind <> 0);
				IF RESULT THEN BEGIN
          IF Ind > 0 THEN BEGIN
            Res	:=	SysUtils.IntToStr(PINTEGER(C_VAR_ERM_Y - 4 + Ind * 4)^);
          END // .IF
          ELSE BEGIN
            Res	:=	SysUtils.IntToStr(ny^[-Ind]);
          END; // .ELSE
				END; // .IF
			END; // .CASE 'Y'
		'E':
			BEGIN
				RESULT	:=	(Ind >= -100) AND (Ind <= 100) AND (Ind <> 0);
				IF RESULT THEN BEGIN
					DecimalSeparator	:=	'.';
          
          IF Ind > 0 THEN BEGIN
            Res	:=	SysUtils.FloatToStr(e^[Ind]);
          END // .IF
          ELSE BEGIN
            Res	:=	SysUtils.FloatToStr(ne^[-Ind]);
          END; // .ELSE
				END; // .IF
			END; // .CASE 'E'
		'Z':
			BEGIN
				RESULT	:=	(Ind >= -10) AND (Ind <> 0);
				IF RESULT THEN BEGIN
					IF Ind > 1000 THEN BEGIN
						Res	:=	GetErtStr(Ind);
					END // .IF
          ELSE IF Ind > 0 THEN BEGIN
            Res	:=	PCHAR(C_VAR_ERM_Z - 512 + Ind * 512);
          END // .ELSEIF
					ELSE BEGIN
            Res :=  nz^[-Ind];
					END; // .ELSE
				END; // .IF
			END; // .CASE 'Z'
	ELSE
		RESULT	:=	FALSE;
	END; // .SWITCH VarType
END; // .FUNCTION GetVarStrValue

FUNCTION FindChar (c: CHAR; CONST Str: STRING; VAR Pos: INTEGER): BOOLEAN;
VAR
	Len:	INTEGER;

BEGIN
	Len	:=	LENGTH(Str);
	WHILE (Pos <= Len) AND (Str[Pos] <> c) DO BEGIN
		INC(Pos);
	END; // .WHILE
	RESULT	:=	Pos <= Len;
END; // .FUNCTION FindChar

FUNCTION UnwrapStr (CONST Str: STRING; VAR Res: STRING): BOOLEAN;
TYPE
	PListItem	=	^TListItem;
	TListItem	=	RECORD
		Value:		STRING;
		NextItem:	PListItem;
	END; // .RECORD TListItem

VAR
{O}	Root:			PListItem;
{U}	CurrItem:	PListItem;
		StrLen:		INTEGER;
		StartPos:	INTEGER;
		Pos:			INTEGER;
		Token:		STRING;
		VarType:	CHAR;
		Found:		BOOLEAN;
		NumItems:	INTEGER;
		ResLen:		INTEGER;

	PROCEDURE AddItem (CONST Str: STRING);
	BEGIN
		IF Root = NIL THEN BEGIN
			NEW(Root);
			Root^.Value			:=	Str;
			Root^.NextItem	:=	NIL;
			CurrItem				:=	Root;
		END // .IF
		ELSE BEGIN
			NEW(CurrItem^.NextItem);
			CurrItem						:=	CurrItem^.NextItem;
			CurrItem^.Value			:=	Str;
			CurrItem^.NextItem	:=	NIL;
		END; // .ELSE
		INC(NumItems);
	END; // .PROCEDURE AddItem

BEGIN
	Root			:=	NIL;
	CurrItem	:=	NIL;
	NumItems	:=	0;
	// * * * * * //
	RESULT	:=	TRUE;
	StrLen	:=	LENGTH(Str);
	Pos			:=	1;
	WHILE Pos <= StrLen DO BEGIN
		StartPos	:=	Pos;
		Found			:=	FindChar('%', Str, Pos);
		SetLength(Token, Pos - StartPos);
		IF LENGTH(Token) > 0 THEN BEGIN
			Windows.CopyMemory(POINTER(Token), POINTER(@Str[StartPos]), LENGTH(Token));
		END; // .IF
		AddItem(Token);
		IF Found THEN BEGIN
			IF ((Pos + 1) <= StrLen) AND (Str[Pos+1] = '%') THEN BEGIN
				AddItem('%');
				Pos	:=	Pos + 2;
			END // .IF
			ELSE BEGIN
				INC(Pos);
				RESULT	:=	(Pos+1) <= StrLen;
				IF RESULT THEN BEGIN
					VarType	:=	Str[Pos];
					INC(Pos);
					StartPos	:=	Pos;
          
          IF Str[Pos] IN ['+', '-'] THEN BEGIN
            INC(Pos);
          END; // .IF
          
					WHILE (Pos <= StrLen) AND (Str[Pos] IN ['0'..'9']) DO BEGIN
						INC(Pos);
					END; // .WHILE
					SetLength(Token, Pos - StartPos);
					RESULT	:=	LENGTH(Token) > 0;
					IF RESULT THEN BEGIN
						Windows.CopyMemory(POINTER(Token), POINTER(@Str[StartPos]), LENGTH(Token));
						RESULT	:=	GetVarStrValue(VarType, SysUtils.StrToInt(Token), Token);
						IF RESULT THEN BEGIN
							AddItem(Token);
						END; // .IF
					END; // .IF
				END; // .IF
			END; // .ELSE
		END; // .IF
	END; // .WHILE
	IF NumItems = 0 THEN BEGIN
		Res	:=	'';
	END // .IF
	ELSE BEGIN
		ResLen		:=	0;
		CurrItem	:=	Root;
		WHILE CurrItem <> NIL DO BEGIN
			ResLen		:=	ResLen + LENGTH(CurrItem^.Value);
			CurrItem	:=	CurrItem.NextItem;
		END; // .WHILE
		SetLength(Res, ResLen);
		Pos				:=	1;
		CurrItem	:=	Root;
		WHILE CurrItem <> NIL DO BEGIN
			Windows.CopyMemory(POINTER(@Res[Pos]), POINTER(CurrItem^.Value), LENGTH(CurrItem^.Value));
			Pos				:=	Pos + LENGTH(CurrItem^.Value);
			CurrItem	:=	CurrItem.NextItem;
		END; // .WHILE
	END; // .ELSE
	WHILE Root <> NIL DO BEGIN
		CurrItem	:=	Root^.NextItem;
		DISPOSE(Root);
		Root	:=	CurrItem;
	END; // .WHILE
END; // .FUNCTION UnwrapStr

FUNCTION GetServiceParams (Cmd: PCHAR; VAR NumParams: INTEGER; VAR Params: TServiceParams): INTEGER;
TYPE
	TCharArr = ARRAY [0..MAXLONGINT] OF CHAR;
	PCharArr = ^TCharArr;

VAR
	PCmd:			PCharArr;
	ParType:	CHAR;
	ParValue:	INTEGER;
	BeginPos:	INTEGER;
	Pos:			INTEGER;
	CharPos:	INTEGER;
	StrLen:		INTEGER;
	IndStr:		STRING;

BEGIN
	PCmd			:=	POINTER(Cmd);
	NumParams	:=	0;
	Pos				:=	1;
	WHILE NOT (PCmd^[Pos] IN [';', ' ']) DO BEGIN
		// �������� ��� �������: GET or SET
		IF PCmd^[Pos] = '?' THEN BEGIN
			Params[NumParams].Get	:=	TRUE;
			INC(Pos);
		END // .if
		ELSE BEGIN
			Params[NumParams].Get	:=	FALSE;
		END; // .else
		IF PCmd^[Pos] = '^' THEN BEGIN
			INC(Pos);
			BeginPos	:=	Pos;
			WHILE PCmd^[Pos] <> '^' DO BEGIN
				INC(Pos);
			END; // .WHILE
			StrLen	:=	Pos - BeginPos;
			Params[NumParams].IsString	:=	TRUE;
			SetLength(Params[NumParams].StrValue, StrLen);
			Windows.CopyMemory(POINTER(Params[NumParams].StrValue), @PCmd^[BeginPos], StrLen);
			Params[NumParams].Value			:=	INTEGER(Params[NumParams].StrValue);
			INC(Pos);
			CharPos	:=	1;
			IF FindChar('%', Params[NumParams].StrValue, CharPos) THEN BEGIN
				IF NOT UnwrapStr(Params[NumParams].StrValue, Params[NumParams].StrValue) THEN BEGIN
					RESULT	:=	-1; EXIT;
				END; // .IF
				Params[NumParams].Value	:=	INTEGER(Params[NumParams].StrValue);
			END; // .IF
		END // .IF
		ELSE BEGIN
			// �������� ��� ���������: z, v, x, y ��� ���������
			ParType	:=	PCmd^[Pos];
			IF ParType IN ['-', '+', '0'..'9'] THEN BEGIN
				ParType	:=	#0;
			END // .if
			ELSE BEGIN
				INC(Pos);
			END; // .else
			// ���������� ������ ���������
			BeginPos	:=	Pos;
			// ��������� ������ �� ������� ';' ��� '/', ������� �������� �������������� ����������
			WHILE NOT(PCmd^[Pos] IN [';', '/', ' ']) DO BEGIN
				INC(Pos);
			END; // .while
			// �������� �������� �������� ���������
			IF ParType IN ['f'..'t'] THEN BEGIN
				ParValue	:=	ORD(ParType) - ORD('f');
			END // .IF
			ELSE BEGIN
				SetLength(IndStr, Pos - BeginPos);
				Windows.CopyMemory(POINTER(IndStr), @PCmd^[BeginPos], Pos - BeginPos);
				TRY
					ParValue	:=	SysUtils.StrToInt(IndStr);
				EXCEPT
					RESULT	:=	-1; EXIT;
				END; // .TRY
			END; // .ELSE
			// ��� �������� ��� �� ������, ��� ��� ������������ ����������.
			// ��� ������ ������� �� �������� ������. �������� $887668 ������ v1. ���� ��������� SET, �� �������� �������� �� �������
			IF ParType <> #0 THEN BEGIN
				CASE ParType OF
					'y': BEGIN
            IF ParValue < 0 THEN BEGIN
              ParValue  :=  INTEGER(@ny^[-ParValue]);
            END // .IF
            ELSE BEGIN
              ParValue  :=  (C_VAR_ERM_Y - 4) + ParValue * 4;
            END; // .ELSE
			
            IF NOT Params[NumParams].Get THEN BEGIN
							ParValue  :=  PINTEGER(ParValue)^;
						END; // .if
					END; // .switch y
					'v': BEGIN
						ParValue:=(C_VAR_ERM_V-4) + ParValue * 4;
						IF NOT Params[NumParams].Get THEN BEGIN
							ParValue:=PINTEGER(ParValue)^;
						END; // .if
					END; // .switch v
					'z': BEGIN
						IF ParValue > 1000 THEN BEGIN
							ParValue	:=	INTEGER(GetErtStr(ParValue));
						END // .IF
            ELSE IF ParValue > 0 THEN BEGIN
              ParValue	:=	(C_VAR_ERM_Z-512) + ParValue * 512;
            END // .ELSEIF
						ELSE BEGIN
              ParValue	:=	INTEGER(@nz^[-ParValue]);
						END; // .ELSE
					END; // .switch z
					'x': BEGIN
						ParValue:=(C_VAR_ERM_X-4) + ParValue * 4;
						IF NOT Params[NumParams].Get THEN BEGIN
							ParValue:=PINTEGER(ParValue)^;
						END; // .if
					END; // .switch x
					'w':	BEGIN
						IF Params[NumParams].Get THEN BEGIN
							ParValue	:=	INTEGER(@w^[PINTEGER(PINTEGER(C_VAR_ERM_PTR_CURRHERO)^ + $1A)^, ParValue]);
						END // .IF
						ELSE BEGIN
							ParValue	:=	w^[PINTEGER(PINTEGER(C_VAR_ERM_PTR_CURRHERO)^ + $1A)^, ParValue];
						END; // .ELSE
					END; // .switch w
					'f'..'t':	BEGIN
						ParValue	:=	C_VAR_ERM_F + ParValue * 4;
						IF NOT Params[NumParams].Get THEN BEGIN
							ParValue	:=	PINTEGER(ParValue)^;
						END; // .if
					END; // .switch f..t
					'e':	BEGIN
            IF ParValue > 0 THEN BEGIN
              ParValue	:=	INTEGER(@e^[ParValue]);
            END // .IF
            ELSE BEGIN
              ParValue	:=	INTEGER(@ne^[-ParValue]);
            END; // .ELSE
          
						IF NOT Params[NumParams].Get THEN BEGIN
							ParValue	:=	PINTEGER(ParValue)^;
						END; // .if
					END; // switch e
				ELSE
					RESULT:=-1; EXIT;
				END; // .case ParType
			END; // .if
			// ������������� �������� ��������� Params � ��������� � ���������� ���������
			Params[NumParams].IsString	:=	ParType = 'z';
			Params[NumParams].Value			:=	ParValue;
		END; // .ELSE
		IF PCmd^[Pos] = '/' THEN BEGIN
			INC(Pos);
		END; // .if
		INC(NumParams);
	END; // .while
	WHILE PCmd^[Pos] = ' ' DO BEGIN
		INC(Pos);
	END; // .WHILE
	RESULT	:=	Pos; // Pos - ��� ��� ������ ������ ����������
END; // .FUNCTION GetServiceParams

FUNCTION CheckServiceParams
(
				NumParams:		INTEGER;
	VAR		Params:				TServiceParams;
	CONST	ParamsChecks:	ARRAY OF BOOLEAN
): BOOLEAN;

VAR
	NumChecks:	INTEGER;
	i:					INTEGER;

BEGIN
	NumChecks	:=	HIGH(ParamsChecks) + 1;
	RESULT		:=	(NumChecks DIV 2) = NumParams;
	i					:=	0;
	WHILE RESULT AND (i <= HIGH(ParamsChecks)) DO BEGIN
		RESULT	:=
			(Params[i DIV 2].IsString = ParamsChecks[i])	AND
			(Params[i DIV 2].Get = ParamsChecks[i + 1]);
		i	:=	i + 2;
	END; // .WHILE
END; // .FUNCTION CheckServiceParams

PROCEDURE SaveEventParams;
VAR
{U}	SavedEventParams:	PEventParamsStack;
	
BEGIN
	NEW(SavedEventParams);
	// * * * * * //
	SavedEventParams.PrevParams	:=	EventParamsStack;
	SavedEventParams.Params			:=	EventParams;
	EventParamsStack						:=	SavedEventParams;
END; // .PROCEDURE SaveEventParams

PROCEDURE RestoreEventParams;
VAR
{U}	StackToDelete:	PEventParamsStack;
	
BEGIN
	StackToDelete	:=	NIL;
	// * * * * * //
	IF EventParamsStack = NIL THEN BEGIN
		FatalError('Cannot restore event params: the stack is empty!');
	END; // .IF
	EventParams				:=	EventParamsStack.Params;
	StackToDelete			:=	EventParamsStack;
	EventParamsStack	:=	EventParamsStack.PrevParams;
	DISPOSE(StackToDelete);
END; // .PROCEDURE RestoreEventParams

PROCEDURE GenerateCustomErmEvent (ID: INTEGER); ASSEMBLER; {$FRAME-}
ASM
	PUSH ID
	MOV EAX, C_FUNC_ZVS_CALLFU
	CALL EAX
	ADD ESP, 4
	// RET
END; // .PROCEDURE GenerateCustomErmEvent

FUNCTION PCharToAnsi (PStr: PCHAR): STRING;
VAR
	S: STRING;
	Len: INTEGER;

BEGIN
	Len:=SysUtils.StrLen(PStr);
	SetLength(S, Len);
	Windows.CopyMemory(@S[1], PStr, Len);
	RESULT:=S;
END; // .function PCharToAnsi

PROCEDURE StrReplace (VAR Str: STRING; CONST SWhat, SWith: STRING);
VAR
	Pos: PCHAR;

BEGIN
	Pos:=Strings.StrPos(@Str[1], @SWhat[1]);
	IF Pos <> NIL THEN BEGIN
		Windows.CopyMemory(Pos, @SWith[1], Length(SWith));
	END; // .if
END; // .procedure StrReplace
	
END.
