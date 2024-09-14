UNIT General;
{!INFO
MODULENAME = 'General'
VERSION = '3.0'
AUTHOR = 'Berserker'
DESCRIPTION = 'Общие константы, переменные и функции для всех модулей фреймворка Era'
}

(***)  INTERFACE  (***)
USES Win, Utils, Strings, Lang;

CONST
  (* Герои: Адреса *)
  C_PCHAR_SAVEGAME_NAME = $69FC88; // Имя сохраняемой игры (сейва)
  C_PCHAR_LASTSAVEGAME_NAME = $68338C; // Имя последнего сохранённого/загруженного файла
  (* Герои: Функции *)
  C_FUNC_PLAYSOUND = $59A890; // Функция PlaySound
  C_FUNC_ZVS_TRIGGERS_PLAYSOUND = $774F0A; // Перехватчик PlaySound от ZVS
  C_FUNC_ZVS_ERMMESSAGE = $70FB63; // Функция IF:M
  C_FUNC_ZVS_PROCESSCMD = $741DF0; // ProcessCmd
  C_FUNC_SAVEGAME_HANDLER = $4180C0; // Обработчик: Меню-> Сохранить
  C_FUNC_SAVEGAME = $4BEB60; // Функция сохранения игры
  C_FUNC_ZVS_GZIPWRITE = $704062; // Функция GZipWrite(Address: POINTER; Count: INTEGER); CDECL;
  C_FUNC_ZVS_GZIPREAD = $7040A7; // Функция GZipRead(Address: POINTER; Count: INTEGER); CDECL;
  C_FUNC_ZVS_GETHEROPTR = $71168D; // Функция GetHeroPtr(HeroNum: INTEGER); CDECL;
  C_FUNC_ZVS_CALLFU = $74CE30; // void FUCall(int n)
  C_FUNC_FOPEN = $619691; // FOpen
  (* Герои: Переменные *)
  C_VAR_ERM_V = $887668; // ЕРМ-переменная v1
  C_VAR_ERA_COMMAND = C_VAR_ERM_V + 4*9949; // Команда для Эры или переменная v9950
  C_VAR_ERA_APIRESULT = C_VAR_ERM_V + 4*9998; // Результат выполнения функции API через сервис Эры
  C_VAR_ERM_Z = $9273E8; // ЕРМ-переменная z1
  C_VAR_ERM_Y = $A48D80; // ERM-переменная y1
  C_VAR_ERM_X = $91DA38; // ERM-переменная x1
  C_VAR_ERM_HEAP = $27F9548; // Указатель на первый триггер (_Cmd_)
  C_VAR_ERM_PTR_CURRHERO = $27F9970; // Текущий герой
  C_VAR_HWND = $699650; // Дескриптор окна Героев
  (* Переменные и константы Эры *)
  C_ERA_DLLNAME = 'Angel.dll'; // НЕ ПОДЛЕЖИТ ИЗМЕНЕНИЮ!!!
  C_ERA_PLUGINS_FOLDER = 'EraPlugins\'; // Папка с плагинами для Эры
  (*  Список команд, поддерживаемых Era  *)
  C_ERA_CMD_NONE = 0;
  C_ERA_CMD_LOADLIBRARY = 1;
  C_ERA_CMD_GETPROCADDRESS = 2;
  C_ERA_CMD_CALLAPI = 3;
  C_ERA_CMD_JUSTPLAYSOUND = 4;
  // Примечание: остальные ID - это идентификаторы новых событий/триггеров
  (* Список соглашений API, поддерживаемых Era *)
  C_ERA_CALLCONV_PASCAL = 0;
  C_ERA_CALLCONV_CDECL_OR_STDCALL = 1;
  C_ERA_CALLCONV_THISCALL = 2;
  C_ERA_CALLCONV_FASTCALL = 3;
  (* HookCode constants *)
  C_HOOKTYPE_JUMP = FALSE;
  C_HOOKTYPE_CALL = TRUE;
  C_OPCODE_JUMP = $E9;
  C_OPCODE_CALL = $E8;
  C_UNIHOOK_SIZE = 5;
  (* Erm Message *)
  C_ERMMESSAGE_MES = 1; // Обычное сообщение
  C_ERMMESSAGE_QUESTION = 2; // Вопрос (да/нет)
  C_ERMMESSAGE_RMBINFO = 4; // Окошко popup по правой кнопке
  C_ERMMESSAGE_CHOOSE = 7; // Выбор из двух
  C_ERMMESSAGE_CHOOSEORCANCEL = 10; // Выбор из двух с возможностью отказа
  (* Era Events *)
  C_ERA_EVENT_SAVEGAME_BEFORE = 77000; // Событие до выполнения SaveGame
  C_ERA_EVENT_SAVEGAME_PACK = 77001; // Событие, дающее возможность вызывать GZipWrite
  C_ERA_EVENT_LOADGAME_UNPACK = 77002; //  Событие, дающее возможность вызывать GZipRead
  C_ERA_EVENT_WNDPROC_KEYDOWN = 77003; //  Событие нажатия на клавишу
  C_ERA_EVENT_HEROSCREEN_ENTER = 77004; //  Событие открытия Окна Героя
  C_ERA_EVENT_HEROSCREEN_EXIT = 77005; //  Событие выхода из Окна Героя
  C_ERA_EVENT_BATTLE_WHOMOVES = 77006; //  Событие: кто сейчас ходит в битве
  C_ERA_EVENT_BATTLE_BEFOREACTION = 77007; //  Событие: до действия (на поле боя)
  C_ERA_EVENT_SAVEGAME_AFTER = 77008; // Событие после выполнения SaveGame
  C_ERA_EVENT_SAVEGAME_DIALOG = 77009; // Событие показа диалога сохранения игры по клавише "S"
  C_ERA_EVENT_HEROMEET = 77010; // Событие встречи с другим героем
  (* Era Options *)
  C_ERA_OPTIONSNUM = 4; // Кол-во опций Эры
  C_ERA_OPTION_LOADGAME_QUESTION = 0; // Опция отключения вопроса о загрузке игры
  C_ERA_OPTION_ERMTIMER_ONOFF = 1; // Опция отключения ERM таймера для ускорения игры
  C_ERA_OPTION_CONFLUXGRAILALLSPELLS_ONOFF = 2; // Опция отключения свойства грааля в Сопряжении по обучению всем спелам
  C_ERA_OPTION_COLORFUL_DIALOGS = 3; // Опция разноцветных диалогов
  (* Heroes Constants *)
  C_GAME_TOWN_CONFLUX = 8;
  (* EraHtml *)
  C_ERAHTML_MAX_TEXT_LEN = 1048575; // Максимальный размер текста, который можно обработать в рамках EraHtml


