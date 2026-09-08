![T0rment0rRice desktop](Pictures/desktop.png)
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/b524e67f-a682-4733-a9ab-65fe7304cd81" />




# T0rment0rRice

A ready-to-use Linux rice assembled from existing open-source projects, with custom configuration, integration, wallpapers, and **The Installer**.

> **I did not create the original components used in this rice. I assembled them, configured them, modified parts of them, and integrated them into one setup.**

## What is this?

T0rment0rRice is a starter rice for a Wayland desktop environment.

The goal is to provide a complete setup without requiring users to manually assemble every component themselves.

It combines:

* **Ashell** for the status bar
* **Quickshell** modules for the application launcher and wallpaper selector
* **Matugen** for dynamic theming
* A collection of wallpapers from **dharmx/walls**
* Custom configuration and integration
* **The Installer** for automated installation

The project is intended as a starting point. Feel free to modify, replace, remove, or extend any part of it.

---

## Components

### Ashell

[MalpenZibo/ashell](https://github.com/MalpenZibo/ashell)

Used as the status bar.

Ashell provides the main bar and its modules, with configuration handled through TOML.

The Ashell configuration in this rice has been customized to fit the overall design and layout.

### Quickshell

[doannc2212/quickshell-config](https://github.com/doannc2212/quickshell-config)

This rice uses components from doannc2212's modular Quickshell configuration:

* Application launcher
* Wallpaper manager / selector

The original project is modular, so only the components needed for this rice were used.

### Matugen

[InioX/matugen](https://github.com/InioX/matugen)

Used for dynamic theming.

Colors are generated from the current wallpaper and used throughout the configuration to keep the desktop visually consistent.

### Wallpapers

[dharmx/walls](https://github.com/dharmx/walls)

The wallpaper collection is sourced from this repository.

**The wallpapers are not my original work. Credit belongs to their respective artists and creators.**

Please refer to the original repository for the wallpaper collection and its attribution information.

---

## The Installer

The main piece of original work in this repository is **The Installer**.

It handles:

* Arch / Arch-based system detection
* Official package installation
* AUR package installation
* Automatic `yay` installation when required
* Existing configuration backups
* Configuration deployment
* Local script deployment
* Wallpaper deployment
* Installation summaries and confirmation
* Error handling and cleanup

The installer is designed to make installing the rice significantly easier while still keeping the user's existing configuration backed up.

### Backup

By default, the installer creates a backup before modifying existing configuration.

To disable the backup:

```bash
./install.sh --no-backup
```

---

## Installation

Clone the repository:

```bash
git clone https://github.com/SteelT0rment0r/T0rment0rRice.git
cd T0rment0rRice
```

Run the installer:

```bash
./install.sh
```

The installer will show what it intends to install and ask for confirmation before making changes.

**Do not run the installer as root.**

---

## Requirements

This rice is primarily intended for:

* Arch Linux
* Arch-based distributions
* Wayland
* Hyprland

The installer can detect non-Arch systems and will warn before continuing.

---

## Important

This repository is an **assembled rice**, not an original collection of every component used in it.

I did not write:

* Ashell
* Quickshell
* Matugen
* The original wallpaper collection

The purpose of this project is to bring these existing projects together into a cohesive, installable setup.

All original projects retain their respective licenses and attribution.

Please refer to each upstream repository for its own licensing and contribution information.

---

## Credits

| Project                                                                         | Used for                                    |
| ------------------------------------------------------------------------------- | ------------------------------------------- |
| [doannc2212/quickshell-config](https://github.com/doannc2212/quickshell-config) | Application launcher and wallpaper selector |
| [MalpenZibo/ashell](https://github.com/MalpenZibo/ashell)                       | Status bar                                  |
| [InioX/matugen](https://github.com/InioX/matugen)                               | Dynamic theming                             |
| [dharmx/walls](https://github.com/dharmx/walls)                                 | Wallpaper collection                        |

### My work

My contribution to this project is primarily the **assembly, configuration, integration, modifications, package definitions, wallpaper selection, and The Installer**.

The installer is intended to turn the collection of components into something that can be deployed with a single command.
As for the important shortcuts:


Mod + D -> App Launcher


Mod + R -> Also App Launcher


Mod + W -> Wallpaper Switcher


Mod + T -> Launch Kitty


Mod + Q -> Kill Focused Window


Mod + E -> Dolphin File Manager


Mod + V -> Float Focused Window


Mod + Arrow Keys -> Move Focus (But focus also follows cursor)

***DISCLAIMER***

You might wanna change the scale in ~/.config/hypr/hyprland.lua because I use 0.7 scale, or you can use the Hyprmod app which can be installed by typing yay -S hyprmod in your terminal!

The keyboard layout is Turkish Q layout, can be changed by editing the input section of ~/.config/hypr/hyprland.lua, for example to get US layout you need to change kb_layout = "tr", to kb_layout = "us",

---

## License

The individual components used by this project remain under their respective licenses.

Check the upstream repositories listed above before redistributing modified versions of their work.

