UNIT ConsoleAPI;
{!INFO
NAME = 'Console API'
VERSION = '1.0'
AUTHOR = 'Berserker'
}

INTERFACE
USES Windows, SysUtils;

TYPE
  PWin32Cell = ^TWin32Cell;
  TWin32Cell = packed record
    Ch:     WORD;
    Attr:   WORD;
  end;

  TMenu = RECORD
    Count: INTEGER;
    Start: PAnsiString;
    Interval: INTEGER;
  END; // .record TMenu
  
  PMenu = ^TMenu;

  TConsoleBuffer = RECORD
    Width, Height: INTEGER;
  END; // .record TConsoleBuffer

  TCodePage = (cp1251, cp866);

  TConsole = CLASS
    {*} PROTECTED {*}
    fWidth: INTEGER;
    fHeight: INTEGER;
    fBufWidth: INTEGER;
    fBufHeight: INTEGER;
    fTitle: STRING;
    fColor: BYTE;
    fBack: BYTE;
    TIR: TInputRecord;
    {*} PUBLIC {*}
    { FIELDS }
    hIn, hOut: INTEGER;
    hWnd: INTEGER;
    CodePage: TCodePage;
    { PROCEDURES }
    PROCEDURE SetWindowSize(NewWidth, NewHeight: INTEGER);
    PROCEDURE SetWidth(NewWidth: INTEGER);
    PROCEDURE SetHeight(NewHeight: INTEGER);
    PROCEDURE SetBufferSize(NewWidth, NewHeight: INTEGER);
    PROCEDURE SetBufferWidth(NewWidth: INTEGER);
    PROCEDURE SetBufferHeight(NewHeight: INTEGER);
    FUNCTION  GetTitle: STRING;
    PROCEDURE SetTitle(NewTitle: STRING);
    PROCEDURE SetColors(NewColor, NewBack: BYTE);
    PROCEDURE SetColor(NewColor: BYTE);
    PROCEDURE SetBack(NewBack: BYTE);
    PROCEDURE Clear;
    PROCEDURE GotoXY(x,y: INTEGER);
    PROCEDURE GotoX(x: INTEGER);
    PROCEDURE GotoY(y: INTEGER);
    FUNCTION  WhereX: INTEGER;
    FUNCTION  WhereY: INTEGER;
    PROCEDURE SetWindowPos(x,y: INTEGER);
    PROCEDURE MoveWindow(dx, dy: INTEGER);
    PROCEDURE Center;
    PROCEDURE WriteC(Attr: BYTE; Txt: STRING);
    PROCEDURE Print(Txt: STRING);
    PROCEDURE SetCodePage(NewCodePage: INTEGER);
    FUNCTION ReadKey: CHAR;
    FUNCTION ReadCode: CHAR;
    FUNCTION Read: STRING;
    PROCEDURE HideArea(x1, y1, x2, y2: INTEGER; col, back: BYTE);
    FUNCTION Menu(TitleCol, TitleBack, ItemCol, ItemBack, ChosenCol, ChosenBack,
                          FooterCol, FooterBack: BYTE;
                          CONST Title: STRING; CONST Footer: STRING; Items: PMenu): INTEGER;
    CONSTRUCTOR Create(Title: STRING; WinWidth, WinHeight, BufWidth, BufHeight: INTEGER);
    { PROPERTIES }
    PROPERTY Width: INTEGER READ fWidth WRITE SetWidth;
    PROPERTY Height: INTEGER READ fHeight WRITE SetHeight;
    PROPERTY BufWidth: INTEGER READ fBufWidth WRITE SetBufferWidth;
    PROPERTY BufHeight: INTEGER READ fBufHeight WRITE SetBufferHeight;
    PROPERTY Title: STRING READ GetTitle WRITE SetTitle;
    PROPERTY Color: BYTE READ fColor WRITE SetColor;
    PROPERTY Back: BYTE READ fBack WRITE SetBack;
    PROPERTY CurX: INTEGER READ WhereX WRITE GotoX;
    PROPERTY CurY: INTEGER READ WhereY WRITE GotoY;
  END; // .class TConsole

IMPLEMENTATION

FUNCTION PackColors(col, back: BYTE): BYTE;  //INLINE;
BEGIN
  Result:=(back SHL 4) OR col;
END; // .function PackColors

PROCEDURE TConsole.SetWindowSize(NewWidth, NewHeight: INTEGER);
VAR
  sr: TSmallRect;