TYPE
  (* Запись, необходимая для работы с функциями патчинга *)
  THookRec = RECORD
    Opcode: BYTE;
    Ofs: INTEGER;
  END; // .record THookRec

  TIntArr = ARRAY[0..MAXLONGINT DIV 4] OF INTEGER;
  PIntArr = ^TIntArr;
  TPtrArr = ARRAY[0..MAXLONGINT DIV 4] OF POINTER;
  PPtrArr = ^TPtrArr;

  (* Формат опций Эры *)
  TOption = RECORD
    Handler: POINTER;
    Value: LongBool;
  END; // .record TOption

  TOptions = ARRAY[0..MAXLONGINT DIV SIZEOF(TOption)] OF TOption;
  POptions = ^TOptions;

  ZIndex = INTEGER; // Индекс ЕРМ-переменной z

  TEraHtmlBuf = OBJECT
    Len: INTEGER; // Кол-во использованных байт
    Buffer: ARRAY [0..C_ERAHTML_MAX_TEXT_LEN] OF BYTE; // Буфер под текст = 1 МБ
    (* Clear *) {Очищает буфер}
    PROCEDURE Clear;
    (* Push *) {Помещает в буфер очередную порцию текста}
    PROCEDURE Push(Addr: POINTER; Num: INTEGER);
  END; // .object  TEraHtmlBuf

  TServiceParam = RECORD
    IsString: BOOLEAN; // является ли значение адресом ЕРМ строки z
    Get: BOOLEAN; // был ли запрос на получение значения
    _0: ARRAY[0..1] OF BYTE; // выравнивание
    Value: INTEGER; // Для чисел - значение, иначе - адрес
  END; // .record TServiceParam

  TServiceParams = RECORD // Тип буфера для параметров к функциям сервиса Эры
    Num: INTEGER;
    Params: ARRAY[0..63] OF TServiceParam;
  END; // .record  TServiceParams

  TServiceRet = RECORD
    Trigger: INTEGER; // Указатель на структуру триггера
    CmdN: INTEGER; // Номер команды в триггере
  END; // .record TServiceRet

  TServiceCallStack = RECORD
    Pos: INTEGER; // Позиция в стёке или -1
    Stack: ARRAY [0..127] OF TServiceRet; // Адреса триггеров для возврата
  END; // .record TServiceCallStack

  TEventParams = ARRAY[0..15] OF INTEGER; // Параметры новых событий


