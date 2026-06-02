#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — Uninstall Script
# ══════════════════════════════════════════════════════════════════════════════
# Removes HyprFlux configuration files and optionally restores the most recent
# pre-install backup. Packages installed by install.sh are NOT removed
# automatically (you may want to keep pipewire, kitty, etc.).
#
# Usage:
#   ./uninstall.sh              Interactive uninstall
#   ./uninstall.sh --restore    Restore most recent backup after uninstall
#   ./uninstall.sh --yes        Skip confirmation prompts
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_PARENT="${HOME}/.config/hyprflux-backup"

# ── Colours ───────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
    BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
    BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN=''
    BOLD='' DIM='' RESET=''
fi

log()     { echo -e "${BOLD}${BLUE}  ==> ${RESET}${*}"; }
success() { echo -e "${BOLD}${GREEN}  ✔  ${RESET}${*}"; }
warn()    { echo -e "${BOLD}${YELLOW}  ⚠  ${RESET}${*}"; }
error()   { echo -e "${BOLD}${RED}  ✖  ${RESET}${*}"; }
info()    { echo -e "${DIM}      ${*}${RESET}"; }
header()  { echo -e "\n${BOLD}${MAGENTA}━━━  ${*}  ━━━${RESET}\n"; }
divider() { echo -e "${DIM}──────────────────────────────────────────────────────${RESET}"; }

# ── Argument parsing ──────────────────────────────────────────────────────────
OPT_YES=false
OPT_RESTORE=false

for arg in "$@"; do
    case "${arg}" in
        --yes|-y)      OPT_YES=true ;;
        --restore)     OPT_RESTORE=true ;;
        --help|-h)
            echo "Usage: ${0} [--yes] [--restore]"
            echo "  --yes       Skip confirmation prompts"
            echo "  --restore   Restore most recent backup after removing configs"
            exit 0
            ;;
        *)
            error "Unknown option: ${arg}"
            exit 1
            ;;
    esac
done

# ── Guard: must not be root ───────────────────────────────────────────────────
if [[ "${EUID}" -eq 0 ]]; then
    error "Do not run this script as root."
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — CONFIRMATION
# ═══════════════════════════════════════════════════════════════════════════════

confirm_uninstall() {
    header "HyprFlux Uninstaller"

    echo -e "  This will remove the following HyprFlux configuration directories:"
    echo ""
    echo -e "    ${CYAN}~/.config/hypr${RESET}"
    echo -e "    ${CYAN}~/.config/waybar${RESET}"
    echo -e "    ${CYAN}~/.config/rofi${RESET}"
    echo -e "    ${CYAN}~/.config/kitty${RESET}"
    echo -e "    ${CYAN}~/.config/dunst${RESET}"
    echo -e "    ${CYAN}~/.config/swaync${RESET}"
    echo -e "    ${CYAN}~/.config/wlogout${RESET}"
    echo -e "    ${CYAN}~/.config/fastfetch${RESET}"
    echo -e "    ${CYAN}~/.config/fish${RESET}"
    echo -e "    ${CYAN}~/.config/gtk-3.0${RESET}  ${DIM}(settings.ini only)${RESET}"
    echo -e "    ${CYAN}~/.config/gtk-4.0${RESET}  ${DIM}(settings.ini only)${RESET}"
    echo -e "    ${CYAN}~/.config/qt5ct${RESET}"
    echo -e "    ${CYAN}~/.config/hyprflux${RESET}"
    echo -e "    ${CYAN}~/.local/share/hyprflux${RESET}"
    echo -e "    ${CYAN}~/.local/bin${RESET}        ${DIM}(HyprFlux symlinks only)${RESET}"
    echo -e "    ${CYAN}~/.zshrc${RESET}            ${DIM}(HyprFlux .zshrc only)${RESET}"
    echo ""
    echo -e "  ${BOLD}Packages will NOT be removed.${RESET}"
    echo ""

    if [[ "${OPT_YES}" != "true" ]]; then
        read -r -p "  Continue with uninstall? [y/N] " confirm
        case "${confirm}" in
            y|Y) ;;
            *)
                info "Uninstall cancelled."
                exit 0
                ;;
        esac
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — REMOVE CONFIGS
# ═══════════════════════════════════════════════════════════════════════════════

