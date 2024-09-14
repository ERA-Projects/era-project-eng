////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ����������� patcher_x86.dll 
// ���������������� ��������(���������)
// ��������� �����: ������� ��������� (baratorch), e-mail: baratorch@yandex.ru
// ����� ���������� �������������� ����� (LoHook) ������� �������������� � Berserker (�� ERA)
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ��������.
//
// ! ���������� �������������:
//		- ������� ��������������� ���������������� 
//		  ����������� ��� ��������� ������ � �����
//		  � ��� ������� ���������.
//		- �������������� �����������: ������������ ���� ������� � �������
//		  ���������� ��� � ���������� ��������� ������� jmp � call c 
//		  ������������� ����������
// ! ���������� ���������
//		- ������������� ��� ������� ��� � ������� �����.
//		  � �������� �� ��������� ������� ������ ����� ��� �� ������ ��������
//		  ��� � ����������� (���� �� ������� ������ ����� � ������� � ������)
//		- ������������� ��������������� ����, ������� ������������ ������� �
//		  � ������� ���� �� ����, �� �������� � ��������� ����������,
//		  �����, � �������� � ������������ ���.
//		- ������������� ��������������� ���� ���� �� ������
//		  �� �������� � �������� ��� ���� ���������������� �����
//		  ������������� ������ ����������, ��� ����� ����������� ��������� ������������
//		- ������������� �������������� ���� � ��������������� �������� �
//		  ��������� ����������, ��������� ���� � ������ �������� � ���
//		- �������� ����� ���� � ���, ������������� � ������� ���� ����������.
//		- ������ ������������ �� ������������ ���, ������������ ����������
//		- ������ ����� ��� (������������ ����������) ��������� ������������ ����/���
//		- �������� ������ ������ �� ���� ������/�����, ������������� �� ������ ����� 
//		  � ������� ���� ����������
//		- ����� � ������ ���������� ������������� ����� �� ������ �����
//		  (������������ ��� ����������) 1) �������� ���� ����� ��������� ���:
//								- ��������������� �����/���� ������� ������� �� ���� �����
//								- ��������������� �����/���� ������������� ���� ������� �� ���������
//								- ��������������� ����� ������ ����� � ��������
//		  � ��� �� 2) ����� ����������� ���������� ���� (����� �������) ���� ������ 
//		  � ����� ������������� � ������� ���� ���������� � ���������� ������ �������.
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �����������.
//
// �� ��������� � patcher_x86.dll ����������� ���������, ����� �������� ���,
// ���������� � ��� �� ����� ������� ���� patcher_x86.ini c ������������
// �������: Logging on = 1 (Logging on = 0 - ��������� ����������� �����)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ������� �������������.
//
// 1) ������ ��� ������ 1 ��� ������� ������� GetPatcher(), �������� ���������
//		��������: Patcher* _P = GetPatcher();
// 2) ����� � ������� ������ Pather::CreateInstance ����� �������  
// ��������� Pat�herInstance �� ����� ���������� ������
//		��������:	Pat�herInstance* _PI = _P->CreateInstance("HD");
//		���:		Pat�herInstance* _PI = _P->CreateInstance("HotA");
// 3)  ����� ������������ ������ ������� Pat�her � Pat�herInstance
// ��������������� ��� ������ � ������� � ������
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

unit PatchApi;

interface

const

// �������� ������������ �������� ������������� �� LoHook ����
  EXEC_DEFAULT    = true;
  NO_EXEC_DEFAULT = false;


// �������� ������������� Patch::GetType()
  PATCH_  = 0;
  LOHOOK_ = 1;
  HIHOOK_ = 2;

// �������� ������������ ��� �������� hooktype � TPatcherInstance.WriteHiHook � TPatcherInstance.CreateHiHook
  CALL_   = 0;
  SPLICE_ = 1;
  FUNCPTR_= 2;

