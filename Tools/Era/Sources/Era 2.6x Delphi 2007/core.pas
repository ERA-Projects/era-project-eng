unit Core;
{
DESCRIPTION: Low-level functions
AUTHOR:      Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, PsApi, Math, StrUtils, SysUtils,
  hde32, PatchApi,
  Utils, Alg, WinWrappers, DlgMes, CFiles, Files, DataLib, StrLib, Concur,
  DebugMaps;

type
  (* Import *)
  TStrList = DataLib.TStrList;
  TList    = DataLib.TList;
  TObjDict = DataLib.TObjDict;

const
  (*
    Hook types

    HOOKTYPE_BRIDGE has opcode OPCODE_CALL. Creates a bridge to high-level function.
    function (Context: PHookContext): TExecuteDefaultCodeFlag; stdcall;
    if default code should be executed, it can contain any commands except jumps.
    The only jump opcodes allowed are: OPCODE_JUMP, OPCODE_CALL
  *)
  HOOKTYPE_JUMP   = 0; // jmp, 5 bytes
  HOOKTYPE_CALL   = 1; // call, 5 bytes
  HOOKTYPE_BRIDGE = 2; // call, 5 bytes

  OPCODE_JUMP    = $E9;
  OPCODE_CALL    = $E8;
  OPCODE_RET     = $C3;
  OPCODE_RET_IW  = $C2;
  OPCODE_RETF    = $CB;
  OPCODE_RETF_IW = $CA;

  RET_OPCODES = [OPCODE_RET, OPCODE_RET_IW, OPCODE_RETF, OPCODE_RETF_IW];

  EXEC_DEF_CODE   = true;
  IGNORE_DEF_CODE = not EXEC_DEF_CODE;

  ANALYZE_DATA      = true;
  DONT_ANALYZE_DATA = not ANALYZE_DATA;

type
  THookRec = packed record
    Opcode: byte;
    Ofs:    integer;
  end; // .record THookRec
  
  PHookContext = ^THookContext;

  THookContext = packed record
    EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: integer;
    RetAddr:                                pointer;
  end;

  TModuleInfo = class
    Name:       string;  // evaluated: lower case without extension + capitalize
    FileName:   string;  // evaluated: lower case
    Path:       string;  // original data returned by WinApi
    BaseAddr:   pointer;
    EndAddr:    pointer; // evaluated
    EntryPoint: pointer;
    Size:       integer;
    IsExe:      boolean; // evaluated

    procedure EvaluateDerivatives;
    function  OwnsAddr ({n} Addr: pointer): boolean;
    function  ToStr: string;
  end; // .class TModuleInfo

  TModuleList = {O} TStrList {of TModuleInfo};

  TModuleContext = class
   protected
    {On} fModuleList:         TModuleList;
         fModulesOrderByAddr: TArrayOfInt;
         fCritSection:        Concur.TCritSection;

    function  CompareModulesByAddr (Ind1, Ind2: integer): integer;
    procedure EnsureModuleList;
    function  GetModuleList: TModuleList;
    function  GetModuleInfo (Ind: integer): TModuleInfo;
    function  CompareModuleToAddr (OrderTableInd, Addr: integer): integer;

   public
    constructor Create;
    destructor Destroy; override;

    // Thread-safe context grab/release
    procedure Lock;
    procedure Unlock;

    procedure UpdateModuleList;
    // Uses separate index table and binary search unlike unit `FindModuleByAddr` function
    function  FindModuleByAddr ({n} Addr: pointer; out ModuleInd: integer): boolean;
    function  AddrToStr ({n} Addr: pointer;  AnalyzeData: bool = DONT_ANALYZE_DATA): string;

    property ModuleList: TModuleList read GetModuleList;
    property ModuleInfo[Ind: integer]: TModuleInfo read GetModuleInfo;
  end; // .class TModuleContext


function  WriteAtCode (Count: integer; Src, Dst: pointer): boolean; stdcall;
(* For HOOKTYPE_BRIDGE hook functions return address to call original routine.
   It's expected that PatchSize covers integer number of commands *)
function  Hook (HandlerAddr: pointer; HookType: integer; PatchSize: integer;
                CodeAddr: pointer): {n} pointer; stdcall;
function  ApiHook (HandlerAddr: pointer; HookType: integer;
                   CodeAddr: pointer): {n} pointer; stdcall;
function  CalcHookSize (Code: pointer): integer;
function  GetStdcallArg (Context: PHookContext; ArgN: integer): pinteger; inline;
procedure KillThisProcess;
procedure GenerateException;
procedure NotifyError (const Err: string);
procedure FatalError (const Err: string);
// Returns address of assember ret-routine which will clean the arguments and return
function  Ret (NumArgs: integer): pointer;
procedure SetDebugMapsDir (const Dir: string);
function  GetModuleList: TModuleList;
function  FindModuleByAddr ({n} Addr: pointer; ModuleList: TModuleList;
                            out ModuleInd: integer): boolean;

var
  AbortOnError: boolean = false; // if set to false, NotifyError does nothing
  (* Patching provider *)
  GlobalPatcher: PatchApi.TPatcher;
  p:             PatchApi.TPatcherInstance;

{O} ModuleContext: TModuleContext; // Shareable between threads, use lock methods


implementation


type
  PBridgeCodePart1 = ^TBridgeCodePart1;
  TBridgeCodePart1 = packed record
    Pushad:               byte;
    PushEsp:              byte;
    MovEaxConst32:        byte;
    HandlerAddr:          pointer;
    CallEax:              word;
    TestEaxEax:           word;
    JzOffset8:            byte;
    OffsetToAfterDefCode: byte;
    Label_ExecDefCode:    Utils.TEmptyRec;
    Popad:                byte;
    AddEsp4:              array [0..2] of byte;
    // < Default code > //
  end; // .record TBridgeCodePart1

  PBridgeCodePart2 = ^TBridgeCodePart2;
  TBridgeCodePart2 = packed record
    PushConst32:           byte;
    RetAddr:               pointer;
    Ret_1:                 byte;
    Label_DontExecDefCode: Utils.TEmptyRec;
    Popad:                 byte;
    Ret_2:                 byte;
  end; // .record TBridgeCodePart2

var
  BridgeCodePart1: TBridgeCodePart1 =
  (
    Pushad:        $60;
    PushEsp:       $54;
    MovEaxConst32: $B8;
    CallEax:       $D0FF;
    TestEaxEax:    $C085;
    JzOffset8:     $74;
    Popad:         $61;
    AddEsp4:       ($83, $C4, $04);
  );

  BridgeCodePart2: TBridgeCodePart2 =
  (
    PushConst32: $68;
    Ret_1:       $C3;
    Popad:       $61;
    Ret_2:       $C3;
  );

  DebugMapsDir: string;

{O} Maps: {O} TDict {OF DebugMaps.TDebugMap};

procedure TModuleInfo.EvaluateDerivatives;
begin
  EndAddr  := Utils.PtrOfs(BaseAddr, Size);
  FileName := AnsiLowerCase(ExtractFileName(Path));
  Name     := StrLib.Capitalize(ChangeFileExt(FileName, ''));
  IsExe    := StrUtils.AnsiEndsStr('.exe', FileName);
end; // .procedure TModuleInfo.EvaluateDerivatives

function TModuleInfo.OwnsAddr ({n} Addr: pointer): boolean;
begin
  result := (cardinal(Addr) >= cardinal(BaseAddr)) and (cardinal(Addr) < cardinal(EndAddr));
end; // .function TModuleInfo.OwnsAddr

function TModuleInfo.ToStr: string;
begin
  result := Format('%s ("%s", size: %d, addr: %p, entry: %x)',
                   [Name, Path, Size, BaseAddr, integer(EntryPoint) - integer(BaseAddr)]);
end; // .function TModuleInfo.ToStr

constructor TModuleContext.Create;
begin
  fCritSection.Init;
end; // .constructor TModuleContext.Create

destructor TModuleContext.Destroy;
begin
  FreeAndNil(fModuleList);
  fCritSection.Delete;
end; // .destructor TModuleContext.Destroy

function TModuleContext.CompareModulesByAddr (Ind1, Ind2: integer): integer;
begin
  result := Alg.PtrCompare(TModuleInfo(fModuleList.Values[Ind1]).BaseAddr,
                           TModuleInfo(fModuleList.Values[Ind2]).BaseAddr);
end; // .function TModuleContext.CompareModulesByAddr

procedure SetDebugMapsDir (const Dir: string);
begin
  DebugMapsDir := Dir;
end;

procedure TModuleContext.EnsureModuleList;
var
  i: integer;

begin
  if fModuleList = nil then begin
    fModuleList := Core.GetModuleList;
    fModuleList.Sort;
    SetLength(fModulesOrderByAddr, fModuleList.Count);
    
    for i := 0 to fModuleList.Count - 1 do begin
      fModulesOrderByAddr[i] := i;
    end; // .for

    Alg.CustomQuickSort(pointer(fModulesOrderByAddr), 0, fModuleList.Count - 1,
                        CompareModulesByAddr);
  end; // .if
end; // .procedure TModuleContext.EnsureModuleList

function TModuleContext.GetModuleList: TModuleList;
begin
  EnsureModuleList;
  result := fModuleList;
end; // .function TModuleContext.GetModuleList

function TModuleContext.GetModuleInfo (Ind: integer): TModuleInfo;
begin
  EnsureModuleList;
  result := TModuleInfo(fModuleList.Values[Ind]);
end; // .function TModuleContext.GetModuleInfo

function TModuleContext.CompareModuleToAddr (OrderTableInd, Addr: integer): integer;
var
{U} ModInfo: TModuleInfo;

begin
  ModInfo := TModuleInfo(fModuleList.Values[fModulesOrderByAddr[OrderTableInd]]);
  
  if cardinal(Addr) < cardinal(ModInfo.BaseAddr) then begin
    result := -1;
  end else if cardinal(Addr) >= cardinal(ModInfo.EndAddr) then begin
    result := +1;
  end else begin
    result := 0;
  end; // .else
end; // .function TModuleContext.CompareModuleToAddr

procedure TModuleContext.Lock;
begin
  fCritSection.Enter;
end; // .procedure TModuleContext.Lock

procedure TModuleContext.Unlock;
begin
  fCritSection.Leave;
end; // .procedure TModuleContext.Unlock

procedure TModuleContext.UpdateModuleList;
begin
  FreeAndNil(fModuleList);
  fModulesOrderByAddr := nil;
end; // .procedure TModuleContext.UpdateModuleList

function TModuleContext.FindModuleByAddr ({n} Addr: pointer; out ModuleInd: integer): boolean;
begin
  EnsureModuleList;

  result := Alg.CustomBinarySearch(pointer(fModulesOrderByAddr), 0, length(fModulesOrderByAddr) - 1,
                                   integer(Addr), CompareModuleToAddr, ModuleInd);
  if result then begin
    ModuleInd := fModulesOrderByAddr[ModuleInd];
  end; // .if
end; // .function TModuleContext.FindModuleByAddr

function TModuleContext.AddrToStr ({n} Addr: pointer; AnalyzeData: bool = DONT_ANALYZE_DATA): string;
const
  MAX_DECIMAL_DIGIT                     = 9;
  STR_DEBUG_CHUNK_LEN                   = 32;
  BINARY_CHARS                          = [#0..#8, #11..#12, #14..#31];
  TRUSTED_CHARS                         = ['a'..'z', 'A'..'Z', '0'..'9', '_', 'à'..'ÿ', 'À'..'ß', '¸', '¨'];
  HEUR_MIN_PTR_ADDR                     = $100000;
  HEUR_MIN_STR_LEN                      = 3;
  HEUR_MIN_STR_TRUSTED_CHARS_PERCENTAGE = 50;

var
{U} ModuleInfo:          TModuleInfo;
    ModuleInd:           integer;
{U} DebugMap:            DebugMaps.TDebugMap;
    MapFilePath:         string;
    MapFile:             string;
    ReadableAddr:        string;
    TargetStr:           pchar;
    TargetStrChunk:      string;
    TrustedCharsInChunk: integer;
    c:                   char;
    i:                   integer;

begin
  ModuleInfo := nil;
  DebugMap   := nil;
  // * * * * * //
  EnsureModuleList;
  result := '';

  if FindModuleByAddr(Addr, ModuleInd) then begin
    ModuleInfo := GetModuleInfo(ModuleInd);
    result     := ModuleInfo.Name + '.';

    if ModuleInfo.IsExe then begin
      result := result + IntToHex(integer(Addr), 8);
    end else begin
      result := result + IntToHex(integer(Addr) - integer(ModuleInfo.BaseAddr), 1);
    end; // .else

    if DebugMapsDir <> '' then begin
      DebugMap := Maps[ModuleInfo.Name];

      if DebugMap = nil then begin
        DebugMap              := DebugMaps.TDebugMap.Create();
        Maps[ModuleInfo.Name] := DebugMap;
        MapFilePath           := DebugMapsDir + '\' + ModuleInfo.Name + '.dbgmap';

        if (SysUtils.FileExists(MapFilePath) and Files.ReadFileContents(MapFilePath, MapFile)) and (length(MapFile) >= MIN_DBGMAP_FILE_SIZE) then begin
          DebugMap.LoadFromString(MapFile);
        end;
      end;

      ReadableAddr := DebugMap.GetReadableAddr(integer(Addr) - integer(ModuleInfo.BaseAddr));

      if ReadableAddr <> '' then begin
        result := result + ' (' + ReadableAddr + ')';
      end;
    end; // .if
  end else begin
    result := IntToHex(integer(Addr), 8);
  end; // .else

  if AnalyzeData then begin
    result := result + ' (int: ' + SysUtils.IntToStr(integer(Addr));

    if (cardinal(Addr) >= HEUR_MIN_PTR_ADDR) and not Windows.IsBadReadPtr(Addr, sizeof(integer)) then begin
      result := result + ', pint: ' + '0x' + SysUtils.IntToHex(pinteger(Addr)^, 8);

      if pinteger(Addr)^ > MAX_DECIMAL_DIGIT then begin
        result := result + ' = ' + SysUtils.IntToStr(pinteger(Addr)^);
      end;

      if not Windows.IsBadReadPtr(Addr, STR_DEBUG_CHUNK_LEN) then begin
        TargetStr           := pchar(Addr);
        TargetStrChunk      := '';
        TrustedCharsInChunk := 0;

        for i := 0 to STR_DEBUG_CHUNK_LEN - 1 do begin
          c := TargetStr^;

          if c in BINARY_CHARS then begin
            TargetStrChunk := TargetStrChunk + '\x' + SysUtils.IntToHex(ord(c), 2);
            break;
          end else begin
            TargetStrChunk := TargetStrChunk + c;

            if c in TRUSTED_CHARS then begin
              inc(TrustedCharsInChunk);
            end;
          end;

          inc(TargetStr);
        end; // .for

        if (length(TargetStrChunk) >= HEUR_MIN_STR_LEN) and (TrustedCharsInChunk * 100 div length(TargetStrChunk) >= HEUR_MIN_STR_TRUSTED_CHARS_PERCENTAGE) then begin
          result := result + ', str: "' + TargetStrChunk + '"';
        end; // .if
      end; // .if
    end; // .if
    
    result := result + ')';
  end; // .if
end; // .function TModuleContext.AddrToStr

function WriteAtCode (Count: integer; Src, Dst: pointer): boolean;
begin
  {!} Assert(Utils.IsValidBuf(Dst, Count));
  {!} Assert((Src <> nil) or (Count = 0));
  result := (Count = 0) or p.Write(Dst, Src, Count, true).IsApplied();
end;

function WriteAtCode_Standalone (Count: integer; Src, Dst: pointer): boolean;
var
  OldPageProtect: integer;

begin
  {!} Assert(Utils.IsValidBuf(Dst, Count));
  {!} Assert((Src <> nil) or (Count = 0));
  result := Count = 0;

  if not result then begin
    result := Windows.VirtualProtect(Dst, Count, Windows.PAGE_EXECUTE_READWRITE, @OldPageProtect);
    
    if result then begin
      Utils.CopyMem(Count, Src, Dst);
      result := Windows.VirtualProtect(Dst, Count, OldPageProtect, @OldPageProtect);
    end; // .if
  end; // .if
end; // .function WriteAtCode_Standalone

// function WriteCodeBridge (HandlerAddr, CodeAddr, DataAddr: pointer): {n} pointer;
// type
//   TBytes = array of byte;

// var
// {O} BridgeCode:    pointer; // Memory is not freed or tracked
//     BridgePart1:   PBridgeCodePart1;
//     BridgeDefCode: pointer;
//     BridgePart2:   PBridgeCodePart2;
//     NopCount:      integer;
//     NopBuf:        TBytes;
//     HookRec:       THookRec;

//  function PreprocessCode (CodeSize: integer; OldCodeAddr, NewCodeAddr: pointer): TBytes;
//  var
//    Delta:  integer;
//    BufPos: integer;
//    Disasm: hde32.TDisasm;
 
//  begin
//   {!} Assert(CodeSize >= sizeof(THookRec));
//   {!} Assert(OldCodeAddr <> nil);
//   {!} Assert(NewCodeAddr <> nil);
//   SetLength(result, CodeSize);
//   Utils.CopyMem(CodeSize, OldCodeAddr, @result[0]);
//   Delta  := integer(NewCodeAddr) - integer(OldCodeAddr);
//   BufPos := 0;
  
//   while BufPos < CodeSize do begin
//     hde32.hde32_disasm(Utils.PtrOfs(OldCodeAddr, BufPos), Disasm);
    
//     if (Disasm.Len = sizeof(THookRec)) and (Disasm.Opcode in [OPCODE_JUMP, OPCODE_CALL]) then begin
//       Dec(pinteger(@result[BufPos + 1])^, Delta);
//     end; // .if
    
//     Inc(BufPos, Disasm.Len);
//   end; // .while
//  end; // .function PreprocessCode

//  function FieldOffset (RecAddr, FieldAddr: pointer): integer;
//  begin
//    {!} Assert(cardinal(FieldAddr) >= cardinal(RecAddr));
//    result := cardinal(FieldAddr) - cardinal(RecAddr);
//  end; // .function FieldOffset

// begin
//   {!} Assert(HandlerAddr <> nil);
//   {!} Assert(Math.InRange(HookType, HOOKTYPE_JUMP, HOOKTYPE_BRIDGE));
//   {!} Assert(PatchSize >= sizeof(THookRec));
//   {!} Assert(CodeAddr <> nil);
//   BridgeCode := nil;
//   // * * * * * //
//   result := nil;

//   if HookType = HOOKTYPE_JUMP then begin
//     HookRec.Opcode := OPCODE_JUMP;
//   end else begin
//     HookRec.Opcode := OPCODE_CALL;
//   end; // .else
  
//   if HookType = HOOKTYPE_BRIDGE then begin
//     // Allocate memory block for bridge and assign pointers to its parts
//     GetMem(BridgeCode, sizeof(TBridgeCodePart1) + sizeof(TBridgeCodePart2) + PatchSize);
//     BridgePart1   := BridgeCode;
//     BridgeDefCode := Utils.PtrOfs(BridgeCode, sizeof(BridgePart1^));
//     BridgePart2   := Utils.PtrOfs(BridgeCode, sizeof(BridgePart1^) + PatchSize);

//     // Copy preprocessed default code to destination
//     Utils.CopyMem(PatchSize, @PreprocessCode(PatchSize, CodeAddr, BridgeDefCode)[0], BridgeDefCode);

//     // Copy bridge parts to destination and fill in required fields
//     BridgePart1^                     := BridgeCodePart1;
//     BridgePart1.HandlerAddr          := HandlerAddr;
//     BridgePart1.OffsetToAfterDefCode := PatchSize + sizeof(BridgePart1^)
//                                         - FieldOffset(BridgePart1, @BridgePart1.Label_ExecDefCode)
//                                         + FieldOffset(BridgePart2,
//                                                       @BridgePart2.Label_DontExecDefCode);
//     BridgePart2^                     := BridgeCodePart2;
//     BridgePart2.RetAddr              := Utils.PtrOfs(CodeAddr, sizeof(THookRec));

//     HandlerAddr := BridgeCode;
//     result      := BridgeDefCode;
//   end; // .if

//   HookRec.Ofs := integer(HandlerAddr) - integer(CodeAddr) - sizeof(THookRec);
//   {!} Assert(WriteAtCode(sizeof(THookRec), @HookRec, CodeAddr));
//   NopCount    := PatchSize - sizeof(THookRec);

//   if NopCount > 0 then begin
//     SetLength(NopBuf, NopCount);
//     FillChar(NopBuf[0], NopCount, Chr($90));
//     {!} Assert(WriteAtCode(NopCount, pointer(NopBuf), Utils.PtrOfs(CodeAddr, sizeof(THookRec))));
//   end; // .if
// end; // .function WriteCodeBridge

function Hook (HandlerAddr: pointer; HookType: integer; PatchSize: integer; CodeAddr: pointer): {n} pointer;
type
  TBytes = array of byte;

var
{O} BridgeCode:    pointer; // Memory is not freed or tracked
    BridgePart1:   PBridgeCodePart1;
    BridgeDefCode: pointer;
    BridgePart2:   PBridgeCodePart2;
    NopCount:      integer;
    NopBuf:        TBytes;
    HookRec:       THookRec;

 function PreprocessCode (CodeSize: integer; OldCodeAddr, NewCodeAddr: pointer): TBytes;
 var
   Delta:  integer;
   BufPos: integer;
   Disasm: hde32.TDisasm;
 
 begin
  {!} Assert(CodeSize >= sizeof(THookRec));
  {!} Assert(OldCodeAddr <> nil);
  {!} Assert(NewCodeAddr <> nil);
  SetLength(result, CodeSize);
  Utils.CopyMem(CodeSize, OldCodeAddr, @result[0]);
  Delta  := integer(NewCodeAddr) - integer(OldCodeAddr);
  BufPos := 0;
  
  while BufPos < CodeSize do begin
    hde32.hde32_disasm(Utils.PtrOfs(OldCodeAddr, BufPos), Disasm);
    
    if (Disasm.Len = sizeof(THookRec)) and (Disasm.Opcode in [OPCODE_JUMP, OPCODE_CALL]) then begin
      Dec(pinteger(@result[BufPos + 1])^, Delta);
    end; // .if
    
    Inc(BufPos, Disasm.Len);
  end; // .while
 end; // .function PreprocessCode

 function FieldOffset (RecAddr, FieldAddr: pointer): integer;
 begin
   {!} Assert(cardinal(FieldAddr) >= cardinal(RecAddr));
   result := cardinal(FieldAddr) - cardinal(RecAddr);
 end; // .function FieldOffset

begin
  {!} Assert(HandlerAddr <> nil);
  {!} Assert(Math.InRange(HookType, HOOKTYPE_JUMP, HOOKTYPE_BRIDGE));
  {!} Assert(PatchSize >= sizeof(THookRec));
  {!} Assert(CodeAddr <> nil);
  BridgeCode := nil;
  // * * * * * //
  result := nil;

  if HookType = HOOKTYPE_JUMP then begin
    HookRec.Opcode := OPCODE_JUMP;
  end else begin
    HookRec.Opcode := OPCODE_CALL;
  end; // .else
  
  if HookType = HOOKTYPE_BRIDGE then begin
    // Allocate memory block for bridge and assign pointers to its parts
    GetMem(BridgeCode, sizeof(TBridgeCodePart1) + sizeof(TBridgeCodePart2) + PatchSize);
    BridgePart1   := BridgeCode;
    BridgeDefCode := Utils.PtrOfs(BridgeCode, sizeof(BridgePart1^));
    BridgePart2   := Utils.PtrOfs(BridgeCode, sizeof(BridgePart1^) + PatchSize);

    // Copy preprocessed default code to destination
    Utils.CopyMem(PatchSize, @PreprocessCode(PatchSize, CodeAddr, BridgeDefCode)[0], BridgeDefCode);

    // Copy bridge parts to destination and fill in required fields
    BridgePart1^                     := BridgeCodePart1;
    BridgePart1.HandlerAddr          := HandlerAddr;
    BridgePart1.OffsetToAfterDefCode := PatchSize + sizeof(BridgePart1^)
                                        - FieldOffset(BridgePart1, @BridgePart1.Label_ExecDefCode)
                                        + FieldOffset(BridgePart2,
                                                      @BridgePart2.Label_DontExecDefCode);
    BridgePart2^                     := BridgeCodePart2;
    BridgePart2.RetAddr              := Utils.PtrOfs(CodeAddr, sizeof(THookRec));

    HandlerAddr := BridgeCode;
    result      := BridgeDefCode;
  end; // .if

  HookRec.Ofs := integer(HandlerAddr) - integer(CodeAddr) - sizeof(THookRec);
  {!} Assert(WriteAtCode(sizeof(THookRec), @HookRec, CodeAddr));
  NopCount    := PatchSize - sizeof(THookRec);

  if NopCount > 0 then begin
    SetLength(NopBuf, NopCount);
    FillChar(NopBuf[0], NopCount, Chr($90));
    {!} Assert(WriteAtCode(NopCount, pointer(NopBuf), Utils.PtrOfs(CodeAddr, sizeof(THookRec))));
  end; // .if
end; // .function Hook

function CalcHookSize (Code: pointer): integer;
var
  Disasm: hde32.TDisasm;

begin
  {!} Assert(Code <> nil);
  result := 0;

  while result < sizeof(THookRec) do begin
    hde32.hde32_disasm(Code, Disasm);
    result := result + Disasm.Len;
    Code   := Utils.PtrOfs(Code, Disasm.Len);
  end; // .while
end; // .function CalcHookSize

function ApiHook (HandlerAddr: pointer; HookType: integer; CodeAddr: pointer): {n} pointer;
begin
  result := Hook(HandlerAddr, HookType, CalcHookSize(CodeAddr), CodeAddr);
end; // .function ApiHook

function GetStdcallArg (Context: PHookContext; ArgN: integer): pinteger;
begin
  result := Ptr(Context.ESP + (4 + 4 * ArgN));
end; // .function GetStdcallArg

procedure KillThisProcess; assembler;
asm
  XOR EAX, EAX
  MOV ESP, EAX
  MOV [EAX], EAX
end; // .procedure KillThisProcess

procedure GenerateException; assembler;
asm
  xor eax, eax
  mov [eax], eax
end; // .procedure GenerateException

procedure NotifyError (const Err: string);
begin
  Windows.MessageBox(0, pchar(Err), 'Error notification', Windows.MB_OK or Windows.MB_ICONEXCLAMATION);

  if AbortOnError then begin
    FatalError(Err);
  end;
end; // .procedure NotifyError

procedure FatalError (const Err: string);
begin
  DlgMes.MsgError(Err);
  GenerateException;
end; // .procedure FatalError

procedure Ret0; assembler;
asm
  // RET
end; // .procedure Ret0

procedure Ret4; assembler;
asm
  ret 4
end; // .procedure Ret4

procedure Ret8; assembler;
asm
  ret 8
end; // .procedure Ret8

procedure Ret12; assembler;
asm
  ret 12
end; // .procedure Ret12

procedure Ret16; assembler;
asm
  ret 16
end; // .procedure Ret16

procedure Ret20; assembler;
asm
  ret 20
end; // .procedure Ret20

procedure Ret24; assembler;
asm
  ret 24
end; // .procedure Ret24

procedure Ret28; assembler;
asm
  ret 28
end; // .procedure Ret28

procedure Ret32; assembler;
asm
  ret 32
end; // .procedure Ret32

function Ret (NumArgs: integer): pointer;
begin
  case NumArgs of 
    0: result := @Ret0;
    1: result := @Ret4;
    2: result := @Ret8;
    3: result := @Ret12;
    4: result := @Ret16;
    5: result := @Ret20;
    6: result := @Ret24;
    7: result := @Ret28;
    8: result := @Ret32;
  else
    result := nil;
    {!} Assert(false);
  end; // .SWITCH NumArgs
end; // .function Ret

function GetModuleList: TModuleList;
var
{O} ModuleInfo:     TModuleInfo;
    ModuleInfoRes:  PsApi.TModuleInfo;
    ModuleHandles:  array of HMODULE;
    CurrentProcess: THandle;
    SizeNeeded:     cardinal;
    NumModules:     integer;
    i:              integer;

begin
  ModuleInfo := nil;
  // * * * * * //
  result         := DataLib.NewStrList(Utils.OWNS_ITEMS, DataLib.CASE_SENSITIVE);
  CurrentProcess := GetCurrentProcess;
  SetLength(ModuleHandles, 16000);

  if PsApi.EnumProcessModules(CurrentProcess, @ModuleHandles[0],
                              Length(ModuleHandles) * sizeof(ModuleHandles[0]), SizeNeeded)
  then begin
    NumModules := SizeNeeded div sizeof(HMODULE);

    for i := 0 to NumModules - 1 do begin
      if PsApi.GetModuleInformation(CurrentProcess, ModuleHandles[i], @ModuleInfoRes,
                                    sizeof(ModuleInfoRes))
      then begin
        ModuleInfo := TModuleInfo.Create;

        with ModuleInfo do begin
          Path       := WinWrappers.GetModuleFileName(ModuleHandles[i]);
          BaseAddr   := pointer(ModuleHandles[i]);
          EntryPoint := ModuleInfoRes.EntryPoint;
          Size       := ModuleInfoRes.SizeOfImage;
        end; // .with

        ModuleInfo.EvaluateDerivatives;
        result.AddObj(ModuleInfo.Name, ModuleInfo); ModuleInfo := nil;
      end; // .if
    end; // .for
  end; // .if
  // * * * * * //
  FreeAndNil(ModuleInfo);
end; // .function GetModuleList

function FindModuleByAddr ({n} Addr: pointer; ModuleList: TModuleList;
                           out ModuleInd: integer): boolean;
var
  i: integer;

begin
  {!} Assert(ModuleList <> nil);
  result := Addr <> nil;
  
  if result then begin
    i := 0;

    while (i < ModuleList.Count) and
           not (TObject(ModuleList.Values[i]) as TModuleInfo).OwnsAddr(Addr)
    do begin
      Inc(i);
    end; // .while

    result := i < ModuleList.Count;

    if result then begin
      ModuleInd := i;
    end; // .if
  end; // .if
end; // .function FindModuleByAddr

begin
  GlobalPatcher := PatchApi.GetPatcher;
  p             := GlobalPatcher.CreateInstance(pchar(WinWrappers.GetModuleFileName(hInstance)));
  ModuleContext := TModuleContext.Create;
  Maps          := DataLib.NewDict(Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
end.
