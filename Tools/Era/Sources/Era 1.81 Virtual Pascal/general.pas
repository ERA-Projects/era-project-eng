UNIT General;
{!INFO
MODULENAME = 'General'
VERSION = '3.0'
AUTHOR = 'Berserker'
DESCRIPTION = '����� ���������, ���������� � ������� ��� ���� ������� ���������� Era'
}

(***)  INTERFACE  (***)
USES Win, Utils, Strings, Lang;

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
  C_VAR_ERM_HEAP = $27F9548; // ��������� �� ������ ������� (_Cmd_)
  C_VAR_ERM_PTR_CURRHERO = $27F9970; // ������� �����
  C_VAR_HWND = $699650; // ���������� ���� ������
  (* ���������� � ��������� ��� *)
  C_ERA_DLLNAME = 'Angel.dll'; // �� �������� ���������!!!
  C_ERA_PLUGINS_FOLDER = 'EraPlugins\'; // ����� � ��������� ��� ���
  (*  ������ ������, �������������� Era  *)
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
  C_ERA_EVENT_HEROSCREEN_ENTER = 77004; //  ������� �������� ���� �����
  C_ERA_EVENT_HEROSCREEN_EXIT = 77005; //  ������� ������ �� ���� �����
  C_ERA_EVENT_BATTLE_WHOMOVES = 77006; //  �������: ��� ������ ����� � �����
  C_ERA_EVENT_BATTLE_BEFOREACTION = 77007; //  �������: �� �������� (�� ���� ���)
  C_ERA_EVENT_SAVEGAME_AFTER = 77008; // ������� ����� ���������� SaveGame
  C_ERA_EVENT_SAVEGAME_DIALOG = 77009; // ������� ������ ������� ���������� ���� �� ������� "S"
  C_ERA_EVENT_HEROMEET = 77010; // ������� ������� � ������ ������
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

  TServiceParam = RECORD
    IsString: BOOLEAN; // �������� �� �������� ������� ��� ������ z
    Get: BOOLEAN; // ��� �� ������ �� ��������� ��������
    _0: ARRAY[0..1] OF BYTE; // ������������
    Value: INTEGER; // ��� ����� - ��������, ����� - �����
  END; // .record TServiceParam

  TServiceParams = RECORD // ��� ������ ��� ���������� � �������� ������� ���
    Num: INTEGER;
    Params: ARRAY[0..63] OF TServiceParam;
  END; // .record  TServiceParams

  TServiceRet = RECORD
    Trigger: INTEGER; // ��������� �� ��������� ��������
    CmdN: INTEGER; // ����� ������� � ��������
  END; // .record TServiceRet

  TServiceCallStack = RECORD
    Pos: INTEGER; // ������� � ���� ��� -1
    Stack: ARRAY [0..127] OF TServiceRet; // ������ ��������� ��� ��������
  END; // .record TServiceCallStack

  TEventParams = ARRAY[0..15] OF INTEGER; // ��������� ����� �������


