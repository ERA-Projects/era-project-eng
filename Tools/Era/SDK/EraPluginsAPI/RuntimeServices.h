#pragma once
#include <cstdint>

// Shared discovery/publication for process-local services. Include after header.h/H3API.
// Patcher variables are shared by DLLs; discovery never loads a plugin by filename.
namespace era_services
{
// Versioned prefix for service tables published through a named patcher variable.
struct Header { std::uint32_t structSize, version; };
// Return only a compatible table; null covers missing providers and ABI mismatches.
template <class Api> const Api *Find(const char *key, unsigned version = 1)
{
    if (!key || !*key) return nullptr;
    auto *patcher = GetPatcher();
    const auto *api = patcher ? patcher->VarGetValue<const Api *>(key, nullptr) : nullptr;
    return api && api->version == version && api->structSize >= sizeof(Api) ? api : nullptr;
}
// Publish a process-lifetime table. Refuse to replace a different owner at the same key.
template <class Api> bool Publish(const char *key, const Api *api)
{
    auto *patcher = GetPatcher();
    if (!patcher || !key || !*key || !api || api->structSize < sizeof(Api) || !api->version) return false;
    auto *variable = patcher->VarFind(key);
    if (variable && variable->GetValue() && variable->GetValue() != reinterpret_cast<std::uintptr_t>(api)) return false;
    if (!variable) variable = patcher->VarInit(key, reinterpret_cast<std::uintptr_t>(api));
    if (!variable) return false;
    *variable->GetPValue() = reinterpret_cast<std::uintptr_t>(api);
    return true;
}
constexpr const char *ARTIFACT_OWNER = "ERA.Services.ArtifactOwner.v1";
constexpr const char *DWELLING_OWNER = "ERA.Services.DwellingOwner.v1";
constexpr const char *BANK_OWNER = "ERA.Services.BankOwner.v1";
// Presence means that the domain extender owns its native table and field application.
struct Ownership { std::uint32_t structSize = sizeof(Ownership), version = 1; };
}
