#pragma once
/*
* The API was updated for ERA 3.9.16.
*/

#include <windows.h>
#include <cstdio>
#include <cstdint>
#include <vector>
#include <string>

#define ERA_API extern

namespace Era
{

#pragma pack(push, 1)


typedef int int32_bool;

// A zero terminated string, stored in static (permanent) memory, which will never be deallocated and must not be modified
typedef char* static_str;

// A zero-terminated string located in the memory block allocated by the Era kernel. Must be released using MemFree when it is no longer necessary
typedef char* era_str;

// A zero-terminated string located in a temp memory block, which must be copied immediately
typedef char* temp_str;

const int32_bool EXEC_DEF_CODE = true;


enum ECallingConvention: int
{
  // Right-to-left, caller clean-up
  CONV_CDECL = 0,

  // Right-to-left
  CONV_STDCALL = 1,

  // Right-to-left, first argument in ECX
  CONV_THISCALL = 2,

  // Right-to-left, first two arguments in ECX, EDX
  CONV_FASTCALL = 3,

  // Left-to-right, first three arguments in EAX, EDX, ECX
  CONV_REGISTER = 4,

  // Left-to-right
  CONV_PASCAL = 5,
};

enum THookType: int
{
  HOOKTYPE_BRIDGE = 0,
  HOOKTYPE_CALL   = 1,
  HOOKTYPE_JUMP   = 2,
};

enum EGameMenuTarget: int
{
  PAGE_DEFAULT    = -1,
  PAGE_NEW_GAME   = 101,
  PAGE_LOAD_GAME  = 102,
  PAGE_HIGH_SCORE = 103,
  PAGE_CREDITS    = 104,
  PAGE_QUIT       = 105,
  PAGE_RESTART    = 107,
  PAGE_MAIN       = 108,
};

enum ESearchDirection: int
{
  SD_FORWARD  = -1,
  SD_BACKWARD = -2,
};

enum EImageResizeAlg: int
{
  RESIZE_ALG_NO_RESIZE = 0, // Do not apply any constaints and do not change image dimensions
  RESIZE_ALG_STRETCH   = 1, // Assign image width and height to box width and height, scale unproportionally
  RESIZE_ALG_CONTAIN   = 2, // Resize image so, that at least one of its dimension become same as box dimension, and the other one less or equal to box dimension
  RESIZE_ALG_DOWNSCALE = 3, // Only downscale images proportionally, do not upscale small images
  RESIZE_ALG_UPSCALE   = 4, // Only upscale small images proportionally, leave big images as is
  RESIZE_ALG_COVER     = 5, // NOT IMPLEMENTED
  RESIZE_ALG_FILL      = 6, // Use image as a tile to fill the whole box
};

typedef void* TPlugin;

struct THookContext
{
  int EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX;
  int RetAddr;
};

typedef int32_bool (__stdcall *THookHandler) (THookContext* Context);

struct TEvent
{
  char* Name;
  void* Data;
  int   DataSize;
};

typedef void (__stdcall *TEventHandler) (TEvent* Event);

struct TGameState
{
  int RootDlgId;
  int CurrentDlgId;
};

struct TMultiPurposeDlgSetup
{
	char* Title;             // Top dialog title
	char* InputFieldLabel;   // If specified, user will be able to enter arbitrary text in input field
	char* ButtonsGroupLabel; // If specified, right buttons group will be displayed
	char* InputBuf;          // OUT. Field to write a pointer to a temporary buffer with user input. Copy this text to safe location immediately
	int        SelectedItem;      // OUT. Field to write selected item index to (0-3 for buttons, -1 for Cancel)
	char* ImagePaths[4];     // All paths are relative to game root directory or custom absolute paths
	char* ImageHints[4];
	char* ButtonTexts[4];
	char* ButtonHints[4];
	int32_bool ShowCancelBtn;
};


typedef char TErmZVar[512];
typedef int TXVars[16];


ERA_API int* v;      // 1..10000
ERA_API TErmZVar* z; // 1..1000
ERA_API int* y;      // 1..100
ERA_API int* x;      // 1..16
ERA_API bool* f;     // 1..1000
ERA_API float* e;    // 1..100


/**
 * Loads Era library and imports necessary functions. Must be called as soon as possible.
 * @param PluginDllHandle DLL module handle, which is passed to DLLMain entry as the first parameter.
 * @param PluginName      Plugin name or nullptr to use DLL file name. If you use patcher_x86 by Baratorch, specify the same name, as in CreateInstance call.
 */
void ConnectEra (HINSTANCE PluginDllHandle, const char* PluginName = nullptr);

/** Creates new plugin API instance for particular DLL plugin. Pass real dll name with extension. Returns plugin instance or NULL is plugin is already created */
ERA_API TPlugin (__stdcall *CreatePlugin) (const char* Name);


// ======================= EVENTS ======================= //
/** Adds handler to be called when specific named event triggers, ex. "OnAfterWoG" or "OnSavegameWrite" */
ERA_API void (__stdcall *RegisterHandler) (TEventHandler Handler, const char* EventName);

/** Triggers named event, passing custom event data of specified length to its handlers */
ERA_API void (__stdcall *FireEvent) (const char* EventName, void* EventData, int DataSize);
// ===================== END EVENTS ===================== //


// ======================= INTERNATIONALIZATION ======================= //
/** Changes current language code in memory without altering ini files or reloading already loaded data */
ERA_API int (__stdcall *SetLanguage) (const char* NewLanguage);

/** Reloads all json files from "Lang" directory and current language subdirectory */
ERA_API void (__stdcall *ReloadLanguageData) ();

/** Returns persisted/static translation for a given key */
static_str tr (const char* key);

/**
 * Returns translation for given complex key ('xxx.yyy.zzz') with substituted parameters.
 * Pass vector of (parameter name, parameter value) pairs to substitute named parameters.
 * Example: Mod\Lang\*.json file: { "eqs": { "greeting": "Hello, @name@" } }
 * Example: ShowMessage(tr("eqs.greeting", { "name", "igrik" }).c_str());
 *
 * @param  key    Key to get translation for.
 * @param  params Vector of (parameter name, parameter value pairs).
 * @return        Translation string.
 */
std::string tr(const char* key, const std::vector<std::string>& params);

/** Translates given key, using pairs of (key, value) params for translation */
ERA_API era_str (__stdcall *_tr) (const char* key, const char** params, int LastParamsIndex);

/** Translates given key, using pairs of (key, value) params for translation. Returns temporary buffer address, which must be immediately copied */
ERA_API temp_str (__stdcall *trTemp) (const char* key, const char** params, int LastParamsIndex);

/** Translates given key and returns persistent pointer to translation */
ERA_API static_str (__stdcall *trStatic) (const char* key);
// ===================== END INTERNATIONALIZATION ===================== //


// ======================= ERM ======================= //
ERA_API int (__stdcall *AllocErmFunc) (const char* EventName, int &EventId);
ERA_API void (__stdcall *FireErmEvent) (int EventId);
ERA_API void (__stdcall *ExecErmCmd) (const char* CmdStr);
ERA_API void (__stdcall *ExtractErm) ();
ERA_API void (__stdcall *ReloadErm) ();
ERA_API void (__stdcall *NameTrigger) (int TriggerId, const char *Name);

/**
 * Compiles single ERM command without "!!" prefix and conditions and saves its compiled code in persisted memory storage.
 * Returns non-nil opaque pointer on success and NULL on failure. Trailing semicolon is optional.
 */
ERA_API void* (__stdcall *PersistErmCmd) (const char* CmdStr);

/** Executes previously compiled and persisted ERM command. Use PersistErmCmd API for compilation */
ERA_API void (__stdcall *ExecPersistedErmCmd) (void* PersistedCmd);

/** Displays regular ERM error dialog and can be used for ERM scripts error reporting and debugging */
ERA_API void (__stdcall *ShowErmError) (const char *Error);

/** Returns pointer to array of arguments, that will be passed to ERM trigger as x-vars on ERM event generation */
ERA_API TXVars* (__stdcall *GetArgXVars) ();

/** Returns pointer to array of ERM x-vars copy after ERM has been handled. Some variables may be treated as result */
ERA_API TXVars* (__stdcall *GetRetXVars) ();

/** Returns human readable string for ERM event ID. Usually it's ERM trigger human readable name or ERM function name. */
ERA_API era_str (__stdcall *GetTriggerReadableName) (int TriggerId);

ERA_API int (__stdcall *GetAssocVarIntValue) (const char* VarName);
ERA_API era_str (__stdcall *GetAssocVarStrValue) (const char* VarName);
ERA_API void (__stdcall *SetAssocVarIntValue) (const char* VarName, int NewValue);
ERA_API void (__stdcall *SetAssocVarStrValue) (const char* VarName, const char* NewValue);

// ===================== END ERM ===================== //


// ======================= SHARED GLOBAL MEMORY ======================= //
ERA_API int (__stdcall *GetEraRegistryIntValue) (const char* VarName);
ERA_API era_str (__stdcall *GetEraRegistryStrValue) (const char* VarName);
ERA_API void (__stdcall *SetEraRegistryIntValue) (const char* VarName, int NewValue);
ERA_API void (__stdcall *SetEraRegistryStrValue) (const char* VarName, const char* NewValue);
// ===================== END SHARED GLOBAL MEMORY ===================== //


// ======================= CUSTOMIZABLE API ======================= //
typedef int32_bool (__stdcall *TIsCommanderId) (int MonId);
ERA_API TIsCommanderId (__stdcall *SetIsCommanderIdFunc) (TIsCommanderId NewImpl);

typedef int32_bool (__stdcall *TIsElixirOfLifeStack) (uint8_t* BattleStack);
ERA_API TIsElixirOfLifeStack (__stdcall *SetIsElixirOfLifeStackFunc) (TIsElixirOfLifeStack NewImpl);

ERA_API int32_bool (__stdcall *IsCommanderId) (int MonId);
ERA_API void (__stdcall *SetRegenerationAbility) (int32_t MonId, int32_t Chance, int32_t HitPoints, int32_t HpPercents);
ERA_API void (__stdcall *SetStdRegenerationEffect) (int32_t Level7Percents, int32_t HpPercents);
// ===================== END CUSTOMIZABLE API ===================== //


// ======================= MAP RELATED FUNCTIONS ======================= //
ERA_API int32_bool (__stdcall *IsCampaign) ();
ERA_API era_str (__stdcall *GetCampaignFileName) ();
ERA_API era_str (__stdcall *GetMapFileName) ();
ERA_API int (__stdcall *GetCampaignMapInd) ();

/** Works the same as UN:U with fast search syntax, but does not raise error on no more objects, returns success flag; Direction is -1 for FORWARD and -2 for BACKWARD. */
ERA_API int32_bool (__stdcall *FindNextObject) (int ObjType, int ObjSubtype, int* x, int *y, int*z, ESearchDirection Direction);
// ===================== END MAP RELATED FUNCTIONS ===================== //


// ======================= INI FILES ======================= //
/** Forgets all cached data for specified ini file. Any read/write operation will lead to its re-reading and re-parsing */
ERA_API void (__stdcall *ClearAllIniCache) ();

/** Forgets all cached data for all ini files */
ERA_API void (__stdcall *ClearIniCache) (const char* FilePath);

/** Replaces ini file cache in memory with an empty one. Use it for recreating ini files from scratch, when you don't need previously cached data and original file on disk */
ERA_API void (__stdcall *EmptyIniCache) (const char* FilePath);

/** Reads entry from ini file. The fill will be cached in memory for further fast reading */
ERA_API int32_bool (__stdcall *ReadStrFromIni) (const char* Key, const char* SectionName, const char* FilePath, char* ResultBuffer);

/** Writes new value to ini file cache in memory. Automatically loads ini to cache if necessary */
ERA_API int32_bool (__stdcall *WriteStrToIni) (const char* Key, const char* Value, const char* SectionName, const char* FilePath);

/** Loads two ini files and merges source ini entries with target ini entries in cache without overwriting existing entries */
ERA_API int32_bool (__stdcall *MergeIniWithDefault) (const char* TargetPath, const char* SourcePath);

/** Saves cached ini file data on disk */
ERA_API int32_bool (__stdcall *SaveIni) (const char* FilePath);
// ===================== END INI FILES ===================== //


// ======================= HOOKS AND PATCHES ======================= //
/**
 * Installs new hook at specified address. Returns pointer to bridge with original code if any. Optionally specify address of a pointer to write applied patch structure
 * pointer to. It will allow to rollback the patch later. MinCodeSize specifies original code size to be erased (nopped). Use 0 in most cases.
 *
 * In case of bridge cook type calls handler function, when execution reaches specified address. Handler receives THookContext pointer.
 * If it returns true, overwritten commands are executed. Otherwise overwritten commands are skipped.
 * Change Context.RetAddr field to return to specific address after handler finishes execution with FALSE result.
 * The hook bridge code is always thread safe.
 */
void* Hook (void* Addr, THookHandler HandlerFunc, void** AppliedPatch = nullptr, int MinCodeSize = 0, THookType HookType = HOOKTYPE_BRIDGE);
ERA_API void* (__stdcall *_Hook) (TPlugin plugin, void* Addr, THookHandler HandlerFunc, void** AppliedPatch, int MinCodeSize, THookType HookType);

/**
 * Replaces original function with the new one with the same prototype and 1-2 extra arguments.
 * Calling convention is changed to STDCALL. The new argument is callable pointer, which can be used to
 * execute original function. The pointer is passed as THE FIRST argument. If custom parameter address
 * is given, the value of custom parameter will be passed to handler as THE SECOND argument. If AppliedPatch
 * pointer is given, it will be assigned an opaque pointer to applied patch data structure. This* pointer can
 * be used to rollback the patch (remove splicing).
 *
 * Returns address of the bridge to original function.
 *
 * Example:
 *   int custom_param = 700;
 *   Splice((void*) 0x401000, (void*) MainProc, CONV_STDCALL, 2, &custom_param);
 *   int __stdcall (void* orig_func, int custom_param, int arg1, int arg2) MainProc {...}
 */
void* Splice (void* OrigFunc, void* HandlerFunc, int CallingConv, int NumArgs, int* CustomParam = nullptr, void** AppliedPatch = nullptr);
ERA_API void* (__stdcall *_Splice) (TPlugin plugin, void* OrigFunc, void* HandlerFunc, int CallingConv, int NumArgs, int* CustomParam, void** AppliedPatch);

/** Writes Count bytes from Src buffer to Dst code block */
ERA_API void (__stdcall *WriteAtCode) (int Count, void* Src, void* Dst);

/** Returns applied patch size in bytes (number of ovewritten bytes) */
ERA_API int (__stdcall *GetAppliedPatchSize) (void* AppliedPatch);

/** Returns true if applied patch was overwritten */
ERA_API int32_bool (__stdcall *IsPatchOverwritten) (void* AppliedPatch);

/** Rollback patch and free its memory. Do not use it afterwards */
ERA_API void (__stdcall *RollbackAppliedPatch) (void* pointer);

/** Frees applied patch structure. Use it if you don't plan to rollback it at all */
ERA_API void (__stdcall *FreeAppliedPatch) (void* pointer);// (*  *)
// ===================== END HOOKS AND PATCHES ===================== //


// ======================= DEBUG AND INFO ======================= //
/** Displays system message box with error and terminates application */
ERA_API void (__stdcall *FatalError) (const char* Err);

/** Displays system message box with error. Terminates application only if Debug.AbortOnError = 1 in heroes3.ini */
ERA_API void (__stdcall *NotifyError) (const char* error);

/** Generates full Era debug info (scripts, plugins, patches, context) and saves all the files in Debug\Era directory */
ERA_API void (__stdcall *GenerateDebugInfo) ();

/** Returns Era version string */
ERA_API static_str (__stdcall *GetEraVersion) ();

/** Returns Era version number in 'X.X.XX' format. 3915 means 3.9.15 */
ERA_API int (__stdcall *GetVersionNum) ();

/** Addes line to plugin versions message, shown on RMB on Credits button. The proposed format is: "{plugin name} vx.x.x". The function must be called in OnReportVersion event */
ERA_API void (__stdcall *ReportPluginVersion) (const char* VersionLine);

/** Returns 32-character unique key for current game process. The ID will be unique between multiple game runs */
ERA_API static_str (__stdcall *GetProcessGuid) ();

/** Returns IDs of game root dialog and current dialog. The first item in dialog class VMT tables is used as ID */
ERA_API void (__stdcall *GetGameState) (TGameState* GameState);
// ===================== END DEBUG AND INFO ===================== //


// ======================= SAVEGAMES ======================= //
/** Appends data portion to a certain named savegame section during game saving */
ERA_API void (__stdcall *WriteSavegameSection) (int DataSize, void* Data, const char* SectionName);

/** Reads data portion from a certain named savegame section during game loading. Returns number of bytes actually loaded */
ERA_API int (__stdcall *ReadSavegameSection) (int DataSize, void* Data, const char* SectionName);
// ===================== END SAVEGAMES ===================== //


// ======================= RESOURCES ======================= //
/** Returns ID of game button by its unique name, specified in *.btn file */
ERA_API int (__stdcall *GetButtonID) (const char* ButtonName);

/** Checks if binary patch exist. Provide full file name with extension like 'no prisons.bin' */
ERA_API int32_bool (__stdcall *PatchExists) (const char* PatchName);

/** Tries to load PNG replacement for pcx file name and returns success flag */
ERA_API int32_bool (__stdcall *PcxPngExists) (const char* PcxName);

/** Check if plugin with given name exists. Omit the extension. Era automatically searches for both deprecated 'dll' and modern 'era' extensions */
ERA_API int32_bool (__stdcall *PluginExists) (const char* PluginName);

/** Creates resource redirection for current savegame only. Whenever an attempt to load non-cached resource with OldFileName will be made, NewFileName will be used instead */
ERA_API void (__stdcall *RedirectFile) (const char* OldFileName, const char* NewFileName);

/**
 * Creates global resource redirection. Whenever an attempt to load non-cached resource with OldFileName will be made, NewFileName will be used instead.
 * Can be overriden by RedirectFile.
 */
ERA_API void (__stdcall *GlobalRedirectFile) (const char* OldFileName, const char* NewFileName);
// ===================== END RESOURCES ===================== //


// ======================= MEMORY ======================= //
/**
 * Stores string contents in persistent memory under unique address. Returns existing address if string with the same contents exists.
 * The functions serves two purposes: data deduplication (only one string buffer for particular contents will be kept)
 * and pointer persistence (the pointer buffer will never be freed and thus can be safely used in dialogs and game structures).
 */
ERA_API static_str (__stdcall *ToStaticStr) (const char* Str);

/** Releases memory, allocated by Era. Such memory blocks are marked with ERA_MEM() in API */
ERA_API void (__stdcall *MemFree) (const void* buf);

/** Informs Era about moved game array or structure into another location. Specify old array address, old array size and new address */
ERA_API void (__stdcall *RedirectMemoryBlock) (void* OldAddr, int BlockSize, void* NewAddr);

/** Returns final address for old known game array or structure. Uses information from all RedirectMemoryBlock calls. If nothing is found, returns address itself */
ERA_API void* (__stdcall *GetRealAddr) (void* Addr);

/**
 * Assigns new string value to buffer.
 * @param Buf      Buffer to change contents of.
 * @param NewValue New string value.
 * @param BufSize  Maximal buffer size or -1 to ignore it (buffer overflow may occur).
 */
void SetPcharValue(char* Buf, const char* NewValue, int BufSize);
// ===================== END MEMORY ===================== //


// ======================= CRYPTO ======================= //
/** Calculates data block hash */
ERA_API int (__stdcall *Hash32) (const char* data, int DataSize);

/** Generates new random value using SplitMix32 algorithm and modifies input seed value */
ERA_API int (__stdcall *SplitMix32) (int* seed, int MinValue, int MaxValue);

/**
 * Generates random value in specified range with additional custom parameter used only in deterministic generators to produce different outputs for sequence of generations.
 * For instance, if you need to generate random value in battle for each enemy stack, you could use stack ID or loop variable for FreeParam. But for better generation quality
 * use (stackID XOR UNIQUE_ACTION_MASK) and define UNIQUE_ACTION_MASK constant as unique int32 pre-generated value. In network battles multiple random value generations with
 * the same parameters produce the same output until next action is performed. This function allows to bring back randomness to multiple same time generations.
 */
ERA_API int (__stdcall *RandomRangeWithFreeParam) (int MinValue, int MaxValue, int FreeParam);
// ===================== END CRYPTO ===================== //


// ======================= GRAPHICS ======================= //
/**
 * Loads Pcx16 resource with rescaling support. Values <= 0 are considered 'auto'. If it's possible, images are scaled proportionally.
 * Resource name (name in binary resource tree) can be either fixed or automatic. Pass empty PcxName for automatic name.
 * If PcxName exceeds 12 characters, it's replaced with valid unique name. Check name field of result.
 * If resource is already registered and has proper format, it's returned with RefCount increased.
 * Result image dimensions may differ from requested if fixed PcxName is specified. Use automatic naming
 * to load image of desired size for sure.
 * Default image is returned in case of missing file and user is notified.
 */
ERA_API void* (__stdcall *LoadImageAsPcx16) (const char* FilePath, const char* PcxName, int Width, int Height, int MaxWidth, int MaxHeight, EImageResizeAlg ResizeAlg);
// ===================== END GRAPHICS ===================== //


// ======================= ERA RICH TEXT SUPPORT ======================= //
/** Gives a name to a certain ARGB int32 color to use in colored texts */
ERA_API void (__stdcall *NameColor) (int Color32, const char* Name);
// ===================== END ERA RICH TEXT SUPPORT ===================== //


// ======================= DIALOGS AND MENUS ======================= //
/** Display in-game native message dialog with OK button */
ERA_API void (__stdcall *ShowMessage) (const char *Message);

/** Raises special exception, closing all dialogs and forcing the game to return to the main menu */
ERA_API int (__stdcall *FastQuitToGameMenu) (EGameMenuTarget TargetScreen);

/** Displayes customizable configured multipurpose dialog and returns selected button ID (1..4) or -1 for Cancel */
ERA_API int (__stdcall *ShowMultiPurposeDlg) (TMultiPurposeDlgSetup* Setup);

/** Replaces current multipurpose dialog handler/implementor. Returns old handler if any */
typedef int (__stdcall *TShowMultiPurposeDlgFunc) (TMultiPurposeDlgSetup * Setup);
ERA_API TShowMultiPurposeDlgFunc (__stdcall *SetMultiPurposeDlgHandler) (TShowMultiPurposeDlgFunc NewImpl);
// ===================== END DIALOGS AND MENUS ===================== //


// ======================= UTILITIES ======================= //
/** Converts integer to std::string */
std::string IntToStr(int value);

/** Formats given positive or negative quantity to human-readable string with desired constraints on length */
ERA_API int (__stdcall *FormatQuantity) (int value, char* buffer, int BufSize, int MaxLen, int MaxDigits);

/** Converts integer to string, separating each three digit group by "era.locale.thousand_separator" character. */
ERA_API int (__stdcall *DecorateInt) (int value, char* buffer, int IgnoreSmallNumbers);
// ===================== END UTILITIES ===================== //

#pragma pack(pop)
}
