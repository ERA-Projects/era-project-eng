#pragma once

// Read-only snapshots. The caller owns the record; strings remain owned by the plugin.
// Keep records append-only and check structSize before writing across the DLL boundary.
namespace EraJS
{
struct DwellingExportInfo
{
    unsigned structSize = sizeof(DwellingExportInfo);
    int creatures[4] = {-1, -1, -1, -1};
    int slotCount = 0;
    int frame = 0;
    int frameCount = 0;
    const char *name = nullptr;
    const char *image = nullptr;
    int imageFrame = 0;
    int overviewFrame = -1;
    int overviewFrameCount = 0;
};
struct RmgExportInfo
{
    unsigned structSize = sizeof(RmgExportInfo);
    int enabled = 0, map = -1, zone = -1, value = -1, density = -1;
};
struct RmgExportOverridesInfo
{
    unsigned structSize = sizeof(RmgExportOverridesInfo);
    unsigned fieldMask = 0;
    int fields[5] = {};
};
struct BankExportInfo
{
    unsigned structSize = sizeof(BankExportInfo);
    const char *name = nullptr;
    h3::H3CreatureBankState states[4] = {};
    int isBank = 1;
    int positions[14] = {};
};
using GetDwellingExportInfo = int(__stdcall *)(int, int, DwellingExportInfo *);
using GetRmgExportInfo = int(__stdcall *)(int, int, RmgExportInfo *);
// (-1, -1): global limits; (type, -1): type overrides; (type, subtype): subtype overrides.
using GetRmgExportOverrides = int(__stdcall *)(int, int, RmgExportOverridesInfo *);
using GetBankExportInfo = int(__stdcall *)(int, BankExportInfo *);
using GetOriginalObjectSubtypeLimit = int(__stdcall *)(int);
using GetObjectSubtypeCount = int(__stdcall *)(int);
using GetObjectExportProperty = const char *(__stdcall *)(int);
} // namespace EraJS