VAR
  Temp: INTEGER; // Универсальная временная переменная
  hEra: Win.THandle; // Дескриптор библиотеки
  (* SaveGame *)
  InSaveGame: LongBool = FALSE; // Мы в экспортируемой процедуре SaveGame или это обычное сохранение
  MarkSaveGame: LongBool = FALSE; // Нужно ли изменить переменную со строкой последнего загруженного/сохранённого сейва
  SaveGameName: PCHAR = NIL; // Имя сохраняемой игры
  CustomSaveGameHandler: POINTER = NIL; // Адрес процедуры, произвольно обрабатывающей запись данных в сейв до передачи управления событию ЕРМ
  CustomLoadGameHandler: POINTER = NIL; // Адрес процедуры, произвольно обрабатывающей загрузку данных из сейва до передачи управления событию ЕРМ
  (* Era Options Table *)
  Options: STRING; // Таблица с опциями Эры
  (* Main Window Hook *)
  InGame: LongBool = FALSE; // В игре ли мы или нет
  DefWndProc: POINTER = NIL; // Адрес оригинальной оконной функции
  (* Colorful Dialogs *)
  PalInd: INTEGER = -1; // Индекс цвета в палитре
  Palette: ARRAY[0..1023] OF SMALLWORD; // Палитра
  EraHtml: TEraHtmlBuf; // Объект, необходимый для реализации цветных диалогов
  (* Service *)
  ServiceParams: TServiceParams; // Буфер для ЕРМ-параметров,
  PtrLastTriggerCall: POINTER = NIL; // Указатель на триггер, который вызывался последним через сервис Эры
  ServiceCallStack: TServiceCallStack; // Стёк возвратов из вызовов произвольных триггеров функций
  EventParams: TEventParams; // Параметры новых событий
  (* Data\s Patch*)
  ErmPath: STRING = '..\Data\ERA\.erm\';          // Путь к скриптам из Map
  ErsPath: STRING = 'Data\ERA\.ers\script00.ers'; // Шаблон для загрузки ers
  ErtPath: STRING = 'Data\ERA\.ert\';             // Путь к файлам ert

