# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — Fish Shell Configuration
# ~/.config/fish/config.fish
# ══════════════════════════════════════════════════════════════════════════════

# ── Only run interactive config in interactive sessions ───────────────────────
if not status is-interactive
    exit
end

# ══════════════════════════════════════════════════════════════════════════════
# PATH
# ══════════════════════════════════════════════════════════════════════════════

fish_add_path --move --prepend \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.go/bin" \
    "/usr/local/bin"

# ══════════════════════════════════════════════════════════════════════════════
# ENVIRONMENT
# ══════════════════════════════════════════════════════════════════════════════

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER  less
set -gx BROWSER firefox

set -gx LESS '-R --use-color -Dd+r$Du+b'
set -gx LESSHISTFILE /dev/null

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME   "$HOME/.local/share"
set -gx XDG_STATE_HOME  "$HOME/.local/state"
set -gx XDG_CACHE_HOME  "$HOME/.cache"

# Wayland / Qt
set -gx QT_QPA_PLATFORM         wayland
set -gx QT_QPA_PLATFORMTHEME    qt6ct
set -gx MOZ_ENABLE_WAYLAND      1
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland

# ══════════════════════════════════════════════════════════════════════════════
# PROMPT — Starship (if installed), otherwise built-in fish_prompt.fish
# ══════════════════════════════════════════════════════════════════════════════

if command -v starship &>/dev/null
    starship init fish | source
end

# ══════════════════════════════════════════════════════════════════════════════
# ABBREVIATIONS (expand on Space, unlike aliases)
# ══════════════════════════════════════════════════════════════════════════════

# Navigation
abbr --add ..     'cd ..'
abbr --add ...    'cd ../..'
abbr --add ....   'cd ../../..'
abbr --add ~      'cd ~'
abbr --add dl     'cd ~/Downloads'
abbr --add dt     'cd ~/Desktop'
abbr --add dc     'cd ~/Documents'

# Listing (use eza if available, else ls)
if command -v eza &>/dev/null
    abbr --add ls    'eza --icons --group-directories-first'
    abbr --add ll    'eza --icons --group-directories-first -l --git'
    abbr --add la    'eza --icons --group-directories-first -la --git'
    abbr --add lt    'eza --icons --tree --level=2'
    abbr --add lta   'eza --icons --tree --level=3 -a'
else
    abbr --add ls    'ls --color=auto --group-directories-first'
    abbr --add ll    'ls --color=auto -lhF --group-directories-first'
    abbr --add la    'ls --color=auto -lahF --group-directories-first'
end

# Editor
abbr --add v     'nvim'
abbr --add vi    'nvim'
abbr --add vim   'nvim'
abbr --add nv    'nvim'
abbr --add code  'code --ozone-platform=wayland'

# Git
abbr --add g      'git'
abbr --add ga     'git add'
abbr --add gaa    'git add --all'
abbr --add gc     'git commit'
abbr --add gcm    'git commit -m'
abbr --add gco    'git checkout'
abbr --add gcb    'git checkout -b'
abbr --add gd     'git diff'
abbr --add gds    'git diff --staged'
abbr --add gl     'git log --oneline --graph --decorate --all'
abbr --add gp     'git push'
abbr --add gpl    'git pull'
abbr --add gst    'git status'
abbr --add gsta   'git stash'
abbr --add gstp   'git stash pop'
abbr --add gr     'git remote -v'
abbr --add grb    'git rebase'
abbr --add gm     'git merge'
abbr --add gt     'git tag'
abbr --add gclone 'git clone'

# Pacman / yay
abbr --add pac    'sudo pacman'
abbr --add pacs   'sudo pacman -S'
abbr --add pacr   'sudo pacman -Rns'
abbr --add pacu   'sudo pacman -Syu'
abbr --add pacq   'pacman -Q'
abbr --add pacss  'pacman -Ss'
abbr --add yay    'yay'
abbr --add yayu   'yay -Syu'
abbr --add yays   'yay -S'

# System
abbr --add df     'df -h'
abbr --add du     'du -sh'
abbr --add free   'free -h'
abbr --add top    'btop'
abbr --add ps     'ps aux'
abbr --add psg    'ps aux | grep'
abbr --add ports  'ss -tulpn'
abbr --add myip   'curl -s ifconfig.me'

