UNIT Core;
{
DESCRIPTION:  Low-level functions
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Windows, Math, Utils, DlgMes, CFiles, Files, hde32;

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


TYPE
  THookRec = PACKED RECORD
    Opcode: BYTE;
    Ofs:    INTEGER;
  END; // .RECORD THookRec
  
  PHookHandlerArgs  = ^THookHandlerArgs;
  THookHandlerArgs  = PACKED RECORD
    EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: INTEGER;
    RetAddr:                                POINTER;
  END; // .RECORD THookHandlerArgs
  
  PAPIArg = ^TAPIArg;
  TAPIArg = PACKED RECORD
    v:  INTEGER;
  END; // .RECORD TAPIArg


PROCEDURE WriteAtCode (Count: INTEGER; Src, Dst: POINTER); STDCALL;

(* In BRIDGE mode hook functions return address to call original routine *)
FUNCTION  Hook
(
  HandlerAddr:  POINTER;
  HookType:     INTEGER;
  PatchSize:    INTEGER;
  CodeAddr:     POINTER
): {n} POINTER; STDCALL;

FUNCTION  ApiHook
(
  HandlerAddr:  POINTER;
  HookType:     INTEGER;
  CodeAddr:     POINTER
): {n} POINTER; STDCALL;

{#}FUNCTION  APIArg (Context: PHookHandlerArgs; ArgN: INTEGER): PAPIArg; //INLINE;
FUNCTION  GetOrigAPIAddr (HookAddr: POINTER): POINTER; STDCALL;
FUNCTION  RecallAPI (Context: PHookHandlerArgs; NumArgs: INTEGER): INTEGER; STDCALL;
PROCEDURE KillThisProcess; STDCALL;
PROCEDURE FatalError (CONST Err: STRING); STDCALL;

// Returns address of assember ret-routine which will clean the arguments and return
FUNCTION  Ret (NumArgs: INTEGER): POINTER;


(***) IMPLEMENTATION (***)


CONST
  BRIDGE_DEF_CODE_OFS = 17;


VAR
{O} Hooker: Files.TFixedBuf;


PROCEDURE WriteAtCode (Count: INTEGER; Src, Dst: POINTER);
VAR
  OldPageProtect: INTEGER;

BEGIN
  {!} ASSERT(Count >= 0);
  {!} ASSERT(Src <> NIL);
  {!} ASSERT(Dst <> NIL);
  Windows.VirtualProtect(Dst, Count, Windows.PAGE_READWRITE, @OldPageProtect);
  Utils.CopyMem(Count, Src, Dst);
  Windows.VirtualProtect(Dst, Count, OldPageProtect, NIL);
END; // .PROCEDURE WriteAtCode

FUNCTION Hook
(
  HandlerAddr:  POINTER;
  HookType:     INTEGER;
  PatchSize:    INTEGER;
  CodeAddr:     POINTER
): {n} POINTER;

CONST
  MIN_BRIDGE_SIZE = 25;

VAR
{U} BridgeCode: POINTER;
    HookRec:    THookRec;
    NopCount:   INTEGER;
    NopBuf:     STRING;

BEGIN
  {!} ASSERT(HandlerAddr <> NIL);
  {!} ASSERT(Math.InRange(HookType, HOOKTYPE_JUMP, HOOKTYPE_BRIDGE));
  {!} ASSERT(PatchSize >= SIZEOF(THookRec));
  {!} ASSERT(CodeAddr <> NIL);
  BridgeCode  :=  NIL;
  // * * * * * //
  RESULT  :=  NIL;
  
  IF HookType = HOOKTYPE_JUMP THEN BEGIN
    HookRec.Opcode  :=  OPCODE_JUMP;
  END // .IF
  ELSE BEGIN
    HookRec.Opcode  :=  OPCODE_CALL;
  END; // .ELSE
  
  IF HookType = HOOKTYPE_BRIDGE THEN BEGIN
    GetMem(BridgeCode, MIN_BRIDGE_SIZE + PatchSize);
    Hooker.Open(BridgeCode, MIN_BRIDGE_SIZE + PatchSize, CFiles.MODE_WRITE);
    // PUSHAD
    // PUSH ESP
    // MOV EAX, ????
    Hooker.WriteStr(#$60#$54#$B8);
    Hooker.WriteInt(INTEGER(HandlerAddr));
    // CALL NEAR EAX
    Hooker.WriteStr(#$FF#$D0);
    // TEST EAX, EAX
    // JZ ??
    Hooker.WriteStr(#$85#$C0#$74);
    Hooker.WriteByte(PatchSize + 10);
    // POPAD
    Hooker.WriteByte($61);
    // ADD ESP, 4
    Hooker.WriteStr(#$83#$C4#$04);
    // DEFAULT CODE
    Hooker.Write(PatchSize, CodeAddr);
    // PUSH ????
    Hooker.WriteByte($68);
    Hooker.WriteInt(INTEGER(CodeAddr) + SIZEOF(THookRec));
    // RET
    Hooker.WriteByte($C3);
    // POPAD
    // RET
    Hooker.WriteByte($61);
    Hooker.WriteByte($C3);
    Hooker.Close;
    HandlerAddr :=  BridgeCode;
    
    RESULT  :=  Utils.PtrOfs(BridgeCode, BRIDGE_DEF_CODE_OFS);
  END; // .IF
  
  HookRec.Ofs :=  INTEGER(HandlerAddr) - INTEGER(CodeAddr) - SIZEOF(THookRec);
  WriteAtCode(SIZEOF(THookRec), @HookRec, CodeAddr);
  NopCount    :=  PatchSize - SIZEOF(THookRec);
  
  IF NopCount > 0 THEN BEGIN
    SetLength(NopBuf, NopCount);
    FillChar(NopBuf[1], NopCount, CHR($90));
    WriteAtCode(NopCount, POINTER(NopBuf), Utils.PtrOfs(CodeAddr, SIZEOF(THookRec)));
  END; // .IF 
END; // .FUNCTION Hook

FUNCTION CalcHookSize (Code: POINTER): INTEGER;
VAR
  Disasm: hde32.TDisasm;

BEGIN
  {!} ASSERT(Code <> NIL);
  RESULT  :=  0;
  
  WHILE RESULT < SIZEOF(THookRec) DO BEGIN
    hde32.hde32_disasm(Code, Disasm);
    RESULT  :=  RESULT + Disasm.Len;
    Code    :=  Utils.PtrOfs(Code, Disasm.Len);
  END; // .WHILE
END; // .FUNCTION CalcHookSize

FUNCTION ApiHook (HandlerAddr: POINTER; HookType: INTEGER; CodeAddr: POINTER): {n} POINTER;
BEGIN
  RESULT  :=  Hook(HandlerAddr, HookType, CalcHookSize(CodeAddr), CodeAddr);
END; // .FUNCTION ApiHook

FUNCTION APIArg (Context: PHookHandlerArgs; ArgN: INTEGER): PAPIArg;
BEGIN
  RESULT :=  Ptr(Context.ESP + 4 + 4 * ArgN);
END; // .FUNCTION APIArg

FUNCTION GetOrigAPIAddr (HookAddr: POINTER): POINTER;
BEGIN
  {!} ASSERT(HookAddr <> NIL);
  RESULT  :=  POINTER
  (
    INTEGER(HookAddr)                 +
    SIZEOF(THookRec)                  +
    PINTEGER(INTEGER(HookAddr) + 1)^  +
    BRIDGE_DEF_CODE_OFS
  );
END; // .FUNCTION GetOrigAPIAddr

FUNCTION RecallAPI (Context: PHookHandlerArgs; NumArgs: INTEGER): INTEGER;
VAR
  APIAddr:  POINTER;
  PtrArgs:  INTEGER;
  APIRes:   INTEGER;
   
BEGIN
  APIAddr :=  GetOrigAPIAddr(Ptr(PINTEGER(Context.ESP)^ - SIZEOF(THookRec)));
  PtrArgs :=  INTEGER(APIArg(Context, NumArgs));
  
  ASM
    MOV ECX, NumArgs
    MOV EDX, PtrArgs
  
  @PUSHARGS:
    PUSH [EDX]
    SUB EDX, 4
    DEC ECX
    JNZ @PUSHARGS
    
    MOV EAX, APIAddr
    CALL EAX
    MOV APIRes, EAX
  END; // .ASM
  
  RESULT :=  APIRes;
END; // .FUNCTION RecallAPI

PROCEDURE KillThisProcess; ASSEMBLER;
ASM
  XOR EAX, EAX
  MOV ESP, EAX
  MOV [EAX], EAX
END; // .PROCEDURE KillThisProcess

PROCEDURE FatalError (CONST Err: STRING);
BEGIN
  DlgMes.MsgError(Err);
  KillThisProcess;
END; // .PROCEDURE FatalError

PROCEDURE Ret0; ASSEMBLER;
ASM
  // RET
END; // .PROCEDURE Ret0

PROCEDURE Ret4; ASSEMBLER;
ASM
  RET 4
END; // .PROCEDURE Ret4

PROCEDURE Ret8; ASSEMBLER;
ASM
  RET 8
END; // .PROCEDURE Ret8

PROCEDURE Ret12; ASSEMBLER;
ASM
  RET 12
END; // .PROCEDURE Ret12

PROCEDURE Ret16; ASSEMBLER;
ASM
  RET 16
END; // .PROCEDURE Ret16

PROCEDURE Ret20; ASSEMBLER;
ASM
  RET 20
END; // .PROCEDURE Ret20

PROCEDURE Ret24; ASSEMBLER;
ASM
  RET 24
END; // .PROCEDURE Ret24

PROCEDURE Ret28; ASSEMBLER;
ASM
  RET 28
END; // .PROCEDURE Ret28

PROCEDURE Ret32; ASSEMBLER;
ASM
  RET 32
END; // .PROCEDURE Ret32

FUNCTION Ret (NumArgs: INTEGER): POINTER;
BEGIN
  CASE NumArgs OF 
    0:  RESULT  :=  @Ret0;
    1:  RESULT  :=  @Ret4;
    2:  RESULT  :=  @Ret8;
    3:  RESULT  :=  @Ret12;
    4:  RESULT  :=  @Ret16;
    5:  RESULT  :=  @Ret20;
    6:  RESULT  :=  @Ret24;
    7:  RESULT  :=  @Ret28;
    8:  RESULT  :=  @Ret32;
  ELSE
    RESULT  :=  NIL;
    {!} ASSERT(FALSE);
  END; // .SWITCH NumArgs
END; // .FUNCTION Ret

BEGIN
  Hooker  :=  Files.TFixedBuf.Create;
END.
