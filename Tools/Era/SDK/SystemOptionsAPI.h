#pragma once
#include <windows.h>

namespace system_options
{
constexpr const char *PLUGIN_NAME = "ERA_SystemOptionsExtension.era";
constexpr const char *SETTINGS_FILE = "Runtime/era_system_options.ini";

enum SetResult : int
{
    SAVE_FAILED = -3, // Applied in memory; retry with SaveOptions.
    REJECTED = -2,    // Combat dialog reconstruction or unavailable sound driver.
    UNKNOWN_KEY = -1,
    UNCHANGED = 0,
    CHANGED = 1,
};
using GetOptionValue = int(__stdcall *)(const char *key);
using SetOptionValue = int(__stdcall *)(const char *key, int value);
using SaveOptions = BOOL(__stdcall *)();
// Resolve the three exports by their undecorated names with GetProcAddress.
// See ERA_SystemOptionsExtension/README.md for supported keys and ranges.
}
