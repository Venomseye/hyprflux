# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — fish_prompt.fish
# Fallback prompt — only used when Starship is NOT installed.
# ══════════════════════════════════════════════════════════════════════════════

function fish_prompt --description "HyprFlux fallback prompt"
    # Starship handles prompt when installed (see config.fish)
    if command -v starship &>/dev/null
        return
    end

    set -l last_status $status
    set -l cyan    (set_color --bold cyan)
    set -l blue    (set_color brblue)
    set -l white   (set_color --bold white)
    set -l yellow  (set_color yellow)
    set -l red     (set_color --bold red)
    set -l green   (set_color --bold green)
    set -l dim     (set_color brblack)
    set -l reset   (set_color normal)

    set -l cwd (string replace --regex "^$HOME" "~" $PWD)

    set -l git_info ""
    if command -v git &>/dev/null
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$branch"
            set -l dirty ""
            if test -n "$(git status --porcelain 2>/dev/null | head -1)"
                set dirty "$red*"
            end
            set git_info "  $dim on $yellow $branch$dirty"
        end
    end

    echo -n "$dim╭─ $reset$cyan$USER$dim@$blue"(hostname -s)"$reset $white$cwd$reset$git_info$reset"
    echo ""
    echo -n "$dim╰─ "
    if test $last_status -eq 0
        echo -n "$green❯ $reset"
    else
        echo -n "$red❯ $reset"
    end
end

function fish_mode_prompt; end
