#pragma once
#include <windows.h>

// Resolve the already-loaded plugin; this wrapper never loads another DLL.
// Call on the game UI thread after ERA has initialized its native tables.
namespace era_help
{
enum class Page : int
{
    Mods = 100,
    Hotkeys = 101,
    Creatures = 102,
    Artifacts = 103,
    Towns = 104,
    Heroes = 107,
    SecondarySkills = 108,
    Spells = 109
};
using ShowDialogProc = BOOL(__stdcall *)(Page, int);
using ShowObjectProc = BOOL(__stdcall *)(Page, int);
using ShowObjectHintProc = BOOL(__stdcall *)(Page, int, BOOL);

inline BOOL ShowDialog(Page page = Page::Mods, int category = 0)
{
    const HMODULE plugin = GetModuleHandleA("ERA_HelpDialog.era");
    const auto show = plugin ? reinterpret_cast<ShowDialogProc>(GetProcAddress(plugin, "ERAHelp_ShowDialog")) : nullptr;
    return show ? show(page, category) : FALSE;
}
inline BOOL ShowObject(Page page, int objectId)
{
    const HMODULE plugin = GetModuleHandleA("ERA_HelpDialog.era");
    const auto show = plugin ? reinterpret_cast<ShowObjectProc>(GetProcAddress(plugin, "ERAHelp_ShowObject")) : nullptr;
    return show ? show(page, objectId) : FALSE;
}
// Open only the object's card. TRUE uses native RMB_Show while the right
// mouse button is held; FALSE opens a modal card with OK/Enter/Escape.
// The call returns after the card closes. No library navigation is changed.
inline BOOL ShowObjectHint(Page page, int objectId, BOOL popup = TRUE)
{
    const HMODULE plugin = GetModuleHandleA("ERA_HelpDialog.era");
    const auto show = plugin
                          ? reinterpret_cast<ShowObjectHintProc>(GetProcAddress(plugin, "ERAHelp_ShowObjectHint"))
                          : nullptr;
    return show ? show(page, objectId, popup) : FALSE;
}
} // namespace era_help