BEGIN
  fWidth:=NewWidth;
  fHeight:=NewHeight;
  sr.Left:=0;
  sr.Top:=0;
  sr.Right:=NewWidth-1;
  sr.Bottom:=NewHeight-1;
  SetConsoleWindowInfo(hOut, TRUE, sr);
END; // .procedure TConsole.SetWindowSize

PROCEDURE TConsole.SetWidth(NewWidth: INTEGER);
BEGIN
  fWidth:=NewWidth;
  SetWindowSize(NewWidth, Height);
END; // .procedure TConsole.SetWidth

PROCEDURE TConsole.SetHeight(NewHeight: INTEGER);
BEGIN
  fHeight:=NewHeight;
  SetWindowSize(Width, NewHeight);
END; // .procedure TConsole.SetHeight

PROCEDURE TConsole.SetBufferSize(NewWidth, NewHeight: INTEGER);
VAR
  tc: TCoord;

BEGIN
  fBufWidth:=NewWidth;
  fBufHeight:=NewHeight;
  tc.x:=NewWidth;
  tc.y:=NewHeight;
  SetConsoleScreenBufferSize(hOut, tc);
END; // .procedure TConsole.SetBufferSize

PROCEDURE TConsole.SetBufferWidth(NewWidth: INTEGER);
BEGIN
  fBufWidth:=NewWidth;
  SetBufferSize(NewWidth, BufHeight);
END; // .procedure TConsole.SetBufferWidth

PROCEDURE TConsole.SetBufferHeight(NewHeight: INTEGER);
BEGIN
  fBufHeight:=NewHeight;
  SetBufferSize(BufWidth, NewHeight);
END; // .procedure TConsole.SetBufferHeight

FUNCTION TConsole.GetTitle: STRING;
VAR
  NewTitle: STRING;
  C: CHAR;

BEGIN
  NewTitle:=fTitle;
  IF CodePage=cp1251 THEN BEGIN
    C:=NewTitle[1];
    NewTitle[1]:=C;
    OEMToCharBuff(@NewTitle[1], @NewTitle[1], Length(NewTitle));
  END; // .if
  RESULT:=NewTitle;
END; // .procedure TConsole.GetTitle

PROCEDURE TConsole.SetTitle(NewTitle: STRING);
BEGIN
  fTitle:=NewTitle;
  IF CodePage=cp1251 THEN CharToOEMBuff(@NewTitle[1], @NewTitle[1], Length(NewTitle));
  Windows.SetConsoleTitle(@fTitle[1]);
END; // .procedure TConsole.SetTitle

PROCEDURE TConsole.SetColors(NewColor, NewBack: BYTE);
BEGIN
  fColor:=NewColor;
  fBack:=NewBack;
  SetConsoleTextAttribute(hOut, PackColors(NewColor, NewBack));
END; // .procedure TConsole.SetColors

PROCEDURE TConsole.SetColor(NewColor: BYTE);
BEGIN
  fColor:=NewColor;
  SetColors(NewColor, Back);
END; // .procedure TConsole.SetColor

PROCEDURE TConsole.SetBack(NewBack: BYTE);
BEGIN
  fBack:=NewBack;
  SetColors(Color, NewBack);
END; // .procedure TConsole.SetBack

PROCEDURE TConsole.Clear;
VAR
  sr: TSmallRect;
  c: TWin32Cell;
  cr: TCoord;

BEGIN
  sr.Left:=0;
  sr.Top:=0;
  sr.Right:=BufWidth-1;
  sr.Bottom:=BufHeight-1;
  c.Ch:=32;
  c.Attr:=PackColors(Color, Back);
  cr.x:=0;
  cr.y:=BufHeight;
  ScrollConsoleScreenBuffer(hOut, sr, @sr, cr, TCharInfo(c));
  GotoXY(0,0);
END; // .procedure TConsole.Clear

PROCEDURE TConsole.GotoXY(x, y: INTEGER);
VAR
  pos: TCoord;

BEGIN
  pos.x:=x;
  pos.y:=y;
  SetConsoleCursorPosition(hOut, pos);
END; // .procedure TConsole.GotoXY

PROCEDURE TConsole.GotoX(x: INTEGER);
BEGIN
  GotoXY(x, CurY);
END; // .procedure TConsole.GotoX

