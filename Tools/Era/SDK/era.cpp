#include "era.h"

namespace Era {

/* WoG vars */
int*      v = (int*)      0x887664; // 1..10000
TErmZVar* z = (TErmZVar*) 0x9271E8; // 1..1000
int*      y = (int*)      0xA48D7C; // 1..100
int*      x = (int*)      0x91DA34; // 1..16
bool*     f = (bool*)     0x91F2DF; // 1..1000
float*    e = (float*)    0xA48F14; // 1..100

HINSTANCE hEra = LoadLibraryA("era.dll");
HINSTANCE hPlugin = 0;
TPlugin   Plugin = nullptr;

#define ERA_IMPORT(funcName) decltype(funcName) funcName = reinterpret_cast<decltype(funcName)>(GetProcAddress(hEra, #funcName))
#define ERA_IMPORT_RENAMED(origName, newName) decltype(newName) newName = reinterpret_cast<decltype(newName)>(GetProcAddress(hEra, #origName))

ERA_IMPORT(AllocErmFunc);
ERA_IMPORT(ClearAllIniCache);
ERA_IMPORT(ClearIniCache);
ERA_IMPORT(CreatePlugin);
ERA_IMPORT(DecorateInt);
ERA_IMPORT(ExecErmCmd);
ERA_IMPORT(ExecPersistedErmCmd);
ERA_IMPORT(ExtractErm);
ERA_IMPORT(FastQuitToGameMenu);
ERA_IMPORT(FatalError);
ERA_IMPORT(FindNextObject);
ERA_IMPORT(FireErmEvent);
ERA_IMPORT(FireEvent);
ERA_IMPORT(FormatQuantity);
ERA_IMPORT(FreeAppliedPatch);
ERA_IMPORT(GenerateDebugInfo);
ERA_IMPORT(GetAppliedPatchSize);
ERA_IMPORT(GetArgXVars);
ERA_IMPORT(GetAssocVarIntValue);
ERA_IMPORT(GetAssocVarStrValue);
ERA_IMPORT(GetButtonID);
ERA_IMPORT(GetCampaignFileName);
ERA_IMPORT(GetCampaignMapInd);
ERA_IMPORT(GetEraRegistryIntValue);
ERA_IMPORT(GetEraRegistryStrValue);
ERA_IMPORT(GetGameState);
ERA_IMPORT(GetMapFileName);
ERA_IMPORT(GetProcessGuid);
ERA_IMPORT(GetRealAddr);
ERA_IMPORT(GetRetXVars);
ERA_IMPORT(GetTriggerReadableName);
ERA_IMPORT(GetVersionNum);
ERA_IMPORT(GlobalRedirectFile);
ERA_IMPORT(Hash32);
ERA_IMPORT(IsCampaign);
ERA_IMPORT(IsCommanderId);
ERA_IMPORT(IsPatchOverwritten);
ERA_IMPORT(LoadImageAsPcx16);
ERA_IMPORT(MemFree);
ERA_IMPORT(NameColor);
ERA_IMPORT(NameTrigger);
ERA_IMPORT(NotifyError);
ERA_IMPORT(PatchExists);
ERA_IMPORT(PcxPngExists);
ERA_IMPORT(PersistErmCmd);
ERA_IMPORT(PluginExists);
ERA_IMPORT(RandomRangeWithFreeParam);
ERA_IMPORT(ReadSavegameSection);
ERA_IMPORT(ReadStrFromIni);
ERA_IMPORT(RedirectFile);
ERA_IMPORT(RedirectMemoryBlock);
ERA_IMPORT(RegisterHandler);
ERA_IMPORT(ReloadErm);
ERA_IMPORT(ReloadLanguageData);
ERA_IMPORT(ReportPluginVersion);
ERA_IMPORT(RollbackAppliedPatch);
ERA_IMPORT(SaveIni);
ERA_IMPORT(SetAssocVarIntValue);
ERA_IMPORT(SetAssocVarStrValue);
ERA_IMPORT(SetEraRegistryIntValue);
ERA_IMPORT(SetEraRegistryStrValue);
ERA_IMPORT(SetIsCommanderIdFunc);
ERA_IMPORT(SetIsElixirOfLifeStackFunc);
ERA_IMPORT(SetLanguage);
ERA_IMPORT(SetMultiPurposeDlgHandler);
ERA_IMPORT(SetRegenerationAbility);
ERA_IMPORT(SetStdRegenerationEffect);
ERA_IMPORT(ShowErmError);
ERA_IMPORT(ShowMessage);
ERA_IMPORT(ShowMultiPurposeDlg);
ERA_IMPORT(SplitMix32);
ERA_IMPORT(ToStaticStr);
ERA_IMPORT(trStatic);
ERA_IMPORT(trTemp);
ERA_IMPORT(WriteAtCode);
ERA_IMPORT(WriteSavegameSection);
ERA_IMPORT(WriteStrToIni);
ERA_IMPORT_RENAMED(GetVersion, GetEraVersion);
ERA_IMPORT_RENAMED(Hook, _Hook);
ERA_IMPORT_RENAMED(Splice, _Splice);
ERA_IMPORT_RENAMED(tr, _tr);

std::string GetModuleFileName (HINSTANCE hInstance)
{
  char buf[256];
  GetModuleFileNameA(hInstance, buf, sizeof(buf));

  return buf;
}

void ConnectEra (HINSTANCE PluginDllHandle, const char* PluginName)
{
  std::string finalPluginName = GetModuleFileName(PluginDllHandle);

  if (PluginName && *PluginName)
  {
    finalPluginName = PluginName;
  }

  Plugin = CreatePlugin(finalPluginName.c_str());

  if (!Plugin) {
    FatalError((std::string("Duplicate registered plugin: ") + GetModuleFileName(PluginDllHandle)).c_str());
  }
}

void* Hook (void* Addr, THookHandler HandlerFunc, void** AppliedPatch, int MinCodeSize, THookType HookType)
{
  return _Hook(Plugin, Addr, HandlerFunc, AppliedPatch, MinCodeSize, HookType);
}

void* Splice (void* OrigFunc, void* HandlerFunc, int CallingConv, int NumArgs, int* CustomParam, void** AppliedPatch)
{
  return _Splice(Plugin, OrigFunc, HandlerFunc, CallingConv, NumArgs, CustomParam, AppliedPatch);
}

static_str tr (const char* key)
{
    return trStatic(key);
}

std::string tr(const char* key, const std::vector<std::string>& params)
{
   constexpr int MAX_PARAMS = 64;

   const char* _params[MAX_PARAMS]{};
   const int numParams = ( params.size() <= MAX_PARAMS ? params.size() : MAX_PARAMS) & ~1;

   for (int i = 0; i < numParams; i++) {
     _params[i] = params[i].c_str();
   }

   return trTemp(key, _params, numParams - 1);
}

std::string IntToStr (int value)
{
  char buf[16];
  sprintf_s(buf, sizeof(buf), "%d", value);

  return buf;
}

void SetPcharValue (char *Buf, const char *NewValue, int BufSize)
{
  if (BufSize < 0) {
    lstrcpyA(Buf, NewValue);
  } else if (BufSize > 0) {
    int NumBytesToCopy = lstrlenA(NewValue);

    if (NumBytesToCopy >= BufSize) {
      NumBytesToCopy = BufSize - 1;
    }

    memcpy(Buf, NewValue, NumBytesToCopy);
    Buf[NumBytesToCopy] = 0;
  }
}

} // .namespace Era