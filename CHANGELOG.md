### Version 2.99

#### ERA Scripts:
- Fixed Cover of Darkness description corruption;

#### WoG Scripts:
- Fixed Creature Banks refill;


### Version 2.98

#### Other
- missing files restored;

### Version 2.97

#### ERA:
- updating the ERA.dll kernel to version 3.9.13:
	- ATTENTION! examples of using all innovations are in the file /Help/Era manual/era iii changelog.txt;
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

####TrainerX:
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

- updating the ERA.dll kernel to version 3.9.12:
	- ATTENTION! examples of using all innovations are in the file /Help/Era manual/era iii changelog.txt;
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
- Updated to version 5.4 R86 - thanks to baratorch;

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
