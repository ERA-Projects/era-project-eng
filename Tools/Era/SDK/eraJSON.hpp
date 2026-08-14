#pragma once
#include "era.h"

namespace EraJS
{
#ifdef ERA2 // old ERA which didn't clear memory
#define TR _tr
#elif !defined(ERA_MAPED)
#define TR Era::tr
#define BUFFER h3::h3_TextBuffer
#else
char mappedTextBuffer[512];
#define BUFFER mappedTextBuffer

#define TR Eramap::tr
#endif

inline Era::static_str _tr(const char *key)
{

    char *buf = Era::_tr(key, NULL, -1);
    char *result = Era::ToStaticStr(buf);
    Era::MemFree(buf);

    return result;
}
inline bool isEmpty(const char *keyName) noexcept
{
    return !strcmp(TR(keyName), keyName);
}

inline int readInt(const char *keyName) noexcept
{
    return atoi(TR(keyName));
}

inline int readInt(const std::string &keyName) noexcept
{
    return readInt(keyName.data());
}

inline int readInt(const char *keyName, bool &success) noexcept
{
    char *result = TR(keyName);
    success = strcmp(result, keyName) != 0;
    return atoi(result);
}
inline int readInt(const std::string &keyName, bool &success) noexcept
{
    return readInt(keyName.data(), success);
}

inline char *read(const char *keyName) noexcept
{
    return TR(keyName);
}
inline char *read(const char *keyName, bool &success) noexcept
{
    char *result = TR(keyName);
    success = strcmp(result, keyName) != 0;
    return result;
}
inline char *read(const std::string &keyName) noexcept
{
    return read(keyName.c_str());
}
inline char *read(const std::string &keyName, bool &success) noexcept
{
    return read(keyName.c_str(), success);
}
inline double readFloat(const char *keyName) noexcept
{
    return atof(TR(keyName));
}
inline double readFloat(const std::string &keyName) noexcept
{
    return readFloat(keyName.data());
}
inline double readFloat(const char *keyName, bool &success) noexcept
{
    char *result = TR(keyName);
    success = strcmp(result, keyName) != 0;
    return atof(result);
}
inline double readFloat(const std::string &keyName, bool &success) noexcept
{
    return readFloat(keyName.data(), success);
}
// inline int readFloat(char* keyName)
//{
//	if (isEmpty(keyName))
//		return NAN;
//	return atof(Era::tr(keyName));
// }

template <typename T, bool IsEnum = std::is_enum_v<T>> struct safe_underlying_type
{
    using type = T;
};

template <typename T> struct safe_underlying_type<T, true>
{
    using type = std::underlying_type_t<T>;
};

template <typename T> using safe_underlying_type_t = typename safe_underlying_type<T>::type;
template <typename T> inline BOOL ReadSingleValue(T &target, LPCSTR jsonKey, bool &outSuccess) noexcept
{
    if constexpr (std::is_same_v<T, LPCSTR>)
    {
        LPCSTR readResult = EraJS::read(jsonKey, outSuccess);
        if (outSuccess)
            target = readResult;
    }
    else if constexpr (std::is_integral_v<T> || std::is_enum_v<T>)
    {
        using TargetType = safe_underlying_type_t<T>;
        int rawValue = EraJS::readInt(jsonKey, outSuccess);
        if (outSuccess)
        {
            target = static_cast<T>(static_cast<TargetType>(rawValue));
        }
    }
    else
    {
        static_assert(sizeof(T) == 0, "Unsupported type passed to EraJson engine");
    }
    return outSuccess;
}
template <typename T> inline BOOL ReadSingleValue(T &target, LPCSTR jsonKey) noexcept
{
	bool outSuccess = false;
    if constexpr (std::is_same_v<T, LPCSTR>)
    {
        LPCSTR readResult = EraJS::read(jsonKey, outSuccess);
        if (outSuccess)
            target = readResult;
    }
    else if constexpr (std::is_integral_v<T> || std::is_enum_v<T>)
    {
        using TargetType = safe_underlying_type_t<T>;
        int rawValue = EraJS::readInt(jsonKey, outSuccess);
        if (outSuccess)
        {
            target = static_cast<T>(static_cast<TargetType>(rawValue));
        }
    }
    else
    {
        static_assert(sizeof(T) == 0, "Unsupported type passed to EraJson engine");
    }
    return outSuccess;
}

template <typename T> inline BOOL ReadField(T &target, LPCSTR format, const int idx) noexcept
{
    // Directly using the global h3_TextBuffer
    sprintf(BUFFER, format, idx);
    bool readSuccess = false;
    return ReadSingleValue(target, BUFFER, readSuccess);
}

template <typename ElementType, size_t N>
inline BOOL ReadArrayField(ElementType (&target)[N], LPCSTR format, const int idx) noexcept
{
    bool elementReadSuccess = false;
    for (size_t i = 0; i < N; i++)
    {
        sprintf(BUFFER, format, idx, i);

        if (!ReadSingleValue(target[i], BUFFER, elementReadSuccess))
        {
            return i > 0;
        }
    }
    return TRUE;
}

// Dispatcher helpers used by the generation engine
template <typename T> inline void ParseFieldDispatch(T &field, LPCSTR format, const int idx, std::true_type)
{
    // It's an array!
    ReadArrayField(field, format, idx);
}

template <typename T> inline void ParseFieldDispatch(T &field, LPCSTR format, const int idx, std::false_type)
{
    // It's a single field!
    ReadField(field, format, idx);
}

} // namespace EraJS
