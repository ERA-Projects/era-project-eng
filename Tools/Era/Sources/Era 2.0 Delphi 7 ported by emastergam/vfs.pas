UNIT VFS;
{
DESCRIPTION:  Virtual File System
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  Windows, SysUtils, Math, Utils, Crypto, Lists, AssocArrays, StrLib,
  StrUtils, Files, Log, TypeWrappers, MMSystem,
  Core;

(*
Redirects calls to:
  CreateFileA,
  GetFileAttributesA,
  FindFirstFileA,
  FindNextFileA,
  FindClose,
  LoadLibraryA,
  DeleteFileA,
  CreateDirectoryA,
  RemoveDirectoryA,
  GetPrivateProfileStringA,
  LoadCursorFromFileA,
  PlaySoundA,
  GetCurrentDirectoryA,
  SetCurrentDirectoryA
*)

(* IMPORT *)
TYPE
  TAssocArray = AssocArrays.TAssocArray;
  TString     = TypeWrappers.TString;


CONST
  MODS_DIR      = 'Mods';
  WOG_LOD_NAME  = 'hmm35wog.pac';


TYPE
  PModPos = ^TModPos;
  TModPos = RECORD
    Priority:     INTEGER;
    CreationTime: Windows.TFileTime;
  END; // .RECORD TModPos

  TSearchList = CLASS
    {O} FileList: {O} Lists.TStringList {OF Windows.PWin32FindData};
        FileInd:  INTEGER;

    CONSTRUCTOR Create;
    DESTRUCTOR  Destroy; OVERRIDE;
  END; // .CLASS TSearchList


VAR
{O} ModList:        {O} Lists.TStringList {OF PModPos};
(*
CachedPaths, case RedirectedPath of
  '[Full path to file in Mods]' => file exists, no search is necessary
  ''                            => file does not exist in Mods, no search is necessary
  NIL                           => no information, search is necessary
*)
{O} CachedPaths:    TAssocArray {OF RelPath: STRING => RedirectedPath: TString};
{O} SearchHandles:  TObjArray {OF hSearch: INTEGER => Value: TSearchList};

  hSearch:  INTEGER = 1;
  
  CachedPathsCritSection: Windows.TRTLCriticalSection;
  FileSearchCritSection:  Windows.TRTLCriticalSection;
  FileSearchInProgress:   BOOLEAN;
  CurrDirCritSection:     Windows.TRTLCriticalSection;
  
  NativeGetFileAttributes:  FUNCTION (FilePath: PCHAR): INTEGER; STDCALL;
  
  Kernel32Handle: INTEGER;
  User32Handle:   INTEGER;

  GamePath:   STRING;
  CurrentDir: STRING;
  
  DebugOpt: BOOLEAN;


(***) IMPLEMENTATION (***)


CONSTRUCTOR TSearchList.Create;
BEGIN
  Self.FileList  :=  Lists.NewStrList
  (
    Utils.OWNS_ITEMS,
    NOT Utils.ITEMS_ARE_OBJECTS,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );

  Self.FileList.CaseInsensitive   :=  TRUE;
  Self.FileList.ForbidDuplicates  :=  TRUE;
END; // .CONSTRUCTOR TSearchList.Create

DESTRUCTOR TSearchList.Destroy;
BEGIN
  SysUtils.FreeAndNil(Self.FileList);
END; // .DESTRUCTOR TSearchList.Destroy

FUNCTION IsRelativePath (CONST Path: STRING): BOOLEAN;
VAR
  DesignatorPos:  INTEGER;

BEGIN
  RESULT :=
    NOT StrLib.FindChar(':', Path, DesignatorPos) AND
    NOT StrUtils.AnsiStartsStr('\\', Path);
END; // .FUNCTION IsRelativePath

PROCEDURE MakeModList;
  FUNCTION ComparePos (Pos1, Pos2: PModPos): INTEGER;
  BEGIN
    RESULT  :=  Pos2.Priority - Pos1.Priority;
    IF RESULT = 0 THEN BEGIN
      RESULT  :=  Pos2.CreationTime.dwHighDateTime - Pos1.CreationTime.dwHighDateTime;
      IF RESULT = 0 THEN BEGIN
        RESULT  :=  Pos2.CreationTime.dwLowDateTime - Pos1.CreationTime.dwLowDateTime;
      END; // .IF
    END; // .IF
  END; // .FUNCTION ComparePos

CONST
  PRIORITY_SEPARATOR  = ' ';
  DEFAULT_PRIORITY    = 0;

  MODNAME_NUM_TOKENS  = 2;
  PRIORITY_TOKEN      = 0;
  MODNAME_TOKEN       = 1;

VAR
{O} Locator:        Files.TFileLocator;
{O} FileInfo:       Files.TFileItemInfo;
{U} ModPos:         PModPos;
    ModName:        STRING;
    ModNameTokens:  Utils.TArrayOfString;
    Priority:       INTEGER;
    TestPriority:   INTEGER;
    i:              INTEGER;
    j:              INTEGER;

BEGIN
  Locator   :=  Files.TFileLocator.Create;
  FileInfo  :=  NIL;
  ModPos    :=  NIL;
  // * * * * * //
  Locator.DirPath :=  StrLib.Concat([GamePath, '\', MODS_DIR]);
  Locator.InitSearch('*');
  
  WHILE Locator.NotEnd DO BEGIN
    ModName :=  Locator.GetNextItem(Files.TItemInfo(FileInfo));

    IF (ModName <> '.') AND (ModName <> '..') AND FileInfo.IsDir THEN BEGIN
      ModNameTokens :=  StrLib.ExplodeEx
      (
        ModName,
        PRIORITY_SEPARATOR,
        NOT StrLib.INCLUDE_DELIM,
        StrLib.LIMIT_TOKENS,
        MODNAME_NUM_TOKENS
      );

      Priority  :=  DEFAULT_PRIORITY;
      
      IF
        (LENGTH(ModNameTokens) = MODNAME_NUM_TOKENS)  AND
        (SysUtils.TryStrToInt(ModNameTokens[PRIORITY_TOKEN], TestPriority))
      THEN BEGIN
        Priority  :=  TestPriority;
      END; // .IF

      NEW(ModPos);
      ModPos.Priority     :=  Priority;
      ModPos.CreationTime :=  FileInfo.Data.ftCreationTime;

      ModList.AddObj(ModName, ModPos);
    END; // .IF

    SysUtils.FreeAndNil(FileInfo);
  END; // .WHILE
  
  Locator.FinitSearch;

  (* Sort via insertion by Priority/Time *)
  FOR i:=1 TO ModList.Count - 1 DO BEGIN
    ModPos  :=  ModList.Values[i];
    j       :=  i - 1;

    WHILE (j >= 0) AND (ComparePos(ModPos, ModList.Values[j]) < 0) DO BEGIN
      DEC(j);
    END; // .WHILE

    ModList.Move(i, j + 1);
  END; // .FOR

  FOR i:=0 TO ModList.Count - 1 DO BEGIN
    ModList.Keys[i] :=  StrLib.Concat([GamePath, '\' + MODS_DIR + '\', ModList.Keys[i]]);
  END; // .FOR
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .PROCEDURE MakeModList

FUNCTION FileExists (CONST FilePath: STRING): BOOLEAN;
BEGIN
  RESULT  :=  NativeGetFileAttributes(PCHAR(FilePath)) <> - 1;
END; // .FUNCTION FileExists

FUNCTION DirExists (CONST FilePath: STRING): BOOLEAN;
VAR
  Attrs:  INTEGER;

BEGIN
  Attrs   :=  NativeGetFileAttributes(PCHAR(FilePath));
  RESULT  :=  (Attrs <> - 1) AND ((Attrs AND Windows.FILE_ATTRIBUTE_DIRECTORY) <> 0);
END; // .FUNCTION DirExists

FUNCTION FindVFSPath (CONST RelativePath: STRING; OUT RedirectedPath: STRING): BOOLEAN;
VAR
{U} RedirectedPathValue:  TString;
    NumMods:              INTEGER;
    i:                    INTEGER;

BEGIN
  RedirectedPathValue :=  NIL;
  // * * * * * //
  {!} Windows.EnterCriticalSection(CachedPathsCritSection);
  
  RESULT  :=  FALSE;
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'FindVFSPath', 'Original: ' + RelativePath);
  END; // .IF
  
  IF CachedPaths.GetExistingValue(RelativePath, POINTER(RedirectedPathValue)) THEN BEGIN
    RESULT  :=  RedirectedPathValue.Value <> '';
    
    IF RESULT THEN BEGIN
      RedirectedPath  :=  RedirectedPathValue.Value;
    END; // .IF
  END // .IF
  ELSE BEGIN
    NumMods :=  ModList.Count;
    i       :=  0;
    
    WHILE (i < NumMods) AND NOT RESULT DO BEGIN
      RedirectedPath  :=  StrLib.Concat([ModList[i], '\', RelativePath]);
      RESULT          :=  FileExists(RedirectedPath);
      
      INC(i);
    END; // .WHILE
    
    IF RESULT THEN BEGIN
      CachedPaths[RelativePath] :=  TString.Create(RedirectedPath);
    END // .IF
    ELSE BEGIN
      CachedPaths[RelativePath] :=  TString.Create('');
    END; // .ELSE
  END; // .ELSE

  IF DebugOpt THEN BEGIN
    IF RESULT THEN BEGIN
      Log.Write('VFS', 'FindVFSPath', 'Redirected: ' + RedirectedPath);
    END // .IF
    ELSE BEGIN
      Log.Write('VFS', 'FindVFSPath', 'Result: NOT_FOUND');
    END; // .ELSE
  END; // .IF
  
  {!} Windows.LeaveCriticalSection(CachedPathsCritSection);
END; // .FUNCTION FindVFSPath

FUNCTION IsInGameDir (CONST FullPath: STRING): BOOLEAN;
BEGIN
  RESULT :=
    ((LENGTH(FullPath) - LENGTH(GamePath)) > 1) AND
    StrUtils.AnsiStartsText(GamePath, FullPath) AND
    (FullPath[LENGTH(GamePath) + 1] = '\');
END; // .FUNCTION IsInGameDir

FUNCTION GameRelativePath (CONST FullPath: STRING): STRING;
BEGIN
{#}  RESULT :=  System.Copy(FullPath, LENGTH(GamePath) + SIZEOF('\') + 1, 65535);
END; // .FUNCTION GameRelativePath

PROCEDURE MyScanDir (CONST SearchDir, SearchMask: STRING; SearchList: TSearchList);
VAR
{O} Locator:    Files.TFileLocator;
{O} FileInfo:   Files.TFileItemInfo;
{U} FoundData:  Windows.PWin32FindData;
    FileName:   STRING;

BEGIN
  {!} ASSERT(SearchList <> NIL);
  Locator   :=  Files.TFileLocator.Create;
  FileInfo  :=  NIL;
  // * * * * * //
  Locator.DirPath :=  SearchDir;

  Locator.InitSearch(SearchMask);

  WHILE Locator.NotEnd DO BEGIN
    FileName  :=  Locator.GetNextItem(Files.TItemInfo(FileInfo));

    IF SearchList.FileList.Items[FileName] = NIL THEN BEGIN
      NEW(FoundData);
      FoundData^  :=  FileInfo.Data;
      SearchList.FileList.AddObj(FileName, FoundData);
    END; // .IF

    SysUtils.FreeAndNil(FileInfo);
  END; // .WHILE

  Locator.FinitSearch;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .PROCEDURE MyScanDir

FUNCTION MyFindFirstFile
(
  CONST SearchDir:        STRING;
  CONST SearchMask:       STRING;
        IsInternalSearch: BOOLEAN;
  OUT   ResHandle:        INTEGER
): BOOLEAN;

VAR
{O} SearchList: TSearchList;
    i:          INTEGER;

BEGIN
  SearchList  :=  TSearchList.Create;
  // * * * * * //
  IF IsInternalSearch THEN BEGIN
    FOR i:=0 TO ModList.Count - 1 DO BEGIN
      MyScanDir(ModList[i], SearchMask, SearchList);
    END; // .FOR
    MyScanDir(GamePath, SearchMask, SearchList);
  END // .IF
  ELSE BEGIN
    MyScanDir(SearchDir, SearchMask, SearchList);
  END; // .ELSE
  
  RESULT :=  SearchList.FileList.Count > 0;
  
  IF RESULT THEN BEGIN 
    WHILE SearchHandles[Ptr(hSearch)] <> NIL DO BEGIN
      INC(hSearch);
      
      IF hSearch < 0 THEN BEGIN
        hSearch :=  1;
      END; // .IF
    END; // .WHILE
  
    ResHandle                     :=  hSearch;
    SearchHandles[Ptr(ResHandle)] :=  SearchList; SearchList :=  NIL;
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(SearchList);
END; // .FUNCTION MyFindFirstFile

FUNCTION MyFindNextFile (SearchHandle: INTEGER; OUT ResData: Windows.PWin32FindData): BOOLEAN;
VAR
{U} SearchList: TSearchList;

BEGIN
  {!} ASSERT(ResData = NIL);
  SearchList  :=  SearchHandles[Ptr(SearchHandle)];
  // * * * * * //
  RESULT  :=  (SearchList <> NIL) AND ((SearchList.FileInd + 1) < SearchList.FileList.Count);
  
  IF RESULT THEN BEGIN
    INC(SearchList.FileInd);
    ResData :=  SearchList.FileList.Values[SearchList.FileInd];
  END; // .IF
END; // .FUNCTION MyFindNextFile

FUNCTION Hook_GetFullPathNameA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 4;
  ARG_FILENAME  = 1;
  ARG_BUFFER    = 3;

VAR
  FilePath: STRING;
  Buffer:   PCHAR;
  ApiRes:   STRING;

BEGIN
  FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
  Buffer    :=  PCHAR(Core.APIArg(Context, ARG_BUFFER).v);

  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'GetFullPathNameA', 'Original: ' + FilePath);
  END; // .IF
  
  (* zvslib1.dll fix. The dll uses registry to find game folder and access h3sprite.lod which was
  renamed to WOG_LOD_NAME, so we have to override the path fully if file name is the magic one *)
  
  IF SysUtils.AnsiLowerCase(SysUtils.ExtractFileName(FilePath)) = WOG_LOD_NAME THEN BEGIN
    FilePath  :=  GamePath + ('\Data\' + WOG_LOD_NAME);
  END // .IF
  ELSE BEGIN
    IF IsRelativePath(FilePath) THEN BEGIN
      Windows.EnterCriticalSection(CurrDirCritSection);
      FilePath  :=  StrLib.Concat([CurrentDir, '\', FilePath]);
      Windows.LeaveCriticalSection(CurrDirCritSection);
    END; // .IF
  END; // .ELSE
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'GetFullPathNameA', 'Redirected: ' + FilePath);
  END; // .IF
  
  Core.APIArg(Context, ARG_FILENAME).v  :=  INTEGER(FilePath);
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  
  IF DebugOpt THEN BEGIN
    System.SetString(ApiRes, Buffer, Context.EAX);
    Log.Write('VFS', 'GetFullPathNameA', 'Result: ' + ApiRes);
  END; // .IF
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_GetFullPathNameA

FUNCTION Hook_CreateFileA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS            = 7;
  ARG_FILENAME        = 1;
  ARG_CREATION_FLAGS  = 5;

VAR
  FilePath:           STRING;
  RedirectedFilePath: STRING;
  FinalFilePath:      STRING;
  CreationFlags:      INTEGER;

BEGIN
  FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'CreateFileA', 'Original: ' + FilePath);
  END; // .IF
  
  FilePath      :=  SysUtils.ExpandFileName(FilePath);
  CreationFlags :=  Core.APIArg(Context, ARG_CREATION_FLAGS).v;
  FinalFilePath :=  FilePath;

  IF
    IsInGameDir(FilePath) AND
    (
      ((CreationFlags AND Windows.OPEN_EXISTING)      = Windows.OPEN_EXISTING) OR
      ((CreationFlags AND Windows.TRUNCATE_EXISTING)  = Windows.TRUNCATE_EXISTING)
    ) AND
    FindVFSPath(GameRelativePath(FilePath), RedirectedFilePath)
  THEN BEGIN
    FinalFilePath :=  RedirectedFilePath;
  END; // .IF
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'CreateFileA', 'Redirected: ' + FinalFilePath);
  END; // .IF
  
  Core.APIArg(Context, ARG_FILENAME).v :=  INTEGER(FinalFilePath);
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_CreateFileA

FUNCTION Hook_GetFileAttributesA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 1;
  ARG_FILENAME  = 1;

VAR
  FilePath:           STRING;
  RedirectedFilePath: STRING;
  FinalFilePath:      STRING;

BEGIN
  FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'GetFileAttributesA', 'Original: ' + FilePath);
  END; // .IF
  
  FilePath      :=  SysUtils.ExpandFileName(FilePath);
  FinalFilePath :=  FilePath;

  IF
    IsInGameDir(FilePath) AND
    FindVFSPath(GameRelativePath(FilePath), RedirectedFilePath)
  THEN BEGIN
    FinalFilePath :=  RedirectedFilePath;
  END; // .IF

  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'GetFileAttributesA', 'Redirected: ' + FinalFilePath);
  END; // .IF
  
  Core.APIArg(Context, ARG_FILENAME).v :=  INTEGER(FinalFilePath);
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_GetFileAttributesA

FUNCTION Hook_LoadLibraryA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 1;
  ARG_FILENAME  = 1;

VAR
  FilePath:           STRING;
  RedirectedFilePath: STRING;
  FinalFilePath:      STRING;

BEGIN
  FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'LoadLibraryA', 'Original: ' + FilePath);
  END; // .IF
  
  FilePath  :=  SysUtils.ExpandFileName(FilePath);

  IF IsInGameDir(FilePath) THEN BEGIN
    FinalFilePath :=  '';
    
    IF FindVFSPath(GameRelativePath(FilePath), RedirectedFilePath) THEN BEGIN
      FinalFilePath :=  RedirectedFilePath;
    END; // .IF
    
    IF (FinalFilePath = '') AND FileExists(FilePath) THEN BEGIN
      FinalFilePath :=  FilePath;
    END; // .IF
  
    IF FinalFilePath <> '' THEN BEGIN
      Core.APIArg(Context, ARG_FILENAME).v :=  INTEGER(FinalFilePath);
    
      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'LoadLibraryA', 'Redirected: ' + FinalFilePath);
      END; // .IF
    END; // .IF
  END; // .IF
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);

  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_LoadLibraryA

FUNCTION Hook_CreateDirectoryA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 2;
  ARG_DIR_PATH  = 1;

VAR
  DirPath:            STRING;
  RedirectedDirPath:  STRING;
  
BEGIN
  DirPath  :=  PCHAR(Core.APIArg(Context, ARG_DIR_PATH).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'CreateDirectoryA', 'Original: ' + DirPath);
  END; // .IF

  RedirectedDirPath :=  SysUtils.ExpandFileName(DirPath);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'CreateDirectoryA', 'Redirected: ' + RedirectedDirPath);
  END; // .IF

  Core.APIArg(Context, ARG_DIR_PATH).v :=  INTEGER(RedirectedDirPath);
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_CreateDirectoryA

FUNCTION Hook_RemoveDirectoryA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 1;
  ARG_DIR_PATH  = 1;

VAR
  DirPath:            STRING;
  RedirectedDirPath:  STRING;
  
BEGIN
  DirPath  :=  PCHAR(Core.APIArg(Context, ARG_DIR_PATH).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'RemoveDirectoryA', 'Original: ' + DirPath);
  END; // .IF

  RedirectedDirPath :=  SysUtils.ExpandFileName(DirPath);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'RemoveDirectoryA', 'Redirected: ' + RedirectedDirPath);
  END; // .IF

  Core.APIArg(Context, ARG_DIR_PATH).v :=  INTEGER(RedirectedDirPath);
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_RemoveDirectoryA

