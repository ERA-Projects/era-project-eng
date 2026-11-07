#pragma once
#include "RuntimeServices.h"
namespace era_objects
{
// Read-only view of the final merged object-definition catalog published by an editor/game adapter.
constexpr const char *DEFINITIONS = "ERA.Services.ObjectDefinitions.v1";
struct DefinitionsApi
{
    unsigned structSize, version;
    unsigned (__stdcall *count)();
    const char *(__stdcall *at)(int);
    int (__stdcall *originalSubtypeLimit)(int);
    // Final definition range: max subtype + 1, including gaps; 0 before loading,
    // for an absent type or an invalid type. Supported IDs: 0..32767.
    // This is not a domain table capacity.
    int (__stdcall *subtypeCount)(int);
};
}
