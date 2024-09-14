{729ad3 - hdlg:find (id)
72b820 - destructor
777030 - loadtxt name, file
7770b5 - unload.txt
55d300}

PGlobalEvent  = ^TGlobalEvent;
TGlobalEvent  = packed record (* FORMAT TOKEN *)
  Dummy1: integer;
  Mes:    TGameString;
  Dummy2: array [0..35] of byte;
end; // .record TGlobalEvent

PMapSettings  = ^TMapSettings;
TMapSettings  = packed record (* FORMAT TOKEN *)
  Dummy:            array [0..$83] of byte;
  FirstGlobalEvent: PGlobalEvent;
  EndGlobalEvent:   PGlobalEvent;
  (* Dummy *)
end; // .record TMapSettings

//ZvsGameBeforeSave 750093 at 4beb3b

function Hook_AfterApplyDamage (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  WOG_MF_DAMAGE:  PINTEGER  = Ptr($2811888);

var
  HookAddr:  integer;

begin
  HookAddr :=  integer(Context.RetAddr) - sizeof(Core.THookRec);
  case HookAddr of 
    $43F960:  PINTEGER(Context.EBP - $1C)^  :=  WOG_MF_DAMAGE^;
    $43FA63:  Context.EBX                   :=  WOG_MF_DAMAGE^;
    $43FD42:  PINTEGER(Context.EBP - $1C)^  :=  WOG_MF_DAMAGE^;
    $4400E4:  Context.EBX                   :=  WOG_MF_DAMAGE^;
    $44085D:  Context.ESI                   :=  WOG_MF_DAMAGE^;
    $440E75:  Context.EBX                   :=  WOG_MF_DAMAGE^;
    $44104D:  PINTEGER(Context.EBP + $8)^   :=  WOG_MF_DAMAGE^;
    $441251:  Context.ESI                   :=  WOG_MF_DAMAGE^;
    $44173E:  PINTEGER(Context.EBP - $10)^  :=  WOG_MF_DAMAGE^;
    $44178F:  PINTEGER(Context.EBP - $20)^  :=  WOG_MF_DAMAGE^;
    $465964:  PINTEGER(Context.EBP + $8)^   :=  WOG_MF_DAMAGE^;
    $469A98:  Context.EBX                   :=  WOG_MF_DAMAGE^;
    $5A106A:  PINTEGER(Context.EBP - $34)^  :=  WOG_MF_DAMAGE^;
  else
    {!} Assert(false);
  end; // .switch HookAddr
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_AfterApplyDamage

(* Fix MF:F corrected damage log *)
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 10, Ptr($43F960));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 10, Ptr($43FA63));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 10, Ptr($43FD42));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 10, Ptr($4400E4));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($44085D));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($440E75));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($44104D));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($441251));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($44173E));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 10, Ptr($44178F));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($465964));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 6, Ptr($469A98));
Core.Hook(@Hook_AfterApplyDamage, Core.HOOKTYPE_BRIDGE, 5, Ptr($5A106A));

procedure LoadExtraErm;
const
  SCRIPTS_PATH        = 'Data\s';
  WOG_SCRIPTS_PREFIX  = 'script';

  PRIORITY_SEPARATOR  = ' ';
  DEFAULT_PRIORITY    = 0;

  SCRIPTNAME_NUM_TOKENS = 2;
  PRIORITY_TOKEN        = 0;
  SCRIPTNAME_TOKEN      = 1;

var
{O} ScriptList: Lists.TStringList {OF ScriptPriority: INTEGER}
{O} Locator:    Files.TFileLocator;
{O} FileInfo:   Files.TFileItemInfo;

    ScriptName:         string;
    ScriptContents:     Utils.TArrayOfStr;
    ScriptNameTokens:   Utils.TArrayOfStr;
    ScriptPriority:     integer;
    TestPriority:       integer;
    ScriptInd:          integer;
    ScriptEndMarkerPos: integer;
    i:                  integer;
    j:                  integer;

