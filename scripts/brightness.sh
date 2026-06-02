#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — brightness.sh
# Backlight brightness control with OSD notifications.
#
# Usage:
#   brightness.sh up         Raise brightness by STEP%
#   brightness.sh down       Lower brightness by STEP%
#   brightness.sh set <0-100> Set brightness to an exact percentage
#   brightness.sh get        Print current brightness as JSON
#
# Dependencies: brightnessctl, libnotify, dunst
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
readonly STEP=5          # Percentage change per up/down press
readonly MIN_BRIGHTNESS=2   # Never go fully dark (keeps screen usable)
readonly NOTIFY_ID=9902  # Fixed dunst replace ID

# ── Helpers ───────────────────────────────────────────────────────────────────
die() {
    echo "brightness: error: $*" >&2
    exit 1
}

command -v brightnessctl &>/dev/null || die "brightnessctl is not installed"

# Get current brightness as a percentage (0–100)
get_brightness() {
    local current max pct
    current="$(brightnessctl get 2>/dev/null)"
    max="$(brightnessctl max 2>/dev/null)"
    if [[ -z "$current" || -z "$max" || "$max" -eq 0 ]]; then
        echo "0"
        return
    fi
    pct=$(( current * 100 / max ))
    echo "$pct"
}

# Brightness percentage → Nerd Font icon
brightness_glyph() {
    local pct="$1"
    if (( pct == 0 )); then
        echo "󰃞"
    elif (( pct < 34 )); then
        echo "󰃟"
    elif (( pct < 67 )); then
        echo "󰃠"
    else
        echo "󰃠"
    fi
}

# Brightness percentage → XDG icon name
brightness_icon() {
    local pct="$1"
    if (( pct < 34 )); then
        echo "display-brightness-low-symbolic"
    elif (( pct < 67 )); then
        echo "display-brightness-medium-symbolic"
    else
        echo "display-brightness-high-symbolic"
    fi
}

# OSD notification with progress bar hint
send_notification() {
    local pct="$1"
    local glyph
    glyph="$(brightness_glyph "$pct")"
    local icon
    icon="$(brightness_icon "$pct")"

    if command -v dunstify &>/dev/null; then
        dunstify \
            --appname="HyprFlux" \
            --icon="$icon" \
            --hints="int:value:${pct}" \
            --hints="string:x-dunst-stack-tag:brightness" \
            --replace="$NOTIFY_ID" \
            --timeout=1800 \
            "${glyph}  Brightness" \
            "${pct}%"
    elif command -v notify-send &>/dev/null; then
        notify-send \
            --app-name="HyprFlux" \
            --icon="$icon" \
            --hint="int:value:${pct}" \
            --hint="string:x-dunst-stack-tag:brightness" \
            --expire-time=1800 \
            "${glyph}  Brightness" \
            "${pct}%"
    fi
}

# ── Actions ───────────────────────────────────────────────────────────────────
brightness_up() {
    brightnessctl set "+${STEP}%" --quiet
    send_notification "$(get_brightness)"
}

brightness_down() {
    local current
    current="$(get_brightness)"
    local target=$(( current - STEP ))

    if (( target < MIN_BRIGHTNESS )); then
        target=$MIN_BRIGHTNESS
    fi

    brightnessctl set "${target}%" --quiet
    send_notification "$(get_brightness)"
}

brightness_set() {
    local level="$1"
    [[ "$level" =~ ^[0-9]+$ ]] || die "Expected a number 0–100, got: ${level}"
    (( level > 100 )) && level=100
    (( level < MIN_BRIGHTNESS )) && level=$MIN_BRIGHTNESS
    brightnessctl set "${level}%" --quiet
    send_notification "$(get_brightness)"
}

brightness_get() {
    local pct
    pct="$(get_brightness)"
    printf '{"brightness":%s}\n' "$pct"
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    local action="${1:-get}"

    case "$action" in
        up)    brightness_up ;;
        down)  brightness_down ;;
        set)
            [[ -z "${2:-}" ]] && die "Usage: brightness.sh set <0-100>"
            brightness_set "$2"
            ;;
        get)   brightness_get ;;
        *)
            echo "Usage: brightness.sh [up|down|set <level>|get]" >&2
            exit 1
            ;;
    esac
}

main "$@"
