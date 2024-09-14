UNIT Main;
{!INFO
MODULENAME = 'Main'
VERSION = '4.0'
AUTHOR = 'Berserker'
DESCRIPTION = 'Ядро Эры'
}

(***)  INTERFACE  (***)
USES Windows, SysUtils, General, UExports, Triggers, Lang, Strings;

(* InitEra *) {Инициализирует Эру. Патчит нужные места для работы ядра и вызывает процедуры патчинга других модулей. Также реализует подгрузку сторонних DLL}
PROCEDURE InitEra;


(***)  IMPLEMENTATION  (***)


FUNCTION  ExtendedEraService (Cmd: CHAR; NumParams: INTEGER; Params: General.PServiceParams; VAR Err: PCHAR): BOOLEAN; STDCALL; EXTERNAL 'era.dll' NAME 'ExtendedEraService';


(* ShowServiceError *) {Отображает ошибку в виде  ЕРМ сообщения и показывает контекст ЕРМ-кода}
PROCEDURE ShowServiceError(Mes: PCHAR; CmdStr: PCHAR);
TYPE
  TCharArr = ARRAY [0..MAXLONGINT] OF CHAR;
  PCharArr = ^TCharArr;

VAR
  Cmd: PCharArr; // указатель на очереднй символ контекста ошибки
  Pos: INTEGER; // позиция в контексте ошибки
  c: CHAR; // заменяемый символ
  
