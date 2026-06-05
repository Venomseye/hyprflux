# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — fish_greeting.fish
# ══════════════════════════════════════════════════════════════════════════════

function fish_greeting --description "HyprFlux session greeting"
    if not status is-interactive
        return
    end

    # Skip in dumb terminals or embedded contexts
    if test "$TERM" = dumb
        return
    end

    if set -q VSCODE_INJECTION; or set -q INSIDE_EMACS
        return
    end

    if command -v fastfetch &>/dev/null
        fastfetch --config "$HOME/.config/fastfetch/config.jsonc" 2>/dev/null
    end
end
