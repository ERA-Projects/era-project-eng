////////////////////////////////////////////////////////////////////////////////////////////////////////////
// библиоотека patcher_x86.dll 
// распространяется свободно(бесплатно)
// авторское право: Баринов Александр (baratorch), e-mail: baratorch@yandex.ru
// форма реализации низкоуровневых хуков (LoHook) отчасти позаимствована у Berserker (из ERA)
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ОПИСАНИЕ.
//
// ! библиотека предоставляет:
//		- удобные унифицированные централизованные 
//		  инструменты для установки патчей и хуков
//		  в код целевой программы.
//		- дополнительные инструменты: дизассемблер длин опкодов и функцию
//		  копирующую код с корректным переносом опкодов jmp и call c 
//		  относительной адресацией
// ! библиотека позволяет
//		- устанавливать как простые так и сложные патчи.
//		  с методами по установке сложных патчей почти так же удобно работать
//		  как с ассемблером (пока не хватает только меток и прыжкам к меткам)
//		- устанавливать высокоуровневые хуки, замещая оригинальные функции в
//		  в целевом коде на свои, не заботясь о регистрах процессора,
//		  стеке, и возврате в оригинальный код.
//		- устанавливать высокоуровневые хуки один на другой
//		  не исключая а дополняя при этом функциональность хуков
//		  установленных раньше последнего, тем самым реализуется идеология сабклассинга
//		- устанавливать низкоуровневые хуки с высокоуровневым доступом к
//		  регистрам процессора, затертому коду и адресу возврата в код
//		- отменять любой патч и хук, установленный с помощью этой библиотеки.
//		- узнать задействован ли определенный мод, использующий библиотеку
//		- узнать какой мод (использующий библиотеку) установил определенный патч/хук
//		- получить полный доступ ко всем патчам/хукам, установленным из других модов 
//		  с помощью этой библиотеки
//		- легко и быстро обнаружить конфликтующие патчи из разных модов
//		  (использующих эту библиотеку) 1) отмечаяв логе такие конфликты как:
//								- устанавливаются патчи/хуки разного размера на один адрес
//								- устанавливаются патчи/хуки перекрывающие один другого со смещением
//								- устанавливаются патчи поверх хуков и наоборот
//		  а так же 2) давая возможность посмотреть дамп (общий листинг) всех патчей 
//		  и хуков установленных с помощью этой библиотеки в конкретный момент времени.
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ЛОГИРОВАНИЕ.
//
// по умолчанию в patcher_x86.dll логирование отключено, чтобы включить его,
// необходимо в той же папке создать файл patcher_x86.ini c единственной
// записью: Logging on = 1 (Logging on = 0 - отключает логирование снова)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ПРАВИЛА ИСПОЛЬЗОВАНИЯ.
//
// 1) каждый мод должен 1 раз вызвать функцию GetPatcher(), сохранив результат
//		например: Patcher* _P = GetPatcher();
// 2) затем с помощью метода Pather::CreateInstance нужно создать  
// экземпляр PatсherInstance со своим уникальным именем
//		например:	PatсherInstance* _PI = _P->CreateInstance("HD");
//		или:		PatсherInstance* _PI = _P->CreateInstance("HotA");
// 3)  затем использовать методы классов Patсher и PatсherInstance
// непосредственно для работы с патчами и хуками
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

unit PatchApi;

interface

const

// значения возвращаемые функцией срабатываемой по LoHook хуку
  EXEC_DEFAULT    = true;
  NO_EXEC_DEFAULT = false;


// значения возвращаеемые Patch::GetType()
  PATCH_  = 0;
  LOHOOK_ = 1;
  HIHOOK_ = 2;

// значения передаваемые как аргумент hooktype в TPatcherInstance.WriteHiHook и TPatcherInstance.CreateHiHook
  CALL_   = 0;
  SPLICE_ = 1;
  FUNCPTR_= 2;

// значения передаваемые как аргумент subtype в TPatcherInstance.WriteHiHook и TPatcherInstance.CreateHiHook
  DIRECT_  = 0;
  EXTENDED_= 1;
  SAFE_    = 2;

// значения передаваемые как аргумент calltype в TPatcherInstance.WriteHiHook и TPatcherInstance.CreateHiHook
  ANY_     = 0;
  STDCALL_ = 0;
  THISCALL_= 1;
  FASTCALL_= 2;
  CDECL_   = 3;

  FASTCALL_1 = 1;

  NULL_PTR = nil;

type
  _dword_ = cardinal;

// все адреса и часть указателей определены этим типом,
// если вам удобнее по-другому, можете заменить _ptr_
// на любой другой четырехбайтовый тип: pointer или integer например
  _ptr_ = pointer;