BEGIN
  Pos:=0;
  Cmd:=POINTER(CmdStr);
  WHILE (Pos<256) AND (Cmd^[Pos]<>#0) DO BEGIN
    INC(Pos);
  END; // .while
  c:=Cmd^[Pos];
  Cmd^[Pos]:=#0;
  General.ErmMessage(Mes, General.C_ERMMESSAGE_MES);
  General.ErmMessage(CmdStr, General.C_ERMMESSAGE_MES);
  Cmd^[Pos]:=c;
END; // .procedure ShowServiceError

(* GetFuncTriggerAddr *) {Возвращает указатель на структуру триггера нужной функции по её номеру}
FUNCTION GetFuncTriggerAddr(FuncN: INTEGER): INTEGER;
TYPE
  PCmd = ^TCmd;
  TCmd = RECORD // Часть структуры триггера
    Next: PCmd;
    Event: INTEGER;
  END; // .record TCmd

VAR
  Res: PCmd;
  
BEGIN
  INTEGER(Res):=PINTEGER(General.C_VAR_ERM_HEAP)^;
  WHILE Res<>NIL DO BEGIN
    IF Res^.Event = FuncN THEN BEGIN
      RESULT:=INTEGER(Res); EXIT;
    END; // .if
    Res:=Res^.Next;
  END; // .while
  RESULT:=0;
END; // .function GetFuncTriggerAddr

(* CallProc *) {Вызывает внешнюю функцию. PParams указывает на начало массива параметров. v1 содержит результат}
PROCEDURE CallProc(Addr: INTEGER; Convention: INTEGER; PParams: POINTER; NumParams: INTEGER); ASSEMBLER; {$FRAME+}
CONST
  ParamOffset = SIZEOF(General.TServiceParam); // Смещение до следующего параметра в массиве параметров

VAR
  SavedEsp:   INTEGER;  // Сохранённое состояние стёка
  IsFloatRes: LONGBOOL;
  
ASM
  MOV IsFloatRes, 0
  CMP Convention, CONVENTION_FLOAT
  JB @@IntConvention
@@FloatConvetion:
  MOV IsFloatRes, 1
  SUB Convention, CONVENTION_FLOAT
@@IntConvention:
  // Сохранили регистр EBX
  PUSH EBX
  // Сохранили состояние стёка в EBP
  MOV SavedEsp, ESP
  // Если параметров у функции нет, то сразу вызываем её
  MOV ECX, NumParams
  TEST ECX, ECX
  JZ @@CallProc
  // EBX = Convention
  MOV EBX, Convention
  // EDX указывает на первый параметр
  MOV EDX, PParams
  // Обрабатываем соглашение Pascal отдельно от других
  TEST EBX, EBX
  JNZ @@NotPascalConversion
@@PascalConversion:
  // Цикл вталкивания аргументов в стёк
  @@PascalLoop:
    PUSH DWORD [EDX]
    ADD EDX, ParamOffset
    DEC ECX
    JNZ @@PascalLoop
  JMP @@CallProc
@@NotPascalConversion:
  // Перерасчитываем кол-во аргументов для вталкивания в стёк
  DEC EBX
  SUB ECX, EBX
  // ...И если аргументы поместились в регистры, то вталкивать в стёк ничего не нужно
  JZ @@InitThisOrFastCall
  JS @@InitThisOrFastCall
  // Иначе вталкиваем аргументы в стёк в обратном порядке
  ADD ECX, EBX
  PUSH ECX
  (* WARNING! TServiceParam size used *)
  SHL ECX, 4
  //LEA ECX, [ECX + ECX * 3]
  LEA EDX, [EDX + ECX - ParamOffset]
  POP ECX
  SUB ECX, EBX
  @@CdeclLoop:
    PUSH DWORD [EDX]
    SUB EDX, ParamOffset
    DEC ECX
    JNZ @@CdeclLoop
  @@InitThisOrFastCall:
  // Инициализируем аргументы для ThisCall и FastCall
  MOV ECX, PParams
  MOV EDX, [ECX+ParamOffset]
  MOV ECX, [ECX]
@@CallProc:
  // Вызываем процедуру
  MOV EAX, Addr
  CALL EAX
  // Сохраняем  результат
  CMP IsFloatRes, 1
  JNE @@IntRes
@@FloatRes:
  FST DWORD [$A48F18]
  JMP @@Ret
@@IntRes:
  MOV DWORD [General.C_VAR_ERM_V], EAX
@@Ret:
  // Восстанавливаем указатель стёка и сохранённые регистры
  MOV ESP, SavedEsp
  POP EBX
  // RET
END; // .PROCEDURE CallProc

(* Service *) {Команды ЕРМ, реализуемые фреймворком "Эра"}
FUNCTION Service(Ebp: INTEGER): LONGBOOL;
CONST
  PtrStackMes   = $14;  // + Указатель на структуру _Mes_, что используется в ProcessErm
  PtrCmdLen     = $268; // + // Указатель на размер/смещение команды в функции ProcessCmd 
  PtrStackCmdN  = $730; // + Указатель на номер команды в данном триггере. ProcessErm
  PtrTrigger    = $8C8; // + Указатель на структуру текущего триггера. ProcessErm
  PtrEventId    = $72C; // + Указатель на ID текущего события
  
  (* контанты для функции CheckServiceParams *)
  STR   = TRUE;   // Параметр является строкой
  NUM   = FALSE;  // Параметр - числовое значение
  GETV  = TRUE;   // Синтаксис GET
  SETV  = FALSE;  //Синтаксис SET

TYPE
  TMes = RECORD
    Offset: INTEGER; // смещение до подкоманды в команде
    Ptr: PCHAR; // указатель на текст команды
  END; // .record Mes
  
  PCmd = ^TCmd;
  TCmd = RECORD
    Next: PCmd;
    Event: INTEGER;
  END; // .record TCmd
  
VAR
  Mes:        ^TMes; // Указатель на структуру TMes
  BaseCmdStr: PCHAR;
  CmdStr:     PCHAR; // Строка команды
  Cmd:        CHAR; // Символ команды
  CmdLen:     INTEGER; // Длина команды
  CmdN:       PINTEGER; // Указатель на номер текущей команды в триггере
  Trigger:    PCmd; // Текущий триггер
  Len:        INTEGER; // Длина внешней строки текста типа PCHAR
  NumParams:  INTEGER;
  Params:     General.TServiceParams;
  Err:        PCHAR;
  i:          INTEGER;


BEGIN
  RESULT:=TRUE; // По умолчанию Эра обрабатывает все команды
  INTEGER(Mes):=PINTEGER(Ebp+PtrStackMes)^; // Получили указатель на структуру TMes
  INTEGER(CmdStr):=PINTEGER(INTEGER(Mes)+4)^; // Получили указатель на строку с командой
  CmdN:=PINTEGER(Ebp+PtrStackCmdN); // Указатель на номер команды в триггере
  Cmd:=CmdStr^; // Получили сам символ команды
  // Если это стандартная, то пусть её обрабатывает оригинальный обработчик
  IF (Cmd = 'P') OR (Cmd = 'S') THEN BEGIN
    RESULT:=FALSE; EXIT;
  END; // .if
  BaseCmdStr  :=  CmdStr;
  WHILE CmdStr^ <> ';' DO BEGIN
    Cmd:=CmdStr^;
    CmdLen:=GetServiceParams(CmdStr, NumParams, Params); // Парсим параметры, а заодно получаем истинный размер строки команды
    // Если парсинг был неудачным, значит в параметрах ошибка. Выведем сообщение и корректно выйдем из функции
    IF CmdLen = -1 THEN BEGIN
      ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_Params]), CmdStr);
      CmdN^:=2000000000;
      EXIT;
    END; // .if
    // Установим реальный размер строки параметров для ProcessCmd, иначе она будет ещё не раз вызывать нашу функцию, считая каждый символ командой
    // Пошло выполнение отдельных команд
    CASE Cmd OF 
      'G': BEGIN
        // PARAMS: CmdN: INTEGER
        IF NOT General.CheckServiceParams(NumParams, Params, [NUM, SETV]) THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_G]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        CmdN^:=Params[0].Value - 1;
      END; // .switch G
      'C': BEGIN
        IF (NumParams = 2) THEN BEGIN
          // PARAMS: TriggerAddr: POINTER; CmdN: INTEGER;
          IF NOT General.CheckServiceParams(NumParams, Params, [NUM, SETV, NUM, SETV]) THEN BEGIN
            ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_C]), CmdStr);
            CmdN^:=2000000000;
            EXIT;
          END; // .if
          INC(General.ServiceCallStack.Pos);
          General.ServiceCallStack.Stack[General.ServiceCallStack.Pos].Trigger:=PINTEGER(Ebp+PtrTrigger)^;
          General.ServiceCallStack.Stack[General.ServiceCallStack.Pos].CmdN:=CmdN^;
          PINTEGER(Ebp+PtrTrigger)^:=Params[0].Value;
          PINTEGER(Ebp+PtrStackCmdN)^:=Params[1].Value-1;
        END // .if
        ELSE IF (NumParams = 3) THEN BEGIN
          // PARAMS: NIL; TriggerID: INTEGER; ?Res: INTEGER; 
          IF
            (NOT General.CheckServiceParams(NumParams, Params, [NUM, SETV, NUM, SETV, NUM, GETV])) OR
            (Params[0].Value <> 0)
          THEN BEGIN
            ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_C]), CmdStr);
            CmdN^:=2000000000;
            EXIT;
          END; // .if
          PINTEGER(Params[2].Value)^:=GetFuncTriggerAddr(Params[1].Value);
        END // .elseif
        ELSE BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_C]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .else
      END; // .switch C
      'R': BEGIN
        // PARAMS: (NO)
        IF NumParams <> 0 THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_R]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        PINTEGER(Ebp+PtrTrigger)^:=General.ServiceCallStack.Stack[General.ServiceCallStack.Pos].Trigger;
        PINTEGER(Ebp+PtrStackCmdN)^:=General.ServiceCallStack.Stack[General.ServiceCallStack.Pos].CmdN;
        DEC(General.ServiceCallStack.Pos);
      END; // .switch R
      'Q': BEGIN
        // PARAMS: (NO)
        IF NumParams <> 0 THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_Q]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        PINTEGER(Ebp+PtrEventId)^:=2000000000;
        CmdN^:=2000000000;
      END; // .switch Q
      'E': BEGIN
        // PARAMS: Addr: POINTER; Convention: INTEGER; Params: ANY...
        IF
          (NumParams < 0) OR
          NOT (General.CheckServiceParams(2, Params, [NUM, SETV, NUM, SETV])) OR
          (Params[0].Value = 0) OR
          NOT (Params[1].Value IN [General.C_ERA_CALLCONV_PASCAL..General.C_ERA_CALLCONV_FASTCALL + CONVENTION_FLOAT])
        THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_E]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        
        CallProc
        (
          Params[0].Value, // Addr
          Params[1].Value, // Convention
          @Params[2].Value, // PParams
          NumParams - 2 // NumParams
        ); // CallProc
      END; // .switch E
      'A': BEGIN
        // PARAMS: hDll: INTEGER; ProcName: STRING; ?Res: INTEGER;
        IF NOT General.CheckServiceParams(NumParams, Params, [NUM, SETV, STR, SETV, NUM, GETV]) THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_A]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        PINTEGER(Params[2].Value)^:=INTEGER(Windows.GetProcAddress(Params[0].Value, PCHAR(Params[1].Value)));
      END; // .switch A
      'L': BEGIN
        // PARAMS: DllName: STRING; ?Res: INTEGER;
        IF NOT General.CheckServiceParams(NumParams, Params, [STR, SETV, NUM, GETV]) THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_L]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        PINTEGER(Params[1].Value)^:=INTEGER(Windows.LoadLibrary(PCHAR(Params[0].Value)));
      END; // .switch L
      'X': BEGIN
        IF NumParams > (HIGH(General.EventParams)+1) THEN BEGIN
          ShowServiceError(PCHAR(Lang.Str[Lang.Str_Error_Service_X]), CmdStr);
          CmdN^:=2000000000;
          EXIT;
        END; // .if
        FOR i:=0 TO NumParams - 1 DO BEGIN
          IF Params[i].Get THEN BEGIN
            IF Params[i].IsString THEN BEGIN
              Len:=Strings.StrLen(POINTER(General.EventParams[i]));
              IF Len>0 THEN BEGIN
                Windows.CopyMemory(POINTER(Params[i].Value), POINTER(General.EventParams[i]), Len+1);
              END // .if
              ELSE BEGIN
                PCHAR(Params[i].Value)^:=#0;
              END; // .else
            END // .if
            ELSE BEGIN
              PINTEGER(Params[i].Value)^:=General.EventParams[i];
            END; // .else
          END // .if
          ELSE BEGIN
            General.ModifyWithParam(@General.EventParams[i], @Params[i]);
          END; // .else
        END; // .for
      END; // .switch X
    ELSE
      IF NOT ExtendedEraService(Cmd, NumParams, @Params, Err) THEN BEGIN
        ShowServiceError(Err, CmdStr);
        CmdN^ :=  2000000000; EXIT;
      END; // .IF
    END; // .case Cmd
    INC(INTEGER(CmdStr), CmdLen);
  END; // .WHILE
  
  PINTEGER(Ebp+PtrCmdLen)^:=INTEGER(CmdStr) - INTEGER(BaseCmdStr);