VAR
  Temp: INTEGER; // ������������� ��������� ����������
  hEra: Win.THandle; // ���������� ����������
  (* SaveGame *)
  InSaveGame: LongBool = FALSE; // �� � �������������� ��������� SaveGame ��� ��� ������� ����������
  MarkSaveGame: LongBool = FALSE; // ����� �� �������� ���������� �� ������� ���������� ������������/����������� �����
  SaveGameName: PCHAR = NIL; // ��� ����������� ����
  CustomSaveGameHandler: POINTER = NIL; // ����� ���������, ����������� �������������� ������ ������ � ���� �� �������� ���������� ������� ���
  CustomLoadGameHandler: POINTER = NIL; // ����� ���������, ����������� �������������� �������� ������ �� ����� �� �������� ���������� ������� ���
  (* Era Options Table *)
  Options: STRING; // ������� � ������� ���
  (* Main Window Hook *)
  InGame: LongBool = FALSE; // � ���� �� �� ��� ���
  DefWndProc: POINTER = NIL; // ����� ������������ ������� �������
  (* Colorful Dialogs *)
  PalInd: INTEGER = -1; // ������ ����� � �������
  Palette: ARRAY[0..1023] OF SMALLWORD; // �������
  EraHtml: TEraHtmlBuf; // ������, ����������� ��� ���������� ������� ��������
  (* Service *)
  ServiceParams: TServiceParams; // ����� ��� ���-����������,
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
FUNCTION GetServiceParams(Cmd: PCHAR): INTEGER;
(* CheckServiceParams *) {��������� ���������, ���������� ��� ������� !!SN:... � ���������� ���� �����}
FUNCTION CheckServiceParams(CONST Params: ARRAY OF BOOLEAN): BOOLEAN;
(* GenerateCustomErmEvent *) {���������� ������� � ��������� ID}
PROCEDURE GenerateCustomErmEvent(ID: INTEGER);
(* PCharToAnsi *) {������������ ����-��������������� ������ � ����-������ � ���������� ���������}
FUNCTION PCharToAnsi (PStr: PCHAR): STRING;
(* StrReplace *) {�������� ��������� � ������ ������ ������� ��� �� �����}
PROCEDURE StrReplace (VAR Str: STRING; CONST SWhat, SWith: STRING);


(***)  IMPLEMENTATION  (***)


PROCEDURE WriteAtCode(P: POINTER; Buf: POINTER; Count: INTEGER);
BEGIN
  Win.VirtualProtect(P, Count, PAGE_READWRITE, @Temp);
  Win.CopyMemory(P, Buf, Count);
  Win.VirtualProtect(P, Count, Temp, NIL);
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
  Win.MessageBox(0, PCHAR(Msg), PCHAR(Lang.Str[Str_FatalError_Init_Title]), Win.MB_ICONSTOP);
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

FUNCTION GetServiceParams(Cmd: PCHAR): INTEGER;
TYPE
  TCharArr = ARRAY [0..MAXLONGINT] OF CHAR;
  PCharArr = ^TCharArr;

VAR
  PCmd: PCharArr; // ��������� �� ������ ������ ����������
  NumParams: INTEGER; // ���-�� ����������
  ParType: CHAR; // ��� ���������: v, z, x, y ��� #0
  ParValue: INTEGER; // �������� ���������
  BeginPos: INTEGER; // ��������� ������� ���������� ��������� � ������ ����������
  Pos: INTEGER; // ������� ������� � ������ ����������

