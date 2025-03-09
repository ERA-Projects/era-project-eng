[![Github Downloads](https://img.shields.io/github/downloads/ERA-Projects/era-project-eng/total)](https://github.com/ERA-Projects/era-project-eng/releases)
[![ERA Discord Invite](https://img.shields.io/discord/665742159307341827?color=%237289DA&label=chat&logo=discord&logoColor=white)](https://discord.gg/bvfJGZe)

# ERA Project (English version)
## This repository is used to develop and publish releases of the **English version** of the ERA Project
> [!IMPORTANT]
> ### [ERA Project (Russian version) repository](https://github.com/ERA-Projects/era-project-rus)


# Game installation
## 1. Automatic game installation:
- Download [Heroes Launcher from here](https://github.com/HeroesLauncher/heroeslauncher/releases) and install **NOT** in the system folder;
- Select the "**ERA**" tab in the game list;
- specify a folder with any working version of the game "Heroes of Might and Magic III", based on "Shadow of Death", which can be one of:
    - Shadow of Death/SoD (Breath of Death);
    - Complete (Complete Collection) You can buy it in the [UBISOFT Store](https://store.ubisoft.com/us/heroes-of-might-and-magic-3--complete/575ffd9ba3be1633568b4d8c.html), or in [GOG](https://www.gog.com/en/game/heroes_of_might_and_magic_3_complete_edition), or in the [EPIC GAMES Store](https://store.epicgames.com/en-US/p/might-and-magic-heroes-3);
    - Master of Puppets/MOP;
    - In the Wake of Gods/WoG;
    - Horn of the Abyss/HotA (Horn of the Abyss) - You can download it from the [Official Site](https://h3hota.com/en/download);
- Select the required language for installing the assembly (Russian or English);
- Confirm or select a new folder where the assembly will be installed;
- Wait for the files to download and unpack;
- Click on the "Gear" button next to the "Play" button;
- Select ``HD-mod settings`` to launch the HD Mod settings:
    - change the language to "English";
    - set the desired game resolution;
    - the ``(stretchable) 32-bit OpenGL by Verok`` mode is recommended;
    - configure ["**TWEAKS**"](https://sites.google.com/site/heroes3hd/eng/tweaks);
- Click "**Play**" in Heroes Launcher to start the game;

## 2. Manual installation of the game:
- Prepare a working game folder based on any working version of the game "Heroes of Might and Magic III", based on "Shadow of Death", which can be one of:
    - Shadow of Death / SoD (Breath of Death);
    - Complete (Complete Collection) You can buy it in the [UBISOFT Store](https://store.ubisoft.com/us/heroes-of-might-and-magic-3--complete/575ffd9ba3be1633568b4d8c.html), or in [GOG](https://www.gog.com/en/game/heroes_of_might_and_magic_3_complete_edition), or in the [EPIC GAMES Store](https://store.epicgames.com/en-US/p/might-and-magic-heroes-3);
    - Master of Puppets / MOP;
    - In the Wake of Gods/WoG;
    - Horn of the Abyss/HotA (Horn of the Abyss) - You can download it from the [Official website](https://h3hota.com/en/download);
- Create a folder where the following will be copied:
    - all ".dll" files from the root directory of the game;
    - "MP3" folder - entirely
    - "Data" folder - with files:
      - "H3bitmap.lod";
      - "H3sprite.lod";
      - "Heroes3.snd";
      - "VIDEO.VID";
    - optionally the "Maps" folder, if you need maps from it;
- [**Download the current release**](https://github.com/ERA-Projects/era-project-eng/releases/latest) of this repository;
- Unzip to the prepared game folder;
- Run the file ["Tools/install.bat"](Tools/install.bat) to initialize the list of default mods or run ["Tools/Mod Manager/mmanager.cmd"](Tools/Mod%20Manager/mmanager.cmd) and connect the necessary Mods (the "WOG" mod is required);
- Run the file ["HD_Launcher.exe"](HD_Launcher.exe) to run the HD Mod settings:
    - change the language to "English";
    - set the desired game resolution;
    - the ``(stretchable) 32-bit OpenGL by Verok`` mode is recommended;
    - configure ["**TWEAKS**"](https://sites.google.com/site/heroes3hd/eng/tweaks);
- Run the file ["h3era HD.exe"](h3era%20HD.exe) to start the game;

# Game update
## 1. Automatic game update:
- Launch the previously installed [Heroes Launcher](https://github.com/HeroesLauncher/heroeslauncher/releases)
- Click the "Gear" button next to the "Play" button;
- Select ``Check for updates``;
- Wait for the update to complete;

## 2. Manual game update:
- [**Download the latest release**](https://github.com/ERA-Projects/era-project-eng/releases/latest) of this repository;
- Make sure that there were no deleted files in "Mods" between the installed version and the new one;
        - If any mod had such files, it is highly recommended to delete the folder of this mod from the folder with the installed game;
- Unpack the files from the downloaded archive into the folder with the installed game, replacing files whose size or date differs;

# Uninstalling the game
## 1. Automatically uninstalling the game:
- Launch the previously installed [Heroes Launcher](https://github.com/HeroesLauncher/heroeslauncher/releases)
- Click the "Gear" button next to the "Play" button;
- Select ``Uninstall``;
- *Optionally* you can Keep the base game files, deleting only the Game Assembly files;
- Confirm deletion;

## 2. Manually uninstalling the game:
- Delete the game folder;

> [!NOTE]
> ## To get the latest version of the project, download it from [RELEASES](https://github.com/ERA-Projects/era-project-eng/releases/latest)

> [!TIP]
> ## It is recommended to use [Heroes Launcher](https://github.com/HeroesLauncher/heroeslauncher/releases) to get updates
> ## [Changelog](https://github.com/ERA-Projects/era-project-eng/blob/main/CHANGELOG.md)