END; // .function Service

(* Asm_Service *) {Переходник к высокоуровневой процедуре ядра Service}
PROCEDURE Asm_Service; ASSEMBLER; {$FRAME-}
ASM
  // Сохраним регистры
  PUSHAD
  // Вызываем высокоуровневую функцию Service
  PUSH EBP
  CALL Service
  // Если результат отрицательный - значит выполняем действие по умолчанию
  TEST EAX, EAX
  JNZ @@QuitCmdSN
@@ExecCmdSN:
  // Восстановим регистры
  POPAD
  // Выполним старый код
  MOV AL, BYTE [EBP+$8]
  MOV BYTE [EBP-$0C], AL
  // И возвратим управление оригинальной функции
  PUSH $774FB0
  RET
@@QuitCmdSN:
  // ...Service вернула положительный результат, значит нужно корректно выйти из оригинальной функции
  // Восстановим регистры
  POPAD
  // И выйдем
  PUSH $77519F
  // RET
END; // .procedure Asm_Service

PROCEDURE LoadPlugins;
VAR
  Pattern: STRING; // Шаблон файлов для поиска
  FileName: STRING; // Полное имя загружаемой dll
  FileInfo: Windows.TWin32FindData; // Информация о найденном файле
  hFileSearch: Windows.THandle; // Дескриптор поиска
  
