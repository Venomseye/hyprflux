#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — nowplaying.sh
# Waybar now-playing module with smooth scrolling text.
#
# Output: one JSON line per tick for waybar's custom module.
# Usage:  exec this script from the waybar custom/nowplaying module.
#         Do not call directly; waybar manages the process lifecycle.
#
# Keybinds wired up in config.jsonc:
#   Left-click  → play/pause
#   Right-click → next track
#   Scroll up   → next track
#   Scroll down → previous track
# ══════════════════════════════════════════════════════════════════════════════

readonly MAX_DISPLAY=20       # Characters visible at once
readonly SCROLL_STEP=0.5      # Seconds between scroll advances
readonly POLL_STEP=1          # Seconds between polls when not scrolling
readonly SCROLL_GAP="    "    # Padding between end and start of scrolling text

readonly ICON_PLAY="󰎈"
readonly ICON_PAUSE="⏸"

# ── JSON-safe string escape ────────────────────────────────────────────────────
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"    # backslash
    s="${s//\"/\\\"}"    # double-quote
    s="${s//$'\t'/ }"    # tab → space
    s="${s//$'\n'/ }"    # newline → space
    printf '%s' "$s"
}

# ── Emit one waybar JSON line ──────────────────────────────────────────────────
emit() {
    local text="$1" class="$2" tooltip="$3"
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
        "$(json_escape "$text")" \
        "$class" \
        "$(json_escape "$tooltip")"
}

# ── State ─────────────────────────────────────────────────────────────────────
offset=0
last_full=""
last_status=""

# ── Main loop ─────────────────────────────────────────────────────────────────
while true; do

    # Check whether any MPRIS player is available
    if ! playerctl status &>/dev/null 2>&1; then
        if [[ "$last_status" != "none" ]]; then
            emit "" "stopped" "No media player"
            last_status="none"
            offset=0
            last_full=""
        fi
        sleep "$POLL_STEP"
        continue
    fi

    status=$(playerctl status 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null || true)
    title=$(playerctl  metadata title  2>/dev/null || true)

    # Build the full display string
    if [[ -n "$artist" && -n "$title" ]]; then
        full="${artist} — ${title}"
    elif [[ -n "$title" ]]; then
        full="$title"
    else
        full="Unknown"
    fi

    len=${#full}

    # Reset scroll position when the track changes
    if [[ "$full" != "$last_full" ]]; then
        offset=0
        last_full="$full"
    fi

    # ── Stopped ───────────────────────────────────────────────────────────────
    if [[ "$status" == "Stopped" ]]; then
        if [[ "$last_status" != "Stopped" ]]; then
            emit "" "stopped" "Stopped"
            last_status="Stopped"
            offset=0
        fi
        sleep "$POLL_STEP"
        continue
    fi

    # ── Paused ────────────────────────────────────────────────────────────────
    if [[ "$status" == "Paused" ]]; then
        # Show static (non-scrolling) truncated title with pause icon
        if (( len <= MAX_DISPLAY )); then
            display="$full"
        else
            display="${full:0:$MAX_DISPLAY}"
        fi
        emit "${ICON_PAUSE}  ${display}" "paused" "${full}"
        last_status="Paused"
        offset=0
        sleep "$POLL_STEP"
        continue
    fi

    # ── Playing ───────────────────────────────────────────────────────────────
    last_status="Playing"

    if (( len <= MAX_DISPLAY )); then
        # Short enough — show as-is, no scroll needed
        display="$full"
        emit "${ICON_PLAY}  ${display}" "playing" "${full}"
        offset=0
        sleep "$POLL_STEP"
        continue
    fi

    # Text is longer than MAX_DISPLAY — build scrolling window
    padded="${full}${SCROLL_GAP}"
    plen=${#padded}

    # Clamp offset in case the track length changed under us
    (( offset >= plen )) && offset=0

    if (( offset + MAX_DISPLAY <= plen )); then
        display="${padded:$offset:$MAX_DISPLAY}"
    else
        # Wrap: take remainder from end, fill from beginning
        tail="${padded:$offset}"
        needed=$(( MAX_DISPLAY - ${#tail} ))
        head="${padded:0:$needed}"
        display="${tail}${head}"
    fi

    emit "${ICON_PLAY}  ${display}" "playing" "${full}"

    # Advance scroll offset
    (( offset++ )) || true
    (( offset >= plen )) && offset=0

    sleep "$SCROLL_STEP"
done
