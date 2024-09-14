#pragma once
#include <windows.h>

namespace Era
{
	#pragma pack(push, 1)

	/* Hooks, requires at least 5 bytes */
	const int HOOKTYPE_JUMP	 = 0;
	const int HOOKTYPE_CALL	 = 1;
	const int HOOKTYPE_BRIDGE = 2;
	
	/*
	Automatically creates safe bridge to high-level function:
		BOOL __stdcall Handler (THookContext* Context);
	Returns "Execute default code" flag. If default code should be executed, it can contain any
	commands except jumps.
	*/

	const int OPCODE_JUMP = 0xE9;
	const int OPCODE_CALL = 0xE8;
	const int OPCODE_RET	= 0xC3;

	const int EXEC_DEF_CODE = true;

	/* Erm triggers */
	const int TRIGGER_FU1			 = 0;
	const int TRIGGER_FU30000	 = 29999;
	const int TRIGGER_TM1			 = 30000;
	const int TRIGGER_TM100		 = 30099;
	const int TRIGGER_HE0			 = 30100;
	const int TRIGGER_HE198		 = 30298;
	const int TRIGGER_BA0			 = 30300;
	const int TRIGGER_BA1			 = 30301;
	const int TRIGGER_BR				= 30302;
	const int TRIGGER_BG0			 = 30303;
	const int TRIGGER_BG1			 = 30304;
	const int TRIGGER_MW0			 = 30305;
	const int TRIGGER_MW1			 = 30306;
	const int TRIGGER_MR0			 = 30307;
	const int TRIGGER_MR1			 = 30308;
	const int TRIGGER_MR2			 = 30309;
	const int TRIGGER_CM0			 = 30310;
	const int TRIGGER_CM1			 = 30311;
	const int TRIGGER_CM2			 = 30312;
	const int TRIGGER_CM3			 = 30313;
	const int TRIGGER_CM4			 = 30314;
	const int TRIGGER_AE0			 = 30315;
	const int TRIGGER_AE1			 = 30316;
	const int TRIGGER_MM0			 = 30317;
	const int TRIGGER_MM1			 = 30318;
	const int TRIGGER_CM5			 = 30319;
	const int TRIGGER_MP				= 30320;
	const int TRIGGER_SN				= 30321;
	const int TRIGGER_MG0			 = 30322;
	const int TRIGGER_MG1			 = 30323;
	const int TRIGGER_TH0			 = 30324;
	const int TRIGGER_TH1			 = 30325;
	const int TRIGGER_IP0			 = 30330;
	const int TRIGGER_IP1			 = 30331;
	const int TRIGGER_IP2			 = 30332;
	const int TRIGGER_IP3			 = 30333;
	const int TRIGGER_CO0			 = 30340;
	const int TRIGGER_CO1			 = 30341;
	const int TRIGGER_CO2			 = 30342;
	const int TRIGGER_CO3			 = 30343;
	const int TRIGGER_BA50			= 30350;
	const int TRIGGER_BA51			= 30351;
	const int TRIGGER_BA52			= 30352;
	const int TRIGGER_BA53			= 30353;
	const int TRIGGER_GM0			 = 30360;
	const int TRIGGER_GM1			 = 30361;
	const int TRIGGER_PI				= 30370;
	const int TRIGGER_DL				= 30371;
	const int TRIGGER_HM				= 30400;
	const int TRIGGER_HM0			 = 30401;
	const int TRIGGER_HM198		 = 30599;
	const int TRIGGER_HL				= 30600;
	const int TRIGGER_HL0			 = 30601;
	const int TRIGGER_HL198		 = 30799;
	const int TRIGGER_BF				= 30800;
	const int TRIGGER_MF1			 = 30801;
	const int TRIGGER_TL0			 = 30900;
	const int TRIGGER_TL1			 = 30901;
	const int TRIGGER_TL2			 = 30902;
	const int TRIGGER_TL3			 = 30903;
	const int TRIGGER_TL4			 = 30904;
	const int TRIGGER_OB_POS		= (int)(0x10000000);
	const int TRIGGER_LE_POS		= (int)(0x20000000);
	const int TRIGGER_OB_LEAVE	= (int)(0x08000000);

	/* Era Triggers */
	const int TRIGGER_BEFORE_SAVE_GAME					= 77000; // DEPRECATED	
	const int TRIGGER_SAVEGAME_WRITE						= 77001;
	const int TRIGGER_SAVEGAME_READ						 = 77002;
	const int TRIGGER_KEYPRESS									= 77003;
	const int TRIGGER_OPEN_HEROSCREEN					 = 77004;
	const int TRIGGER_CLOSE_HEROSCREEN					= 77005;
	const int TRIGGER_STACK_OBTAINS_TURN				= 77006;
	const int TRIGGER_REGENERATE_PHASE					= 77007;
	const int TRIGGER_AFTER_SAVE_GAME					 = 77008;
	const int TRIGGER_SKEY_SAVEDIALOG					 = 77009; // DEPRECATED	
	const int TRIGGER_HEROESMEET								= 77010; // DEPRECATED
	const int TRIGGER_BEFOREHEROINTERACT				= 77010;
	const int TRIGGER_AFTERHEROINTERACT				 = 77011;
	const int TRIGGER_ONSTACKTOSTACKDAMAGE			= 77012;
	const int TRIGGER_ONAICALCSTACKATTACKEFFECT = 77013;
	const int TRIGGER_ONCHAT										= 77014;