// Структура HookContext
// используется в функциях сработавших по LoHook хуку
  THookContext = packed record
    eax: integer;
    ecx: integer;
	  edx: integer;
	  ebx: integer;
	  esp: integer;
	  ebp: integer;
	  esi: integer;
	  edi: integer;
 	  RetAddr: _ptr_;
  end;
  PHookContext = ^THookContext;

// Абстрактный класс TPatch
// создать экземпляр можно с помощью методов класса TPatcherInstance
  TPatch = packed class

	// возвращает адрес по которому устанавливается патч
    function GetAddress: integer; virtual; stdcall; abstract;

	// возвращает размер патча
    function GetSize: cardinal; virtual; stdcall; abstract;

	// возвращает уникальное имя экземпляра TPatcherInstance, с помощью которого был создан патч
    function GetOwner: PAnsiChar; virtual; stdcall; abstract;

	// возвращает тип патча
	// для не хука всегда PATCH_
	// для TLoHook всегда LOHOOK_
	// для THiHook всегда HIHOOK_
    function GetType: integer; virtual; stdcall; abstract;

	// возвращает true, если патч применен и false, если нет.
    function IsApplied: boolean; virtual; stdcall; abstract;


	// применяет патч 
	// возвращает >= 0 , если патч/хук применился успешно
	// (возвращаемое значение является порядковым номером патча в последовательности
	// патчей, примененных по данному адресу, чем больше число, 
	// тем позднее был применен патч)
	// возвращает -1, если нет (в версии 1.1 патч применяется всегда успешно)
	// возвращает -2, если патч уже применен
	// Результат выполнения метода распространенно пишется в лог
	// В случаях конфликтного применения (см. конец ОПИСАНИЯ библиотеки выше)
	// ранее примененный патч  (с которым так или иначе конфликтует этот) отмечается как 
	// неотменяемый (FIXED), и в лог пишется предупреждение о конфликте.
    function Apply: boolean; virtual; stdcall; abstract;

  // ApplyInsert применяет патч с указанием порядкового номера в
	// последовательности патчей, примененных по этому адресу.
	// возвращаемые значения аналогичны соответсвующим в TPatch.Apply
	// Внимание! Применить патч перед FIXED патчем нельзя, поэтому 
	// возвращаемый порядковый номер может отличаться от желаемого, переданного параметром.
	// функции ApplyInsert можно аргументом передать значение, возвращаемое 
	// функцией Undo, чтобы применить патч в то же место, на котором тот был до отменения.
    function ApplyInsert(ZOrder: integer): boolean; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// Метод Undo
	// Отменяет патч/хук (в случае если патч применен последним - восстанавливает затертый код)
	// Возвращает число >= 0, если патч/хук был отменен успешно
	// (возвращаемое значение является номером патча в последовательности
	// патчей, примененных по данному адресу, чем больше число, 
	// тем позднее был применен патч)
	// Возвращает -2, если патч и так уже был отменен (не был применен)
	// Возвращает -3, если патч является неотменяемым (FIXED) (см. метод Apply)
	// Результат выполнения метода распространенно пишется в лог
    function Undo: integer; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// Метод Destroy
	// Деструктор
	// Безвозвратно уничтожает патч/хук
	// Уничтожить можно только отмененный патч/хук.
	// возвращает 1, если патч(хук) уничтожен успешно
	// возвращает 0, если патч не уничтожен
	// Результат уничтожения распространенно пишется в лог
    function _Destroy: integer; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// Метод GetAppliedBefore
	// возвращает патч примененный перед данным
	// возвращает nil если данный патч применен первым
    function GetAppliedBefore: TPatch; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// Метод GetAppliedAfter
	// возвращает патч примененный после данного
	// возвращает nil если данный патч применен последним
    function GetAppliedAfter: TPatch; virtual; stdcall; abstract;
  end;

// Абстрактный класс TLoHook (унаследован от TPatch, т.е. по сути лоу-хук является патчем)
// создать экземпляр можно с  помощью методов класса TPatcherInstance
  TLoHook = packed class(TPatch)
  end;

// Абстрактный класс THiHook (унаследован от TPatch, т.е. по сути хай-хук является патчем)
// создать экземпляр можно с помощью методов класса TPatcherInstance
  THiHook = packed class(TPatch)

	// возвращает указатель на функцию (на мост к функции в случае SPLICE_),
	// замещенную хуком
	// Внимание! Вызывая функцию для не примененного хука, можно получить
	// неактуальное (но рабочее) значение.
	  function GetDefaultFunc: _ptr_; virtual; stdcall; abstract;

	// возвращает указатель на оригинальную функцию (на мост к функции в случае SPLICE_),
	// замещенную хуком(хуками) по данному адресу
	// (т.е. возвращает GetDefaultFunc() для первого примененного хука по данному адресу)
	// Внимание! Вызывая функцию для не примененного хука, можно получить
	// неактуальное (но рабочее) значение.
	  function GetOriginalFunc: _ptr_; virtual; stdcall; abstract;

	// возвращает адрес возврата в оригинальный код
	// можно использовать внутри хук-функции
	// SPLICE_ хука, чтобы узнать откуда она была вызвана
	  function GetReturnAddress: _ptr_; virtual; stdcall; abstract;
  end;

