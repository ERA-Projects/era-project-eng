PROGRAM BinMagic;
{
DESCRIPTION:  Manager of binary patches for the ERA project
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

USES
  SysUtils, Utils, CFiles, Files, CmdApp, DlgMes, TypeWrappers, Lists,
  BinMan, Windows;

{$R *.res}

CONST
  TEXT_PATCH            = 'text';
  BINARY_PATCH          = 'binary';
  AUTODETECT_PATCHTYPE  = 'autodetect';

  TEXT_EXT  = '.txt';

  DOMAIN_FILE   = 0;
  DOMAIN_MEMORY = 1;

  OPTION_PATCHFOR       = 'PatchFor';
  OPTION_ADDRCONVERTER  = 'AddrConverter';
  DEFAULT_ADDRCONVERTER = 'DefaultAddrConverter.dll';

  PATCHFOR_MEMORY = 'memory';
  PATCHFOR_FILE   = 'file';

  SET_PATCH_DOMAIN_PROC = 'SetPatchDomain';
  CONVERT_ADDR_FUNC     = 'ConvertAddr';

  KEY_OPTIMIZE  = 'Optimize';
  KEY_STRIPTAGS = 'StripTags';

  ARG_CMD             = 'Cmd';
  ARG_SOURCE_PATCH    = 'SourcePatch';
  ARG_SOURCEPATCHTYPE = 'SourcePatchType';
  ARG_ORIGFILE        = 'OrigFile';
  ARG_MODIFIEDFILE    = 'ModifiedFile';
  ARG_RESULTPATCH     = 'ResultPatch';
  ARG_RESULTPATCHTYPE = 'ResultPatchType';
  ARG_PATCH           = 'Patch';
  ARG_PATCHTYPE       = 'PatchType';
  ARG_APPLYTO         = 'ApplyTo';


TYPE
  (* IMPORT *)
  TString   = TypeWrappers.TString;
  TBinPatch = BinMan.TBinPatch;

  TCmdHandler = FUNCTION (OUT Error: STRING): BOOLEAN;

  TSetPatchDomainProc = PROCEDURE (Domain: INTEGER); STDCALL;
  TConvertAddrFunc    = FUNCTION (Addr: INTEGER): INTEGER; STDCALL;


VAR
{O} CmdList:            Lists.TStringList {OF TCmdHandler};
    SetPatchDomainProc: TSetPatchDomainProc;
    ConvertAddrFunc:    TConvertAddrFunc;


FUNCTION GetArg (CONST ArgName: STRING): STRING;
BEGIN
  RESULT  :=  SysUtils.AnsiLowerCase(CmdApp.GetArg(ArgName));
END; // .FUNCTION GetArg

FUNCTION ArgsExist (CONST ArgNames: ARRAY OF STRING; OUT Error: STRING): BOOLEAN;
VAR
  NumArgs:  INTEGER;
  i:        INTEGER;

BEGIN
  {!} ASSERT(Error = '');
  RESULT  :=  TRUE;
  NumArgs :=  LENGTH(ArgNames);
  i       :=  0;
  WHILE (i < NumArgs) AND RESULT DO BEGIN
    RESULT  :=  CmdApp.GetArg(ArgNames[i]) <> '';
    INC(i);
  END; // .WHILE
  IF NOT RESULT THEN BEGIN
    Error :=  'Argument "' + ArgNames[i - 1] + '" is required';
  END; // .IF
END; // .FUNCTION ArgsExist

FUNCTION ConvertAddr (Addr: INTEGER): INTEGER;
BEGIN
  RESULT  :=  ConvertAddrFunc(Addr);
END; // .FUNCTION ConvertAddr

FUNCTION PreprocessPatch (Patch: TBinPatch; OUT Error: STRING): BOOLEAN;
VAR
  PatchFor:           STRING;
  AddrConverter:      STRING;
  AddrConverterPath:  STRING;
  hAddrConverter:     INTEGER;
  PatchDomain:        INTEGER;

BEGIN
  {!} ASSERT(Patch <> NIL);
  {!} ASSERT(Error = '');
  RESULT    :=  TRUE;
  PatchFor  :=  GetArg(OPTION_PATCHFOR);
  IF PatchFor <> '' THEN BEGIN
    RESULT  :=  (PatchFor = PATCHFOR_MEMORY) OR (PatchFor = PATCHFOR_FILE);
    IF NOT RESULT THEN BEGIN
      Error :=  'Invalid PatchFor argument: "' + PatchFor + '"';
    END // .IF
    ELSE BEGIN
      AddrConverter :=  GetArg(OPTION_ADDRCONVERTER);
      IF AddrConverter = '' THEN BEGIN
        AddrConverter :=  DEFAULT_ADDRCONVERTER;
      END; // .IF
      AddrConverterPath :=  SysUtils.ExtractFileDir(ParamStr(0)) + '\' + AddrConverter;
      hAddrConverter    :=  Windows.LoadLibrary(PCHAR(AddrConverterPath));
      RESULT            :=  hAddrConverter <> 0;
      IF NOT RESULT THEN BEGIN
        Error :=  'Cannot load library "' + AddrConverterPath + '"';
      END // .IF
      ELSE BEGIN
        SetPatchDomainProc  :=  Windows.GetProcAddress(hAddrConverter, SET_PATCH_DOMAIN_PROC);
        ConvertAddrFunc     :=  Windows.GetProcAddress(hAddrConverter, CONVERT_ADDR_FUNC);
        RESULT              :=  (@SetPatchDomainProc <> NIL) AND (@ConvertAddrFunc <> NIL);
        IF NOT RESULT THEN BEGIN
          Error :=  'Library "' + AddrConverterPath + '" does not implement necessary interface';
        END; // .IF
      END; // .ELSE
    END; // .ELSE
    IF RESULT THEN BEGIN
      IF PatchFor = PATCHFOR_MEMORY THEN BEGIN
        PatchDomain :=  DOMAIN_MEMORY;
      END // .IF
      ELSE BEGIN
        PatchDomain :=  DOMAIN_FILE;
      END; // .ELSE
      SetPatchDomainProc(PatchDomain);
      Patch.ConvertAddresses(ConvertAddr);
      IF PatchDomain = DOMAIN_MEMORY THEN BEGIN
        Patch.Tags.Items['Applies to']  :=  TString.Create('Memory');
      END // .IF
      ELSE BEGIN
        Patch.Tags.Items['Applies to']  :=  TString.Create('File');
      END; // .ELSE
    END; // .IF
  END; // .IF
  IF RESULT THEN BEGIN
    Patch.Tags.Items['Generator'] :=  TString.Create('BinMagic');
    IF GetArg(KEY_OPTIMIZE) <> '' THEN BEGIN
      Patch.Optimize;
    END; // .IF
    IF GetArg(KEY_STRIPTAGS) <> '' THEN BEGIN
      Patch.Tags.Clear;
    END; // .IF
  END; // .IF
END; // .FUNCTION PreprocessPatch

FUNCTION LoadFile (CONST FilePath: STRING; OUT FileContents: STRING; OUT Error: STRING): BOOLEAN;
BEGIN
  {!} ASSERT(Error = '');
  RESULT  :=  Files.ReadFileContents(FilePath, FileContents);
  IF NOT RESULT THEN BEGIN
    Error :=  'Cannot load file "' + FilePath + '"';
  END; // .IF
END; // .FUNCTION LoadFile

FUNCTION SaveFile (CONST FileContents, FilePath: STRING; OUT Error: STRING): BOOLEAN;
BEGIN
  {!} ASSERT(Error = '');
  RESULT  :=  Files.WriteFileContents(FileContents, FilePath);
  IF NOT RESULT THEN BEGIN
    Error :=  'Cannot save file "' + FilePath + '"';
  END; // .IF
END; // .FUNCTION SaveFile

FUNCTION LoadPatch
(
  CONST PatchPath:  STRING;
        PatchType:  STRING;
  OUT   Patch:      TBinPatch;
  OUT   Error:      STRING
): BOOLEAN;

VAR
{O} OtherPatch:         TBinPatch;
{O} Locator:            Files.TFileLocator;
{O} FileInfo:           CFiles.TItemInfo;
    FileName:           STRING;
    PatchContents:      STRING;
    CurrentPatchType:   STRING;
    
BEGIN
  {!} ASSERT(Patch = NIL);
  {!} ASSERT(Error = '');
  Patch       :=  TBinPatch.Create;
  OtherPatch  :=  TBinPatch.Create;
  Locator     :=  Files.TFileLocator.Create;
  FileInfo    :=  NIL;
  // * * * * * //
  IF PatchType = '' THEN BEGIN
    PatchType :=  AUTODETECT_PATCHTYPE;
  END; // .IF
  RESULT  :=
    (PatchType = TEXT_PATCH)    OR
    (PatchType = BINARY_PATCH)  OR
    (PatchType = AUTODETECT_PATCHTYPE);
  IF NOT RESULT THEN BEGIN
    Error :=  'Invalid patch type: "' + PatchType + '"';
  END; // .IF
  IF RESULT THEN BEGIN
    Locator.DirPath :=  SysUtils.ExtractFileDir(PatchPath);
    IF Locator.DirPath = '' THEN BEGIN
      Locator.DirPath :=  '.';
    END; // .IF
    Locator.InitSearch(SysUtils.ExtractFileName(PatchPath));
    RESULT  :=  Locator.NotEnd;
    IF NOT RESULT THEN BEGIN
      Error :=  'Cannot find file/s "' + PatchPath + '"';
    END // .IF
    ELSE BEGIN
      FileName  :=  Locator.GetNextItem(FileInfo);
      SysUtils.FreeAndNil(FileInfo);
      RESULT  :=  LoadFile(Locator.DirPath + '\' + FileName, PatchContents, Error);
      IF RESULT THEN BEGIN
        CurrentPatchType  :=  PatchType;
        IF CurrentPatchType = AUTODETECT_PATCHTYPE THEN BEGIN
          IF SysUtils.AnsiLowerCase(SysUtils.ExtractFileExt(FileName)) = TEXT_EXT THEN BEGIN
            CurrentPatchType  :=  TEXT_PATCH;
          END // .IF
          ELSE BEGIN
            CurrentPatchType  :=  BINARY_PATCH;
          END; // .ELSE
        END; // .IF
        IF CurrentPatchType = TEXT_PATCH THEN BEGIN
          RESULT  :=  Patch.LoadSourcePatch(PatchContents, Error);
        END // .IF
        ELSE BEGIN
          Patch.LoadCompiledPatch(PatchContents);
        END; // .ELSE
      END; // .IF
      IF RESULT THEN BEGIN
        WHILE Locator.NotEnd AND RESULT DO BEGIN
          FileName  :=  Locator.GetNextItem(FileInfo);
          SysUtils.FreeAndNil(FileInfo);
          RESULT    :=  Files.ReadFileContents(Locator.DirPath + '\' + FileName, PatchContents);
          IF NOT RESULT THEN BEGIN
            Error :=  'Cannot load file "' + FileName + '"';
          END // .IF
          ELSE BEGIN
            CurrentPatchType  :=  PatchType;
            IF CurrentPatchType = AUTODETECT_PATCHTYPE THEN BEGIN
              IF SysUtils.AnsiLowerCase(SysUtils.ExtractFileExt(FileName)) = TEXT_EXT THEN BEGIN
                CurrentPatchType  :=  TEXT_PATCH;
              END // .IF
              ELSE BEGIN
                CurrentPatchType  :=  BINARY_PATCH;
              END; // .ELSE
            END; // .IF
            IF CurrentPatchType = TEXT_PATCH THEN BEGIN
              RESULT  :=  OtherPatch.LoadSourcePatch(PatchContents, Error);
            END // .IF
            ELSE BEGIN
              OtherPatch.LoadCompiledPatch(PatchContents);
            END; // .ELSE
          END; // .ELSE
          IF RESULT THEN BEGIN
            Patch.AddFromPatch(OtherPatch);
          END; // .IF
        END; // .WHILE
      END; // .IF
    END; // .ELSE
    Locator.FinitSearch;
  END; // .IF
  IF RESULT THEN BEGIN
    RESULT  :=  PreprocessPatch(Patch, Error);
  END; // .IF
  IF NOT RESULT THEN BEGIN
    SysUtils.FreeAndNil(Patch);
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(OtherPatch);
  SysUtils.FreeAndNil(Locator);
END; // .FUNCTION LoadPatch

FUNCTION SavePatch (Patch: TBinPatch; CONST PatchType, FilePath: STRING; OUT Error: STRING): BOOLEAN;
VAR
  CurrentPatchType: STRING;

BEGIN
  {!} ASSERT(Patch <> NIL);
  {!} ASSERT(Error = '');
  CurrentPatchType  :=  PatchType;
  IF CurrentPatchType = '' THEN BEGIN
    CurrentPatchType  :=  AUTODETECT_PATCHTYPE;
  END; // .IF
  RESULT  :=
    (CurrentPatchType = TEXT_PATCH)   OR
    (CurrentPatchType = BINARY_PATCH) OR
    (CurrentPatchType = AUTODETECT_PATCHTYPE);
  IF NOT RESULT THEN BEGIN
    Error :=  'Invalid patch type: "' + PatchType + '"';
  END // .IF
  ELSE BEGIN
    IF CurrentPatchType = AUTODETECT_PATCHTYPE THEN BEGIN
      IF SysUtils.AnsiLowerCase(SysUtils.ExtractFileExt(FilePath)) = TEXT_EXT THEN BEGIN
        CurrentPatchType  :=  TEXT_PATCH;
      END // .IF
      ELSE BEGIN
        CurrentPatchType  :=  BINARY_PATCH;
      END; // .ELSE
    END; // .IF
    RESULT  :=  FilePath <> '';
    IF NOT RESULT THEN BEGIN
      Error :=  'Result file path is not specified';
    END // .IF
    ELSE BEGIN
      IF CurrentPatchType = TEXT_PATCH THEN BEGIN
        RESULT  :=  SaveFile(Patch.MakeSourcePatch, FilePath, Error);
      END // .IF
      ELSE BEGIN
        RESULT  :=  SaveFile(Patch.MakeCompiledPatch, FilePath, Error);
      END; // .ELSE
    END; // .ELSE
  END; // .ELSE
END; // .FUNCTION SavePatch

FUNCTION Diff (CONST OrigFile, ModifiedFile: STRING; OUT Patch: TBinPatch; OUT Error: STRING): BOOLEAN;
CONST
  ARG_TOLERANCEDIST = 'ToleranceDist';

VAR
  OrigContents:     STRING;
  ModifiedContents: STRING;
  ToleranceDistStr: STRING;
  ToleranceDist:    INTEGER;

BEGIN
  {!} ASSERT(Patch = NIL);
  {!} ASSERT(Error = '');
  Patch :=  TBinPatch.Create;
  // * * * * * //
  RESULT  :=  OrigFile <> '';
  IF NOT RESULT THEN BEGIN
    Error :=  'Original file is not specified';
  END // .IF
  ELSE BEGIN
    RESULT  :=  ModifiedFile <> '';
    IF NOT RESULT THEN BEGIN
      Error :=  'New file is not specified';
    END // .IF
    ELSE BEGIN
      RESULT  :=
        LoadFile(OrigFile, OrigContents, Error) AND
        LoadFile(ModifiedFile, ModifiedContents, Error);
    END; // .ELSE
  END; // .ELSE
  IF RESULT THEN BEGIN
    ToleranceDistStr  :=  GetArg(ARG_TOLERANCEDIST);
    IF ToleranceDistStr = '' THEN BEGIN
      ToleranceDist :=  BinMan.DEF_TOLERANCE_DIST;
    END // .IF
    ELSE BEGIN
      RESULT  :=  SysUtils.TryStrToInt(ToleranceDistStr, ToleranceDist);
      IF NOT RESULT THEN BEGIN
        Error :=  'Invalid ToleranceDist value: "' + ToleranceDistStr + '"';
      END; // .IF
    END; // .ELSE
    IF RESULT THEN BEGIN
      Patch.LoadDifference(OrigContents, ModifiedContents, ToleranceDist);
      RESULT  :=  PreprocessPatch(Patch, Error);
    END; // .IF
  END; // .IF
  IF NOT RESULT THEN BEGIN
    SysUtils.FreeAndNil(Patch);
  END; // .IF
END; // .FUNCTION Diff

FUNCTION ApplyPatch (Patch: TBinPatch; CONST ApplyTo: STRING; OUT Error: STRING): BOOLEAN;
VAR
  ResContents:  STRING;

BEGIN
  {!} ASSERT(Patch <> NIL);
  {!} ASSERT(Error = '');
  RESULT  :=
    LoadFile(ApplyTo, ResContents, Error) AND
    SaveFile(Patch.ApplyToStr(ResContents), ApplyTo, Error);
END; // .FUNCTION ApplyPatch

FUNCTION CmdConvertPatch (OUT Error: STRING): BOOLEAN;
VAR
{O} Patch:  BinMan.TBinPatch;

BEGIN
  Patch :=  NIL;
  // * * * * * //
  RESULT  :=
    ArgsExist([ARG_SOURCE_PATCH, ARG_RESULTPATCH], Error) AND
    LoadPatch(GetArg(ARG_SOURCE_PATCH), GetArg(ARG_SOURCEPATCHTYPE), Patch, Error)  AND
    SavePatch(Patch, GetArg(ARG_RESULTPATCHTYPE), GetArg(ARG_RESULTPATCH), Error);
  // * * * * * //
  SysUtils.FreeAndNil(Patch);
END; // .FUNCTION CmdConvertPatch

FUNCTION CmdMakePatch (OUT Error: STRING): BOOLEAN;
VAR
{O} Patch:  BinMan.TBinPatch;

BEGIN
  Patch :=  NIL;
  // * * * * * //
  RESULT  :=
    ArgsExist([ARG_ORIGFILE, ARG_MODIFIEDFILE, ARG_RESULTPATCH], Error) AND
    Diff(GetArg(ARG_ORIGFILE), GetArg(ARG_MODIFIEDFILE), Patch, Error)    AND
    SavePatch(Patch, GetArg(ARG_RESULTPATCHTYPE), GetArg(ARG_RESULTPATCH), Error);
  // * * * * * //
  SysUtils.FreeAndNil(Patch);
END; // .FUNCTION CmdMakePatch

FUNCTION CmdApplyPatch (OUT Error: STRING): BOOLEAN;
VAR
{O} Patch:  BinMan.TBinPatch;

BEGIN
  Patch :=  NIL;
  // * * * * * //
  CmdApp.SetArg(OPTION_PATCHFOR, PATCHFOR_FILE);
  RESULT  :=
    ArgsExist([ARG_PATCH, ARG_APPLYTO], Error)  AND
    LoadPatch(GetArg(ARG_PATCH), GetArg(ARG_PATCHTYPE), Patch, Error) AND
    ApplyPatch(Patch, GetArg(ARG_APPLYTO), Error);
  // * * * * * //
  SysUtils.FreeAndNil(Patch);
END; // .FUNCTION CmdApplyPatch

PROCEDURE RegisterCommands;
BEGIN
  CmdList                       :=  Lists.NewSimpleStrList;
  CmdList.CaseInsensitive       :=  TRUE;
  CmdList.Sorted                :=  TRUE;
  CmdList.Items['ConvertPatch'] :=  @CmdConvertPatch;
  CmdList.Items['MakePatch']    :=  @CmdMakePatch;
  CmdList.Items['ApplyPatch']   :=  @CmdApplyPatch;
END; // .PROCEDURE RegisterCommands

FUNCTION ProcessCmd (CONST Cmd: STRING; OUT Error: STRING): BOOLEAN;
VAR
  CmdHandler: TCmdHandler;

BEGIN
  {!} ASSERT(Error = '');
  CmdHandler  :=  CmdList.Items[Cmd];
  RESULT      :=  @CmdHandler <> NIL;
  IF NOT RESULT THEN BEGIN
    Error :=  'Invalid command "' + Cmd + '"';
  END // .IF
  ELSE BEGIN
    RESULT  :=  CmdHandler(Error);
  END; // .ELSE
END; // .FUNCTION ProcessCmd

FUNCTION Run: BOOLEAN;
VAR
  Error:  STRING;

BEGIN
  Error   :=  '';
  RESULT  :=  ArgsExist([ARG_CMD], Error);
  IF RESULT THEN BEGIN
    RegisterCommands;
    RESULT  :=  ProcessCmd(GetArg(ARG_CMD), Error);
  END; // .IF
  IF NOT RESULT THEN BEGIN
    DlgMes.MsgError(Error);
  END; // .IF
END; // .FUNCTION Run

BEGIN
  Run;
END.
