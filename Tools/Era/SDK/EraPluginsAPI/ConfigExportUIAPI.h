#pragma once
#include "RuntimeServices.h"
namespace era_config_ui
{
constexpr const char *SERVICE = "ERA.Services.ConfigExportUi.v1";
enum Mode : unsigned { Configuration = 0, Translations = 1 };
struct Api { unsigned structSize, version; int (__stdcall *open)(unsigned mode); };
inline int Open(unsigned mode)
{ const auto *api = era_services::Find<Api>(SERVICE); return api && api->open ? api->open(mode) : 0; }
}
