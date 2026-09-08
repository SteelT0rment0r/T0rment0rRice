#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

echo "======================================"
echo "       T0rment0rRice Installer"
echo "======================================"
echo

# --------------------------------------
# Check dependencies
# --------------------------------------

if ! command -v pacman >/dev/null 2>&1; then
    echo "ERROR: pacman was not found."
    echo "This installer is intended for Arch-based systems."
    exit 1
fi

# --------------------------------------
# Install official packages
# --------------------------------------

echo "[1/4] Installing official packages..."

if [[ -f "$DOTFILES_DIR/packages/pacman.txt" ]]; then
    mapfile -t PACMAN_PACKAGES < "$DOTFILES_DIR/packages/pacman.txt"

    sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"
else
    echo "WARNING: packages/pacman.txt not found."
fi

# --------------------------------------
# Install AUR packages
# --------------------------------------

echo
echo "[2/4] Installing AUR packages..."

if [[ -f "$DOTFILES_DIR/packages/aur.txt" ]]; then

    if command -v yay >/dev/null 2>&1; then
        mapfile -t AUR_PACKAGES < "$DOTFILES_DIR/packages/aur.txt"

        yay -S --needed "${AUR_PACKAGES[@]}"

    else
        echo "WARNING: yay is not installed."
        echo "AUR packages were NOT installed."
        echo
        echo "Install yay and run this installer again."
    fi

else
    echo "WARNING: packages/aur.txt not found."
fi

# --------------------------------------
# Restore configuration
# --------------------------------------

echo
echo "[3/4] Restoring configuration..."

mkdir -p "$CONFIG_DIR"
mkdir -p "$LOCAL_BIN"
mkdir -p "$WALLPAPER_DIR"

if [[ -d "$DOTFILES_DIR/.config" ]]; then
    cp -a "$DOTFILES_DIR/.config/." "$CONFIG_DIR/"
fi

if [[ -d "$DOTFILES_DIR/.local/bin" ]]; then
    cp -a "$DOTFILES_DIR/.local/bin/." "$LOCAL_BIN/"
fi

# --------------------------------------
# Restore wallpapers
# --------------------------------------

echo
echo "[4/4] Restoring wallpapers..."

if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
    cp -a "$DOTFILES_DIR/wallpapers/." "$WALLPAPER_DIR/"
fi

# --------------------------------------
# Permissions
# --------------------------------------

chmod +x "$LOCAL_BIN/matugen-rmpc" 2>/dev/null || true

echo
echo "======================================"
echo "       Installation complete!"
echo "======================================"
echo
echo "Your rice has been restored."
echo
echo "You may need to log out and back in"
echo "for some desktop/session components."
echo
