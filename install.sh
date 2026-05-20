#!/usr/bin/env bash
set -euo pipefail

start=$(date +%s)

RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
PINK="\e[35m"
WHITE="$RESET"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"

ui_line() {
    printf '%b\n' "${PINK}---------------------------------------------------------------------${RESET}"
}

ui_banner() {
    clear
    printf '%b\n' "${PINK}${BOLD}"
    printf '  ANTO426 ARCH HYPRLAND SETUP\n'
    printf '%b\n' "${RESET}${DIM}  Complete Wayland desktop install for Arch-based systems.${RESET}"
    ui_line
}

ui_step() {
    local current="$1"
    local total="$2"
    local title="$3"

    printf '\n'
    ui_line
    printf '%b[%02d/%02d]%b %b%s%b\n' "$YELLOW" "$current" "$total" "$RESET" "$BOLD" "$title" "$RESET"
    ui_line
}

ui_ok() {
    printf '%b[OK]%b %s\n' "$GREEN" "$RESET" "$*"
}

ui_note() {
    printf '%b[NOTE]%b %s\n' "$BLUE" "$RESET" "$*"
}

ui_warn() {
    printf '%b[WARN]%b %s\n' "$YELLOW" "$RESET" "$*"
}

ui_error() {
    printf '%b[ERROR]%b %s\n' "$YELLOW" "$RESET" "$*"
}

ui_confirm() {
    printf '%b\n' "${YELLOW}This script will modify your system, install packages, enable services, and stow dotfiles.${RESET}"
    printf '%b' "${YELLOW}Continue with the Hyprland installation? [y/N]: ${RESET}"
}

ui_done() {
    local duration="$1"
    local hours="$2"
    local minutes="$3"
    local seconds="$4"

    clear
    printf '%b\n' "${PINK}${BOLD}"
    printf '  HYPRLAND SETUP COMPLETE\n'
    printf '%b\n' "$RESET"
    ui_line
    printf '  Duration: %s hours, %s minutes, %s seconds\n' "$hours" "$minutes" "$seconds"
    printf '  Total seconds: %s\n' "$duration"
    printf '  Recommended next step: reboot to apply all services and themes.\n'
    ui_line
    printf '\n'
}

AUTO_SETUP_URL="${AUTO_SETUP_URL:-https://raw.githubusercontent.com/Anto426/auto-setup-LT/main/arch.sh}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/Anto426/dotfiles.git}"
WALLPAPER_REPO="${WALLPAPER_REPO:-https://github.com/Anto426/Wallpaper-Collection.git}"
ANTO_THEME_REPO="${ANTO_THEME_REPO:-https://github.com/Anto426/Anto426-theme.git}"
ANTO_GRUB_THEME_REPO="${ANTO_GRUB_THEME_REPO:-https://github.com/Anto426/grub2-themes.git}"
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
    ghostty nemo gvfs curl jq python python-gobject gtk3 loupe celluloid gnome-text-editor evince
    ffmpeg cava cliphist gnome-characters keepass playerctl wev

    # Qt, display manager, and theming
    sddm qt5ct qt6ct qt5-wayland qt6-wayland nwg-look kvantum kvantum-qt5
    sassc gnome-themes-extra

    # Input method
    fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-bamboo

    # Fonts and image libraries
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    libvips libheif openslide poppler-glib imagemagick grub
)

