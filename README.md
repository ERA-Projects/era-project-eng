[![Github Downloads](https://img.shields.io/github/downloads/ERA-Projects/era-project-eng/total)](https://github.com/ERA-Projects/era-project-eng/releases)
[![ERA Discord Invite](https://img.shields.io/discord/665742159307341827?color=%237289DA&label=chat&logo=discord&logoColor=white)](https://discord.gg/bvfJGZe)

> [!IMPORTANT]
> ### [Русская версия репозитория →](https://github.com/ERA-Projects/era-project-rus)

# ⚔️ Heroes of Might and Magic III: ERA Project (English Version)

Welcome to **ERA Project** — a modern platform for *Heroes of Might and Magic III* modifications.  
ERA continues the ideas of **WoG (Wake of Gods)**, maintaining backward compatibility and providing powerful tools for modders, scripters, and plugin developers.

---

## 🧩 What is ERA

**ERA** is a modular enhancement for the original Heroes III that expands the game’s capabilities through:
- 🔹 **ERM 2.0** — an improved scripting language for events and logic;  
- 🔹 **C++ plugins** (via the ERA API);  
- 🔹 **Modular mod-loading system**;  
- 🔹 **Better compatibility** with HD Mod and modern systems;  
- 🔹 **Flexible customization** of random maps, objects, and UI.

ERA serves as a core engine upon which you can build large-scale modifications  
or lightweight plugins that change gameplay, visuals, or object behavior.

---

## 🚀 Key Features

- 🧠 **Modern ERM 2.0** — improved syntax, macros, new commands, and extended data types.  
- ⚙️ **C++ Plugin Support** — integrate via `.dll` files, hooks, and the extended ERA API.  
- 🗺️ **Map & Object Editor** — fine-tune spawn density, frequency, and generation rules.  
- 🎨 **Enhanced UI Framework** — new widgets, dynamic sprites, filtering, and sorting.  
- 📦 **Mod System** — modular activation, load order control, and conflict detection.  
- 💬 **Localization Support** — text loaded from JSON by locale name.  

> ## [📜 Changelog](https://github.com/ERA-Projects/era-project-eng/blob/main/CHANGELOG.md)

---

## 📦 Game Installation

> [!NOTE]
> To get the latest version, download it from [**RELEASES**](https://github.com/ERA-Projects/era-project-eng/releases/latest)

<details>
<summary><b>1️⃣ Automatic installation via Heroes Launcher</b></summary>

- Download [Heroes Launcher](https://github.com/HeroesLauncher/heroeslauncher/releases) and install it **outside system folders**;  
- Open the **ERA** tab in the games list;  
- Select any working version of *Heroes III* based on *Shadow of Death*:  
  - Shadow of Death (SoD);  
  - Complete Edition — available on [UBISOFT Store](https://store.ubisoft.com/us/heroes-of-might-and-magic-3--complete/575ffd9ba3be1633568b4d8c.html), [GOG](https://www.gog.com/en/game/heroes_of_might_and_magic_3_complete_edition), or [Epic Games Store](https://store.epicgames.com/en-US/p/might-and-magic-heroes-3);  
  - Master of Puppets (MOP);  
  - In the Wake of Gods (WoG);  
  - Horn of the Abyss (HotA) — from the [official website](https://h3hota.com/en/download);  
- Choose installation language (Russian / English);  
- Select the target directory;  
- Wait for files to download and unpack;  
- Open ⚙️ > `HD Mod Settings`:  
  - set language to *Russian* or *English*;  
  - choose your screen resolution;  
  - recommended mode: `stretchable 32-bit OpenGL by Verok`;  
  - adjust optional [“Tweaks”](https://sites.google.com/site/heroes3hd/eng/tweaks);  
- Click **Play** in Heroes Launcher.
</details>

<details>
<summary><b>2️⃣ Manual installation</b></summary>

- Prepare a working folder of *Heroes III* based on *Shadow of Death* (SoD / Complete / MOP / WoG / HotA).  
- Copy into a new directory:  
  - all `.dll` files from the game root;  
  - the `MP3` folder;  
  - the `Data` folder with:
    - `H3bitmap.lod`  
    - `H3sprite.lod`  
    - `Heroes3.snd`  
    - `VIDEO.VID`  
  - *optional*: the `Maps` folder;  
- [**Download the latest release**](https://github.com/ERA-Projects/era-project-eng/releases/latest);  
- Extract files into the game folder;  
- Run `Tools/install.bat` to initialize default mods,  
  or `Tools/Mod Manager/mmanager.cmd` to manage them manually (`WOG` mod is required);  
- Configure HD Mod via `HD_Launcher.exe`;  
- Launch the game through `h3era HD.exe`.  
</details>

---

## 🔄 Updating the Game

> [!TIP]
> Use [Heroes Launcher](https://github.com/HeroesLauncher/heroeslauncher/releases) for automatic updates.

<details>
<summary><b>1️⃣ Automatic update</b></summary>

- Launch **Heroes Launcher**  
- Click ⚙️ > `Check for Updates`  
- Wait for the process to complete  
</details>

<details>
<summary><b>2️⃣ Manual update</b></summary>

- [Download the latest release](https://github.com/ERA-Projects/era-project-eng/releases/latest);  
- Make sure no files were removed in any mods;  
- If some were deleted, remove those mod folders before updating;  
- Extract the new archive over the existing installation, replacing outdated files.  
</details>

---

## 🗑️ Uninstallation

<details>
<summary><b>1️⃣ Automatic removal via Heroes Launcher</b></summary>

- Open **Heroes Launcher**  
- Click ⚙️ > `Uninstall`  
- (Optional) keep base game files  
- Confirm removal  
</details>

<details>
<summary><b>2️⃣ Manual removal</b></summary>

- Delete the game folder manually  
</details>

---

## 🧰 For Developers

ERA provides an open platform for creating your own mods, scripts, and plugins.

- **ERM 2.0** — main event-driven scripting language  
- **C++ Plugins** — direct access to game internals via ERA API  
- **JSON / INI** — for configuration, localization, and parameters  

📘 [ERM 2.0 Documentation](https://github.com/ERA-Projects/era-script-docs)  
🔧 [ERA API Reference](https://github.com/ERA-Projects/era-api-docs)

---

## 🖼️ Screenshots

| Main Menu | TrainerX Mod | Random Map Generator Settings |
|------------|----------|----------------------|
| ![Menu](https://raw.githubusercontent.com/ERA-Projects/era-project-eng/refs/heads/main/Help/Screens/era_main_menu.png) | ![TrainerX Mod](https://raw.githubusercontent.com/ERA-Projects/era-project-eng/refs/heads/main/Help/Screens/era_trainer_dlg.png) | ![RMG](https://raw.githubusercontent.com/ERA-Projects/era-project-eng/refs/heads/main/Help/Screens/era_rmg_settings.png) |

---

## 🤝 Community

- 🌍 VK Group: [vk.com/wog_era](https://vk.com/wog_era)  
- 💬 Forum: [WoG Forum / ERA Project](http://wforum.heroes35.net/showthread.php?tid=5235)  
- 🧠 Discord: [ERA Discord](https://discord.gg/bvfJGZe)

Contributions are welcome — open a **Pull Request** or submit an **Issue** with your ideas.

---

## 🧾 License & Authors

This project is distributed under the [MIT License](LICENSE).  
Author and Coordinator — [**daemon_n**](https://github.com/daemon1995/)  
Contributors are listed in [contributors.md](CONTRIBUTORS.md)

---

> 🏰 *ERA Project is not just a mod — it’s a platform for endless Heroes III expansion.*  
> Create, experiment, and breathe new life into the game you love!