BEGIN
  PCmd:=POINTER(Cmd); // ��������� �� ������ ������ � �����������
  NumParams:=0; // ���-�� ����������
  Pos:=1; // ��������� �������. ������ ������ ����������, ��� ��� ��� ���� �������
  WHILE PCmd^[Pos]<>';' DO BEGIN
    // �������� ��� �������: GET or SET
    IF PCmd^[Pos] = '?' THEN BEGIN
      ServiceParams.Params[NumParams].Get:=TRUE;
      INC(Pos);
    END // .if
    ELSE BEGIN
      ServiceParams.Params[NumParams].Get:=FALSE;
    END; // .else
    // �������� ��� ���������: z, v, x, y ��� ���������
    ParType:=PCmd^[Pos];
    IF ParType IN ['0'..'9'] THEN BEGIN
      ParType:=#0;
    END // .if
    ELSE BEGIN
      INC(Pos);
    END; // .else
    // ���������� ������ ���������
    BeginPos:=Pos;
    // ��������� ������ �� ������� ';' ��� '/', ������� �������� �������������� ����������
    WHILE NOT(PCmd^[Pos] IN [';', '/']) DO BEGIN
      INC(Pos);
    END; // .while
    // �������� �������� �������� ���������
    ParValue:=StrToIntFast(@PCmd^[BeginPos], Pos-BeginPos);
    IF PCmd^[Pos] = '/' THEN BEGIN
      INC(Pos);
    END; // .if
    // ��� �������� ��� �� ������, ��� ��� ������������ ����������.
    // ��� ������ ������� �� �������� ������. �������� $887668 ������ v1. ���� ��������� SET, �� �������� �������� �� �������
    IF ParType <> #0 THEN BEGIN
      CASE ParType OF
        'y': BEGIN
          ParValue:=(C_VAR_ERM_Y-4) + ParValue * 4;
          IF NOT ServiceParams.Params[NumParams].Get THEN BEGIN
            ParValue:=PINTEGER(ParValue)^;
          END; // .if
        END; // .switch y
        'v': BEGIN
          ParValue:=(C_VAR_ERM_V-4) + ParValue * 4;
          IF NOT ServiceParams.Params[NumParams].Get THEN BEGIN
            ParValue:=PINTEGER(ParValue)^;
          END; // .if
        END; // .switch v
        'z': BEGIN
          ParValue:=(C_VAR_ERM_Z-512) + ParValue * 512;
        END; // .switch z
        'x': BEGIN
          ParValue:=(C_VAR_ERM_X-4) + ParValue * 4;
          IF NOT ServiceParams.Params[NumParams].Get THEN BEGIN
            ParValue:=PINTEGER(ParValue)^;
          END; // .if
        END; // .switch x
      ELSE
        RESULT:=-1; EXIT;
      END; // .case ParType
    END; // .if
    // ������������� �������� ��������� ServiceParams � ��������� � ���������� ���������
    ServiceParams.Params[NumParams].IsString:=ParType = 'z';
    ServiceParams.Params[NumParams].Value:=ParValue;
    INC(NumParams);
  END; // .while
  ServiceParams.Num:=NumParams;
  RESULT:=Pos; // Pos - ��� ��� ������ ������ ����������
END; // .function GetServiceParams

FUNCTION CheckServiceParams(CONST Params: ARRAY OF BOOLEAN): BOOLEAN;
VAR
  NumParams: INTEGER; // ���-�� ����������� ����������
  i: INTEGER;

BEGIN
  // �� ��������� ��������� - ������
  RESULT:=TRUE;
  // �������� ���-�� ����������� ����������
  NumParams:=HIGH(Params)+1;
  // ...� �������� �� � ���-��� ���������� ����������, ������ �� ��������, ��� ��� ����������� ��������� �� ����� ���� - ���� IsString � Get ������ ���������
  IF (NumParams DIV 2) <> ServiceParams.Num THEN BEGIN
    // ... � ���� ��� �� �����, �� ���������� false
    RESULT:=FALSE; EXIT;
  END; // .if
  // ��������� ������ �������� � �����
  FOR i:=0 TO HIGH(Params) DO BEGIN
    IF
      (ServiceParams.Params[i DIV 2].IsString <> Params[i]) OR
      (ServiceParams.Params[i DIV 2].Get <> Params[i+1])
    THEN BEGIN
      RESULT:=FALSE; EXIT;
    END; // .if
    INC(i);
  END; // .for
END; // .function CheckServiceParams

PROCEDURE GenerateCustomErmEvent(ID: INTEGER); ASSEMBLER; {$FRAME-}
ASM
  PUSH ID
  MOV EAX, C_FUNC_ZVS_CALLFU
  CALL EAX
  ADD ESP, 4
  // RET
END; // .procedure GenerateCustomErmEvent

FUNCTION PCharToAnsi (PStr: PCHAR): STRING;
VAR
  S: STRING;
  Len: INTEGER;

BEGIN
  Len:=Utils.StrLen(PStr);
  SetLength(S, Len);
  Win.CopyMemory(@S[1], PStr, Len);
  RESULT:=S;
END; // .function PCharToAnsi

PROCEDURE StrReplace (VAR Str: STRING; CONST SWhat, SWith: STRING);
VAR
  Pos: PCHAR;

BEGIN
  Pos:=Strings.StrPos(@Str[1], @SWhat[1]);
  IF Pos <> NIL THEN BEGIN
    Win.CopyMemory(Pos, @SWith[1], Length(SWith));
  END; // .if
END; // .procedure StrReplace

END.