(* WriteAtCode *) {Записывает данные из буфера в указанное место}
PROCEDURE WriteAtCode(P: POINTER; Buf: POINTER; Count: INTEGER);
(* HookCode *) {Патчит указанное место 5-байтовым хуком на новое, адрес которого указывается в параметре. Хук может быть вызовом или прыжком. Остальное забивается нопами}
PROCEDURE HookCode(P: POINTER; NewAddr: POINTER; UseCall: BOOLEAN; PatchSize: INTEGER);
(*KillProcess *) {Безжалостно убивает текущий процесс. Никаких ошибок, крайняя мера. PS. SEH отдыхает, скорее всего и векторные тоже}
PROCEDURE KillProcess;
(* FatalError *) {Выводит сообщение об ошибки и варварски завершает процесс}
PROCEDURE FatalError(Msg: STRING);
(* ErmMessage *) {Отображает стандартное геройское сообщение. Переходник к функции ZVS}
FUNCTION ErmMessage(Mes: PCHAR; MesType: INTEGER): INTEGER;
(* ErmMessageEx *) {Отображает стандартное геройское сообщение с раскрытием ЕРМ-переменных через динамическую генерацию и выполнение ресивера IF:M.
Формат строки: 'IF:M^текст^;'}
PROCEDURE ErmMessageEx(Mes: PCHAR; MesLen: INTEGER);
(* ErmJoinedMessage *) {! UNSAFE !; ! HACKS USED ! Процедура выводит объединённое нелогируемое ЕРМ-сообщение через массив строк.
Параметры: Strings..., Count;}
PROCEDURE ErmJoinedMessage;
(* FatalErrorErmMessage *) {! UNSAFE !; ! HACKS USED ! Переходник к ErmJoinedMessage, работающий с индексами строк модуля Lang.
Пример вызова: PUSH Str_A, PUSH Str_B, PUSH 2, CALL ... }
PROCEDURE FatalErrorErmMessage;
(* HexColor2Int *) {Преобразует текст из 4 хекс-символов в его двухбайтовый машинный эквивалент}
FUNCTION HexColor2Int(PHexCol: PINTEGER): INTEGER;
(* HexParam2Int *) {Принимает хекс-строку из 8 символов в нижнем регстре и возвращает её бинарный эквивалент}
{FUNCTION HexParam2Int(PHexStr: POINTER; HexSize: INTEGER): INTEGER;}
(* GetServiceParams *) {Парсит параметры ЕРМ, заносит их в буфер и возвращает реальный размер команды}
FUNCTION GetServiceParams(Cmd: PCHAR): INTEGER;
(* CheckServiceParams *) {Проверяет параметры, переданные ЕРМ команде !!SN:... и возвращает флаг удачи}
FUNCTION CheckServiceParams(CONST Params: ARRAY OF BOOLEAN): BOOLEAN;
(* GenerateCustomErmEvent *) {Генерирует триггер с указанным ID}
PROCEDURE GenerateCustomErmEvent(ID: INTEGER);
(* PCharToAnsi *) {Конвертирует нуль-терминированную строку в анси-строку и возвращает последнюю}
FUNCTION PCharToAnsi (PStr: PCHAR): STRING;
(* StrReplace *) {Заменяет подстроку в строке другой строкой той же длины}
PROCEDURE StrReplace (VAR Str: STRING; CONST SWhat, SWith: STRING);


(***)  IMPLEMENTATION  (***)


PROCEDURE WriteAtCode(P: POINTER; Buf: POINTER; Count: INTEGER);
BEGIN
  Win.VirtualProtect(P, Count, PAGE_READWRITE, @Temp);
  Win.CopyMemory(P, Buf, Count);
  Win.VirtualProtect(P, Count, Temp, NIL);
END; // .procedure WriteAtCode

PROCEDURE HookCode(P: POINTER; NewAddr: POINTER; UseCall: BOOLEAN; PatchSize: INTEGER);
VAR
  HookRec: THookRec;
  NopCount: INTEGER;
  NopBuf: STRING;

