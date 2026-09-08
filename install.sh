#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# T0rment0rRice Installer
# ============================================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="${XDG_CONFIG_HOME:-"$HOME/.config"}"
LOCAL_BIN="${XDG_BIN_HOME:-"$HOME/.local/bin"}"
WALLPAPER_DIR="${XDG_PICTURES_DIR:-"$HOME/Pictures"}/Wallpapers"

PACMAN_FILE="$SCRIPT_DIR/packages/pacman.txt"
AUR_FILE="$SCRIPT_DIR/packages/aur.txt"

BACKUP_ENABLED=true
BACKUP_DIR=""

# ============================================================
# Colors
# ============================================================

if [[ -t 1 ]]; then
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
    RED='\033[31m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    BLUE='\033[34m'
else
    BOLD=''
    DIM=''
    RESET=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
fi

# ============================================================
# Output helpers
# ============================================================

info() {
    printf '%b\n' "${BLUE}==>${RESET} $*"
}

success() {
    printf '%b\n' "${GREEN}✓${RESET} $*"
}

warning() {
    printf '%b\n' "${YELLOW}WARNING:${RESET} $*"
}

error() {
    printf '%b\n' "${RED}ERROR:${RESET} $*" >&2
}

die() {
    error "$*"
    exit 1
}

# ============================================================
# Error handling
# ============================================================

on_error() {
    local exit_code=$?
    local line_no=$1

    error "Installation failed on line ${line_no} (exit code ${exit_code})."

    if [[ -n "${BACKUP_DIR:-}" && -d "$BACKUP_DIR" ]]; then
        warning "Your existing configuration backup is located at:"
        printf '    %s\n' "$BACKUP_DIR"
    fi

    exit "$exit_code"
}

trap 'on_error $LINENO' ERR

# ============================================================
# Cleanup
# ============================================================

TEMP_DIRS=()

cleanup() {
    local dir

    for dir in "${TEMP_DIRS[@]:-}"; do
        if [[ -d "$dir" ]]; then
            rm -rf -- "$dir"
        fi
    done
}

trap cleanup EXIT

# ============================================================
# Package list helper
# ============================================================

load_packages() {
    local pkg_file="$1"

    [[ -f "$pkg_file" ]] || return 0

    # Remove comments, blank lines, and Windows CRLF endings.
    sed \
        -e 's/\r$//' \
        -e '/^[[:space:]]*#/d' \
        -e '/^[[:space:]]*$/d' \
        "$pkg_file"
}

# ============================================================
# Command checks
# ============================================================

require_command() {
    command -v "$1" >/dev/null 2>&1 || die \
        "Required command '$1' was not found."
}

# ============================================================
# Argument parsing
# ============================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-backup)
            BACKUP_ENABLED=false
            shift
            ;;

        -h|--help)
            cat <<EOF
T0rment0rRice Installer

Usage:
    ./install.sh
    ./install.sh --no-backup

Options:
    --no-backup    Do not back up existing configuration
    -h, --help     Show this help message
EOF
            exit 0
            ;;

        *)
            die "Unknown option: $1"
            ;;
    esac
done

# ============================================================
# Header
# ============================================================

printf '\n'
printf '%b\n' "${BOLD}======================================${RESET}"
printf '%b\n' "${BOLD}        T0rment0rRice Installer${RESET}"
printf '%b\n' "${BOLD}======================================${RESET}"
printf '\n'

# ============================================================
# Basic safety checks
# ============================================================

if [[ $EUID -eq 0 ]]; then
    die "Do not run this installer as root.

Run:
    ./install.sh

The script will use sudo when required."
fi

[[ -d "$SCRIPT_DIR" ]] || die \
    "Could not determine repository directory."

require_command pacman
require_command sudo

# ============================================================
# Detect distribution
# ============================================================

if [[ ! -f /etc/os-release ]]; then
    die "Could not determine the operating system."
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "arch" &&
      " ${ID_LIKE:-} " != *" arch "* ]]; then

    warning "This does not appear to be an Arch-based distribution."
    warning "T0rment0rRice is designed for Arch and Arch-based systems."

    printf '\n'
    read -rp "Continue anyway? [y/N] " answer

    case "$answer" in
        y|Y|yes|YES)
            ;;
        *)
            info "Installation cancelled."
            exit 0
            ;;
    esac
fi

success "Detected: ${PRETTY_NAME:-Arch-based system}"

# ============================================================
# Repository validation
# ============================================================

if [[ ! -f "$PACMAN_FILE" ]]; then
    warning "packages/pacman.txt was not found."
fi

if [[ ! -f "$AUR_FILE" ]]; then
    warning "packages/aur.txt was not found."
fi

if [[ ! -d "$SCRIPT_DIR/.config" &&
      ! -d "$SCRIPT_DIR/.local/bin" &&
      ! -d "$SCRIPT_DIR/wallpapers" ]]; then

    warning "No configuration, scripts, or wallpapers were found."
    warning "Make sure you are running this from the root of the rice repository."
fi

# ============================================================
# Load package lists
# ============================================================

PACMAN_PACKAGES=()
AUR_PACKAGES=()

if [[ -f "$PACMAN_FILE" ]]; then
    mapfile -t PACMAN_PACKAGES < <(
        load_packages "$PACMAN_FILE"
    )
fi

if [[ -f "$AUR_FILE" ]]; then
    mapfile -t AUR_PACKAGES < <(
        load_packages "$AUR_FILE"
    )
fi

# ============================================================
# Installation summary
# ============================================================

