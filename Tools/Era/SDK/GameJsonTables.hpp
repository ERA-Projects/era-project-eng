#pragma once
// Game executable operands only. The editor has its own adapter and layout.
namespace EraJS
{
namespace GameTables
{
inline int ArtifactEventCapacity() noexcept { return h3::DwordAt(0x49DD8E + 2) / sizeof(LPCSTR); }
inline LPCSTR *ArtifactEvents() noexcept { return *reinterpret_cast<LPCSTR **>(0x49F51B + 3); }
inline int Dwelling1Capacity() noexcept { return h3::DwordAt(0x405CCE + 2) / sizeof(LPCSTR); }
inline int Dwelling4Capacity() noexcept { return h3::ByteAt(0x405CFE + 2) / sizeof(LPCSTR); }
// This is the constructor's allocation count, not the count of map prototypes.
// A relocator must publish/patch the count as well before extra slots may be read.
inline int CreatureBankCapacity() noexcept { return h3::ByteAt(0x47A3BA + 1); }
inline LPCSTR *HeroBiographies() noexcept { return *reinterpret_cast<LPCSTR **>(0x5B9A18 + 2) + 1; }
} // namespace GameTables
} // namespace EraJS
