unit CmdApp;
{
DESCRIPTION:  Provides new-style command line handling and some inter-process functions
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(*
New style command line: ArgName=ArgValue "Arg Name"="Arg Value"
Simple "ArgName" means ArgName:1.
Argument names are case-insensitive.
Duplicate arguments override the previous ones.
*)

(***)  interface  (***)
uses Windows, SysUtils, Utils, TypeWrappers, Crypto, TextScan, AssocArrays, Lists;

const
  (* RunProcess *)
  WAIT_PROCESS_END  = TRUE;


type
  (* IMPORT *)
  TString = TypeWrappers.TString;


function  ArgExists (const ArgName: string): boolean;
function  GetArg (const ArgName: string): string;
procedure SetArg (const ArgName, NewArgValue: string);
function  RunProcess (const ExeFilePath, ExeArgs, ExeCurrentDir: string; WaitEnd: boolean): boolean;


var
{O} Args:     {O} AssocArrays.TAssocArray {OF TString};
{O} ArgsList: Lists.TStringList;
    AppPath:  string;


(***)  implementation  (***)


function ArgExists (const ArgName: string): boolean;
begin
  result  :=  Args[ArgName] <> nil;
end; // .function ArgExists

function GetArg (const ArgName: string): string;
var
{U} ArgValue: TString;

begin
  ArgValue  :=  Args[ArgName];
  // * * * * * //
  if ArgValue <> nil then begin
    result  :=  ArgValue.Value;
  end // .if
  else begin
    result  :=  '';
  end; // .else
end; // .function GetArg

procedure SetArg (const ArgName, NewArgValue: string);
var
{U} ArgValue: TString;
  
begin
  ArgValue  :=  Args[ArgName];
  // * * * * * //
  if ArgValue <> nil then begin
    ArgValue.Value  :=  NewArgValue;
  end // .if
  else begin
    Args[ArgName] :=  TString.Create(NewArgValue);
  end; // .else
end; // .procedure SetArg

procedure ProcessArgs;
const
  BLANKS    = [#0..#32];
  ARGDELIM  = BLANKS + ['='];

var
{O} Scanner:  TextScan.TTextScanner;
    CmdLine:  string;
    ArgName:  string;
    ArgValue: string;
    SavedPos: integer;
    c:        char;

  function ReadToken (const ArgDelimCharset: Utils.TCharSet): string;
  begin
    {!} Assert(Scanner.GetCurrChar(c));
    
    if c = '"' then begin
      Scanner.GotoNextChar;
      Scanner.ReadTokenTillDelim(['"'], result);
      Scanner.GotoNextChar;
    end // .if
    else begin
      Scanner.ReadTokenTillDelim(ArgDelimCharset, result);
    end; // .else
  end; // .function ReadToken

begin
  Scanner :=  TextScan.TTextScanner.Create;
  // * * * * * //
  CmdLine   :=  System.CmdLine;
  Args      :=  AssocArrays.NewStrictAssocArr(TString);
  ArgsList  :=  Lists.NewSimpleStrList;
  Scanner.Connect(CmdLine, #10);
  
  if Scanner.SkipCharset(BLANKS) then begin
    AppPath :=  ReadToken(BLANKS);
  end; // .if
  
  while Scanner.SkipCharset(BLANKS) do begin
    SavedPos  :=  Scanner.Pos;
    ArgsList.Add(ReadToken(BLANKS));
    Scanner.GotoPos(SavedPos);
    ArgName :=  ReadToken(ARGDELIM);
    
    if Scanner.GetCurrChar(c) then begin
      if c = '=' then begin
        Scanner.GotoNextChar;
        ArgValue  :=  ReadToken(BLANKS);
      end // .if
      else begin
        ArgValue  :=  '1';
      end; // .else
    end // .if
    else begin
      ArgValue  :=  '1';
    end; // .else
    
    Args[ArgName] :=  TString.Create(ArgValue);
  end; // .while
  // * * * * * //
  SysUtils.FreeAndNil(Scanner);
end; // .procedure ProcessArgs

function RunProcess (const ExeFilePath, ExeArgs, ExeCurrentDir: string; WaitEnd: boolean): boolean;
const
  NO_APPLICATION_NAME         = nil;
  DEFAULT_PROCESS_ATTRIBUTES  = nil;
  DEFAULT_THREAD_ATTRIBUTES   = nil;
  INHERIT_HANDLES             = TRUE;
  NO_CREATION_FLAGS           = 0;
  INHERIT_ENVIROMENT          = nil;

var
  StartupInfo:  Windows.TStartupInfo;
  ProcessInfo:  Windows.TProcessInformation;
  
begin
  FillChar(StartupInfo, sizeof(StartupInfo), #0);
  StartupInfo.cb  :=  sizeof(StartupInfo);
  result          :=  Windows.CreateProcess
  (
    NO_APPLICATION_NAME,
    pchar('"' + ExeFilePath + '" ' + ExeArgs),
    DEFAULT_PROCESS_ATTRIBUTES,
    DEFAULT_THREAD_ATTRIBUTES,
    not INHERIT_HANDLES,
    NO_CREATION_FLAGS,
    INHERIT_ENVIROMENT,
    pointer(ExeCurrentDir),
    StartupInfo,
    ProcessInfo
  );
  
  if result and WaitEnd then begin
    Windows.WaitForSingleObject(ProcessInfo.hProcess, Windows.INFINITE);
  end; // .if
end; // .function RunProcess

begin
  ProcessArgs;
end.
