unit FolderBrowser;

interface
uses Windows, SysUtils, ShlObj;

function GetFolderDialog(Handle: integer; Caption: string; var strFolder: string): boolean;

implementation

function BrowseCallbackProc(hwnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM): integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
  BrowseCallbackProc:= 0;
end;

function GetFolderDialog(Handle: integer; Caption: string; var strFolder: string): boolean;
const
  BIF_STATUSTEXT           = $0004;
  BIF_EDITBOX              = $0010;
  BIF_NEWDIALOGSTYLE       = $0040;
  BIF_RETURNONLYFSDIRS     = $0080;
  BIF_SHAREABLE            = $0100;
  BIF_NONEWFOLDERBUTTON    = $0200;
  BIF_USENEWUI             = BIF_EDITBOX or BIF_NEWDIALOGSTYLE;

var
  BrowseInfo: TBrowseInfo;
  ItemIDList: PItemIDList;
  JtemIDList: PItemIDList;
  Path: PAnsiChar;
begin
  result:= False;
  Path:= StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(Handle, CSIDL_DRIVES, JtemIDList);
  with BrowseInfo do
  begin
    hwndOwner:= GetActiveWindow;
    pidlRoot:= JtemIDList;
    SHGetSpecialFolderLocation(hwndOwner, CSIDL_DRIVES, JtemIDList);
    pszDisplayName:= StrAlloc(MAX_PATH);
    lpszTitle:= pchar(Caption);
    lpfn:= @BrowseCallbackProc;
    lParam:= LongInt(pchar(strFolder));
    ulflags :=  
      BIF_STATUSTEXT or BIF_NEWDIALOGSTYLE or BIF_RETURNONLYFSDIRS or
      BIF_SHAREABLE or BIF_NONEWFOLDERBUTTON;
  end;

  ItemIDList:= SHBrowseForFolder(BrowseInfo);

  if (ItemIDList <> nil) then
    if SHGetPathFromIDList(ItemIDList, Path) then
    begin
      strFolder:= Path;
      result:= True;
    end;
end;

end.