begin
  ScriptList  :=  Lists.NewSimpleStrList;
  Locator     :=  Files.TFileLocator.Create;
  FileInfo    :=  nil;
  // * * * * * //
  Locator.DirPath :=  SCRIPTS_PATH;

  ScriptList.CaseInsensitive   :=  true;
  ScriptList.Sorted            :=  true;
  ScriptList.ForbidDuplicates  :=  true;

  Locator.InitSearch('*.erm');
  
  while Locator.NotEnd do begin
    ScriptName :=  Locator.GetNextItem(Files.TItemInfo(FileInfo));

    if
      not SysUtils.AnsiStartsText(WOG_SCRIPTS_PREFIX, ScriptName) or
      not SysUtils.TryStrToInt
      (
        System.Copy(ScriptName, Length(WOG_SCRIPTS_PREFIX) + 1),
        ScriptInd
      ) or
      not Math.InRange(ScriptInd, 0, ERM_MAX_NUM_SCRIPTS - 1)
    then begin
      ScriptNameTokens :=  StrLib.ExplodeEx
      (
        ScriptName,
        PRIORITY_SEPARATOR,
        not StrLib.INCLUDE_DELIM,
        StrLib.LIMIT_TOKENS,
        SCRIPTNAME_NUM_TOKENS
      );

      ScriptPriority  :=  DEFAULT_PRIORITY;
      
      if
        (Length(ScriptNameTokens) = SCRIPTNAME_NUM_TOKENS)  and
        (SysUtils.TryStrToInt(ScriptNameTokens[PRIORITY_TOKEN], TestPriority))
      then begin
        ScriptPriority  :=  TestPriority;
      end; // .if

      ScriptList.AddObj(ScriptName, Ptr(ScriptPriority));
    end; // .if

    SysUtils.FreeAndNil(FileInfo);
  end; // .while
  
  Locator.FinitSearch;

  ScriptList.Sorted            :=  false;
  ScriptList.ForbidDuplicates  :=  false;
  ScriptList.CaseInsensitive   :=  false;

  (* Sort via insertion by Priority *)
  for i:=1 to ScriptList.Count - 1 do begin
    ScriptPriority  :=  integer(ScriptList.Values[i]);
    j               :=  i - 1;

    while (j >= 0) and (ScriptPriority > integer(ScriptList.Values[j])) do begin
      Dec(j);
    end; // .while

    ScriptList.Move(i, j + 1);
  end; // .for

  SetLength(ScriptContents, ScriptList.Count);
  FirstScriptSize :=  0;
  LastScriptSize  :=  0;
  
  for i:=0 to ScriptList.Count - 1 do begin
    if
      not Files.ReadFileContents(SCRIPTS_PATH + '\' + ScriptList.Keys[i], ScriptContents[i]) or
      (Length(ScriptContents[i]) <= Length(SCRIPT_POSTFIX))
    then begin
      ScriptContents[i] :=  nil;
    end // .if
    else begin
      Priority  :=  integer(ScriptList.Values[i]);
      
      if Priority < 0 then begin
        FirstScriptSize  :=  FirstScriptSize + Length(ScriptContents[i]) - Length(SCRIPT_POSTFIX);
        FirstScriptBuilder.AppendBuf(pointer(ScriptContents), ScriptEndMarkerPos - 1);
      end // .if
      else begin
        LastScriptBuilder.AppendBuf(pointer(ScriptContents), ScriptEndMarkerPos - 1);
      end; // .else
    end; // .else
  end; // .for
  
      
  
  StrLib.RevFindChar(SCRIPT_END_MARKER, ScriptContents[i], ScriptEndMarkerPos)
  
  (*
  replace script00.erm and script99.erm
  *)
  // * * * * * //
  SysUtils.FreeAndNil(ScriptList);
  SysUtils.FreeAndNil(Locator);
end; // .procedure LoadExtraErm

function Match (const Str, Pattern: string): boolean;
const
  ONE_SYM_WILDCARD  = '?';
  ANY_SYMS_WILLCARD = '*';
  WILDCARDS         = [ONE_SYM_WILDCARD, ANY_SYMS_WILLCARD];

type
  TState  =
  (
    STATE_STRICT_COMPARE,       // [L]
    STATE_FIRST_LETTER_SEARCH,  // *[L]
    STATE_MATCH_SUBSTR_TAIL,    // *L[...]*
    STATE_EXIT
  );

var
  State:          TState;
  StrLen:         integer;
  PatternLen:     integer;
  StrBasePos:     integer;
  PatternBasePos: integer;
  s:              integer;  // Pos in Pattern
  p:              integer;  // Pos in Str
  
  function CharMatch: boolean;
  begin
    result  :=
      (p <= PatternLen)                 and
      (s <= StrLen)                     and
      (Pattern[p] <> ANY_SYMS_WILDCARD) and
      (
        (Str[s]     = Pattern[p]) or
        (Pattern[p] = ONE_SYM_WILDCARD)
      )
  end; // .function CharMatch

  function StrictMatch: boolean;
  begin
    while CharMatch do begin
      Inc(p);
      Inc(s);
    end; // .while
    
    result  :=  ( <= StrLen;
  end; // .function StrictMatch
  
  function SkipWildcards: boolean;
  var
    NumOneSymWildcards: integer;
  
  begin
    NumOneSymWildcards  :=  0;
    
    while (p <= PatternLen) and (Pattern[p] in WILDCARDS) do begin
      if Pattern[p] = ONE_SYM_WILDCARD then begin
        Inc(NumOneSymWildcards);
      end; // .if
      
      Inc(p);
    end; // .while
    
    result  :=  (p <= PatternLen) and ((s + NumOneSymWildcards - 1) <= StrLen);
    
    if result then begin
      s :=  s + NumOneSymWildcards;
    end; // .if
  end; // .function SkipWildcards
  
  function FindNextStr;
  var
    StrBasePos:     integer;
    PatternBasePos: integer;
    
    function FindFirstChar: boolean;
    var
      c:  char;
    
    begin
      c :=  Pattern[p];
      
      while (s <= StrLen) and (Str[s] <> c) do begin
        Inc(s);
      end; // .while
      
      result  :=  s <= StrLen;
      
      if result then begin
        Inc(p);
        Inc(s);
      end; // .if
    end; // .function FindFirstChar
  
  begin
    result          :=  false;
    StrBasePos      :=  s;
    PatternBasePos  :=  p;
  
    while not result and (s <= StrLen) and FindFirstChar do begin
      while CharMatch do begin
        Inc(p);
        Inc(s);
      end; // .while
    end; // .while
    
    result  :=  s <= StrLen;
  end; // .function FindNextStr

begin
  StrLen          :=  Length(Str);
  PatternLen      :=  Length(Pattern);
  s               :=  1;
  p               :=  1;
  State           :=  STATE_STRICT_COMPARE;
  result          :=  false;
  
  if StrictMatch then begin
    while SkipWillcards and FindNextStr do begin end;
  end; // .if
end; // .function Match