BEGIN
  Pattern:=General.C_ERA_PLUGINS_FOLDER+'*.dll';
  hFileSearch:=Windows.FindFirstFile(PCHAR(Pattern), FileInfo);
  IF hFileSearch=Windows.INVALID_HANDLE_VALUE THEN BEGIN
    EXIT;
  END; // .if 
  REPEAT
    IF FileInfo.nFileSizeLow > 0 THEN BEGIN
      FileName:=General.C_ERA_PLUGINS_FOLDER;
      FileName:=FileName+FileInfo.cFileName;
      LoadLibrary(PCHAR(FileName));
    END; // .IF
  UNTIL Windows.FindNextFile(hFileSearch, FileInfo)=FALSE;
  
  Windows.FindClose(hFileSearch);
END; // .procedure LoadPlugins

PROCEDURE PatchFromBin(FileName: STRING);
TYPE
  PMiniPatch = ^TMiniPatch;
  TMiniPatch  = RECORD
    Address: INTEGER; // Абсолютный адрес для патча
    Number: INTEGER; // Кол-во байт
    // Bytes...
  END; // .record 

VAR
  hFile: Windows.THandle; // Дескриптор файла
  Buffer: STRING; // Временный буфер для файла
  Count: INTEGER; // Кол-во мини-патчей в файле
  FileSize: INTEGER; // Размер файла
  ErrorStr: STRING; // Сообщение о фатальной ошибке с именем файла
  Patch: PMiniPatch; // Указатель на очередной мини-патч
  Address: INTEGER; // Абсолютный адрес из очредного мини-патча
  Number: INTEGER; // Размер буфера очередного мини-патча
  Buf: POINTER; // Адрес буфера очередного мини-патча
  i: INTEGER;
  
