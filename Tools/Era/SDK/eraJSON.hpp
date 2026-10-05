#pragma once
#ifdef ERA_MAPED
#include "eramap.h"
#else
#include "era.h"
#endif
#include <cerrno>
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <limits>
#include <type_traits>
#ifdef ERA_TRACK_TEXT_OVERRIDES
#include <unordered_map>
#endif
#include <algorithm>

namespace EraJS
{
// Translation strings belong to ERA's permanent storage, never to the game's free().
inline char *read(const char *key) noexcept
{
#ifdef ERA_MAPED
    return Eramap::tr(key);
#elif defined(ERA2)
    char *buffer = Era::_tr(key, nullptr, -1);
    char *result = Era::ToStaticStr(buffer);
    Era::MemFree(buffer);
    return result;
#else
    return Era::tr(key);
#endif
}
inline char *read(const char *key, bool &success) noexcept
{
    char *result = read(key);
    success = result && std::strcmp(result, key) != 0;
    return result;
}
inline char *read(const std::string &key) noexcept { return read(key.c_str()); }
inline char *read(const std::string &key, bool &success) noexcept { return read(key.c_str(), success); }
inline bool isEmpty(const char *key) noexcept { bool found; read(key, found); return !found; }

template <typename T, bool IsEnum = std::is_enum<T>::value> struct safe_underlying_type { using type = T; };
template <typename T> struct safe_underlying_type<T, true> { using type = typename std::underlying_type<T>::type; };
template <typename T> using safe_underlying_type_t = typename safe_underlying_type<T>::type;
inline bool AtEnd(const char *end) noexcept
{
    while (*end && std::isspace(static_cast<unsigned char>(*end))) ++end;
    return !*end;
}
// Keep the shared reader compatible with C++11. Entity schemas may opt into
// newer language features through their own headers; ordinary clients do not.
namespace detail
{
template <typename Value, typename Enable = void> struct NumberParser
{
    static bool Parse(const char *, Value &) noexcept
    {
        static_assert(sizeof(Value) == 0, "Unsupported JSON number type");
        return false;
    }
};
template <typename Value> struct NumberParser<Value, typename std::enable_if<
    std::is_integral<Value>::value && std::is_signed<Value>::value>::type>
{
    static bool Parse(const char *text, Value &target) noexcept
    {
        char *end = nullptr;
        const long long value = std::strtoll(text, &end, 10);
        if (end == text || errno == ERANGE || !AtEnd(end) ||
            value < (std::numeric_limits<Value>::min)() || value > (std::numeric_limits<Value>::max)()) return false;
        target = static_cast<Value>(value);
        return true;
    }
};
template <typename Value> struct NumberParser<Value, typename std::enable_if<
    std::is_integral<Value>::value && !std::is_signed<Value>::value>::type>
{
    static bool Parse(const char *text, Value &target) noexcept
    {
        if (*text == '-') return false;
        char *end = nullptr;
        const unsigned long long value = std::strtoull(text, &end, 10);
        if (end == text || errno == ERANGE || !AtEnd(end) ||
            value > static_cast<unsigned long long>((std::numeric_limits<Value>::max)())) return false;
        target = static_cast<Value>(value);
        return true;
    }
};
template <typename Value> struct NumberParser<Value, typename std::enable_if<std::is_floating_point<Value>::value>::type>
{
    static bool Parse(const char *text, Value &target) noexcept
    {
        char *end = nullptr;
        const double value = std::strtod(text, &end);
        if (end == text || errno == ERANGE || !AtEnd(end) || !std::isfinite(value) ||
            value < -(std::numeric_limits<Value>::max)() || value > (std::numeric_limits<Value>::max)()) return false;
        const Value narrowed = static_cast<Value>(value);
        if (value != 0 && narrowed == 0) return false;
        target = narrowed;
        return true;
    }
};
} // namespace detail
template <typename T> inline bool ParseNumber(const char *text, T &target) noexcept
{
    typedef safe_underlying_type_t<T> Value;
    if (!text) return false;
    while (*text && std::isspace(static_cast<unsigned char>(*text))) ++text;
    if (!*text) return false;
    errno = 0;
    Value value;
    if (!detail::NumberParser<Value>::Parse(text, value)) return false;
    target = static_cast<T>(value);
    return true;
}
inline int readInt(const char *key, bool &success) noexcept
{
    const char *text = read(key, success);
    int value = 0;
    success = success && ParseNumber(text, value);
    return value;
}
inline int readInt(const char *key) noexcept { bool success; return readInt(key, success); }
inline int readInt(const std::string &key, bool &success) noexcept { return readInt(key.c_str(), success); }
inline int readInt(const std::string &key) noexcept { return readInt(key.c_str()); }
inline double readFloat(const char *key, bool &success) noexcept
{
    const char *text = read(key, success);
    double value = 0;
    success = success && ParseNumber(text, value);
    return value;
}
inline double readFloat(const char *key) noexcept { bool success; return readFloat(key, success); }
inline double readFloat(const std::string &key, bool &success) noexcept { return readFloat(key.c_str(), success); }
inline double readFloat(const std::string &key) noexcept { return readFloat(key.c_str()); }

enum class ReadStatus { Missing, Invalid, Applied };

// Only the game adapter opts in. Slots must remain alive until ForgetTextRange().
#ifdef ERA_TRACK_TEXT_OVERRIDES
struct TextBinding
{
    LPCSTR original;
    LPCSTR published;
    std::string key, alias;
};
inline std::unordered_map<LPCSTR *, TextBinding> &TextBindings()
{
    static std::unordered_map<LPCSTR *, TextBinding> bindings;
    return bindings;
}
inline void TrackText(LPCSTR &target, LPCSTR key, LPCSTR alias)
{
    auto &bindings = TextBindings();
    auto found = bindings.find(&target);
    if (found == bindings.end())
        bindings.emplace(&target, TextBinding{target, target, key, alias ? alias : ""});
    else
    {
        if (target != found->second.published) found->second.original = target;
        found->second.key = key;
        found->second.alias = alias ? alias : "";
    }
}
inline void ForgetTextRange(const void *base, size_t bytes)
{
    const uintptr_t address = reinterpret_cast<uintptr_t>(base);
    auto &bindings = TextBindings();
    for (auto it = bindings.begin(); it != bindings.end();)
    {
        const uintptr_t slot = reinterpret_cast<uintptr_t>(it->first);
        if (slot >= address && slot - address < bytes) it = bindings.erase(it);
        else ++it;
    }
}
inline void ReloadTextOverrides()
{
    for (auto &entry : TextBindings())
    {
        auto &binding = entry.second;
        // Another plugin owns a newer value: do not overwrite it or restore an old snapshot.
        if (*entry.first != binding.published) continue;
        bool found = false;
        LPCSTR value = read(binding.key, found);
        if (!found && !binding.alias.empty()) value = read(binding.alias, found);
        *entry.first = found ? value : binding.original;
        binding.published = *entry.first;
    }
}
#else
inline void ForgetTextRange(const void *, size_t) {}
#endif

template <typename T> inline ReadStatus ReadValue(T &target, LPCSTR key, LPCSTR alias = nullptr)
{
    bool found = false;
    const char *value = read(key, found);
    if (!found && alias) value = read(alias, found);
    if (!found) return ReadStatus::Missing;
    return ParseNumber(value, target) ? ReadStatus::Applied : ReadStatus::Invalid;
}
template <> inline ReadStatus ReadValue<LPCSTR>(LPCSTR &target, LPCSTR key, LPCSTR alias)
{
#ifdef ERA_TRACK_TEXT_OVERRIDES
    TrackText(target, key, alias);
#endif
    bool found = false;
    const char *value = read(key, found);
    if (!found && alias) value = read(alias, found);
    if (!found)
    {
#ifdef ERA_TRACK_TEXT_OVERRIDES
        auto &binding = TextBindings().at(&target);
        target = binding.original;
        binding.published = target;
#endif
        return ReadStatus::Missing;
    }
    target = value;
#ifdef ERA_TRACK_TEXT_OVERRIDES
    TextBindings().at(&target).published = target;
#endif
    return ReadStatus::Applied;
}
template <typename T> inline BOOL ReadSingleValue(T &target, LPCSTR key, bool &success)
{
    success = ReadValue(target, key) == ReadStatus::Applied;
    return success;
}
template <typename T> inline BOOL ReadSingleValue(T &target, LPCSTR key)
{
    return ReadValue(target, key) == ReadStatus::Applied;
}
template <typename T, typename... Indices> inline BOOL ReadFormatted(T &target, LPCSTR format, Indices... indices)
{
    char key[512];
    const int size = std::snprintf(key, sizeof(key), format, indices...);
    return size >= 0 && size < sizeof(key) && ReadSingleValue(target, key);
}
template <typename T> inline BOOL ReadField(T &target, LPCSTR format, const int idx)
{ return ReadFormatted(target, format, idx); }
// Resource identifiers are configuration, not user-visible translations.
// Keep them fixed when language data is reloaded, just like numeric properties.
inline bool ReadResourceField(LPCSTR &target, LPCSTR format, int id)
{
    char key[512];
    const int length = std::snprintf(key, sizeof(key), format, id);
    if (length < 0 || length >= sizeof(key)) return false;
    bool found = false;
    LPCSTR value = read(key, found);
    if (found) target = value;
    return found;
}
template <typename T, typename... Indices>
inline bool ReadNumberInRange(T &target, LPCSTR format, long long minimum, long long maximum, Indices... indices)
{
    static_assert(std::is_integral<T>::value || std::is_enum<T>::value, "Only numeric fields can be validated through a temporary");
    T candidate = target;
    if (!ReadFormatted(candidate, format, indices...)) return false;
    const long long value = static_cast<long long>(candidate);
    if (value < minimum || value > maximum) return false;
    target = candidate;
    return true;
}
template <typename... Prefix> inline bool ReadIndexedText(LPCSTR *table, size_t count, LPCSTR format, Prefix... prefix)
{
    if (!table) return false;
    bool changed = false;
    for (size_t i = 0; i < count; ++i)
        changed = ReadFormatted(table[i], format, prefix..., static_cast<int>(i)) || changed;
    return changed;
}
template <typename Element, size_t N> inline BOOL ReadArrayField(Element (&target)[N], LPCSTR format, const int idx)
{
    bool changed = false;
    for (size_t i = 0; i < N; ++i)
        changed = ReadFormatted(target[i], format, idx, static_cast<int>(i)) || changed;
    return changed;
}
template <typename T> inline void ParseFieldDispatch(T &field, LPCSTR format, int idx, std::true_type)
{ ReadArrayField(field, format, idx); }
template <typename T> inline void ParseFieldDispatch(T &field, LPCSTR format, int idx, std::false_type)
{ ReadField(field, format, idx); }

struct TextPointerBackup
{
    LPCSTR *base = nullptr;
    std::vector<LPCSTR> originals;
    void Capture(LPCSTR *slots, size_t count)
    {
        base = slots;
        if (!slots || !count) { originals.clear(); return; }
        originals.assign(slots, slots + count);
    }
    void Restore(LPCSTR *slots, size_t count, bool release = false)
    {
        ForgetTextRange(slots, count * sizeof(LPCSTR));
        if (slots && slots == base && !originals.empty())
            std::copy_n(originals.begin(), (std::min)(count, originals.size()), slots);
        if (release) { originals.clear(); base = nullptr; }
    }
};
} // namespace EraJS
