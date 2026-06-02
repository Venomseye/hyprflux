# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — fish_greeting.fish
# Shown once when a new interactive Fish session starts.
# Displays fastfetch if installed, otherwise a minimal ASCII greeting.
# ══════════════════════════════════════════════════════════════════════════════

function fish_greeting --description "HyprFlux session greeting"
    # Suppress greeting in non-interactive or dumb terminals
    if not status is-interactive
        return
    end
    if test "$TERM" = dumb
        return
    end

    # Skip greeting inside certain contexts
    if set -q VSCODE_INJECTION; or set -q INSIDE_EMACS
        return
    end

    if command -v fastfetch &>/dev/null
        fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
    else
        # Minimal fallback banner
        set -l col_accent  (set_color --bold brblue)
        set -l col_dim     (set_color brblack)
        set -l col_reset   (set_color normal)
        set -l col_text    (set_color brwhite)

        echo ""
        echo -n "  $col_accent󱄅  HyprFlux$col_reset"
        echo    "$col_dim  ·  Arch Linux · Hyprland · Wayland$col_reset"
        echo ""
        echo    "  $col_dim User:    $col_text$USER$col_reset"
        echo    "  $col_dim Shell:   $col_text$(fish --version 2>&1 | head -1)$col_reset"
        echo    "  $col_dim Kernel:  $col_text$(uname -r)$col_reset"
        echo    "  $col_dim Uptime:  $col_text$(uptime -p | sed 's/up //')$col_reset"
        echo ""
    end
end
