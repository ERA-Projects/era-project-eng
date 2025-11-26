### Version 2.221

#### Game Enhancement Mod:
- Removed the "1" symbol from the top icon in the town list;


### Version 2.220

#### Game Enhancement Mod:
- Updated the "Gameplay_GameplayEnhancementsPlugin.era" plugin to version 1.7.1:
    - Fixed the tooltip disappearing when building construction in cities is complete after the hero movement is complete;
    - Disabled the tooltip display during AI turns to avoid rendering bugs;


### Version 2.219

#### WoG:
- Updated the "wog native dialogs.era" plugin:
    - The active hero window can now be opened in Black Market and Artifact Merchant dialogs;

#### WoG Scripts:
- Monster Week: A relevant image is now displayed when a new week begins;


### Version 2.218

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.27:
    - Fixed a desynchronization bug in PvP network combat that occurred when one client’s CPU supported SSE 4.2 while the other did not. The two systems were using different CRC‑32 hashing algorithms, which caused mismatched state updates. The patch normalises the hashing routine and updates the exported `Hash32` function so that it produces identical results on all platforms regardless of CPU capabilities.
    - Fixed text truncation in multiline text dialogs.

#### WoG:
- Updated "game bug fixes extended.dll" plugin:
    - Fixed a crash during AI morale calculations in an army with the Angel Alliance;

#### Game Enhancement Mod:
- Updated the "Gameplay_GameplayEnhancementsPlugin.era" plugin to version 1.7.0:
    - Added additional building construction status icons to the Adventure Map and City View windows:
        - All built — yellow checkmark;
        - Buildings available for construction, but not enough money — crossed-out gold coins;
        - Buildings available and sufficient resources — hidden icon;
        - Controlled via the "gem_plugin.building_hints.enable" json key;
### Version 2.217

#### WoG:
- Updated "wog native dialogs.era" plugin:
    - Fixed memory leaks and crashes in dialogs with dynamic font changes;
    - Added "Esc" hotkey to close the WoG options menu;
- Updated "Interface_MainMenuAPI.era" plugin to version 1.6:
    - Added the ability to easily sort added buttons:
    ```
    Added 2 flags for widgets:
    ON_TOP - to display the widget closer to the top of the list;
    AT_BOTTOM - to display widgets closer to the bottom of the list;
    ```
    - Updated API for the relative directory "Tools/Era/SDK/MainMenuAPI.hpp";
    - Minor fixes;
- Updated the "Assembly_MainPlugin.era" plugin to version 1.82:
    - Added support for the new API;
    - The "Notifications" button in the main menu is now displayed as low as possible;
- Updated the "RMG_CustomizeObjectProperties.era" plugin to version 1.29:
    - Added support for the new API;
    - The "Generation Settings" button in the main menu is now displayed as low as possible and only in the "Singleplayer" menu;
- Updated the "ERA_MultilingualSupport.era" plugin to version 2.3:
    - Added support for the new API;
    - The "Language" button in the main menu is now displayed as high as possible;


### Version 2.216

#### WoG:
- Updated the "game bug fixes extended.dll" plugin:
    - Added even better compatibility with the "Typhon" plugin;
    - Fixed creatures gaining experience outside of battle (for example, the "start heroes at level 5" option);
    - Fixed creatures not being able to gain experience if the hero's level reached the maximum for the map;

#### Game Enhancement Mod:
- Updated the "Gameplay_GameplayEnhancementsPlugin.era" plugin to version 1.6.4:
    - In "Hot-Seat" mode, added interface elements are now correctly colored in the human player's color (even before a turn is accepted);
- Re-enabled the display of a message about a hero reaching the maximum level. This message will only appear once for each hero.


### Version 2.215

#### ERA ERM Framework:
- Added a new function that allows you to get a list of active mods (names of folders with mods):
    ```
    !?FU(GetModList);
    !#VA(arrayId:x); returns string array of the loaded mods (list.txt)
    !#VA(toLower:x); OPT set mod name to lower case or keep original; is FALSE by default
    !#VA(reverse:x); OPT reverse mod list order; is FALSE by default
    ```

#### Game Enhancement Mod:
- Restored optimal game version acquisition;
- Minor internal function fixes;

#### WoG:
- Updated "game bug fixes extended.dll" plugin:
    - Fixed a crash when attacking creatures in melee combat with the "ERA+" mod active;


### Version 2.214

#### WoG:
- Updated "game bug fixes extended.dll" plugin:
    - Fixed a crash when attacking creatures in melee combat with the "ERA+" mod active;

#### TrainerX:
- Fixed recalculation of hero movement points after closing a dialogue;

#### WoG Graphics Fix Lite:
- Mod updated to version 2.23.0;

### Version 2.213

#### WoG Scripts:
- Sorcery I: Fixed several objects setup corruption caused by remote visit;


### Version 2.212

#### ERA ERM Framework:
- Fixed constants for hero class indices;

#### WoG Graphics Fix Lite:
- Fixed the passability mask for the "Town Gate" object;


### Version 2.211

#### Other:
- SD Mod Manager (@SyDr) updated to version 0.98.69:
    - Added compatibility with Heroes Launcher v1.2.0;
    - Added a "Create new mod" option in the "Tools" tab;


### Version 2.210

#### WoG:
- Updated the "RMG_CustomizeObjectProperties.era" plugin to version 1.28:
    - added functionality of the plugin without HD Mod;
    - Fixed duplicate creature banks in the object settings dialog;
    - Artifacts that are part of collections can no longer be quest objects on random maps;
- Minor localization fixes;

#### Game Enhancement Mod:
- Removed duplicate code for old fixes and changes;


### Version 2.209

- hotfix


### Version 2.208

#### WoG:
- Updated "game bug fixes extended.dll" plugin:
    - Fixed lycanthropy vulnerability check for commanders and gods;
    - Optimized lycanthropy mechanics in quick combat;
    - Removed immunity to fire magic from Ghosts and Messengers of all elements;
- Corrected the name and description of the "Ghosts" unit;


### Version 2.207

#### Game Enhancement Mod:
- добавлена заглушка "StartArmyAllSlots.bin" для избежания вылета на старте игры;

#### Other:
- removed extra files;


### Version 2.206

#### WoG:
- updated the "AssemblyMainPLugin.era" plugin to version 1.81:
    - now the notification panel is hidden when viewing "Credits";
    - fixed the incorrect display of the colored strip under the notification name if the text is too long;
- updated the "game bug fixes extended.dll" plugin:
    - now when hovering over monsters with the "Vision" spell, their exact number is shown in the status bar;
- updated the "RMG_CustomizeObjectProperties.era" plugin to version 1.27:
    - fixed the inoperability of new objects;

#### Game Enhancement Mod:
- updated the "GameplayEnhancementsPlugin.era" plugin to version 1.6.3:
    - fixed a crash from the game when viewing information about artifacts after a meeting of two heroes;


### Version 2.205

#### WoG:
- updated plugin "game bug fixes extended.dll":
    - fixed pikemen spawning in refugee camps;
    - now in player's towns if there is a fort there will always be 2 levels of creatures built;
    - now heroes always have 3 units of creatures at the start;
    - fixed infinite loop when calculating army value for exchanging creatures in the AI ​​army;
    - now AI will always receive artifacts and experience for a defeated enemy;
    - improved negative luck code;
    - fixed display of unexplored monoliths and underworld gates when casting View Earth/Air;
    - fixed saving of extra berserk round and defense on unit;
    - blocked ability to cast Dimension Door in inaccessible zones and to the same position where the hero is;
    - fixed possibility of vampirism when attacking clones;
    - sacrificed Phoenixes are no longer resurrected;
    - daemonic resurrection now places a sacrifice flag on the killed unit;
- updated "wog native dialogs.era" plugin:
    - View Earth and View Air effects are now saved until the end of the player's turn, information is available through the View World screen;
- updated "RMG_CustomizeObjectProperties.era" plugin to version 1.26:
    - rewritten logic for adding Extenders for future support of plugin modularity;
    - improved function for getting object names;
    - API update;
- updated "Interface_MainMenuAPI.era" plugin to version 1.5:
    - hotkeys [1;0] are now available for the first ten buttons;
- corrected description of Arch Devils;

#### Game Enhancement Mod:
- updated the "GameplayEnhancementsPlugin.era" plugin to version 1.6.2:
    - the mechanics of the hint for the cost of moving heroes to objects on the map have been improved and transferred to the plugin;
- removed the StartArmyAllSlots binary, since the logic has been moved to the "WoG" mod;


### Version 2.204

#### WoG:
- updated plugin "game bug fixes extended.dll":
    - added fix for double damage for Ballista shots and "Double Damage" skill like Death Knights;
    - limited number of crypts per zone for random maps to 5;

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era" to version 1.6.1:
    - minor fix for artifact tooltip;

#### Random Wallpaper Mod:
- Added new logo with game name;


### Version 2.203

- hotfix


### Version 2.202

- hotfix


### Version 2.201

#### Game Enhancement Mod:
- artifact tooltips are now enabled by default;

#### WoG Scripts:
- Enhanced Commander Artifacts: Added support for displaying artifact tooltips;

#### TrainerX:
- Added support for displaying artifact tooltips;

#### Other:
- SD Mod Manager (@SyDr) updated to version 0.98.67;


### Version 2.200

#### WoG:
- updated plugin "Interface_MainMenuAPI.era" to version 1.4:
    - now the called function of the widget processing procedure has a fixed calling convention (__fastcall) and return type int:
    ```
    int (__fastcall * customProc)(void *msg);
    ```
- updated plugin "wog native dialogs.era":
    - fixed display of commander's power stone messages after their selection;
    - fixed response check for input dialogs of the "Sphinx" type;
    - fixed display of battle rounds at the start of a battle without a tactical phase;
    - now visiting mithril works as with the original refreshes the screen;
    - now the text of the message about the army reduction, caused by the Conflux commander (Astral Spirit) is written directly to the battle log, and the message about the army return is removed;