BEGIN
  IF UseCall THEN BEGIN
    HookRec.Opcode:=C_OPCODE_CALL;
  END // .if
  ELSE BEGIN
    HookRec.Opcode:=C_OPCODE_JUMP;
  END; // .else
  HookRec.Ofs:=INTEGER(NewAddr)-INTEGER(P)-C_UNIHOOK_SIZE;
  WriteAtCode(P, @HookRec, 5);
  NopCount:=PatchSize-5;
  IF NopCount>0 THEN BEGIN
    SetLength(NopBuf, NopCount);
    FillChar(NopBuf[1], NopCount, CHR($90));
    General.WriteAtCode(Ptr(INTEGER(P)+5), @NopBuf[1], NopCount);
  END; // .if
END; // .procedure HookCode

PROCEDURE KillProcess; ASSEMBLER;
ASM
  XOR EAX, EAX
  MOV ESP, EAX
  MOV EAX, [EAX]
END; // .procedure KillProcess

PROCEDURE FatalError(Msg: STRING);
BEGIN
  Win.MessageBox(0, PCHAR(Msg), PCHAR(Lang.Str[Str_FatalError_Init_Title]), Win.MB_ICONSTOP);
  KillProcess;
END; // .procedure FatalError

FUNCTION ErmMessage(Mes: PCHAR; MesType: INTEGER): INTEGER; ASSEMBLER; {$FRAME+}
ASM
  PUSH 0
  PUSH MesType
  PUSH Mes
  MOV EAX, C_FUNC_ZVS_ERMMESSAGE
  CALL EAX
  ADD ESP, $0C
END; // .function ErmMessage

PROCEDURE ErmMessageEx(Mes: PCHAR; MesLen: INTEGER);
TYPE
  TStr = RECORD
    PText: PCHAR;
    Len: INTEGER;
  END; // .record

  TCommand = RECORD
    Name: ARRAY[0..1] OF CHAR; // IF
    Disabled: BOOLEAN; // FALSE
    PrevDisabled: BOOLEAN; // FALSE
    _1: ARRAY[0..511] OF BYTE;
    _2: POINTER;
    _3: ARRAY[0..127] OF BYTE;
    ParamsCount: INTEGER; // 0
    PCmdHeader: TStr; // IF:M
    PCmdBody: TStr; // M^...^;
  END; // .record

VAR
  Cmd: TCommand;

BEGIN
  Cmd.Name:='IF';
  Cmd.Disabled:=FALSE;
  Cmd.PrevDisabled:=FALSE;
  Cmd.ParamsCount:=0;
  Cmd.PCmdHeader.PText:=Mes;
  Cmd.PCmdHeader.Len:=MesLen;
  Cmd.PCmdBody.PText:=POINTER(INTEGER(Mes)+3);
  Cmd.PCmdBody.Len:=MesLen-3;
  ASM
    // Вызываем ProcessCmd без лога последней ЕРМ-команды.
    // Заталкиваем параметры в стёк
    PUSH 0
    PUSH 0
    LEA EAX, Cmd
    PUSH EAX
    // Псевдовызов ProcessCmd
    // Заталкиваем адрес возврата
    LEA EAX, @@Ret
    PUSH EAX
    // Выполняем дефолтный код без лога
    PUSH EBP
    MOV EBP, ESP
    SUB ESP, $544
    PUSH EBX
    PUSH ESI
    PUSH EDI
    MOV EAX,[EBP+8]
    MOV CX,[EAX]
    MOV [EBP-$314], CX
    MOV EDX, [EBP+8]
    MOV EAX,[EDX+$294]
    MOV [EBP-$2FC], EAX
    // А теперь передаём управление коду после лога
    PUSH $741E3F
    RET
    @@Ret:
  END; // .asm
END; // .procedure ErmMessageEx

PROCEDURE ErmJoinedMessage;
TYPE
  TStrArray = ARRAY[0..MAXLONGINT DIV 4] OF STRING;
  PStrArray = ^TStrArray;