# Safety nets
abbr --add rm     'rm -i'
abbr --add cp     'cp -i'
abbr --add mv     'mv -i'
abbr --add mkdir  'mkdir -p'

# Misc
abbr --add please 'sudo'
abbr --add sudo   'sudo '         # trailing space propagates sudo to abbrs
abbr --add q      'exit'
abbr --add reload 'source ~/.config/fish/config.fish'
abbr --add ff     'fastfetch'
abbr --add py     'python3'
abbr --add http   'python3 -m http.server'

# HyprFlux scripts
abbr --add wallpaper   'wallpaper'
abbr --add theme       'theme-switch'
abbr --add update      'update-system'
abbr --add screenshot  'screenshot'

# ══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════════

# mkcd: create and enter a directory
function mkcd --description "Create directory and cd into it"
    mkdir -p -- $argv[1] && cd -- $argv[1]
end

# extract: universal archive extractor
function extract --description "Extract any archive"
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'  ; tar xjf $argv[1]
            case '*.tar.gz'   ; tar xzf $argv[1]
            case '*.tar.xz'   ; tar xJf $argv[1]
            case '*.tar.zst'  ; tar --zstd -xf $argv[1]
            case '*.bz2'      ; bunzip2 $argv[1]
            case '*.gz'       ; gunzip $argv[1]
            case '*.tar'      ; tar xf $argv[1]
            case '*.tbz2'     ; tar xjf $argv[1]
            case '*.tgz'      ; tar xzf $argv[1]
            case '*.zip'      ; unzip $argv[1]
            case '*.7z'       ; 7z x $argv[1]
            case '*.rar'      ; unrar x $argv[1]
            case '*.xz'       ; unxz $argv[1]
            case '*.zst'      ; zstd -d $argv[1]
            case '*'          ; echo "extract: unknown extension for '$argv[1]'"
        end
    else
        echo "extract: '$argv[1]' is not a file"
    end
end

# fcd: fuzzy-find and cd into a directory
function fcd --description "Fuzzy cd into a directory"
    if command -v fzf &>/dev/null
        set dir (find . -type d -not -path '*/.git/*' 2>/dev/null | fzf --height=40% --preview='ls {}')
        if test -n "$dir"
            cd $dir
        end
    else
        echo "fcd: fzf is not installed"
    end
end

# gig: create a .gitignore from gitignore.io
function gig --description "Generate .gitignore via gitignore.io"
    curl -sL "https://www.toptal.com/developers/gitignore/api/$argv" > .gitignore \
        && echo ".gitignore created for: $argv"
end

# ══════════════════════════════════════════════════════════════════════════════
# FZF INTEGRATION
# ══════════════════════════════════════════════════════════════════════════════

if command -v fzf &>/dev/null
    set -gx FZF_DEFAULT_OPTS "\
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --prompt='  ' \
        --pointer=' ' \
        --marker=' ' \
        --color=bg+:#24283b,bg:#1a1b26,spinner:#7aa2f7,hl:#f7768e \
        --color=fg:#c0caf5,header:#7aa2f7,info:#7aa2f7,pointer:#7aa2f7 \
        --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e"

    if command -v fd &>/dev/null
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND  "$FZF_DEFAULT_COMMAND"
    end
end

# ══════════════════════════════════════════════════════════════════════════════
# ZOXIDE (smarter cd)
# ══════════════════════════════════════════════════════════════════════════════

if command -v zoxide &>/dev/null
    zoxide init fish | source
    abbr --add cd 'z'
end

# ══════════════════════════════════════════════════════════════════════════════
# COLOURS
# ══════════════════════════════════════════════════════════════════════════════

# Use bat instead of cat if available
if command -v bat &>/dev/null
    abbr --add cat 'bat --style=plain'
    set -gx BAT_THEME "tokyonight_night"
end

# Coloured man pages via bat
if command -v bat &>/dev/null
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# ══════════════════════════════════════════════════════════════════════════════
# GREETING
# ══════════════════════════════════════════════════════════════════════════════
# Defined in functions/fish_greeting.fish
