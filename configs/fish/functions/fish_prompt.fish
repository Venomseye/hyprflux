# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — fish_prompt.fish
# Fallback prompt for when Starship is not installed.
# Starship is the preferred prompt (config.fish initialises it if present).
# ══════════════════════════════════════════════════════════════════════════════
# Layout:
#   ╭─ user@host  ~/path  git:branch  [venv]
#   ╰─ ❯
# ══════════════════════════════════════════════════════════════════════════════

function fish_prompt --description "HyprFlux fallback prompt"
    # Only run this prompt if Starship hasn't taken over
    if command -v starship &>/dev/null
        return
    end

    set -l last_status $status

    # ── Colours ───────────────────────────────────────────────────────────────
    set -l col_user    (set_color --bold brblue)
    set -l col_host    (set_color cyan)
    set -l col_dir     (set_color --bold brwhite)
    set -l col_git     (set_color yellow)
    set -l col_venv    (set_color magenta)
    set -l col_ok      (set_color --bold green)
    set -l col_err     (set_color --bold red)
    set -l col_dim     (set_color brblack)
    set -l col_reset   (set_color normal)

    # ── User & host ───────────────────────────────────────────────────────────
    set -l user_host "$col_user$USER$col_dim@$col_host$hostname"

    # ── Current directory (contract $HOME to ~) ───────────────────────────────
    set -l cwd (string replace --regex "^$HOME" "~" $PWD)
    set -l dir_part "$col_dir $cwd"

    # ── Git branch ────────────────────────────────────────────────────────────
    set -l git_part ""
    if command -v git &>/dev/null
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        if test -n "$branch"
            set -l dirty ""
            if test -n (git status --porcelain 2>/dev/null | head -1)
                set dirty "$col_err*"
            end
            set git_part "  $col_dim on $col_git $branch$dirty"
        end
    end

    # ── Python virtual env ────────────────────────────────────────────────────
    set -l venv_part ""
    if test -n "$VIRTUAL_ENV"
        set venv_part "  $col_venv($(basename $VIRTUAL_ENV))"
    end

    # ── Top line ──────────────────────────────────────────────────────────────
    echo -n "$col_dim╭─ $col_reset"
    echo -n "$user_host$dir_part$git_part$venv_part"
    echo ""

    # ── Bottom line (prompt character) ────────────────────────────────────────
    echo -n "$col_dim╰─ "
    if test $last_status -eq 0
        echo -n "$col_ok❯ $col_reset"
    else
        echo -n "$col_err❯ $col_reset"
    end
end

function fish_mode_prompt --description "Suppress vi mode indicator"
    # We handle this in fish_prompt above if needed
end
