#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — powermenu.sh
# Session / power menu.  Prefers wlogout; falls back to Rofi dmenu.
#
# Usage:
#   powermenu.sh           Launch power menu (auto-detects wlogout/rofi)
#   powermenu.sh --rofi    Force Rofi fallback
#   powermenu.sh --wlogout Force wlogout
#
# Dependencies: wlogout OR rofi-wayland, systemctl, hyprctl
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
readonly WLOGOUT_LAYOUT="${HOME}/.config/wlogout/layout"
readonly WLOGOUT_STYLE="${HOME}/.config/wlogout/style.css"
readonly ROFI_CONFIG="${HOME}/.config/rofi/powermenu.rasi"

# Require confirmation before shutdown / reboot?
readonly CONFIRM_DESTRUCTIVE=true

# ── Helpers ───────────────────────────────────────────────────────────────────
notify() {
    command -v notify-send &>/dev/null \
        && notify-send --app-name="HyprFlux" --icon="system-shutdown" "$1" "${2:-}"
}

confirm() {
    local action="$1"
    if [[ "$CONFIRM_DESTRUCTIVE" != "true" ]]; then
        return 0
    fi
    local choice
    choice=$(printf 'Yes\nNo' \
        | rofi -dmenu \
               -config "$ROFI_CONFIG" \
               -p "󰤇  ${action}?" \
               -theme-str 'window { width: 280px; }
                            listview { lines: 2; columns: 1; }' \
               2>/dev/null || echo "No")
    [[ "$choice" == "Yes" ]]
}

# ── Actions ───────────────────────────────────────────────────────────────────
do_lock() {
    if command -v hyprlock &>/dev/null; then
        hyprlock
    else
        notify "Lock" "hyprlock is not installed"
    fi
}

do_logout() {
    hyprctl dispatch exit
}

do_suspend() {
    do_lock &
    sleep 1
    systemctl suspend
}

do_hibernate() {
    if confirm "Hibernate"; then
        do_lock &
        sleep 1
        systemctl hibernate
    fi
}

do_reboot() {
    if confirm "Reboot"; then
        notify "Rebooting…" "System will restart shortly"
        sleep 1
        systemctl reboot
    fi
}

do_shutdown() {
    if confirm "Shut Down"; then
        notify "Shutting Down…" "System will power off shortly"
        sleep 1
        systemctl poweroff
    fi
}

# ── wlogout mode ──────────────────────────────────────────────────────────────
launch_wlogout() {
    local args=(
        --layout  "$WLOGOUT_LAYOUT"
        --css     "$WLOGOUT_STYLE"
        --buttons-per-row 3
        --column-spacing  10
        --row-spacing     10
        --margin-top      200
        --margin-bottom   200
        --margin-left     400
        --margin-right    400
    )
    wlogout "${args[@]}"
}

# ── Rofi dmenu fallback ───────────────────────────────────────────────────────
launch_rofi() {
    # Menu entries — icon glyph followed by label
    local entries=(
        "󰌾  Lock"
        "󰗽  Logout"
        "⏾  Suspend"
        "󰒲  Hibernate"
        "󰜉  Reboot"
        "⏻  Shutdown"
    )

    local menu
    menu="$(printf '%s\n' "${entries[@]}")"

    # -urgent 5 → Shutdown (index 5) gets red
    # -active 0 → Lock (index 0) gets blue accent
    local chosen
    chosen=$(printf '%s\n' "${entries[@]}" \
        | rofi -dmenu \
               -config "$ROFI_CONFIG" \
               -p "  Session" \
               -no-custom \
               -urgent "5" \
               -active "0" \
               -theme-str 'listview { columns: 3; lines: 2; }
                            window   { width: 480px; padding: 24px; }
                            element  { padding: 18px 10px 14px; orientation: vertical; }
                            element-text { horizontal-align: 0.5; font: "JetBrainsMono Nerd Font Bold 13"; }' \
               2>/dev/null || echo "")

    [[ -z "$chosen" ]] && exit 0

    case "$chosen" in
        *Lock*)      do_lock ;;
        *Logout*)    do_logout ;;
        *Suspend*)   do_suspend ;;
        *Hibernate*) do_hibernate ;;
        *Reboot*)    do_reboot ;;
        *Shutdown*)  do_shutdown ;;
        *)           exit 0 ;;
    esac
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    local mode="auto"
    [[ "${1:-}" == "--rofi"    ]] && mode="rofi"
    [[ "${1:-}" == "--wlogout" ]] && mode="wlogout"

    case "$mode" in
        wlogout)
            if command -v wlogout &>/dev/null; then
                launch_wlogout
            else
                echo "powermenu: wlogout not installed, falling back to rofi" >&2
                launch_rofi
            fi
            ;;
        rofi)
            launch_rofi
            ;;
        auto)
            if command -v wlogout &>/dev/null \
                    && [[ -f "$WLOGOUT_LAYOUT" ]] \
                    && [[ -f "$WLOGOUT_STYLE" ]]; then
                launch_wlogout
            else
                launch_rofi
            fi
            ;;
    esac
}

main "$@"
