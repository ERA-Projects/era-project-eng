#pragma once
#include <algorithm>
#include <string>
#include <vector>
#include <windows.h>

namespace modList
{
static std::vector<std::string> globalModList, lowerCaseModList;
constexpr INT CASE_TO_LOWER = 1;
constexpr INT CASE_DEFAULT = 0;

// Чтение int из буфера (предположим, little endian)
inline int ReadInt(const char *&p)
{
    int value;
    std::memcpy(&value, p, sizeof(int));
    p += sizeof(int);
    return value;
}

// Чтение строки (сначала длина, затем символы)
inline std::string ReadStrWithLenField(const char *&p)
{
    const int len = ReadInt(p);
    std::string result(p, len);
    p += len;
    return result;
}

// Основная функция разбора
inline void ParseSerializedModList(void *SerializedModList, std::vector<std::string> &ResModList)
{
    //    assert(SerializedModList != nullptr);

    const char *p = static_cast<const char *>(SerializedModList);
    const int NumMods = ReadInt(p);
    //    assert(NumMods >= 0);

    ResModList.resize(NumMods);
    for (int i = 0; i < NumMods; ++i)
    {
        ResModList[i] = ReadStrWithLenField(p);
    }
}

inline BOOL GetEraMappedModList(std::vector<std::string> &modLsit)
{
    if (HINSTANCE hDll = GetModuleHandleA("vfs.dll"))
    {
        // using GetModList = Era::era_str(__stdcall *)();
        using GetSerializedModListA = void *(__stdcall *)();
        // get exported function
        if (GetSerializedModListA getModList = (GetSerializedModListA)GetProcAddress(hDll, "GetSerializedModListA"))
        {

            void *SerializedModList = getModList();
            ParseSerializedModList(SerializedModList, modLsit);

            // get "Free" function
            using FreeModList = void(__stdcall *)(void *);

            FreeModList freeModList = (FreeModList)GetProcAddress(hDll, "MemFree");
            if (freeModList)
            {
                // clear memory
                freeModList(SerializedModList);
            }

            return true;
        }
    }
    return false;
}

inline int GetEraModList(std::vector<std::string> &modList, const BOOL toLower = CASE_DEFAULT)
{
    modList.clear();

    if (globalModList.empty())
    {
        GetEraMappedModList(globalModList);
    }
    if (toLower && lowerCaseModList.empty())
    {
        lowerCaseModList = globalModList;
        for (auto &modName : lowerCaseModList)
        {
            std::transform(modName.begin(), modName.end(), modName.begin(), ::tolower);
        }
    }
    modList = toLower ? lowerCaseModList : globalModList;

    return modList.size();
}
inline std::vector<std::string> GetEraModList(const BOOL toLower = modList::CASE_DEFAULT)
{
    std::vector<std::string> modList;
    GetEraModList(modList, toLower);
    return modList;
}

} // namespace modList