// �������� ������������ ��� �������� subtype � TPatcherInstance.WriteHiHook � TPatcherInstance.CreateHiHook
  DIRECT_  = 0;
  EXTENDED_= 1;
  SAFE_    = 2;

// �������� ������������ ��� �������� calltype � TPatcherInstance.WriteHiHook � TPatcherInstance.CreateHiHook
  ANY_     = 0;
  STDCALL_ = 0;
  THISCALL_= 1;
  FASTCALL_= 2;
  CDECL_   = 3;

  FASTCALL_1 = 1;

  NULL_PTR = nil;

type
  _dword_ = cardinal;

// ��� ������ � ����� ���������� ���������� ���� �����,
// ���� ��� ������� ��-�������, ������ �������� _ptr_
// �� ����� ������ ��������������� ���: pointer ��� integer ��������
  _ptr_ = pointer;

// ��������� HookContext
// ������������ � �������� ����������� �� LoHook ����
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

// ����������� ����� TPatch
// ������� ��������� ����� � ������� ������� ������ TPatcherInstance
  TPatch = packed class

	// ���������� ����� �� �������� ��������������� ����
    function GetAddress: integer; virtual; stdcall; abstract;

	// ���������� ������ �����
    function GetSize: cardinal; virtual; stdcall; abstract;

	// ���������� ���������� ��� ���������� TPatcherInstance, � ������� �������� ��� ������ ����
    function GetOwner: PAnsiChar; virtual; stdcall; abstract;

	// ���������� ��� �����
	// ��� �� ���� ������ PATCH_
	// ��� TLoHook ������ LOHOOK_
	// ��� THiHook ������ HIHOOK_
    function GetType: integer; virtual; stdcall; abstract;

	// ���������� true, ���� ���� �������� � false, ���� ���.
    function IsApplied: boolean; virtual; stdcall; abstract;


	// ��������� ���� 
	// ���������� >= 0 , ���� ����/��� ���������� �������
	// (������������ �������� �������� ���������� ������� ����� � ������������������
	// ������, ����������� �� ������� ������, ��� ������ �����, 
	// ��� ������� ��� �������� ����)
	// ���������� -1, ���� ��� (� ������ 1.1 ���� ����������� ������ �������)
	// ���������� -2, ���� ���� ��� ��������
	// ��������� ���������� ������ ��������������� ������� � ���
	// � ������� ������������ ���������� (��. ����� �������� ���������� ����)
	// ����� ����������� ����  (� ������� ��� ��� ����� ����������� ����) ���������� ��� 
	// ������������ (FIXED), � � ��� ������� �������������� � ���������.
    function Apply: boolean; virtual; stdcall; abstract;

  // ApplyInsert ��������� ���� � ��������� ����������� ������ �
	// ������������������ ������, ����������� �� ����� ������.
	// ������������ �������� ���������� �������������� � TPatch.Apply
	// ��������! ��������� ���� ����� FIXED ������ ������, ������� 
	// ������������ ���������� ����� ����� ���������� �� ���������, ����������� ����������.
	// ������� ApplyInsert ����� ���������� �������� ��������, ������������ 
	// �������� Undo, ����� ��������� ���� � �� �� �����, �� ������� ��� ��� �� ���������.
    function ApplyInsert(ZOrder: integer): boolean; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// ����� Undo
	// �������� ����/��� (� ������ ���� ���� �������� ��������� - ��������������� �������� ���)
	// ���������� ����� >= 0, ���� ����/��� ��� ������� �������
	// (������������ �������� �������� ������� ����� � ������������������
	// ������, ����������� �� ������� ������, ��� ������ �����, 
	// ��� ������� ��� �������� ����)
	// ���������� -2, ���� ���� � ��� ��� ��� ������� (�� ��� ��������)
	// ���������� -3, ���� ���� �������� ������������ (FIXED) (��. ����� Apply)
	// ��������� ���������� ������ ��������������� ������� � ���
    function Undo: integer; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// ����� Destroy
	// ����������
	// ������������ ���������� ����/���
	// ���������� ����� ������ ���������� ����/���.
	// ���������� 1, ���� ����(���) ��������� �������
	// ���������� 0, ���� ���� �� ���������
	// ��������� ����������� ��������������� ������� � ���
    function _Destroy: integer; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// ����� GetAppliedBefore
	// ���������� ���� ����������� ����� ������
	// ���������� nil ���� ������ ���� �������� ������
    function GetAppliedBefore: TPatch; virtual; stdcall; abstract;

	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// ����� GetAppliedAfter
	// ���������� ���� ����������� ����� �������
	// ���������� nil ���� ������ ���� �������� ���������
    function GetAppliedAfter: TPatch; virtual; stdcall; abstract;
  end;