PROCEDURE TConsole.GotoY(y: INTEGER);
BEGIN
  GotoXY(CurX, y);
END; // .procedure TConsole.GotoY

FUNCTION TConsole.WhereX: INTEGER;
VAR
  info: TConsoleScreenBufferInfo;

BEGIN
  GetConsoleScreenBufferInfo(hOut, info);
  Result:=info.dwCursorPosition.x;
END; // .function TConsole.WhereX

FUNCTION TConsole.WhereY: INTEGER;
VAR
  info: TConsoleScreenBufferInfo;

BEGIN
  GetConsoleScreenBufferInfo(hOut, info);
  Result:=info.dwCursorPosition.y;
END; // .function TConsole.WhereY

FUNCTION GetConsoleWindow: INTEGER; EXTERNAL 'kernel32.dll' NAME 'GetConsoleWindow';

PROCEDURE TConsole.SetWindowPos(x, y: INTEGER);
VAR
  r: TRect;

BEGIN
  GetWindowRect(hWnd, r);
  Windows.MoveWindow(hWnd, x, y, r.Right-r.Left+1, r.Bottom-r.Top+1, TRUE);
END; // .procedure TConsole.SetWindowPos

PROCEDURE TConsole.MoveWindow(dx, dy: INTEGER);
VAR
  r: TRect;

BEGIN
  GetWindowRect(hWnd, r);
  Windows.MoveWindow(hWnd, r.Left+dx, r.Top+dy, r.Right-r.Left+1, r.Bottom-r.Top+1, TRUE);
END; // .procedure TConsole.MoveWindow

PROCEDURE TConsole.Center;
VAR
  r: TRect;
  w, h, x, y: INTEGER;

BEGIN
  GetWindowRect(hWnd, r);
  w:=r.Right-r.Left+1;
  h:=r.Bottom-r.Top+1;
  GetWindowRect(GetDesktopWindow, r);
  x:=(r.Right-r.Left-w) div 2;
  y:=(r.Bottom-r.Top-h) div 2;
  IF y<0 THEN y:=0;
  IF (x>0) THEN Windows.MoveWindow(hWnd, x, y, w, h, TRUE);
END; // .procedure TConsole.Center

PROCEDURE TConsole.WriteC(Attr: BYTE; Txt: STRING);
VAR
  col: BYTE;

BEGIN
  col:=Color;
  SetColors(Attr AND $0F, (Attr AND $F0) SHR 4);
  IF CodePage=cp1251 THEN BEGIN
    CharToOEMBuff(@Txt[1], @Txt[1], Length(Txt));
    Write(Txt);
    OEMToCharBuff(@Txt[1], @Txt[1], Length(Txt));
  END // .if 
  ELSE BEGIN
    Write(Txt);
  END; // .else 
  Color:=col;
END; // .procedure TConsole.WriteC

PROCEDURE TConsole.Print(Txt: STRING);
BEGIN
  IF CodePage=cp1251 THEN BEGIN
    CharToOEMBuff(@Txt[1], @Txt[1], Length(Txt));
    Write(Txt);
    OEMToCharBuff(@Txt[1], @Txt[1], Length(Txt));
  END // .if 
  ELSE BEGIN
    Write(Txt);
  END; // .else 
END; // .procedure TConsole.Print

PROCEDURE TConsole.SetCodePage(NewCodePage: INTEGER);
BEGIN
  CodePage:=TCodePage(NewCodePage);
END; // .procedure SetCodePage

FUNCTION TConsole.ReadKey: CHAR;
VAR
  Temp: INTEGER;
  
BEGIN
  REPEAT
    Windows.ReadConsoleInput(hIn, TIR, 1, DWORD(Temp));
  UNTIL ((TIR.EventType AND 1)=1) AND TIR.Event.KeyEvent.bKeyDown;
  RESULT:=TIR.Event.KeyEvent.AsciiChar;
END; // .function ReadKey

FUNCTION TConsole.ReadCode: CHAR;
BEGIN
  RESULT:=CHAR(BYTE(TIR.Event.KeyEvent.wVirtualScanCode));
END; // .function ReadCode

FUNCTION TConsole.Read: STRING;
VAR
  s: STRING;
  temp: INTEGER;

BEGIN
  SetLength(s, 256);
  Windows.ReadFile(hIn, s[1], 256, DWORD(temp), nil);
  SetLength(s, temp);
  RESULT:=s;
END; // .function Read

