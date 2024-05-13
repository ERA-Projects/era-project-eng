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