	struct THookContext
	{
		int EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX;
		int RetAddr;
	};

	struct TEvent
	{
		char* Name;
		void* Data;
		int	 DataSize;
	};

	typedef int TEventParams[16];
	typedef void (__stdcall *TEventHandler) (TEvent* Event);

	typedef char	TErmZVar[512];


	/* WoG vars */
	int*			v = (int*)			0x887664; // 1..10000
	TErmZVar* z = (TErmZVar*) 0x9271E8; // 1..1000
	int*			y = (int*)			0xA48D7C; // 1..100
	int*			x = (int*)			0x91DA34; // 1..16
	bool*		 f = (bool*)		 0x91F2DF; // 1..1000
	float*		e = (float*)		0xA48F14; // 1..100

	struct TGameState
	{
		int RootDlgId;
		int CurrentDlgId;
	};

	typedef void	(__stdcall *TWriteAtCode) (int Count, void* Src, void* Dst);
	typedef void* (__stdcall *THook) (void* HandlerAddr, int HookType, int PatchSize, void* CodeAddr);
	typedef void* (__stdcall *TApiHook) (void* HandlerAddr, int HookType, void* CodeAddr);
	typedef void	(__stdcall *TKillThisProcess) ();
	typedef void	(__stdcall *TFatalError) (char* Err);
	typedef int	 (__stdcall *TRecallAPI) (THookContext* Context, int NumArgs);
	typedef void	(__stdcall *TRegisterHandler) (TEventHandler Handler, char* EventName);
	typedef void	(__stdcall *TFireEvent) (char* EventName, void* EventData, int DataSize);
	typedef void* (__stdcall *TLoadTxt) (char* Name);
	typedef void	(__stdcall *TForceTxtUnload) (char* Name);
	typedef void	(__stdcall *TExecErmCmd) (char* CmdStr);
	typedef void	(__stdcall *TReloadErm) ();
	typedef void	(__stdcall *TExtractErm) ();
	typedef void	(__stdcall *TFireErmEvent) (int EventID);
	typedef void	(__stdcall *TClearAllIniCache) ();
	typedef void	(__stdcall *TClearIniCache) (char* FileName);

	typedef bool	(__stdcall *TReadStrFromIni)
	(
		char* Key,
		char* SectionName,
		char* FilePath,
		char* Res
	);

	typedef bool	(__stdcall *TWriteStrToIni)
	(
		char* Key,
		char* Value,
		char* SectionName,
		char* FilePath
	);

	typedef bool	(__stdcall *TSaveIni) (char* FilePath);
	typedef void	(__stdcall *TNameColor) (int Color32, char* Name);
	typedef void	(__stdcall *TWriteSavegameSection) (int DataSize, void* Data, char* SectionName);
	typedef int	 (__stdcall *TReadSavegameSection) (int DataSize, void* Data, char* SectionName);
	typedef void	(__stdcall *TGetGameState) (TGameState* GameState);
	typedef int	 (__stdcall *TGetButtonID) (char* ButtonName);
	typedef bool	(__stdcall *TPatchExists) (char* PatchName);
	typedef bool	(__stdcall *TPluginExists) (char* PluginName);
	typedef void	(__stdcall *TRedirectFile) ();
	typedef void	(__stdcall *TGlobalRedirectFile) ();
	typedef void	(__stdcall *TRedirectMemoryBlock) (void* OldAddr, int BlockSize, void* NewAddr);
	typedef void* (__stdcall *TGetRealAddr) (void* Addr);
	typedef void	(__stdcall *TSaveEventParams) ();
	typedef void	(__stdcall *TRestoreEventParams) ();
 

	TEventParams* EventParams = NULL;