remove_configs() {
    header "Removing HyprFlux Configurations"

    safe_remove() {
        local target="$1"
        if [[ -e "${target}" || -L "${target}" ]]; then
            rm -rf "${target}"
            info "Removed: ${target}"
        else
            info "Not found (skipping): ${target}"
        fi
    }

    # Full directory removals
    safe_remove "${HOME}/.config/hypr"
    safe_remove "${HOME}/.config/waybar"
    safe_remove "${HOME}/.config/rofi"
    safe_remove "${HOME}/.config/kitty"
    safe_remove "${HOME}/.config/dunst"
    safe_remove "${HOME}/.config/swaync"
    safe_remove "${HOME}/.config/wlogout"
    safe_remove "${HOME}/.config/fastfetch"
    safe_remove "${HOME}/.config/fish"
    safe_remove "${HOME}/.config/qt5ct"
    safe_remove "${HOME}/.config/qt6ct"
    safe_remove "${HOME}/.config/Kvantum"
    safe_remove "${HOME}/.config/hyprflux"
    safe_remove "${HOME}/.local/share/hyprflux"
    safe_remove "${HOME}/.zshrc"

    # GTK: only remove settings.ini (leave the rest in case user has other GTK configs)
    safe_remove "${HOME}/.config/gtk-3.0/settings.ini"
    safe_remove "${HOME}/.config/gtk-4.0/settings.ini"

    # XDG portal config we wrote
    safe_remove "${HOME}/.config/xdg-desktop-portal/hyprland-portals.conf"

    # Remove ~/.local/bin symlinks created by installer
    local hyprflux_scripts=(
        wallpaper powermenu theme-switch screenshot
        record-screen volume brightness update-system
    )
    for script in "${hyprflux_scripts[@]}"; do
        local link="${HOME}/.local/bin/${script}"
        if [[ -L "${link}" ]]; then
            rm -f "${link}"
            info "Removed symlink: ${link}"
        fi
    done

    success "Configuration files removed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — RESTORE BACKUP (optional)
# ═══════════════════════════════════════════════════════════════════════════════

restore_backup() {
    header "Backup Restoration"

    if [[ ! -d "${BACKUP_PARENT}" ]]; then
        warn "No backup directory found at: ${BACKUP_PARENT}"
        return 0
    fi

    # Find the most recent backup
    local latest_backup
    latest_backup="$(find "${BACKUP_PARENT}" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)"

    if [[ -z "${latest_backup}" ]]; then
        warn "No backups found in: ${BACKUP_PARENT}"
        return 0
    fi

    log "Most recent backup: ${latest_backup}"

    if [[ "${OPT_RESTORE}" != "true" ]]; then
        read -r -p "  Restore this backup? [y/N] " restore_ans
        case "${restore_ans}" in
            y|Y) ;;
            *)
                info "Skipping backup restoration."
                return 0
                ;;
        esac
    fi

    log "Restoring backup..."
    for item in "${latest_backup}"/*/; do
        [[ -d "${item}" ]] || continue
        local basename
        basename="$(basename "${item}")"
        local dest="${HOME}/.config/${basename}"
        cp -r "${item}" "${dest}"
        info "Restored: ${dest}"
    done

    # .zshrc backup (stored directly, not in a subdir)
    if [[ -f "${latest_backup}/.zshrc" ]]; then
        cp "${latest_backup}/.zshrc" "${HOME}/.zshrc"
        info "Restored: ~/.zshrc"
    fi

    success "Backup restored from: ${latest_backup}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — COMPLETION
# ═══════════════════════════════════════════════════════════════════════════════

print_summary() {
    echo ""
    divider
    echo -e "${BOLD}${GREEN}  HyprFlux has been uninstalled.${RESET}"
    divider
    echo ""
    echo -e "  Your backup(s) are kept at:"
    echo -e "    ${CYAN}${BACKUP_PARENT}/${RESET}"
    echo ""
    echo -e "  Packages installed by HyprFlux were ${BOLD}not${RESET} removed."
    echo -e "  To remove them, use: ${DIM}sudo pacman -Rns <package-name>${RESET}"
    echo ""
    divider
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    confirm_uninstall
    remove_configs
    restore_backup
    print_summary
}

main "$@"
