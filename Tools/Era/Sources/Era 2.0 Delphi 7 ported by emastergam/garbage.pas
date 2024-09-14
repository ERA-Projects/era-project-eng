{729ad3 - hdlg:find (id)
72b820 - destructor
777030 - loadtxt name, file
7770b5 - unload.txt
55d300}

PGlobalEvent  = ^TGlobalEvent;
TGlobalEvent  = PACKED RECORD (* FORMAT TOKEN *)
  Dummy1: INTEGER;
  Mes:    TGameString;
  Dummy2: ARRAY [0..35] OF BYTE;
END; // .RECORD TGlobalEvent

PMapSettings  = ^TMapSettings;
TMapSettings  = PACKED RECORD (* FORMAT TOKEN *)
  Dummy:            ARRAY [0..$83] OF BYTE;
  FirstGlobalEvent: PGlobalEvent;
  EndGlobalEvent:   PGlobalEvent;
  (* Dummy *)
END; // .RECORD TMapSettings

//ZvsGameBeforeSave 750093 at 4beb3b

FUNCTION Hook_AfterApplyDamage (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  WOG_MF_DAMAGE:  PINTEGER  = Ptr($2811888);

VAR
  HookAddr:  INTEGER;

BEGIN
  HookAddr :=  INTEGER(Context.RetAddr) - SIZEOF(Core.THookRec);
  CASE HookAddr OF 
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
  ELSE
    {!} ASSERT(FALSE);
  END; // .SWITCH HookAddr
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_AfterApplyDamage

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

PROCEDURE LoadExtraErm;
CONST
  SCRIPTS_PATH        = 'Data\s';
  WOG_SCRIPTS_PREFIX  = 'script';

  PRIORITY_SEPARATOR  = ' ';
  DEFAULT_PRIORITY    = 0;

  SCRIPTNAME_NUM_TOKENS = 2;
  PRIORITY_TOKEN        = 0;
  SCRIPTNAME_TOKEN      = 1;

VAR
{O} ScriptList: Lists.TStringList {OF ScriptPriority: INTEGER}
{O} Locator:    Files.TFileLocator;
{O} FileInfo:   Files.TFileItemInfo;

    ScriptName:         STRING;
    ScriptContents:     Utils.TArrayOfString;
    ScriptNameTokens:   Utils.TArrayOfString;
    ScriptPriority:     INTEGER;
    TestPriority:       INTEGER;
    ScriptInd:          INTEGER;
    ScriptEndMarkerPos: INTEGER;
    i:                  INTEGER;
    j:                  INTEGER;

BEGIN
  ScriptList  :=  Lists.NewSimpleStrList;
  Locator     :=  Files.TFileLocator.Create;
  FileInfo    :=  NIL;
  // * * * * * //
  Locator.DirPath :=  SCRIPTS_PATH;

  ScriptList.CaseInsensitive   :=  TRUE;
  ScriptList.Sorted            :=  TRUE;
  ScriptList.ForbidDuplicates  :=  TRUE;

  Locator.InitSearch('*.erm');
  
  WHILE Locator.NotEnd DO BEGIN
    ScriptName :=  Locator.GetNextItem(Files.TItemInfo(FileInfo));

    IF
      NOT SysUtils.AnsiStartsText(WOG_SCRIPTS_PREFIX, ScriptName) OR
      NOT SysUtils.TryStrToInt
      (
        System.Copy(ScriptName, LENGTH(WOG_SCRIPTS_PREFIX) + 1),
        ScriptInd
      ) OR
      NOT Math.InRange(ScriptInd, 0, ERM_MAX_NUM_SCRIPTS - 1)
    THEN BEGIN
      ScriptNameTokens :=  StrLib.ExplodeEx
      (
        ScriptName,
        PRIORITY_SEPARATOR,
        NOT StrLib.INCLUDE_DELIM,
        StrLib.LIMIT_TOKENS,
        SCRIPTNAME_NUM_TOKENS
      );

      ScriptPriority  :=  DEFAULT_PRIORITY;
      
      IF
        (LENGTH(ScriptNameTokens) = SCRIPTNAME_NUM_TOKENS)  AND
        (SysUtils.TryStrToInt(ScriptNameTokens[PRIORITY_TOKEN], TestPriority))
      THEN BEGIN
        ScriptPriority  :=  TestPriority;
      END; // .IF

      ScriptList.AddObj(ScriptName, Ptr(ScriptPriority));
    END; // .IF

    SysUtils.FreeAndNil(FileInfo);
  END; // .WHILE
  
  Locator.FinitSearch;

  ScriptList.Sorted            :=  FALSE;
  ScriptList.ForbidDuplicates  :=  FALSE;
  ScriptList.CaseInsensitive   :=  FALSE;

  (* Sort via insertion by Priority *)
  FOR i:=1 TO ScriptList.Count - 1 DO BEGIN
    ScriptPriority  :=  INTEGER(ScriptList.Values[i]);
    j               :=  i - 1;

    WHILE (j >= 0) AND (ScriptPriority > INTEGER(ScriptList.Values[j])) DO BEGIN
      DEC(j);
    END; // .WHILE

    ScriptList.Move(i, j + 1);
  END; // .FOR

  SetLength(ScriptContents, ScriptList.Count);
  FirstScriptSize :=  0;
  LastScriptSize  :=  0;
  
  FOR i:=0 TO ScriptList.Count - 1 DO BEGIN
    IF
      NOT Files.ReadFileContents(SCRIPTS_PATH + '\' + ScriptList.Keys[i], ScriptContents[i]) OR
      (LENGTH(ScriptContents[i]) <= LENGTH(SCRIPT_POSTFIX))
    THEN BEGIN
      ScriptContents[i] :=  NIL;
    END // .IF
    ELSE BEGIN
      Priority  :=  INTEGER(ScriptList.Values[i]);
      
      IF Priority < 0 THEN BEGIN
        FirstScriptSize  :=  FirstScriptSize + LENGTH(ScriptContents[i]) - LENGTH(SCRIPT_POSTFIX);
        FirstScriptBuilder.AppendBuf(POINTER(ScriptContents), ScriptEndMarkerPos - 1);
      END // .IF
      ELSE BEGIN
        LastScriptBuilder.AppendBuf(POINTER(ScriptContents), ScriptEndMarkerPos - 1);
      END; // .ELSE
    END; // .ELSE
  END; // .FOR
  
      
  
  StrLib.RevFindChar(SCRIPT_END_MARKER, ScriptContents[i], ScriptEndMarkerPos)
  
  (*
  replace script00.erm and script99.erm
  *)
  // * * * * * //
  SysUtils.FreeAndNil(ScriptList);
  SysUtils.FreeAndNil(Locator);
END; // .PROCEDURE LoadExtraErm