FUNCTION Hook_FindFirstFileA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 2;
  ARG_FILENAME  = 1;
  ARG_FIND_DATA = 2;

VAR
{U} FoundData:        Windows.PWin32FindData;
    SearchDir:        STRING;
    FilePath:         STRING;
    FoundPath:        STRING;
    ResHandle:        INTEGER;
    IsInternalSearch: BOOLEAN;

BEGIN
  {!} Windows.EnterCriticalSection(FileSearchCritSection);

  RESULT  :=  FileSearchInProgress;

  IF NOT RESULT THEN BEGIN
    FileSearchInProgress  :=  TRUE;
    
    FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
  
    IF DebugOpt THEN BEGIN
      Log.Write('VFS', 'FindFirstFileA', 'Original: ' + FilePath);
    END; // .IF
  
    FilePath          :=  SysUtils.ExpandFileName(FilePath);
    FoundData         :=  POINTER(Core.APIArg(Context, ARG_FIND_DATA).v);
    IsInternalSearch  :=  IsInGameDir(FilePath);
    
    IF IsInternalSearch THEN BEGIN
      SearchDir :=  GamePath;
      FilePath  :=  GameRelativePath(FilePath);
    END // .IF
    ELSE BEGIN
      SearchDir :=  SysUtils.ExtractFileDir(FilePath);
      FilePath  :=  SysUtils.ExtractFileName(FilePath);
    END; // .ELSE

    IF DebugOpt THEN BEGIN
      Log.Write
      (
        'VFS',
        'FindFirstFileA',
        StrLib.Concat(['SearchDir: ', SearchDir, #13#10, 'SearchMask: ', FilePath])
      );
    END; // .IF
    
    IF MyFindFirstFile(SearchDir, FilePath, IsInternalSearch, ResHandle) THEN BEGIN
      Context.EAX :=  ResHandle;
      FoundData^  :=  Windows.PWin32FindData
      (
        TSearchList(SearchHandles[Ptr(ResHandle)]).FileList.Values[0]
      )^;
      Windows.SetLastError(Windows.ERROR_SUCCESS);
    
      IF DebugOpt THEN BEGIN
        FoundPath :=  FoundData.cFileName;
        Log.Write
        (
          'VFS',
          'FindFirstFileA',
          StrLib.Concat(['Handle: ', SysUtils.IntToStr(ResHandle), #13#10, 'Result: ', FoundPath])
        );
      END; // .IF
    END // .IF
    ELSE BEGIN
      Context.EAX :=  INTEGER(Windows.INVALID_HANDLE_VALUE);
      Windows.SetLastError(Windows.ERROR_NO_MORE_FILES);
      
      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'FindFirstFileA', 'Error: ERROR_NO_MORE_FILES');
      END; // .IF
    END; // .ELSE

    Context.RetAddr :=  Core.Ret(NUM_ARGS);
    
    FileSearchInProgress  :=  FALSE;
  END; // .IF
  
  {!} Windows.LeaveCriticalSection(FileSearchCritSection);
END; // .FUNCTION Hook_FindFirstFileA

FUNCTION Hook_FindNextFileA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS          = 2;
  ARG_SEARCH_HANDLE = 1;
  ARG_FIND_DATA     = 2;

VAR
{U} FoundDataArg: Windows.PWin32FindData;
{U} FoundData:    Windows.PWin32FindData;
    SearchHandle: INTEGER;
    FoundPath:    STRING;

BEGIN
  {!} Windows.EnterCriticalSection(FileSearchCritSection);
  
  RESULT  :=  FileSearchInProgress;

  IF NOT RESULT THEN BEGIN
    FileSearchInProgress  :=  TRUE;
  
    SearchHandle  :=  Core.APIArg(Context, ARG_SEARCH_HANDLE).v;
    FoundDataArg  :=  POINTER(Core.APIArg(Context, ARG_FIND_DATA).v);

    IF DebugOpt THEN BEGIN
      Log.Write('VFS', 'FindNextFileA', 'Handle: ' + SysUtils.IntToStr(SearchHandle))
    END; // .IF
    
    FoundData   :=  NIL;
    Context.EAX :=  ORD(MyFindNextFile(SearchHandle, FoundData));

    IF Context.EAX <> 0 THEN BEGIN
      FoundDataArg^  :=  FoundData^;
      Windows.SetLastError(Windows.ERROR_SUCCESS);
      
      IF DebugOpt THEN BEGIN
        FoundPath :=  FoundData.cFileName;
        Log.Write('VFS', 'FindNextFileA', 'Result: ' + FoundPath)
      END; // .IF
    END // .IF
    ELSE BEGIN
      Windows.SetLastError(Windows.ERROR_NO_MORE_FILES);
      
      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'FindNextFileA', 'Error: ERROR_NO_MORE_FILES')
      END; // .IF
    END; // .ELSE
    
    Context.RetAddr :=  Core.Ret(NUM_ARGS);
    
    FileSearchInProgress  :=  FALSE;
  END; // .IF

  {!} Windows.LeaveCriticalSection(FileSearchCritSection);
END; // .FUNCTION Hook_FindNextFileA

FUNCTION Hook_FindClose (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS          = 1;
  ARG_SEARCH_HANDLE = 1;

VAR
  SearchHandle: INTEGER;

BEGIN
  {!} Windows.EnterCriticalSection(FileSearchCritSection);
  
  RESULT  :=  FileSearchInProgress;

  IF NOT RESULT THEN BEGIN
    SearchHandle  :=  Core.APIArg(Context, ARG_SEARCH_HANDLE).v;
    
    IF DebugOpt THEN BEGIN
      Log.Write('VFS', 'FindClose', 'Handle: ' + SysUtils.IntToStr(SearchHandle))
    END; // .IF
  
    Context.EAX :=  ORD(SearchHandles[Ptr(SearchHandle)] <> NIL);

    IF Context.EAX <> 0 THEN BEGIN
      SearchHandles.DeleteItem(Ptr(SearchHandle));
      Windows.SetLastError(Windows.ERROR_SUCCESS);
      
      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'FindClose', 'Result: ERROR_SUCCESS');
      END; // .IF
    END // .IF
    ELSE BEGIN
      Windows.SetLastError(Windows.ERROR_INVALID_HANDLE);
      
      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'FindClose', 'Result: ERROR_INVALID_HANDLE');
      END; // .IF
    END; // .ELSE
    
    Context.RetAddr :=  Core.Ret(NUM_ARGS);
  END; // .IF

  {!} Windows.LeaveCriticalSection(FileSearchCritSection);
END; // .FUNCTION Hook_FindClose

FUNCTION Hook_GetPrivateProfileStringA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 6;
  ARG_FILENAME  = 6;

VAR
  FilePath:           STRING;
  RedirectedFilePath: STRING;
  FinalPath:          STRING;

BEGIN
  FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'GetPrivateProfileStringA', 'Original: ' + FilePath);
  END; // .IF
  
  IF FilePath <> '' THEN BEGIN
    FilePath  :=  SysUtils.ExpandFileName(FilePath);
    FinalPath :=  FilePath;

    IF
      IsInGameDir(FilePath) AND
      FindVFSPath(GameRelativePath(FilePath), RedirectedFilePath)
    THEN BEGIN
      FinalPath :=  RedirectedFilePath;
    END; // .IF
    
    Core.APIArg(Context, ARG_FILENAME).v :=  INTEGER(FinalPath);
      
    IF DebugOpt THEN BEGIN
      Log.Write('VFS', 'GetPrivateProfileStringA', 'Redirected: ' + FinalPath);
    END; // .IF
  END; // .IF
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);

  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_GetPrivateProfileStringA