VAR
  i: INTEGER;
  JoinedLen: INTEGER; // Размер объединённой строки
  Len: INTEGER; // Размер очередной копируемой строки
  BufPos: INTEGER; // Текущая позиция в  буфере объединяемой строки
  Count: INTEGER; // Кол-во строк
  Strings: PStrArray; // Указатель на массив строк
  Str: STRING; // Объединённая строка

BEGIN
  ASM
    // Получаем кол-во аргументов
    MOV EAX, [EBP+8]
    MOV Count, EAX
    // Получаем указатель на список строк
    LEA EAX, [EBP+12]
    MOV Strings, EAX
  END; // .asm
  // Рассчитываем общую длину строк
  JoinedLen:=0;
  FOR i:=0 TO Count-1 DO BEGIN
    INC(JoinedLen, Length(Strings^[i]));
  END; // .for
  // Выделяем буфер данной длины
  SetLength(Str, JoinedLen);
  // Поочерёдно копируем строки в буфер
  BufPos:=1;
  FOR i:=Count-1 DOWNTO 0 DO BEGIN
    Len:=Length(Strings^[i]);
    IF Len>0 THEN BEGIN
      CopyMemory(@Str[BufPos], @Strings^[i][1], Len);
      INC(BufPos, Len);
    END; // .if
  END; // .for
  General.ErmMessageEx(PCHAR(Str), JoinedLen);
  // Реализация очистки мусора
  ASM
    // Блок подмены адреса возврата
    MOV EAX, [EBP+4]
    MOV [EBP+12], EAX
    LEA EAX, @@Garbage
    MOV [EBP+4], EAX
    JMP @@Exit
      @@Garbage:
      // Блок уборки мусора
      MOV EAX, [ESP]
      MOV ECX, [ESP+4]
      LEA ESP, [ESP+EAX*4+4]
      JMP ECX
    @@Exit:
  END; // .asm
END; // .procedure ErmJoinedMessage

PROCEDURE FatalErrorErmMessage; ASSEMBLER; {$FRAME-}
ASM
  // Перенаправляем адрес возврата
  LEA EAX, @@Continue
  MOV [ESP], EAX
  // ECX = ParamsCount
  MOV ECX, [ESP+4]
  // Меняем индексы строк на реальные адреса из модуля Lang
  // EDX = @Params[Count]
  LEA EDX, [ESP+8]
  @@Loop:
    MOV EAX, [EDX]
    MOV EAX, [OFFSET Lang.Str+EAX*4]
    MOV [EDX], EAX
    ADD EDX, 4
    DEC ECX
    JNZ @@Loop
  JMP ErmJoinedMessage
  @@Continue:
    // Вызываем исключение
    XOR EAX, EAX
    MOV [EAX], EAX
END; // .procedure FatalErrorErmMessage

PROCEDURE TEraHtmlBuf.Clear;
BEGIN
  Self.Len:=0;
END; // .procedure TEraHtmlBuf.Clear

PROCEDURE TEraHtmlBuf.Push(Addr: POINTER; Num: INTEGER);
BEGIN
  CopyMemory(@Self.Buffer[Self.Len], Addr, Num);
  INC(Self.Len, Num);
END; // .procedure TEraHtmlBuf.Push

FUNCTION HexColor2Int(PHexCol: PINTEGER): INTEGER; ASSEMBLER; {$FRAME-}
ASM
  XOR EAX, EAX
  MOV EDX, PHexCol
  MOV EDX, [EDX]
  PUSH ESI
  MOV ECX, 4
@@Cycle:
  SUB DL, $40
  JS @@BelowTen
@@AboveTen:
  ADD DL, $9
  JMP @@AddHalfByte
@@BelowTen:
  ADD DL, $10
@@AddHalfByte:
  MOVZX ESI, DL
  OR EAX, ESI
  SHL EAX, 4
  SHR EDX, 8
  DEC ECX
  JNZ @@Cycle
  SHR EAX, 4
  POP ESI
  // RET
