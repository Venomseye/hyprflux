#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — record-screen.sh
# Screen recorder using wf-recorder.
#
# Usage:
#   record-screen.sh toggle     Start recording, or stop if already running
#   record-screen.sh start      Start a new recording (with region select)
#   record-screen.sh start full Start recording the full screen
#   record-screen.sh stop       Stop any active recording
#   record-screen.sh status     Print "recording" or "idle"
#
# Saved to: ~/Videos/Recordings/
# Dependencies: wf-recorder, slurp, wl-clipboard, libnotify
# Optional:     ffmpeg (for post-process: convert mkv → mp4)
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

readonly SAVE_DIR="${HOME}/Videos/Recordings"
readonly PID_FILE="/tmp/hyprflux-recorder.pid"
readonly TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
readonly FILENAME="recording_${TIMESTAMP}.mkv"
readonly FILEPATH="${SAVE_DIR}/${FILENAME}"

# Audio: set to "default" to record desktop audio via PipeWire;
#        set to "" to record silently.
readonly AUDIO_DEVICE="default"

# ── Helpers ───────────────────────────────────────────────────────────────────
notify() {
    local summary="$1" body="${2:-}" icon="${3:-video-display}"
    command -v notify-send &>/dev/null \
        && notify-send --app-name="HyprFlux" --icon="$icon" "$summary" "$body"
}

die() {
    echo "record-screen: error: $*" >&2
    notify "Recording Error" "$*" "dialog-error"
    exit 1
}

is_recording() {
    [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

ensure_save_dir() {
    mkdir -p "$SAVE_DIR"
}

check_deps() {
    command -v wf-recorder &>/dev/null \
        || die "wf-recorder is not installed (pacman -S wf-recorder)"
}

# ── Stop recording ────────────────────────────────────────────────────────────
stop_recording() {
    if ! is_recording; then
        echo "record-screen: not recording" >&2
        return 0
    fi

    local pid
    pid="$(cat "$PID_FILE")"
    kill -SIGINT "$pid" 2>/dev/null || kill -SIGTERM "$pid" 2>/dev/null || true

    # Wait for wf-recorder to flush and close the file
    local waited=0
    while kill -0 "$pid" 2>/dev/null && (( waited < 30 )); do
        sleep 0.2
        (( waited++ )) || true
    done

    rm -f "$PID_FILE"

    # Find the most recently modified recording file
    local latest
    latest="$(find "$SAVE_DIR" -maxdepth 1 -name '*.mkv' -newer "$PID_FILE" \
              -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | head -1 | awk '{print $2}')"

    # Optionally convert to mp4 in background
    if [[ -n "$latest" ]] && [[ -f "$latest" ]] && command -v ffmpeg &>/dev/null; then
        local mp4="${latest%.mkv}.mp4"
        ffmpeg -i "$latest" -c:v copy -c:a aac -y "$mp4" &>/dev/null \
            && rm -f "$latest" \
            && latest="$mp4" &
        disown
    fi

    notify "Recording Stopped" \
        "Saved to: $(basename "${latest:-${FILEPATH}}")" \
        "video-display"
}

# ── Start recording ───────────────────────────────────────────────────────────
start_recording() {
    local capture_mode="${1:-region}"

    is_recording && die "Already recording. Use 'stop' first."
    ensure_save_dir

    # Countdown notification
    notify "Recording Starting" "3…" "video-display"
    sleep 1
    notify "Recording Starting" "2…" "video-display"
    sleep 1
    notify "Recording Starting" "1…" "video-display"
    sleep 1

    local wfr_args=( -f "$FILEPATH" )

    # Audio
    if [[ -n "$AUDIO_DEVICE" ]]; then
        wfr_args+=( --audio="$AUDIO_DEVICE" )
    fi

    # Region selection
    if [[ "$capture_mode" == "region" ]]; then
        if ! command -v slurp &>/dev/null; then
            die "slurp is not installed (pacman -S slurp)"
        fi
        local region
        region="$(slurp -d -c '#f7768eFF' -b '#1a1b2640' -s '#f7768e20' 2>/dev/null || echo "")"
        [[ -z "$region" ]] && exit 0
        wfr_args+=( -g "$region" )
    fi
    # "full" mode: no -g flag → records all outputs

    # Launch wf-recorder in background, save PID
    wf-recorder "${wfr_args[@]}" &
    local rec_pid=$!
    printf '%s\n' "$rec_pid" > "$PID_FILE"

    # Verify it started
    sleep 0.5
    if ! kill -0 "$rec_pid" 2>/dev/null; then
        rm -f "$PID_FILE"
        die "wf-recorder failed to start"
    fi

    notify "Recording" "Press Super+Alt+R to stop" "media-record"
}

# ── Status ────────────────────────────────────────────────────────────────────
print_status() {
    if is_recording; then
        echo "recording"
    else
        echo "idle"
    fi
}

# ── Toggle ────────────────────────────────────────────────────────────────────
toggle_recording() {
    if is_recording; then
        stop_recording
    else
        start_recording "region"
    fi
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    check_deps

    local action="${1:-toggle}"

    case "$action" in
        toggle) toggle_recording ;;
        start)
            local mode="${2:-region}"
            start_recording "$mode"
            ;;
        stop)   stop_recording ;;
        status) print_status ;;
        *)
            echo "Usage: record-screen.sh [toggle|start [full]|stop|status]" >&2
            exit 1
            ;;
    esac
}

main "$@"