FUNCTION Hook_PlaySoundA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 3;
  ARG_FILENAME  = 1;
  ARG_FLAGS     = 3;

VAR
  FilePath:           STRING;
  RedirectedFilePath: STRING;
  FinalPath:          STRING;
  Flags:              INTEGER;

BEGIN
  Flags :=  Core.APIArg(Context, ARG_FLAGS).v;
  
  IF
    (Flags <= SND_NOSTOP) OR
    ((Flags AND MMSystem.SND_FILENAME) = MMSystem.SND_FILENAME)
  THEN BEGIN
    FilePath  :=  PCHAR(Core.APIArg(Context, ARG_FILENAME).v);
    
    IF FilePath <> '' THEN BEGIN
      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'PlaySoundA', 'Original: ' + FilePath);
      END; // .IF
      
      FilePath  :=  SysUtils.ExpandFileName(FilePath);
      FinalPath :=  FilePath;

      IF
        IsInGameDir(FilePath) AND
        FindVFSPath(GameRelativePath(FilePath), RedirectedFilePath)
      THEN BEGIN
        FinalPath :=  RedirectedFilePath;
      END; // .IF

      IF DebugOpt THEN BEGIN
        Log.Write('VFS', 'PlaySoundA', 'Redirected: ' + FinalPath);
      END; // .IF
      
      Core.APIArg(Context, ARG_FILENAME).v :=  INTEGER(FinalPath);
    END; // .IF
  END; // .IF
  
  Context.EAX     :=  Core.RecallAPI(Context, NUM_ARGS);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);

  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_PlaySoundA

