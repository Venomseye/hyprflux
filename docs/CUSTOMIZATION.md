# HyprFlux — Customisation Guide

How to make HyprFlux your own without breaking the update path.

---

## Table of Contents

1. [Philosophy](#philosophy)
2. [Themes](#themes)
3. [Monitors & Layout](#monitors--layout)
4. [Keybinds](#keybinds)
5. [Default Applications](#default-applications)
6. [Window Rules](#window-rules)
7. [Workspace Rules](#workspace-rules)
8. [Gaps, Borders & Rounding](#gaps-borders--rounding)
9. [Animations](#animations)
10. [Waybar Modules](#waybar-modules)
11. [Autostart Applications](#autostart-applications)
12. [Shell Aliases](#shell-aliases)

---

## Philosophy

HyprFlux uses a **modular source-chain** pattern. The root config
(`hyprland.conf`) sources 9 focused sub-files. To change something:

1. Identify which module owns it (see table below)
2. Edit only that file
3. Reload with `Super + Shift + R` (no logout needed)

| What you want to change | File to edit |
|---|---|
| Colours, borders, shadows | `~/.config/hypr/theme.conf` → `~/.config/hyprflux/themes/*.conf` |
| Monitor resolution/refresh | `~/.config/hypr/monitors.conf` |
| Keyboard, touchpad, mouse | `~/.config/hypr/input.conf` |
| Keybinds | `~/.config/hypr/keybinds.conf` |
| Float/opacity rules | `~/.config/hypr/windowrules.conf` |
| Workspace assignments | `~/.config/hypr/rules.conf` |
| Animations | `~/.config/hypr/animations.conf` |
| Startup daemons | `~/.config/hypr/autostart.conf` |
| Gaps, rounding, blur | `~/.config/hypr/hyprland.conf` |

---

## Themes

### Switching

```bash
theme-switch toggle           # cycle through all 8 themes
theme-switch select           # Rofi picker
theme-switch set catppuccin-mocha
theme-switch set nord
```

### Creating a custom theme

```bash
# 1. Copy an existing theme
cp ~/.config/hyprflux/themes/dark.conf ~/.config/hyprflux/themes/mytheme.conf

# 2. Edit it — change $accent, $accent_alt, the palette variables,
#    and all the #@wb waybar colour lines
nvim ~/.config/hyprflux/themes/mytheme.conf

# 3. Apply
theme-switch set mytheme
```

The `#@wb` comment lines in each theme file are parsed by `theme-switch.sh`
to generate `~/.config/waybar/colors.css`. Every line must follow the format:

```
#@wb     --variable-name:    value;
```

### Changing the border gradient

Edit `~/.config/hypr/hyprland.conf`:

```ini
general {
    col.active_border   = $accent $accent_alt 45deg
    # Solid border (no gradient):
    # col.active_border = $accent
    # Three-colour gradient:
    # col.active_border = $accent $accent_alt $red 90deg
}
```

---

## Monitors & Layout

Edit `~/.config/hypr/monitors.conf`.

```ini
# Auto-detect everything (default)
monitor = ,preferred,auto,auto

# Specific resolution
monitor = DP-1, 2560x1440@144, 0x0, 1

# 4K with 1.5x scaling
monitor = DP-1, 3840x2160@60, 0x0, 1.5

# Laptop display at 2x scale
monitor = eDP-1, 2560x1600@120, 0x0, 2

# Disable built-in display (clamshell mode)
monitor = eDP-1, disable
```

Find your monitor names with:
```bash
hyprctl monitors
```

### Changing workspace layout engine

Edit `~/.config/hypr/hyprland.conf`:

```ini
general {
    layout = dwindle   # or: master
}
```

---

## Keybinds

Edit `~/.config/hypr/keybinds.conf`.

### Add a new keybind

```ini
# Open your file manager with Super+E (already set)
bind = SUPER, E, exec, thunar

# Launch a specific app
bind = SUPER CTRL, B, exec, blueman-manager
bind = SUPER CTRL, V, exec, pavucontrol
bind = SUPER CTRL, M, exec, kitty -e btop
```

### Change the modifier key

At the top of `keybinds.conf`, the `SUPER` modifier is used throughout.
If you want to use `ALT` as the main modifier instead, do a find-replace:
```bash
sed -i 's/= SUPER,/= ALT,/g; s/= SUPER SHIFT,/= ALT SHIFT,/g' \
    ~/.config/hypr/keybinds.conf
```
Then reload.

---

## Default Applications

Edit the variables at the top of `~/.config/hypr/keybinds.conf`:

```ini
$terminal   = kitty
$launcher   = rofi -show drun -config ~/.config/rofi/launcher.rasi
$filesrv    = thunar
$browser    = firefox
$editor     = kitty -e nvim
```

After editing, reload with `Super + Shift + R`.

---

## Window Rules

Edit `~/.config/hypr/windowrules.conf`.

Find the class name of any window:
```bash
# Method 1: hyprctl
hyprctl clients | grep -E 'class|title'

# Method 2: live monitor (launch app, then run)
hyprctl -j clients | python3 -m json.tool | grep -E '"class"|"title"'
```

### Common rule patterns

```ini
# Float a window
windowrulev2 = float, class:^(yourapp)$

# Float and centre with a specific size
windowrulev2 = float,  class:^(yourapp)$
windowrulev2 = size 800 500, class:^(yourapp)$
windowrulev2 = center, class:^(yourapp)$

# Make a window always on top
windowrulev2 = pin, class:^(yourapp)$

# Set opacity (active inactive)
windowrulev2 = opacity 0.95 0.85, class:^(yourapp)$

# Open on a specific workspace
windowrulev2 = workspace 3, class:^(yourapp)$

# Prevent idle from triggering while app is open
windowrulev2 = idleinhibit always, class:^(yourapp)$
```

---

## Workspace Rules

Edit `~/.config/hypr/rules.conf`.

```ini
# Always open browser on workspace 2
windowrulev2 = workspace 2 silent, class:^(firefox)$

# Open terminal apps on current workspace (default — no rule needed)

# Multiple classes on same workspace
windowrulev2 = workspace 6 silent, class:^(vesktop)$
windowrulev2 = workspace 6 silent, class:^(thunderbird)$
```

The `silent` keyword moves the window without switching to its workspace.
Remove `silent` if you want Hyprland to jump to the workspace when the app opens.

---

## Gaps, Borders & Rounding

Edit `~/.config/hypr/hyprland.conf`:

```ini
general {
    gaps_in   = 4     # gap between tiled windows
    gaps_out  = 10    # gap from monitor edges
    border_size = 2   # border width in pixels
}

decoration {
    rounding = 10     # corner radius (0 = square windows)

    blur {
        enabled = true
        size    = 6       # blur radius
        passes  = 3       # quality (more = smoother, heavier)
    }

    shadow {
        enabled     = true
        range       = 20  # shadow spread
        render_power = 3  # sharpness
    }
}
```

### Remove all gaps (tiling purist)

```ini
general {
    gaps_in  = 0
    gaps_out = 0
}
```

### Disable blur (performance)

```ini
decoration {
    blur { enabled = false }
}
```

---

## Animations

Edit `~/.config/hypr/animations.conf`.

### Disable all animations

```ini
animations {
    enabled = false
}
```

### Change workspace transition style

```ini
# Options: slide, slidevert, fade, slidefadevert, popin
animation = workspaces, 1, 5, easeOutQuint, slidevert
```

### Make animations faster

Reduce the duration value (3rd argument) on each line:

```ini
animation = windowsIn,  1, 2,  easeOutQuint, slide   # was 4
animation = workspaces, 1, 3,  easeOutQuint, slide   # was 5
```

---

## Waybar Modules

Edit `~/.config/waybar/config.jsonc`.

### Add a module to a section

```jsonc
"modules-right": [
    "cpu",
    "memory",
    "custom/mymodule",   // ← add here
    ...
]
```

Then define it:

```jsonc
"custom/mymodule": {
    "exec":    "echo 'hello'",
    "format":  "  {}",
    "interval": 5,
    "tooltip": false
}
```

### Remove a module

Delete its name from `modules-left/center/right` and optionally delete
its definition block.

### Move the clock to the right

```jsonc
"modules-left":   ["custom/launcher", "hyprland/workspaces", "hyprland/window"],
"modules-center": ["custom/cava", "custom/nowplaying"],
"modules-right":  ["clock", "cpu", "memory", ...]
```

---

## Autostart Applications

Edit `~/.config/hypr/autostart.conf`.

```ini
# Start your app once at login
exec-once = your-app

# Start and restart on config reload
exec = your-persistent-daemon

# Delayed start (wait 2 seconds for compositor to settle)
exec-once = sleep 2 && your-app
```

Common additions:

```ini
# Clipboard manager (already included)
exec-once = wl-paste --watch cliphist store

# Kanshi (automatic monitor layout)
exec-once = kanshi

# KDE Connect
exec-once = kdeconnectd

# Syncthing
exec-once = syncthing --no-browser
```

---

## Shell Aliases

### Fish — add to `~/.config/fish/config.fish`

```fish
# Custom abbreviations (expand on Space)
abbr --add myalias 'my long command here'

# Custom functions
function myfunction
    echo "hello from fish"
end
```

### Zsh — add to `~/.zshrc` (after the zinit section)

```zsh
# Aliases
alias myalias='my long command here'

# Functions
myfunction() {
    echo "hello from zsh"
}
```

Both shells source their config without a restart:

```bash
# Fish
reload    # abbreviation for: source ~/.config/fish/config.fish

# Zsh
reload    # alias for: source ~/.zshrc
```
