#pragma once
#include <windows.h>
namespace mainmenu
{
class H3DlgCaptionButton;

enum eMenuList : INT
{
    MAIN = 0x1,
    NEW_GAME = 0x2,
    LOAD_GAME = 0x4,
    CAMPAIGN = 0x8,
    ALL = 0xF
};
struct MenuWidgetInfo
{
    const char *name = nullptr; // Renamed from id
    const char *text = nullptr;
    eMenuList menuList = eMenuList::MAIN;
    void (*onClick)(void *msg);
};

typedef BOOL(__stdcall *TMainMenu_RegisterWidget)(const MenuWidgetInfo &info);
typedef H3DlgCaptionButton *(__stdcall *TMainMenu_GetDialogButton)(const char *name);
typedef int(__stdcall *TMainMenu_GetDialogButtonId)(const char *name);
typedef BOOL(__stdcall *TMainMenu_SetDialogButtonText)(const char *name, const char *text);

static constexpr LPCSTR _PLUGIN_NAME = "Interface_MainMenuAPI.era";
#define DECLARE_PLUGIN_FUNC(name, returnType, argTypes, argNames)                                                      \
    inline returnType name(argTypes)                                                                                   \
    {                                                                                                                  \
        HINSTANCE hApi = LoadLibraryA(_PLUGIN_NAME);                                                                   \
        if (auto func = reinterpret_cast<T##name>(GetProcAddress(hApi, #name)))                                        \
        {                                                                                                              \
            return func(argNames);                                                                                     \
        }                                                                                                              \
        return 0;                                                                                                      \
    }

// »спользование макроса дл€ объ€влени€ функций:
DECLARE_PLUGIN_FUNC(MainMenu_RegisterWidget, BOOL, const MenuWidgetInfo &info, info)
DECLARE_PLUGIN_FUNC(MainMenu_GetDialogButton, H3DlgCaptionButton *, const char *name, name)
DECLARE_PLUGIN_FUNC(MainMenu_GetDialogButtonId, int, const char *name, name)

inline BOOL MainMenu_SetDialogButtonText(const char *name, const char *text)
{
    HINSTANCE hApi = LoadLibraryA(_PLUGIN_NAME);
    if (auto func = reinterpret_cast<TMainMenu_SetDialogButtonText>(GetProcAddress(hApi, "MainMenu_SetDialogButtonText")))
    {
        return func(name, text);
    }
    return 0;
}

} // namespace mainmenu