PROCEDURE TConsole.HideArea(x1, y1, x2, y2: INTEGER; col, back: BYTE);
VAR
  tc: TCoord;
  temp: INTEGER;
  
BEGIN
  tc.x:=x1;
  tc.y:=y1;
  FillConsoleOutputAttribute(hOut, PackColors(col, back), (y2-y1+1)*(Width)-x1, tc, DWORD(temp));
END; // .procedure HideArea

FUNCTION TConsole.Menu(TitleCol, TitleBack, ItemCol, ItemBack, ChosenCol, ChosenBack, FooterCol, FooterBack: BYTE;
                      CONST Title: STRING; CONST Footer: STRING; Items: PMenu): INTEGER;

CONST
  C_ERROR_TOO_LARGE = -2;
  C_ESC = -1;

VAR
  Count: INTEGER; // Кол-во элементов меню
  X, Y: INTEGER; // Верхняя граница первого элемента меню
  Index: INTEGER;
  bExit: BOOLEAN;
  i: INTEGER;
  C: CHAR;
  Chosen: INTEGER;
  P: POINTER;
  Interval: INTEGER;
  
BEGIN
  // Определяем, а вместится ли наше меню в экран, если нет, то не отображаем
  Count:=Items^.Count;
  P:=Items^.Start;
  Interval:=Items^.Interval;
  IF (Height-CurY-Count-2)<0 THEN BEGIN
    RESULT:=C_ERROR_TOO_LARGE; EXIT;
  END; // .if 
  X:=CurX;
  WriteC(PackColors(TitleCol, TitleBack), Title); GotoXY(X, CurY+1);
  Y:=CurY;
  Index:=0;
  bExit:=FALSE; 
  WHILE NOT bExit DO BEGIN
    // Цикл отрисовки
    GotoXY(X, Y);
    FOR i:=0 TO Count-1 DO BEGIN
      IF i=Index THEN BEGIN
        WriteC(PackColors(ChosenCol, ChosenBack), PAnsiString(INTEGER(P)+i*Interval)^); GotoXY(X, Y+i+1);
      END // .if 
      ELSE BEGIN
        WriteC(PackColors(ItemCol, ItemBack), PAnsiString(INTEGER(P)+i*Interval)^); GotoXY(X, Y+i+1);
      END; // .else 
    END; // .for - конец цикла отрисовки
    WriteC(PackColors(FooterCol, FooterBack), Footer);
    // Цикл чтения клавиатуры
    WHILE TRUE DO BEGIN
      C:=ReadKey;
      CASE C OF 
        #13:
          BEGIN
            Chosen:=Index;
            bExit:=TRUE;
            BREAK;
          END;
        #27:
          BEGIN
            Chosen:=-1;
            bExit:=TRUE;
            BREAK;
          END;
        #0:
          BEGIN
            C:=ReadCode;
            CASE C OF 
              #72:
                BEGIN
                  DEC(Index);
                  IF Index<0 THEN BEGIN
                    Index:=Count-1;
                  END; // .if 
                  BREAK;
                END;
              #80:
                BEGIN
                  INC(Index);
                  IF Index=Count THEN BEGIN
                    Index:=0;
                  END; // .if 
                  BREAK;
                END;
            END; // .case 
          END;
      END; // .case C
    END; // .while 
  END; // .while
  // Очищаем экран от меню и восстанавливаем положение курсора
  DEC(Y);
  HideArea(X, Y, Width-1, Y+Count+1, Self.Back, Self.Back);
  GotoXY(X, Y);
  RESULT:=Chosen;
END; // .function Menu

CONSTRUCTOR TConsole.Create(Title: STRING; WinWidth, WinHeight, BufWidth, BufHeight: INTEGER);
BEGIN
  AllocConsole;
  hWnd:=GetConsoleWindow;
  hIn:=GetStdHandle(STD_INPUT_HANDLE);
  hOut:=GetStdHandle(STD_OUTPUT_HANDLE);
  PInteger(@Input)^:=hIn;
  PInteger(@Output)^:=hOut;
  CodePage:=cp1251;
  Self.Title:=Title;
  SetBufferSize(BufWidth, BufHeight);
  SetWindowSize(WinWidth, WinHeight);
  SetColors(15, 0);
  Windows.ShowWindow(hWnd, SW_NORMAL);
END; // .constructor TConsole.Create

BEGIN
END.
