#!/usr/bin/env bash
set -euo pipefail

# Variables
#----------------------------

# time variable
start=$(date +%s)

# Color variables
PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"

AUTO_SETUP_URL="${AUTO_SETUP_URL:-https://raw.githubusercontent.com/Anto426/auto-setup-LT/main/arch.sh}"
WALLPAPER_REPO="${WALLPAPER_REPO:-https://github.com/Anto426/Wallpaper-Collection.git}"
ANTO_THEME_REPO="${ANTO_THEME_REPO:-https://github.com/Anto426/Anto426-theme.git}"
ANTO_GRUB_THEME_REPO="${ANTO_GRUB_THEME_REPO:-https://github.com/Anto426/Anto426-grub-theme.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ANTO_CONFIG_DIR="$DOTFILES_DIR/.config/anto426"
THEME_BUILD_DIR="${THEME_BUILD_DIR:-$HOME/.cache/anto426-theme}"
GRUB_THEME_BUILD_DIR="${GRUB_THEME_BUILD_DIR:-$HOME/.cache/anto426-grub-theme}"

pacman_packages=(
    # Hyprland & Wayland environment
    hyprland hyprlock awww grim slurp wf-recorder swaync waybar
    rofi rofi-emoji yad hyprshot
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-wlr xdg-desktop-portal-gtk

    # System services and controls
    brightnessctl network-manager-applet bluez bluez-utils blueman
    pipewire pipewire-pulse wireplumber pavucontrol

    # Apps used by the dotfiles
    ghostty nemo gvfs curl python loupe celluloid gnome-text-editor evince
    ffmpeg cava cliphist gnome-characters keepass

    # Qt, display manager, and theming
    sddm qt5ct qt6ct qt5-wayland qt6-wayland nwg-look adw-gtk-theme kvantum-qt5
    sassc gnome-themes-extra gtk-engine-murrine

    # Input method
    fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-bamboo

    # Fonts and image libraries
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    libvips libheif openslide poppler-glib imagemagick grub
)

aur_packages=(
    # Desktop shell extras
    wlogout sddm-astronaut-theme apple_cursor whitesur-icon-theme tint

    # Browsers and editors
    brave-bin zen-browser-bin visual-studio-code-bin sublime-text-4

    # Fonts
    ttf-segoe-ui-variable
)

ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        return 0
    fi

    local build_dir
    build_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (
        cd "$build_dir/yay"
        makepkg -si --noconfirm
    )
    rm -rf "$build_dir"
}

install_hyprland_packages() {
    sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
    ensure_yay
    yay -S --needed --noconfirm "${aur_packages[@]}"
}