// ����������� ����� TLoHook (����������� �� TPatch, �.�. �� ���� ���-��� �������� ������)
// ������� ��������� ����� �  ������� ������� ������ TPatcherInstance
  TLoHook = packed class(TPatch)
  end;

// ����������� ����� THiHook (����������� �� TPatch, �.�. �� ���� ���-��� �������� ������)
// ������� ��������� ����� � ������� ������� ������ TPatcherInstance
  THiHook = packed class(TPatch)

	// ���������� ��������� �� ������� (�� ���� � ������� � ������ SPLICE_),
	// ���������� �����
	// ��������! ������� ������� ��� �� ������������ ����, ����� ��������
	// ������������ (�� �������) ��������.
	  function GetDefaultFunc: _ptr_; virtual; stdcall; abstract;

	// ���������� ��������� �� ������������ ������� (�� ���� � ������� � ������ SPLICE_),
	// ���������� �����(������) �� ������� ������
	// (�.�. ���������� GetDefaultFunc() ��� ������� ������������ ���� �� ������� ������)
	// ��������! ������� ������� ��� �� ������������ ����, ����� ��������
	// ������������ (�� �������) ��������.
	  function GetOriginalFunc: _ptr_; virtual; stdcall; abstract;

	// ���������� ����� �������� � ������������ ���
	// ����� ������������ ������ ���-�������
	// SPLICE_ ����, ����� ������ ������ ��� ���� �������
	  function GetReturnAddress: _ptr_; virtual; stdcall; abstract;
  end;

