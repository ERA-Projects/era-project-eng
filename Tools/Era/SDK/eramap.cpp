#include "eramap.h"

namespace Eramap
{

// Never load the editor runtime from a game or an unrelated process.
bool IsMapEditor() noexcept
{
    const auto *image = reinterpret_cast<const BYTE *>(GetModuleHandleA(nullptr));
    if (reinterpret_cast<uintptr_t>(image) != 0x400000) return false;
    const auto *dos = reinterpret_cast<const IMAGE_DOS_HEADER *>(image);
    if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < sizeof(*dos) || dos->e_lfanew > 4096)
        return false;
    const auto *nt = reinterpret_cast<const IMAGE_NT_HEADERS32 *>(image + dos->e_lfanew);
    if (nt->Signature != IMAGE_NT_SIGNATURE || nt->FileHeader.Machine != IMAGE_FILE_MACHINE_I386 ||
        nt->OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR32_MAGIC ||
        nt->OptionalHeader.AddressOfEntryPoint != 0xE84D4 || nt->OptionalHeader.SizeOfImage < 0xE84D9)
        return false;
    // Executable signature used by the supported ERA map editor (credits: RoseKavalier).
    return *reinterpret_cast<const DWORD *>(image + 0xE84D4 + 1) == 0x596ED4;
}

HINSTANCE hEramap = nullptr;
HINSTANCE hPlugin = nullptr;
TPlugin plugin = nullptr;

#define ERAMAP_IMPORTS \
    ERA_IMPORT(AllocErmFunc) \
    ERA_IMPORT(ClearAllIniCache) \
    ERA_IMPORT(ClearIniCache) \
    ERA_IMPORT(CreatePlugin) \
    ERA_IMPORT(EmptyIniCache) \
    ERA_IMPORT(FireEvent) \
    ERA_IMPORT(FreeAppliedPatch) \
    ERA_IMPORT(GetAppliedPatchSize) \
    ERA_IMPORT(GetCodePage) \
    ERA_IMPORT(GetEraRegistryIntValue) \
    ERA_IMPORT(GetEraRegistryStrValue) \
    ERA_IMPORT(GetLanguage) \
    ERA_IMPORT(GetProcessGuid) \
    ERA_IMPORT(GetVersionNum) \
    ERA_IMPORT(Hash32) \
    ERA_IMPORT(MemFree) \
    ERA_IMPORT(MergeIniWithDefault) \
    ERA_IMPORT(NameColor) \
    ERA_IMPORT(NameTrigger) \
    ERA_IMPORT(NotifyError) \
    ERA_IMPORT(PatchExists) \
    ERA_IMPORT(PcxPngExists) \
    ERA_IMPORT(PluginExists) \
    ERA_IMPORT(RandomRangeWithFreeParam) \
    ERA_IMPORT(ReadSavegameSection) \
    ERA_IMPORT(ReadStrFromIni) \
    ERA_IMPORT(RedirectFile) \
    ERA_IMPORT(RedirectMemoryBlock) \
    ERA_IMPORT(RegisterHandler) \
    ERA_IMPORT(ReloadLanguageData) \
    ERA_IMPORT(ReportPluginVersion) \
    ERA_IMPORT(RollbackAppliedPatch) \
    ERA_IMPORT(SaveIni) \
    ERA_IMPORT(SetCodePage) \
    ERA_IMPORT(SetEraRegistryIntValue) \
    ERA_IMPORT(SetEraRegistryStrValue) \
    ERA_IMPORT(SetLanguage) \
    ERA_IMPORT(ShowErmError) \
    ERA_IMPORT(SplitMix32) \
    ERA_IMPORT(ToStaticStr) \
    ERA_IMPORT(trStatic) \
    ERA_IMPORT(trTemp) \
    ERA_IMPORT(WriteAtCode) \
    ERA_IMPORT(WriteLog) \
    ERA_IMPORT(WriteStrToIni) \
    ERA_IMPORT_RENAMED(GetVersion, GetEraVersion) \
    ERA_IMPORT_RENAMED(Hook, _Hook) \
    ERA_IMPORT_RENAMED(Splice, _Splice) \
    ERA_IMPORT_RENAMED(tr, _tr)

