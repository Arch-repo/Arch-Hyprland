<div align="center">

# 🚀 anto426 Arch-Hyprland

[![Typing SVG](https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=28&duration=3000&pause=1000&color=8cb8e4&center=true&vCenter=true&width=435&lines=Arch+Hyprland+Setup;Aesthetic+Wayland+Install;Automatic+Deployment)](https://git.io/typing-svg)

A beautiful, automated installer to deploy a complete Wayland/Hyprland desktop ecosystem on Arch Linux.

</div>

---

## ✨ Preview

> [!NOTE]
> Previews, screenshots, and setup demonstration videos are currently **to be uploaded** (*ancora da caricare*).

### 📽️ Videos
- ⏳ *Demo video coming soon (to be uploaded)*

### 📸 Screenshots
- ⏳ *Setup screenshots coming soon (to be uploaded)*

---

## 📝 Important Notes

> [!IMPORTANT]
> This script automates the installation and setup of my Arch Hyprland environment.
> - If you want to try it, you should use a minimal profile and backup your system beforehand.

> [!NOTE]
> This script does not include package uninstallation, as some packages may already exist on your system by default. Creating an uninstallation script could potentially affect your current setup.
> Non-essential entertainment apps are not installed by the base setup.

### ⌨️ Keybinding Hint
Press `SUPER + H` (Windows + H) to open the interactive keybinding hints.

---

## ⚙️ Installation

Use this script to install Hyprland on a clean Arch-based system:

```bash
git clone --depth=1 https://github.com/Anto426/Arch-Hyprland.git
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh
```

---

## 📂 Repository Variables

The installer uses these repo variables and checks that existing cached clones point to the expected remote before pulling:

```bash
DOTFILES_REPO=https://github.com/Anto426/dotfiles.git
WALLPAPER_REPO=https://github.com/Anto426/Wallpaper-Collection.git
ANTO_THEME_REPO=https://github.com/Anto426/Anto426-theme.git
ANTO_GRUB_THEME_REPO=https://github.com/Anto426/grub2-themes.git
```

---

## 🎨 Theme Repos

- 🖌️ **GTK Base Theme**: Installed from [`Anto426-theme`](https://github.com/Anto426/Anto426-theme), a tuned fork of Orchis used as the stable base for the dynamic color engine.
- 🗂️ **GRUB Theme**: Installed from [`grub2-themes`](https://github.com/Anto426/grub2-themes), a single `anto426` theme aligned with the Riva controls.
  - The Arch installer auto-detects the active display resolution for GRUB. You can still override it before running `install.sh`:
    - `ANTO426_GRUB_SCREEN=2k` or `4k`
    - `ANTO426_GRUB_RESOLUTION=3440x1440` (for custom ultrawide)

---

## 🌌 Inspirations

I drew inspiration from the following projects and communities:

- [r/unixporn](https://www.reddit.com/r/unixporn/)
- [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)
- [Hyde-project/hyde](https://github.com/Hyde-project/hyde)
- [mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles)

and more...

---

<div align="center">
  <i>Configured by anto426</i>
</div>