	TWriteAtCode					WriteAtCode					 = NULL;
	THook								 Hook									= NULL;
	TApiHook							ApiHook							 = NULL;
	TKillThisProcess			KillThisProcess			 = NULL;
	TFatalError					 FatalError						= NULL;
	TRecallAPI						RecallAPI						 = NULL;
	TRegisterHandler			RegisterHandler			 = NULL;
	TFireEvent						FireEvent						 = NULL;
	TLoadTxt							LoadTxt							 = NULL;
	TForceTxtUnload			 ForceTxtUnload				= NULL;
	TExecErmCmd					 ExecErmCmd						= NULL;
	TReloadErm						ReloadErm						 = NULL;
	TExtractErm					 ExtractErm						= NULL;
	TFireErmEvent				 FireErmEvent					= NULL;
	TClearAllIniCache		 ClearAllIniCache			= NULL;
	TClearIniCache				ClearIniCache				 = NULL;
	TReadStrFromIni			 ReadStrFromIni				= NULL;
	TWriteStrToIni				WriteStrToIni				 = NULL;
	TSaveIni							SaveIni							 = NULL;
	TNameColor						NameColor						 = NULL;
	TWriteSavegameSection WriteSavegameSection	= NULL;
	TReadSavegameSection	ReadSavegameSection	 = NULL;
	TGetGameState				 GetGameState					= NULL;
	TGetButtonID					GetButtonID					 = NULL;
	TPatchExists					PatchExists					 = NULL;
	TPluginExists				 PluginExists					= NULL;
	TRedirectFile				 RedirectFile					= NULL;
	TGlobalRedirectFile	 GlobalRedirectFile		= NULL;
	TRedirectMemoryBlock	RedirectMemoryBlock	 = NULL;
	TGetRealAddr					GetRealAddr					 = NULL;
	TSaveEventParams			SaveEventParams			 = NULL;
	TRestoreEventParams	 RestoreEventParams		= NULL;


	HINSTANCE hEra;
	HINSTANCE hAngel;


	void ConnectEra ()
	{
		hAngel								= LoadLibrary("angel.dll");
		EventParams					 = (TEventParams*) GetProcAddress(hAngel, "EventParams");
		SaveEventParams			 = (TSaveEventParams) GetProcAddress(hAngel, "SaveEventParams");
		RestoreEventParams		= (TRestoreEventParams)GetProcAddress(hAngel, "RestoreEventParams");
		/***/
		hEra									= (HINSTANCE) v[1];
		WriteAtCode					 = (TWriteAtCode)					GetProcAddress(hEra, "WriteAtCode");
		Hook									= (THook)								 GetProcAddress(hEra, "Hook");
		ApiHook							 = (TApiHook)							GetProcAddress(hEra, "ApiHook");
		KillThisProcess			 = (TKillThisProcess)			GetProcAddress(hEra, "KillThisProcess");
		FatalError						= (TFatalError)					 GetProcAddress(hEra, "FatalError");
		RecallAPI						 = (TRecallAPI)						GetProcAddress(hEra, "RecallAPI");
		RegisterHandler			 = (TRegisterHandler)			GetProcAddress(hEra, "RegisterHandler");
		FireEvent						 = (TFireEvent)						GetProcAddress(hEra, "FireEvent");
		LoadTxt							 = (TLoadTxt)							GetProcAddress(hEra, "LoadTxt");
		ForceTxtUnload				= (TForceTxtUnload)			 GetProcAddress(hEra, "ForceTxtUnload");
		ExecErmCmd						= (TExecErmCmd)					 GetProcAddress(hEra, "ExecErmCmd");
		ReloadErm						 = (TReloadErm)						GetProcAddress(hEra, "ReloadErm");
		ExtractErm						= (TExtractErm)					 GetProcAddress(hEra, "ExtractErm");
		FireErmEvent					= (TFireErmEvent)				 GetProcAddress(hEra, "FireErmEvent");
		ClearAllIniCache			= (TClearAllIniCache)		 GetProcAddress(hEra, "ClearAllIniCache");
		ClearIniCache				 = (TClearIniCache)				GetProcAddress(hEra, "ClearIniCache");
		ReadStrFromIni				= (TReadStrFromIni)			 GetProcAddress(hEra, "ReadStrFromIni");
		WriteStrToIni				 = (TWriteStrToIni)				GetProcAddress(hEra, "WriteStrToIni");
		SaveIni							 = (TSaveIni)							GetProcAddress(hEra, "SaveIni");
		NameColor						 = (TNameColor)						GetProcAddress(hEra, "NameColor");
		WriteSavegameSection	= (TWriteSavegameSection) GetProcAddress(hEra, "WriteSavegameSection");
		ReadSavegameSection	 = (TReadSavegameSection)	GetProcAddress(hEra, "ReadSavegameSection");
		GetGameState					= (TGetGameState)				 GetProcAddress(hEra, "GetGameState");
		GetButtonID					 = (TGetButtonID)					GetProcAddress(hEra, "GetButtonID");
		PatchExists					 = (TPatchExists)					GetProcAddress(hEra, "PatchExists");
		PluginExists					= (TPluginExists)				 GetProcAddress(hEra, "PluginExists");
		RedirectFile					= (TRedirectFile)				 GetProcAddress(hEra, "RedirectFile");
		GlobalRedirectFile		= (TGlobalRedirectFile)	 GetProcAddress(hEra, "GlobalRedirectFile");
		RedirectMemoryBlock	 = (TRedirectMemoryBlock)	GetProcAddress(hEra, "RedirectMemoryBlock");
		GetRealAddr					 = (TGetRealAddr)					GetProcAddress(hEra, "GetRealAddr");
	}
	
	#pragma pack(pop)
}
