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

#### Game Enhancements Mod:
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

#### Game Enhancements Mod:
- restored end of turn button;

#### WoG Scripts:
- Fixed non replacing banned spells for scholars;
- Moved henchmen's warlord's banner to the hero's backpack when killed - thanks to Archer30;
- Small text fixes;

### Version 2.964

#### ERA ERM Framework:
- added constants about quest types and rewards;
- added function that refreshes all quests on the map (doesn't affect custom text);

#### Game Enhancements Mod:
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

#### Game Enhancements Mod:
- Fixed mixing of units in towns (there were pikermen in the fortress and conflux);

#### WoG Scripts:
- New battlefields: non-working fields have been fixed - thanks to Yuritsuki;

#### ERA scripts:
- Machine Capture: fixed crash when capturing other artifacts;
- Night scouting: fixed assassin switch not working;

### Version 2.962

#### Game Enhancements Mod:
- Removed hardcore memory edits;

#### WoG Scripts:
- Warfare: Fixed crash when AI tries to get one of Warfare Skill;

#### ERA scripts:
- Elemental Suppression: Fixed possible to lose magic skills after battle - thanks to Archer30;
- Capture War Machines: Fixed disappearing of the captured War Machines;
- Removed unused script and text for Capture War Machines - thanks to Archer30;
 
### Version 2.961

#### Game Enhancements Mod:
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

#### Game Enhancements Mod:
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
