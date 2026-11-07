#pragma once
#include <cstdint>

namespace era_config
{
// Service discovery and data-ready notifications; providers register after READY_EVENT.
constexpr const char *SERVICE = "ERA.Services.ConfigExport";
constexpr const char *READY_EVENT = "OnConfigExportApiReady";
constexpr const char *DATA_READY_EVENT = "OnConfigDataReady";
// Ok means success; Unavailable means data is not ready; Busy prevents re-entrant work.
enum Result : int { Ok = 1, Unavailable = 0, Invalid = -1, ProviderFailed = -2, Busy = -3 };
#pragma pack(push, 4)
// JSON construction, merging and serialization belong to the service DLL. No STL ABI.
// Provider fields are separated so callers can export translated text and native data independently.
enum Section : unsigned { Text = 0, Data = 1, Defaults = 2 };
enum ValueType : unsigned { Signed = 0, Unsigned, Real, Utf8, LocalText, Array, Object, Boolean, Null };
struct Value
{
    std::uint32_t structSize = sizeof(Value), type = Signed;
    union { std::int64_t integer; std::uint64_t unsignedInteger; double real; const char *string; };
    Value() : integer(0) {}
};
using RecordHandle = std::uint32_t;
using SnapshotHandle = std::uint32_t;
struct Sink
{
    std::uint32_t structSize = sizeof(Sink);
    void *context = nullptr;
    int (__stdcall *beginRecord)(void *, const char *category, const char *fileStem,
        const char *identity, int original, RecordHandle *) = nullptr;
    int (__stdcall *field)(void *, RecordHandle, unsigned section, const char *path, const Value *) = nullptr;
};
struct Provider
{
    std::uint32_t structSize = sizeof(Provider), version = 1;
    const char *id = nullptr;
    void *context = nullptr;
    int (__stdcall *collect)(void *, const Sink *) = nullptr;
};
struct CategoryInfo
{
    std::uint32_t structSize = sizeof(CategoryInfo);
    const char *key = nullptr, *fileStem = nullptr;
    unsigned recordCount = 0;
    int supportsData = 0;
};
struct Selection { int original = 1, mods = 1, text = 1, data = 1; };
struct Options { int mergeTextAndData = 0, ignoreRmgDefaults = 1; };
enum OutputKind : unsigned { TextFile = 0, DataFile = 1, CombinedFile = 2 };
struct OutputSink
{
    std::uint32_t structSize = sizeof(OutputSink);
    void *context = nullptr;
    int (__stdcall *output)(void *, unsigned kind, const char *fileName, const char *utf8Json) = nullptr;
};
struct Api
{
    std::uint32_t structSize, version;
    int (__stdcall *registerProvider)(const Provider *);
    int (__stdcall *collectSnapshot)(SnapshotHandle *);
    int (__stdcall *releaseSnapshot)(SnapshotHandle);
    unsigned (__stdcall *categoryCount)(SnapshotHandle);
    int (__stdcall *categoryInfo)(SnapshotHandle, unsigned index, CategoryInfo *);
    int (__stdcall *counts)(SnapshotHandle, unsigned index, const Selection *, int ignoreDefaults, int *fourCounts);
    int (__stdcall *outputs)(SnapshotHandle, unsigned index, const Selection *, const Options *, const OutputSink *);
    const char *(__stdcall *lastError)();
};
// Sink handles/strings are borrowed during one provider callback only.
// Values/paths are copied synchronously. LocalText uses ERA's current code page.
// Arrays/objects are initialized with a marker, then filled using dotted paths.
// Snapshot handles own immutable data until releaseSnapshot; CategoryInfo strings
// live with that snapshot. Output strings live only during output(). lastError
// is borrowed until the next failing API call. All calls use the main thread.
#pragma pack(pop)
}
