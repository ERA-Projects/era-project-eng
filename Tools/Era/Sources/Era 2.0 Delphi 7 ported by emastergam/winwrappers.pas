UNIT WinWrappers;
{
DESCRIPTION:  Correct wrappers for many Windows/SysUtils/... functions
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Windows, SysUtils;

CONST
  INVALID_HANDLE  = -1;


FUNCTION  FileCreate (CONST FilePath: STRING; (* i *) OUT hFile: INTEGER): BOOLEAN;
FUNCTION  FileOpen (CONST FilePath: STRING; OpenMode: INTEGER; OUT hFile: INTEGER): BOOLEAN;
FUNCTION  GetFileSize (hFile: INTEGER; OUT FileSizeL, FileSizeH: INTEGER): BOOLEAN;
FUNCTION  FileRead (hFile: INTEGER; VAR Buffer; StrictCount: INTEGER): BOOLEAN;
FUNCTION  GetModuleHandle (CONST ModuleName: STRING; OUT hModule: INTEGER): BOOLEAN;
FUNCTION  FindResource (hModule: INTEGER; CONST ResName: STRING; ResType: PCHAR; OUT hResource: INTEGER): BOOLEAN;
FUNCTION  LoadResource (hModule, hResource: INTEGER; OUT hMem: INTEGER): BOOLEAN;
FUNCTION  LockResource (hMem: INTEGER; OUT ResData: POINTER): BOOLEAN;
FUNCTION  SizeOfResource (hResource, hInstance: INTEGER; OUT ResSize: INTEGER): BOOLEAN;
FUNCTION  FindFirstFile (CONST Path: STRING; OUT hSearch: INTEGER; OUT FindData: Windows.TWin32FindData): BOOLEAN;
FUNCTION  FindNextFile (hSearch: INTEGER; VAR FindData: Windows.TWin32FindData): BOOLEAN;


(***) IMPLEMENTATION (***)


FUNCTION FileCreate (CONST FilePath: STRING; (* i *) OUT hFile: INTEGER): BOOLEAN;
BEGIN
  hFile   :=  SysUtils.FileCreate(FilePath);
  RESULT  :=  hFile <> INVALID_HANDLE;
END; // .FUNCTION FileCreate

FUNCTION FileOpen (CONST FilePath: STRING; OpenMode: INTEGER; (* i *) OUT hFile: INTEGER): BOOLEAN;
BEGIN
  hFile   :=  SysUtils.FileOpen(FilePath, OpenMode);
  RESULT  :=  hFile <> INVALID_HANDLE;
END; // .FUNCTION FileOpen

FUNCTION GetFileSize (hFile: INTEGER; OUT FileSizeL, FileSizeH: INTEGER): BOOLEAN;
BEGIN
  FileSizeL :=  Windows.GetFileSize(hFile, @FileSizeH);
  RESULT    :=  FileSizeL <> -1;
END; // .FUNCTION GetFileSize

FUNCTION FileRead (hFile: INTEGER; VAR Buffer; StrictCount: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  SysUtils.FileRead(hFile, Buffer, StrictCount) = StrictCount;
END; // .FUNCTION FileRead

FUNCTION GetModuleHandle (CONST ModuleName: STRING; OUT hModule: INTEGER): BOOLEAN;
BEGIN
  hModule :=  Windows.GetModuleHandle(PCHAR(ModuleName));
  RESULT  :=  hModule <> 0;
END; // .FUNCTION GetModuleHandle

FUNCTION FindResource (hModule: INTEGER; CONST ResName: STRING; ResType: PCHAR; OUT hResource: INTEGER): BOOLEAN;
BEGIN
  hResource :=  Windows.FindResource(hModule, PCHAR(ResName), ResType);
  RESULT    :=  hResource <> 0;
END; // .FUNCTION FindResource

FUNCTION LoadResource (hModule, hResource: INTEGER; OUT hMem: INTEGER): BOOLEAN;
BEGIN
  hMem    :=  Windows.LoadResource(hModule, hResource);
  RESULT  :=  hMem <> 0;
END; // .FUNCTION LoadResource

FUNCTION LockResource (hMem: INTEGER; OUT ResData: POINTER): BOOLEAN;
BEGIN
  {!} ASSERT(ResData = NIL);
  ResData :=  Windows.LockResource(hMem);
  RESULT  :=  ResData <> NIL;
END; // .FUNCTION LockResource

FUNCTION SizeOfResource (hResource, hInstance: INTEGER; OUT ResSize: INTEGER): BOOLEAN;
BEGIN
  ResSize :=  Windows.SizeOfResource(hResource, hInstance);
  RESULT  :=  ResSize <> 0;
END; // .FUNCTION SizeOfResource

FUNCTION FindFirstFile (CONST Path: STRING; OUT hSearch: INTEGER; OUT FindData: Windows.TWin32FindData): BOOLEAN;
BEGIN
  hSearch :=  Windows.FindFirstFile(PCHAR(Path), FindData);
  RESULT  :=  hSearch <> INVALID_HANDLE;
END; // .FUNCTION FindFirstFile

FUNCTION FindNextFile (hSearch: INTEGER; VAR FindData: Windows.TWin32FindData): BOOLEAN;
BEGIN
  RESULT  :=  Windows.FindNextFile(hSearch, FindData);
END; // .FUNCTION FindNextFile

END.
