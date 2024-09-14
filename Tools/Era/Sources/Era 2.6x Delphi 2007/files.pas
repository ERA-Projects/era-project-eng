unit Files;
{
DESCRIPTION:  Implementations of virtual device with sequential access
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Windows, SysUtils, Math, WinWrappers, Utils, Log, CFiles;

const
  (* IMPORT *)
  MODE_OFF        = CFiles.MODE_OFF;
  MODE_READ       = CFiles.MODE_READ;
  MODE_WRITE      = CFiles.MODE_WRITE;
  MODE_READWRITE  = CFiles.MODE_READWRITE;
  
  (* Scan function settings *)
  faNotDirectory  = SysUtils.faAnyFile and not SysUtils.faDirectory;
  ANY_EXT         = '';

type
  (* IMPORT *)
  TDeviceMode = CFiles.TDeviceMode;
  TItemInfo   = CFiles.TItemInfo;
  
  TFixedBuf = class (CFiles.TAbstractFile)
    (***) protected (***)
      {OUn} fBuf:     pointer;
            fOwnsMem: boolean;
    
    (***) public (***)
      destructor  Destroy; override;
      procedure Open ({n} Buf: pointer; BufSize: integer; DeviceMode: TDeviceMode);
      procedure Close;
      procedure CreateNew (BufSize: integer);
      function  ReadUpTo (Count: integer; {n} Buf: pointer; out BytesRead: integer): boolean; override;
      function  WriteUpTo (Count: integer; {n} Buf: pointer; out ByteWritten: integer): boolean; override;
      function  Seek (NewPos: integer): boolean; override;
      
      property  Buf:      pointer read fBuf;
      property  OwnsMem:  boolean read fOwnsMem;
  end; // .class TFixedBuf
  
  TFile = class (CFiles.TAbstractFile)
    (***) protected (***)
      fhFile:     integer;
      fFilePath:  string;
      
    (***) public (***)
      destructor  Destroy; override;
      function  Open (const FilePath: string; DeviceMode: TDeviceMode): boolean;
      procedure Close;
      function  CreateNew (const FilePath: string): boolean;
      function  ReadUpTo (Count: integer; {n} Buf: pointer; out BytesRead: integer): boolean; override;
      function  WriteUpTo (Count: integer; {n} Buf: pointer; out ByteWritten: integer): boolean; override;
      function  Seek (NewPos: integer): boolean; override;
      
      property  hFile:    integer read fhFile;
      property  FilePath: string read fFilePath;
  end; // .class TFile
  
  TFileItemInfo = class (CFiles.TItemInfo)
    Data: Windows.TWin32FindData;
  end; // .class TFileItemInfo
  
  TFileLocator  = class (CFiles.TAbstractLocator)
    (***) protected (***)
      fOpened:        boolean;
      fSearchHandle:  integer;
      fFindData:      Windows.TWin32FindData;
      fDirPath:       string;
      
    (***) public (***)
      destructor  Destroy; override;
    
      procedure FinitSearch; override;
      procedure InitSearch (const Mask: string); override;
      function  GetNextItem (out ItemInfo: TItemInfo): string; override;
      function  GetItemInfo (const ItemName: string; out ItemInfo: TItemInfo): boolean; override;

      property  DirPath:  string read fDirPath write fDirPath;
  end; // .class TFileLocator
  
  TScanCallback = function (var SearchRes: SysUtils.TSearchRec): boolean;


  (*  High level directory scanning
      Files are strictly matched against template with wildcards  *)
  
  PSearchRec = ^TSearchRec;
  TSearchRec = record
    Rec: SysUtils.TSearchRec;

    function IsFile: boolean;
    function IsDir: boolean;
  end;

  TSearchSubj = (ONLY_FILES, ONLY_DIRS, FILES_AND_DIRS);
  
  ILocator = interface
    procedure Locate (const MaskedPath: string; SearchSubj: TSearchSubj);
    function  FindNext: boolean;
    procedure FindClose;
    function  GetFoundName: string;
    function  GetFoundPath: string;
    function  GetFoundRec:  {U} PSearchRec;
    
    property FoundName: string read GetFoundName;
    property FoundPath: string read GetFoundPath;
    property FoundRec:  PSearchRec read GetFoundRec;
  end; // .interface ILocator


function  ReadFileContents (const FilePath: string; out FileContents: string): boolean;
function  WriteFileContents (const FileContents, FilePath: string): boolean;
function  AppendFileContents (const FileContents, FilePath: string): boolean;
function  DeleteDir (const DirPath: string): boolean;
function  GetFileSize (const FilePath: string; out Res: integer): boolean;
function  Scan
(
  const FileMask:         string;
        AdditionalAttrs:  integer;
  const FileLowCaseExt:   string;
        Callback:         TScanCallback
): boolean;

function  DirExists (const FilePath: string): boolean;
(* Safe replacement for SysUtils.ForceDirectories, not raising exceptions *)
function  ForcePath (const DirPath: string): boolean;
function  Locate (const MaskedPath: string; SearchSubj: TSearchSubj): ILocator;
  

(***) implementation (***)
uses StrLib;

const
  FILES_EXTRA_DEBUG = FALSE;


type
  TLocator  = class (TInterfacedObject, ILocator)
    protected
      fLastOperRes:   boolean;
      fSearchStarted: boolean;
      fDir:           string;
      fFileMask:      string;
      fSearchSubj:    TSearchSubj;
      fFoundRec:      SysUtils.TSearchRec;
      
      function  MatchResult: boolean;
    
    public
      constructor Create;
      destructor  Destroy; override;
    
      procedure Locate (const MaskedPath: string; SearchSubj: TSearchSubj);
      function  FindNext: boolean;
      procedure FindClose;
      function  GetFoundName: string;
      function  GetFoundPath: string;
      function  GetFoundRec:  {U} PSearchRec;
  end; // .class TLocator


destructor TFixedBuf.Destroy;
begin
  Self.Close;
end; // .destructor TFixedBuf.Destroy

procedure TFixedBuf.Open ({n} Buf: pointer; BufSize: integer; DeviceMode: TDeviceMode);
begin
  {!} Assert(Utils.IsValidBuf(Buf, BufSize));
  {!} Assert(DeviceMode <> MODE_OFF);
  Self.Close;
  Self.fMode          :=  DeviceMode;
  Self.fHasKnownSize  :=  true;
  Self.fSizeIsConst   :=  true;
  Self.fSize          :=  BufSize;
  Self.fPos           :=  0;
  Self.fEOF           :=  BufSize = 0;
  Self.fBuf           :=  Buf;
  Self.fOwnsMem       :=  FALSE;
end; // .procedure TFixedBuf.Open

procedure TFixedBuf.Close;
begin
  if (Self.fMode <> MODE_OFF) and Self.OwnsMem then begin
    FreeMem(Self.fBuf); Self.fBuf :=  nil;
  end; // .if
  Self.fMode  :=  MODE_OFF;
end; // .procedure TFixedBuf.Close

procedure TFixedBuf.CreateNew (BufSize: integer);
var
(* on *)  NewBuf: pointer;
  
begin
  {!} Assert(BufSize >= 0);
  NewBuf  :=  nil;
  // * * * * * //
  if BufSize > 0 then begin
    GetMem(NewBuf, BufSize);
  end; // .if
  Self.Open(NewBuf, BufSize, MODE_READWRITE); NewBuf  :=  nil;
  Self.fOwnsMem := true;
end; // .procedure TFixedBuf.CreateNew

function TFixedBuf.ReadUpTo (Count: integer; {n} Buf: pointer; out BytesRead: integer): boolean;
begin
  {!} Assert(Utils.IsValidBuf(Buf, Count));
  result  :=  ((Self.Mode = MODE_READ) or (Self.Mode = MODE_READWRITE)) and (not Self.EOF) and (Count > 0);
  if result then begin
    BytesRead :=  Math.Min(Count, Self.Size - Self.Pos);
    Utils.CopyMem(BytesRead, Utils.PtrOfs(Self.Buf, Self.Pos), Buf);
    Self.fPos :=  Self.Pos + BytesRead;
    Self.fEOF :=  Self.Pos = Self.Size;
  end; // .if
end; // .function TFixedBuf.ReadUpTo

function TFixedBuf.WriteUpTo (Count: integer; {n} Buf: pointer; out ByteWritten: integer): boolean;
begin
  {!} Assert(Utils.IsValidBuf(Buf, Count));
  result  :=  ((Self.Mode = MODE_WRITE) or (Self.Mode = MODE_READWRITE)) and (not Self.EOF);
  if result then begin
    ByteWritten :=  Math.Min(Count, Self.Size - Self.Pos);
    Utils.CopyMem(ByteWritten, Buf, Utils.PtrOfs(Self.Buf, Self.Pos));
    Self.fPos :=  Self.Pos + ByteWritten;
    Self.fEOF :=  Self.Pos = Self.Size;
  end; // .if
end; // .function TFixedBuf.WriteUpTo

function TFixedBuf.Seek (NewPos: integer): boolean;
begin
  {!} Assert(NewPos >= 0);
  result  :=  (Self.Mode <> MODE_OFF) and (NewPos <= Self.Size);
  if result then begin
    Self.fPos :=  NewPos;
    Self.fEOF :=  Self.Pos = Self.Size;
  end; // .if
end; // .function TFixedBuf.Seek

destructor TFile.Destroy;
begin
  Self.Close;
end; // .destructor TFile.Destroy

function TFile.Open (const FilePath: string; DeviceMode: TDeviceMode): boolean;
var
  OpeningMode:  integer;
  FileSizeL:    integer;
  FileSizeH:    integer;

begin
  {!} Assert(DeviceMode <> MODE_OFF);
  Self.Close;
  Self.fhFile :=  WinWrappers.INVALID_HANDLE;
  case DeviceMode of 
    MODE_READ:      OpeningMode :=  SysUtils.fmOpenRead or SysUtils.fmShareDenyWrite;
    MODE_WRITE:     OpeningMode :=  SysUtils.fmOpenWrite or SysUtils.fmShareExclusive;
    MODE_READWRITE: OpeningMode :=  SysUtils.fmOpenReadWrite or SysUtils.fmShareExclusive;
  else
    OpeningMode :=  0;
  end; // .SWITCH
  result  :=  WinWrappers.FileOpen(FilePath, OpeningMode, Self.fhFile);
  if not result then begin
    Log.Write('FileSystem', 'OpenFile', 'Cannot open file "' + FilePath + '"');
  end // .if
  else begin
    result  :=  WinWrappers.GetFileSize(Self.hFile, FileSizeL, FileSizeH);
    if not result then begin
      Log.Write('FileSystem', 'GetFileSize', 'Cannot get size of file "' + FilePath + '"');
    end; // .if
  end; // .else
  if result then begin
    result  :=  FileSizeH = 0;
    if not result then begin
      Log.Write
      (
        'FileSystem',
        'OpenFile',
        'Size of file "' + FilePath +'" exceeds 2 GB = ' + SysUtils.IntToStr(INT64(FileSizeH) * $FFFFFFFF + FileSizeL)
      );
    end // .if
    else begin
      Self.fMode          :=  DeviceMode;
      Self.fSize          :=  FileSizeL;
      Self.fPos           :=  0;
      Self.fEOF           :=  Self.Pos = Self.Size;
      Self.fFilePath      :=  FilePath;
      Self.fHasKnownSize  :=  true;
      Self.fSizeIsConst   :=  FALSE;
    end; // .else
  end; // .if
  // * * * * * //
  if (not result) and (Self.hFile <> WinWrappers.INVALID_HANDLE) then begin
    Windows.CloseHandle(Self.hFile);
  end; // .if
end; // .function TFile.Open

procedure TFile.Close;
begin
  if (Self.Mode <> MODE_OFF) and (not Windows.CloseHandle(Self.hFile)) then begin
    Log.Write('FileSystem', 'CloseFile', 'Cannot close file "' + Self.FilePath + '"');
  end; // .if;
  Self.fMode      :=  MODE_OFF;
  Self.fFilePath  :=  '';
end; // .procedure TFile.Close

function TFile.CreateNew (const FilePath: string): boolean;
begin
  Self.Close;
  result  :=  WinWrappers.FileCreate(FilePath, Self.fhFile);
  
  if not result then begin
    Log.Write('FileSystem', 'CreateFile', 'Cannot create file "' + Self.FilePath + '"');
  end // .if
  else begin
    Self.fMode          :=  MODE_READWRITE;
    Self.fSize          :=  0;
    Self.fPos           :=  0;
    Self.fEOF           :=  true;
    Self.fFilePath      :=  FilePath;
    Self.fHasKnownSize  :=  true;
    Self.fSizeIsConst   :=  FALSE;
  end; // .else
end; // .function TFile.CreateNew

function TFile.ReadUpTo (Count: integer; {n} Buf: pointer; out BytesRead: integer): boolean;
begin
  {!} Assert(Utils.IsValidBuf(Buf, Count));
  result  :=  ((Self.Mode = MODE_READ) or (Self.Mode = MODE_READWRITE)) and (not Self.EOF);
  if result then begin
    BytesRead :=  SysUtils.FileRead(Self.hFile, Buf^, Count);
    result    :=  BytesRead > 0;
    if not result then begin
      Log.Write('FileSystem', 'ReadFile', 'Cannot read file "' + Self.FilePath + '" at offset ' + SysUtils.IntToStr(Self.Pos));
    end; // .if
    Self.fPos :=  Self.Pos + BytesRead;
    Self.fEOF :=  Self.Pos = Self.Size;
  end; // .if
end; // .function TFile.ReadUpTo

function TFile.WriteUpTo (Count: integer; {n} Buf: pointer; out ByteWritten: integer): boolean;
begin
  {!} Assert(Utils.IsValidBuf(Buf, Count));
  result  :=  (Self.Mode = MODE_WRITE) or (Self.Mode = MODE_READWRITE);
  if result then begin
    ByteWritten :=  SysUtils.FileWrite(Self.hFile, Buf^, Count);
    result      :=  ByteWritten > 0;
    if not result then begin
      Log.Write('FileSystem', 'WriteFile', 'Cannot write file "' + Self.FilePath + '" at offset ' + SysUtils.IntToStr(Self.Pos));
    end; // .if
    Self.fPos   :=  Self.Pos + ByteWritten;
    Self.fSize  :=  Self.Size + ByteWritten;
    Self.fEOF   :=  Self.Pos = Self.Size;
  end; // .if
end; // .function TFile.WriteUpTo

function TFile.Seek (NewPos: integer): boolean;
var
  SeekRes:  integer;

begin
  {!} Assert(NewPos >= 0);
  result  :=  Self.Mode <> MODE_OFF;
  if result then begin
    SeekRes :=  SysUtils.FileSeek(Self.hFile, NewPos, 0);
    result  :=  SeekRes <> -1;
    if result then begin
      Self.fPos :=  SeekRes;
      result    :=  SeekRes = NewPos;
    end; // .if
    if not result then begin
      Log.Write('FileSystem', 'SeekFile', 'Cannot set file "' + Self.FilePath + '" pointer to ' + SysUtils.IntToStr(NewPos));
    end; // .if
    Self.fEOF :=  Self.Pos = Self.Size;
  end; // .if
end; // .function TFile.Seek

procedure TFileLocator.FinitSearch;
begin
  if Self.fOpened then begin
    Windows.FindClose(Self.fSearchHandle);
    Self.fOpened := FALSE;
  end; // .if
end; // .procedure TFileLocator.FinitSearch

procedure TFileLocator.InitSearch (const Mask: string);
begin
  Self.FinitSearch;
  Self.fSearchMask := Mask;
  Self.fOpened     := WinWrappers.FindFirstFile(Self.DirPath + '\' + Mask, Self.fSearchHandle, Self.fFindData);
  Self.fNotEnd     := Self.fOpened;
end; // .procedure TFileLocator.InitSearch

function TFileLocator.GetNextItem (out ItemInfo: TItemInfo): string;
var
(* O *) FileInfo: TFileItemInfo;

begin
  {!} Assert(Self.NotEnd);
  {!} Assert(ItemInfo = nil);
  FileInfo := TFileItemInfo.Create;
  // * * * * * //
  FileInfo.IsDir := (Self.fFindData.dwFileAttributes and Windows.FILE_ATTRIBUTE_DIRECTORY) <> 0;
  
  if not FileInfo.IsDir and (Self.fFindData.nFileSizeHigh = 0) and (Self.fFindData.nFileSizeLow < $7FFFFFFF) then begin
    FileInfo.HasKnownSize := true;
    FileInfo.FileSize     := Self.fFindData.nFileSizeLow;
  end;
  
  FileInfo.Data := Self.fFindData;
  ItemInfo      := FileInfo; FileInfo  :=  nil;
  result        := Self.fFindData.cFileName;
  Self.fNotEnd  := WinWrappers.FindNextFile(Self.fSearchHandle, Self.fFindData);
end; // .function TFileLocator.GetNextItem

destructor TFileLocator.Destroy;
begin
  Self.FinitSearch;
end; // .destructor Destroy

function TFileLocator.GetItemInfo (const ItemName: string; out ItemInfo: TItemInfo): boolean;
var
(* O *) Locator:  TFileLocator;
        ItemPath: string;

begin
  {!} Assert(ItemInfo = nil);
  Locator :=  TFileLocator.Create;
  // * * * * * //
  ItemPath  :=  Self.DirPath + '\' + ItemName;
  result    :=  SysUtils.FileExists(ItemPath);
  if result then begin
    Locator.InitSearch(ItemPath);
    if Locator.NotEnd then begin
      Locator.GetNextItem(ItemInfo);
    end; // .if
  end; // .if
  SysUtils.FreeAndNil(Locator);
end; // .function TFileLocator.GetItemInfo

function ReadFileContents (const FilePath: string; out FileContents: string): boolean;
var
{O} MyFile: TFile;

begin
  MyFile  :=  TFile.Create;
  // * * * * * //
  result  :=
    MyFile.Open(FilePath, MODE_READ)  and
    MyFile.ReadAllToStr(FileContents);
  // * * * * * //
  SysUtils.FreeAndNil(MyFile);
end; // .function ReadFileContents

function WriteFileContents (const FileContents, FilePath: string): boolean;
var
{O} MyFile: TFile;

begin
  MyFile  :=  TFile.Create;
  // * * * * * //
  result  :=
    MyFile.CreateNew(FilePath)  and
    MyFile.WriteStr(FileContents);
  // * * * * * //
  SysUtils.FreeAndNil(MyFile);
end; // .function WriteFileContents

function AppendFileContents (const FileContents, FilePath: string): boolean;
var
{O} MyFile: TFile;

begin
  MyFile := TFile.Create;
  // * * * * * //
  if SysUtils.FileExists(FilePath) then begin
    result := MyFile.Open(FilePath, MODE_WRITE) and MyFile.Seek(MyFile.Size);
  end else begin
    result := MyFile.CreateNew(FilePath);
  end; // .else

  result := result and MyFile.WriteStr(FileContents);
  // * * * * * //
  SysUtils.FreeAndNil(MyFile);
end; // .function AppendFileContents

function DeleteDir (const DirPath: string): boolean;
var
{O} Locator:  TFileLocator;
{O} FileInfo: TFileItemInfo;
    FileName: string;
    FilePath: string;

begin
  Locator   :=  TFileLocator.Create;
  FileInfo  :=  nil;
  // * * * * * //
  result          :=  true;
  Locator.DirPath :=  DirPath;
  Locator.InitSearch('*');
  while result and Locator.NotEnd do begin
    FileName  :=  Locator.GetNextItem(CFiles.TItemInfo(FileInfo));
    if (FileName <> '.') and (FileName <> '..') then begin
      FilePath  :=  DirPath + '\' + FileName;
      if (FileInfo.Data.dwFileAttributes and Windows.FILE_ATTRIBUTE_DIRECTORY) <> 0 then begin
        result  :=  DeleteDir(FilePath);
      end // .if
      else begin
        result  :=  SysUtils.DeleteFile(FilePath);
      end; // .else
    end; // .if
    SysUtils.FreeAndNil(FileInfo);
  end; // .while
  Locator.FinitSearch;
  result  :=  result and SysUtils.RemoveDir(DirPath);
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
end; // .function DeleteDir

function GetFileSize (const FilePath: string; out Res: integer): boolean;
var
{O} MyFile: TFile;

begin
  MyFile  :=  TFile.Create;
  // * * * * * //
  result  :=  MyFile.Open(FilePath, MODE_READ) and MyFile.HasKnownSize;
  if result then begin
    Res :=  MyFile.Size;
  end; // .if
  // * * * * * //
  SysUtils.FreeAndNil(MyFile);
end; // .function GetFileSize

function Scan
(
  const FileMask:         string;
        AdditionalAttrs:  integer;
  const FileLowCaseExt:   string;
        Callback:         TScanCallback
): boolean;

var
  SearchRec:  SysUtils.TSearchRec;

begin
  result  :=  true;

  if SysUtils.FindFirst(FileMask, AdditionalAttrs, SearchRec) = 0 then begin
    repeat
      if
        (FileLowCaseExt = ANY_EXT) or
        (SysUtils.ExtractFileExt(SysUtils.AnsiLowerCase(SearchRec.Name)) = FileLowCaseExt)
      then begin
        result  :=  Callback(SearchRec);
      end; // .if
    until SysUtils.FindNext(SearchRec) <> 0;
    
    SysUtils.FindClose(SearchRec);
  end; // .if
end; // .function Scan

function DirExists (const FilePath: string): boolean;
var
  Attrs:  integer;

begin
  Attrs   :=  Windows.GetFileAttributes(pchar(FilePath));
  result  :=  (Attrs <> - 1) and ((Attrs and Windows.FILE_ATTRIBUTE_DIRECTORY) <> 0);
end; // .function DirExists

function ForcePath (const DirPath: string): boolean;
var
  PathParts: StrLib.TArrayOfStr;
  TestPath:  string;
  i:         integer;

begin
  result := true;

  if (DirPath = '') or (DirPath = '\') or (DirPath = '\\') or (DirPath = '/') then begin
    // Root or current directory always exist, do nothing
  end else begin
    PathParts := StrLib.Explode(StrLib.TrimEx(StringReplace(DirPath, '/', '\', [rfReplaceAll]), ['\'], [StrLib.RIGHT_SIDE]), '\');

    if length(PathParts) > 0 then begin
      TestPath := '';
      i        := 0;

      while result and (i < length(PathParts)) do begin
        if PathParts[i] <> '' then begin
          if TestPath <> '' then begin
            TestPath := TestPath + '\';
          end;
          
          TestPath := TestPath + PathParts[i];

          if not DirExists(TestPath) then begin
            result := SysUtils.CreateDir(TestPath);
          end;
        end else if (TestPath = '') then begin
          TestPath := '\';
        end; // .elseif

        inc(i);
      end; // .while
    end; // .if
  end; // .else
end; // .function ForcePath

function TSearchRec.IsFile: boolean;
begin
  result := (Self.Rec.FindData.dwFileAttributes and Windows.FILE_ATTRIBUTE_DIRECTORY) = 0;
end;

function TSearchRec.IsDir: boolean;
begin
  result := (Self.Rec.FindData.dwFileAttributes and Windows.FILE_ATTRIBUTE_DIRECTORY) <> 0;
end;

constructor TLocator.Create;
begin
  inherited;
  Self.fLastOperRes :=  true;
end; // .constructor TLocator.Create

destructor TLocator.Destroy;
begin
  Self.FindClose;
  inherited;
end; // .destructor TLocator.Destroy

procedure TLocator.FindClose;
begin
  if Self.fSearchStarted then begin
    SysUtils.FindClose(Self.fFoundRec);
    Self.fSearchStarted :=  FALSE;
  end; // .if
end; // .procedure TLocator.FindClose

function TLocator.MatchResult: boolean;
  function CanonicMask (const Mask: string): string;
  var
    i: integer;
  
  begin
    result := Mask;
    i := Length(result);
    
    while ((i > 0) and (result[i] = '*')) do begin
      Dec(i);
    end; // .while
  
    if (i > 0) and (result[i] <> '.') then begin
      result := result + '.';
    end; // .if
  end; // .function CanonicMask
  
  function CanonicName (const Name: string): string;
  begin
    result := Name;
  
    if (result <> '') and (result[Length(result)] <> '.') then begin
      result := result + '.';
    end; // .if
  end; // .function CanonicName

begin
  {!} Assert(Self.fSearchStarted and Self.fLastOperRes);
  result  :=  FALSE;
  
  case Self.fSearchSubj of 
    ONLY_FILES:     result  :=  (Self.fFoundRec.Attr and SysUtils.faDirectory) = 0;
    ONLY_DIRS:      result  :=  (Self.fFoundRec.Attr and SysUtils.faDirectory) <> 0;
    FILES_AND_DIRS: result  :=  true;
  else
    {!} Assert(FALSE);
  end; // .SWITCH 
  
  result  :=  result and StrLib.Match(CanonicName(SysUtils.AnsiLowercase(Self.fFoundRec.Name)),
                                      CanonicMask(SysUtils.AnsiLowerCase(Self.fFileMask)));
  
  if FILES_EXTRA_DEBUG then begin
    Log.Write('Files', 'TLocator.MatchResult', 'Match "' + Self.fFoundRec.Name + '" to "' +
                                               Self.fFileMask + '" is ' + IntToStr(ORD(result)));
  end; // .if
end; // .function TLocator.MatchResult

function TLocator.FindNext: boolean;
begin
  {!} Assert(Self.fLastOperRes);
  result  :=  FALSE;
  
  if not Self.fSearchStarted then begin
    Self.fLastOperRes :=
      SysUtils.FindFirst(Self.fDir + '\*', SysUtils.faAnyFile, Self.fFoundRec) = 0;
    
    Self.fSearchStarted :=  Self.fLastOperRes;
    result              :=  Self.fSearchStarted and Self.MatchResult;
  end; // .if

  if not result and Self.fSearchStarted then begin
    while not result and (SysUtils.FindNext(Self.fFoundRec) = 0) do begin
      result  :=  Self.MatchResult;
    end; // .while
    
    Self.fLastOperRes :=  result;
  end; // .if
end; // .function TLocator.FindNext

procedure TLocator.Locate (const MaskedPath: string; SearchSubj: TSearchSubj);
begin
  Self.fDir         :=  SysUtils.ExtractFileDir(MaskedPath);
  Self.fFileMask    :=  SysUtils.ExtractFileName(MaskedPath);
  Self.fSearchSubj  :=  SearchSubj;
end;

function TLocator.GetFoundName: string;
begin
  {!} Assert(Self.fSearchStarted and Self.fLastOperRes);
  result  :=  Self.fFoundRec.Name;
end;

function TLocator.GetFoundPath: string;
begin
  {!} Assert(Self.fSearchStarted and Self.fLastOperRes);
  result  :=  Self.fDir + '\' + Self.fFoundRec.Name;
end;

function TLocator.GetFoundRec: {U} PSearchRec;
begin
  {!} Assert(Self.fSearchStarted and Self.fLastOperRes);
  result  :=  @Self.fFoundRec;
end;

function Locate (const MaskedPath: string; SearchSubj: TSearchSubj): ILocator;
var
{O} Locator: TLocator;

begin
  Locator := TLocator.Create;
  // * * * * * //
  Locator.Locate(MaskedPath, SearchSubj);
  result := Locator; Locator := nil;
end; // .function Locate

end.
