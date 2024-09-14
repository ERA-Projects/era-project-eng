unit WinUtils;

interface
uses
  Windows;

const
  OWNS_BUF    = true;
  HIDE_CURSOR = true;

type
  PBgraPix = ^TBgraPix;
  TBgraPix = packed record
    case boolean of
      false: (Value: integer);
      true:
      (
        Blue:  byte;
        Green: byte;
        Red:   byte;
        Alpha: byte;
      );
  end; // .record TBgraPix
  
  PBgraBuf = ^TBgraBuf;
  TBgraBuf = array [0..MAXLONGINT div sizeof(TBgraPix) - 1] of TBgraPix;

  TRawImage = class
   protected
         fWidth:   integer;
         fHeight:  integer;
    {?n} fBuf:     PBgraBuf;
         fOwnsBuf: boolean;

   public
    constructor Create({?} aBuf: PBgraBuf; aOwnsBuf: boolean; aWidth, aHeight: integer);
    destructor  Destroy; override;

    property Buf:    {?} PBgraBuf read fBuf;
    property Width:  integer read fWidth;
    property Height: integer read fHeight;
  end; // .class TRawImage

function TakeScreenshot (hWnd: THandle; HideCursor: boolean; out Res: TRawImage): boolean;


implementation
uses Utils;

constructor TRawImage.Create ({?} aBuf: PBgraBuf; aOwnsBuf: boolean; aWidth, aHeight: integer);
begin
  {!} Assert(aWidth >= 0);
  {!} Assert(aHeight >= 0);
  {!} Assert(Utils.IsValidBuf(aBuf, aWidth and aHeight));
  fBuf     := aBuf;
  fOwnsBuf := aOwnsBuf;
  fWidth   := aWidth;
  fHeight  := aHeight;
end; // .constructor TRawImage.Create

destructor TRawImage.Destroy;
begin
  if fOwnsBuf and (fBuf <> nil) then begin
    FreeMem(fBuf); fBuf := nil;
  end; // .if
end; // .destructor TRawImage.Destroy

function TakeScreenshot (hWnd: THandle; HideCursor: boolean; out Res: TRawImage): boolean;
const
  BITS_PER_PIXEL  = 32;
  BYTES_PER_PIXEL = BITS_PER_PIXEL div 8;

var
{U} Buf:                 PBgraBuf;
    BufSize:             integer;
    WindowDeviceContext: HDC;
    ImageDeviceContext:  HDC;
    WindowInfo:          TWindowInfo;
    ScreenWidth:         integer;
    ScreenHeight:        integer;
    VisibleRect:         TRect;
    VisibleRectWidth:    integer;
    VisibleRectHeight:   integer;
    ImageHandle:         HBITMAP;
    BitmapInfo:          TBitmapInfo;
    OldImage:            HGDIOBJ;

  function IsWndVisible: boolean;
  begin
    result := (WindowInfo.rcWindow.Right  >= 0) and (WindowInfo.rcWindow.Left < ScreenWidth) and
              (WindowInfo.rcWindow.Bottom >= 0) and (WindowInfo.rcWindow.Top  < ScreenHeight)
  end; // .function IsWndVisible

  procedure GetVisibleRect;
  begin
    if WindowInfo.rcWindow.Left < 0 then begin
      VisibleRect.Left := Abs(WindowInfo.rcWindow.Left);
    end else begin
      VisibleRect.Left := 0;
    end; // .else

    VisibleRect.Right := WindowInfo.rcWindow.Right - WindowInfo.rcWindow.Left;

    if WindowInfo.rcWindow.Right >= ScreenWidth then begin
      VisibleRect.Right := VisibleRect.Right + ScreenWidth - 1 - WindowInfo.rcWindow.Right;
    end; // .if

    if WindowInfo.rcWindow.Top < 0 then begin
      VisibleRect.Top := Abs(WindowInfo.rcWindow.Top);
    end else begin
      VisibleRect.Top := 0;
    end; // .else

    VisibleRect.Bottom := WindowInfo.rcWindow.Bottom - WindowInfo.rcWindow.Top;

    if WindowInfo.rcWindow.Bottom >= ScreenHeight then begin
      VisibleRect.Bottom := VisibleRect.Bottom + ScreenHeight - 1 - WindowInfo.rcWindow.Bottom;
    end; // .if
  end; // .procedure GetVisibleRect

  procedure DrawCursor;
  var
    hCursor:    HICON;
    CursorInfo: TCursorInfo;
    IconInfo:   TIconInfo;

  begin
    if not HideCursor then begin
      CursorInfo.cbSize := sizeof(CursorInfo);
      GetCursorInfo(CursorInfo);

      if CursorInfo.flags = CURSOR_SHOWING then begin
        hCursor := CopyIcon(CursorInfo.hCursor);

        if hCursor <> 0 then begin
          GetIconInfo(hCursor, IconInfo);
          DrawIcon(ImageDeviceContext,
                   CursorInfo.ptScreenPos.x - WindowInfo.rcWindow.Left - VisibleRect.Left
                     - integer(IconInfo.xHotspot),
                   CursorInfo.ptScreenPos.y - WindowInfo.rcWindow.Top - VisibleRect.Top
                     - integer(IconInfo.yHotspot),
                   CursorInfo.hCursor);
          DestroyIcon(hCursor);
        end; // .if
      end; // .if
    end; // .if
  end; // .procedure DrawCursor