FUNCTION Hook_GetCurrentDirectoryA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 2;
  ARG_BUF_SIZE  = 1;
  ARG_BUF       = 2;

VAR
{U} Buf:          PCHAR;
    BufSize:      INTEGER;
    FixedCurrDir: STRING;

BEGIN
  {!} Windows.EnterCriticalSection(CurrDirCritSection);
  
  FixedCurrDir  :=  CurrentDir;
  
  {!} Windows.LeaveCriticalSection(CurrDirCritSection);

  BufSize :=  Core.APIArg(Context, ARG_BUF_SIZE).v;
  Buf     :=  PCHAR(Core.APIArg(Context, ARG_BUF).v);

  Context.EAX :=  ORD(Utils.IsValidBuf(Buf, BufSize));
  
  IF Context.EAX <> 0 THEN BEGIN
    IF FixedCurrDir[LENGTH(FixedCurrDir)] = ':' THEN BEGIN
      FixedCurrDir  :=  FixedCurrDir + '\';
    END; // .IF
  
    Context.EAX :=  LENGTH(FixedCurrDir) + 1;
    
    IF (BufSize - 1) >= LENGTH(FixedCurrDir) THEN BEGIN
      Utils.CopyMem(LENGTH(FixedCurrDir) + 1, PCHAR(FixedCurrDir), Buf);
    END; // .IF
    
    Windows.SetLastError(Windows.ERROR_SUCCESS);
    
    IF DebugOpt THEN BEGIN
      Log.Write('VFS', 'GetCurrentDirectoryA', 'Result: ' + FixedCurrDir);
    END; // .IF
  END // .IF
  ELSE BEGIN
    Windows.SetLastError(Windows.ERROR_NOT_ENOUGH_MEMORY);
    
    IF DebugOpt THEN BEGIN
      Log.Write('VFS', 'GetCurrentDirectoryA', 'Error: ERROR_NOT_ENOUGH_MEMORY');
    END; // .IF
  END; // .ELSE

  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  RESULT          :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_GetCurrentDirectoryA

