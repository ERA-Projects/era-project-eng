#pragma once

namespace object_config
{
constexpr int OBJECT_TYPE_LIMIT = 232;
// ObjectExtender identities and H3MapItem subtypes use signed 16-bit fields.
constexpr int SUBTYPE_COUNT_LIMIT = 32768;
constexpr int PROPERTY_SUBTYPE_SCAN_LIMIT = 1024;

constexpr bool IsObjectType(int type) noexcept { return type >= 0 && type < OBJECT_TYPE_LIMIT; }
constexpr bool IsObjectSubtype(int subtype) noexcept { return subtype >= 0 && subtype < SUBTYPE_COUNT_LIMIT; }
}