aur_packages=(
    # Desktop shell extras
    wlogout sddm-sugar-candy-git apple_cursor whitesur-icon-theme tint
    gtk-engine-murrine

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
        local current_remote
        current_remote="$(git -C "$target" remote get-url origin 2>/dev/null || true)"

        if [[ "$current_remote" == "$repo" ]]; then
            git -C "$target" pull --ff-only || true
        else
            local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
            mv "$target" "$backup"
            ui_note "Existing $target remote differs, moved to $backup"
            git clone --depth 1 "$repo" "$target"
        fi
    elif [[ -e "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$target" "$backup"
        ui_note "Existing $target moved to $backup"
        git clone --depth 1 "$repo" "$target"
    else
        git clone --depth 1 "$repo" "$target"
    fi
}

pick_largest_resolution() {
    awk '
        function consider(value, parts, width, height, area) {
            sub(/@.*/, "", value)

            if (value !~ /^[0-9]+x[0-9]+$/) {
                return
            }

            split(value, parts, "x")
            width = parts[1] + 0
            height = parts[2] + 0
            area = width * height

            if (area > best_area) {
                best_area = area
                best = width "x" height
            }
        }

        {
            for (i = 1; i <= NF; i++) {
                consider($i)
            }
        }

        END {
            if (best != "") {
                print best
            } else {
                exit 1
            }
        }
    '
}

detect_display_resolution() {
    local resolution
    local mode_file
    local status_file

    if command -v hyprctl >/dev/null 2>&1; then
        resolution="$(
            hyprctl monitors 2>/dev/null |
                awk '/^[[:space:]]*[0-9]+x[0-9]+@/ { split($1, mode, "@"); print mode[1] }' |
                pick_largest_resolution 2>/dev/null || true
        )"

        if [[ "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
            printf '%s\n' "$resolution"
            return 0
        fi
    fi

    if command -v xrandr >/dev/null 2>&1; then
        resolution="$(
            xrandr --query 2>/dev/null |
                awk '
                    / connected/ { connected = 1; next }
                    /^[^[:space:]]/ { connected = 0 }
                    connected && /\*/ { print $1 }
                ' |
                pick_largest_resolution 2>/dev/null || true
        )"

        if [[ "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
            printf '%s\n' "$resolution"
            return 0
        fi
    fi

    resolution="$(
        for mode_file in /sys/class/drm/card*-*/modes; do
            [[ -r "$mode_file" ]] || continue

            status_file="${mode_file%/modes}/status"
            if [[ -r "$status_file" && "$(<"$status_file")" != "connected" ]]; then
                continue
            fi

            cat "$mode_file"
        done |
            pick_largest_resolution 2>/dev/null || true
    )"

    if [[ "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        printf '%s\n' "$resolution"
        return 0
    fi

    return 1
}

install_dotfiles_repo() {
    clone_or_update_repo "$DOTFILES_REPO" "$DOTFILES_DIR"
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
        ui_note "Active GRUB installation not found, skipping GRUB theme install."
        return 0
    fi

    (
        cd "$GRUB_THEME_BUILD_DIR"
        local grub_args=(-t anto426 -i color)
        local grub_resolution="${ANTO426_GRUB_RESOLUTION:-}"
        local grub_screen="${ANTO426_GRUB_SCREEN:-}"

        if [[ -n "$grub_resolution" ]]; then
            grub_args+=(-c "$grub_resolution")
            ui_note "Using GRUB resolution override: $grub_resolution"
        elif [[ -n "$grub_screen" ]]; then
            grub_args+=(-s "$grub_screen")
            ui_note "Using GRUB screen override: $grub_screen"
        elif grub_resolution="$(detect_display_resolution)"; then
            grub_args+=(-c "$grub_resolution")
            ui_note "Detected GRUB display resolution: $grub_resolution"
        else
            grub_screen="1080p"
            grub_args+=(-s "$grub_screen")
            ui_warn "Could not detect display resolution, falling back to GRUB 1080p theme."
        fi

        if [[ "${ANTO426_GRUB_BOOT:-0}" == "1" ]]; then
            grub_args+=(-b)
        fi

        if [[ -f ./install-anto426.sh ]]; then
            local sudo_env=(
                "ANTO426_GRUB_BOOT=${ANTO426_GRUB_BOOT:-0}"
            )

            if [[ -n "$grub_resolution" ]]; then
                sudo_env+=("ANTO426_GRUB_RESOLUTION=$grub_resolution")
            else
                sudo_env+=("ANTO426_GRUB_SCREEN=$grub_screen")
            fi

            sudo env "${sudo_env[@]}" bash ./install-anto426.sh
        else
            sudo bash ./install.sh "${grub_args[@]}"
        fi
    )
}

setup_dynamic_theme_permissions() {
    if [[ -x "$ANTO_CONFIG_DIR/wallpaper_effects.sh" ]]; then
        sudo ANTO426_ADMIN_USER="$(id -un)" "$ANTO_CONFIG_DIR/wallpaper_effects.sh" --setup-admin || true
    fi
}

configure_hyprland_session() {
    local session_dir="/usr/share/wayland-sessions"
    local session_file="$session_dir/hyprland.desktop"

    if [[ ! -x /usr/bin/start-hyprland ]]; then
        ui_note "start-hyprland not found, skipping Hyprland session rewrite."
        return 0
    fi

    sudo install -d -m 755 "$session_dir"
    sudo tee "$session_file" >/dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/bin/start-hyprland
TryExec=/usr/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
Keywords=tiling;wayland;compositor;
EOF

    ui_ok "Hyprland session now starts through start-hyprland."
}

configure_sddm() {
    local theme_name="${ANTO426_SDDM_THEME:-sugar-candy}"
    local theme_dir="/usr/share/sddm/themes/$theme_name"
    local config_file="/etc/sddm.conf.d/10-anto426-theme.conf"
    local active_display_manager

    if [[ ! -d "$theme_dir" ]]; then
        ui_note "SDDM theme '$theme_name' not found. Check that sddm-sugar-candy-git installed correctly."
    else
        sudo install -d -m 755 /etc/sddm.conf.d
        sudo tee "$config_file" >/dev/null <<EOF
[Theme]
Current=$theme_name
CursorTheme=macOS
Font=Segoe UI Variable Static Text
EOF
        ui_ok "SDDM theme set to '$theme_name'."
    fi

    active_display_manager="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"

    if [[ -z "$active_display_manager" ]]; then
        sudo systemctl enable sddm.service
        ui_ok "SDDM has been enabled."
    elif [[ "$active_display_manager" == */sddm.service ]]; then
        sudo systemctl enable sddm.service >/dev/null 2>&1 || true
        ui_ok "SDDM is already the active display manager."
    else
        ui_note "Another display manager is active: $active_display_manager"
        ui_note "Leaving it enabled. Run 'sudo systemctl disable --now display-manager && sudo systemctl enable sddm' to switch manually."
    fi
}

run_auto_setup() {
    local setup_script
    setup_script="$(mktemp)"

    curl -fSL "$AUTO_SETUP_URL" -o "$setup_script"
    DOTFILES_REPO="$DOTFILES_REPO" bash "$setup_script"
    rm -f "$setup_script"
}

ensure_dotfiles_ready() {
    if [[ ! -d "$ANTO_CONFIG_DIR" ]]; then
        ui_error "Dotfiles config directory not found: $ANTO_CONFIG_DIR"
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


ui_banner
ui_confirm
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        printf '\n'
        ui_ok "Continuing with installation."
        ;;
    *)
        ui_note "Installation cancelled by user."
        exit 1
        ;;
esac

# Start of the install procedure
cd ~

# Full system update
ui_step 1 11 "Updating system packages"
sudo pacman -Syu --noconfirm

# Launch auto-setup script and download all the dotfiles
ui_step 2 11 "Setting up terminal and dotfiles"
sleep 0.5
run_auto_setup
install_dotfiles_repo
ensure_dotfiles_ready

# Make all dotfiles scripts executable
ui_step 3 11 "Making dotfiles scripts executable"
find "$ANTO_CONFIG_DIR" -type f -name "*.sh" -exec chmod +x {} +

# Download wallpapers and terminal images
ui_step 4 11 "Downloading wallpapers and terminal assets"
install_assets
init_dotfiles_sync_config

# Install the required packages
ui_step 5 11 "Installing packages and themes"
sleep 0.5
install_hyprland_packages
install_anto426_theme
install_anto426_grub_theme
setup_dynamic_theme_permissions
"$ANTO_CONFIG_DIR/gtkthemes.sh" || true

# enable bluetooth & networkmanager
ui_step 6 11 "Enabling Bluetooth and NetworkManager"
sleep 0.5
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# Set Ghostty as default terminal emulator for Nemo
ui_step 7 11 "Setting Ghostty as Nemo terminal"
if command -v gsettings >/dev/null 2>&1 &&
    [[ "$(gsettings writable org.cinnamon.desktop.default-applications.terminal exec 2>/dev/null)" == "true" ]]; then
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
else
    ui_note "Nemo terminal schema not available, skipping."
fi

# Apply fonts
ui_step 8 11 "Refreshing font cache"
fc-cache -fv

# Set cursor
ui_step 9 11 "Applying cursor theme"
"$ANTO_CONFIG_DIR/setcursor.sh"

# Stow
ui_step 10 11 "Stowing dotfiles"
cd "$DOTFILES_DIR"
stow -t ~ .
cd ~

# Setup display manager
ui_step 11 11 "Configuring SDDM display manager"
configure_hyprland_session
configure_sddm

# Wait a little just for the last message
sleep 0.7
end=$(date +%s)
duration=$((end - start))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

printf -v minutes "%02d" "$minutes"
printf -v seconds "%02d" "$seconds"

ui_done "$duration" "$hours" "$minutes" "$seconds"