BEGIN
  ErrorStr:=Lang.Str[Str_Error_DinPatch_CannotLoadBinFile]+FileName+'".';
  hFile:=SysUtils.FileOpen(FileName, fmOpenRead OR fmShareExclusive);
  IF hFile<0 THEN BEGIN
    FatalError(ErrorStr);
  END; // .if 
  FileSize:=Windows.GetFileSize(hFile, NIL);
  IF FileSize=-1 THEN BEGIN
    FatalError(ErrorStr);
  END; // .if 
  IF FileSize=0 THEN BEGIN
    SysUtils.FileClose(hFile);
    EXIT;
  END; // .if 
  SetLength(Buffer, FileSize);
  IF SysUtils.FileRead(hFile, Buffer[1], FileSize)<>FileSize THEN BEGIN
    FatalError(ErrorStr);
  END; // .if 
  Count:=PINTEGER(@Buffer[1])^;
  Patch:=@Buffer[5];
  ErrorStr:=Lang.Str[Str_Error_DinPatch_Exception]+FileName+'".';
  TRY
    FOR i:=1 TO Count DO BEGIN
      Address:=Patch^.Address;
      Number:=Patch^.Number;
      Buf:=POINTER(INTEGER(Patch)+8);
      General.WriteAtCode(POINTER(Address), Buf, Number);
      INC(INTEGER(Patch), 8+Number);
    END; // .for 
  EXCEPT
    FatalError(ErrorStr);
  END; // .try 
  SysUtils.FileClose(hFile);
END; // .procedure PatchFromBin

PROCEDURE DinamicPatching;
VAR
  Pattern: STRING; // Шаблон файлов для поиска
  FileName: STRING; // Полное имя загружаемого файлаl
  FileInfo: Windows.TWin32FindData; // Информация о найденном файле
  hFileSearch: Windows.THandle; // Дескриптор поиска
  
BEGIN
  Pattern:=General.C_ERA_PLUGINS_FOLDER+'*.bin';
  hFileSearch:=Windows.FindFirstFile(PCHAR(Pattern), FileInfo);
  IF hFileSearch=Windows.INVALID_HANDLE_VALUE THEN BEGIN
    EXIT;
  END; // .if 
  REPEAT
    FileName:=General.C_ERA_PLUGINS_FOLDER;
    FileName:=FileName+FileInfo.cFileName;
    PatchFromBin(FileName);
  UNTIL Windows.FindNextFile(hFileSearch, FileInfo)=FALSE;
  
  Windows.FindClose(hFileSearch);
END; // .procedure DinamicPatching

(*
PROCEDURE Hook_HeroesMeet_Call; ASSEMBLER; {$FRAME-}
ASM
  // Если триггер - !?OB, то возвращаемся
  CMP DWORD [EBP+$1C], 34
  JNE @@Exit
  // Получаем номер героя-инициатора
  PUSHAD
  CALL General.SaveEventParams
  POPAD
  MOV EAX, [$69CCFC]
  MOV EAX, [EAX+4]
  MOV DWORD [General.EventParams], EAX
  // Получаем номер цели
  LEA ECX, [ECX-30100]
  MOV DWORD [General.EventParams+4], ECX
  // Генерируем ЕРМ-событие
  PUSHAD
  PUSH General.C_ERA_EVENT_HEROMEET
  CALL General.GenerateCustomErmEvent
  CALL General.RestoreEventParams
  POPAD
  // Возвращаем управление ZVS
  @@Exit:
  PUSH $74D760
  PUSH $74C816
END; // .procedure Hook_HeroesMeet_Call
*)

