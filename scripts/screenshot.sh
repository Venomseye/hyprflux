#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — screenshot.sh
# Screenshot tool for Hyprland / Wayland.
#
# Usage:
#   screenshot.sh full        Capture entire screen(s) → file + clipboard
#   screenshot.sh region      Interactive region select → annotate in swappy
#   screenshot.sh window      Capture the focused window → file + clipboard
#   screenshot.sh clipboard   Region select → clipboard only (no file saved)
#
# Saved to: ~/Pictures/Screenshots/
# Dependencies: grim, slurp, swappy, wl-clipboard, libnotify
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

readonly SAVE_DIR="${HOME}/Pictures/Screenshots"
readonly TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
readonly FILENAME="screenshot_${TIMESTAMP}.png"
readonly FILEPATH="${SAVE_DIR}/${FILENAME}"

# ── Helpers ───────────────────────────────────────────────────────────────────
notify_success() {
    local file="$1"
    if command -v notify-send &>/dev/null; then
        notify-send \
            --app-name="HyprFlux" \
            --icon="${file}" \
            --hint="string:image-path:${file}" \
            "Screenshot Saved" \
            "$(basename "$file")"
    fi
}

notify_clipboard() {
    command -v notify-send &>/dev/null \
        && notify-send --app-name="HyprFlux" \
                       --icon="edit-copy" \
                       "Screenshot" \
                       "Copied to clipboard"
}

notify_error() {
    command -v notify-send &>/dev/null \
        && notify-send --app-name="HyprFlux" \
                       --icon="dialog-error" \
                       --urgency=critical \
                       "Screenshot Failed" "$1"
    echo "screenshot: error: $1" >&2
}

check_deps() {
    for cmd in grim; do
        command -v "$cmd" &>/dev/null || {
            notify_error "${cmd} is not installed (pacman -S ${cmd})"
            exit 1
        }
    done
}

ensure_save_dir() {
    mkdir -p "$SAVE_DIR"
}

# Copy file to clipboard if wl-copy is available
copy_to_clipboard() {
    local file="$1"
    if command -v wl-copy &>/dev/null; then
        wl-copy < "$file"
    fi
}

# ── Capture modes ─────────────────────────────────────────────────────────────

# Full screenshot — all outputs
capture_full() {
    ensure_save_dir
    if ! grim "$FILEPATH"; then
        notify_error "grim failed to capture screen"
        exit 1
    fi
    copy_to_clipboard "$FILEPATH"
    notify_success "$FILEPATH"
}

# Region select → swappy annotation
capture_region() {
    ensure_save_dir

    if ! command -v slurp &>/dev/null; then
        notify_error "slurp is not installed (pacman -S slurp)"
        exit 1
    fi

    local region
    region="$(slurp -d -c '#7aa2f7FF' -b '#1a1b2640' -s '#7aa2f720' 2>/dev/null || echo "")"
    [[ -z "$region" ]] && exit 0   # User cancelled

    if command -v swappy &>/dev/null; then
        # Pipe directly into swappy for annotation; swappy handles saving
        grim -g "$region" - | swappy -f - -o "$FILEPATH"
        [[ -f "$FILEPATH" ]] && {
            copy_to_clipboard "$FILEPATH"
            notify_success "$FILEPATH"
        }
    else
        # swappy not available — just save the raw capture
        grim -g "$region" "$FILEPATH"
        copy_to_clipboard "$FILEPATH"
        notify_success "$FILEPATH"
    fi
}

# Active window capture using hyprctl geometry
capture_window() {
    ensure_save_dir

    if ! command -v hyprctl &>/dev/null; then
        notify_error "hyprctl not found — is Hyprland running?"
        exit 1
    fi

    # Get active window geometry from Hyprland
    local geom
    geom="$(hyprctl activewindow -j 2>/dev/null \
        | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    at = d['at']
    sz = d['size']
    print(f'{at[0]},{at[1]} {sz[0]}x{sz[1]}')
except Exception:
    sys.exit(1)
" 2>/dev/null || echo "")"

    if [[ -z "$geom" ]]; then
        notify_error "No active window found"
        exit 1
    fi

    if ! grim -g "$geom" "$FILEPATH"; then
        notify_error "grim failed to capture window"
        exit 1
    fi

    copy_to_clipboard "$FILEPATH"
    notify_success "$FILEPATH"
}

# Region select → clipboard only (no file)
capture_to_clipboard() {
    if ! command -v slurp &>/dev/null; then
        notify_error "slurp is not installed (pacman -S slurp)"
        exit 1
    fi

    local region
    region="$(slurp -d -c '#7aa2f7FF' -b '#1a1b2640' -s '#7aa2f720' 2>/dev/null || echo "")"
    [[ -z "$region" ]] && exit 0

    local tmpfile
    tmpfile="$(mktemp /tmp/hyprflux-screenshot-XXXXXX.png)"
    # shellcheck disable=SC2064
    trap "rm -f '${tmpfile}'" EXIT

    grim -g "$region" "$tmpfile"
    wl-copy < "$tmpfile"
    notify_clipboard
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    check_deps

    local mode="${1:-region}"

    case "$mode" in
        full)       capture_full ;;
        region)     capture_region ;;
        window)     capture_window ;;
        clipboard)  capture_to_clipboard ;;
        *)
            echo "Usage: screenshot.sh [full|region|window|clipboard]" >&2
            exit 1
            ;;
    esac
}

main "$@"
