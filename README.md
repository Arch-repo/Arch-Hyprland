# My Arch-Hyprland

## Table of Contents
- [Preview](#preview)
    - [Videos](#videos)
    - [Screenshots](#screenshots)
- [Notes](#notes)
    - [Keybinding](#keybinding)
- [Installation](#installation)
- [Dotfiles Repo](#dotfiles-repo)
- [Wallpapers Repo](#wallpapers-repo)
- [Theme Repos](#theme-repos)
- [Inspirations](#inspirations)

## Preview
### Videos
[▶️ Watch on YouTube](https://youtu.be/j_eCc8s1v3M)

<https://github.com/user-attachments/assets/8fc6831a-26cc-4415-8005-a533fa1bfb72>

### Screenshots
<p align="center">
    <img src="https://github.com/user-attachments/assets/a004c50a-4001-4596-a48e-97ecc9997843" alt="Image-1.png" width="49%"/>
    <img src="https://github.com/user-attachments/assets/5d59431c-de0c-487d-bc1a-ea4b2828787a" alt="Image-2.png" width="49%"/>
    <img src="https://github.com/user-attachments/assets/b2b0674f-4709-40d3-bfbe-9c5c5660bf3b" alt="Image-3.png" width="49%"/>
    <img src="https://github.com/user-attachments/assets/c55950ed-8e7b-4e10-bde3-dd445fbc388b" alt="Image-4.png" width="49%"/>
</p>

## Notes
> [!IMPORTANT]
> `This script automates the installation and setup of my Arch Hyprland environment.`
> - If you want to try it, you should use a minimal profile and backup your system beforehand.

> [!NOTE]
> This script does not include package uninstallation, as some packages may already exist on your system by default. Creating an uninstallation script could potentially affect your current setup.
> Non-essential entertainment apps are not installed by the base setup.

### Keybinding
`SUPER + H` (Windows + H) to open keybinding hints.

## Installation
Use this script to install Hyprland on an Arch-based system:
``` bash
git clone --depth=1 https://github.com/Anto426/Arch-Hyprland.git
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh
```

## Dotfiles Repo
This repo contains all my dotfiles: [`dotfiles`](https://github.com/Anto426/dotfiles).

## Wallpapers Repo
You can find the desktop wallpapers and Fastfetch terminal images in: [`Wallpaper-Collection`](https://github.com/Anto426/Wallpaper-Collection).

The installer copies `Wallpapers/` to `~/Pictures/Wallpapers` and `neofetch/` to `~/Pictures/neofetch`. You can later point the dotfiles sync config to Google Drive or another local folder via `~/.local/share/anto426/sync.env`.

## Theme Repos
The GTK base theme is installed from [`Anto426-theme`](https://github.com/Anto426/Anto426-theme), a tuned fork of Orchis used as the stable base for the dynamic color engine.

The GRUB theme is installed from [`Anto426-grub-theme`](https://github.com/Anto426/Anto426-grub-theme), a tuned fork of vinceliuice/grub2-themes with an `anto426` variant. You can set `ANTO426_GRUB_SCREEN=2k`, `ANTO426_GRUB_SCREEN=4k`, or `ANTO426_GRUB_RESOLUTION=3440x1440` before running `install.sh` if the default 1080p GRUB layout is not right for the machine.

## Inspirations
I drew inspiration from the following projects and communities:

- https://www.reddit.com/r/unixporn/
- https://github.com/JaKooLit/Hyprland-Dots
- https://github.com/Hyde-project/hyde
- https://github.com/mylinuxforwork/dotfiles

and more...

## Feedback
If you find this repo useful or have any suggestions, feel free to open an issue or submit a pull request. Happy ricing! 🍚