clone_or_update_repo() {
    local repo="$1"
    local target="$2"

    if [[ -d "$target/.git" ]]; then
        git -C "$target" pull --ff-only || true
    elif [[ -e "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$target" "$backup"
        echo -e "${BLUE}[NOTE]${PINK} ==> Existing $target moved to $backup"
        git clone --depth 1 "$repo" "$target"
    else
        git clone --depth 1 "$repo" "$target"
    fi
}

install_anto426_theme() {
    clone_or_update_repo "$ANTO_THEME_REPO" "$THEME_BUILD_DIR"

    (
        cd "$THEME_BUILD_DIR"
        if [[ -f ./install-anto426.sh ]]; then
            bash ./install-anto426.sh
        else
            ./install.sh -n Anto426 -c dark -t default --tweaks compact solid primary --round 8
        fi
    )
}

install_anto426_grub_theme() {
    clone_or_update_repo "$ANTO_GRUB_THEME_REPO" "$GRUB_THEME_BUILD_DIR"

    if [[ ! -f /etc/default/grub ]] || { [[ ! -d /boot/grub ]] && [[ ! -d /boot/grub2 ]]; }; then
        echo -e "${BLUE}[NOTE]${PINK} ==> Active GRUB installation not found, skipping GRUB theme install."
        return 0
    fi

    (
        cd "$GRUB_THEME_BUILD_DIR"
        if [[ -f ./install-anto426.sh ]]; then
            local sudo_env=(
                "ANTO426_GRUB_SCREEN=${ANTO426_GRUB_SCREEN:-1080p}"
                "ANTO426_GRUB_ICON=${ANTO426_GRUB_ICON:-color}"
                "ANTO426_GRUB_BOOT=${ANTO426_GRUB_BOOT:-0}"
            )

            if [[ -n "${ANTO426_GRUB_RESOLUTION:-}" ]]; then
                sudo_env+=("ANTO426_GRUB_RESOLUTION=$ANTO426_GRUB_RESOLUTION")
            fi

            sudo env "${sudo_env[@]}" bash ./install-anto426.sh
        else
            sudo bash ./install.sh -t anto426 -i color -s "${ANTO426_GRUB_SCREEN:-1080p}"
        fi
    )
}

setup_dynamic_theme_permissions() {
    if [[ -x "$ANTO_CONFIG_DIR/wallpaper_effects.sh" ]]; then
        sudo ANTO426_ADMIN_USER="$(id -un)" "$ANTO_CONFIG_DIR/wallpaper_effects.sh" --setup-admin || true
    fi
}

run_auto_setup() {
    local setup_script
    setup_script="$(mktemp)"

    curl -fSL "$AUTO_SETUP_URL" -o "$setup_script"
    bash "$setup_script"
    rm -f "$setup_script"
}

ensure_dotfiles_ready() {
    if [[ ! -d "$ANTO_CONFIG_DIR" ]]; then
        echo -e "${BLUE}[ERROR]${PINK} ==> Dotfiles config directory not found: $ANTO_CONFIG_DIR"
        exit 1
    fi
}

copy_assets_dir() {
    local source_dir="$1"
    local target_dir="$2"

    [[ -d "$source_dir" ]] || return 0

    mkdir -p "$target_dir"
    cp -rn "$source_dir/." "$target_dir/"
}

install_assets() {
    local assets_dir
    assets_dir="$(mktemp -d)"

    git clone --depth 1 "$WALLPAPER_REPO" "$assets_dir"

    copy_assets_dir "$assets_dir/Wallpapers" "$HOME/Pictures/Wallpapers"
    copy_assets_dir "$assets_dir/neofetch" "$HOME/Pictures/neofetch"

    rm -rf "$assets_dir"
}

init_dotfiles_sync_config() {
    if [[ -x "$ANTO_CONFIG_DIR/remote_sync.sh" ]]; then
        ANTO426_SYNC_QUIET=1 "$ANTO_CONFIG_DIR/remote_sync.sh" init || true
    fi
}


clear

# Welcome message
echo -e "${PINK}\e[1m
 WELCOME!${PINK} Now we will install and setup Hyprland on an Arch-based system
                       Created by \e[1;4manto426
${WHITE}"

# Warning message
echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4mWARNING\e[0m${PINK}:                              *
 *               This script will modify your system!                *
 *         It will install Hyprland and several dependencies.        *
 *      Make sure you know what you are doing before continuing.     *
 *********************************************************************
\n
"

# Asking if the user want to proceed
echo -e "${YELLOW} Do you still want to continue with Hyprland installation using this script? [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[OK]${PINK} ==> Continuing with installation..."
        ;;
    *)
        echo -e "${BLUE}[NOTE]${PINK} ==> You 🫵 chose ${YELLOW}NOT${PINK} to proceed.. Exiting..."
        echo
        exit 1
        ;;
esac

# Start of the install procedure
cd ~

# Full system update
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/11]${PINK} ==> Updating system packages\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -Syu --noconfirm

# Launch auto-setup script and download all the dotfiles
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> Setup terminal\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
run_auto_setup
ensure_dotfiles_ready

# Make all dotfiles scripts executable
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> Make executable\n---------------------------------------------------------------------\n${WHITE}"
find "$ANTO_CONFIG_DIR" -type f -name "*.sh" -exec chmod +x {} +

# Download wallpapers and terminal images
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> Download wallpaper\n---------------------------------------------------------------------\n${WHITE}"
install_assets
init_dotfiles_sync_config

# Install the required packages
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> Install package\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
install_hyprland_packages
install_anto426_theme
install_anto426_grub_theme
setup_dynamic_theme_permissions
"$ANTO_CONFIG_DIR/gtkthemes.sh" || true

# enable bluetooth & networkmanager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> Enable bluetooth & networkmanager\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# Set Ghostty as default terminal emulator for Nemo
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> Set Ghostty as the default terminal emulator for Nemo\n---------------------------------------------------------------------\n${WHITE}"
if command -v gsettings >/dev/null 2>&1 &&
    [[ "$(gsettings writable org.cinnamon.desktop.default-applications.terminal exec 2>/dev/null)" == "true" ]]; then
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
else
    echo -e "${BLUE}[NOTE]${PINK} ==> Nemo terminal schema not available, skipping."
fi

# Apply fonts
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> Apply fonts\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv

# Set cursor
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/11]${PINK} ==> Set cursor\n---------------------------------------------------------------------\n${WHITE}"
"$ANTO_CONFIG_DIR/setcursor.sh"

# Stow
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/11]${PINK} ==> Stow dotfiles\n---------------------------------------------------------------------\n${WHITE}"
cd "$DOTFILES_DIR"
stow -t ~ .
cd ~

# Check display manager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/11]${PINK} ==> Check display manager\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -e /etc/systemd/system/display-manager.service ]]; then
    sudo systemctl enable sddm
    echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee -a /etc/sddm.conf
    sudo sed -i 's|astronaut.conf|purple_leaves.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    echo -e "\n${PINK}SDDM has been enabled."
fi

# Wait a little just for the last message
sleep 0.7
clear

# Calculate how long the script took
end=$(date +%s)
duration=$((end - start))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

printf -v minutes "%02d" "$minutes"
printf -v seconds "%02d" "$seconds"

echo -e "\n
 *********************************************************************
 *                    Hyprland setup is complete!                    *
 *                                                                   *
 *             Duration : $hours hours, $minutes minutes, $seconds seconds            *
 *                                                                   *
 *   It is recommended to \e[1;4mREBOOT\e[0m your system to apply all changes.   *
 *                                                                   *
 *                 \e[4mHave a great time with Hyprland!!${WHITE}                 *
 *********************************************************************
 \n
"
