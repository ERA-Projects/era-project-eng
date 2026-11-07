#pragma once
// RMG_CustomizeObjectProperties.era, API version 1. __stdcall, undecorated exports.
// These operations select and filter rules; placement still uses RuntimeServices
// and must pass its topology checks. They do not provide network replication.
namespace wogification_api
{
enum Kind { Target = 0, Source = 1 };
enum Field { Enabled = 0, Rate, Limit, DistanceOrGroup, Levels, MapKinds };
using Version = int(__stdcall *)();
// Target rate/limit -1 inherit fallback; source chance/preserve are >= 0. Source group -1
// means all permitted rule groups. Level/map masks: 1 surface/authored, 2 below/random.
using Setting = int(__stdcall *)(int kind, int type, int subtype, int field, int fallback);
// Legacy target paths are extended by catalog targetGroups; other keys retain fallback.
using ReadInt = int(__stdcall *)(const char *key, int fallback);
// One synchronous configured-replacement pass. Always call End, including on error.
// Begin snapshots original live instances, existing target counts and positions.
using Begin = int(__stdcall *)(int randomMap);
// Supply the ERM RNG's chance result, reused for this source across groups.
using AllowSource = int(__stdcall *)(int x, int y, int z, int type, int subtype, int group, int rollPassed);
using TargetWeight = int(__stdcall *)(int x, int y, int z, int type, int subtype, int fallback);
// Call only after successful native placement and ordinary initialization.
// Notify marks the original source consumed, updates counts, then invokes the
// catalog's optional named ERM initializer(x,y,z,type,subtype). -1 stops the pass.
using Notify = int(__stdcall *)(int x, int y, int z, int type, int subtype);
using End = int(__stdcall *)();
// Separate ERM artifact/monster passes. Begin counts existing instances; Notify
// updates source/target limits only after successful creation. Same Field/Kind.
using PickupBegin = int(__stdcall *)(int type, int randomMap);
using PickupSetting = int(__stdcall *)(int kind, int type, int id, int field, int z, int fallback);
// Optional process controls; the original version 1 API remains compatible.
enum ProcessField { CreatureEnabled, CreatureLevels, MaxAggression, QuestCreatures,
    ArtifactEnabled, ArtifactLevels, BankArtifacts, BankBanners, ScrollEnabled,
    ScrollLevel1, ScrollLevel2, ScrollLevel3, ScrollLevel4, ScrollLevel5, ProcessMaps };
// Creature mask: bits 0..7; artifact mask: special/treasure/minor/major/relic.
// Scroll modes: 0 keep, 1 random chest/gold, 2 chest, 3 gold.
using ProcessSetting = int(__stdcall *)(int field, int randomMap, int fallback);
// True for a stack targeted by a defeat-monster quest.
using QuestCreature = int(__stdcall *)(int x, int y, int z);
using PickupNotify = int(__stdcall *)(int type, int sourceId, int targetId);
}
