#pragma once
#include "era.h"

namespace EraJS
{
#ifdef ERA2 // old ERA which didn't clear memory
#define TR _tr
#elif !defined(ERA_MAPED)
#define TR Era::tr
#else
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

} // namespace EraJS