printf '\n'
info "Installation summary:"
printf '    Official packages : %d\n' "${#PACMAN_PACKAGES[@]}"
printf '    AUR packages      : %d\n' "${#AUR_PACKAGES[@]}"
printf '    Configuration     : %s\n' "$CONFIG_DIR"
printf '    Local binaries    : %s\n' "$LOCAL_BIN"
printf '    Wallpapers        : %s\n' "$WALLPAPER_DIR"
printf '    Backup enabled    : %s\n' "$BACKUP_ENABLED"

printf '\n'
read -rp "Continue with installation? [Y/n] " answer

case "$answer" in
    n|N|no|NO)
        info "Installation cancelled."
        exit 0
        ;;
esac

# ============================================================
# 1. Backup existing configuration
# ============================================================

printf '\n'
info "[1/5] Backing up existing configuration..."

if [[ "$BACKUP_ENABLED" == true ]]; then

    BACKUP_DIR="$HOME/.t0rment0rrice-backup-$(date +%Y%m%d-%H%M%S)"

    mkdir -p "$BACKUP_DIR"

    BACKUP_CREATED=false

    if [[ -d "$CONFIG_DIR" ]]; then
        cp -a "$CONFIG_DIR" "$BACKUP_DIR/config"
        BACKUP_CREATED=true
    fi

    if [[ -d "$LOCAL_BIN" ]]; then
        cp -a "$LOCAL_BIN" "$BACKUP_DIR/bin"
        BACKUP_CREATED=true
    fi

    if [[ -d "$WALLPAPER_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$WALLPAPER_DIR" "$BACKUP_DIR/wallpapers"
        BACKUP_CREATED=true
    fi

    if [[ "$BACKUP_CREATED" == true ]]; then
        success "Backup created at:"
        printf '    %s\n' "$BACKUP_DIR"
    else
        rm -rf -- "$BACKUP_DIR"
        BACKUP_DIR=""
        info "No existing files needed to be backed up."
    fi

else
    warning "Backup disabled."
fi

# ============================================================
# 2. Official packages
# ============================================================

printf '\n'
info "[2/5] Installing official packages..."

if [[ ${#PACMAN_PACKAGES[@]} -eq 0 ]]; then

    warning "No official packages found."

else

    sudo pacman -Syu --needed "${PACMAN_PACKAGES[@]}"
    success "Official packages installed."

fi

# ============================================================
# 3. AUR packages
# ============================================================

printf '\n'
info "[3/5] Installing AUR packages..."

if [[ ${#AUR_PACKAGES[@]} -eq 0 ]]; then

    warning "No AUR packages found."

else

    if ! command -v yay >/dev/null 2>&1; then

        warning "yay is required to install AUR packages."

        printf '\n'
        read -rp "Install yay automatically? [Y/n] " answer

        case "$answer" in
            n|N|no|NO)
                die "Cannot install AUR packages without an AUR helper."
                ;;
        esac

        info "Installing dependencies for yay..."

        sudo pacman -S --needed base-devel git

        YAY_TEMP="$(mktemp -d)"
        TEMP_DIRS+=("$YAY_TEMP")

        info "Cloning yay..."

        git clone \
            https://aur.archlinux.org/yay.git \
            "$YAY_TEMP/yay"

        info "Building yay..."

        (
            cd "$YAY_TEMP/yay"
            makepkg -si
        )

        require_command yay
        success "yay installed."
    fi

    info "Installing AUR packages..."

    yay -S --needed "${AUR_PACKAGES[@]}"

    success "AUR packages installed."

fi

# ============================================================
# 4. Restore configuration and scripts
# ============================================================

printf '\n'
info "[4/5] Restoring configuration..."

mkdir -p \
    "$CONFIG_DIR" \
    "$LOCAL_BIN"

if [[ -d "$SCRIPT_DIR/.config" ]]; then

    cp -a \
        "$SCRIPT_DIR/.config/." \
        "$CONFIG_DIR/"

    success "Configuration restored."

else

    warning "No .config directory found."

fi

if [[ -d "$SCRIPT_DIR/.local/bin" ]]; then

    cp -a \
        "$SCRIPT_DIR/.local/bin/." \
        "$LOCAL_BIN/"

    find "$LOCAL_BIN" \
        -type f \
        -exec chmod +x {} +

    success "Local scripts restored."

else

    warning "No .local/bin directory found."

fi

# ============================================================
# 5. Restore wallpapers
# ============================================================

printf '\n'
info "[5/5] Restoring wallpapers..."

if [[ -d "$SCRIPT_DIR/wallpapers" ]]; then

    mkdir -p "$WALLPAPER_DIR"

    cp -a \
        "$SCRIPT_DIR/wallpapers/." \
        "$WALLPAPER_DIR/"

    success "Wallpapers restored."

else

    warning "No wallpapers directory found."

fi

# ============================================================
# Final information
# ============================================================

printf '\n'
printf '%b\n' "${BOLD}======================================${RESET}"
printf '%b\n' "${BOLD}        Installation complete!${RESET}"
printf '%b\n' "${BOLD}======================================${RESET}"
printf '\n'

success "T0rment0rRice has been installed successfully."

if [[ -n "${BACKUP_DIR:-}" ]]; then
    printf '\n'
    info "Backup:"
    printf '    %s\n' "$BACKUP_DIR"
fi

printf '\n'
info "You may need to:"
printf '    • Log out and back in for session changes.\n'
printf '    • Restart your window manager/compositor.\n'
printf '    • Restart applications using your updated configuration.\n'

printf '\n'
success "Enjoy your rice!"
printf '\n'