- updated plugin "game bug fixes extended.dll":
    - fixed numerous bugs with non-updated maximum points of hero movement and a number of shortcomings in calculating the length of the path;
    - added accounting for the reset of the effects of Stables when calculating the required number of days of travel;
    - now changing the radius of the hero's scouting opens the map in a timely manner;
    - fixing the SoD bug: resetting the number of sirens visited after the battle;
    - fixed incorrect construction of the hero's route;
    - fixed excessive redrawing of the "Move hero" button;
    - fixed a bug with cloning monsters when reaching the monster limit.
    - changing the balance of forts on hills: the cost of improvement is calculated based on the level of the upgraded monster, not the current one;
    - fixing the calculation of gold for the Beast after the battle;
    - adjusting the parameters of the Commander with the Ring of Power (Slavas's Ring);
    - Commanders no longer summon war machines in creature Banks (WoG bug);
    - The formula for summoning dragons using the "Dragon Heart" artifact has been replaced;
    - Incorrect deletion of disappearing objects from the game's memory has been fixed;
    - SoD bug has been fixed: AI thought that the death cloud only does not affect the undead creatures.
    - The presence of poison now prevents you from casting Spell Dispell;
    - Shackles of War now only work in battles between two heroes (run);
    - The speed of quick battles has been significantly increased (previously the game "waited" for the animation of any action to play)
    - Fixed the triggering of the fire shield on a corpse;
    - Fixed the active side of the battle during a counterattack in close combat;
    ## The logic of Positive and Negative Luck has been rewritten:
        - Support for "Negative Luck" has been implemented, reducing the final damage by exactly 2 times;
        - Triggered Positive or Negative Luck now changes damage to all targets of the strike, and not just one;
        - Triggered "Positive luck" in battle now increases damage exactly 2 times, and does not add +100% to only the base damage;
        - now the Hourglass of the Evil Hour neutralizes Positive luck only;
        - Fixed the lack of display of the Hourglass of the Evil Hour influence in the list of hero luck modifiers and the AI's assessment of some luck-changing objects

#### Game Enhancement Mod:
- Added display of primary skills bonuses for artifacts when viewing its description;
- Added the ability to manage the following options in the GEM settings menu:
    - Display of the bonus of primary skills for artifacts;
    - Display of parts for combined artifacts;
- Updated the formula for calculating movement on the next turn and moved to the plugin;
- Moved a significant amount of code from scripts to the plugins;
- When viewing tooltips about objects, heroes are no longer displayed on "Alt";

#### ERA ERM Framework:
- the following functions have been added:
    - Getting the current name of the hero portrait (small and large):
    ```
    !?FU(GetHeroPortraitName);
    !#VA(heroId:x) (small:x) (large:x);
    ```
    - Centering the custom DL dialog at the cursor;
    ```
    !?FU(DL_CenterAtMouse);
    !#VA(dlgId:x);
    ```

#### TrainerX:
- fixed a crash when transferring commander artifacts to heroes;

#### WoG Scripts:
- War Machines III: numerous displaying of the current number of combat vehicles have been added to the hero and meeting window;
- Enhanced Commanders: Fixed a bug that disabled subtype 6 chests;
- Mithril: Fixed the time it takes to add mithril to the player's treasury;

#### ERA Scripts:
- Capturing Mills and Gardens: Fixed the lack of shadows and incorrect flag positions for Resource Warehouses;


### Version 2.199

#### WoG:
- updated the "AssemblyMainPLugin.era" plugin to version 1.79:
    - minor fixes;

### Version 2.198

#### WoG:
- updated the "AssemblyMainPLugin.era" plugin to version 1.78:
    - The notification panel now correctly displays the notification text;
    - The frame around the mod text has been changed;
{~cphx.def:0:0 valign=top}
#### Human AI:
- Updated to version 1.17;

#### WoG Scripts:
- minor text corrections;


### Version 2.197

#### WoG:
- updated the "Interface_MainMenuAPI.era" plugin to version 1.3:
    - now the button for hiding the additional buttons menu is not displayed when this menu is placed outside the background of the main menu;
    - the position and names of some buttons have been changed;


### Version 2.196

#### WoG:
- updated the "AssemblyMainPLugin.era" plugin to version 1.77:
    - the system cursor is no longer displayed when hovering over the notification button;
- updated the "Interface_MainMenuAPI.era" plugin to version 1.2:
    - now the system options dialog opened via the button in the main menu does not display images for unused dialog buttons;
- the text of additional buttons in the main menu has been brought to a single format;
- unnecessary/incorrect localization files have been removed;


### Version 2.195

#### WoG:
- plugin "ERA_MultilingualSupport.era" updated to version 2.1:
    - fixed impossibility to translate monster names in plural using json keys;
    - optimized text size for "Export text" button in language selection dialog;


### Version 2.194

#### WoG:
- updated the plugin "Interface_MainMenuAPI.era" to version 1.1:
    - fixed incorrect display of the System Options and WoG Options menu in the main menu when playing a video;
    - fixed incorrect background when hiding buttons after opening the main menu after starting a map;
    - added comments to the API plugin header file;
- updated the plugin "wog native dialogs.era" without changing the version:
    - fixed the game window breaking after opening the hero meeting dialog in the city window;


### Version 2.193

#### HD Mod:
- Updated to version 5.5 R71;

#### WoG:
> [!NOTE]
> added a new plugin "Interface_MainMenuAPI.era", allowing you to add your own buttons to the main menu using:
> - API for creating and managing buttons in the main menu;
> - allows you to add buttons to the general list of stylized buttons in different dialogs of the main menu, which are specified via the id bit set:
> ```cpp
> enum eMenuList : int
> {
>     MAIN = 0x1, // main menu
>     NEW_GAME = 0x2, // submenu for selecting a new game
>     LOAD_GAME = 0x4, // submenu for loading a game
>     CAMPAIGN = 0x8, // campaign submenu
>     ALL = 0xF // all menus at once
> };
> ```
> - button registration is performed by the "MainMenu_RegisterWidget" function via a unique widget name
> ```cpp
> struct MenuWidgetInfo
> {
>     const char *name = nullptr; // unique widget name
>     const char *text = nullptr; // button display text
>     eMenuList menuList = eMenuList::MAIN; // set of menus in which to display the button
>     void (*processMessage)(void *msg); // main processing procedure
> };
> ```
> > - button registration is performed by the "MainMenu_RegisterWidget" function via a unique widget name
> ```cpp
> int (__stdcall *MainMenu_RegisterWidget)(const MenuWidgetInfo &info);
> ```
> - the following functions allow you to manage already registered widgets:
> ```cpp
> H3DlgCaptionButton *(__stdcall *MainMenu_GetDialogButton)(const char *name); // returns a pointer to the button created in the current dialog
> int (__stdcall *MainMenu_GetDialogButtonId)(const char *name); // returns the id of the button created in the current dialog
> int (__stdcall *MainMenu_SetDialogButtonText)(const char *name, const char *text); // changes the displayed text of the button. If the button is currently drawn, the text will change on the screen
> ```
> - the header for this API is located at "Tools/Era/SDK/MainMenuAPI.hpp";
> - the following buttons have been added to the main menu:
    > - Hide the button menu;
    > - Show system options;
    > - Show the WoG-Options menu (can be changed and saved)

- ### plugin "ERA_MultilingualSupport.era" updated to version 2.0:
    - Now the names of folders for languages are based on the "iso-639-1" format;
    - to add your own language, simply specify the locale name in the json key:
    ```
    "era.locale.list.[locale_name].name":string,
    ```
    - it is also possible to specify an alternative locale name, for this a key is used, but then the alternative name must have its own json key in the "name" field:
    ```
    "era.locale.list.[locale_name].alternative":string,
    "era.locale.list.[alternative_name].name":string,
    ```
    - the language selection dialog has been rewritten and the main launch button has been moved;
    - the ability to change the language from the system settings menu has been removed;
    - added the ability to translate text from the following txt files using json keys:
        - HeroBios.txt
        - HeroSpec.txt
        - Dwelling.txt
        - Since these files are read when the game is launched, after changing the language in the game, it will need to be restarted so that the new text (if it exists) is written to the game's memory over the names from the txt files;
        - The keys for translating strings are as follows
            - for Heroes, name, biography, and specialization text can be replaced:
            ```
            "era.heroes.[hero_id].name": string,
            "era.heroes.[hero_id].biography": string,
            "era.heroes.[hero_id].specialty.short": string,
            "era.heroes.[hero_id].specialty.full": string,
            "era.heroes.[hero_id].specialty.description": string,
            ```
            - for city dwellings, names and descriptions can be replaced. Index "-1" is used for a random town:
            ```
            "era.towns.[town_type].dwellings.[dwelling_id].name": string,
            "era.towns.[town_type].dwellings.[dwelling_id].description": string,
            ```
    - added the ability to export the following data to separate json files in the "Runtime/Exports/" subfolder via a separate "Export text" button in the language selection dialog:
        - names and descriptions of creatures;
        - names, biographies and specializations of heroes;
        - names of creature dwellings on the Adventure Map and in cities;
        - names and auxiliary texts of creature banks;
        - names, descriptions and text when selecting artifacts;
        - names of adventure map objects;

- The names and descriptions of creatures have been brought to a common form for greater information content;
- names and descriptions of creatures in json format have been added for English and Russian;
- fixed placement of creatures in the Nativity Scene;
- updated plugin "game bug fixes extended.dll":
    - fixed display of cursor shadow for the "Force Field" spell for the defender hero;

#### WoG Scripts:
- fixed function for checking the admissibility of a building for construction in the city;

#### Game Enhancement Mod:
- minor function fixes;

#### ERA Scripts:
- removed unnecessary and non-working fixes;
- file optimization;

### Version 2.192

> [!NOTE]
> the crash report tool — **Issue Wizard** — has been updated to version 1.3:
> - improved program design;
> - added the ability to attach all necessary debug files (Recommended);
> - improved algorithm for collecting unique error information;
> - added display of the list of plugins and game resolution;
> - reduced the amount of information stored on the disk;
> - fixed the inability to receive information about outdated reports;
> - minor corrections to text formatting;

#### WoG:
- updated some plugins to decouple from runtime libraries;
- minor fixes and improvements;

#### Other:
- SD Mod Manager - added standard profiles with lists of ERA Project mods;


### Version 2.191

#### WoG:
- updated some plugins to support older OS;

#### Other:
- SD Mod Manager (@SyDr) updated to version 0.98.67

### Version 2.190

#### WoG:
- updated plugin "wog native dialogs.era" without version change:
  - fixed a crash when starting the game and opening the WoG Options save settings dialog;
  - other fixes;


### Version 2.189

#### WoG:
- updated plugin "AssemblyMainPlugin.era" to version 1.75:
  - each mod can now add up to 5 notifications to the main menu. The mod folder name must be in lowercase. Keys:
    ```"era.[mod_folder_name].notification.[index].name" - display name
    "era.[mod_folder_name].notification.[index].text" - notification text
    "era.[mod_folder_name].notification.[index].url" - link to a website or local file to open
    ```
    - improved localization and integration with the notification panel;
    - added a notification about known issues;

#### Game Enhancement Mod:
- updated plugin "ArchBugFixes.era":
  - fixed an issue where level 1 creatures could be obtained infinitely from their dwellings on the Adventure Map;


### Version 2.188

#### ERA Scripts:
- Capture of mills and gardens: added player flags for Mithril Warehouses;

#### WoG Graphics Fix Lite:
- removed unnecessary texts with objects;
- optimized archives with graphics;


### Version 2.187

#### WoG:
- updated plugin "AssemblyMainPLugin.era" to version 1.74:
    - now notifications in the main menu are translated without restarting the game/menu;

#### Game Enhancement Mod:
- removed unnecessary code for managing creature hiring dialogues;


### Version 2.186

#### Advanced Classes Mod:
- fixed crash in battle at low resolutions of the game window when trying to open the dialog for upgrading the commander's class;

#### Other:
- Mod Manager has been updated to version 0.98.61;


### Version 2.185

#### WoG:
- updated plugin "Game bug fixes extended.dll":
    - now when casting targeted attack spells by monsters, the magic modifier from the hero-owner is taken into account;


### Version 2.184

#### Other:

> [!IMPORTANT]
> ## the new Mod Manager is now used by default:
> - major mods have been added to the compatibility list for automatic conflict resolution (launch the Mod Manager and click the "Sort" button in the bottom-left corner);

> [!NOTE]
> the crash report tool — **Issue Wizard** — has been updated to version 1.2:
> - improved program design;
> - more detailed issue description added;
> - minor text formatting fixes;

#### WoG:
- updated plugin "Game bug fixes extended.dll":
  - fixed a bug preventing a hero from casting flying spells again on the same day if the spell's power exceeds the current effect;
  - fixed Uland incorrectly having the Advanced Wisdom skill;
  - fixed sound loading for Fairy Dragons' spellcasting;
  - fixed missing "Splash Attack" flag for Dracoliches.


### Version 2.183

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era" to version 1.5.0:
    - minor fixes with display of mithril in the Kingdom Overview window;
    - debug file added;


### Version 2.182

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era" to version 1.24:
    - fixed getting list of new objects for from nested arrays;

#### Advanced Classes Mod:
- fixed crash in battle at low resolutions of the game window when trying to open the dialog for upgrading the commander's class;

#### Game Enhancement Mod:
- now the tooltip about the cost of the surrendering will not be displayed in cases where surrendering is unavailable;

#### Other:
> [!NOTE]
> new tool for sending crash reports - **Issue Wizard** updated to version 1.1:
> - added more detailed issue title;
> - increased minimum message length;
> - minor text formatting fixes;


### Version 2.181

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era" without changing the version:
    - added export function to get object name by type and subtype:
    ```
    const char* GetObjectName(int type, int subtype);
    ```
- updated plugin "wog native dialogs.era" without changing the version:
    - rebuilt with a different set of tools so that antiviruses don't complain;

#### WoG Scripts:
- Sorcery I: now remote visiting of objects allows interaction with Resource Warehouses;
- Added function to get the name of objects added by RMG plugin:
    ```
    !?FU(WOG_GetRealObjectName);
    !#VA(objType:x) (objSubtype:x) (string:x);
    ```
- other important fixes;

#### ERA Scripts
- Capture of mills and gardens:
    - now the capture mechanics also apply to Resource Warehouses;
    - the logic of interaction with all objects has been completely rewritten;


### Version 2.180

- ## update era.dll core without changing the version:
    - updated debugging tool;

#### Other:
- updated plugins debug files;


### Version 2.179

#### WoG:
- updated plugin "AssemblyMainPLugin.era" without changing the version:
    - small improvements;
- Added zip archive with packed json files in order to prevent game crash at the start;


### Version 2.178

#### WoG:
- updated plugin "AssemblyMainPLugin.era" without changing the version:
    - fixed rare Main Menu Crash;


### Version 2.177

## hotfix


### Version 2.176

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.26:
    - Implemented detailed game context dumping in "exception context.txt" on crash
    - Fixed bug in hooked Heroes 3 "free" function: WoG static addresses were not excluded from processing, which leaded to corrupted counter of allocated bytes and random crashes.

> [!NOTE]
> A new tool has been added to the build for reporting game crashes — **Issue Wizard**:
> - Launches automatically after a crash or manually from the "/Tools/Issue Wizard/" folder;
> - Collects technical information about the issue;
> - Includes a text field for describing events leading up to the crash;
> - Allows attaching a save file;
> - Creates a unique report on the project repository and returns a link to it (the report);
> - Requires an internet connection to work.

#### WoG:
- updated the "AssemblyMainPLugin.era" plugin to version 1.73 and placed in the "WoG" mod:
> [!TIP]
> ### Added the ability to display notifications in the Main Menu for each mod:
> - Now mod authors can add their own notifications to the main menu, which can only be controlled by updating their own mod;
> - To add a notification, you need to add the following json keys, where [mod_folder_name] is the name of the active mod folder:
>    ```
>    "era.[mod_folder_name].notification.name" - to display the notification name;
>    "era.[mod_folder_name].notification.text" - to display the notification text;
>    "era.[mod_folder_name].notification.url" - to open an external file or follow an external link when clicking on the notification name;
>    ```
>    - Colored text and display of def images with replacement by PNG are supported;
>    - Once hidden notification will not be forced to be displayed until its text is changed;
- Now the game build version is tied to the WoG mod;
- all new elements are displayed only in the main menu dialog;

- updated plugin "RMG_CustomizeObjectProperties.era" without changing the version:
    - fixed AI behavior for some new objects;

#### Advanced Classes Mod:
- Most abilities that reduces/steals creature stats on the battlefield now can only set the Speed to minimum of 3 (instead of 2).
- Estates Specialists now provides 5% bonus to the gold of Estates each level.
- Fixed messy Ammo Cart description.
- Fixed the issue that Fire Mage not attacking with Fire Ball sometimes.
- Fixed the compatibility between Nobility and 8th Creatures (from Third Upgrade Mod).
- Fixed the issue of unexpected resistance effect in all the scenarios (thanks to daemon_n and Yuritsuki).
- Fixed wrong Estates effect for Estates specialists.
- Temporarily fixed the issue of getting wrong speed by using Hunter class. The solution should be tweaked later.
- Fixed wrong description of General commander.
- Eagle Eye can no longer kill an entire stack of creatures (minimum HP is now 1). This prevents potential game freezes when the last enemy stack is eliminated by Eagle Eye.
- Fixed an issue with spell piercing—it now works correctly against spell-immune targets.
- Fixed a bug where +350 gold specialists were providing more resources than their speciality description indicated.
- Fixed multiple issues with the Fire Mage commander class:
    - They now receive kill counts normally.
    - They cannot advance to the Ancient class if it is not unlocked in the game.
    - They no longer skip advancement opportunities to Ancient in certain cases.
- Booby Trap for Ammo Carts now triggers after the Ammo Cart is destroyed, instead of before.

#### Advanced Difficulties Mod:
- Updated to version 1.042
    - replaced monster arts from the splash screen with upscaled versions (thanks to Suft - the HD Remastered god)
    - increased the default growth limit of neutral stack size when the grow beyond 4000 option is activated
    - slighty reduced the speed and damage scaling of battle commanders, also removed the possibilty that they spawn with active Prayer spell
    - fixed grow beyond 4000 option for level 0 monsters on the map

#### Enhanced Henchmen:
- Warlord's Banner equipped by a henchman now behaves like commander artifacts on commanders: You can equip or unequip it freely when the henchman is killed. The banner will stay with the henchman even if the hero loses a battle.

#### ERA Scripts
- Battle Experience: Fixed wrong creature stats after battle replay.

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
    - Added mithril displayment into Adventure Map and Kingdom Overview dialogs;
- Fixed a bug where sometimes a hero could appear in a tavern even when already recruited by another player.
- Now the retaliation of Ballista and Catapult are completely blocked.
- Removed the message when successfully recruiting level 1 creatures from their dwellings - thanks to SadnessPower.
- removed extra plugin and assets;

#### TrainerX:
- Added a temporary method of removing Boats for Remove Object feature.
- Teleport: Heroes can no longer be teleported to tiles that would clearly disrupt the game.

#### WoG Graphics Fix Lite:
- Updated to version 2.22.0

#### WoG Scripts:
- Estates I&II: Fixed details for Estates specialists
- Treasure Chest 2: Fixed a bug that occupying the last mine through Treasure Chest 2 might result in not possible to beat a map.
- Possibly fixed the unknown error when using HE:S commands in scripts.
- Transfer owner now works once per week for each mine or town. This is to prevent spamming battles.
- Master of Life no longer upgrades creatures owned by heroes with no owner.
- Fixed the text description error of Scouting II.
- Fixed Learning I not showing which primary skill is granted when a hero gains a new level.
- Resistance I: You can now set i^wog_216_nonNeutralBattle_enabled^ to TRUE to make Resistance I work in all types of battles.
- Sorcery I: Fixed the crash when right-clicking on a Scholar that gives a spell.


### Version 2.175

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era" to version 1.23:
- added the ability to have a modified appearance of the Creature Bank depending on its level;

#### Other:
- updated plugins to support older versions of operating systems;


### Version 2.174

#### WoG:
- updated the "RMG_CustomizeObjectProperties.era" plugin to version 1.22:
    - now after saving the game, the array of custom awards will not be re-created;
    - fixed display of names and descriptions for some objects;
    - fixed inability to change object generation limits in the dialog if the entered value is already 0;

#### Game Enhancement Mod:
- compatibility with other mods has been added to the script for setting new hero sprites in battle

    
### Version 2.173

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era" to version 1.21:
    - Added support for adding up to 4 specific artifacts as a reward to the Creature Bank;
    - fixed an error with filling the array with random artifacts;
    - fixed an error reading the key with a chance of upgraded creatures for guards;


### Version 2.172

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era" to version 1.20:
    - help dialog message replaced with a full-fledged dialog;
    - added link to the tool for creating and editing Creature Banks;
    - improved dialog hints for some objects;
    - added the ability to limit skills in universities;
    - added the ability to create magic shrines with a specific spell (type 89/subtype - spell id +1)
    - fixed crash when trying to display a dialog with rewards for plundering a Creature Bank without original rewards;
    - fixed crash when generating spells for creature banks;
- updated plugin "game bug fixes extended.dll":
    - fixed bug with registering university visits by players;


### Version 2.171

#### WoG:
- updated the plugin "ERA_MultilingualSupport.era" to version 1.07:
    - changed the format for displaying localization names;
    - fixed the address for receiving creature dwellings for localization from json;
    - fixed incorrect pointers to creature names set from outside;
- updated the plugin "RMG_CustomizeObjectProperties.era" to version 1.18:
    - added support for custom rewards for any creature bank:
        - mithril;
        - experience;
        - spell points;
        - primary parameters;
        - morale;
        - luck;
        - spells (up to 4):
            - ability to specify the exact index of the spell;
            - ability to specify parameters for generating spells;
## more details in the help inside the RMG dialog
    - Now the plugin allows you to edit the protection and reward of the original creature banks, and not just the added ones;
    - Now the data entered in the RMG dialog does not require extra clicks for confirmation and changes immediately when entering numbers;
    - fixed a crash when generating spell scrolls;
- renamed and reformatted almost all json files of the mod;
- fixed mixed up portraits of some monsters when playing with hd mod;

#### ERA Scripts:
- Use of Scrolls, Banners and Artifacts: Fixed not giving proper amount of spell points when dismantling spell scrolls.

#### WoG Scripts:
- Prevent placing Lost Bottles when the passability isn't ideal (as Lost bottles cannot be visited from above)
- Fixed banned spells cannot appear in Shrines no matter what combination of wog options.
- Fixed not possible to ban View Earth from heroes' starting spells.
- Fixed not possible to ban Barbarian's Axe of Ferocity.
- Enhanced War Machines I:
    - Fixed not possible to disable the war machines summoned by Hierophants and Ogre Leaders.
    - Fixed data sync in multiplayer games.
    
#### WoG Graphics Fix Lite:
- Updated to version 2.21.0

#### Other:
- updated sources and SDK of the Era kernel;
- Edited json file names according to the standard;


### Version 2.170

#### HD-Mod:
- updated up to 5.5 R44


### Version 2.169

- hotfix


### Version 2.168

#### WoG:
- updated plugin "wog native dialogs.era":
    - removed debug message before opening some dialogs with pictures;


### Version 2.167

#### Game Enhancement Mod:
- updated plugin "ChooseAttack.dll":
    - removed question about auto battle start
    - attempt to fix some crashes


### Version 2.166

- hotfix


### Version 2.165

#### ERA:
- ## update of era.dll kernel without changing the version:
    - Exported the following functions in era.dll:
        - procedure LogMemoryState
        - Appends entry to "log.txt" file in the following form: >> [EventSource]: [Operation] #13#10 [Description]:
            - function WriteLog (EventSource, Operation, Description: pchar): TInt32Bool;
            - Example:
            ```
            WriteLog("SaveGame", "Save monsters section", "Failed to detect monster array size") *)
            ```

#### Game Enhancement Mod:
- The following plugins have been updated to support ERA memory manager:
    - "ChooseAttack.dll"
    - "GameplayEnhancementsPlugin.era"

#### WoG:
- The following plugins have been updated to support ERA memory manager:
    - "wog native dialogs.era"
    - "game bug fixes extended.dll"
    - "RMG_CustomizeObjectProperties.era"
    - "ERA_MultilingualSupport.era"

- updated plugin "ERA_MultilingualSupport.era" up to version 1.04:
    - fixed dialog memory leaking
- updated plugin "RMG_CustomizeObjectProperties.era" up to version 1.14:
    - fixed dialog memory leaking

#### Other:
- updated ERA SDK. Path is "/Tools/Era/SDK";


### Version 2.164

#### Game Enhancement Mod:
- Now you can use cheat codes in Hot Seat games.

#### ERA Scripts:
- Achievements: Fixed the text of Inspector achievement.

#### WoG Scripts:
- Henchmen:
    - Fixed a bug that setting a new henchman affecting the stack exp of the remaining troops in the stack.
    - Fixed not returning correct number of Warlord's Banner when setting a henchman.
- Map Rules:
    - Starting hero with 5th level: now game giving experience after all messages shown and works only for active player
 
#### Easy Cheats:
- Added the management of Open Puzzle Map cheat. You can now enter 'puzzle' to open the puzzle map.

#### Quick Saving Mod:
- You can now press "S" button to quickly save your game, or Ctrl/Shift/Alt+S to enter the save game dialogue.


### Version 2.163

- hotfix


### Version 2.162

- hotfix


### Version 2.161

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.24:
    - Changed memory manager to FastMM4. The game uses memory manager from Era now and manages separate allocation statistics.
    - Implemented detailed game, Era and plugins allocated memory tracking. Memory report is written to "log.txt" on crash or "OnGenerateDebugInfo" event (triggered by F11).
    - Exported the following function in era.dll:
        - Memory functions, which are common for game and Era engine now. They will be used in Era SDK to redirect plugins memory managers to Era memory manager
        ```
        function MemAlloc (BufSize: integer): {n} pointer; stdcall;
        ```
        ```
        procedure MemFree ({On} Buf: pointer); stdcall;
        ```
        ```
        function MemRealloc (var {On} Buf: pointer; NewBufSize: integer): {n} pointer; stdcall;
        ```
        - Registers memory consumer (plugin with custom memory manager) and returns address of allocated memory counter, which consumer should atomically increase and decrease in malloc/calloc/realloc/free operations:
        ```
        function RegisterMemoryConsumer (ConsumerName: pchar): pinteger; stdcall;
        ```
    - Improved detection of invalid usage of Era memory buffers from Era API by plugins. Attempts to free result buffers using other memory manager API were ignored previously and will most probably cause crashes now.
    - Fixed memory leak in LoadPcx8: pcx8 stub image was created on any GetPcx8 request if corresponding png replacement existed and stub was not registered propertly in the game resource tree, which leaded to out-of-memory errors and could lead to savegame corruption.

#### WoG:
- updated plugin "wog native dialogs.era":
    - critical fix for plugin memory management;
- updated plugin "game bug fixes extended.dll":
    - critical fix for plugin memory management;
- updated plugin "RMG_CustomizeObjectProperties.era":
    - removed extra text in reward message after looting creature bank;
- Fixed text when visiting Warehouses.

#### WoG Scripts:
- "Tavern Card Games" option: the game will no longer replace objects with taverns on random maps;
- "Eagle Eye I" option: added a function to set the maximum level of a spell that a hero can learn when leveling up:
```
!?FU(WOG_103_Hero_GetMaxSpellLevel);
!#VA(heroId:x) (result:x);
```

#### Game Enhancement Mod:
- minor corrections in mod texts;


### Version 2.160

#### ERA:
- ## update era.dll core to version 3.9.23:
    - Updated vfs.dll to allow getting mods list via API.
    - Improved Era crash handling and debug reports generation:
        - Era preallocates 5 MB and reservers another 15 MB for debug report generation in out-of-memory situations.
        - Improved ERM memory dumping. Only 1 MB is necessary to generate report of arbitrary size.
        - Added Era memory manager statistics logging during crashes because of running out of memory. It's written to "log.txt".
        - Fixed wrong "Total sections size" field calculation when generating crash report during game saving.


### Version 2.159

#### ERA:
- ## update of era.dll kernel without changing the version:
    - Implemented saving of additional debug information for crash reports:
        - If crash occurs during game saving, full savegame sections info will be logged and "Debug/Era/Savegame Sections" directory with savegame contents will be created.
        - Memory report is written to "log.txt". "PagefileUsage" is total amount of reserved memory (both in RAM and in pagefile). "WorkingSetSize" is the amount of physical RAM used by process.

#### WoG:
- updated plugin "ERA_MultilingualSupport.era":
    - added the ability to translate text from the following txt files using json keys:
    - artevent.txt
    - artraits.txt
    - crgen1.txt
    - crtrait0.txt
    - crtraits.txt
    - objnames.txt
    - zcrgn1.txt
    - zcrtrait.txt
    - Since these files are read when the game is launched, after changing the language in the game, it will be necessary to restart it so that the new text (if it exists) is written to the game memory over the names from the txt files;
    - Keys for translating strings are:
        - for Artifacts, you can replace the name, description, and text when picked up on the Adventure Map:
        ```
        "era.artifacts.[art_id].name": string,
        "era.artifacts.[art_id].description": string,
        "era.artifacts.[art_id].event": string
        ```
        - for Creatures, you can replace the singular, plural name, and ability description:
        ```
        "era.monsters.[monster_id].name.singular": string,
        "era.monsters.[monster_id].name.plural": string,
        "era.monsters.[monster_id].name.description": string
        ```
        - for Adventure Map Objects, you can replace the name of standard objects and Creature Dwellings (type 17):
        ```
        "era.objects.[object_type]": string,
        "era.objects.17.[object_subtype]": string
        ```
    - in the future it is possible to support more txt files (including those related to heroes);

#### WoG Scripts:
- Karmic battles: fixed incorrect level for creatures from the Fortress;


### Version 2.158

#### Game Enhancement Mod:
- Restored the message about gold received after the battle for the Commander "Brute";

#### Other:
- SD Mod Manager (@SyDr) updated to version 0.98.59


### Version 2.157

#### WoG:
- updated plugin "wog native dialogs.era":
    - fixed the impossibility of meeting heroes inside the town in hotseat mode for a non-red player;

#### Game Enhancement Mod:
- Added extended dialog tooltip for the "Black Market" object:
    - right-clicking on a visited Black Market displays a dialog with prices of all artifacts available there;
    - hovering the mouse over an object adds the number of available artifacts to the hintbar text;
- added text with instructions for creating an error report to the game crash message;
- removed unnecessary files;


### Version 2.156

#### ERA:
- ## update of era.dll kernel without changing the version


### Version 2.155

#### WoG:
- updated plugin "game bug fixes extended.dll":
    - fix for game crash when right-clicking on the "Next artifact" button in the sacrificial altar
    - fixed SoD bug: when checking the possibility of casting spells, Sorcerers now take into account all units, not just the first on each side
- updated plugin "RMG_CustomizeObjectProperties.era":
    - added the ability to give mithril as a reward to creature banks (adds 8 elements to the resource reward column);
    - added the ability to control the generation of scrolls with spells:
        - For spells of each level, you can now set the value, generation density, limit on the map and on the zone
        - The spells "Dimension Door", "Town Portal", "Fly" and "Water Walking" now have a pseudo-level during generation equal to 6, and have their own generation settings (the value is set to 12500).
        - Scrolls with Water Spells are no longer generated on a map without water;
        - restrictions on the zone and map are set for all scrolls with spells of all levels
        - Parameters can be controlled via keys, where [spell_level] is from 1 to 6:
        ```
        "RMG.objectGeneration.93.[spell_level].map": int,
        "RMG.objectGeneration.93.[spell_level].zone": int,
        "RMG.objectGeneration.93.[spell_level].value": int,
        "RMG.objectGeneration.93.[spell_level].density": int
        ```
- Fixed incorrect placement of troops in the Churchyard for the 7th squad, which led to a crash when adding a commander to this bank of creatures;

#### WoG Scripts:
- Added limits to the number of WoG objects generated by the RMG;

#### Game Enhancement Mod:
- Replaced the Creature Stack Experience ability "Fireball" for Magogs and Nightmares with "Curse" (since the AI ​​does not know about this ability).

#### ERA Scripts:
- Third class: fixed discrepancy in the number of secondary skills.

#### ERA ERM Framework:
- added a constant with the address of the standard text buffer of the game;
- added a constant with the size of the BattleStack structure;

#### Other:
- minor corrections to descriptions


### Version 2.154

#### WoG:
- updated plugin "wog native dialogs.era":
    - Hero Meeting Screen in town:
        - added button with hotkey "E"
        - rewritten mechanics:
        - now works if it is active player's turn;
        - fixed triggering town's dlg button;
        - fixed rare bug with blocking town screen
    - added "ESC" hotkey for the closing HMS
- updated plugin "game bug fixes extended.dll":
    - fixed WoG ERM !!CB:M command bug: it set max monster type to 196 (Dracolich) if monster type/number was checked/set as reward if creature type was higher than 196;

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
    - fixed not updating last 8 pixels of Adventure Map dialog;
    - fixed closing any pop-up dialog if it already had another dialog called earlier;
    - added compatibility with scripts;
    - code refactoring and optimization;


### Version 2.153

#### WoG:
- updated plugin "game bug fixes extended.dll":
    - now frames with bonus or penalty of luck and morale above 1 display bonus in the picture (previously always displayed 1)
    - Fixed damage calculation for units with low defence;
- Improved "Slayer" spell description;
- Fixed Map Editor error messages from WoG-objects;


### Version 2.152

- hotfix


### Version 2.151

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## updated era.dll without version changed:
    - Switched on "NXCOMPAT:NO" flag in h3era.exe and h3wmaped.exe executables, thus signalling OS, that these executables do not support DEP (Data Execution Prevention). This change can be performed on any custom executable by running "editbin.exe /NXCOMPAT:NO path_to_exe" from Visual Studio utilities.
    - Improved CM:H to always return valid hero IDs from SwapManager even in non-click events (-1 if no hero meeting dialog is active).
    - Fixed memory corruption bug, leading to random crashes. The bug was introduced in version 3.9.16.
    - Fixed Heroes 3 bug: control words of adventure map objects used to be interpreted in a wrong way due to arithmetic shift usage instead of a logical one. Thanks to MoP for information.

#### WoG:
- updated plugin "game bug fixes extended.dll":
    -  removed subterranean on the surface;

#### Advanced Classes Mod:
- Added missing text/animation/sound for Hypnotize spell casted by Succubus commander.
- Fixed the compatibility between Nobility and Achievement option.
- Export an embed string from erm to json.

#### ERA Scripts:
- Remagic: Fixed the missing ".es" in new spell descriptions.
- Bounty Hunting: Fixed wrong resources name.
- Dragon Town: Fixed possible to rebuild an Utopia when it's on the edge of map, which leads to issues afterwards.

#### Game Enhancement Mod:
- Replace the stack exp ability of casting Death Ripple (Liches/Power Liches/Nightmare) with Advanced Sorrow.
- Removed plugins:
    - "Hawaiing_DlgEdit_Keypad_Support.era"
    - "Hawaiing_hero_def.era"
    - "Hawaiing_town_def.era"
- updated plugin "GameplayEnhancementsPlugin.era":
    - Added Numpad keyboard support to input numbers;
    - Added ability to set custom Adventure Map view for heroes:
        - Set custom view for hero class male:
        ```
        "gem_plugin.map_item_view.54.class.[class_id].0": string
        ```
        - Set custom view for hero class female:
        ```
        "gem_plugin.map_item_view.54.class.[class_id].1": string
        ```
        - Set custom view for exact heroId:
        ```
        "gem_plugin.map_item_view.54.id.[hero_id]": string
        ```
    - Added ability to set custom Adventure Map view for different town levels:
        - Set custom view for only fort is built:
        ```
        "gem_plugin.map_item_view.98.[town_type].fort": string
        ```
        - Set custom view for only citadel is built:
        ```
        "gem_plugin.map_item_view.98.[town_type].citadel": string
        ```

#### WoG Scripts:
- Commander Witch Huts: Fixed the icon for commander primary skills.


### Version 2.150

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era" to version 1.13:
    - added the ability to replace properties of existing objects in texts. Now you can change the soil for generating an object without having to edit the original game files. The key to determine the replacement of properties will be the def name, type and subtype of the object;
    - fixed the original bug of generating of the Subterranean Gates for zones with different terrains
- added generation of snow objects INSTEAD of the usual ones on the snow terrain;

#### WoG Graphics Fix Lite:
- added all the graphics of the mod to the list of game objects, which were previously required to be added into txt-files;

#### WoG Scripts:
- Enhanced Commander's Artifacts: now artifacts will not added banned Secondary Skills 


### Version 2.149

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - added fine-tuning for the placement of attackers and defenders in Creature Banks. For a specific subtype, you can set positions for attackers and defenders. Keep in mind that duplicate positions will place multiple units in one spot, which can lead to a crash during battle:
    ```
    "RMG.objectGeneration.16.[object_subtype].defenderPositions": int array
    "RMG.objectGeneration.16.[object_subtype].attackerPositions": int array
    ```
    - changed the location of defenders in the Churchyard and the Spit;
- updated plugin "ERA_MultilingualSupport.era":
    - fixed crash when starting the game in debug mode;
    - added debug file to the "DebugMaps" folder;
- Updated Chinese localization.

#### Advanced Classes Mod:
- Improved the damage calculation of M/GM Leadership to be compatible with 3rd party scripts.
- Sync the change in Backpack Artifacts option.

#### Advanced Difficulties Mod:
- small text adjustments

#### ERA Scripts:
- Zombie-flesheater: Fixed the hp consumption amount when Zombie-flesheater learns Strike all around.

#### Game Enhancement Mod:
- Restored Commanders'Secondary Skills Scrolling in commander's Dialog;
- Fixed losing stack exp after battle replay
- Spell Research: Fixed erm error in some custom maps.
- Fixed a crash upon entering the battlefield
- fix shrines description for spells granted by artifacts

#### Human AI:
- Fixed the compatibility with Hero Limit option.

#### TrainerX:
- Now the trainer respects wog option "Disable Cheat Codes and Menu". If the option is enabled, TrainerX would by disabled.


### Version 2.148

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.21:
    - Included modern LuaJit2 OpenResty x86 sources and compiled lua51.dll, luajit.exe without VC++ dependecies and with partial Lua 5.2 compatibility.

    - Added the following functions to Era Erm Framework:
    ```
      !?FU(ReadJsonIntArray);
      ; Reads integer array from json config into either existing dynamic array or into automatically created local one.
      !#VA(jsonKeyPtr:x); JSON full key like "test.guards" for { "test": { "guards": [1, 2, 3, 4] } }
      !#VA(intArray:x);   IN/OUT. Either existing dynamic array ID or ?(localArrayId:y).

      Example:

      !?FU(OnAfterErmInstructions);
      !!FU(ReadJsonIntArray):P^test.guards^/?(arr:y);
      !!FU(Array_Join):P(arr)/?(text:z)/^, ^;
      !!IF:M^%(text)^;
    ```
    ```
      !?FU(ReadJsonStrArray);
      ; Reads string array from json config into either existing dynamic array or into automatically created local one.
      !#VA(jsonKeyPtr:x); JSON full key like "test.names" for { "test": { "names": ["daemon", "corwin", "deo"] } }
      !#VA(strArray:x);   IN/OUT. Either existing dynamic array ID or ?(localArrayId:y).

      Example:

      !?FU(OnAfterErmInstructions);
      !!FU(ReadJsonStrArray):P^test.names^/?(arr:y);
      !!FU(Array_Join):P(arr)/?(text:z)/^, ^;
      !!IF:M^%(text)^;
    ```
    - GenerateDebugInfo function (triggered by F11) now clears Debug directory, but preserves "log.txt". The same goes for in-game exceptions (crashes).
    - Improved crash detection and debug information dumping during savegame generation.
    - Fixed images path prefix to use backward slashes as path delimiters in IF:D dialogs.
    - Fixed IF:D dialog: cancel button should be enabled by default.

#### WoG:
- added 2 new creature banks, disabled for generation by default;
- maximum number of unique subtypes of creature banks of type "16" object per zone set to 5 by default;

#### Advanced Classes Mod:
- Fixed possibly to fail on Eagle Eye magic artillery while the opponent doesn't have Emblem of Cognizance.

#### Other:
- reorganization of the list of mods and files in them;


### Version 2.147

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - fixed monsters never flee and split to max stacks;

#### Game Enhancement Mod:
- added new objects for hints on the adventure map;
- some hints have had their height position changed;
- a portrait is drawn on the adventure map as a hint for heroes;


### Version 2.146

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - now adding sounds of the environment of objects will not work if other plugins are loaded that make the same changes;
- reorganization of files that add objects;
- preparation for transferring json files to zip archives;

#### Advanced Classes Mod:
- Fixed the chance of summoning Fire Elemental when attacking a unit with Master/Grand Master Fire Shield.

#### Game Enhancement Mod:
- Fixed possible to retaliate a attacking stack even if the stack was killed by Fire Shield.


### Version 2.145
- hotfix


### Version 2.144

#### ERA:
- updated files to the current version of ERA from the official installer;

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - added support for looped sounds for new and current objects. Setting the value to an empty string will disable the sound for an already specified object. Examples of use:
        - Set a looped sound for a specific subtype of the specified object type:
        ```
        "RMG.objectGeneration.[object_type].[object_subtype].sound.loop": string
        ```
        - Set a looped sound for all subtypes of the specified object type:
        ```
        "RMG.objectGeneration.[object_type].sound.loop": string
        ```
    - added .dbgmap debug file;
- added ambient sounds to hota objects;

#### Game Enhancement Mod:
- fixed desynchronization in PvP battles when one of the players holds any dialogue open;

#### Other:
- updated Lua engine to the latest;


### Version 2.143

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.20:
    - Added support for logging random number generations to log.txt. This feature is controlled by "Debug.Rng" option in "heroes 3.ini".
    - Fixed bug introduced in 3.9.16: CombatManager::CastSpell improvement used to check stack spell level instead of spell duration.

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - added ability to set custom AI value for guard generation. Not set value or less than "0" will not change monster AI-value:
        - Set AI value for each Monster Guard: 
        ```
        "RMG.objectGeneration.54.[monster_id].value": int
        ```
        - Set AI value for ALL Monster Guard (why do you need that :thinking:?):
        ```
        "RMG.objectGeneration.54.value": int
        ```

#### Game Enhancement Mod:
- fixed rare tooltip bug;

    
### Version 2.142

## HD Mod:
- Updated to version 5.5 R37;

#### Game Enhancement Mod:
- GameplayEnhancementsPlugin:
    - Tooltips for objects are now drawn over the fog of war;
    - Tooltips for objects are now drawn over the entrance to the object if it is visible;


### Version 2.141

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.19:
    - Added automatic grid and selection redraw after using BM:Q on inactive stack.
    - Added the following functions to Era Erm Framework:
        ```
        !?FU(EmptyIniCache);
        ; Replaces ini file cache in memory with an empty one. Use it for recreating ini files from scratch, when you don't need previously cached data and original file on disk
        !#VA(filePathPtr:x); Absolute or relative path to ini file
        ```
        ```
        !?FU(MergeIniWithDefault);
        ; Loads two ini files and merges source ini entries with target ini entries in cache without overwriting existing entries
        !#VA(targetPathPtr:x); Absolute or relative path to destination ini file (main settings)
        !#VA(sourcePathPtr:x); Absolute or relative path to source ini file (default settings)
        ```
    - Refactored and improved ini handling API. The following functions were exported/updated:
        ```
        (* Forgets all cached data for specified ini file. Any read/write operation will lead to its re-reading and re-parsing *)
        procedure ClearIniCache (const FileName: pchar); stdcall;
        ```
        ```
        (* Forgets all cached data for all ini files *)
        procedure ClearAllIniCache; stdcall;
        ```
        ```
        (* Replaces ini file cache in memory with an empty one. Use it for recreating ini files from scratch, when you don't need previously cached data and original file on disk *)
        procedure EmptyIniCache (const FileName: pchar); stdcall;
        ```
        ```
        (* Reads entry from in-memory cache. Automatically loads ini file from disk if it's not cached yet *)
        function ReadStrFromIni (const Key: pchar; const SectionName: pchar; FilePath: pchar; out Res: pchar): boolean; stdcall;
        ```
        ```
        (* Writes and entry to in-memory cache. Automatically loads ini file from disk if it's not cached yet *)
        function WriteStrToIni (const Key, Value, SectionName: pchar; FilePath: pchar): boolean; stdcall;
        ```
        ```
        (* Loads and parses ini file. Creates in-memory cache for it to prevent further disk accesses. Returns true only if file existed, was successfully read and parsed.
        Creates empty cache entry in case of any error *)
        function LoadIni (FilePath: pchar): boolean; stdcall;
        ```        
        ```
        (* Saves cached ini to the specified file on a disk. Automatically recreates all directories in a path to the file. Loads file contents from disk if it was not cached earlier. *)
        function SaveIni (FilePath: pchar): boolean; stdcall;
        ```
        ```
        (* Loads two ini files and merges source ini entries with target ini entries in cache without overwriting existing entries *)
        procedure MergeIniWithDefault (TargetPath, SourcePath: pchar); stdcall;
        ```
    - Included Era B2 library source code in "Tools/Era/Sources/Era B2 Library".
    - "OnRemoteEvent" is not triggered for FU:D call anymore. Era now uses FireRemoteEvent to synchronize the creation of objects on adventure map in multiplayer.

## HD Mod:
- Updated to version 5.5 R37;

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - fixed crash when generating water maps;
    - fixed deletion of dialog settings

#### WoG Scripts:
- Neutral towns population growth: added the ability to not influence the increase in Creature Bank security by key:
```
"RMG.objectGeneration.[type].[subtype].isNotBank": bool
```
- Mithril upgrades: Added support for high-level spells for Magic Shrines;

#### WoG Graphics Fix Lite:
- Updated to version 2.20.2

#### Other:
- SD Mod Manager (@SyDr) updated to version 0.98.53


### Version 2.140

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - fixed saving of dialog settings;
- now generation of WoG objects (type 63) is possible only with the WoG Scripts mod enabled;
- generation of some snow objects has been removed;


### Version 2.139
- hotfix


### Version 2.138

#### Game Enhancement Mod:
- Fixed incorrect visiting status when hovering over/right-clicking on borderguards.

#### Other:
- restored Map Editor Shortcut;


### Version 2.137
- hotfix


### Version 2.136

## HD Mod:
- Updated to version 5.5 R36;

#### Advanced Classes Mod:
- Fixed losing experience on creatures killed by Artillery/Ballista.

#### WoG Scripts:
- Artillery: Fixed losing experience on creatures killed by Ballista's preventing shot; 

#### Other:
- new Mod Manager (@SyDr) updated to version 0.98.51
- removed extra files;


### Version 2.135

#### ERA:
- ## update era.dll core to version 3.9.18:
    - Implemented automatic shadow/grid/selection border redraw after calling BM:C.
    - Fixed bug, introduced in 3.9.16 version: global scripts used to be loaded and parsed during savegame loading.

#### Advanced Classes Mod:
- added missing check for hero ID in calculation of Fire Mage commander damage
- added check for Orb of Tempestuous Fire when calculating Fire Mage damage (+25%)

#### Other:
- "UncToBin" utility for conversion of UN:C ERM commands into binary patches, now supports memory address offsets;
- Updated Era and VFS sources in "Tools/Era/Sources".


### Version 2.134

#### ERA:
> [!IMPORTANT]
> Critical fix for loading saved games!
- information about the RNG operation in multiplayer games has been added to the ERA changelog. The file is located at "/Help/Era manual/era iii changelog.txt", or simply click on the ERA version in the game's main menu to open it;

#### Game Enhancement Mod:
- GameplayEnhancementsPlugin: fixed showing hints for non-active window;


### Version 2.133

#### ERA:
    - ATTENTION! examples of using all innovations are in the file "/Help/Era manual/era iii changelog.txt" or just click on ERA version in the game main menu;
- ## update era.dll core to version 3.9.17:
    - Added support for IME (Input Method Editor) input, used by Asian (Chinese/Japanese/Korean) languages.
    - Added "Lang/\*" directory support for zip archives in Data
    - Introduced another directory for ERM global library scripts: "Data/s/lib_end". Scripts from this directory will be loaded after all other map/global/library scripts.
    Likewise "lib" directory, these scripts do not depend on UN:P5 WoG option state.
    - Improved CombatManager::CastSpell function (used also in BM:C) by temporarily setting CombatManager->ControlSide to the side, controlling casting stack.
    - Rewritten IF:D, IF:F, IF:E commands (multipurpose dialog implementation). Features:
        - Whenever string is accepted as a parameter, it may be any string or string literal. The value will be copied to global settings, no more dependency on z-variables.
        - Dialog IDs are totally ignored (better use 0 or -1 for them for readability). There is only one copy of dialog settings in memory.
        - Dialog settings are totally cleared before IF:D and after IF:E execution.
        - Fixed bugs with phantom empty strings instead of image paths or hints.
        - IF:F accepts 0..6 parameters. Empty parameter means "remove hint".
        - IF:E accepts the following syntaxes: IF:E(v-var index to store result) or IF:E?(any integer variable to store result).
- Extended VR:R command with optional 4-th parameter: VR:R(dummy)/(min)/(max)/(free_param);
    - In network battles deterministic random value generator is used, which generates values using current action ID, round ID and battle ID. An attempt to generate multiple random values in one action produces the same values like 44 44 44. To overcome this issue pass unique value to 4-th parameter for each iteration. It may be stack ID or loop counter, but better XOR it with pre-generated int32 constant, unique for the effect/spell/function, you implement. For instance, 1833290248 XOR stack ID is a good choice.
- Added support for Phoenix Ressurection and Death Stare in network PvP battles.
- Updated "Era Erm Framework":
    - Added support for area shooting creatures to BattleStack_Shoot function.
    - Synchronized with Launcher "Era Erm Framework" version.
- Added the following export types and functions to era.dll:
    ```
    Customizable dialog with up to 4 external/internal pictures (bmp/jpg/png/pcx/pcx16,def?), optional input field and 4 selectable buttons with checkboxes.
    All pointers may be null. All fields must be writable by dialog processing routines and must be considered "dirty" after dialog processing except the field, where result values are written.
    ```
    - PMultiPurposeDlgSetup = ^TMultiPurposeDlgSetup;
    - TMultiPurposeDlgSetup = packed record
    ```
    Title:             pchar;                 // Top dialog title
    InputFieldLabel:   pchar;                 // If specified, user will be able to enter arbitrary text in input field
    ButtonsGroupLabel: pchar;                 // If specified, right buttons group will be displayed
    InputBuf:          pchar;                 // OUT. Field to write a pointer to a temporary buffer with user input. Copy this text to safe location immediately
    SelectedItem:      integer;               // OUT. Field to write selected item index to (0-3 for buttons, -1 for Cancel)
    ImagePaths:        array [0..3] of pchar; // All paths are relative to game root directory or custom absolute paths
    ImageHints:        array [0..3] of pchar;
    ButtonTexts:       array [0..3] of pchar;
    ButtonHints:       array [0..3] of pchar;
    ShowCancelBtn:     TInt32Bool;
    end;
    ```
    - TShowMultiPurposeDlgFunc = procedure (Setup: PMultiPurposeDlgSetup); stdcall;
    ```
    ( Displayes customizable configured multipurpose dialog and returns selected button ID (1..4) or -1 for Cancel *)
    ```
    - function ShowMultiPurposeDlg (Setup: PMultiPurposeDlgSetup): integer; stdcall;
    ```
    (* Replaces current multipurpose dialog handler/implementor. Returns old handler if any *)
    ```
    - function SetMultiPurposeDlgHandler (NewImpl: TShowMultiPurposeDlgFunc): {n} TShowMultiPurposeDlgFunc; stdcall;
    ```
    (* Creates new plugin API instance for particular DLL plugin. Pass real dll name with extension. Returns plugin instance or NULL is plugin is already created *)
    ```
    - function CreatePlugin (Name: pchar) : {On} TPlugin; stdcall;
    ```
    (* Installs new hook at specified address. Returns pointer to bridge with original code if any. Optionally specify address of a pointer to write applied patch structure pointer to. It will allow to rollback the patch later. MinCodeSize specifies original code size to be erased (nopped). Use 0 in most cases. *)
    ```
    - function Hook (Addr: pointer; HandlerFunc: THookHandler; {n} AppliedPatch: ppointer; MinCodeSize, HookType: integer): {n} pointer; stdcall;
    ```
    (* Returns true if applied patch was overwritten *)
    ```
    - function IsPatchOverwritten (AppliedPatch: pointer): TInt32Bool; stdcall;
    ```
    (* Returns applied patch size in bytes (number of ovewritten bytes) *)
    ```
    - function GetAppliedPatchSize (AppliedPatch: pointer): integer; stdcall;
    ```
    (* Generates random value in specified range with additional custom parameter used only in deterministic generators to produce different outputs for sequence of generations. For instance, if you need to generate random value in battle for each enemy stack, you could use stack ID or loop variable for FreeParam. But for better generation quality use (stackID XOR UNIQUE_ACTION_MASK) and define UNIQUE_ACTION_MASK constant as unique int32 pre-generated value. In network battles multiple random value generations with the same parameters produce the same output until next action is performed. This function allows to bring back randomness to multiple same time generations. *)
    ```
    - function RandomRangeWithFreeParam (MinValue, MaxValue, FreeParam: integer): integer; stdcall;    
- Added "Debug.LogWindowMessagesOpt" option to "heroes 3.ini", enabling logging of main window messages and their parameters.
- Added the following translatable strings to "era.json":
    - 'era.debug.game_saving_exception_warning':   shown on savegame writing exception
    - 'era.debug.debug_dump_confirmation':         shown on any ERM error
    - 'era.incompatible_savegame_version_warning': shown if game saving was performed on too old Era engine
> [!NOTE]
> From now on, Era always asks permission to load global scripts on map start or scripts reloading if map has internal scripts. The permission text was changed from "skip" to "load" by default. The following language key must be re-translated: 'era.global_scripts_vs_map_scripts_warning'. WoG Option 5 is always set to 3 (ask for loading global scripts if map has internal scripts) before any scripts are loaded, thus there is no more necessity to keep it in WoG Options. UN:P5/# instruction in map internal scripts controls, wether map author forces global scripts loading or not.
- Included updated sources codes for the following plugins: "Buttons", "Erm Hooker", "WoG Native Dialogs", "Game Bug Fixes Extended". Thanks to baratorch and Hota team for sharing their header files.
- Included refactored Delphi and C++ Era SDK (API files) in Tools/Era/SDK.
- Included latest Era sources (Tools/Era/Sources/Era 3.9.16) and Virtual File System sources.
- Restored WoG cheat codes functionality in Easy Cheats mod, fixed documentation typos and added display of dumped array sizes.
- Updated "erm_hooker.era" plugin to reflect Era engine changes.
- Updated "buttons.era" plugin to reflect Era engine changes.
- Updated "wog native dialogs.era" plugin to be more tolerant of unsupported image types for IF:E dialogs.
- Increased stability of snd/vid resources processing (using splice hooks instead of patch hooks).
- "load only these scripts.txt" file support is deprecated. It will be removed in Era 4.X versions. Duplicate entries in this file are ignored from now.
- Updated "Era Erm Framework" mod to use "lib_end" directory for some scripts.
> [!IMPORTANT]
> Savegame file format was changed. Added format checking. Old savegames will be loaded without scripts/plugins data.
- Removed the following functions from era.dll: "CalcHookPatchSize".
- Fixed crash in network game in savegame dialog: RMB on some dialog items leaded to an invalid attempt to update ScreenLog without having initialized textWidget field.
- Fixed wrong ERA version reporting.
- Updated C++ Era SDK ("ConnectEra" function now accepts up to 2 arguments).

#### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
    - fixed incorrect value of objects during Random Map Generation:
        - Pandora's Box;
        - Prison;
        - Spell Scroll;
        - Witch's Hut;
        - Keymaster's Chamber;
> [!IMPORTANT]
>     - To add properties using the key "RMG.[mod_folder_name].properties.[index]" now requires specifying the mod folder name in lowercase. For example:
>    ```
>    "RMG.wog.properties.0":"AVSidol0.def 011111111111111111111111111111111111111111111111 100000000000000000000000000000000000000000000000 111111111 011110111 38 0 0 0"
>    ```

#### Game Enhancement Mod:
- Fixed improved tooltip for university on RMB;
- Fixed hotkeys for the combat quick actions;

#### ERA Scripts:
- Fixed erm errors in Lizard Warrior Ranged Retaliation.

#### WoG Scripts:
- Metamorph: Fixed incorrect amount of creatures when Metamorph transforms.

#### Other:
- new Mod Manager (@SyDr) updated to version 0.98.47, and the executable file name changed to "Mod Manager.exe";
- added plugin sources from igrik;
- old and new plugin and application sources from the "Tools\Era\Sources" folder are packed into an archive to save space;


### Version 2.132

#### Advanced Classes Mod:
- Fixed not possible to resurrect a completely killed stack after casting M/GM Cure spell.
- Added a check for sec skill id in the cursor hovering script

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
    - now additional description of objects is not displayed in the tooltip
    - now tooltips are correctly displayed in multiplayer for an inactive player;
    - new objects have been added for display by default;
- tooltip for visited university on RMC has been fixed;
- Fixed battle expected shooting damage hint

#### TrainerX:
- Now giving the ability to fly to an active hero recalculates his path;

#### Other:
- Added new Mod Manager (@SyDr):
    - At the moment, you can launch the new Mod Manager at "[Game_Folder]/Tools/SD Mod Manager/main.exe"
    - Send suggestions, bug reports and thanks to [Discord channel](https://discord.com/channels/665742159307341827/723550276077748357)


### Version 2.131

#### WoG:
- Updated plugin "RMG_CustomizeObjectProperties.era":
    - Added generation of objects on the snow, which have the necessary graphics;
    - When visiting the Creature Bank, its name and the number of guarding creatures are now written;
    - Added the ability to display extended tooltips when visiting Creature Banks. Key:
    ```
    "RMG.settings.creatureBanks.extendedDlgInformation": bool
    ```
    - Added the ability to display the name of the tooltip when visiting Creature Banks. Key:
    ```
    "RMG.settings.creatureBanks.displayName": bool
    ```
    - Added the ability to set a custom message when visiting Creature Banks. Key:
    ```
    "RMG.objectGeneration.[type].[subtype].text.visit": string
    ```
    - Added support for generating creature dwellings with 4 creatures (type 20);
- Improved description of the spell "Antimagic";

#### Advanced Classes Mod:
- Fixed Breath Attack
- Added combat log for the Ammo Cart Trap.
- Fixed display of gold return dialog for the First Aid Tent for a hero who lost the battle.
- Fixed bug: creature spells did not work with Amethyst enabled.
- Changed the trigger area of the "Nobility" skill. Now only clicking on the city or building screen activates this ability.

#### ERA Scripts:
- Town Treasuries: Optimised the dialogue of looting.

#### WoG Graphics Fix Lite:
- Updated to version 2.20.1

#### WoG Scripts:
- Enhanced Artifacts I: now Dead Man's Boots are duplicated only if the owner does not have Dead Man's Boots in his backpack.

#### Other:
- other fixes and improvements;

### Version 2.130

### WoG:
- Updated plugin "RMG_CustomizeObjectProperties.era":
    - Added ability to reset settings for each map object separately to the dialog of generation objects;
    - Added ability to enter exact generation seed to create a specific random map to the menu of creating a random map;
    - Fixed crash when generating Seer's Huts;
    - Fixed reset of resource type for Resource Warehouses to the wood at the beginning of each week;
    - Added support for setting objects to be able to visit from an adjacent cell (like for artifacts);

#### Advanced Classes Mod:
- Changed the timing of execution for FU(ACM_DrawActionPlay):P, hopefully the damaging animation looks better.

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
    - Changed the image of the button in the dialog for destroying a building in the town;
    - Improved the tooltip about objects;
- Updated the dialog for the mod settings;
- Added a setting to disable mass waiting/protection for Combat Vehicles;

#### ERA Scripts:
- Battle Experience: Now the script respects human/AI exp multiplier set in scripts or wog options;


### Version 2.129

### WoG:
- Updated plugin "RMG_CustomizeObjectProperties.era":
    - Gazebo now has cost picture;
    - Fixed endless loop sound;
    

### Version 2.128

### WoG:
- Updated plugin "RMG_CustomizeObjectProperties.era":
    - Fixed WoG-objects generation;


### Version 2.127

#### Advanced Classes Mod:
- Fixed the animation of Meteor Shower and Implosion animation not changed correctly in 2-hero battles.

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
    - Fixed uneven tooltips on objects;
- For Armour specialists under level 868, the max physical damage reduction from Armour is set to 96%.

### WoG:
- Updated plugin "RMG_CustomizeObjectProperties.era":
    - Added support for the object "Coliseum of Mages";
    - Added support for the object "Gazebo";
    - Now you can add any number of additional object properties to the map using the key "RMG.[mod_folder_name].properties.[index]". Please note that the properties must be in order (you can also use an array of properties);
    - Now the generation of WoG objects works only for those objects whose operation is provided by the corresponding script (the option number is specified in json. It must be enabled for the object to be created);
    - Now the dialog settings save only the changed object data;
    - Fixed: seer's huts were not generated;
- Added 2 seer's huts for generation (5 in total);
- Changed the properties and soils of generation for some WoG objects (no more Snow Grottoes on other soils);

#### Other:
- Sublime Text Editor updated to build 4189;


### Version 2.126

### WoG:
- added missed crystal warehouse properties;


### Version 2.125

#### Advanced Classes Mod:
- Fixed sometimes the animation of a stack isn't updated after receiving a damage from scripts (Like Magic Artillery).
- Fixed Phoenix type of revival not triggering immediately after scripted damage.

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
    - fixed uneven tooltips on objects;

### WoG:
- updated plugin "RMG_CustomizeObjectProperties.era":
- added support for the object "Mithril Warehouse" - graphics by @Grossmaestro;
- corrected the description in the dialog;


### Version 2.124

### WoG:
## Added a new major plugin "RMG_CustomizeObjectProperties.era":
> [!NOTE]
> Random Map Generator (hereinafter RMG)
    - This plugin allows you to:
    - add completely native for Heroes 3 Creature Banks with the object type "16";
    - change any existing banks;
    - change sounds for visiting and surroundings for all objects;
    - generate WoG objects RMG (no more replacing the necessary objects);
    - add new objects to the game mechanics with full AI support (No more "Pyramids"!):
        - already added "Resource Warehouses" from HotA;
        - in development "Watering Hole" and "Gazebo";
> [!TIP]
> All of the above is done ONLY with the help of JSON files. No more objects.txt!
> Now everyone can add their own objects

# And now the most interesting:
### Two new buttons have been added to the Random Map creation menu:
- "RMG settings" - opens a new dialog, inside which you can (should):
    - customize ANY generation for yourself!
    - enable/disable most objects for the RMG;
    - customize the maximum number of objects per map/zone;
    - change the value of objects;
    - change the base cost of creature dwellings;
    - change the density of object generation;
    - change the value of objects (later I will try to work with zone limits as well);
- "Dice" - before each generation, create truly random settings for all objects, which turns each map into a unique set of objects;

#### Game Enhancement Mod:
- updated plugin "GameplayEnhancementsPlugin.era":
- Added the ability to view descriptions of hints above objects on the adventure map while holding down the "Alt" key;
- You can change the list of objects and the hotkey for working in the file "Runtime/gem_AdventureMapHints.ini";
- You can enable/disable the display of hints through the GEM settings window;

#### Advanced Classes Mod:
- Added a fix to prevent critical hit damage overflow (recheck MF:D/F value before applying).
- Fixed the descriptions of creature specialists (again).


### Version 2.123

#### HD-Mod:
- updated up to 5.5 R29
- Added many graphic settings to HD-mod Launcher - try new modes

#### Advanced Classes Mod:
- Fire Mage: New implementation for Fire Mage's Fireball attack in order to fix some behaviours (like not triggering once the commander learns Strike All Around)
- Fixed incorrect bonuses shown for the descriptions of creature specialities.

#### ERA Scripts:
- Achievements: Fixed the special effect of Slayer achievement (forces enemies to skip their turns in the battle) did not skip non-living creatures.
- Remagic: Fixed the interaction with Summon Elemental option (allowing you to summon elemental on the adventure map). Orb of Tempestuous Fire now correctly boost the number of Fire Elemental summoned.
- Hero Limit: Fixed the hint text in the tavern when you already reached the hero limit and try to recruit a new one.
- Zombi-flesheater: Fixed the hero not receiving experience on the eaten stacks.
- Fixed the hook trigger FU(ES_OnAfterMelee) and FU(ES_OnAfterShoot) not working. This should the problems of some creature abilities like Zombie-flesheaters.

#### Game Enhancement Mod:
- Added a feature showing the keymaster's tent visiting status when you hover over/right-click on a Border Guard/Gate
- Added a fix to prevent AI gets into an loop in the battle after reviving their troops.

#### WoG:
- Added missed 63-type objects into zaobjects.txt to allow its generation with RMG;

#### WoG Scripts:
- Enhanced War Machines I/II: Fixed First Aid Tents possibly to set the creature at 0 hp after healing.
- Enhanced Monsters: Hopefully fixed the speed of Devils/Arch Devils messing up after battle replay.
- Garrisons: Restored the landmines/quicksand spells in garrisons (were removed as they damaged the guards in garrisons for some reason).
- Mirror of the Home Way: the exorbitant fee for use has been disabled;


### Version 2.122

#### Advanced Classes Mod:
- Fixed possible to select a class in battle
- Fixed ACM bonuses from Scouting events not translated.
- Added a switch for "Switching actions" script, allowing it to be toggle on/off by external scripts.

#### ERA Scripts:
- Achievements: Fixed erm error when visiting a witch hut with no skill.
- Lizard Warrior Ranged Retaliation: Now they only retaliate with one shot even if they can shoot twice in normal attacks (same logic as Crusaders' retaliations).

#### Game Enhancement Mod:
- Fixed Spell Research not working properly when the amount of spell in a level is fewer than usual (happens when most spells are banned in map editor or scripts)
- Added a fix for stack exp spells immunity check.


### Version 2.121

#### HD-Mod:
- updated up to 5.5 R19

#### ERA Scripts:
- Fixed text corruption in New Cover of Darkness
- Adapted Military Duty so it can be customised by external scripts.

#### Game Enhancement Mod:
- Fixed pressing F to cast not working for Faerie Dragons when the owner hero cannot cast.
- Fixed stack exp messing up in battle replay after quick combat

#### WoG Graphics Fix Lite:
- Updated up to v2.19.5

#### WoG Scripts:
- Hero Specialty Boost: Secondary Skills specialist with the ability to cast a spell at the beginning of battle no longer requires spell book to activate.
- Living Scrolls: Living Scrolls now works without spell books.
- Rogues attacks heroes at random: Fixed interfering Achievements option and external scripts.


### Version 2.120

#### Advanced Difficulties Mod:
- added compatibility between ADM and MNM. Now when grow beyond 4k option is active MNM will show correct stack size in hint text and dialogue picture

#### Game Enhancement Mod:
- Battle Replay stack exp fix: Now use a more reliable way of getting army pointers

#### WoG Scripts:
- Mithril Enhancement: Improved the compatibility between Mithril Enhancement (Monolith feature) and GEM Monolith Locator feature.
- Emerald Tower: now it Makes number of creatures to sacrifice modable.


### Version 2.119

#### Game Enhancement Mod:
- Fixed wrong constants;

#### ERA Scripts:
- Capture Garden and Mills: fixed capturing;


### Version 2.118

>[!WARNING]
> Don't update HD-mod cause it's newer version does conflict with some plugins;

#### Game Enhancement Mod:
- Fixed messing up creature stack experience data on battle replay in some scenarios (affecting Metamorph option).

#### WoG Scripts:
- Death Chamber: Now the hostile spell casting before action is only triggered when it's a monster action (Walk/Defend/Walk and Attack/Shoot).

#### Other:
- other minor fixes;


### Version 2.117

>[!NOTE]
> 16 2-Ways Monoliths mod is removed from the assembly cause of lack of stability;

#### Advanced Difficulties Mod:
- Fixed Creature Banks settings

#### Advanced Classes Mod:
- Now Magic Mushrooms option is disabled, as it conflicts with several features in ACM
- Removed Anti-magic from the random spell granted from casting GM Resurrection, as it prevents further use of Resurrection.
- Fixed neutral commanders' abilities not adapted by ACM.
- Fixed improved Cure breaks the possibility of casting Resurrection on killed units (due to changing the HP of them).

#### ERA Scripts:
- Third Class: Now this option is partially compatible with ACM. Enabling both this option and ACM allows you to choose from 3 skills instead of 2 when hero levels up.

#### Game Enhancement Mod:
- Health Bar: Added opportunity to set health bar below creature number label
- Fixed weird interaction when there are duplicate of combination parts
- Fixed GEM plugin text
- fixed version determination with scripts;

#### WoG Scripts:
- New Battlefields: Fixed new battlefields sometimes not enabled.
- Neutral Town and Creatures Bank Growth: fixed CB monthly guard reset
- Week of Monsters: Script is rewritten and is able to be played with
- Fishing Well: Now Tunnel event will only be activated in random maps (as it potentially breaks the compatibility with some custom maps)
- Mithril Enhancements: Fixed an erm error of !!MN:R (do not use short form of coordinates here like MN4, use MNv4/v5/v6 instead)
- Artillery: fixed auto spell target side when casting is by artifacts after the prevent shot;

#### WoG:
- Fixed Multilanguage support plugin


### Version 2.116

#### Advanced Difficulties Mod:
- formatted some text lines in json file
- Commanders in creature banks will no longer gain abilities and slightly reduce their scaling at the game start
- removed extra fonts

#### Advanced Classes Mod:
- fixed dlgs text display

#### Game Enhancement Mod:
- added combat health bar
- added map Scrolling on the mouse Wheel and RMC
- added town heroes deleting
- added dlg command confirmation with spacebar
- removed "creature stats texts.era"
- Fixed battle replay loosing experience lines

#### WoG Scripts:
- Metamorph: Fixed possible to transform when the space is not enough.
- Recreated GetRandomMonster function (used in Week of Monsters/Metamorph)
- added gosolo support for scouting script


### Version 2.115

#### WOG:
- Removed debug message that appeared when opening dialogs


### Version 2.114

#### Game Enhancement Mod:
- Fixed messing up creature stats with stack exp after battle replay when the stack was killed with Summoned flag. This fixed the stats of Metamorphs and probably some 3rd party scripts.

#### WOG:
- some plugins have been rewritten to improve game stability

#### WoG Graphics Fix Lite:
- Fixed WM II catapult small icon

#### WoG Scripts:
- added support for the plugin for generating WoG objects on random maps (the plugin is currently available in the VIP channel)
- Witch Commander Huts: Added the ability to refuse the offered skill

#### Other:
- added ERA source code
- updated and added headers for creating plugins for using ERA API


### Version 2.113

#### Advanced Classes Mod:
- corrected ERM error during combat with healing

#### ERA Scripts:
- Removed "Bandit Ambush" option, as it is highly similar to "Rogues attack heroes at random".
- Removed unused functions erm files

#### WoG Scripts:
- now triggers from the second day only (same as daily events from the original game)
    - Masters of Life
    - Heroes create magic plains each day
    - Hero's upgraded lvl 7 monsters become lvl 8 


### Version 2.112

#### Advanced Classes Mod:
- Now Fire Mages and allies will still be immune to their own Fire Ball with Orb of Vulnerability presented.
- Now Diplomacy cannot attract creatures that cannot be generated on the map (Must set MA:H=0 beforehand).

#### Game Enhancement Mod:
- hotfix


### Version 2.111

#### Advanced Classes Mod:
- in multiplayer games text from Estate/Natural Healer/Secret Sets ability wont show up for remote player
- fix MP issue were it was possible to select enemy commander spell (Archmage/Warden class) during combat, leading to   desync
- Its now slighlty more difficult to get high stats value for Prayer and Bless spell
- various fixes for MP games
- Dispel is now an Air Spell and to compensate Disguised moved to Water
- Fixed Scouting Set bonus message before combat
- Power of the Dragon Father changed artifact description
- Badge of Courage lost mind immunity for all troops
- Warden commander class spells now have proper scaling based on spell modifier
- all spells cast by commanders now have a 50% chance to give +1 kill count
- Fixed the compatibility with ERA 3.9.15 (Estates hook)
- Disable Economy (ES option) as it creates multiple text description and specialty compatibility issues.
- Optimise HL triggers (Note that they executes for hero starting with high level by default. Here we use   i^acm_isGameStarted^ to skip the HL process before game started)
- corrected Mutare specialist text
- slightly reduced Fire Shield damage scaling
- fixed commander zero movement bug with Hunter class
- Prevent reducing the stack number of the healing creature if it has BM:B>BM:N
- Ogre shield has a small chance to block 50% damage
- Wooden Dwarv shield gives bonus life to level 1 and level 2 troops
- Gnoll shield applies magic mirror in the first battle round
- commander artifacts scaling halved
- commander artifacts no longer lose bonus if unequipped
- commander attack skill (Basic to Grandmaster)now scales from 5-25, same as defense.

#### ERA Scripts:
- Fixed game freeze when displaying achievements.
- Added compatibility with the WoG Graphics Fix mod.

#### Game Enhancement Mod:
- Main plugin update to version 1.7:
  - Changed cursor when hovering over version numbers in the main menu.
  - Added the ability to open the changelog of the game assembly (click on the installed build version).
  - Added the ability to open the changelog of the ERA engine (click on the ERA version).
  - Reminder about the ability to go to the website with the latest version (click on the latest assembly version).

#### WoG Scripts:
- Castle Upgrading: Fixed the growth data shown in the right-clicking dialogue on creature icons in towns.
- Random Heroes: Fixed the random hero becomes available for all the players after battle (if he/she was banned in the map).


### Version 2.110

#### Advanced Classes Mod:
- Disabled remove theoretical battle ai vs ai
- Now the rate of Master/Grandmaster Necromancy is 20%/25% (was 17%/20%)
- Alternative Necromancy:
    - Now the choice of creature to raise for alternative necromancy will be reset when the hero's respawned in taverns.
    - Now the Necromancy rate of raising a custom creature is calculated based on the current value:
        - Walking Dead: 80% of the original value
        - Wights: 55% of the original value
        - Vampires: 30% of the original value
        - Liches: 25% of the original value
        - Black Knights: 15% of the original value

#### ERA Scripts:
- Mortal Heroes: Fixed the icon of speciality occasionally not getting reset when the hero gains a new speciality.

#### Game Enhancement Mod:
- added main menu items font selection;
- added question before opening website;

#### Other:
- Added Vietnamese language in the language selection dialogue;
- Some mods get icons;
- Added Heroes Chronicles Campaigns;


### Version 2.109

## HD Mod:
- The following tweaks are now enabled by default:
    - `Fix.Crit.MapsOver5000` - fixes crash with a huge number of maps;

#### ERA Scripts:
- Mortal Heroes: fixed a code type;

#### Game Enhancement Mod:
- Added a fix for incorrect calculation of the defense ignoring bonus;


### Version 2.108

#### ERA Scripts:
- Mortal Heroes: fixed a code type;


### Version 2.107

## HD Mod:
- The following tweaks are now enabled by default:
    - `Misc.TournamentSaver` - creates unique saves for each game every day;
    - `Misc.RenameRandMap` - creates a unique name for each map created by the Random Map Generator;
    - `UI.Ext.TownMgr.AvailableInsteadGrowth` - displays the number of creatures available for hiring in the town window, instead of growth;
    - `UI.Tavern.InviteHero` - allows you to select the next hired hero after purchasing the current one;
    - `UI.Ext.AdvMgr` - supports an extended tooltip in the adventure map status bar;

#### Advanced Classes Mod:
- Alternative Necromancy is now activated by left-click on Necromancy icon (was right-clicking).

#### ERA ERM Framework:
- added NPC table data;
- added SWAP_MANAGER address (Hero Meeting Manager);

#### ERA Scripts:
- Town Treasures: Fixed sometimes not possible to loot Red player.
- Night Scouting: Optimised the dialogue for checking Assassins owned by heroes.
- Mortal Heroes:
    - Prevent generating the same specialties when spamming battles in the same location.
    - NPC reset now made by WoG function, higher "Enhnanced Commanders" -option compatibility

#### TrainerX:
- Fixed not possible to change the level of heroes not belong to the current player.

#### WoG Graphics Fix Lite:
- fixed gogs/hellhounds small portraits (they were mismatched previously)

### WoG Scripts:
- ##  "Week of Monsters" option is temporary disabled;
- Standardise the interaction of secondary skills (Estates II, Scouting I/III). Now they are activated by left-clicking on secondary skill icons from hero screen. They cannot be activated when it's not on the player's turn/the hero does not belongs to the player.
    - When enabling both Scouting I and Scouting III, the customization dialogue of Scouting I would be activated by right-clicking on the Scouting icon. (as the left-clicking dialog is occupied by Scouting III).
- Released z250-z265, z770-z786 from Scouting III script. Now they can be used freely.
- Scouting III: Basic Scouting can no longer steal resources and spells (must advance to Advanced level to use). Fixed wrong hero primary skills displayed of the town infiltrated.
- Artillery: restricted ballistas' amount at prevent shot with  1;
- Enhnanced Commanders: small code optimization, Astral spirit spell reset fix;

#### Other:
- Added (xxx_OnResetHero) hook to deal with hero variables (or global hero variables). This is to help reset the choices of secondary skills/artifacts when the hero is dismissed/defeated and respawn in taverns.
- added missed AB's campaigns data


### Version 2.106

#### Advanced Classes Mod:
- Axe of Centaur now gives +5% physical crit chance
- Spell Trainer for summoning spells now gives percent bonus (weaker early game, stronger late game)
- Helm of Unicorn, Ammo Cart and Ammo Cart WM Upgrade provide more spell point regeneration after combat
- Replenish SP Ammo Cart upgrade now requires Warfare(Tactics) secondary skill instead of Learning (makes it more accessible for Warriors, since they can struggle having enough SP). Overheal Upgrade now requires Learning, instead of Warfare.
- Ogre's Club of Havoc fixed stun ability not working
- Pacifist ability will not reduce low level units damage by 50% anymore (thanks to Diozia)
- Fix Diplomacy not working properly
- Rebalance Cripple effects. The minimum speed of creatures is 3 instead of 2 (same stats of peasants).

#### Advanced Difficulties Mod:
- Fixed: additional abilities will not accumulate in battle replay (thanks to TheInvisible1966)

#### ERA Scripts:
- Mortal Heroes: Now Aura of Curse speciality no longer grants you a hidden spell speciality. Improved battle log, now it's less confusing.
- Removed abundant functions;

#### Game Enhancement Mod:
- Added Hota style Mana Vortex interaction: Mana Vortex is now activated manually and can only be used by a guest hero. Additionally, it's not possible to use Mana Vortex in allies' towns.

#### WoG Graphics Fix Lite:
- Update the mod to version 2.19.0;

#### WoG Scripts:
- Adventure Cave: Now abilities obtained from Hermits can be used in network battles.


### Version 2.105

#### ERA Scripts:
- enhanced creature specialists: changed hook and optimized script;
- Skeletons with artifacts: removed animation when combat is hidden;

#### WoG Scripts:
- Artillery: fixed crash when attacking towns with towers;

### Version 2.104

#### Advanced Classes Mod:
- Fixed showing Plunder message when a human player's town is captured by AI

#### ERA ERM Framework:
- Added an initialization of battle variables OnSetupBattlefield;

#### ERA Scripts:
- Now backpack artifact is fully compatible with ACM (again). By enabling this option with ACM, it allows movement points artifacts to provide movement points while in backpack.

#### Game Enhancement Mod:
- Disabled invalid Quick Combat buttons and dialogues in the Tutorial map (as the whole Quick Combat feature is disable in Tutorial).

#### WoG Scripts:
- Added a function in Masters of Life to allow injecting by external scripts.
- Refactor neutral bonuses script, boost the performance and resolve a potential variable crossing issue


### Version 2.103

#### Advanced Classes Mod:
- Fix possible being able to cast Forgetfulness on non-shooter

#### WoG:
- Fixed a crash when trying to create random maps;
- Added pictures for the Chronicle campaigns;


### Version 2.102

#### ERA:
    - ATTENTION! examples of using all innovations are in the file /Help/Era manual/era iii changelog.txt;
    
- ## updating the ERA.dll kernel to version 3.9.15:
- Updated erm_hooker.era plugin to version 3.0:
  - Switched to modern patching API from era.dll.
  - Implemented protection from overlapping patches.
  - Implemented protection from patch restoration if patched code was changed by third-party code.
  - Improved patch bridge code.
  - Added version reporting (RMB on Credits in game menu).
  - Patch report file (Debug/Era/erm hooks.txt) uses human readable ERM function names instead of numeric IDs now.
- Added support for ERM script libraries. Scripts, located in "Data/s/lib" directory are considered library scripts. They are loaded before other global scripts and before     all map scripts (both internal and external). Such scripts must be propertly written, use only named variables and functions with prefixes. They must not influence the gameplay, interface or other scripts. They should be treated as a callable collection of functions, together with related constants and data structures.
- Era Erm Framework scripts are moved to "Data/s/lib" and can be used in maps now, even in maps, disabling global ERM scripts.
- Fixed DL:H command. Any string is accepted as hint. The hint is copied to a dialog internal location and automatically freed on dialog closing. No more need to use global z-variables for custom dialog hints. Hints are not interpolated at show time anymore.
- Modified "IF:L" command to allow any string as argument and automatically escape '%' character. Previously strings with '%' led to garbage results or even crashes.
- Modified "HE:B0", "HE:B1", "HE:B3" commands to allow any string as argument.
- Rewritten WoG "ApplyString" and "NewMesMan" functions, allowing any string in multiple ERM commands (CA, LE, GE, etc):
    - Disabled syntax of setting event message to the one from event with given ID (ex, "GE:M30" for event with ID 30).
    - Deprecated syntax of using -1 instead of empty string.
- Extended SN:K(str)/(ind)/[?](strchar or char code) syntax. If result is integer variable, char code is returned instead.
- Extended 'VR:F' command with the 4-th parameter:
    - If (defaultValue) is specified and variable does not fit (minValue)..(maxValue) range, it will be set to (defaultValue):
    ```
    !!VR(intVar):F(minValue)/(maxValue)/(showErrors)/(defaultValue);
    ```
- Improved stability of dynamic ERM commands execution using 'ExecErmCmd' API. Added support for all ERM 2 variables in command parameters.
- Extended ERM fast memory buffer for string literals and string arguments in ERM commands and triggers from 1 MB to 3 MB.
- Added possibility to increase buffer size for compiled erm scripts using heroes3.ini setting. The default value is 128 MB. Single ERM command need ~0.5 KB:
    - CompiledErmBufSize = 134217728; maximum size of a buffer for compiled erm scripts (does not influence dynamic compilation on the fly using PersistErmCmd or ExecErmCmd)
- Disabled ERM tracking for Era Erm Framework mouse and keyboard handling code.
- Improved ERM tracking report formatting.
- Added new event "OnBeforeLoadGame" for plugins. It occurs right after old game leaving and before new game loading.
- Added new option "Debug.CopySavegameOnCrash" to heroes3.ini. The option is on by default and enabled copying of last used savegame to debug directory on crash, which may be useful for crash investigation.
- Moved a few messages from code into era.json for further localization:
  - era.no_memory_for_erm_optimization;
  - era.game_crash_message;
- Refactored and updated Era SDK files in "Tools/Era/SDK". For C++ use "era.h" and "era.cpp". For Delphi use "era.pas".

- Added the following functions to Era Erm Framework:
    - ```
        !?FU(Interpolate);
        ; Interpolates ERM variables inside given string (%v1, etc). Can be used for nested translation strings like %T(...) is json.
        !#VA(strPtr:x);    Source string.
        !#VA(resultPtr:x); OUT. Result string.
    
        Example:
    
        !!VRi^edu_age^:S33;
        !!VRs^edu_name^:S^Xeon^;
        !!VR(templateStr:z):S^%%s(edu_name) is %%i(edu_age) years old^;
        !!IF:M(templateStr); displays "%s(edu_name) is %i(edu_age) years old"
        !!FU(Interpolate):P(templateStr)/?(interpolatedStr:z);
        !!IF:M(interpolatedStr); displays "Xeon is 33 years old"
        ```
    - ```
        !?FU(Trim);
        ; Trims #0..#32 characters (space and control characters) from both sides of the string.
        !#VA(strPtr:x);    Source string.
        !#VA(resultPtr:x); OUT. Result string.

        Example:

        !!VR(text:z):S^    Hello World    ^;
        !!FU(Trim):P(text)/?(text);
        !!IF:M^%(text)^; displays "Hello World" without leading and trailing spaces
        ```
    - ```
        !?FU(StrPos);
        ; Finds the first occurance of needle string in the haystack string. Returns offset from string start or -1 for faulure
        !#VA(haystackPtr:x); String to search in
        !#VA(needlePtr:x);   String to seacrh for
        !#VA(result:x);      Result offset in the haystack string or -1.
        !#VA(offset:x);      Zero-based offset in haystack string to start search from. Default: 0.

        Example:

        !!VR(text:z):S^Hello World^;
        !!FU(StrPos):P(text)/^World^/?(substrPos:y);
        !!IF:M^%(substrPos)^; displays "6"
        ```
    - ```
        !?FU(StrReplace);
        ; Replaces all occurencies of Pattern string in the Source string with Replacement string. Returns final string.
        ; Can be used inside triggers only.
        !#VA(sourcePtr:x);      Original string to perform replacements in
        !#VA(patternPtr:x);     What string to replace
        !#VA(replacementPtr:x); Replacement string
        !#VA(result:x);         Result string index

        Example:
    
        !!VR(text:z):S^You should cast the spell. Spell casting increases your intelligence^;
        !!FU(StrReplace):P(text)/^cast^/^learn^/?(text);
        !!IF:M^%(text)^; You should learn the spell. Spell learning increases your intelligence
        ```
- Added the following constans to Era Erm Framework:
    - CHAT_EVENT_TYPE_XXX   for 'OnChat' event subtype
    - CHAT_EVENT_RESULT_XXX for 'OnChat' event result
- Added the following exported functions to era.dll:

  (* Compiles single ERM command without !! prefix and conditions and saves its compiled code in persisted memory storage.
     Returns non-nil opaque pointer on success and nil on failure. Trailing semicolon is optional *)
  function PersistErmCmd (CmdStr: pchar): {n} pointer; stdcall;

  (* Executes previously compiled and persisted ERM command. Use PersistErmCmd API for compilation *)
  procedure ExecPersistedErmCmd (PersistedCmd: pointer); stdcall;

  (* Translates given string. Returns static translated string address, which will never be deallocated *)
  function trStatic (const Key: pchar): pchar; stdcall;

  (* Translates given string. Pass parameters as pairs of (key, value). Returns temporary string address, which must be immediately copied to a safe location *)
  function trTemp (const Key: pchar; Params: pointer to array of pchar; LastParamIndex: integer): pchar; stdcall;

  (* Returns human readable string for ERM event ID. Usually it's ERM trigger human readable name or ERM function name.
     The caller MUST free returned memory block using MemFree from era.dll *)
  function GetTriggerReadableName (EventId: integer): {O} pchar; stdcall;

  (* Installs new hook at specified address. Returns pointer to bridge with original code. Optionally specify address of a pointer to write applied patch structure pointer to.
     It will allow to rollback the patch later.
     Handler function must use stdcall convention. It receives hook context pointer and must return non-zero value in order to execute overwritten code.  *)
  function HookCode (Addr: pointer; HandlerFunc: THookHandler; {n} AppliedPatch: ppointer): pointer; stdcall;

  type
    PHookContext = ^THookContext;
    THookContext = packed record
      EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: integer;
      RetAddr:                                pointer;
    end;

    THookHandler = function (Context: PHookContext): LONGBOOL; stdcall;

  (* Calculates number of bytes to be overwritten during hook placement *)
  function CalcHookPatchSize (Addr: pointer): integer; stdcall;

  (* The patch will be rollback and internal memory and freed. Do not use it anymore *)
  procedure RollbackAppliedPatch ({O} AppliedPatch: pointer); stdcall;

  (* Frees applied patch structure. Use it if you don't plan to rollback it anymore *)
  procedure FreeAppliedPatch ({O} AppliedPatch: pointer); stdcall;

-  Modified some exported function signatures. Many of them now use TInt32Bool type (32 bit 0 or 1) instead of boolean for better compatiblity with ERM:

      type
        TIsCommanderIdFunc       = function (MonId: integer): TInt32Bool stdcall;
        TIsElixirOfLifeStackFunc = function (Stack: Heroes.PBattleStack): TInt32Bool stdcall;
    
      function IsCommanderId (MonId: integer): TInt32Bool; stdcall;
      function SetIsCommanderIdFunc (NewImpl: TIsCommanderIdFunc): {n} TIsCommanderIdFunc; stdcall;
      function IsElixirOfLifeStack (Stack: Heroes.PBattleStack): TInt32Bool; stdcall;
      function SetIsElixirOfLifeStackFunc (NewImpl: TIsElixirOfLifeStackFunc): {n} TIsElixirOfLifeStackFunc; stdcall;
    
      (* Returns 32-character unique key for current game process. The ID will be unique between multiple game runs. *)
      procedure GetProcessGuid: static_pchar; stdcall;


- Increased performance of "Substr" function from Era Erm Framework.
- Changed unsafe Era hooks with manually specified hook sizes to fully automatical hooks with hook length calculation using integrated disassembler engine.
- Fixed bug: "OnWinGame" and "OnLoseGame" events were not executed after "OnGameLeave", because ERM engine was disabled by that time. Now "OnWinGame" and "OnLoseGame" occur right before "OnGameLeave".
- Fixed ERM bug. Local array item access by variable index lacked lazy evaluation support. Constructions like "!!if&v1<>v1/(array[hugeValueVar])" used to produce runtime warnings. For now invalid item index is changed into 0, producing runtime error only in case of real item access.
- Fixed IsCommanderId function crashing.
- Fixed game bug: typing in chat bar produced phantom chat mouse button click events.
- Fixed crash, occuring when "Debug.TrackErm" option is disabled. The bug was introduced in version 3.9.14.
- Fixed bug: ERM memory context was lost in exceptions because of new fast exit to main menu implementation.
- Fixed WoG complete AI battle detection. Autoclosing dialog timer is not compared to 0 anymore. The "gosolo" cheat works in battles again without ERM errors.
- Deprecated exported 'ApiHook' and 'Hook' functions. 'Hook' will show error message, while ApiHook is preserved for legacy only. Use 'HookCode' instead or patcher_x86 API directly.
- Fixed old event handling bug. Triggering ERM event with disabled ERM resulted in global event not being generated either. For example, Era and plugins could not handle 'OnSavegameRead' event if ERM was disabled at the moment of savegame loading.

#### Advanced Classes Mod:
- Now piecing spell immunity no longer works on own troops
- fixed self heal on First Aid Tent when right-clicking it in combat
- Fixed ACM Before Attack/After Attack hooks.
- Fixed not granting the position of stack for war machine hints
- Fixed Scroll of Summoning not working when equipping more than 1;
- Fixed details of Fire Shield, including
    1. Now we check if the targeted stack has been casted Fire Shield by the hero, instead of checking whether the hero has casted Fire Shield on any of the stack to determine whether to summon Fire Elemental
    2. Remove all the BG usage in MF1 for Fire Shield, avoiding compatibility issues.
    3. fixed Fire Shield calculation

- Torosar now has his Block ability capped at 100% chance/95% damage block
- Fixed the descriptions of Commander specialists
- Prevent reducing the stack number of the healing creature if it has BM:B>BM:N
- Fixed Boots of Polarity giving not refreshing screen after giving movement points
- corrected Mutare specialist text
- slightly reduced Fire Shield damage scaling
- fixed commander zero movement bug with Hunter class
- Badge of Courage no longer grants Mind Immunity
- Power of the Dragon Father changed text to show it doesn't protect against Dispel
- Fixed kill count on battle replay.
- Added battle log for Natural Resistance (as many players found this ability confusing)
- Warden commander-class spells now have proper scaling based on spell modifier
- all spells cast by commanders now have a 50% chance to give +1 kill count

#### Advanced Difficulties Mod:
- correction of wrong Battle Reward calculation with CB settings (thanks to Maximo)
- Creature Bank dif settings slightly reduced commander HP bonus per week on lower difficulties
- Fixed possible to obtain battle reward when the attacking hero is killed
- Fix possible to give AI exp even when it shouldn't (reaching level cap or already level 6424).

#### Easy Cheats:
- Released new mod "Easy Cheats" with really easy to type and remember cheats and built-in ERM console. Type "help" in chat input for details (Don't forget to enable it in the Mod Manager).

#### ERA Scripts:
- Evading Halflings: Fixed the range of damage to be evaded.
- Peons:
    - Move the position of Peons button by 5 pixels to the right to not cover the income number
    - Now it's possible to send the troops from the visiting hero to work if there is no troop in the garrison
- Fixed Leprechaun bank loan not updating screen immediately
- Night Scouting: Fixed the picture of Assassin DLG.

#### Game Enhancement Mod:
- Seer Huts: Combo art pieces can no longer be chosen as the quest item in Seer Huts
- Fix not trigger victory condition after capturing all 7 Griffin Towers in Long Live the Queen - Griffin Cliff scenario
- Fix a crash of battle without boat on the sea - it is resulted by missing background of the battlefield, triggered by events from custom maps when the hero move on the sea with Fly/Water Walk.
- Fix passability after visiting prisons with game bug fixes extended enabled

#### HD mod:
- Updated to version 5.5 R6 - thanks to baratorch;

#### TrainerX:
- TrainerX requires ERA 3.9.15 to work.
- Now TrainerX can be used in any map including Valery's maps that prevents WoGifications.
- Added Ctrl-click on hero portrait in Trainer main interface to centre the camera at the hero's location

#### WoG Scripts:
- Fixed an error when clicking on the morale amount with the 10SSkills mod active;
- Neutral stack exp: Fixed the interaction with stack exp option. It is possible to enable neutral stack exp without enabling the other stack exp.
- Metamorphs: fixed messed up stats of metamorph after they are transformed and given stack exp.
- Mithril Enhancement: Fixed upgrading mines effect lasts for the whole game (should be 1 week according to description)
- Small tweak to Emerald Tower (not changing fight value on enhancement)

#### Other:
- Multiple small scripts adjustments
- Added Commander creatures into objects.txt list to support their placements onto the map;
- files small reorganization;
- added the following templates for creating random maps to the hd mod set:
  - 8xm8a;
  - 8xm8;
  - 13th Region;
  - Battle Arena;
  - Blood Star;
  - Great Sands;
  - Magic of Decateron;
  - Pentagram;
  - Penteract;
  - Tesseract;


### Version 2.101

#### ERA:
- Fixed old event handling bug. Triggering ERM event with disabled ERM resulted in global event not being generated either. For example, Era and plugins could not handle 'OnSavegameRead' event if ERM was disabled at the moment of savegame loading.

#### Game Enhancement Mod:
- Fix cheats not working

#### Random Wallpaper Mod:
- unnecessary files were removed;

#### WoG Graphics Fix Lite:
- Update the mod to version 2.18.0;


### Version 2.100

#### ERA:
    - ATTENTION! examples of using all innovations are in the file /Help/Era manual/era iii changelog.txt;
    
- updating the ERA.dll kernel to version 3.9.14:
    - added screenshot capturing support:
        Added support for capturing game screenshots in png/jpg formats. The following function was exported in era.dll:

              (*
            Captures screenshot and saves it as a file. The format is detected automatically by extension. The following extensions
            are supported: 'jpeg', 'jpg', 'png'. By default in-game cursor is also captured. Returns success flag.

            'Quality' is used to specify jpeg saving quality (0..100).
            'Flags'   is a bit mask of function flags.

            TS_FLAG_HIDE_CURSOR = 1; // Hide cursor
              *)
          - function TakeScreenshot (FilePath: pchar; Quality: integer; Flags: integer): TDwordBool; stdcall;
        - Added new option "Debug.CaptureScreenshotOnCrash" to heroes3.ini. The option allows to capture screenshot on crash and save it in "Debug/Era/screenshot.jpg".
    - improved ERM execution stability:
        - Added automatical ERM tracking reset and settings restoration on game start or load.
        - Implemented automatical "Debug/Era" directory cleanup before generating debug files on crash.
    - improved debugging facilities:
        - Added runtime API for controlling ERM tracking. It can be used to omit well tested library from final ERM tracking log or for tracking particular code units only:
            - Added new option "Debug.AllowRuntimeErmTrackingControl" to heroes3.ini. The option enables or disables runtime control on ERM tracking. It's enabled by default and should be disabled in case of complex bug tracking, where no code can be trusted.
            -  The following functions were exported in era.dll:
                - procedure DisableErmTracking; stdcall; // Pauses ERM tracking. All previously tracked info is preserved.
                - procedure EnableErmTracking; stdcall; // Resumes ERM tracking.
                - procedure RestoreErmTracking; stdcall; // Sets ERM tracking to value, specified in heroes3.ini (the one used before runtime manipulations)
                - procedure ResetErmTracking; stdcall; // Clears all previously recorded tracks.
    - improved network gaming stability:
        - ### Warning. Using "OnGameEnter" for ERM hooks in network games does not work in Era < 3.9.14.
        
        Added support for "OnGameEnter" and "OnGameLeave" events in network games. Previously savegame transfer and loading on remote side used to trigger "OnAfterSavegameLoad", but not "OnGameLeave" + "OnGameEnter". That's why using erm_hooker plugin with "OnGameEnter" event resulted in unset hooks after the first end of turn.
          In network games the sequence of events after remote side end of turn is the following:
          
            "OnGameLeave"     - here were restore UN:C patches and erm_hooker unset hooks
            "OnSavegameRead"  - reading transferred savegame
            "OnAfterLoadGame" - fully loaded trasferred savegame
            "OnGameEnter"     - install UN:C patches and ERM hooks once again

    - other:
        - ERM execution is disabled after "OnGameLeave" event. MP3 and real time triggers are not executed outside of game main loop anymore. Previously triggers were executed in the context of game main menu.
        - Updated erm_hooker.era plugin and debug map.
        - "OnAdvMapTileHint" was renamed to "OnAdventureMapTileHint". The previous name is deprecated, but is kept for compatibility reasons.
        - Deprecated 'OnAbnormalGameLeave' event. HD mod way to return from combat screen to main game menu is not supported anymore.
        - Internal settings module refactoring.
        - IP selection dialog will no be shown in multiplayer setup screen if PC has only one IP address available.
        - Fixed ERM commands tracking with ';' inside string literals (ex. \^...;...^).
        - Fixed inaccurate routine and line detection by address in DebugMaps module.
        - Fixed buttons.dll plugin debug map.

#### Random Wallpaper Mod:
- Added a new menu for all;
- Replaced the logo in the main menu;
- Fixed "empty" pictures;
- Removed .pac/.vid file due to uselessness;

#### WoG:
- Fixed a bug with the experience of creatures from previous updates;

#### WoG Scripts:
- Fixed the logic for updating creature banks;
- Enhanced monsters: fixed speed of Archdevils;
- Improved War Machines III: Fixed healing of enemy units;

####Other:
- Renamed triggers "OnAdvMapTileHint" to "OnAdventureMapTileHint";
- TrainerX/Enhanced Henchmen mods now also support multilingualism;


### Version 2.99

#### ERA Scripts:
- Fixed Cover of Darkness description corruption;
- The animation for the appearance of "Assassins" due to crashing during the battle is temporarily disabled;

#### WoG Scripts:
- Fixed Creature Banks refill;


### Version 2.98

#### Other
- missing files restored;

### Version 2.97

#### ERA:
    - ATTENTION! examples of using all innovations are in the file /Help/Era manual/era iii changelog.txt;

- updating the ERA.dll kernel to version 3.9.13:
    - Improved exceptions tolerance for ERM engine (triggers and commands). ERM memory clean up is performed in case of exception, allowing to reuse ERM engine later after recovery. Exceptions may be used, for instance, to trigger fast quit from deeply nested dialogs.
    - Improved crash/exception handling. HD and WoG handlers are not called at all. Era's handler is called only once. Crash reports become more stable and accurate. Previosly multiple exception could take place and override the same logs.
    - Added experimental (may be subject of removal) exported function to quit from any dialog in main game menu.
    - Commanders without UNDEAD flag are also handled by Elixir of Life now. Plugins may override IsElixirOfLifeStack exported function to implement other behavior.
    - Added exported functions to era.dll, more steps on moving WoG hard-coded mechanics into replaceable API format. API setters return previously set implementation functions or null.
- The button to launch the language selection dialog now works in the campaign menu window;

#### Advanced Classes Mod:
- in multiplayer games text from Estate/Natural Healer/Secret Sets ability wont show up for remote player
- fix MP issue were it was possible to select enemy commander spell (Archmage/Warden class) during combat, leading to desync
- Its now slightly more difficult to get high stats value for Prayer and Bless spell
- various fixes for MP games
- Dispel is now an Air Spell and to compensate Disguised moved to Water
- Fixed Scouting Set bonus message before combat
- Artillery Shot can no longer attack friendly troops when the active turn is enemy;
- Fixed Fire Mage not casting Fire Ball after attack if they learn Strike all around
- Fixed Magogs not damaging own troops if they are hypnotized
- Fixed losing changes inside advanced classes mod.pac

#### Game Enhancement Mod:
- Replaced the mithril icon on the resource panel @Grossmaestro;
- Removed fog of war replacement;

#### Enhanced Henchmen:
- Fixed AI not using commander's banners on Henchmen;

#### TrainerX:
- removing artifacts did not previously trigger the original removal event;
- Fixed overwriting of the artifact "Speculum" when opening the map;
- Fixed the triggering of opening the additional options dialog when "Ctrl" is pressed;
- Fixed incorrect removal of artifacts from the hero structure;


#### Random Wallpaper Mod:
- Rewritten logo plugin; added support for drawing over video and managing the name and position of the picture in both menus;

#### WoG Scripts:
- Artillery: ballista starting shot has been fixed. Now the damage is dealt as described at 100/200/300% of the unit’s normal damage;
- Fixed possibly turning off stack exp on battle replay
- Added New Creature Banks refill support;

#### Other:
- Добавлены файлы предпросмотра кампаний Клинка Армагеддона;
- Небольшие правки описаний;


### Version 2.969

#### ERA:
- ERA.dll kernel update
  - regeneration with the Elixir of Life has been reduced to 100 hp;
  - added exported function SetStdRegenerationEffect for plugins;

#### Random Wallpaper Mod:
- Fixed the inability to select map size in the scenario selection dialog;


### Version 2.968

#### ERA:
    - ATTENTION! examples of using all innovations are in the file /Help/Era manual/era iii changelog.txt;

- updating the ERA.dll kernel to version 3.9.12:
    - Implemented advanced ERM memory synchronization means in network games.
    -  Added !!IP:M command to mark associative variables (SN:W, i^^, s^^) for further synchronization.
  Syntax:
    !!IP:M^var_name_1^/^var_name_2^/...;
    !!IP:M0/^array_var_name_1^/^array_var_name_2^/...;
    -  Added !!IP:S command to perform synchronization of all marked variables and arrays. Use !!IP:D to specify targets for synchronization.
    After calling it marked variables cache is cleared.
    !!IP:S is automatically called right before sending 'start battle' network event with !!IP:D-1.
    - Added GAME_TYPE_XXX constants to Era Erm Framework (see UN:V 5-th parameter).
    - Added the following global variables to Era Erm Framework:
    i^battle_isActingSideUiUser^: bool. Is TRUE if acting side player is local human and thus can use all UI actions.
    Use it to prevent non-active network player from performing state changing UI actions.
    - Added the following functions to Era Erm Framework:
        - !?FU(Array_Move);
        Copies part of the array into another part of the array, overwriting existing values in a smart way.
        - !?FU(Array_Splice);
          Deletes specified number of items from start index and inserts new items in the same position afterwards.
        - !?FU(ActivateNextStack);
          Finds and activates next stack. Returns TRUE on success and FALSE if nobody can move in this phase.
    - Implemented possibility to select desired IP for multiplayer gaming.
    Vanilla game uses the first found IP address for PC, while PC may belong to multiple networks: LAN, WLAN, Virtual LAN, Internet (white IP address).
    - Added the following exported functions to era.dll:
        - Allocates new function ID and binds it to specified name if name is free, otherwise returns already binded ID.
        This function can be used to implement custom ERM events in plugins.
        The result is 1 if new ID was allocated, 0 otherwise.
        function AllocErmFunc (FuncName: pchar; {i} out FuncId: integer): TDwordBool; stdcall;
        typedef bool (__stdcall* TAllocErmFunc) (const char* EventName, int32_t &EventId);
    - Added new event for plugins/Lua: 'OnAfterReloadLanguageData'. It occurs whenever Era reloads all language json data from disk.
    - Rewritten creature regeneration ability support.
    (!) Plugins should not hook regeneration code and should use Era 'SetRegenerationAbility' API instead.
    - Exported function 'SetRegenerationAbility' in era.dll for plugins only (like new creature plugins).
    - Removed heroes3.ini option "FixGetHostByName".
    - Fixed bug: local static string arrays indexes were incorrectly calculated for non-const indexes in ERM 2 scripts, ex. (arr[i]).
    - Fixed bug in VFS.dll, due to which Era was not working on Wine. Null mask parameter for NtQueryDirectoryFile was treated as '*'#0 instead of '*'.
    
#### Advanced Classes Mod:
- prevents message display after combats for non active player
- Added definition of frequent used artifact variables. Currently, i^acm_%(ART_ORB_OF_VULNERABILITY)_equipped^ is used in Fire Mage's Fire Ball (their immunity to their own fire ball would be ignored is Orb of Vulnerability is presented)
- Added i^acm_meleeStack^ and i^acm_meleeSide^ to help with checking the melee attacking under !?MF1. No more BG:N trick needed.
- Fixed the immunity behaviour of Fire Mage if they happen to be Hypnotized
- Reworked Fire Shield rework. Now instead of checking Creature Id to know whether they should be immune to Fire Shield, we use hook to check if they should. This also prevent Fire Shield to visually show if the target is immune.
- Added FU(ACM_GetCustomFireShieldMultiplier) to be called by 3rd party scripts to determine additional Fire Shield damage dealt by specific monsters.
- Fixed MP compatibility of Archmage/Warden's spell table. Now you can't select the spell for your opponent
- Fixed campaign transfer feature.
- Fixed compatibility with TUM Enchanted: Soul Eaters now raise correct third upgraded skeletons.
- Now you are able to choose a spell in or outside of battle
- Partially fixed MP support - now in PVP battle, the change of commander spell type would be reflected to another side.
- Fire Mage: now their Fireball/Inferno attack ignores the spell immunity of hostile unit and also protect own units.
- Paladin Exp and Brute Gold: Fixed multiple logic glitches.
- Paladin Exp: Now bonus exp from damage is maxed at 10 million
(with all the bonuses. The value can be greater without overflow, only it's for balance concern)
- Added commander class constants (it's strongly recommended to add a new .erm with all the ACM constants for convenience)
- Reset bought spells when a commander is bought from a town
- Fixed AI not using summon elemental spells
- Fixed localization of "None" English word in erm
- Added new class names for adventurers of each faction
- Fixed erm error of commander's Strike All Around script
- Fixed screen update when putting on the second artifact with the same name

#### ERA Scripts:
- Mortal Heroes: Fixed campaign transfer feature

#### Game Enhancement Mod:
- the plugin and script for obtaining local and remote versions have been rewritten. To get the local version, a function is now used that returns a string value: "!!FU(gem_GetGameVersion):P?(gameVersion:z);";
- added a check for the presence of saved VoG options settings and a warning about the need to save if they are missing;
- Added ArchBugFixes.era [sources](https://github.com/Archer30/Era-Plugins/tree/main/ArchBugFixes);
- Updated Prima.dll: Fixed not doubling spell points when visiting Mana Vortex when the hero has >127 knowledge.

#### Enhanced Henchmen:
- Fixed campaign transfer feature.

#### Random Wallpaper Mod:
- the plugin for adding a logo has been rewritten to fix a crash when trying to open the game loading window;

#### TrainerX:
- added correct opening of the map after increasing the hero’s visibility radius;

#### WoG:
- Added the "ERA_MultilingualSupport.era" plugin, which allows you to change the language of downloaded resources from Lang/.\*json if localized. The list and parameters of localizations are specified in the file /Mods/WoG/Lang/era.json;

#### WoG Scripts:
- Neutral Town: Fixed elemental creatures cannot be upgraded in hill forts. Fixed neutral town option disabling Rampart Faerie Dragon option
- Added a fix to prevent getting random monsters not allowed to spawn on the map.
- Fixed wrong mapping of external dwellings giving extra growth to creatures in town.

#### Other:
- added the missing file /Tools/H3DefTool/Grid.pcx to launch H3DefTool;
- added the missing file h3wmaped_unleashed.exe to launch the advanced map editor;
- added a manual for disabling DEP (Help/DEP_tutorial.html);
- removed unnecessary tool files;

### Version 2.967

#### Advanced Classes Mod:
- Summon Elemental: Now we use the native way for summoning elemental, corrected the shadow of the battlefield, spell book icon and potentially fixed other issues
- Fixed GM Quicksand messing up highlight
- Commander class is now replay proof
- Kill count is now adding only after kill (instead of before kill). This also fixes in some situation that the kill isn't really there but is still considered valid, for example, some block/reflect abilities of the attacking unit, that prevents a kill, or the attacking unit is killed in the process (like burned by Fire Shield).
- Fixed STOIC_WATCHMAN not giving 10% resistance as the description says
- some format changes
- Now we use hook instead of playing UN:C at needed timing to cover everything in the game and clean our code.
It fixed the not showing correct spell point in the battle [problem](https://discord.com/channels/580473641104310301/580473641104310305/1238718760123109407)
- Fixed wrong condition checked for TUM 8th creature;
- Fixed not possible to raise Wights;
- Fix and balance Fortune;
- Grand Master Fortune now:
    - steals 2 speed, 3 damage, 4 attack or 4 defense on attack (slightly less than previous value);
    - Grand Maser Fortune now respect spell immunity (Black Dragons cannot be stolen by default)
    - Lowest speed is now 2
    - If not enough stats to be stolen, battle log shows the exact value stolen;
- small correction for Spell Point regeneration display
- secret class improvements;
- Fixed duplicate option in "Choose Class" option (at the start of the game). There are two "Ask after 5 levels". Now one of them is now Ask after 2.
- Fixed artifact set detection. Equipping two artifacts with the same name no longer reduces 1 from your set pieces count..
- The max kill count for commander is now at 9999 (visual change)
- AI now can also advance their class set stats with each victory (if they mange to loot one from human. They do not drop class sets due to &1000 condition);

### Game Enhancement Mod:
- Fixed messing the first acting unit when the speed of two stacks are the same;
- rewritten GetTime function;
- updated version check function;

### WoG:
- added locale list for the future change locale dlg;

### WoG Scripts:
- Attacking in melee war machines fix removed cause it is already represented in the plugin;
- Enhanced War Machines III: Fixed possible to heal hostile stacks
- Fishing well: small init message fix;


### Version 2.966

#### Advanced Difficulties Mod:
- Now ranged stack exp abilities would never be given to melee creatures.
- Reduced the rate of guards accumulation for TUM creature banks.
- Added a check to prevent faulty value being executed.
- Neutral Difficulties: Now clicking on the reset button will also disable Mixed Neutrals if it was enabled.

#### Advanced Classes Mod:
- fixed possible erm error with Necromancy;
- When Eagle Eye I (learning spell on levelling up) is enabled, it would remove itself if no spell can be learned in the future. Now if ACM is enabled, this mechanism would not be activated.
- War Machine Upgrade dialog: Fixed the interaction when clicking on upgrade button without choosing any upgrade
- Buff the Landmine spell by doing these changes:
    - Now the spell can be cast if there are native terrain creatures on enemy stack
    - Native terrain creatures will see landmine as normal but will take damage from mines (this change has to be reconsidered after latest plays-testing)
    - Improved Arcane Prophet ability (now damage increase i shown when starting the combat and not randomly selected before every cast. Damage increase directly visible in the spell book). Updated artifact description of SP Reg artifacts.
    - Druid Concentration Perk now works with battle replay.
    - Lord ability or Town plunder now has a 2 week cool-down for each town
    - Master Warrior Perk corrected name. Hybrid classes now get the same amount of crit as Master Warrior
    - Brute commander passive now also work for defending hero
    - Hypnotize duration fix thanks to SadnessPower
- Improved the mouse interaction when clicking on luck icon from hero screen
- Improved mouse interactions (whether to disable standard action or when to disable, etc)
- Fixed the name of the secret class can be revealed before it's unlocked.
- Export some text in erm to json
- Removed unused TUM art table content
- Balanced Sniper class. Now the HP as damage is 7% + 1% for every 7 kills (as discussed). The max value is at 50%. For boss creatures (MA:P >= 5000), the max value is halved (25%).
- Now 10 ss mode is enabled automatically when over 10 skills can be obtained in the game, even if the 10ss or other plugin increasing skill limit are enabled after game starts.
- Extended the clickable area of acmlist.txt - Promoted commander class info so it's more comfortable to click.
- Put a "+" sign before static speed bonus in acmlist.txt. In this way it's less confusing to me.
- ACM - hero screen hotkeys:
    - Press A - current advanced class
    - Press W - advanced classes info
    - Press E - Bonus table
    - Press R - Spell Trainer table (if Enabled)
- Fixed Alt Necromancy allows you to choose higher level creature to raise even if the Necromancy level does not meet the requirement.
- ACM Estates shows in Kingdom Overview;
- No longer disable Alt Necromancy by default when TUM is enabled as they are compatible now.
- Scouting: Now it supports extended monsters. Only monsters with strength < level 8 are allowed to appear in random events.
- Nobility: Now it supports 8th creatures (TUM);
- Fixed spell points not x10 when summoning elemental on adv map;
- Recreated creature specialists. Now it works the native way, shows bonuses in creature dlg when not in combat. Works for Ignissa as well.
- Recreated right-click for details War Machines enhancement from hero screen/hero meeting screen. Now the feature support hero meeting screen.
- Fixed a critical issue: When you check creature info in non-combat, sometimes it shows info of commanders (ACM_beforeCreatureInfoDlg_Show).
- Added UN32 icons for new specialties
- Fixed all the mouse interactions on hero's specialty icons. Now Left mouse click will trigger a normal message dialogue instead of pop-up as it should.
- Disable useless mouse interaction on set names from ACM art set DL. Added set description when clicking on set names is planned but having to manage Russian language is not easy to do.
- Fixed Lord Haart's specialty: icon and text
- Passive for Paladin commander now works for defender
- Spells learned with Eagle Eye will be reset in case of Battle Replay
- ACM - Disable ACM backpack art feature, fix compatibility with spell desc;
- Disable ACM backpack artifacts feature, release ERA Scripts backpack artifacts from ban as ES option works slightly better and seems to be more welcome (as it works also for movement points arts).
- Release Gate Key from ban. Now it can be used to lock your town as in WoG. The effect would be changed in the future when we com up with new ideas.
- Fix compatibility with spell description mod. Now the incorrect text from spell book is disabled.
- Commander's Strike All Around now doesn't show -10% attack bonus in ACM bonus table
- Added a failed safe condition for Commander's Strike All Around script for secondary targets. This sciprt won't work if the attacker, the defender and the secondary targets are all in the same side (possible with Berserk); To solve this, we need to introduce a new hook to get the actual attacking stack. But this is a rare situation so we are not doing it for now"
- Fixed mouse interaction on spell points icon (for LMB, mouse action should be 12, not 13)
- Reworked all the movement points additions. Now you don't have to worry about the max movement points got changed after you open the hero screen. Fixed Master Pathfinding not granting you at least 1700 movement points every turn. Fixed Master/Grandmaster Logistics don't work with Logistics specialty.
- Revised creature specialties display. Now all the bonus stats, including native ones are show in creature specialty description.
- Fixed Ancient not getting +4% after 100 kills
- Fixed memory leak for War Machines description on the battlefield
- Reworked drain effect. Now it should work exactly like the native Vampirism mechanism. Tell me if anything is different

#### Enhanced Henchmen:
- Fixed not able to change henchmen when there is only one creature in the hero's army;
- Fixed Cancel text;

#### ERA ERM Framework:
- FU(UpdateNextStackTurn) would be executed once in !?FU(OnBattleRound_Quit)&i^battle_round^=0 to make sure the turn order is not messed up by scripts.

#### ERA Scripts:
- Fixed unlimited skeleton summons from Skeleton Artifacts option;
- Fixed crash of Devil sacrificing
- 28 Secondary Skills: Improved the compatibility with plugins changing sec skills amount.
- Ranged Death Stare: Now Ranged Death Stare does not work on commanders and level 8 creatures (despite level 8 creatures can be affected by Melee Death Stare). Fixed erm errors. Optimised mouse hints. Fixed erm errors. FU(ES_995_CheckIfStackAffectedByDeathStare) can be used by scripters to exclude their stack from the effect of Ranged Death Stare.
- Night Scouting: Fixed Assassins not showing up.

#### Game Enhancement Mod:
- fixed rare combat crash;
- Update "Game Bug Fixes Extended":
    - Fixed Force Field cursor shadow for defending player;
    - Fixed possibly getting stuck when AI revives a killed stack;
- Changed the fix of AI value overflow from dividing creatures AI value by 15 to 10. This is to soften the issue that AIs become much less aggressive after the division.
- Recreate Dragon Heart summon as the original way can summon dragons overlapping other units ([Discussion](http://wforum.heroes35.net/showthread.php?tid=4218&pid=138936#pid138936))
- Added a general fix to ensure in a new day, the max movement points and current movement points are equal for every hero - this is helpful to prevent some wog features and scripts messing this up;

#### Secondary Skills Scrolling:
- Fixed Tactics button not working when Tactics is not on the current page;

#### TrainerX:
- Now disabling/re-enabling events, build/demolishing town buildings would still work when a event/town is under the hero clicked.
- Added reversal god mode activated by Shift-clicking on the hero's portrait in the trainer's main interface, basically set everything to minimum.
- Fixed some error in Display Events feature
Note: Since now Display Events relies on erm hook to work, loading TrainerX during the game with F12 requires one extra step: save game and load.
- Improved TrainerX's ability to load after game started. Now you don't need to Press F12 + Save and Lod (only F12 needed) when loading TrainerX after game started
- Fixed possible erm error when checking hero screen from TrainerX main dialog.
- God mode can now be used when there is no hero for changing map visions and resources.

#### WOG:
- Fixed Dwellings of Efreeti and Pit lords switching around in zlagport.def

#### WoG Fix Lite:
- updated to version 2.17;
- [Fixed Sacred Phoenix sprite](https://discord.com/channels/665742159307341827/741855494276382801/1232159404359680041)

#### WoG Scripts:
- Now the Market of Time in Titan's Winter map works correctly;
- Optimised the compatibility with Warfare;
 - Emerald Tower: Added Living enhancement;
 - Mithril Enhancement: Now mithril enhancement effects on Windmills/Waterwheels are permanent (like in WoG 3.58f. Not sure why this was changed. The cost for enhancement is more reasonable for a permanent upgrade);
- Creature Relationship: Fixed creature type got corrupted after a conflict happens;
- Fixed warfare not setting all the skills at once;
- Enhanced Monsters: Fixed Devils possibly gaining free speed with Tactic phases activated in a battle
- Enhanced Artifacts I: Now the msg of Pendant Of Second Sight, Pendant Of Free Will and Surcoat Of Counterpoise will only be shown if their effects are actually activated. Fix Garniture Of Interference not being able to be traded for a magic skill on Monday.
- Now all the monster/artifact replacement script ignores customised neutral stacks and artifacts on the map.
- First Aid I: Prevent First Aid I to revive creatures when the original troops are completely killed in any case.
- Henchmen: Small optimisation to AI henchmen selection
- Emerald: Fixed creature names messing up after enhancement.
- Emerald Towers: Clarify the info when the player has not enough to pay.
- Altar of Transformation: Fixed neutral creatures not possible to be converted.
- Emerald Towers: Fixed 6 gems (appointment fee) are always returned. They should be returned only when no enhancement or 24 shots was chosen.
- Emerald Towers: AI will now no longer enhance Undead or Living as they can't use them properly.
- Fixed banning spells from Scholars: Now spells disabled from the map (instead of from wog options) will not trigger the script of banning spells from Scholars.
- Fixed hotseat support hint for Enhanced War Machines III
- Emerald Tower: Fixed showing double dialogues when returning the appointment fee (6 gems).

### Version 2.965

#### Game Enhancement Mod:
- restored end of turn button;

#### WoG Scripts:
- Fixed non replacing banned spells for scholars;
- Moved henchmen's warlord's banner to the hero's backpack when killed - thanks to Archer30;
- Small text fixes;

### Version 2.964

#### ERA ERM Framework:
- added constants about quest types and rewards;
- added function that refreshes all quests on the map (doesn't affect custom text);

#### Game Enhancement Mod:
- added 8px offset for the drawing custom dialogs near to game window borders;;
- removed extra pcx creation;

#### WoG Scripts:
- Fixed the description of Diplomatic artifacts when Enhanced Artifacts I/II and Diplomatic Bargain are enabled - thanks to Archer30;
- Enhanced Commander: Moved the place to jump (would not make a difference for commander though) - thanks to Archer30;
- Fixed defeating neutral stacks with random heroes not completing the corresponding seer hut quest - thanks to Archer30;
- Living Scrolls && Hero Specialisation Boost: removed auto casts on the immobilized stacks;

#### ERA Scripts:
- Capture mills and gardens: Added a coordinates check as there was a report about invalid coordinates - thanks to Archer30;

#### TrainerX:
- Now removing creatures or heroes on the map would also complete the corresponding seer hut quest - thanks to Archer30;

### Version 2.963

#### Game Enhancement Mod:
- Fixed mixing of units in towns (there were pikermen in the fortress and conflux);

#### WoG Scripts:
- New battlefields: non-working fields have been fixed - thanks to Yuritsuki;

#### ERA Scripts:
- Machine Capture: fixed crash when capturing other artifacts;
- Night scouting: fixed assassin switch not working;

### Version 2.962

#### Game Enhancement Mod:
- Removed hardcore memory edits;

#### WoG Scripts:
- Warfare: Fixed crash when AI tries to get one of Warfare Skill;

#### ERA Scripts:
- Elemental Suppression: Fixed possible to lose magic skills after battle - thanks to Archer30;
- Capture War Machines: Fixed disappearing of the captured War Machines;
- Removed unused script and text for Capture War Machines - thanks to Archer30;
 
### Version 2.961

#### Game Enhancement Mod:
- Added some 1st April scripts;
- Hill Forts - the cost of upgrade is calculated based on the level of the upgraded monster instead of the pre-upgraded monster - thanks to Archer30;
- Fixed maximum hero level restriction script - thanks to Archer30;
- Optimised flexible cheats input. Now space before the first word would be ignored - thanks to Archer30

#### WoG Scripts:
- Enhanced Artifacts II: Fixed Ring of the Magi and its components may not work for spell damage boost - thanks to Archer30

#### Advanced Classes Mod:
- Fixed possible to learn spells from Artifacts with GM Scholar - thanks to Archer30;
- Added a fix for future TUM Full - thanks to Archer30;
- Updated the graphics of Magic Want to be compatible with TUM - thanks to Archer30;
- Updated localization - Big thanks to DrD_AVEL_;
- Fixed reduced necromancy rate works only for attacking hero
- Fixed Alternative Necromancy sets the rate of Necromancy instead of restraining it - thanks to Archer30;
- Soul Prism now still provides 20% bonus to Necromancy (instead of 10%) - thanks to Archer30;
- Fixed the text of Necromancy Amplifier (it provides 5% bonus instead of 10%) - thanks to Archer30;
- Optimised the dialogue of Alternative Necromancy. Now it remembers the last choice of the hero. It shows the real creature to be raised by default (instead of skeletons) - thanks to Archer30;

### Version 2.96

#### ERA:
- Updated to version 3.9.11 - thanks to Berserker;
- Updated "game bug fixes extended.dll" plugin - thanks to igrik;

#### HD mod:
- Updated to version 5.5 R6 - thanks to baratorch;

#### ERA ERM Framework:
- Added initialization of i^battle_round_^ on replay - thanks to Archer30

#### Game Enhancement Mod:
- Added Flexible Cheats feature. Now all the cheat codes from RoE/AB/SoD are supported. If a cheat code is entered with other unrelated info, it would also be recognized and applied - thanks to Archer30
- Improved the fix for mage guild in rebuilt towns (after demolishing): Now high level spells would appear in guilds. Added spell research support - thanks to Archer30

#### WoG Scripts:
- New Creature Banks: Now upon the guards of Lost Bottles are defeated, the hero would be asked whether to pick the bottle up. If the bottle is picked up, the hero can read the a random msg inside, and the bottle would vanished from the map permanently - thanks to Archer30

#### ERA Scripts:
- Custom Primary Skills: Fixed possible to distribute PS when levelling up - thanks to Archer30

#### Advanced Classes Mod:
- Fixed possible to learn spells from Artifacts with GM Scholar - thanks to Archer30
- Added a fix for future TUM Full - thanks to Archer30
- Updated the graphics of Magic Want to be compatible with TUM - thanks to Archer30
- Updated localization - thanks to PerryR;

#### Advanced Difficulties Mod:
- Replaced the icon for Primary Skills with original H3 style (was WoG) - thanks to Archer30

#### TrainerX:
- Added God Mode. Alt-click on the hero's portrait to max out Army/Movement/Mana/Fly/Primary Skills/Secondary Skills/Spells/Vision of the map/Resources - thanks to Archer30
- Added Ctrl/Alt/Shift-click on the secondary skills title to manage all the secondary skills at once - thanks to Archer30
- Fixed Scrolling on Primary Skills not working correctly when the stats is over 127 - thanks to Archer30
- Now opening the hero screen from Trainer will allow to editing any data of the hero (instead of view only) - thanks to Archer30;