// ����������� ����� TPatcherInstance
// �������/�������� ��������� ����� � ������� ������� CreateInstance � GetInstance ������ TPatcher
// ��������������� ��������� ���������/������������� ����� � ���� � ���,
// �������� �� � ������ ���� ������/�����, ��������� ����������� patcher_x86.dll
  TPatcherInstance = packed class

	////////////////////////////////////////////////////////////
	// ����� WriteByte
	// ����� ����������� ����� �� ������ address
	// (������� � ��������� DATA_ ����)
	// ���������� ����
	  function WriteByte(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteWord
	// ����� ������������ ����� �� ������ address
	// (������� � ��������� DATA_ ����)
	// ���������� ����
	  function WriteWord(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteDword
	// ����� ��������������� ����� �� ������ address
	// (������� � ��������� DATA_ ����)
	// ���������� ����
	  function WriteDword(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteJmp
	// ����� jmp to_address ����� �� ������ address
	// (������� � ��������� CODE_ ����)
	// ���������� ����
	// ���� ��������� ����� ���������� �������,
	// �.�. ������ ����� >= 5, ������� ����������� NOP'���. 
	  function WriteJmp(address, to_address: _ptr_): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteHexPatch
	// ����� �� ������ address ������������������ ����,
	// ������������ hex_cstr
	// (������� � ��������� DATA_ ����)
	// ���������� ����
	// hex_str - ��-������ ����� ��������� ����������������� �����
	// 0123456789ABCDEF (������ ������� �������!) ��������� ������� 
	// ��� ������ ������� hex_str ������������(������������)
	// ������ ������������ � �������� ��������� ����� ������
	// ������������� � ������� Binary copy � OllyDbg
	{ ������:
			_PI.WriteHexPatch(0x57b521, PChar('6A 01  6A 00'));
	}
	  function WriteHexPatch(address: _ptr_; hex_cstr: PAnsiChar): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteCodePatchVA
	// � ������������ ���� ���������� ������ �� ��������������,
	// �������� (����) �������� ������-�������� WriteCodePatch
	  function WriteCodePatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteLoHook
	// ������� �� ������ address �������������� ��� (CODE_ ����) � ��������� ���
	// ���������� ���
	// func - ��������� �� ������� ���������� ��� ������������ ����
	// ������ ����� ��� func(h: TLoHook; c: PHookContext): integer; stdcall;
	// � c: PHookContext ���������� ��� ������/���������
	// �������� ���������� � ����� ��������
	// ���� func ���������� EXEC_DEFAULT, �� 
	// ����� ���������� func ����������� �������� ����� ���.
	// ���� - NO_EXEC_DEFAULT - �������� ��� �� �����������
	  function WriteLoHook(address: _ptr_; func: pointer): TLoHook; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� WriteHiHook
	// ������� �� ������ address ��������������� ��� � ��������� ���
	// ���������� ���
	//
	// new_func - ������� ���������� ������������
	//
	// hooktype - ��� ����:
	//		CALL_ -		��� �� ����� ������� �� ������ address
	//					�������������� ������ E8 � FF 15, � ��������� ������� ��� �� ���������������
	//					� � ��� ������� ���������� �� ���� ������
	//		SPLICE_ -	��� ��������������� �� ���� ������� �� ������ address
	//		FUNCPTR_ -	��� �� ������� � ��������� (����������� �����, � �������� ��� ����� � �������� �������)
	//
	// subtype - ������ ����:
	//		DIRECT_ - ���������� � �������/����� �� ��������������
	//		EXTENDED_ - ������� new_func ������ �������� ���������� ����������
	//					��������� THiHook �, � ������
	//					���������� �������� �-�� __thiscall � __fastcall
	//					����������� ��������� ���������� ��������� ������� 
	//
	// ����� ������� ��� EXTENDED_ ���� (orig - ���������� �-��):
	//	����					int __stdcall orig(?)	��	new_func(h: THiHook; ?): integer; stdcall;
	//	����		 int __thiscall orig(int this, ?)	��	new_func(h: THiHook; this_: integer; ?): integer; stdcall;
	//	����   int __fastcall orig(int a1, int a2, ?)	��	new_func(h: THiHook; a1, a2: integer; ?): integer; stdcall;
	//	����					  int __cdecl orig(?)	��	new_func(h: THiHook; ?): integer; cdecl;
	//
	//	��������! EXTENDED_ FASTCALL_ ������������ ������ ������� � 2-�� � ����� �����������
	//	��� __fastcall c 1 ���������� ����������� EXTENDED_ FASTCALL_1 / EXTENDED_ THISCALL_
	//
	// 		SAFE_ - �� �� ����� ��� � EXTENDED_, ������ ����� ������� GetDefaultFunc() �����������������
	//				�������� ��������� ���������� EAX, ECX (���� �� FASTCALL_ � �� THISCALL_),
	//				EDX (���� �� FASTCALL_), EBX, ESI, EDI, ������ �� ������ ������ ���������� �������
	//
	// calltype - ���������� � ������ ������������ ���������� �-��:
	//		STDCALL_
	//		THISCALL_
	//		FASTCALL_
	//		CDECL_
	// ���������� ����� ��������� ���������� ��� ���� ����� EXTENDED_ ��� ���������
	// �������� ���� � ����� ���������� �������
	//
	// CALL_, SPLICE_ ��� �������� CODE_ ������
	// FUNCPTR_ ��� �������� DATA_ ������
  //
	  function WriteHiHook(address: _ptr_; hooktype, subtype, calltype: integer; new_func: pointer): THiHook; virtual; stdcall; abstract;

	///////////////////////////////////////////////////////////////////
	// ������ Create...
	// ������� ����/��� ��� �� ��� � ��������������� ������ Write...,
	// �� �� ��������� ���
	// ���������� ����/���
	  function CreateBytePatch(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;
	  function CreateWordPatch(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;
	  function CreateDwordPatch(address: _ptr_; value: integer): TPatch; virtual; stdcall; abstract;
	  function CreateJmpPatch(address, to_address: _ptr_): TPatch; virtual; stdcall; abstract;
	  function CreateHexPatch(address: _ptr_; hex_str: PAnsiChar): TPatch; virtual; stdcall; abstract;
	  function CreateCodePatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;
	  function CreateLoHook(address: _ptr_; func: pointer): TLoHook; virtual; stdcall; abstract;
	  function CreateHiHook(address: _ptr_; hooktype, subtype, calltype: integer; new_func: pointer): THiHook; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� ApplyAll
	// ��������� ��� �����/����, ��������� ���� ����������� TPatcherInstance
	// ���������� TRUE ���� ��� �����/���� ����������� �������
	// ���������� FALSE ���� ���� �� ���� ����/��� �� ��� ��������
	// (��. TPatch.Apply)
	  function ApplyAll: boolean; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� UndoAll
	// �������� ��� �����/����, ��������� ���� ����������� PatcherInstance
	// �.�. ��� ������� �� ������/����� �������� ����� Undo
	// ���������� FALSE, ���� ���� �� ���� ����/��� ���������� �������� (�������� ������������ (FIXED))
	// ����� ���������� TRUE
	  function UndoAll: boolean; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////
	// ����� DestroyAll
	// ���������� ��� �����/����, ��������� ���� ����������� PatcherInstance
	// �.�. ��� ������� �� ������/����� �������� ����� Destroy
	// ���������� FALSE, ���� ���� �� ���� ����/��� ���������� ���������� (�������� �����������)
	// ����� ���������� TRUE
	  function DestroyAll: boolean; virtual; stdcall; abstract;

	// � ������������ ���� ���������� ������ �� ��������������,
	// �������� (����) �������� ������-�������� WriteDataPatch
	  function WriteDataPatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;

 	// � ������������ ���� ���������� ������ �� ��������������,
	// �������� (����) �������� ������-�������� CreateDataPatch
	  function CreateDataPatchVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): TPatch; virtual; stdcall; abstract;

	// ����� GetLastPatchAt
	// ���������� NULL, ���� �� ������ address �� ��� �������� �� ���� ����/���,
	// ��������� ������ ����������� PatcherInstance
	// ����� ���������� ��������� ���������� ����/��� �� ������ address,
	// ��������� ������ ����������� PatcherInstance
   	function GetLastPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;

	// ����� UndoAllAt
	// �������� ����� ����������� ������ ����������� PatcherInstance
	// �� ������ address 
	// ���������� TRUE, ���� ��� ����� ������� ��������,
	// ����� ���������� FALSE
   	function UndoAllAt(address: _ptr_): boolean; virtual; stdcall; abstract;

	// ����� GetFirstPatchAt
	// ���������� NULL, ���� �� ������ address �� ��� �������� �� ���� ����/���,
	// ��������� ������ ����������� PatcherInstance
	// ����� ���������� ������ ���������� ����/��� �� ������ address,
	// ��������� ������ ����������� PatcherInstance
        function GetFirstPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;



	// ����� Write
	// ����� �� ������ address ������/��� �� ������ �� ������ data �������� size ���� 
	// ���� is_code == true, �� ��������� � ������� CODE_ ����, ����� - DATA_ ����.
	// ���������� ����
	function Write(address: _ptr_; data: _ptr_; size: _dword_; is_code: boolean): TPatch; virtual; stdcall; abstract;

	// ����� CreatePatch
	// ������ ���� ��� �� ��� � ����� Write,
	// �� �� ��������� ���
	// ���������� ����
	function CreatePatch(address: _ptr_; data: _ptr_; size: _dword_; is_code: boolean): TPatch; virtual; stdcall; abstract;


	////////////////////////////////////////////////////////////
	// ����� WriteCodePatch
	// ����� �� ������ address ������������������ ����,
	// ������������ args
	// (������� � ��������� ����)
	// ���������� ����
	// ������ ������� args (������ ���� �����������!) - ������, ����� ��������� ����������������� �����
	// 0123456789ABCDEF (������ ������� �������!),
	// � ��� �� ����������� ������-������� (������ �������!):
	// %b - ����� ������������ ����� �� args
	// %w - ����� ������������ ����� �� args
	// %d - ����� ��������������� ����� �� args
	// %j - ����� jmp �� ����� �� args
	// %� - ����� �all args
	// %m - �������� ��� �� ������ args �������� args (�.�. ������ 2 ��������� �� args)
  //      ����������� ���������� ����������� ������� MemCopyCodeEx.
	// %% - ����� ������ � ������-��������� �� args
	// %o - (offset) �������� �� ������ �� ��������� �������� ������� �
	//      Complex ����,  ������������ ������ Complex ����.
	// %n - ����� nop ������, ����������� ��  args
// #0: - #9: -������������� ����� (�� 0 �� 9) � ������� ����� ������� � ������� #0 - #9                              \
// #0 -  #9  -����� ������������ ����� ����� ������� EB, 70 - 7F, E8, E9, 0F80 - 0F8F
	//      ��������������� �����; ����� ������ ������� ������ �� �����
	// ~b - ����� �� args ���������� ����� � ����� ������������� �������� �� ����
	//      �������� � 1 ���� (������������ ��� ������� EB, 70 - 7F)
	// ~d - ����� �� args ���������� ����� � ����� ������������� �������� �� ����
	//      �������� � 4 ����� (������������ ��� ������� E8, E9, 0F 80 - 0F 8F)
	// %. - ������ �� ������ ( ��� � ����� ������ �� ����������� ���� ������ ����� % )
	// ����������� ������:
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
	// ����� CreateCodePatch
	// ������� ���� ��� �� ��� � ����� WriteCodePatch,
	// �� �� ��������� ���
	// ��������e� ����
   	function CreateCodePatch(address: _ptr_; const args: array of const): TPatch; stdcall;

	////////////////////////////////////////////////////////////
	// ����� WriteDataPatch
	// ����� �� ������ address ������������������ ����,
	// ������������ args
	// (������� � ��������� ����)
	// ���������� ����
	// ������ ������� args (������ ���� �����������!) - ������, ����� ��������� ����������������� �����
	// 0123456789ABCDEF (������ ������� �������!),
	// � ��� �� ����������� ������-������� (������ �������!):
	// %b - ����� ������������ ����� �� args
	// %w - ����� ������������ ����� �� args
	// %d - ����� ��������������� ����� �� args
	// %m - �������� ������ �� ������ args �������� args (�.�. ������ 2 ��������� �� args)
	// %% - ����� ������ � ������-��������� �� args
	// %o - (offset) �������� �� ������ �� ��������� �������� ������� �
	//      Complex ����,  ������������ ������ Complex ����.
	// %. - ������ �� ������ ( ��� � ����� ������ �� ����������� ���� ������ ����� % )
	// ����������� ������:
	//	patch := _PI.WriteCodePatch(address, [
	//		'FF FF %d %%', var,					// mov ecx, this  //
	//		'%m %%', address2, size,	// exec  code copy from address2
	//		'AE %.' ] );	// jmp [@return_address]
   	function WriteDataPatch(address: _ptr_; const args: array of const): TPatch; stdcall;

	////////////////////////////////////////////////////////////
	// ����� CreateDataPatch
	// ������� ���� ��� �� ��� � ����� WriteDataPatch,
	// �� �� ��������� ���
	// ��������e� ����
   	function CreateDataPatch(address: _ptr_; const args: array of const): TPatch; stdcall;

  end;

// ����� TPatcher
  TPatcher = packed class

	// �������� ������:

	///////////////////////////////////////////////////
	// ����� CreateInstance
	// ������� ��������� ������ TPatcherInstance, �������
	// ��������������� ��������� ��������� ����� � ���� �
	// ���������� ���� ���������.
	// owner - ���������� ��� ���������� TPatcherInstance
	// ����� ���������� nil, ���� ��������� � ������ owner ��� ������
	// ���� owner = nil ��� owner = '' ��
	// ��������� PatcherInstance ����� ������ � ������ ������ ��
	// �������� ���� ������� �������.
   	function CreateInstance(owner_name: PAnsiChar): TPatcherInstance; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� GetInstance
	// ���������� ��������� TPatcherInstance
	// � ������ owner.
	// � �������� ��������� ����� ���������� ��� ������.
	// ����� ���������� nil � ������, ����
	// ��������� � ������ owner �� ���������� (�� ��� ������)
	// ������������ ��� :
	// - �������� ������� �� ��������� ���, ������������ patcher_x86.dll
	// - ��������� ������� �� ���� ������ � �����
	//    ���������� ����, ������������� patcher_x86.dll
   	function GetInstance(owner_name: PAnsiChar): TPatcherInstance; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� GetLastPatchAt
	// ���������� nil, ���� �� ������ address �� ��� �������� �� ���� ����/���
	// ����� ���������� ��������� ���������� ����/��� �� ������ address
	// ��������������� �������� �� ���� ������ �� ��������� ������ ����� 
	// ��������� ���� ����� � TPatch.GetAppliedBefore
   	function GetLastPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� UndoAllAt
	// �������� ��� �����/���� �� ������ address
	// ���������� FALSE, ���� ���� �� 1 ����/��� �� ���������� �������� (��. Patch::Undo)
	// ����� ���������� TRUE
  	function UndoAllAt(address: _ptr_): boolean; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� SaveDump
	// ��������� � ���� � ������ file_name
	// - ���������� � ����� ���� ����������� TPatcherInstance
	// - ���������� ���� ����������� ������/�����
	// - ������ ���� ����������� ������ � �����
	  procedure SaveDump(file_name: PAnsiChar); virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� SaveLog
	// ��������� � ���� � ������ file_name ��� 
	  procedure SaveLog(file_name: PAnsiChar); virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� GetMaxPatchSize
	// ���������� patcher_x86.dll ����������� ��������� �����������
	// �� ������������ ������ �����,
	// ����� - ����� ������ � ������� ������ GetMaxPatchSize
	// (�� ������ ������ ��� 8192 ����, �.�. ������� :) )
   	function GetMaxPatchSize: integer; virtual; stdcall; abstract;

	// �������������� ������:

	///////////////////////////////////////////////////
	// ����� WriteComplexDataVA
	// � ������������ ���� ���������� ������ �� ��������������,
	// �������� (����) �������� ������-�������� WriteComplexString
   	function WriteComplexDataVA(address: _ptr_; format: PAnsiChar; va_args: _ptr_): integer; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� GetOpcodeLength
	// �.�. ������������ ���� �������
	// ���������� ����� � ������ ������ �� ������ p_opcode
	// ���������� 0, ���� ����� ����������
   	function GetOpcodeLength(p_opcode: pointer): integer; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� MemCopyCode
	// �������� ��� �� ������ �� ������ src � ������ �� ������ dst
	// MemCopyCode �������� ������ ����� ���������� ������� �������� >= size. ������ �����������!
	// ���������� ������ �������������� ����.
	// ���������� ��������� �� �������� ����������� ������ ���,
	// ��� ��������� �������� ������ E8 (call), E9 (jmp long), 0F80 - 0F8F (j** long)
	// c ������������� ���������� �� ������ � ��� ������, ���� ���������� 
	// ���������� �� ������� ����������� ������.
    procedure MemCopyCode(dst, src: pointer; size: cardinal); virtual; stdcall; abstract;


	///////////////////////////////////////////////////
	// ����� GetFirstPatchAt
	// ���������� nil, ���� �� ������ address �� ��� �������� �� ���� ����/���
	// ����� ���������� ������ ���������� ����/��� �� ������ address
	// ��������������� �������� �� ���� ������ �� ��������� ������ ����� 
	// ��������� ���� ����� � Patch::GetAppliedAfter
    function GetFirstPatchAt(address: _ptr_): TPatch; virtual; stdcall; abstract;

	///////////////////////////////////////////////////
	// ����� MemCopyCodeEx
	// �������� ��� �� ������ �� ������ src � ������ �� ������ dst
	// ���������� ������ �������������� ����.
	// ���������� �� MemCopyCode ���,
	// ��� ��������� �������� ������ EB (jmp short), 70 - 7F (j** short)
	// c ������������� ���������� �� ������ � ��� ������, ���� ���������� 
	// ���������� �� ������� ����������� ������ (� ���� ������ ��� ���������� ��
	// ��������������� E9 (jmp long), 0F80 - 0F8F (j** long) ������.
	// ��������! ��-�� ����� ������ �������������� ���� ����� ��������� ����������� 
	// ������ �����������.
    function MemCopyCodeEx(dst, src: pointer; size: cardinal): integer; virtual; stdcall; abstract;

	////////////////////////////////////////////////////////////////////
	// ����� WriteComplexData
	// �������� ����� ������� �����������  
	// ������ WriteComplexDataVA
	// ���� ����� ��������� ����� � �� � ����������, �.�. ��� ��� 
	// ���������� � �� � �����
	// ���������� ������ ����� ��� �� ��� � � TPatcherInstance.WriteCodePatch
	// (��. �������� ����� ������)
	// �� ���� ����� ����� �� ������ address, ������������������ ����,
	// ������������ ����������� args,
	// ��! �� ������� ��������� ������ TPatch, �� ����� ����������� (�.�. �� �������� �������� ������, �������� ������ � ������ �� ������� ���� � �.�.)
	// ��������!
	// ����������� ���� ����� ������ ��� ������������� �������� ������
	// ����, �.�. ������ ���� ������� ������ � ���� ������,
	// � � ��� �������������� ��������� ������ � �������
	// TPatcherInstance.WriteCodePatch / TPatcherInstance.WriteDataPatch
   	function WriteComplexData(address: _ptr_; const args: array of const): integer; stdcall;

  end;

//������� GetPatcher
//��������� ���������� �, � ������� ������ ������������ ��������������
//������� _GetPatcherX86@0, ���������� ��������� ������ TPatcher,
//����������� �������� �������� ���� ���������� ���������� patcher_x86.dll
//���������� nil ��� �������
//������� �������� 1 ���, ��� �������� �� �� �����������
  function GetPatcher: TPatcher; stdcall;

// ������� Call �������� �������� ������������ ������� �� ������������� ������
//������������ � ��� ����� ��� ������ �������
//���������� � ������� THiHook.GetDefaultFunc � THiHook.GetOriginalFunc
  function Call(calltype: integer; address: _ptr_; const args: array of const): _dword_; stdcall;


implementation

uses Windows;

type
  TDwordArgs = array [0..24] of DWORD;

// ������� ����������� array of const � array of _dword_ ��� �������, ����������� ������������ ���-��
// ���������� ������ �����
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