FUNCTION Hook_SetCurrentDirectoryA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS      = 1;
  ARG_DIR_PATH  = 1;

VAR
  DirPath:            STRING;
  RedirectedFilePath: STRING;
  i:                  INTEGER;

BEGIN
  DirPath :=  PCHAR(Core.APIArg(Context, ARG_DIR_PATH).v);
  
  IF DebugOpt THEN BEGIN
    Log.Write('VFS', 'SetCurrentDirectoryA', 'Original: ' + DirPath);
  END; // .IF
  
  DirPath :=  SysUtils.ExpandFileName(DirPath);
  i       :=  LENGTH(DirPath);
  
  WHILE (i > 0) AND (DirPath[i] = '\') DO BEGIN
    DEC(i);
  END; // .WHILE
  
  SetLength(DirPath, i);
  Context.EAX :=  ORD(DirPath <> '');
  
  IF Context.EAX <> 0 THEN BEGIN
    Context.EAX :=  ORD
    (
      DirExists(DirPath)  OR
      (
        IsInGameDir(DirPath)                                        AND
        FindVFSPath(GameRelativePath(DirPath), RedirectedFilePath)  AND
        DirExists(RedirectedFilePath)
      )
    );
    
    IF Context.EAX <> 0 THEN BEGIN
      {!} Windows.EnterCriticalSection(CurrDirCritSection);
      
      CurrentDir  :=  DirPath;
      
      {!} Windows.LeaveCriticalSection(CurrDirCritSection);
      
      Windows.SetLastError(Windows.ERROR_SUCCESS);
    END; // .IF
  END; // .IF

  IF Context.EAX = 0 THEN BEGIN
    Windows.SetLastError(Windows.ERROR_FILE_NOT_FOUND);
  END; // .IF
  
  IF DebugOpt THEN BEGIN
    IF Context.EAX <> 0 THEN BEGIN
      Log.Write('VFS', 'SetCurrentDirectoryA', 'Result: ' + DirPath);
    END // .IF
    ELSE BEGIN
      Log.Write('VFS', 'SetCurrentDirectoryA', 'Error: ERROR_FILE_NOT_FOUND');
    END; // .ELSE
  END; // .IF
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_SetCurrentDirectoryA

PROCEDURE AssertHandler (CONST Mes, FileName: STRING; LineNumber: INTEGER; Address: POINTER);
BEGIN
  Core.FatalError(StrLib.BuildStr(
    'Assert violation in file "~FileName~" on line ~Line~.'#13#10'Error at address: $~Address~.',
    [
      'FileName', FileName,
      'Line',     SysUtils.IntToStr(LineNumber),
      'Address',  SysUtils.Format('%x', [INTEGER(Address)])
    ],
    '~'
  ));
END; // .PROCEDURE AssertHandler

BEGIN
  Windows.InitializeCriticalSection(CachedPathsCritSection);
  Windows.InitializeCriticalSection(FileSearchCritSection);
  Windows.InitializeCriticalSection(CurrDirCritSection);
  
  AssertErrorProc :=  AssertHandler;

  ModList  :=  Lists.NewStrList
  (
    Utils.OWNS_ITEMS,
    NOT Utils.ITEMS_ARE_OBJECTS,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );

  CachedPaths   :=  AssocArrays.NewStrictAssocArr(TString);
  SearchHandles :=  AssocArrays.NewStrictObjArr(TSearchList);

  GamePath    :=  SysUtils.ExtractFileDir(ParamStr(0));
  CurrentDir  :=  GamePath;
  Windows.SetCurrentDirectory(PCHAR(GamePath));

  MakeModList;

  Kernel32Handle  :=  Windows.GetModuleHandle('kernel32.dll');
  User32Handle    :=  Windows.GetModuleHandle('user32.dll');
  
  Core.ApiHook
  (
    @Hook_GetFullPathNameA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'GetFullPathNameA')
  );
  
  Core.ApiHook
  (
    @Hook_CreateFileA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'CreateFileA')
  );
  
  NativeGetFileAttributes :=  Core.ApiHook
  (
    @Hook_GetFileAttributesA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'GetFileAttributesA')
  );
  
  Core.ApiHook
  (
    @Hook_LoadLibraryA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'LoadLibraryA')
  );
  
  Core.ApiHook
  (
    @Hook_CreateDirectoryA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'CreateDirectoryA')
  );
  
  Core.ApiHook
  (
    @Hook_RemoveDirectoryA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'RemoveDirectoryA')
  );
  
  Core.ApiHook
  (
    @Hook_RemoveDirectoryA, (* Similar action *)
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'DeleteFileA')
  );

  Core.ApiHook
  (
    @Hook_FindFirstFileA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'FindFirstFileA')
  );

  Core.ApiHook
  (
    @Hook_FindNextFileA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'FindNextFileA')
  );

  Core.ApiHook
  (
    @Hook_FindClose,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'FindClose')
  );
  
  {Core.ApiHook
  (
    @Hook_GetPrivateProfileStringA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'GetPrivateProfileStringA')
  );}
  
  Core.ApiHook
  (
    @Hook_GetFileAttributesA, (* Similar arguments *)
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(User32Handle, 'LoadCursorFromFileA')
  );
  
  Core.ApiHook
  (
    @Hook_PlaySoundA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Windows.LoadLibrary('winmm.dll'), 'PlaySoundA')
  );
  
  Core.ApiHook
  (
    @Hook_GetCurrentDirectoryA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'GetCurrentDirectoryA')
  );
  
  Core.ApiHook
  (
    @Hook_SetCurrentDirectoryA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Kernel32Handle, 'SetCurrentDirectoryA')
  );
END.
