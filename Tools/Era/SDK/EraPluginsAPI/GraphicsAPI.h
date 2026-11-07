#pragma once
#include <windows.h>
#include <cstdint>
#include <cstddef>
#include "RuntimeServices.h"

// Native Win32 C ABI. No STL or caller-owned allocations cross this boundary.
namespace era_graphics
{
constexpr std::uint32_t API_VERSION = 1;
constexpr const char *PLUGIN_NAME = "ERA_RuntimeServices.era";
constexpr const char *READY_EVENT = "OnGraphicsResourcesReady";
constexpr const char *SERVICE = "ERA.Services.Graphics.v1";
using FrameHandle = std::uint32_t;

enum Result : int
{
    // Zero means the provider is present but not ready; negative values identify a rejected request.
    Ok = 1, NotReady = 0, InvalidArgument = -1, MissingResource = -2,
    UnsupportedFormat = -3, InvalidFrame = -4, OutOfMemory = -5, RecursiveSource = -6
};
enum PaletteMode : std::uint32_t
{
    TargetPalette = 0,
    // Native PCX8 keeps all indices and its active 16/32-bit palette through
    // the service's render hooks. PNG overrides and DEF sources use TargetPalette.
    PreserveNativePcx = 1
};
enum Capability : std::uint32_t
{
    Pcx8 = 1, EraPngOverrides = 2, DefSources = 4, NativePcxPalette = 8
};

#pragma pack(push, 4)
struct FrameRequest
{
    std::uint32_t structSize = sizeof(FrameRequest);
    void *targetDef = nullptr; // Borrowed H3LoadedDef; determines size and target palette.
    const char *resource = nullptr; // Null/empty creates a question-mark placeholder.
    int sourceGroup = 0;
    int sourceFrame = 0;
    std::uint32_t paletteMode = PreserveNativePcx;
};
// Version 1 binding prefix. UpdateRequest carries the stride for future records.
struct FrameBinding
{
    FrameHandle frame = 0;
    // frame == 0 borrows a frame from the SAME target DEF, resolved before updates.
    int sourceGroup = 0;
    int sourceFrame = 0;
};
struct UpdateRequest
{
    std::uint32_t structSize = sizeof(UpdateRequest);
    void *targetDef = nullptr;
    int targetGroup = 0;
    const FrameBinding *bindings = nullptr;
    std::uint32_t count = 0; // Complete resulting table; shrinking is rejected.
    std::uint32_t bindingStride = sizeof(FrameBinding);
};
struct Api
{
    // Versioned function table; clients must check readiness and every callback before use.
    std::uint32_t structSize;
    std::uint32_t version;
    std::uint32_t capabilities;
    int (__stdcall *isReady)();
    int (__stdcall *createFrame)(const FrameRequest *, FrameHandle *);
    int (__stdcall *applyFrames)(const UpdateRequest *);
};
#pragma pack(pop)
using QueryApi = const Api *(__stdcall *)(std::uint32_t version);

// Retry discovery, including after an earlier missing/old provider. Never LoadLibrary
// from a consumer's DllMain. Returned table and successful handles live for the process.
inline const Api *GetApi()
{
    const Api *api = era_services::Find<Api>(SERVICE, API_VERSION);
    return api && api->version == API_VERSION && api->structSize >= sizeof(Api) &&
           api->isReady && api->createFrame && api->applyFrames ? api : nullptr;
}
static_assert(sizeof(FrameBinding) == 12, "Graphics API v1 binding layout");
} // namespace era_graphics
