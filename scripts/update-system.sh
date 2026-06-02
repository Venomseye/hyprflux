#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — update-system.sh
# Full system update: pacman, AUR (yay/paru), orphan cleanup, cache prune.
#
# Usage:
#   update-system.sh            Full interactive update
#   update-system.sh --check    Check for updates without installing
#   update-system.sh --quiet    Update with minimal output (for scripting)
#
# Dependencies: pacman, yay or paru (AUR), libnotify
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

readonly LOG_DIR="${HOME}/.local/share/hyprflux/logs"
readonly LOG_FILE="${LOG_DIR}/update-$(date +%Y%m%d_%H%M%S).log"
readonly LOCK_FILE="/tmp/hyprflux-update.lock"

# ── Colour output ─────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
    BLUE='\033[0;34m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' DIM='' RESET=''
fi

log()     { echo -e "${BOLD}${BLUE}  ==>  ${RESET}${*}" | tee -a "$LOG_FILE"; }
success() { echo -e "${BOLD}${GREEN}  ✔    ${RESET}${*}" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${BOLD}${YELLOW}  ⚠    ${RESET}${*}" | tee -a "$LOG_FILE"; }
error()   { echo -e "${BOLD}${RED}  ✖    ${RESET}${*}" | tee -a "$LOG_FILE"; }
info()    { echo -e "${DIM}        ${*}${RESET}" | tee -a "$LOG_FILE"; }
header()  { echo -e "\n${BOLD}${BLUE}━━━  ${*}  ━━━${RESET}\n" | tee -a "$LOG_FILE"; }

# ── Notifications ─────────────────────────────────────────────────────────────
notify() {
    command -v notify-send &>/dev/null \
        && notify-send --app-name="HyprFlux" --icon="system-software-update" "$1" "${2:-}"
}

# ── Helpers ───────────────────────────────────────────────────────────────────
die() {
    error "$*"
    notify "Update Failed" "$*"
    rm -f "$LOCK_FILE"
    exit 1
}

check_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_pid
        lock_pid="$(cat "$LOCK_FILE" 2>/dev/null || echo "")"
        if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
            die "Another update is already running (PID ${lock_pid})"
        fi
        # Stale lock — remove it
        rm -f "$LOCK_FILE"
    fi
    printf '%s\n' "$$" > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# Detect available AUR helper
get_aur_helper() {
    if command -v yay  &>/dev/null; then echo "yay";  return; fi
    if command -v paru &>/dev/null; then echo "paru"; return; fi
    echo ""
}

# ── Check-only mode ───────────────────────────────────────────────────────────
check_updates() {
    header "Checking for Updates"

    log "Refreshing package databases…"
    sudo pacman -Sy &>>"$LOG_FILE"

    local official_count aur_count=0
    official_count="$(pacman -Qu 2>/dev/null | wc -l || echo 0)"

    local aur_helper
    aur_helper="$(get_aur_helper)"
    if [[ -n "$aur_helper" ]]; then
        aur_count="$("$aur_helper" -Qua 2>/dev/null | wc -l || echo 0)"
    fi

    local total=$(( official_count + aur_count ))

    if (( total == 0 )); then
        success "System is up to date."
        notify "System Up to Date" "No updates available."
    else
        warn "${official_count} official package update(s) available"
        warn "${aur_count} AUR package update(s) available"
        notify "Updates Available" \
            "${official_count} official · ${aur_count} AUR"
    fi
}

# ── Full update ───────────────────────────────────────════════════════════════
run_update() {
    local quiet="${1:-false}"

    check_lock
    trap 'release_lock' EXIT INT TERM

    mkdir -p "$LOG_DIR"

    {
        echo "══════════════════════════════════════════"
        echo "  HyprFlux System Update"
        echo "  Started: $(date)"
        echo "══════════════════════════════════════════"
    } >> "$LOG_FILE"

    notify "System Update" "Starting full system update…"

    # ── 1. Official packages via pacman ───────────────────────────────────────
    header "Updating Official Packages (pacman)"
    log "Running: sudo pacman -Syu"

    if [[ "$quiet" == "true" ]]; then
        sudo pacman -Syu --noconfirm &>>"$LOG_FILE" \
            && success "Official packages updated" \
            || { warn "pacman reported errors — check ${LOG_FILE}"; }
    else
        sudo pacman -Syu 2>>"$LOG_FILE" \
            && success "Official packages updated" \
            || { warn "pacman reported errors — check ${LOG_FILE}"; }
    fi

    # ── 2. AUR packages ───────────────────────────────────────────────────────
    local aur_helper
    aur_helper="$(get_aur_helper)"

    if [[ -n "$aur_helper" ]]; then
        header "Updating AUR Packages (${aur_helper})"
        log "Running: ${aur_helper} -Syu (AUR only)"

        if [[ "$quiet" == "true" ]]; then
            "$aur_helper" -Syu --aur --noconfirm &>>"$LOG_FILE" \
                && success "AUR packages updated" \
                || warn "AUR update reported errors — check ${LOG_FILE}"
        else
            "$aur_helper" -Syu --aur &>>"$LOG_FILE" \
                && success "AUR packages updated" \
                || warn "AUR update reported errors — check ${LOG_FILE}"
        fi
    else
        info "No AUR helper found (yay/paru). Skipping AUR update."
    fi

    # ── 3. Remove orphaned packages ───────────────────────────────────────────
    header "Removing Orphans"
    local orphans
    orphans="$(pacman -Qtdq 2>/dev/null || true)"

    if [[ -n "$orphans" ]]; then
        local count
        count="$(echo "$orphans" | wc -l)"
        log "Found ${count} orphaned package(s):"
        echo "$orphans" | while IFS= read -r pkg; do
            info "  - ${pkg}"
        done

        if [[ "$quiet" == "true" ]]; then
            echo "$orphans" | xargs -r sudo pacman -Rns --noconfirm &>>"$LOG_FILE" \
                && success "Orphans removed" \
                || warn "Failed to remove some orphans"
        else
            read -r -p "  Remove ${count} orphaned package(s)? [y/N] " ans
            if [[ "${ans,,}" == "y" ]]; then
                echo "$orphans" | xargs -r sudo pacman -Rns &>>"$LOG_FILE" \
                    && success "Orphans removed" \
                    || warn "Failed to remove some orphans"
            else
                info "Skipping orphan removal."
            fi
        fi
    else
        success "No orphaned packages found."
    fi

    # ── 4. Clean package cache ────────────────────────────────────────────────
    header "Cleaning Package Cache"
    log "Keeping last 2 versions of each package in cache…"

    if command -v paccache &>/dev/null; then
        sudo paccache -rk2 &>>"$LOG_FILE" \
            && success "Package cache pruned (kept last 2 versions)" \
            || warn "paccache failed (non-fatal)"
    else
        sudo pacman -Sc --noconfirm &>>"$LOG_FILE" \
            && success "Package cache cleaned" \
            || warn "Cache cleanup failed (non-fatal)"
    fi

    # ── 5. Update fish completions ────────────────────────────────────────────
    if command -v fish &>/dev/null; then
        header "Updating Fish Completions"
        fish -c "fish_update_completions" &>>"$LOG_FILE" \
            && success "Fish completions updated" \
            || info "Fish completion update skipped"
    fi

    # ── 6. Summary ────────────────────────────────────────────────────────────
    echo ""
    echo -e "${BOLD}${GREEN}━━━  Update Complete  ━━━${RESET}"
    echo -e "  Log saved to: ${DIM}${LOG_FILE}${RESET}"
    echo ""

    notify "Update Complete" "System is up to date. Log: ${LOG_FILE}"
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    # Must not run as root
    if [[ "${EUID}" -eq 0 ]]; then
        die "Do not run as root. Run as a regular user with sudo privileges."
    fi

    local mode="${1:-update}"

    case "$mode" in
        --check)    check_updates ;;
        --quiet)    run_update "true" ;;
        update|"")  run_update "false" ;;
        *)
            echo "Usage: update-system.sh [--check|--quiet]" >&2
            exit 1
            ;;
    esac
}

main "$@"