begin
  {!} Assert(Res = nil);
  Buf := nil;
  // * * * * * //
  WindowDeviceContext := GetWindowDC(hWnd);
  result              := (WindowDeviceContext <> 0) and GetWindowInfo(hWnd, WindowInfo);

  if result then begin
    ScreenWidth  := GetDeviceCaps(WindowDeviceContext, HORZRES);
    ScreenHeight := GetDeviceCaps(WindowDeviceContext, VERTRES);
    result       := IsWndVisible;

    if result then begin
      GetVisibleRect;
      VisibleRectWidth  := VisibleRect.Right  - VisibleRect.Left + 1;
      VisibleRectHeight := VisibleRect.Bottom - VisibleRect.Top  + 1;
      BufSize           := VisibleRectWidth * VisibleRectHeight * BYTES_PER_PIXEL;
      GetMem(Buf, BufSize);
      Res := TRawImage.Create(Buf, OWNS_BUF, VisibleRectWidth, VisibleRectHeight);

      BitmapInfo.bmiHeader.biSize         := sizeof(BITMAPINFOHEADER);
      BitmapInfo.bmiHeader.biWidth        := VisibleRectWidth;
      BitmapInfo.bmiHeader.biHeight       := -VisibleRectHeight; // Top to bottom line scan
      BitmapInfo.bmiHeader.biPlanes       := 1;
      BitmapInfo.bmiHeader.biBitCount     := BITS_PER_PIXEL;
      BitmapInfo.bmiHeader.biCompression  := BI_RGB;
      BitmapInfo.bmiHeader.biSizeImage    := BufSize;
      BitmapInfo.bmiHeader.biClrUsed      := 0;
      BitmapInfo.bmiHeader.biClrImportant := 0;

      ImageDeviceContext := CreateCompatibleDC(WindowDeviceContext);
      ImageHandle        := CreateCompatibleBitmap(WindowDeviceContext, VisibleRectWidth,
                                                   VisibleRectHeight);
      
      OldImage := SelectObject(ImageDeviceContext, ImageHandle);
      BitBlt(ImageDeviceContext, 0, 0, VisibleRectWidth, VisibleRectHeight, WindowDeviceContext,
             VisibleRect.Left, VisibleRect.Top, SRCCOPY);
      ReleaseDC(hWnd, WindowDeviceContext); WindowDeviceContext := 0;
      DrawCursor;

      SelectObject(ImageDeviceContext, OldImage);
      GetDIBits(ImageDeviceContext, ImageHandle, 0, VisibleRectHeight, Buf, BitmapInfo,
                DIB_RGB_COLORS);

      DeleteObject(ImageHandle);
      DeleteDC(ImageDeviceContext);
    end; // .if
  end; // .if
  // * * * * * //
  if WindowDeviceContext <> 0 then begin
    ReleaseDC(hWnd, WindowDeviceContext);
  end; // .if
end; // .function TakeScreenshot

end.