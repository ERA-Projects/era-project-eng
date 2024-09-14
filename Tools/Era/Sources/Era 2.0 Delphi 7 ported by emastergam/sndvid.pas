UNIT SndVid;
{
DESCRIPTION:  Adds snd/vid archives autoloading support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  Windows, SysUtils, Utils, WinWrappers, Files, StrLib, Crypto, AssocArrays,
  Core, GameExt, Heroes;

CONST  
  CD_GAME_FOLDER  = 'Heroes3';
  CD_VIDEO_PATH   = CD_GAME_FOLDER + '\Data\Heroes3.vid';
  CD_AUDIO_PATH   = CD_GAME_FOLDER + '\Data\Heroes3.snd';
  
  
TYPE
  TArcType  = (ARC_SND, ARC_VID);

  PArcItem  = ^TArcItem;
  TArcItem  = PACKED RECORD
    Name:   ARRAY[0..39] OF CHAR; // For ARC_SND name is separated from extension with #0
    Offset: INTEGER;
  END; // .RECORD TArcItem
  
  PVidArcItem = PArcItem;
  TVidArcItem = TArcItem;
  
  PSndArcItem = ^TSndArcItem;
  TSndArcItem = PACKED RECORD
    Item: TArcItem;
    Size: INTEGER;
  END; // .RECORD TSndArcItem
  
  PItemInfo = ^TItemInfo;
  TItemInfo = RECORD
    hFile:  INTEGER;
    Offset: INTEGER;
    Size:   INTEGER;
  END; // .RECORD TItemInfo
  
  PResourceBuf  = ^TResourceBuf;
  TResourceBuf  = PACKED RECORD
    IsLoaded: BOOLEAN;
    _0:       ARRAY [0..2] OF BYTE;
    Addr:     POINTER;
  END; // .RECORD TResourceBuf


VAR
  LoadCDOpt: BOOLEAN;
  
  GameCDFound:  BOOLEAN;
  GameCDPath:   STRING;
  
  
(***) IMPLEMENTATION (***)


VAR
{O} SndFiles: {O} AssocArrays.TAssocArray {OF PItemInfo};
{O} VidFiles: {O} AssocArrays.TAssocArray {OF PItemInfo};


PROCEDURE FindGameCD;
CONST
  MAX_NUM_DRIVES  = 26;

VAR
  Drives:     INTEGER;
  OldErrMode: INTEGER;
  i:          INTEGER;

BEGIN
  OldErrMode  :=  Windows.SetErrorMode(Windows.SEM_FAILCRITICALERRORS);
  Drives      :=  Windows.GetLogicalDrives;
  GameCDPath  :=  'A:\';
  GameCDFound :=  FALSE;
  {!} ASSERT(Drives <> 0);
  
  i :=  0;

  WHILE (i < MAX_NUM_DRIVES) AND NOT GameCDFound DO BEGIN
    IF (Drives AND (1 SHL i)) <> 0 THEN BEGIN
      IF Windows.GetDriveType(PCHAR(GameCDPath)) = Windows.DRIVE_CDROM THEN BEGIN
        GameCDFound :=  SysUtils.DirectoryExists(GameCDPath + CD_GAME_FOLDER);
      END; // .IF
    END; // .IF
    
    IF NOT GameCDFound THEN BEGIN
      GameCDPath[1] :=  CHR(ORD(GameCDPath[1]) + 1);
    END; // .IF
    INC(i);
  END; // .WHILE
  
  Windows.SetErrorMode(OldErrMode);
END; // .PROCEDURE FindGameCD

PROCEDURE LoadArc (CONST ArcPath: STRING; ArcType: TArcType);
VAR
{U} ItemInfo: PItemInfo;
{U} ArcFiles: AssocArrays.TAssocArray {OF PItemInfo};
{U} CurrItem: PArcItem;
    hFile:    INTEGER;
    
    NumItems: INTEGER;
    ItemSize: INTEGER;
    ItemName: STRING;
    
    BufSize:  INTEGER;
    BufStr:   STRING;
    
    i:        INTEGER;

BEGIN
  ItemInfo  :=  NIL;
  ArcFiles  :=  NIL;
  CurrItem  :=  NIL;
  // * * * * * // 
  IF
    WinWrappers.FileOpen(ArcPath, SysUtils.fmOpenRead OR SysUtils.fmShareDenyWrite, hFile)
  THEN BEGIN
    CASE ArcType OF
      ARC_VID: BEGIN
        ItemSize  :=  SIZEOF(TVidArcItem);
        ArcFiles  :=  VidFiles;
      END; // .CASE ARC_VID
      ARC_SND: BEGIN
        ItemSize  :=  SIZEOF(TSndArcItem);
        ArcFiles  :=  SndFiles;
      END; // .CASE ARC_SND
    ELSE
      ItemSize  :=  0;
      {!} ASSERT(FALSE);
    END; // .CASE ArcType
    
    IF (WinWrappers.FileRead(hFile, NumItems, SIZEOF(NumItems))) AND (NumItems > 0) THEN BEGIN
      BufSize :=  NumItems * ItemSize;
      SetLength(BufStr, BufSize);
      {!} ASSERT(WinWrappers.FileRead(hFile, BufStr[1], BufSize));
      CurrItem  :=  POINTER(BufStr);
      
      FOR i:=0 TO NumItems - 1 DO BEGIN
        ItemName  :=  PCHAR(@CurrItem.Name);

        IF ArcFiles[ItemName] = NIL THEN BEGIN
          NEW(ItemInfo);
          ItemInfo.hFile   :=  hFile;
          ItemInfo.Offset  :=  CurrItem.Offset;
          
          IF ArcType = ARC_SND THEN BEGIN
            ItemInfo.Size :=  PSndArcItem(CurrItem).Size;
          END; // .IF
          
          ArcFiles[ItemName]  :=  ItemInfo; ItemInfo :=  NIL;
        END; // .IF
        
        CurrItem  :=  Utils.PtrOfs(CurrItem, ItemSize);
      END; // .FOR
    END; // .IF
  END; // .IF
END; // .PROCEDURE LoadArc

PROCEDURE LoadArcs (ArcType: TArcType);
VAR
{O} Locator:  Files.TFileLocator;
{O} FileInfo: Files.TFileItemInfo;
    ArcExt:   STRING;
    FileName: STRING;
  
BEGIN
  Locator   :=  Files.TFileLocator.Create;
  FileInfo  :=  NIL;
  // * * * * * //
  IF ArcType = ARC_VID THEN BEGIN
    ArcExt  :=  '.vid';
  END // .IF
  ELSE IF ArcType = ARC_SND THEN BEGIN
    ArcExt  :=  '.snd';
  END // .ELSEIF
  ELSE BEGIN
    ArcExt  :=  '';
    {!} ASSERT(FALSE);
  END; // .ELSE
  
  Locator.DirPath :=  'Data';
  Locator.InitSearch('*' + ArcExt);
  
  WHILE Locator.NotEnd DO BEGIN
    FileName  :=  SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(FileInfo)));
    
    IF
      (SysUtils.ExtractFileExt(FileName) = ArcExt)  AND
      NOT FileInfo.IsDir                            AND
      FileInfo.HasKnownSize                         AND
      (FileInfo.FileSize > SIZEOF(INTEGER))
    THEN BEGIN
      LoadArc('Data\' + FileName, ArcType);
    END; // .IF
    
    SysUtils.FreeAndNil(FileInfo);
  END; // .WHILE
  
  Locator.FinitSearch;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .FUNCTION Hook_LoadArcs

FUNCTION Hook_LoadVideoHeaders (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS  = 0;

BEGIN
  LoadArcs(ARC_VID);
  
  (* Load CD resources *)
  IF SysUtils.FileExists(CD_VIDEO_PATH) THEN BEGIN
    LoadArc(CD_VIDEO_PATH, ARC_VID);
  END // .IF
  ELSE IF LoadCDOpt AND GameCDFound THEN BEGIN
    LoadArc(GameCDPath + CD_VIDEO_PATH, ARC_VID);
  END; // .ELSEIF
  
  Context.EAX     :=  BYTE(TRUE);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  RESULT          :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_LoadVideoHeaders

FUNCTION Hook_OpenSmack (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS          = 1;
  ARG_BUFSIZE_MASK  = 1;
  
  SET_POSITION  = 0;

VAR
{U} ItemInfo: PItemInfo;
    
    FileName:     STRING;
    BufSize:      INTEGER;
    BufSizeMask:  INTEGER;
    
    hFile:  INTEGER;
    Res:    INTEGER;

BEGIN
  ItemInfo  :=  NIL;
  // * * * * * //
  FileName    :=  PCHAR(Context.ECX);
  FileName    :=  FileName + '.smk';
  BufSize     :=  Context.EDX;
  BufSizeMask :=  Core.APIArg(Context, ARG_BUFSIZE_MASK).v;
  BufSize     :=  BufSize OR BufSizeMask OR $1140;

  ItemInfo  :=  VidFiles[FileName];
  
  IF ItemInfo <> NIL THEN BEGIN
    hFile :=  ItemInfo.hFile;
    SysUtils.FileSeek(hFile, ItemInfo.Offset, SET_POSITION);
    
    ASM
      PUSH -1
      PUSH BufSize
      PUSH hFile
      MOV EAX, [Heroes.SMACK_OPEN]
      CALL EAX
      MOV Res, EAX
    END; // .ASM
    Context.EAX :=  Res;
  END // .IF
  ELSE BEGIN
    Context.EAX :=  0;
  END; // .ELSE
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  RESULT          :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_OpenSmack

FUNCTION Hook_OpenBik (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS  = 0;

  SET_POSITION  = 0;

VAR
{U} ItemInfo: PItemInfo;
    
    FileName:     STRING;
    BufSizeMask:  INTEGER;
    
    hFile:  INTEGER;
    Res:    INTEGER;

BEGIN
  ItemInfo  :=  NIL;
  // * * * * * //
  FileName    :=  PCHAR(Context.ECX);
  FileName    :=  FileName + '.bik';
  BufSizeMask :=  Context.EDX OR $8000000;

  ItemInfo  :=  VidFiles[FileName];
  
  IF ItemInfo <> NIL THEN BEGIN
    hFile :=  ItemInfo.hFile;
    SysUtils.FileSeek(hFile, ItemInfo.Offset, SET_POSITION);
    
    ASM
      PUSH BufSizeMask
      PUSH hFile
      MOV EAX, [Heroes.BINK_OPEN]
      CALL EAX
      MOV Res, EAX
    END; // .ASM
    Context.EAX :=  Res;
  END // .IF
  ELSE BEGIN
    Context.EAX :=  0;
  END; // .ELSE
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  RESULT          :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_OpenBik

FUNCTION Hook_LoadSndHeaders (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS  = 0;

BEGIN
  LoadArcs(ARC_SND);

  (* Load CD resources *)
  IF SysUtils.FileExists(CD_AUDIO_PATH) THEN BEGIN
    LoadArc(CD_AUDIO_PATH, ARC_SND);
  END // .IF
  ELSE IF LoadCDOpt AND GameCDFound THEN BEGIN
    LoadArc(GameCDPath + CD_AUDIO_PATH, ARC_SND);
  END; // .ELSEIF
  
  Context.EAX     :=  BYTE(TRUE);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  RESULT          :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_LoadSndHeaders

FUNCTION Hook_LoadSnd (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS          = 1;
  ARG_FILESIZE_PTR  = 1;

  SET_POSITION  = 0;

VAR
{U} ItemInfo: PItemInfo;

    BaseFileName: STRING;
    ResourceBuf:  PResourceBuf;
    FileSizePtr:  PINTEGER;
    
    RightMostDotPos:  INTEGER;

BEGIN
  ItemInfo  :=  NIL;
  // * * * * * //
  BaseFileName  :=  SysUtils.ExtractFileName(PCHAR(Context.ECX));
  
  IF StrLib.ReverseFindChar('.', BaseFileName, RightMostDotPos) THEN BEGIN
    BaseFileName  :=  System.Copy(BaseFileName, 1, RightMostDotPos - 1);
  END; // .IF
  
  ItemInfo  :=  SndFiles[BaseFileName];
  
  IF ItemInfo = NIL THEN BEGIN
    ItemInfo  :=  SndFiles[BaseFileName];
  END; // .IF
  
  IF (ItemInfo <> NIL) AND (ItemInfo.Size > 0) THEN BEGIN
    ResourceBuf :=  POINTER(Context.EDX);
    FileSizePtr :=  POINTER(Core.APIArg(Context, ARG_FILESIZE_PTR).v);
  
    IF ResourceBuf.IsLoaded THEN BEGIN
      Heroes.MFree(ResourceBuf.Addr);
    END; // .IF
    
    ResourceBuf.Addr  :=  Heroes.MAlloc(ItemInfo.Size);
    FileSizePtr^      :=  ItemInfo.Size;
  
    SysUtils.FileSeek(ItemInfo.hFile, ItemInfo.Offset, SET_POSITION);
    SysUtils.FileRead(ItemInfo.hFile, ResourceBuf.Addr^, ItemInfo.Size);

    Context.EAX :=  BYTE(TRUE);
  END // .IF
  ELSE BEGIN
    Context.EAX :=  BYTE(FALSE);
  END; // .ELSE
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  RESULT          :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_LoadSnd

PROCEDURE OnAfterWoG (Event: PEvent); STDCALL;
BEGIN
  (* Setup snd/vid hooks *)
  Core.Hook(@Hook_LoadVideoHeaders, Core.HOOKTYPE_BRIDGE, 6, Ptr($598510));
  Core.Hook(@Hook_OpenSmack, Core.HOOKTYPE_BRIDGE, 6, Ptr($598A90));
  Core.Hook(@Hook_OpenBik, Core.HOOKTYPE_BRIDGE, 6, Ptr($44D270));
  Core.Hook(@Hook_LoadSndHeaders, Core.HOOKTYPE_BRIDGE, 6, Ptr($5987A0));
  Core.Hook(@Hook_LoadSnd, Core.HOOKTYPE_BRIDGE, 5, Ptr($55C340));
  
  (* Disable CloseSndHandles function *)
  PBYTE($4F3DFD)^     :=  $90;
  PINTEGER($4F3DFE)^  :=  INTEGER($90909090);
  
  (* Disable SavePointersToSndHandles function *)
  Core.Hook(Core.Ret(0), Core.HOOKTYPE_JUMP, 5, Ptr($5594F0));
  
  (* Find game CD *)
  IF LoadCDOpt THEN BEGIN
    FindGameCD;
  END; // .IF
  
  (* Disable default CD scanning *)
  PINTEGER($50C409)^  :=  $0000B4E9;
  PWORD($50C40D)^     :=  $9000;
END; // .PROCEDURE OnAfterWoG

BEGIN
  SndFiles :=  AssocArrays.NewAssocArr
  (
    Crypto.AnsiCRC32,
    SysUtils.AnsiLowerCase,
    Utils.OWNS_ITEMS,
    NOT Utils.ITEMS_ARE_OBJECTS,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );
  
  VidFiles :=  AssocArrays.NewAssocArr
  (
    Crypto.AnsiCRC32,
    SysUtils.AnsiLowerCase,
    Utils.OWNS_ITEMS,
    NOT Utils.ITEMS_ARE_OBJECTS,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );

  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
END.
