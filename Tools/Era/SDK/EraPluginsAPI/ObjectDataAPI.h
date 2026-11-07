#pragma once
#include "RuntimeServices.h"
#include "../Era/JsonObjectExport.hpp"
namespace era_objects
{
constexpr const char *DWELLINGS = "ERA.Services.DwellingData.v1";
struct DwellingApi
{
    unsigned structSize, version;
    EraJS::GetDwellingExportInfo read;
    int (__stdcall *initialize)(const INT16 *, unsigned);
};
}