PROCEDURE Hook_BeforeHeroesInteraction; ASSEMBLER; {$FRAME-}
ASM
  PUSH EBP
  MOV EBP, ESP
  PUSH EBX
  PUSH ESI
  PUSH EDI
  //
  PUSHAD
  CALL General.SaveEventParams
  MOV EAX, [EBP + $08]
  MOV EAX, [EAX + $1A]
  MOV DWORD [General.EventParams], EAX
  MOV EAX, [EBP + $0C]
  MOV EAX, [EAX]
  MOV DWORD [General.EventParams + 4], EAX
  XOR EAX, EAX
  MOV DWORD [General.EventParams + 8], EAX
  PUSH General.TRIGGER_BEFORE_HEROINTERACTION
  CALL General.GenerateCustomErmEvent
  MOV EAX, DWORD [General.EventParams + 8]
  PUSH EAX
  CALL General.RestoreEventParams
  POP EAX
  TEST EAX, EAX
  JNZ @@AfterInteraction
  POPAD
  PUSH $4A2476
  RET
@@AfterInteraction:
  CALL General.SaveEventParams
  MOV EAX, [EBP + $08]
  MOV EAX, [EAX + $1A]
  MOV DWORD [General.EventParams], EAX
  MOV EAX, [EBP + $0C]
  MOV EAX, [EAX]
  MOV DWORD [General.EventParams + 4], EAX
  PUSH General.TRIGGER_BEFORE_HEROINTERACTION
  CALL General.GenerateCustomErmEvent
  CALL General.RestoreEventParams
  POPAD
  //
  POP EDI
  POP ESI
  POP EBX
  POP EBP
  RET $10
END; // .PROCEDURE Hook_BeforeHeroesInteraction

PROCEDURE Hook_AfterHeroesInteraction; ASSEMBLER; {$FRAME-}
ASM
  CALL General.SaveEventParams
  MOV EAX, [EBP + $08]
  MOV EAX, [EAX + $1A]
  MOV DWORD [General.EventParams], EAX
  MOV EAX, [EBP + $0C]
  MOV EAX, [EAX]
  MOV DWORD [General.EventParams + 4], EAX
  PUSH General.TRIGGER_AFTER_HEROINTERACTION
  CALL General.GenerateCustomErmEvent
  CALL General.RestoreEventParams
  //
  POP EBX
  POP EBP
  RET $10
END; // .PROCEDURE Hook_AfterHeroesInteraction

{
PROCEDURE InitOptionsHandlers;
VAR
  POptions: General.POptions;

BEGIN
  POptions:=@General.Options[1];
  POptions^[General.C_ERA_OPTION_LOADGAME_QUESTION].Handler:=NIL;
  POptions^[General.C_ERA_OPTION_ERMTIMER_ONOFF].Handler:=@UExports.Option_ErmTimer_OnOff;
  POptions^[General.C_ERA_OPTION_CONFLUXGRAILALLSPELLS_ONOFF].Handler:=@UExports.Option_CorfluxGrailAllSpells_OnOff;
  POptions^[General.C_ERA_OPTION_COLORFUL_DIALOGS].Handler:=NIL;
END; // .procedure InitOptionsHandlers
}
{
(* Процедура сохранения данных ядра Эры в сейве *)
PROCEDURE CoreSaveGame;
BEGIN
  // Сохраняем опции Эры
  ASM
    PUSH General.C_ERA_OPTIONSNUM * 8 // ВНИМАНИЕ! Здесь 8 = SIZEOF (TOption)
    PUSH General.Options
    MOV EAX, General.C_FUNC_ZVS_GZIPWRITE
    CALL EAX
    ADD ESP, 8
  END; // .asm 
END; // .procedure CoreSaveGame

(* Процедура загрузки данных ядра Эры из сейва *)
PROCEDURE CoreLoadGame;
BEGIN
  // Загружаем опции Эры
  ASM
    // Загрузили массив опций с неверными адресами обработчиков
    PUSH General.C_ERA_OPTIONSNUM * 8 // ВНИМАНИЕ! Здесь 8 = SIZEOF (TOption)
    PUSH General.Options
    MOV EAX, General.C_FUNC_ZVS_GZIPREAD
    CALL EAX
    ADD ESP, 8
    // Вернули корректные адреса обработчиков
    CALL InitOptionsHandlers
    // Поочерёдно вызываем обработчики опций
    MOV EAX, General.Options
    MOV ECX, C_ERA_OPTIONSNUM
    @@Loop:
    MOV EDX, [EAX]
    TEST EDX, EDX
    JZ @@DontCall
    PUSHAD
    PUSH DWORD [EAX+4]
    CALL EDX
    POPAD
    @@DontCall:
    ADD EAX, 8 // // ВНИМАНИЕ! Здесь 8 = SIZEOF (TOption)
    DEC ECX
    JNZ @@Loop
  END; // .asm 
END; // .procedure CoreLoadGame
}
PROCEDURE InitEra;
VAR
  POptions: General.POptions;
  Temp: INTEGER; // Временная переменная для патчинга

