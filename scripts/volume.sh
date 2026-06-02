#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — volume.sh
# PipeWire / PulseAudio volume control with OSD notifications.
#
# Usage:
#   volume.sh up            Raise output volume by STEP%
#   volume.sh down          Lower output volume by STEP%
#   volume.sh mute          Toggle output mute
#   volume.sh micmute       Toggle microphone mute
#   volume.sh set <0-150>   Set output volume to an exact level
#   volume.sh get           Print current volume and mute state as JSON
#
# Dependencies: pactl (pipewire-pulse), libnotify, dunst
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
readonly STEP=5          # Percentage change per up/down press
readonly MAX_VOL=150     # Maximum allowed volume (150 = allow slight boost)
readonly NOTIFY_ID=9901  # Fixed notification ID so updates replace each other

# ── Helpers ───────────────────────────────────────────────────────────────────
die() {
    echo "volume: error: $*" >&2
    exit 1
}

command -v pactl &>/dev/null || die "pactl not found — is pipewire-pulse installed?"

# Get current sink volume (0–100+)
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ \
        | grep -oP '\d+(?=%)' | head -1
}

# Get mute state: "yes" or "no"
get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ \
        | grep -oP '(?<=Mute: )\w+'
}

# Get source (mic) mute state
get_mic_mute() {
    pactl get-source-mute @DEFAULT_SOURCE@ \
        | grep -oP '(?<=Mute: )\w+'
}

# Volume → icon name
volume_icon() {
    local vol="$1"
    local muted="$2"
    if [[ "$muted" == "yes" ]]; then
        echo "audio-volume-muted"
    elif (( vol == 0 )); then
        echo "audio-volume-muted"
    elif (( vol < 34 )); then
        echo "audio-volume-low"
    elif (( vol < 67 )); then
        echo "audio-volume-medium"
    else
        echo "audio-volume-high"
    fi
}

# Nerd Font glyph for the OSD
volume_glyph() {
    local vol="$1"
    local muted="$2"
    if [[ "$muted" == "yes" ]] || (( vol == 0 )); then
        echo "󰝟"
    elif (( vol < 34 )); then
        echo "󰕿"
    elif (( vol < 67 )); then
        echo "󰖀"
    else
        echo "󰕾"
    fi
}

# Send an OSD notification with a progress bar
send_notification() {
    local vol="$1"
    local muted="$2"
    local glyph
    glyph="$(volume_glyph "$vol" "$muted")"
    local icon
    icon="$(volume_icon "$vol" "$muted")"

    local label
    if [[ "$muted" == "yes" ]]; then
        label="Muted"
    else
        label="${vol}%"
    fi

    # Use dunstify for replaceable notifications if available
    if command -v dunstify &>/dev/null; then
        dunstify \
            --appname="HyprFlux" \
            --icon="$icon" \
            --hints="int:value:${vol}" \
            --hints="string:x-dunst-stack-tag:volume" \
            --replace="$NOTIFY_ID" \
            --timeout=1800 \
            "${glyph}  Volume" \
            "$label"
    elif command -v notify-send &>/dev/null; then
        notify-send \
            --app-name="HyprFlux" \
            --icon="$icon" \
            --hint="int:value:${vol}" \
            --hint="string:x-dunst-stack-tag:volume" \
            --expire-time=1800 \
            "${glyph}  Volume" \
            "$label"
    fi
}

send_mic_notification() {
    local muted="$1"
    local label icon

    if [[ "$muted" == "yes" ]]; then
        label="Microphone Muted"
        icon="microphone-sensitivity-muted"
    else
        label="Microphone Active"
        icon="microphone-sensitivity-high"
    fi

    if command -v dunstify &>/dev/null; then
        dunstify \
            --appname="HyprFlux" \
            --icon="$icon" \
            --hints="string:x-dunst-stack-tag:mic" \
            --replace="$(( NOTIFY_ID + 1 ))" \
            --timeout=1800 \
            "󰍬  Microphone" \
            "$label"
    elif command -v notify-send &>/dev/null; then
        notify-send \
            --app-name="HyprFlux" \
            --icon="$icon" \
            --hint="string:x-dunst-stack-tag:mic" \
            --expire-time=1800 \
            "󰍬  Microphone" \
            "$label"
    fi
}

# ── Actions ───────────────────────────────────────────────────────────────────
vol_up() {
    local current
    current="$(get_volume)"
    local new=$(( current + STEP ))
    (( new > MAX_VOL )) && new=$MAX_VOL

    if (( new > current )); then
        pactl set-sink-volume @DEFAULT_SINK@ "${new}%"
        # Unmute on raise
        pactl set-sink-mute @DEFAULT_SINK@ 0
    fi

    send_notification "$(get_volume)" "no"
}

vol_down() {
    pactl set-sink-volume @DEFAULT_SINK@ "-${STEP}%"
    local vol
    vol="$(get_volume)"
    (( vol < 0 )) && pactl set-sink-volume @DEFAULT_SINK@ "0%"
    send_notification "$(get_volume)" "$(get_mute)"
}

vol_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    send_notification "$(get_volume)" "$(get_mute)"
}

vol_micmute() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    send_mic_notification "$(get_mic_mute)"
}

vol_set() {
    local level="$1"
    [[ "$level" =~ ^[0-9]+$ ]] || die "Expected a number, got: ${level}"
    (( level > MAX_VOL )) && level=$MAX_VOL
    pactl set-sink-volume @DEFAULT_SINK@ "${level}%"
    send_notification "$(get_volume)" "$(get_mute)"
}

vol_get() {
    local vol muted mic_muted
    vol="$(get_volume)"
    muted="$(get_mute)"
    mic_muted="$(get_mic_mute)"
    printf '{"volume":%s,"muted":%s,"mic_muted":%s}\n' \
        "$vol" \
        "$( [[ "$muted"     == "yes" ]] && echo "true" || echo "false" )" \
        "$( [[ "$mic_muted" == "yes" ]] && echo "true" || echo "false" )"
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    local action="${1:-get}"

    case "$action" in
        up)         vol_up ;;
        down)       vol_down ;;
        mute)       vol_mute ;;
        micmute)    vol_micmute ;;
        set)
            [[ -z "${2:-}" ]] && die "Usage: volume.sh set <0-150>"
            vol_set "$2"
            ;;
        get)        vol_get ;;
        *)
            echo "Usage: volume.sh [up|down|mute|micmute|set <level>|get]" >&2
            exit 1
            ;;
    esac
}

main "$@"