// Абстрактный класс TPatcherInstance
// создать/получить экземпляр можно с помощью методов CreateInstance и GetInstance класса TPatcher
// непосредственно позволяет создавать/устанавливать патчи и хуки в код,
// добавляя их в дерево всех патчей/хуков, созданных библиотекой patcher_x86.dll
  TPatcherInstance = packed class

	////////////////////////////////////////////////////////////
	// Метод WriteByte
	// пишет однбайтовое число по адресу address
	// (создает и применяет DATA_ патч)
	// Возвращает патч
	  function WriteByte(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteWord
	// пишет двухбайтовое число по адресу address
	// (создает и применяет DATA_ патч)
	// Возвращает патч
	  function WriteWord(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteDword
	// пишет четырехбайтовое число по адресу address
	// (создает и применяет DATA_ патч)
	// Возвращает патч
	  function WriteDword(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteJmp
	// пишет jmp to_address опкод по адресу address
	// (создает и применяет CODE_ патч)
	// Возвращает патч
	// патч закрывает целое количество опкодов,
	// т.е. размер патча >= 5, разница заполнятеся NOP'ами. 
	  function WriteJmp(address, to_address: _ptr_): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteHexPatch
	// пишет по адресу address позледовательность байт,
	// определенную hex_cstr
	// (создает и применяет DATA_ патч)
	// Возвращает патч
	// hex_str - си-строка может содержать шестнадцатеричные цифры
	// 0123456789ABCDEF (только верхний регистр!) остальные символы 
	// при чтении методом hex_str игнорируются(пропускаются)
	// удобно использовать в качестве аргумента этого метода
	// скопированное с помощью Binary copy в OllyDbg
	{ пример:
			_PI.WriteHexPatch(0x57b521, PChar('6A 01  6A 00'));
	}
	  function WriteHexPatch(address: _ptr_; hex_cstr: PAnsiChar): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteCodePatchVA
	// в оригинальном виде применение метода не предполагается,
	// смотрите (ниже) описание метода-оболочки WriteCodePatch
	  function WriteCodePatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteLoHook
	// создает по адресу address низкоуровневый хук (CODE_ патч) и применяет его
	// возвращает хук
	// func - указатель на функцию вызываемаю при срабатывании хука
	// должна иметь вид func(h: TLoHook; c: PHookContext): integer; stdcall;
	// в c: PHookContext передаются для чтения/изменения
	// регистры процессора и адрес возврата
	// если func возвращает EXEC_DEFAULT, то 
	// после завершения func выполняется затертый хуком код.
	// если - NO_EXEC_DEFAULT - затертый код не выполняется
	  function WriteLoHook(address: _ptr_; func: pointer): TLoHook; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод WriteHiHook
	// создает по адресу address высокоуровневый хук и применяет его
	// возвращает хук
	//
	// new_func - функция замещающая оригинальную
	//
	// hooktype - тип хука:
	//		CALL_ -		хук НА ВЫЗОВ функции по адресу address
	//					поддерживаются опкоды E8 и FF 15, в остальных случаях хук не устанавливается
	//					и в лог пишется информация об этой ошибке
	//		SPLICE_ -	хук непосредственно НА САМУ ФУНКЦИЮ по адресу address
	//		FUNCPTR_ -	хук на функцию в указателе (применяется редко, в основном для хуков в таблицах импорта)
	//
	// subtype - подтип хука:
	//		DIRECT_ - применение в паскале/делфи не предполагается
	//		EXTENDED_ - функции new_func первым стековым аргументом передается
	//					экземпляр THiHook и, в случае
	//					соглашений исходной ф-ии __thiscall и __fastcall
	//					регистровые аргументы передаются стековыми вторыми 
	//
	// Таким образом для EXTENDED_ хука (orig - замещаемая ф-ия):
	//	если					int __stdcall orig(?)	то	new_func(h: THiHook; ?): integer; stdcall;
	//	если		 int __thiscall orig(int this, ?)	то	new_func(h: THiHook; this_: integer; ?): integer; stdcall;
	//	если   int __fastcall orig(int a1, int a2, ?)	то	new_func(h: THiHook; a1, a2: integer; ?): integer; stdcall;
	//	если					  int __cdecl orig(?)	то	new_func(h: THiHook; ?): integer; cdecl;
	//
	//	ВНИМАНИЕ! EXTENDED_ FASTCALL_ поддерживает только функции с 2-мя и более аргументами
	//	для __fastcall c 1 аргументом используйте EXTENDED_ FASTCALL_1 / EXTENDED_ THISCALL_
	//
	// 		SAFE_ - то же самое что и EXTENDED_, однако перед вызовом GetDefaultFunc() восстанавливаются
	//				значения регистров процессора EAX, ECX (если не FASTCALL_ и не THISCALL_),
	//				EDX (если не FASTCALL_), EBX, ESI, EDI, бывшие на момент вызова замещенной функции
	//
	// calltype - соглашение о вызове оригинальной замещаемой ф-ии:
	//		STDCALL_
	//		THISCALL_
	//		FASTCALL_
	//		CDECL_
	// необходимо верно указывать соглашение для того чтобы EXTENDED_ хук правильно
	// построил мост к новой замещающей функции
	//
	// CALL_, SPLICE_ хук является CODE_ патчем
	// FUNCPTR_ хук является DATA_ патчем
  //
	  function WriteHiHook(address: _ptr_; hooktype, subtype, calltype: integer; new_func: pointer): THiHook; virtual; stdcall; abstract;

	///////////////////////////////////////////////////////////////////
	// Методы Create...
	// создают патч/хук так же как и соответствующие методы Write...,
	// но НЕ ПРИМЕНЯЮТ его
	// возвращают патч/хук
	  function CreateBytePatch(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;
	  function CreateWordPatch(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;
	  function CreateDwordPatch(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;
	  function CreateJmpPatch(address, to_address: _ptr_): TPatch; virtual; stdcall; abstract;
	  function CreateHexPatch(address: _ptr_; hex_str: PAnsiChar): TPatch; virtual; stdcall; abstract;
	  function CreateCodePatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;
	  function CreateLoHook(address: _ptr_; func: pointer): TLoHook; virtual; stdcall; abstract;
	  function CreateHiHook(address: _ptr_; hooktype, subtype, calltype: integer; new_func: pointer): THiHook; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод ApplyAll
	// применяет все патчи/хуки, созданные этим экземпляром TPatcherInstance
	// возвращает TRUE если все патчи/хуки применились успешно
	// возвращает FALSE если хотя бы один патч/хук не был применен
	// (см. TPatch.Apply)
	  function ApplyAll: boolean; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод UndoAll
	// отменяет все патчи/хуки, созданные этим экземпляром PatcherInstance
	// т.е. для каждого из патчей/хуков вызывает метод Undo
	// возвращает FALSE, если хотя бы один патч/хук невозможно отменить (является неотменяемым (FIXED))
	// иначе возвращает TRUE
	  function UndoAll: boolean; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// Метод DestroyAll
	// уничтожает все патчи/хуки, созданные этим экземпляром PatcherInstance
	// т.е. для каждого из патчей/хуков вызывает метод Destroy
	// возвращает FALSE, если хотя бы один патч/хук невозможно уничтожить (является примененным)
	// иначе возвращает TRUE
	  function DestroyAll: boolean; virtual; stdcall; abstract;

	// в оригинальном виде применение метода не предполагается,
	// смотрите (ниже) описание метода-оболочки WriteDataPatch
	  function WriteDataPatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;

 	// в оригинальном виде применение метода не предполагается,
	// смотрите (ниже) описание метода-оболочки CreateDataPatch
	  function CreateDataPatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;

	// Метод GetLastPatchAt
	// возвращает NULL, если по адресу address не был применен ни один патч/хук,
	// созданный данным экземпляром PatcherInstance
	// иначе возвращает последний примененый патч/хук по адресу address,
	// созданный данным экземпляром PatcherInstance
   	function GetLastPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;

	// Метод UndoAllAt
	// отменяет патчи примененные данным экземпляром PatcherInstance
	// по адресу address 
	// возвращает TRUE, если все патчи успешно отменены,
	// иначе возвращает FALSE
   	function UndoAllAt(address: _ptr_): boolean; virtual; stdcall; abstract;

	// Метод GetFirstPatchAt
	// возвращает NULL, если по адресу address не был применен ни один патч/хук,
	// созданный данным экземпляром PatcherInstance
	// иначе возвращает первый примененый патч/хук по адресу address,
	// созданный данным экземпляром PatcherInstance
        function GetFirstPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;



	// Метод Write
	// пишет по адресу address данные/код из памяти по адресу data размером size байт 
	// если is_code == true, то создается и пишется CODE_ патч, иначе - DATA_ патч.
	// Возвращает патч
	function Write(address: _ptr_; data: _ptr_; size: _dword_; is_code: boolean): TPatch; virtual; stdcall; abstract;

	// Метод CreatePatch
	// создаёт патч так же как и метод Write,
	// но НЕ ПРИМЕНЯЕТ его
	// возвращает патч
	function CreatePatch(address: _ptr_; data: _ptr_; size: _dword_; is_code: boolean): TPatch; virtual; stdcall; abstract;


	////////////////////////////////////////////////////////////
	// Метод WriteCodePatch
	// пишет по адресу address позледовательность байт,
	// определенную args
	// (создает и применяет патч)
	// Возвращает патч
	// первый элемент args (должен быть обязательно!) - строка, может содержать шестнадцатеричные цифры
	// 0123456789ABCDEF (только верхний регистр!),
	// а так же специальные формат-символы (нижний регистр!):
	// %b - пишет однобайтовое число из args
	// %w - пишет двухбайтовое число из args
	// %d - пишет четырехбайтовое число из args
	// %j - пишет jmp на адрес из args
	// %с - пишет сall args
	// %m - копирует код по адресу args размером args (т.е. читает 2 аргумента из args)
  //      копирование происходит посредством функции MemCopyCodeEx.
	// %% - пишет строку с формат-символами из args
	// %o - (offset) помещает по адресу из аргумента смещение позиции в
	//      Complex коде,  относительно начала Complex кода.
	// %n - пишет nop опкоды, количеством из  args
// #0: - #9: -устанавливает метку (от 0 до 9) к которой можно перейти с помощью #0 - #9                              \
// #0 -  #9  -пишет отностельный адрес после опкодов EB, 70 - 7F, E8, E9, 0F80 - 0F8F
	//      соответствующей метки; после других опкодов ничего не пишет
	// ~b - берет из args абсолютный адрес и пишет относительное смещение до него
	//      размером в 1 байт (используется для опкодов EB, 70 - 7F)
	// ~d - берет из args абсолютный адрес и пишет относительное смещение до него
	//      размером в 4 байта (используется для опкодов E8, E9, 0F 80 - 0F 8F)
	// %. - ничего не делает ( как и любой другой не объявленный выше символ после % )
	// абстрактный пример:
	//	patch := _PI.WriteCodePatch(address, [
	//		'#0: %%',
	//		'B9 %d %%', this,					// mov ecx, this  //
	//		'BA %d %%', this.context,			// mov edx, this.context  //
	//		'%c %%', @func,						// call func  //
	//		'83 F8 01 %%',						// cmp eax, 1
	//		'0F 85 #7 %%', 						// jne long to label 7 (if func returns 0)
	//		'83 F8 02 %%',						// cmp eax, 2
	//		'0F 85 ~d %%', 0x445544,			// jne long to 0x445544
	//		'EB #0 %%',							// jmp short to label 0
	//		'%m %%', address2, size,	// exec  code copy from address2
	//		'#7: FF 25 %d %.', @return_address ] );	// jmp [@return_address]
   	function WriteCodePatch(address: _ptr_; const args: array of const): TPatch; stdcall;

	////////////////////////////////////////////////////////////
	// Метод CreateCodePatch
	// создает патч так же как и метод WriteCodePatch,
	// но не применяет его
	// возвращаeт патч
   	function CreateCodePatch(address: _ptr_; const args: array of const): TPatch; stdcall;

	////////////////////////////////////////////////////////////
	// Метод WriteDataPatch
	// пишет по адресу address позледовательность байт,
	// определенную args
	// (создает и применяет патч)
	// Возвращает патч
	// первый элемент args (должен быть обязательно!) - строка, может содержать шестнадцатеричные цифры
	// 0123456789ABCDEF (только верхний регистр!),
	// а так же специальные формат-символы (нижний регистр!):
	// %b - пишет однобайтовое число из args
	// %w - пишет двухбайтовое число из args
	// %d - пишет четырехбайтовое число из args
	// %m - копирует данные по адресу args размером args (т.е. читает 2 аргумента из args)
	// %% - пишет строку с формат-символами из args
	// %o - (offset) помещает по адресу из аргумента смещение позиции в
	//      Complex коде,  относительно начала Complex кода.
	// %. - ничего не делает ( как и любой другой не объявленный выше символ после % )
	// абстрактный пример:
	//	patch := _PI.WriteCodePatch(address, [
	//		'FF FF %d %%', var,					// mov ecx, this  //
	//		'%m %%', address2, size,	// exec  code copy from address2
	//		'AE %.' ] );	// jmp [@return_address]
   	function WriteDataPatch(address: _ptr_; const args: array of const): TPatch; stdcall;

	////////////////////////////////////////////////////////////
	// Метод CreateDataPatch
	// создает патч так же как и метод WriteDataPatch,
	// но не применяет его
	// возвращаeт патч
   	function CreateDataPatch(address: _ptr_; const args: array of const): TPatch; stdcall;

  end;

// Класс TPatcher
  TPatcher = packed class

	// основные методы:

	///////////////////////////////////////////////////
	// Метод CreateInstance
	// создает экземпляр класса TPatcherInstance, который
	// непосредственно позволяет создавать патчи и хуки и
	// возвращает этот экземпляр.
	// owner - уникальное имя экземпляра TPatcherInstance
	// метод возвращает nil, если экземпляр с именем owner уже создан
	// если owner = nil или owner = '' то
	// экземпляр PatcherInstance будет создан с именем модуля из
	// которого была вызвана функция.
   	function CreateInstance(owner_name: PAnsiChar): TPatcherInstance; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// Метод GetInstance
	// Возвращает экземпляр TPatcherInstance
	// с именем owner.
	// в качестве аргумента можно передавать имя модуля.
	// метод возвращает nil в случае, если
	// экземпляр с именем owner не существует (не был создан)
	// Используется для :
	// - проверки активен ли некоторый мод, использующий patcher_x86.dll
	// - получения доступа ко всем патчам и хукам
	//    некоторого мода, использующего patcher_x86.dll
   	function GetInstance(owner_name: PAnsiChar): TPatcherInstance; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// Метод GetLastPatchAt
	// возвращает nil, если по адресу address не был применен ни один патч/хук
	// иначе возвращает последний примененый патч/хук по адресу address
	// последовательно пройтись по всем патчам по заданному адресу можно 
	// используя этот метод и TPatch.GetAppliedBefore
   	function GetLastPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// Метод UndoAllAt
	// отменяет все патчи/хуки по адресу address
	// возвращает FALSE, если хотя бы 1 патч/хук не получилось отменить (см. Patch::Undo)
	// иначе возвращает TRUE
  	function UndoAllAt(address: _ptr_): boolean; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// Метод SaveDump
	// сохраняет в файл с именем file_name
	// - количество и имена всех экземпляров TPatcherInstance
	// - количество всех примененных патчей/хуков
	// - список всех примененных патчей и хуков
	  procedure SaveDump(file_name: PAnsiChar); virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// Метод SaveLog
	// сохраняет в файл с именем file_name лог 
	  procedure SaveLog(file_name: PAnsiChar); virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// Метод GetMaxPatchSize
	// Библиотека patcher_x86.dll накладывает некоторые ограничения
	// на максимальный размер патча,
	// какой - можно узнать с помощью метода GetMaxPatchSize
	// (на данный момент это 8192 байт, т.е. дохрена :) )
   	function GetMaxPatchSize: integer; virtual; stdcall; abstract;

	// дополнительные методы:

	///////////////////////////////////////////////////
	// Метод WriteComplexDataVA
	// в оригинальном виде применение метода не предполагается,
	// смотрите (ниже) описание метода-оболочки WriteComplexString
   	function WriteComplexDataVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): integer; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// метод GetOpcodeLength
	// т.н. дизассемблер длин опкодов
	// возвращает длину в байтах опкода по адресу p_opcode
	// возвращает 0, если опкод неизвестен
   	function GetOpcodeLength(p_opcode: pointer): integer; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// метод MemCopyCode
	// копирует код из памяти по адресу src в память по адресу dst
	// MemCopyCode копирует всегда целое количество опкодов размером >= size. Будьте внимательны!
	// возвращает размер скопированного кода.
	// отличается действием от простого копирования памяти тем,
	// что корректно копирует опкоды E8 (call), E9 (jmp long), 0F80 - 0F8F (j** long)
	// c относительной адресацией не сбивая в них адреса, если инструкции 
	// направляют за пределы копируемого блокая.
    procedure MemCopyCode(dst, src: pointer; size: cardinal); virtual; stdcall; abstract;


	///////////////////////////////////////////////////
	// Метод GetFirstPatchAt
	// возвращает nil, если по адресу address не был применен ни один патч/хук
	// иначе возвращает первый примененый патч/хук по адресу address
	// последовательно пройтись по всем патчам по заданному адресу можно 
	// используя этот метод и Patch::GetAppliedAfter
    function GetFirstPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// метод MemCopyCodeEx
	// копирует код из памяти по адресу src в память по адресу dst
	// возвращает размер скопированного кода.
	// отличается от MemCopyCode тем,
	// что корректно копирует опкоды EB (jmp short), 70 - 7F (j** short)
	// c относительной адресацией не сбивая в них адреса, если инструкции 
	// направляют за пределы копируемого блокая (в этом случае они заменяются на
	// соответствующие E9 (jmp long), 0F80 - 0F8F (j** long) опкоды.
	// Внимание! Из-за этого размер скопированного кода может оказаться значительно 
	// больше копируемого.
    function MemCopyCodeEx(dst, src: pointer; size: cardinal): integer; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////////////
	// метод WriteComplexData
	// является более удобным интерфейсом  
	// метода WriteComplexDataVA
	// этот метод определен здесь а не в библиотеке, т.к. его вид 
	// отличается в Си и Делфи
	// Функционал метода почти тот же что и у TPatcherInstance.WriteCodePatch
	// (см. описание этого метода)
	// то есть метод пишет по адресу address, последовательность байт,
	// определенную аргументами args,
	// НО! НЕ создает экземпляр класса TPatch, со всеми вытекающими (т.е. не позволяя отменить правку, получить доступ к правке из другого мода и т.д.)
	// ВНИМАНИЕ!
	// Используйте этот метод только для динамического создания блоков
	// кода, т.е. пишите этим методом только в свою память,
	// а в код модифицируемой программы только с помощью
	// TPatcherInstance.WriteCodePatch / TPatcherInstance.WriteDataPatch
   	function WriteComplexData(address: _ptr_; const args: array of const): integer; stdcall;

  end;

//функция GetPatcher
//загружает библиотеку и, с помощью вызова единственной экспортируемой
//функции _GetPatcherX86@0, возвращает экземпляр класса TPatcher,
//посредством которого доступен весь функционал библиотеки patcher_x86.dll
//возвращает nil при неудаче
//функцию вызывать 1 раз, что очевидно из ее определения
  function GetPatcher: TPatcher; stdcall;

// функция Call позволет вызывать произвольную функцию по определенному адресу
//используется в том числе для вызова функций
//полученных с помощью THiHook.GetDefaultFunc и THiHook.GetOriginalFunc
  function Call(calltype: integer; address: _ptr_; const args: array of const): _dword_; stdcall;


implementation

uses Windows;

type
  TDwordArgs = array [0..24] of DWORD;

// функция преобразует array of const в array of _dword_ для функций, принимающих произвольное кол-во
// аргументов разных типов
  procedure __MoveToDwordArgs(const args: array of const; var dword_args: TDwordArgs);
  var
    i: integer;
  begin
    for i := 0 to High(args) do begin
      with args[i] do begin
        case VType of
          vtInteger:       dword_args[i] := _dword_(VInteger);
          vtBoolean:       dword_args[i] := _dword_(VBoolean);
          vtChar:          dword_args[i] := _dword_(VChar);
          vtPChar:         dword_args[i] := _dword_(PAnsiChar(VPChar));
          vtPointer:       dword_args[i] := _dword_(VPointer);
          vtString:        dword_args[i] := _dword_(PAnsiChar(AnsiString(VString^ + #0)));
          vtAnsiString:    dword_args[i] := _dword_(PAnsiChar(VAnsiString));
          //vtUnicodeString: dword_args[i] := _dword_(PAnsiChar(AnsiString(VUnicodeString)));
          //vtVariant:
        else
          asm int 3 end;
        end;
      end;
    end;
  end;

  function CALL_CDECL(address: _ptr_; var dword_args: TDwordArgs; args_count: integer): _dword_;
  var
    r: _dword_;
    d_esp: integer;
    parg: _ptr_;
  begin
    if args_count > 0 then parg := _ptr_(@dword_args[args_count-1]);
    d_esp := args_count * 4;
   asm
      pushad
      mov edi, parg
      mov esi, args_count
   @loop_start:
      cmp esi, 1
      jl @loop_end
      push [edi]
      sub edi, 4
      Dec esi
      jmp @loop_start
   @loop_end:
      mov eax, address
      call eax
      mov r, eax
      add esp, d_esp
      popad
    end;
    result := r;
  end;

  function CALL_STD(address: _ptr_; var dword_args: TDwordArgs; args_count: integer): _dword_;
  var
    r: _dword_;
    parg: _ptr_;
  begin
    if args_count > 0 then parg := _ptr_(@dword_args[args_count-1]);

    asm
      pushad
      mov edi, parg
      mov esi, args_count
    @loop_start:
      cmp esi, 1
      jl @loop_end
      push [edi]
      sub edi, 4
      Dec esi
      jmp @loop_start
    @loop_end:
      mov eax, address
      call eax
      mov r, eax
      popad
    end;

    result := r;
  end;

  function CALL_THIS(address: _ptr_; var dword_args: TDwordArgs; args_count: integer): _dword_;
  var
    r, ecx_arg: _dword_;
    stack_args_count: integer;
    parg: _ptr_;
  begin
    stack_args_count := args_count - 1;

    if args_count > 0 then begin
      ecx_arg := dword_args[0];
      parg := _ptr_(@dword_args[args_count-1]);
    end
    else begin
      asm int 3 end;
    end;

    asm
      pushad
      mov edi, parg
      mov esi, stack_args_count
    @loop_start:
      cmp esi, 1
      jl @loop_end
      push [edi]
      sub edi, 4
      Dec esi
      jmp @loop_start
    @loop_end:
      mov ecx, ecx_arg
      mov eax, address
      call eax
      mov r, eax
      popad
    end;

    result := r;
  end;

  function CALL_FAST(address: _ptr_; var dword_args: TDwordArgs; args_count: integer): _dword_;
  var
    r, ecx_arg, edx_arg: _dword_;
    stack_args_count: integer;
    parg: _ptr_;
  begin
    stack_args_count := args_count - 2;

    if args_count > 1 then begin
      ecx_arg := dword_args[0];
      edx_arg := dword_args[1];
      parg := _ptr_(@dword_args[args_count-1]);
    end
    else begin
      result := CALL_THIS(address, dword_args, args_count);
      exit;
    end;

    asm
      pushad
      mov edi, parg
      mov esi, stack_args_count
    @loop_start:
      cmp esi, 1
      jl @loop_end
      push [edi]
      sub edi, 4
      Dec esi
      jmp @loop_start
    @loop_end:
      mov ecx, ecx_arg
      mov edx, edx_arg
      mov eax, address
      call eax
      mov r, eax
      popad
    end;

    result := r;
  end;

  function Call(calltype: integer; address: _ptr_; const args: array of const): _dword_;
  var
    dword_args: TDwordArgs; 
  
  begin
    __MoveToDWordArgs(args, dword_args);
    
    case calltype of
      CDECL_   : result := CALL_CDECL(address, dword_args, Length(args));
      STDCALL_ : result := CALL_STD(address, dword_args, Length(args));
      THISCALL_: result := CALL_THIS(address, dword_args, Length(args));
      FASTCALL_: result := CALL_FAST(address, dword_args, Length(args));
    else
      result := 0;
      asm int 3 end;
    end;
  end;


  function TPatcherInstance.WriteCodePatch(address: _ptr_; const args: array of const): TPatch;
  var
    dword_args: TDwordArgs;
  
  begin
    __MoveToDwordArgs(args, dword_args);
    result := WriteCodePatchVA(address, PAnsiChar(dword_args[0]), _ptr_(@dword_args[1]));
  end;

  function TPatcherInstance.CreateCodePatch(address: _ptr_; const args: array of const): TPatch;
  var
    dword_args: TDwordArgs;
  
  begin
    __MoveToDwordArgs(args, dword_args);
    result := CreateCodePatchVA(address, PAnsiChar(dword_args[0]), _ptr_(@dword_args[1]));
  end;


  function TPatcherInstance.WriteDataPatch(address: _ptr_; const args: array of const): TPatch;
  var
    dword_args: TDwordArgs;
  
  begin
    __MoveToDwordArgs(args, dword_args);
    result := WriteDataPatchVA(address, PAnsiChar(dword_args[0]), _ptr_(@dword_args[1]));
  end;

  function TPatcherInstance.CreateDataPatch(address: _ptr_; const args: array of const): TPatch;
  var
    dword_args: TDwordArgs;
  
  begin
    __MoveToDwordArgs(args, dword_args);
    result := CreateDataPatchVA(address, PAnsiChar(dword_args[0]), _ptr_(@dword_args[1]));
  end;


  function TPatcher.WriteComplexData(address: _ptr_; const args: array of const): integer;
  var
    dword_args: TDwordArgs;
  
  begin
    __MoveToDwordArgs(args, dword_args);
    result := WriteComplexDataVA(address, PAnsiChar(dword_args[0]), _ptr_(@dword_args[1]));
  end;

  var
    PatcherPtr: TPatcher = nil;
  
  function GetPatcher: TPatcher;
  var
    dll: cardinal;
    func: _ptr_;
  begin
    result := PatcherPtr;
  
    if result = nil then begin
      dll := Windows.LoadLibrary('patcher_x86.dll');
      {!} Assert(dll <> 0);
      func := _ptr_(Windows.GetProcAddress(dll, '_GetPatcherX86@0'));
      {!} Assert(func <> NULL_PTR);
      result := TPatcher(Call(STDCALL_, func, []));
      {!} Assert(result <> nil);
    end;
  end;

end.