BEGIN
  IF General.hEra=0 THEN BEGIN
    // Убеждаемся, что DllMain не будет вызвана 1000 и 1 раз из-за тредов
    General.hEra:=Windows.GetModuleHandle(General.C_ERA_DLLNAME);
    Windows.DisableThreadLibraryCalls(General.hEra);
    (* Секция патчинга *)
    // Сперва патчим функцию FindErm, чтобы были разрешены функции с любыми номерами
    Temp:=$EB;
    General.WriteAtCode(Ptr($74A724), @Temp, 1);
    // Патчим функцию ERM_Sound для поддержки новых команд
    General.HookCode(Ptr($774FAA), @Asm_Service, General.C_HOOKTYPE_JUMP, 6);
    (*
    // Патчим внутриигровой цикл для определения, в игре ли мы и установки хука на сообщения окна
    General.HookCode(POINTER($4B0BA1), @Hook_GameLoop_Begin, General.C_HOOKTYPE_JUMP, 5);
    General.HookCode(POINTER($4F051B), @Hook_GameLoop_End, General.C_HOOKTYPE_JUMP, 5);
    *)
    // Патчим вызов триггера !?HE
    (*General.HookCode(POINTER($74D75B), @Hook_HeroesMeet_Call, General.C_HOOKTYPE_JUMP, 5);*)
    General.HookCode(POINTER($4A2470), @Hook_BeforeHeroesInteraction, General.C_HOOKTYPE_JUMP, 6);
    General.HookCode(POINTER($4A2521), @Hook_AfterHeroesInteraction, General.C_HOOKTYPE_JUMP, 5);
    General.HookCode(POINTER($4A2531), @Hook_AfterHeroesInteraction, General.C_HOOKTYPE_JUMP, 5);
    General.HookCode(POINTER($4A257B), @Hook_AfterHeroesInteraction, General.C_HOOKTYPE_JUMP, 5);
    General.HookCode(POINTER($4A25AA), @Hook_AfterHeroesInteraction, General.C_HOOKTYPE_JUMP, 5);
    // Вызываем функции инициализации остальных модулей
    UExports.Init;
    Triggers.Init;
    // Загружаем пользовательские плагины
    LoadPlugins;
    // Реализация динамического патчинга из файлов bin
    DinamicPatching;
    {
    // Инициализируем массив опций Эры
    SetLength(General.Options, General.C_ERA_OPTIONSNUM * SIZEOF(General.TOption));
    POptions:=@General.Options[1];
    InitOptionsHandlers;
    POptions^[General.C_ERA_OPTION_LOADGAME_QUESTION].Value:=TRUE;
    POptions^[General.C_ERA_OPTION_ERMTIMER_ONOFF].Value:=TRUE;
    POptions^[General.C_ERA_OPTION_CONFLUXGRAILALLSPELLS_ONOFF].Value:=TRUE;
    POptions^[General.C_ERA_OPTION_COLORFUL_DIALOGS].Value:=FALSE;
    // Устанавливаем свои обработчики сохранения и загрузки данных в сейвах
    General.CustomSaveGameHandler:=@CoreSaveGame;
    General.CustomLoadGameHandler:=@CoreLoadGame;
    }
  END; // .if 
END; // .procedure InitEra


BEGIN
  InitEra; // Инициализируем фреймворк Эры
END.
