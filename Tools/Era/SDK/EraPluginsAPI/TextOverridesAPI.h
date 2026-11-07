#pragma once
#include "RuntimeServices.h"
#include <cstddef>
namespace era_text
{
constexpr const char *SERVICE = "ERA.Services.TextOverrides.v1";
// Applies a translation to a borrowed string slot. Missing keys restore the captured original;
// alias is tried only when the primary key is absent. Slots must be forgotten before storage moves.
struct Api
{
    unsigned structSize, version;
    // 0 missing (restore original), 1 applied, -1 invalid/allocation failure.
    int (__stdcall *apply)(const char **slot, const char *key, const char *alias);
    void (__stdcall *forget)(const void *base, std::size_t bytes);
    void (__stdcall *reload)();
};
inline const Api *GetApi() { return era_services::Find<Api>(SERVICE); }
}
