#pragma once
#include <windows.h>
#include <cstdint>

namespace erm_functions
{
// Function-pointer declarations and ABI contracts for ERA_RuntimeServices exports.
constexpr const char *PLUGIN_NAME = "ERA_RuntimeServices.era";
constexpr int NO_OWNER = -1;
constexpr int INVALID_OBJECT = -2;
constexpr int ANY_SUBTYPE = -1;

// Pure spatial ordering: xyz contains count triples; output holds count indices.
// No game access or map mutation. Returns index count, -1 for invalid arguments.
using OrderGarrisonSites = int(__stdcall *)(const int* xyz, int count, int mapSize,
                                           int* output, int capacity, unsigned seed);
// Tries to place special terrains on level z. Returns placements or -1 on failure.
// A failure can follow a partial placement pass, so do not retry on -1.
using AddSpecialTerrainsEx = int(__stdcall *)(int attempts, int z);
// Bottom-right coordinates of a passable, entrance-free flat terrain. 1 placed,
// 0 not placed, -1 native failure (may have placed an object).
// Multiplayer is currently rejected; see the network protocol limitation.
using PlaceSpecialTerrain = int(__stdcall *)(int x, int y, int z, int type);
// CENTER coordinates; minimum-area fitting DEF, including equivalent 46/230 and
// 21/223 types. Preserves the selected DEF's actual type. 1 placed, 0 skipped,
// -1 native failure/map change: stop the batch. No topology-changing templates.
// LOCAL operation: caller must replicate the same invocation via ERM P/D in MP.
// Suppresses ERA's redundant placement event; network support checks ERA 3.9.31.
using PlaceSmallestSpecialTerrain = int(__stdcall *)(int x, int y, int z, int type);

// All exports use __stdcall and undecorated names in both build configurations.
// Coordinates are the object's entrance (yellow tile), including when a hero stands there.
// Set/Register return 1 on success, 0 on invalid arguments or unavailable map/API.
using SetObjectOwner = int(__stdcall *)(int x, int y, int z, int owner);
// Applies locally and broadcasts an ERA event to peers. No network sends during replay.
// 0 may mean a send failure after local application; 1 is not a peer acknowledgement.
using SetObjectOwnerAndSync = int(__stdcall *)(int x, int y, int z, int owner);
using RegisterObjectType = int(__stdcall *)(int type, int subtype, int drawOnMinimap);
// Main thread only. Sets process-local indices for terrain ID 0..255, until overwritten.
// 0..253 select a palette entry. -1 restores the engine's entry for that branch.
// Returns 1 for a stored rule or 0 for invalid arguments. Takes effect on the next
// minimap redraw when the renderer's color sites are supported.
using SetTerrainMinimapPaletteIndices = int(__stdcall *)(int terrain, int normalIndex, int blockedIndex);
// Returns -1 for neutral, 0..7 for a player, -2 for an invalid/unregistered object.
using GetObjectOwner = int(__stdcall *)(int x, int y, int z);

// Glow uses a separate type registry. enabled=0 disables a type/subtype; 1 enables it.
// Exact subtypes override ANY_SUBTYPE; overrides are cleared when leaving/loading a map.
// Custom types must use the native visitors mask in setup bits 5..12.
using SetObjectGlow = int(__stdcall *)(int type, int subtype, int enabled);
using SetObjectGlowEnabled = int(__stdcall *)(int enabled);
using GetObjectGlowEnabled = int(__stdcall *)();

#pragma pack(push, 4)
struct ObjectGlowProfile
{
    std::uint32_t structSize = sizeof(ObjectGlowProfile), version = 1;
    std::uint64_t counterFrequency = 0;
    std::uint64_t calls = 0, tiles = 0, hits = 0, misses = 0, flushes = 0;
    std::uint64_t glowTicks = 0, fogTicks = 0, decodeTicks = 0;
    std::uint64_t peakMaskBytes = 0, peakScratchBytes = 0;
};
#pragma pack(pop)
static_assert(sizeof(ObjectGlowProfile) == 96, "Glow profile v1 ABI");
// Main thread only. Enable starts a new sample; disable stops and retains it.
// Samples survive map resets; get copies counters without modifying the sample.
using SetObjectGlowProfiling = int(__stdcall *)(int enabled);
using GetObjectGlowProfile = int(__stdcall *)(ObjectGlowProfile *output);

inline SetObjectGlowEnabled FindObjectGlowControl() noexcept
{
    const auto module = GetModuleHandleA(PLUGIN_NAME);
    return module ? reinterpret_cast<SetObjectGlowEnabled>(GetProcAddress(module, "Erm_SetObjectGlowEnabled"))
                  : nullptr;
}

// Geometry API v1 preserves blocked cells and every entrance after aligning the primary entrance.
enum ReplacementResult : int
{
    ReplacementRejected = 0, // No deletion was attempted; source remains intact.
    ReplacementSucceeded = 1,
    ReplacementPartialFailure = -1, // Deletion attempted or source changed by a hook; stop this pass.
    ReplacementMapChanged = -2, // Map was left/reloaded by a native hook; stop all map access.
    ReplacementNetworkUnsupported = -3 // No map changes; selected DEF is not networked in v1.
};
using GetObjectReplacementApiVersion = int(__stdcall *)();
// Writes 15 integers; layout is documented in ERA_RuntimeServices/Docs/OBJECT_REPLACEMENT.md.
using GetObjectGeometry = int(__stdcall *)(int x, int y, int z, int *output, int capacity);
// Returns an opaque 1-based prototype token, or 0 if no variant fits. Tokens are map-local.
using FindObjectReplacement = int(__stdcall *)(int x, int y, int z, int type, int subtype,
                                               int terrain, int approachMask);
// Six integers per target (type, subtype, terrain, approach, weight, caller data).
// Writes one prototype token per target; returns 0 if the batch could not be evaluated.
using FindObjectReplacements = int(__stdcall *)(int x, int y, int z, const int *records,
                                                int count, int *output);
// Revalidates the token and geometry immediately before placement. See ReplacementResult.
// A negative result MUST NOT be treated as an ordinary unsuitable candidate.
using ReplaceObject = int(__stdcall *)(int x, int y, int z, int type, int subtype,
                                       int terrain, int approachMask, int prototype);

// Strict signed 32-bit JSON integers; missing/invalid values return the supplied default.
using ReadJsonInt = int(__stdcall *)(const char *key, int defaultValue);
// Accepts a scalar or contiguous flattened array. Null output/capacity 0 queries count.
// With a buffer, returns min(count, capacity). Invalid data returns 0 without writing.
// Caller owns output; these readers do not cache language data across reloads.
using ReadJsonIntArray = int(__stdcall *)(const char *key, int *output, int capacity);

// Record only; does not execute the callback now. undoFunction == 0 means no undo callback.
// Replayed callbacks receive the copied payload in x1..x16. They are not saved or networked.
using RegisterReplayEvent = int(__stdcall *)(int replayFunction, int undoFunction,
                                            int x1, int x2, int x3, int x4);
using RegisterReplayEventArgs = int(__stdcall *)(int replayFunction, int undoFunction,
                                                const int *args, int argCount);
}
