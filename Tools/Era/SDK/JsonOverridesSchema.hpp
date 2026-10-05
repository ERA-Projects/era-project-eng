#pragma once
#if (defined(_MSVC_LANG) && _MSVC_LANG < 201703L) || (!defined(_MSVC_LANG) && __cplusplus < 201703L)
#error JsonOverridesSchema.hpp requires C++17; include eraJson.hpp for the compatible reader API.
#endif
#include "eraJson.hpp"

// One list drives both adapters and export. Do not expose resource/owner pointers.
#define ERA_ARTIFACT_FIELDS(X) \
    X(name) X(cost) X(position) X(type) X(description) \
    X(comboArtifactId) X(partOfComboArtifactId) X(disabled) X(hasSpell)

namespace EraJS
{
struct ArtifactSchema
{
#define ERA_ART_KEY(field) static constexpr LPCSTR field = "era.artifacts.%d." #field;
    ERA_ARTIFACT_FIELDS(ERA_ART_KEY)
#undef ERA_ART_KEY
    static constexpr LPCSTR event = "era.artifacts.%d.event";
};
inline bool ValidArtifactNumber(LPCSTR key, long long value, int artifactCount, int combinationCount)
{
    if (key == ArtifactSchema::cost) return value >= 0;
    if (key == ArtifactSchema::disabled || key == ArtifactSchema::hasSpell) return value == 0 || value == 1;
    if (key == ArtifactSchema::type) return value >= 0 && (value & ~31LL) == 0;
    if (key == ArtifactSchema::comboArtifactId) return value >= -1 && value < combinationCount;
    if (key == ArtifactSchema::partOfComboArtifactId) return value >= -1 && value < artifactCount;
    if (key == ArtifactSchema::position)
    {
        if (value >= 0 && value <= 14) return true;
        switch (value)
        {
        case 65: case 1334: case 1339: case 16771: case 21732: case 117033: case 35338: case 21748: return true;
        default: return false;
        }
    }
    return true;
}
template <typename T> inline void ReadArtifactField(T &field, LPCSTR key, int id, int artifactCount, int combinationCount)
{
    if constexpr (std::is_same_v<T, LPCSTR>) ReadField(field, key, id);
    else
    {
        T candidate = field;
        if (ReadField(candidate, key, id) && ValidArtifactNumber(key, static_cast<long long>(candidate), artifactCount, combinationCount))
            field = candidate;
    }
}
template <typename Artifact> inline void ReadArtifact(Artifact &artifact, int id, int artifactCount, int combinationCount = 12)
{
#define ERA_ART_READ(field) ReadArtifactField(artifact.field, ArtifactSchema::field, id, artifactCount, combinationCount);
    ERA_ARTIFACT_FIELDS(ERA_ART_READ)
#undef ERA_ART_READ
}
template <typename Artifact, typename Visitor> inline void VisitArtifact(const Artifact &artifact, Visitor visitor)
{
#define ERA_ART_VISIT(field) visitor(#field, artifact.field);
    ERA_ARTIFACT_FIELDS(ERA_ART_VISIT)
#undef ERA_ART_VISIT
}
template <typename Creature, typename Visitor> inline void VisitCreatureText(const Creature &creature, Visitor visitor)
{
    visitor("singular", creature.nameSingular);
    visitor("plural", creature.namePlural);
    visitor("description", creature.description);
}
inline void ReadCreatureDescription(LPCSTR &target, int id)
{
    char key[80], alias[80];
    std::snprintf(key, sizeof(key), "era.monsters.%d.description", id);
    std::snprintf(alias, sizeof(alias), "era.monsters.%d.name.description", id);
    ReadValue(target, key, alias);
}
inline void ReadTownDwelling(LPCSTR &target, int town, int dwelling, bool description)
{
    char key[100], alias[100];
    const char *field = description ? "description" : "name";
    std::snprintf(key, sizeof(key), "era.towns.%d.buildings.%d.%s", town, 30 + dwelling, field);
    std::snprintf(alias, sizeof(alias), "era.towns.%d.dwellings.%d.%s", town, dwelling, field);
    ReadValue(target, key, alias);
}
} // namespace EraJS
