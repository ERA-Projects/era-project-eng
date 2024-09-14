unit SndVid;
{
DESCRIPTION:  Adds snd/vid archives autoloading support
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, SysUtils, Utils, WinWrappers, Files, StrLib, Crypto, AssocArrays,
  Core, GameExt, Heroes;

const  
  CD_GAME_FOLDER  = 'Heroes3';
  CD_VIDEO_PATH   = CD_GAME_FOLDER + '\Data\Heroes3.vid';
  CD_AUDIO_PATH   = CD_GAME_FOLDER + '\Data\Heroes3.snd';
  
  
type
  TArcType  = (ARC_SND, ARC_VID);

  PArcItem  = ^TArcItem;
  TArcItem  = packed record
    Name:   array[0..39] of char; // for ARC_SND name is separated from extension with #0
    Offset: integer;
  end; // .record TArcItem
  
  PVidArcItem = PArcItem;
  TVidArcItem = TArcItem;
  
  PSndArcItem = ^TSndArcItem;
  TSndArcItem = packed record
    Item: TArcItem;
    Size: integer;
  end; // .record TSndArcItem
  
  PItemInfo = ^TItemInfo;
  TItemInfo = record
    hFile:  integer;
    Offset: integer;
    Size:   integer;
  end; // .record TItemInfo
  
  PResourceBuf  = ^TResourceBuf;
  TResourceBuf  = packed record
    IsLoaded: boolean;
    _0:       array [0..2] of byte;
    Addr:     pointer;
  end; // .record TResourceBuf


var
  LoadCDOpt: boolean;
  
  GameCDFound:  boolean;
  GameCDPath:   string;
  
  
(***) implementation (***)


var
{O} SndFiles: {O} AssocArrays.TAssocArray {OF PItemInfo};
{O} VidFiles: {O} AssocArrays.TAssocArray {OF PItemInfo};


procedure FindGameCD;
const
  MAX_NUM_DRIVES  = 26;

var
  Drives:     integer;
  OldErrMode: integer;
  i:          integer;

begin
  OldErrMode  :=  Windows.SetErrorMode(Windows.SEM_FAILCRITICALERRORS);
  Drives      :=  Windows.GetLogicalDrives;
  GameCDPath  :=  'A:\';
  GameCDFound :=  false;
  {!} Assert(Drives <> 0);
  
  i :=  0;

  while (i < MAX_NUM_DRIVES) and not GameCDFound do begin
    if (Drives and (1 shl i)) <> 0 then begin
      if Windows.GetDriveType(pchar(GameCDPath)) = Windows.DRIVE_CDROM then begin
        GameCDFound :=  SysUtils.DirectoryExists(GameCDPath + CD_GAME_FOLDER);
      end; // .if
    end; // .if
    
    if not GameCDFound then begin
      GameCDPath[1] :=  CHR(ORD(GameCDPath[1]) + 1);
    end; // .if
    Inc(i);
  end; // .while
  
  Windows.SetErrorMode(OldErrMode);
end; // .procedure FindGameCD

procedure LoadArc (const ArcPath: string; ArcType: TArcType);
var
{U} ItemInfo: PItemInfo;
{U} ArcFiles: AssocArrays.TAssocArray {OF PItemInfo};
{U} CurrItem: PArcItem;
    hFile:    integer;
    
    NumItems: integer;
    ItemSize: integer;
    ItemName: string;
    
    BufSize:  integer;
    BufStr:   string;
    
    i:        integer;

begin
  ItemInfo  :=  nil;
  ArcFiles  :=  nil;
  CurrItem  :=  nil;
  // * * * * * // 
  if
    WinWrappers.FileOpen(ArcPath, SysUtils.fmOpenRead or SysUtils.fmShareDenyWrite, hFile)
  then begin
    case ArcType of
      ARC_VID: begin
        ItemSize  :=  sizeof(TVidArcItem);
        ArcFiles  :=  VidFiles;
      end; // .case ARC_VID
      ARC_SND: begin
        ItemSize  :=  sizeof(TSndArcItem);
        ArcFiles  :=  SndFiles;
      end; // .case ARC_SND
    else
      ItemSize  :=  0;
      {!} Assert(false);
    end; // .case ArcType
    
    if (WinWrappers.FileRead(hFile, NumItems, sizeof(NumItems))) and (NumItems > 0) then begin
      BufSize :=  NumItems * ItemSize;
      SetLength(BufStr, BufSize);
      {!} Assert(WinWrappers.FileRead(hFile, BufStr[1], BufSize));
      CurrItem  :=  pointer(BufStr);
      
      for i:=0 to NumItems - 1 do begin
        ItemName  :=  pchar(@CurrItem.Name);

        if ArcFiles[ItemName] = nil then begin
          New(ItemInfo);
          ItemInfo.hFile   :=  hFile;
          ItemInfo.Offset  :=  CurrItem.Offset;
          
          if ArcType = ARC_SND then begin
            ItemInfo.Size :=  PSndArcItem(CurrItem).Size;
          end; // .if
          
          ArcFiles[ItemName]  :=  ItemInfo; ItemInfo :=  nil;
        end; // .if
        
        CurrItem  :=  Utils.PtrOfs(CurrItem, ItemSize);
      end; // .for
    end; // .if
  end; // .if
end; // .procedure LoadArc

function IsOrigArc (const FileName: string; ArcType: TArcType): boolean;
begin
  if ArcType = ARC_SND then begin
    result  :=  (FileName = 'h3ab_ahd.snd') or (FileName = 'heroes3.snd');
  end // .if
  else begin
    result  :=
      (FileName = 'h3ab_ahd.vid') or
      (FileName = 'video.vid')    or
      (FileName = 'heroes3.vid');
  end; // .else
end; // .function IsOrigArc

procedure LoadArcs (ArcType: TArcType);
var
{O} Locator:  Files.TFileLocator;
{O} FileInfo: Files.TFileItemInfo;
    ArcExt:   string;
    FileName: string;
  
begin
  Locator   :=  Files.TFileLocator.Create;
  FileInfo  :=  nil;
  // * * * * * //
  if ArcType = ARC_VID then begin
    ArcExt  :=  '.vid';
  end // .if
  else if ArcType = ARC_SND then begin
    ArcExt  :=  '.snd';
  end // .ELSEIF
  else begin
    ArcExt  :=  '';
    {!} Assert(false);
  end; // .else
  
  Locator.DirPath :=  'Data';
  Locator.InitSearch('*' + ArcExt);
  
  while Locator.NotEnd do begin
    FileName  :=  SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(FileInfo)));
    
    if
      (SysUtils.ExtractFileExt(FileName) = ArcExt)  and
      not FileInfo.IsDir                            and
      FileInfo.HasKnownSize                         and
      (FileInfo.FileSize > sizeof(integer))
    then begin
      if not IsOrigArc(FileName, ArcType) then begin
        LoadArc('Data\' + FileName, ArcType);
      end; // .if
    end; // .if
    
    SysUtils.FreeAndNil(FileInfo);
  end; // .while
  
  Locator.FinitSearch;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
end; // .function Hook_LoadArcs

function Hook_LoadVideoHeaders (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  NUM_ARGS  = 0;

begin
  (* Load New resources *)
  LoadArcs(ARC_VID);
  
  (* Load CD resources *)
  if SysUtils.FileExists(CD_VIDEO_PATH) then begin
    LoadArc(CD_VIDEO_PATH, ARC_VID);
  end // .if
  else if LoadCDOpt and GameCDFound then begin
    LoadArc(GameCDPath + CD_VIDEO_PATH, ARC_VID);
  end; // .ELSEIF
  
  (* Load original rsources *)
  LoadArc('Data\video.vid', ARC_VID);
  LoadArc('Data\h3ab_ahd.vid', ARC_VID);
  
  Context.EAX     :=  byte(true);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_LoadVideoHeaders

function Hook_OpenSmack (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  NUM_ARGS          = 1;
  ARG_BUFSIZE_MASK  = 1;
  
  SET_POSITION  = 0;

var
{U} ItemInfo: PItemInfo;
    
    FileName:     string;
    BufSize:      integer;
    BufSizeMask:  integer;
    
    hFile:  integer;
    Res:    integer;

begin
  ItemInfo  :=  nil;
  // * * * * * //
  FileName    :=  pchar(Context.ECX);
  FileName    :=  FileName + '.smk';
  BufSize     :=  Context.EDX;
  BufSizeMask :=  Core.GetStdcallArg(Context, ARG_BUFSIZE_MASK)^;
  BufSize     :=  BufSize or BufSizeMask or $1140;

  ItemInfo  :=  VidFiles[FileName];
  
  if ItemInfo <> nil then begin
    hFile :=  ItemInfo.hFile;
    SysUtils.FileSeek(hFile, ItemInfo.Offset, SET_POSITION);
    
    asm
      PUSH -1
      PUSH BufSize
      PUSH hFile
      MOV EAX, [Heroes.SMACK_OPEN]
      CALL EAX
      MOV Res, EAX
    end; // .asm
    Context.EAX :=  Res;
  end // .if
  else begin
    Context.EAX :=  0;
  end; // .else
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_OpenSmack

function Hook_OpenBik (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  NUM_ARGS  = 0;

  SET_POSITION  = 0;

var
{U} ItemInfo: PItemInfo;
    
    FileName:     string;
    BufSizeMask:  integer;
    
    hFile:  integer;
    Res:    integer;

begin
  ItemInfo  :=  nil;
  // * * * * * //
  FileName    :=  pchar(Context.ECX);
  FileName    :=  FileName + '.bik';
  BufSizeMask :=  Context.EDX or $8000000;

  ItemInfo  :=  VidFiles[FileName];
  
  if ItemInfo <> nil then begin
    hFile :=  ItemInfo.hFile;
    SysUtils.FileSeek(hFile, ItemInfo.Offset, SET_POSITION);
    
    asm
      PUSH BufSizeMask
      PUSH hFile
      MOV EAX, [Heroes.BINK_OPEN]
      CALL EAX
      MOV Res, EAX
    end; // .asm
    Context.EAX :=  Res;
  end // .if
  else begin
    Context.EAX :=  0;
  end; // .else
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_OpenBik

function Hook_LoadSndHeaders (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  NUM_ARGS  = 0;

begin
  (* Load New resources *)
  LoadArcs(ARC_SND);

  (* Load CD resources *)
  if SysUtils.FileExists(CD_AUDIO_PATH) then begin
    LoadArc(CD_AUDIO_PATH, ARC_SND);
  end // .if
  else if LoadCDOpt and GameCDFound then begin
    LoadArc(GameCDPath + CD_AUDIO_PATH, ARC_SND);
  end; // .ELSEIF
  
  (* Load original rsources *)
  LoadArc('Data\heroes3.snd', ARC_SND);
  LoadArc('Data\h3ab_ahd.snd', ARC_SND);
  
  Context.EAX     :=  byte(true);
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_LoadSndHeaders

function Hook_LoadSnd (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  NUM_ARGS          = 1;
  ARG_FILESIZE_PTR  = 1;

  SET_POSITION  = 0;

var
{U} ItemInfo: PItemInfo;

    BaseFileName: string;
    ResourceBuf:  PResourceBuf;
    FileSizePtr:  PINTEGER;
    
    RightMostDotPos:  integer;

begin
  ItemInfo  :=  nil;
  // * * * * * //
  BaseFileName  :=  SysUtils.ExtractFileName(pchar(Context.ECX));
  
  if StrLib.ReverseFindChar('.', BaseFileName, RightMostDotPos) then begin
    BaseFileName  :=  System.Copy(BaseFileName, 1, RightMostDotPos - 1);
  end; // .if
  
  ItemInfo  :=  SndFiles[BaseFileName];
  
  if ItemInfo = nil then begin
    ItemInfo  :=  SndFiles[BaseFileName];
  end; // .if
  
  if (ItemInfo <> nil) and (ItemInfo.Size > 0) then begin
    ResourceBuf :=  pointer(Context.EDX);
    FileSizePtr :=  pointer(Core.GetStdcallArg(Context, ARG_FILESIZE_PTR)^);
  
    if ResourceBuf.IsLoaded then begin
      Heroes.MFree(ResourceBuf.Addr);
    end; // .if
    
    ResourceBuf.Addr  :=  Heroes.MAlloc(ItemInfo.Size);
    FileSizePtr^      :=  ItemInfo.Size;
  
    SysUtils.FileSeek(ItemInfo.hFile, ItemInfo.Offset, SET_POSITION);
    SysUtils.FileRead(ItemInfo.hFile, ResourceBuf.Addr^, ItemInfo.Size);

    Context.EAX :=  byte(true);
  end // .if
  else begin
    Context.EAX :=  byte(false);
  end; // .else
  
  Context.RetAddr :=  Core.Ret(NUM_ARGS);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_LoadSnd

procedure OnAfterWoG (Event: PEvent); stdcall;
begin
  (* Setup snd/vid hooks *)
  Core.Hook(@Hook_LoadVideoHeaders, Core.HOOKTYPE_BRIDGE, 6, Ptr($598510));
  Core.Hook(@Hook_OpenSmack, Core.HOOKTYPE_BRIDGE, 6, Ptr($598A90));
  Core.Hook(@Hook_OpenBik, Core.HOOKTYPE_BRIDGE, 6, Ptr($44D270));
  Core.Hook(@Hook_LoadSndHeaders, Core.HOOKTYPE_BRIDGE, 6, Ptr($5987A0));
  Core.Hook(@Hook_LoadSnd, Core.HOOKTYPE_BRIDGE, 5, Ptr($55C340));
  
  (* Disable CloseSndHandles function *)
  PBYTE($4F3DFD)^     :=  $90;
  PINTEGER($4F3DFE)^  :=  integer($90909090);
  
  (* Disable SavePointersToSndHandles function *)
  Core.Hook(Core.Ret(0), Core.HOOKTYPE_JUMP, 5, Ptr($5594F0));
  
  (* Find game CD *)
  if LoadCDOpt then begin
    FindGameCD;
  end; // .if
  
  (* Disable default CD scanning *)
  PINTEGER($50C409)^  :=  $0000B4E9;
  PWORD($50C40D)^     :=  $9000;
end; // .procedure OnAfterWoG

begin
  SndFiles :=  AssocArrays.NewAssocArr
  (
    Crypto.AnsiCRC32,
    SysUtils.AnsiLowerCase,
    Utils.OWNS_ITEMS,
    not Utils.ITEMS_ARE_OBJECTS,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );
  
  VidFiles :=  AssocArrays.NewAssocArr
  (
    Crypto.AnsiCRC32,
    SysUtils.AnsiLowerCase,
    Utils.OWNS_ITEMS,
    not Utils.ITEMS_ARE_OBJECTS,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );

  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
end.
