#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — cava-waybar.sh
# Waybar CAVA audio visualizer module.
#
# Output: one JSON line per CAVA frame for waybar's custom module.
# Usage:  exec this script from the waybar custom/cava module.
#
# Requires: cava (pacman -S cava), playerctl
#
# Visual states:
#   Playing  →  ▁▃▆▇▅▂▄▆  (live bar graph, 8 bars)
#   Paused   →  ⏸          (pause icon)
#   Stopped  →  (empty)
# ══════════════════════════════════════════════════════════════════════════════

readonly FIFO="/tmp/hyprflux-cava-$$.fifo"   # $$ makes it per-process
readonly BARS=8
readonly FRAMERATE=25
readonly ICON_PAUSE="⏸"
readonly ICON_STOP=""

# Map 0-7 → Unicode block characters (index = bar height)
readonly -a BLOCKS=( '▁' '▂' '▃' '▄' '▅' '▆' '▇' '█' )

# ── Cleanup ───────────────────────────────────────────────────────────────────
cleanup() {
    [[ -n "${CAVA_PID:-}" ]] && kill "$CAVA_PID" 2>/dev/null || true
    [[ -n "${CAVA_CFG:-}" ]] && rm -f "$CAVA_CFG"
    rm -f "$FIFO"
    exit 0
}
trap cleanup EXIT INT TERM HUP

# ── Guard: cava must be installed ─────────────────────────────────────────────
if ! command -v cava &>/dev/null; then
    printf '{"text":"","class":"error","tooltip":"cava not installed: pacman -S cava"}\n'
    while true; do
        printf '{"text":"","class":"error"}\n'
        sleep 60
    done
fi

# ── Guard: playerctl must be installed ────────────────────────────────────────
if ! command -v playerctl &>/dev/null; then
    printf '{"text":"","class":"error","tooltip":"playerctl not installed"}\n'
    while true; do
        printf '{"text":"","class":"error"}\n'
        sleep 60
    done
fi

# ── Create named pipe ─────────────────────────────────────────────────────────
mkfifo "$FIFO"

# ── Write a temporary CAVA config ─────────────────────────────────────────────
CAVA_CFG=$(mktemp /tmp/hyprflux-cava-cfg-XXXXXX.ini)

cat > "$CAVA_CFG" <<EOF
[general]
mode            = normal
framerate       = ${FRAMERATE}
autosens        = 1
bars            = ${BARS}
lower_cutoff_freq  = 50
higher_cutoff_freq = 10000
bar_delim       = 59    ; ASCII code for ';'

[input]
method  = pulse
source  = auto

[output]
method          = raw
raw_target      = ${FIFO}
data_format     = ascii
ascii_max_range = 7
EOF

# ── Start CAVA in the background ──────────────────────────────────────────────
cava -p "$CAVA_CFG" &
CAVA_PID=$!

# Give CAVA a moment to initialise its audio capture
sleep 0.8

# ── Main read loop ────────────────────────────────────────────────────────────
# Each line from the FIFO is one frame of bar values: "3;5;2;7;4;1;6;2;"
while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    # Bail out if cava died
    if ! kill -0 "$CAVA_PID" 2>/dev/null; then
        printf '{"text":"","class":"error"}\n'
        break
    fi

    # ── Check playback state ──────────────────────────────────────────────────
    player_status=$(playerctl status 2>/dev/null || echo "None")

    case "$player_status" in
        Paused)
            printf '{"text":"%s","class":"paused","tooltip":"Paused"}\n' "$ICON_PAUSE"
            continue
            ;;
        Playing)
            ;;
        *)  # Stopped / None
            printf '{"text":"%s","class":"stopped"}\n' "$ICON_STOP"
            continue
            ;;
    esac

    # ── Build block-character visualizer ──────────────────────────────────────
    visual=""
    IFS=';' read -ra raw_vals <<< "$line"

    bar_count=0
    for val in "${raw_vals[@]}"; do
        [[ -z "$val" ]] && continue
        (( bar_count >= BARS )) && break

        # Strip any non-digit characters, clamp to 0–7
        val="${val//[^0-9]/}"
        [[ -z "$val" ]] && val=0
        (( val < 0 )) && val=0
        (( val > 7 )) && val=7

        visual+="${BLOCKS[$val]}"
        (( bar_count++ )) || true
    done

    # Pad with minimum-height bars if CAVA sent fewer values than expected
    while (( bar_count < BARS )); do
        visual+="${BLOCKS[0]}"
        (( bar_count++ )) || true
    done

    printf '{"text":"%s","class":"playing","tooltip":"Now playing"}\n' "$visual"

done < "$FIFO"

# If we fall through the loop (FIFO closed / cava died), emit empty and exit
# waybar's restart-interval will restart this script automatically
printf '{"text":"","class":"stopped"}\n'
