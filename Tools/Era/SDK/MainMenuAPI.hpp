#pragma once
#include <windows.h>

/**
 * @namespace mainmenu
 * @brief Provides API for manipulating Heroes of Might and Magic III main menu interface
 */
namespace mainmenu
{
class H3DlgCaptionButton;

/**
 * @enum eMenuFlags
 * @brief Specifies the menu context where a widget should appear
 * @details Uses bit flags to allow combining multiple menu contexts
 */
enum eMenuFlags : INT
{
    MAIN = 0x1,      ///< Main menu screen
    NEW_GAME = 0x2,  ///< New game menu
    LOAD_GAME = 0x4, ///< Load game menu
    CAMPAIGN = 0x8,  ///< Campaign selection menu
    ALL = 0xF,        ///< All menu screens (combination of all flags)
	ON_TOP = 0x10,   ///< Widget should appear on top of other UI elements
	AT_BOTTOM = 0x20 ///< Widget should appear at the bottom of other UI elements
};
/**
 * @struct MenuWidgetInfo
 * @brief Configuration structure for registering a new menu widget
 */
struct MenuWidgetInfo
{
    const char *name = nullptr;           ///< Unique identifier for the widget
    const char *text = nullptr;           ///< Display text of the widget
    eMenuFlags menuList = eMenuFlags::MAIN; ///< Menu context(s) where the widget should appear
    int (__fastcall * customProc)(void *msg);           ///< Callback function triggered when widget is clicked
};

/**
 * @typedef TMainMenu_RegisterWidget
 * @brief Function type for registering a new menu widget
 * @param info Configuration structure for the widget
 * @return TRUE if registration succeeded, FALSE otherwise
 */
typedef BOOL(__stdcall *TMainMenu_RegisterWidget)(const MenuWidgetInfo &info);

/**
 * @typedef TMainMenu_GetDialogButton
 * @brief Function type for retrieving a dialog button by name
 * @param name Unique identifier of the button
 * @return Pointer to the button object if found, nullptr otherwise
 */
typedef H3DlgCaptionButton *(__stdcall *TMainMenu_GetDialogButton)(const char *name);

/**
 * @typedef TMainMenu_GetDialogButtonId
 * @brief Function type for retrieving a dialog button's ID
 * @param name Unique identifier of the button
 * @return Button ID if found, 0 otherwise
 */
typedef int(__stdcall *TMainMenu_GetDialogButtonId)(const char *name);

/**
 * @typedef TMainMenu_SetDialogButtonText
 * @brief Function type for updating a dialog button's text
 * @param name Unique identifier of the button
 * @param text New text to display on the button
 * @return TRUE if text was updated successfully, FALSE otherwise
 */
typedef BOOL(__stdcall *TMainMenu_SetDialogButtonText)(const char *name, const char *text);

/**
 * @brief Name of the plugin DLL that implements the Main Menu API functionality
 */
static constexpr LPCSTR _PLUGIN_NAME = "Interface_MainMenuAPI.era";

/**
 * @brief Helper macro for declaring plugin functions
 * @details Creates an inline function that dynamically loads and calls the corresponding function from the plugin DLL
 * @param name Name of the function to declare
 * @param returnType Return type of the function
 * @param argTypes Type of the function arguments
 * @param argNames Names of the function arguments
 */
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

// Function declarations for menu operations:
DECLARE_PLUGIN_FUNC(MainMenu_RegisterWidget, BOOL, const MenuWidgetInfo &info, info)
DECLARE_PLUGIN_FUNC(MainMenu_GetDialogButton, H3DlgCaptionButton *, const char *name, name)
DECLARE_PLUGIN_FUNC(MainMenu_GetDialogButtonId, int, const char *name, name)

inline BOOL MainMenu_SetDialogButtonText(const char *name, const char *text)
{
    HINSTANCE hApi = LoadLibraryA(_PLUGIN_NAME);
    if (auto func =
            reinterpret_cast<TMainMenu_SetDialogButtonText>(GetProcAddress(hApi, "MainMenu_SetDialogButtonText")))
    {
        return func(name, text);
    }
    return 0;
}

} // namespace mainmenu
