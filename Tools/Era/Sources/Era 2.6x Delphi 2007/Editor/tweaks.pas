unit Tweaks;
{
DESCRIPTION:  Fixed and improvements
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, SysUtils, Utils, Core, FilesEx, Concur, DataLib,
  MapExt, Editor;

  
(***) implementation (***)


var
{O} TopLevelExceptionHandlers: DataLib.TList {OF Handler: pointer};
    ExceptionsCritSection:     Concur.TCritSection;

procedure DumpWinPeModuleList;
const
  DEBUG_WINPE_MODULE_LIST_PATH = MapExt.DEBUG_DIR + '\pe modules.txt';

var
  i: integer;

begin
  {!} Core.ModuleContext.Lock;
  Core.ModuleContext.UpdateModuleList;

  with FilesEx.WriteFormattedOutput(DEBUG_WINPE_MODULE_LIST_PATH) do begin
    Line('> Win32 executable modules');
    EmptyLine;

    for i := 0 to Core.ModuleContext.ModuleList.Count - 1 do begin
      Line(Core.ModuleContext.ModuleInfo[i].ToStr);
    end; // .for
  end; // .with

  {!} Core.ModuleContext.Unlock;
end; // .procedure DumpWinPeModuleList

procedure DumpExceptionContext (ExcRec: Windows.PExceptionRecord; Context: Windows.PContext);
const
  DEBUG_EXCEPTION_CONTEXT_PATH = MapExt.DEBUG_DIR + '\exception context.txt';

var
  ExceptionText: string;
  LineText:      string;
  Ebp:           integer;
  Esp:           integer;
  RetAddr:       integer;
  i:             integer;

begin
  {!} Core.ModuleContext.Lock;
  Core.ModuleContext.UpdateModuleList;

  with FilesEx.WriteFormattedOutput(DEBUG_EXCEPTION_CONTEXT_PATH) do begin
    case ExcRec.ExceptionCode of
      $C0000005: begin
        if ExcRec.ExceptionInformation[0] <> 0 then begin
          ExceptionText := 'Failed to write data at ' + Format('%x', [integer(ExcRec.ExceptionInformation[1])]);
        end else begin
          ExceptionText := 'Failed to read data at ' + Format('%x', [integer(ExcRec.ExceptionInformation[1])]);
        end; // .else
      end; // .case $C0000005

      $C000008C: ExceptionText := 'Array index is out of bounds';
      $80000003: ExceptionText := 'Breakpoint encountered';
      $80000002: ExceptionText := 'Data access misalignment';
      $C000008D: ExceptionText := 'One of the operands in a floating-point operation is denormal';
      $C000008E: ExceptionText := 'Attempt to divide a floating-point value by a floating-point divisor of zero';
      $C000008F: ExceptionText := 'The result of a floating-point operation cannot be represented exactly as a decimal fraction';
      $C0000090: ExceptionText := 'Invalid floating-point exception';
      $C0000091: ExceptionText := 'The exponent of a floating-point operation is greater than the magnitude allowed by the corresponding type';
      $C0000092: ExceptionText := 'The stack overflowed or underflowed as the result of a floating-point operation';
      $C0000093: ExceptionText := 'The exponent of a floating-point operation is less than the magnitude allowed by the corresponding type';
      $C000001D: ExceptionText := 'Attempt to execute an illegal instruction';
      $C0000006: ExceptionText := 'Attempt to access a page that was not present, and the system was unable to load the page';
      $C0000094: ExceptionText := 'Attempt to divide an integer value by an integer divisor of zero';
      $C0000095: ExceptionText := 'Integer arithmetic overflow';
      $C0000026: ExceptionText := 'An invalid exception disposition was returned by an exception handler';
      $C0000025: ExceptionText := 'Attempt to continue from an exception that isn''t continuable';
      $C0000096: ExceptionText := 'Attempt to execute a privilaged instruction.';
      $80000004: ExceptionText := 'Single step exception';
      $C00000FD: ExceptionText := 'Stack overflow';
      else       ExceptionText := 'Unknown exception';
    end; // .switch ExcRec.ExceptionCode
    
    Line(ExceptionText + '.');
    Line(Format('EIP: %s. Code: %x', [Core.ModuleContext.AddrToStr(Ptr(Context.Eip)), ExcRec.ExceptionCode]));
    EmptyLine;
    Line('> Registers');

    Line('EAX: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Eax), Core.ANALYZE_DATA));
    Line('ECX: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Ecx), Core.ANALYZE_DATA));
    Line('EDC: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Edx), Core.ANALYZE_DATA));
    Line('EBX: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Ebx), Core.ANALYZE_DATA));
    Line('ESP: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Esp), Core.ANALYZE_DATA));
    Line('EBP: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Ebp), Core.ANALYZE_DATA));
    Line('ESI: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Esi), Core.ANALYZE_DATA));
    Line('EDI: ' + Core.ModuleContext.AddrToStr(Ptr(Context.Edi), Core.ANALYZE_DATA));

    EmptyLine;
    Line('> Callstack');
    Ebp     := Context.Ebp;
    RetAddr := 1;

    try
      while (Ebp <> 0) and (RetAddr <> 0) do begin
        RetAddr := pinteger(Ebp + 4)^;

        if RetAddr <> 0 then begin
          Line(Core.ModuleContext.AddrToStr(Ptr(RetAddr)));
          Ebp := pinteger(Ebp)^;
        end; // .if
      end; // .while
    except
      // Stop processing callstack
    end; // .try

    EmptyLine;
    Line('> Stack');
    Esp := Context.Esp - sizeof(integer) * 5;

    try
      for i := 1 to 40 do begin
        LineText := IntToHex(Esp, 8);

        if Esp = integer(Context.Esp) then begin
          LineText := LineText + '*';
        end; // .if

        LineText := LineText + ': ' + Core.ModuleContext.AddrToStr(ppointer(Esp)^, Core.ANALYZE_DATA);
        Inc(Esp, sizeof(integer));
        Line(LineText);
      end; // .for
    except
      // Stop stack traversing
    end; // .try
  end; // .with

  {!} Core.ModuleContext.Unlock;
end; // .procedure DumpExceptionContext

function TopLevelExceptionHandler (const ExceptionPtrs: TExceptionPointers): integer; stdcall;
const
  EXCEPTION_CONTINUE_SEARCH = 0;

begin
  SysUtils.SetCurrentDir(GameDir);
  DumpExceptionContext(ExceptionPtrs.ExceptionRecord, ExceptionPtrs.ContextRecord);
  MapExt.FireEvent('OnGenerateDebugInfo', nil, 0);
  Windows.MessageBox(0, 'Editor is crashing, sorry. Look at "' + MapExt.DEBUG_DIR + '" for debug info.', 'Something went wrong :(', Windows.MB_OK or Windows.MB_ICONEXCLAMATION);

  result := EXCEPTION_CONTINUE_SEARCH;
end; // .function TopLevelExceptionHandler

function OnUnhandledException (const ExceptionPtrs: TExceptionPointers): integer; stdcall;
type
  THandler = function (const ExceptionPtrs: TExceptionPointers): integer; stdcall;

const
  EXCEPTION_CONTINUE_SEARCH = 0;

var
  i: integer;

begin
  {!} ExceptionsCritSection.Enter;

  for i := 0 to TopLevelExceptionHandlers.Count - 1 do begin
    THandler(TopLevelExceptionHandlers[i])(ExceptionPtrs);
  end;

  {!} ExceptionsCritSection.Leave;
  
  result := EXCEPTION_CONTINUE_SEARCH;
end; // .function OnUnhandledException

function Hook_SetUnhandledExceptionFilter (Context: Core.PHookContext): longbool; stdcall;
var
{Un} NewHandler: pointer;

begin
  NewHandler := ppointer(Context.ESP + 8)^;
  // * * * * * //
  if NewHandler <> nil then begin
    {!} ExceptionsCritSection.Enter;
    TopLevelExceptionHandlers.Add(NewHandler);
    {!} ExceptionsCritSection.Leave;
  end;

  (* result = nil *)
  pinteger(Context.EAX)^ := 0;

  (* return to calling routing *)
  Context.RetAddr := Core.Ret(1);
  
  result := Core.IGNORE_DEF_CODE;
end; // .function Hook_SetUnhandledExceptionFilter

function Hook_FixGameVersion (Context: Core.PHookContext): longbool; stdcall;
begin
  Editor.GameVersion^ := AB_AND_SOD;
  result              := Core.EXEC_DEF_CODE;
end;

procedure OnGenerateDebugInfo (Event: PEvent); stdcall;
begin
  DumpWinPeModuleList;
end;

procedure OnInit (Event: MapExt.PEvent); stdcall;
begin
  (* Install global top-level exception filter *)
  Windows.SetErrorMode(SEM_NOGPFAULTERRORBOX);
  Windows.SetUnhandledExceptionFilter(@OnUnhandledException);
  Core.ApiHook(@Hook_SetUnhandledExceptionFilter, Core.HOOKTYPE_BRIDGE, @Windows.SetUnhandledExceptionFilter);
  Windows.SetUnhandledExceptionFilter(@TopLevelExceptionHandler);

  (* Fix game version to allow generating random maps *)
  Core.Hook(@Hook_FixGameVersion, Core.HOOKTYPE_BRIDGE, 5, Ptr($45C5FD));

  (* Fix crashing on exit is some kind of destructor *)
  Core.p.WriteCodePatch(Ptr($4DC080), ['C3']);
end;

begin
  ExceptionsCritSection.Init;
  TopLevelExceptionHandlers := DataLib.NewList(not Utils.OWNS_ITEMS);
  MapExt.RegisterHandler(OnInit, 'OnInit');
  RegisterHandler(OnGenerateDebugInfo, 'OnGenerateDebugInfo');
end.
