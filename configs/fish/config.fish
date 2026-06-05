# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — Fish shell config  (Fish 3.6+)
# ══════════════════════════════════════════════════════════════════════════════

if not status is-interactive
    return
end

# ── PATH ──────────────────────────────────────────────────────────────────────
fish_add_path --move --prepend \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.go/bin"

# ── Environment ───────────────────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER  less
set -gx BROWSER firefox
set -gx LESS   '-R --use-color -Dd+r$Du+b'
set -gx LESSHISTFILE /dev/null

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME   "$HOME/.local/share"
set -gx XDG_STATE_HOME  "$HOME/.local/state"
set -gx XDG_CACHE_HOME  "$HOME/.cache"

# Wayland / Qt
set -gx QT_QPA_PLATFORM          wayland
set -gx QT_QPA_PLATFORMTHEME     qt6ct
set -gx MOZ_ENABLE_WAYLAND       1
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland

# ── Prompt — Starship (preferred) ─────────────────────────────────────────────
if command -v starship &>/dev/null
    starship init fish | source
end

# ── Abbreviations (expand on Space) ───────────────────────────────────────────

# Navigation
abbr -a ..    'cd ..'
abbr -a ...   'cd ../..'
abbr -a ....  'cd ../../..'
abbr -a dl    'cd ~/Downloads'
abbr -a dt    'cd ~/Desktop'

# Listing
if command -v eza &>/dev/null
    abbr -a ls   'eza --icons --group-directories-first'
    abbr -a ll   'eza --icons --group-directories-first -l --git'
    abbr -a la   'eza --icons --group-directories-first -la --git'
    abbr -a lt   'eza --icons --tree --level=2'
else
    abbr -a ls   'ls --color=auto --group-directories-first'
    abbr -a ll   'ls --color=auto -lhF --group-directories-first'
    abbr -a la   'ls --color=auto -lahF --group-directories-first'
end

# Editor
abbr -a v    nvim
abbr -a vi   nvim
abbr -a vim  nvim

# Git
abbr -a g    git
abbr -a ga   'git add'
abbr -a gaa  'git add --all'
abbr -a gc   'git commit'
abbr -a gcm  'git commit -m'
abbr -a gco  'git checkout'
abbr -a gcb  'git checkout -b'
abbr -a gd   'git diff'
abbr -a gl   'git log --oneline --graph --decorate --all'
abbr -a gp   'git push'
abbr -a gpl  'git pull'
abbr -a gst  'git status'
abbr -a gsta 'git stash'
abbr -a gstp 'git stash pop'

# Pacman / yay
abbr -a pac   'sudo pacman'
abbr -a pacs  'sudo pacman -S'
abbr -a pacr  'sudo pacman -Rns'
abbr -a pacu  'sudo pacman -Syu'
abbr -a pacq  'pacman -Q'
abbr -a pacss 'pacman -Ss'
abbr -a yayu  'yay -Syu'
abbr -a yays  'yay -S'

# System
abbr -a df    'df -h'
abbr -a du    'du -sh'
abbr -a free  'free -h'
abbr -a top   btop
abbr -a psg   'ps aux | grep'
abbr -a ports 'ss -tulpn'
abbr -a myip  'curl -s ifconfig.me'

# Safety
abbr -a rm    'rm -i'
abbr -a cp    'cp -i'
abbr -a mv    'mv -i'
abbr -a mkdir 'mkdir -p'

# Misc
abbr -a q     exit
abbr -a reload 'source ~/.config/fish/config.fish'
abbr -a ff    fastfetch
abbr -a py    python3
abbr -a http  'python3 -m http.server'
abbr -a grep  'grep --color=auto'

# HyprFlux
abbr -a wallpaper   'wallpaper'
abbr -a theme       'theme-switch'
abbr -a update      'update-system'

# bat as cat
if command -v bat &>/dev/null
    abbr -a cat 'bat --style=plain'
    set -gx BAT_THEME "tokyonight_night"
end

# ── Functions ─────────────────────────────────────────────────────────────────

function mkcd --description "mkdir + cd"
    mkdir -p -- $argv[1] && cd -- $argv[1]
end

function extract --description "Extract any archive"
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.gz'  ; tar xzf $argv[1]
            case '*.tar.bz2' ; tar xjf $argv[1]
            case '*.tar.xz'  ; tar xJf $argv[1]
            case '*.tar.zst' ; tar --zstd -xf $argv[1]
            case '*.zip'     ; unzip $argv[1]
            case '*.7z'      ; 7z x $argv[1]
            case '*.gz'      ; gunzip $argv[1]
            case '*.bz2'     ; bunzip2 $argv[1]
            case '*.xz'      ; unxz $argv[1]
            case '*.rar'     ; unrar x $argv[1]
            case '*.tar'     ; tar xf $argv[1]
            case '*'         ; echo "extract: unknown format '$argv[1]'"
        end
    else
        echo "extract: '$argv[1]' is not a file"
    end
end

# ── FZF ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null
    set -gx FZF_DEFAULT_OPTS "\
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --prompt='  ' \
        --pointer=' ' \
        --color=bg+:#24283b,bg:#1a1b26,hl:#f7768e \
        --color=fg:#c0caf5,header:#7aa2f7,info:#7aa2f7,pointer:#7aa2f7 \
        --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e"

    if command -v fd &>/dev/null
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    end
end

# ── Zoxide (smarter navigation — use z, keep cd as builtin) ──────────────────
if command -v zoxide &>/dev/null
    zoxide init fish | source
end