END; // .function HexColor2Int

{ NOT USED ANY MORE
FUNCTION HexParam2Int(PHexStr: POINTER; HexSize: INTEGER): INTEGER; ASSEMBLER; {$FRAME+}
{ASM
  XOR EAX, EAX // Очистили результат
  MOV ECX, HexSize // Получили размер хекс-строки
  PUSH ESI // Сохранили ESI
@@Loop:
  MOV EDX, PHexStr
  MOVZX EDX, BYTE [EDX]
  INC PHexStr
  SUB DL, $60
  JS @@BelowTen
@@AboveTen:
  ADD DL, $9
  JMP @@AddHalfByte
@@BelowTen:
  ADD DL, $30
@@AddHalfByte:
  MOVZX ESI, DL
  OR EAX, ESI
  ROL EAX, 4
  DEC ECX
  JNZ @@Loop
  ROR EAX, 4
  POP ESI
  // RET
END; // .function HexParam2Int
}}

FUNCTION StrToIntFast(Str: PCHAR; StrLen: INTEGER): INTEGER; ASSEMBLER; {$FRAME+}
ASM
  XOR EAX, EAX // Очистили результат
  MOV ECX, StrLen // Получили размер строки
  JMP @@LoopStart
@@Loop:
  MOV EDX, EAX
  ROL EAX, 3
  ADD EAX, EDX
  ADD EAX, EDX
@@LoopStart:
  MOV EDX, Str
  MOVZX EDX, BYTE [EDX]
  INC Str
  SUB DL, $30
  MOVZX EDX, DL
  ADD EAX, EDX
  DEC ECX
  JNZ @@Loop
END; // .function StrToIntFast

FUNCTION GetServiceParams(Cmd: PCHAR): INTEGER;
TYPE
  TCharArr = ARRAY [0..MAXLONGINT] OF CHAR;
  PCharArr = ^TCharArr;

VAR
  PCmd: PCharArr; // указатель на начало строки параметров
  NumParams: INTEGER; // кол-во параметров
  ParType: CHAR; // тип параметра: v, z, x, y или #0
  ParValue: INTEGER; // значение параметра
  BeginPos: INTEGER; // начальная позиция очередного параметра в строке параметров
  Pos: INTEGER; // текущая позиция в строке параметров