// Zero-initialized API pointers have no static LoadLibrary/GetProcAddress side effects.
#define ERA_IMPORT(funcName) decltype(funcName) funcName = nullptr;
#define ERA_IMPORT_RENAMED(origName, newName) decltype(newName) newName = nullptr;
ERAMAP_IMPORTS
#undef ERA_IMPORT
#undef ERA_IMPORT_RENAMED

static bool ImportApi()
{
    if (!IsMapEditor()) return false;
    if (!hEramap) hEramap = LoadLibraryA("eramap.dll");
    if (!hEramap) return false;
#define ERA_IMPORT(funcName) funcName = reinterpret_cast<decltype(funcName)>(GetProcAddress(hEramap, #funcName));
#define ERA_IMPORT_RENAMED(origName, newName) newName = reinterpret_cast<decltype(newName)>(GetProcAddress(hEramap, #origName));
    ERAMAP_IMPORTS
#undef ERA_IMPORT
#undef ERA_IMPORT_RENAMED
    return CreatePlugin && trStatic;
}
#undef ERAMAP_IMPORTS

std::string GetModuleFileName(HINSTANCE hInstance)
{
    char buf[256];

    buf[0] = 0;
    size_t filePathLen = GetModuleFileNameA(hInstance, buf, sizeof(buf));

    if (filePathLen > 0)
    {
        int i = filePathLen - 1;

        while (i && buf[i] != '\\')
        {
            i--;
        }

        if (buf[i] == '\\')
        {
            i++;
        }

        return (char *)&buf[i];
    }

    return buf;
}

bool ConnectEra(HINSTANCE PluginDllHandle, const char *PluginName)
{
    if (!ImportApi()) return false;
    std::string finalPluginName = GetModuleFileName(PluginDllHandle);

    if (PluginName && *PluginName)
    {
        finalPluginName = PluginName;
    }

    plugin = CreatePlugin(finalPluginName.c_str());

    if (!plugin)
    {
        MessageBoxA(nullptr,
                    (std::string("Duplicate registered plugin: ") + GetModuleFileName(PluginDllHandle)).c_str(),
                    "FATAL ERROR", MB_OK);
        return false;
    }
    hPlugin = PluginDllHandle;
    return true;
}

void *Hook(void *Addr, THookHandler HandlerFunc, void **AppliedPatch, int MinCodeSize, THookType HookType)
{
    return _Hook(plugin, Addr, HandlerFunc, AppliedPatch, MinCodeSize, HookType);
}

void *Splice(void *OrigFunc, void *HandlerFunc, int CallingConv, int NumArgs, int *CustomParam, void **AppliedPatch)
{
    return _Splice(plugin, OrigFunc, HandlerFunc, CallingConv, NumArgs, CustomParam, AppliedPatch);
}

static_str tr(const char *key)
{
    return trStatic(key);
}

std::string tr(const char *key, const std::vector<std::string> &params)
{
    constexpr int MAX_PARAMS = 64;

    const char *_params[MAX_PARAMS]{};
    const int numParams = (params.size() <= MAX_PARAMS ? params.size() : MAX_PARAMS) & ~1;

    for (int i = 0; i < numParams; i++)
    {
        _params[i] = params[i].c_str();
    }

    return trTemp(key, _params, numParams - 1);
}

std::string IntToStr(int value)
{
    char buf[16];
    sprintf_s(buf, sizeof(buf), "%d", value);

    return buf;
}

void SetPcharValue(char *Buf, const char *NewValue, int BufSize)
{
    if (BufSize < 0)
    {
        lstrcpyA(Buf, NewValue);
    }
    else if (BufSize > 0)
    {
        int NumBytesToCopy = lstrlenA(NewValue);

        if (NumBytesToCopy >= BufSize)
        {
            NumBytesToCopy = BufSize - 1;
        }

        memcpy(Buf, NewValue, NumBytesToCopy);
        Buf[NumBytesToCopy] = 0;
    }
}

} // namespace Eramap