BEGIN
  PCmd:=POINTER(Cmd); // Указатель на начало строки с параметрами
  NumParams:=0; // Кол-во параметров
  Pos:=1; // Начальная позиция. Первый символ пропускаем, так как это сама команда
  WHILE PCmd^[Pos]<>';' DO BEGIN
    // Получаем тип команды: GET or SET
    IF PCmd^[Pos] = '?' THEN BEGIN
      ServiceParams.Params[NumParams].Get:=TRUE;
      INC(Pos);
    END // .if
    ELSE BEGIN
      ServiceParams.Params[NumParams].Get:=FALSE;
    END; // .else
    // Получаем тип параметра: z, v, x, y или константа
    ParType:=PCmd^[Pos];
    IF ParType IN ['0'..'9'] THEN BEGIN
      ParType:=#0;
    END // .if
    ELSE BEGIN
      INC(Pos);
    END; // .else
    // Запоминаем начало параметра
    BeginPos:=Pos;
    // Сканируем строку до символа ';' или '/', которые являются ограничителями параметров
    WHILE NOT(PCmd^[Pos] IN [';', '/']) DO BEGIN
      INC(Pos);
    END; // .while
    // Получаем числовое значение параметра
    ParValue:=StrToIntFast(@PCmd^[BeginPos], Pos-BeginPos);
    IF PCmd^[Pos] = '/' THEN BEGIN
      INC(Pos);
    END; // .if
    // Для констант уже всё готово, так что обрабатываем переменные.
    // Для начала получим их реальные адреса. Например $887668 вместо v1. Если синтаксис SET, то получаем значения по адресам
    IF ParType <> #0 THEN BEGIN
      CASE ParType OF
        'y': BEGIN
          ParValue:=(C_VAR_ERM_Y-4) + ParValue * 4;
          IF NOT ServiceParams.Params[NumParams].Get THEN BEGIN
            ParValue:=PINTEGER(ParValue)^;
          END; // .if
        END; // .switch y
        'v': BEGIN
          ParValue:=(C_VAR_ERM_V-4) + ParValue * 4;
          IF NOT ServiceParams.Params[NumParams].Get THEN BEGIN
            ParValue:=PINTEGER(ParValue)^;
          END; // .if
        END; // .switch v
        'z': BEGIN
          ParValue:=(C_VAR_ERM_Z-512) + ParValue * 512;
        END; // .switch z
        'x': BEGIN
          ParValue:=(C_VAR_ERM_X-4) + ParValue * 4;
          IF NOT ServiceParams.Params[NumParams].Get THEN BEGIN
            ParValue:=PINTEGER(ParValue)^;
          END; // .if
        END; // .switch x
      ELSE
        RESULT:=-1; EXIT;
      END; // .case ParType
    END; // .if
    // Устанавливаем значения структуры ServiceParams и переходим к следующему параметру
    ServiceParams.Params[NumParams].IsString:=ParType = 'z';
    ServiceParams.Params[NumParams].Value:=ParValue;
    INC(NumParams);
  END; // .while
  ServiceParams.Num:=NumParams;
  RESULT:=Pos; // Pos - как раз размер строки параметров
END; // .function GetServiceParams

FUNCTION CheckServiceParams(CONST Params: ARRAY OF BOOLEAN): BOOLEAN;
VAR
  NumParams: INTEGER; // кол-во проверяемых параметров
  i: INTEGER;

BEGIN
  // По умолчанию результат - истина
  RESULT:=TRUE;
  // Получили кол-во проверяемых параметров
  NumParams:=HIGH(Params)+1;
  // ...и сравнили их с кол-вом переданных параметров, причём не забываем, что два проверяемых параметра на самом деле - поля IsString и Get одного параметра
  IF (NumParams DIV 2) <> ServiceParams.Num THEN BEGIN
    // ... и если они не равны, то возвращаем false
    RESULT:=FALSE; EXIT;
  END; // .if
  // Проверяем каждый параметр в цикле
  FOR i:=0 TO HIGH(Params) DO BEGIN
    IF
      (ServiceParams.Params[i DIV 2].IsString <> Params[i]) OR
      (ServiceParams.Params[i DIV 2].Get <> Params[i+1])
    THEN BEGIN
      RESULT:=FALSE; EXIT;
    END; // .if
    INC(i);
  END; // .for
END; // .function CheckServiceParams

PROCEDURE GenerateCustomErmEvent(ID: INTEGER); ASSEMBLER; {$FRAME-}
ASM
  PUSH ID
  MOV EAX, C_FUNC_ZVS_CALLFU
  CALL EAX
  ADD ESP, 4
  // RET
END; // .procedure GenerateCustomErmEvent

FUNCTION PCharToAnsi (PStr: PCHAR): STRING;
VAR
  S: STRING;
  Len: INTEGER;

BEGIN
  Len:=Utils.StrLen(PStr);
  SetLength(S, Len);
  Win.CopyMemory(@S[1], PStr, Len);
  RESULT:=S;
END; // .function PCharToAnsi

PROCEDURE StrReplace (VAR Str: STRING; CONST SWhat, SWith: STRING);
VAR
  Pos: PCHAR;

BEGIN
  Pos:=Strings.StrPos(@Str[1], @SWhat[1]);
  IF Pos <> NIL THEN BEGIN
    Win.CopyMemory(Pos, @SWith[1], Length(SWith));
  END; // .if
END; // .procedure StrReplace

END.
