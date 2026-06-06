<div align="center">

```
  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ███████╗██╗     ██╗   ██╗██╗  ██╗
  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║     ██║   ██║╚██╗██╔╝
  ███████║ ╚████╔╝ ██████╔╝██████╔╝█████╗  ██║     ██║   ██║ ╚███╔╝
  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██║   ██║ ██╔██╗
  ██║  ██║   ██║   ██║     ██║  ██║██║     ███████╗╚██████╔╝██╔╝ ██╗
  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
```

**A Modern · Modular · Production-Ready Hyprland Desktop for Arch Linux**

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=wayland&logoColor=black)](https://hyprland.org)
[![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=flat&logo=wayland&logoColor=black)](https://wayland.freedesktop.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Fish%20%7C%20Zsh-blue)](https://www.gnu.org/software/bash/)

</div>

---

## Overview

HyprFlux is a complete, opinionated Hyprland desktop environment distribution for Arch Linux. It ships as a single repository that installs a fully configured, visually polished Wayland desktop in one command — no manual steps required.

Designed to be **modular**, **maintainable**, and **beautiful** out of the box, while remaining easy to customise for your own workflow.

### What you get

- **Hyprland** with a fully modular, split configuration
- **Waybar** status bar with live CAVA visualizer and scrolling now-playing display
- **Rofi** launcher, window switcher, power menu, and theme selector
- **8 hand-crafted themes** — one command switches the entire desktop
- **kitty** terminal with ligatures, padding, and full Tokyo Night colours
- **Fish** and **Zsh** configured identically with aliases, fzf, zoxide, Starship
- **dunst** + **SwayNC** for notifications and a notification centre
- **wlogout** power menu with custom icons
- **Scripts** for wallpaper, volume, brightness, screenshots, screen recording, and system updates
- **GTK**, **Qt**, **icon**, and **cursor** theming that all match

---

## Screenshots

> Add your screenshots to the `screenshots/` directory and link them here.

| Desktop | Launcher | Notification Centre |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

| Theme: Catppuccin Mocha | Theme: Dracula | Theme: Nord |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

---

## Requirements

| Requirement | Details |
|---|---|
| **OS** | Arch Linux (or Arch-based: EndeavourOS, Manjaro, etc.) |
| **Display server** | Wayland (Hyprland is a Wayland-native compositor) |
| **GPU** | AMD, Intel, or NVIDIA (see [GPU Notes](#gpu-notes)) |
| **Internet** | Required during installation |
| **User** | Non-root with `sudo` privileges |
| **Disk** | ~2 GB free (packages + configs) |

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/hyprflux.git
cd hyprflux

# 2. Make the installer executable (should already be)
chmod +x install.sh

# 3. Run the installer
./install.sh
```

That is the complete installation. The installer handles everything else.

### Non-interactive install

```bash
# Install with no prompts (skips optional packages, keeps current shell)
./install.sh --yes --skip-optional

# Install and skip backing up existing configs
./install.sh --yes --skip-backup
```

### After installation

1. **Log out** of your current session
2. At your display manager, **select Hyprland** from the session list
3. Or, from a TTY, simply run: `Hyprland`

---

## Installation Details

The installer runs 15 sequential steps:

| Step | What happens |
|---|---|
| Pre-flight checks | Verifies Arch Linux, internet, sudo, repo structure |
| AUR helper | Bootstraps `yay` if absent; creates paru shim if paru is present |
| Required packages | Installs 67 packages via pacman + yay |
| Optional packages | Interactive checklist of 32 additional packages |
| Backup | Timestamped backup of all existing configs to `~/.config/hyprflux-backup/` |
| Directories | Creates all `~/.config/*` and `~/.local/*` paths |
| Configs | Copies all HyprFlux configuration files |
| Scripts | Installs scripts to `~/.local/share/hyprflux/scripts/`, symlinks to `~/.local/bin/` |
| Active theme | Symlinks `active.conf → dark.conf` (Tokyo Night Dark default) |
| XDG | Runs `xdg-user-dirs-update`, writes `hyprland-portals.conf` |
| Services | Enables PipeWire, WirePlumber, NetworkManager, Bluetooth |
| Shell | Installs Fisher + Fish plugins; prompts for default shell change |
| Wallpapers | Copies any bundled wallpapers to `~/Pictures/Wallpapers/` |
| Caches | Rebuilds font cache, icon cache, desktop database |
| Verification | Checks all critical binaries and config files exist |

### Uninstall

```bash
./uninstall.sh
```

Removes all HyprFlux config files. Packages are **not** removed. Offers to restore the most recent backup.

```bash
# Restore previous configs automatically
./uninstall.sh --restore
```

---

## Theming

HyprFlux ships with **8 hand-crafted themes**:

| Theme | Accent | Style |
|---|---|---|
| `dark` | `#7aa2f7` | Tokyo Night Dark — deep navy blues (default) |
| `catppuccin-mocha` | `#cba6f7` | Catppuccin Mocha — warm lavender pastels |
| `rose-pine` | `#c4a7e7` | Rosé Pine — dusty rose and muted gold |
| `dracula` | `#bd93f9` | Dracula — electric purple with hot pink |
| `nord` | `#88c0d0` | Nord — arctic icy blues |
| `gruvbox` | `#d79921` | Gruvbox Dark — warm vintage amber |
| `everforest` | `#a7c080` | Everforest — deep forest greens |
| `light` | `#1e66f5` | Catppuccin Latte — crisp minimal light |

### Switching themes

```bash
# Open Rofi theme picker
theme-switch select

# Cycle through all themes (Super+Shift+T)
theme-switch toggle

# Apply a specific theme directly
theme-switch set dracula
theme-switch set nord

# Check current theme
theme-switch current
```

When you switch themes, HyprFlux:
1. Updates the `~/.config/hyprflux/themes/active.conf` symlink
2. Generates a new `~/.config/waybar/colors.css`
3. Reloads Hyprland (compositor colours update instantly)
4. Restarts Waybar, Dunst, and SwayNC with the new palette
5. Updates GTK dark/light mode via gsettings

### Creating a custom theme

```bash
# Copy an existing theme as your starting point
cp ~/.config/hyprflux/themes/dark.conf ~/.config/hyprflux/themes/mytheme.conf

# Edit the accent colours, palette, and #@wb waybar variables
nvim ~/.config/hyprflux/themes/mytheme.conf

# Apply it
theme-switch set mytheme
```

---

## Wallpapers

Add wallpapers to `~/Pictures/Wallpapers/` (`.jpg`, `.jpeg`, `.png`, `.webp`).

| Action | Keybind | Command |
|---|---|---|
| Open picker | `Super + W` | `wallpaper menu` |
| Random wallpaper | `Super + Shift + W` | `wallpaper random` |
| Apply specific file | — | `wallpaper set ~/Pictures/Wallpapers/my.jpg` |

The wallpaper picker shows 3-column thumbnail grid via Rofi. Your last wallpaper is restored automatically on login.

---

## Keybinds

### Core

| Keybind | Action |
|---|---|
| `Super + Return` | Open terminal (kitty) |
| `Super + Space` | App launcher (Rofi) |
| `Super + Q` | Close focused window |
| `Super + Shift + Q` | Force kill focused window |
| `Super + Shift + R` | Reload Hyprland config |
| `Super + Shift + E` | Power menu |
| `Super + Delete` | Lock screen (hyprlock) |

### Windows

| Keybind | Action |
|---|---|
| `Super + H/J/K/L` | Move focus (vim-style) |
| `Super + Arrow keys` | Move focus (arrow keys) |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + Ctrl + H/J/K/L` | Resize window (hold to repeat) |
| `Super + F` | Toggle float |
| `Super + M` | Toggle fullscreen |
| `Super + Alt + M` | Maximise (keep gaps) |
| `Super + C` | Centre floating window |
| `Super + Alt + F` | Pin window on top |
| `Super + P` | Toggle pseudotile (dwindle) |
| `Super + T` | Toggle split direction |
| `Super + G` | Toggle group (tab container) |
| `Super + Tab` | Cycle group tabs forward |
| `Super + U` | Focus urgent window |
| `Super + LMB` (drag) | Move window |
| `Super + RMB` (drag) | Resize window |

### Workspaces

| Keybind | Action |
|---|---|
| `Super + 1–0` | Switch to workspace 1–10 |
| `Super + Shift + 1–0` | Move window to workspace 1–10 |
| `Super + Ctrl + Shift + 1–0` | Move window silently |
| `Super + [` / `Super + ]` | Previous / next workspace |
| `Super + grave` | Toggle between last two workspaces |
| `Super + S` | Toggle scratchpad |
| `Super + Shift + S` | Send window to scratchpad |
| `Super + Shift + >` | Move workspace to right monitor |
| `Super + Shift + <` | Move workspace to left monitor |

### Media & Hardware

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Brightness up 5% |
| `XF86MonBrightnessDown` | Brightness down 5% |
| `XF86AudioPlay` | Play / pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

### Screenshots

| Keybind | Action |
|---|---|
| `Print` | Full screen → file + clipboard |
| `Shift + Print` | Region select → annotate in swappy |
| `Super + Print` | Active window → file + clipboard |
| `Ctrl + Print` | Region select → clipboard only |

### Desktop Utilities

| Keybind | Action |
|---|---|
| `Super + W` | Wallpaper picker |
| `Super + Shift + W` | Random wallpaper |
| `Super + Shift + T` | Cycle theme |
| `Super + N` | Toggle notification centre |
| `Super + V` | Clipboard history (cliphist) |
| `Super + Shift + C` | Colour picker (hyprpicker) |
| `Super + R` | Run command (Rofi) |

---

## Waybar

The status bar is split into three sections:

**Left:** `Launcher button` · `Workspaces` · `Active window title`

**Centre:** `CAVA visualizer` · `Clock` · `Now playing`

**Right:** `CPU` · `RAM` · `Temperature` · `|` · `Network` · `Bluetooth` · `|` · `Volume` · `Mic` · `Brightness` · `|` · `Battery` · `|` · `Notifications` · `Tray`

### Now Playing + CAVA

When music is playing, the centre section shows:
- **Left of clock** — a live 8-bar CAVA audio visualizer: `▁▃▇▆▅▂▄▅`
- **Right of clock** — scrolling artist/title (20 chars visible, 0.5 s/step)
- When **paused** — CAVA shows `⏸`, title shows `⏸  Artist — Title` (static)
- When **stopped** — both modules collapse to zero width

Click the now-playing module to **play/pause**. Right-click to skip to **next track**.

### Waybar interactions

| Module | Left click | Right click | Scroll |
|---|---|---|---|
| Workspaces | Activate workspace | — | Switch workspace |
| Volume | Mute toggle | pavucontrol | ±2% volume |
| Microphone | Mute toggle | pavucontrol | — |
| Backlight | — | — | ±5% brightness |
| Network | nm-connection-editor | nmtui | — |
| Bluetooth | blueman-manager | rfkill toggle | — |
| Battery | — | powertop | — |
| Notifications | Toggle centre | Toggle DND | — |
| Now playing | Play/pause | Next track | Next/prev |
| Clock | Toggle date format | Toggle calendar mode | — |
| CPU / RAM | Open btop | — | — |

---

## Scripts

All scripts are symlinked to `~/.local/bin/` and available on `$PATH`:

```bash
wallpaper   [menu|random|restore|set <path>]
powermenu
theme-switch [toggle|select|set <name>|current]
screenshot  [full|region|window|clipboard]
record-screen [toggle|start [full]|stop|status]
volume      [up|down|mute|micmute|set <0-150>|get]
brightness  [up|down|set <0-100>|get]
update-system [--check|--quiet]
```

---

## Shell

Both Fish and Zsh are configured with identical features. Choose your preferred shell during installation, or change it later:

```bash
chsh -s $(which fish)
# or
chsh -s $(which zsh)
```

### Shared aliases

```bash
# Navigation
..  ...  ....          # cd up 1/2/3 levels
dl  dt  dc             # Downloads, Desktop, Documents

# Listing (eza if installed, else ls)
ls  ll  la  lt         # various listing formats

# Editor
v   vi   vim   nv      # all → nvim

# Git
g ga gaa gc gcm gco gcb gd gds gl gp gpl gst

# Pacman
pac pacs pacr pacu pacq pacss

# HyprFlux
wallpaper  theme  update  screenshot
```

### Functions (both shells)

```bash
mkcd <dir>        # mkdir + cd in one
extract <file>    # extract any archive format
fcd               # fuzzy cd with fzf preview
gig <lang,...>    # generate .gitignore from gitignore.io
```

---

## Configuration Files

```
~/.config/
├── hypr/                    # Hyprland (10 modular files)
│   ├── hyprland.conf        # Root — sources all modules
│   ├── theme.conf           # Sources active theme
│   ├── environment.conf     # Wayland/Qt/GTK env vars
│   ├── monitors.conf        # Display configuration
│   ├── input.conf           # Keyboard, mouse, touchpad
│   ├── animations.conf      # Bezier curves and timing
│   ├── keybinds.conf        # All key bindings
│   ├── autostart.conf       # Startup daemons
│   ├── windowrules.conf     # Float/opacity/size rules
│   └── rules.conf           # Workspace assignments
├── waybar/
│   ├── config.jsonc         # Module layout
│   ├── style.css            # Stylesheet
│   └── colors.css           # Auto-generated theme colours
├── rofi/
│   ├── config.rasi          # Global settings
│   ├── launcher.rasi        # App launcher theme
│   ├── powermenu.rasi       # Power menu theme
│   ├── window-switcher.rasi # Window switcher theme
│   └── theme-selector.rasi  # Theme picker theme
├── kitty/kitty.conf         # Terminal configuration
├── dunst/dunstrc            # Notification daemon
├── swaync/                  # Notification centre
├── wlogout/                 # Power/session screen
├── fastfetch/config.jsonc   # System info display
├── fish/                    # Fish shell
├── gtk-3.0/settings.ini    # GTK 3 theming
├── gtk-4.0/settings.ini    # GTK 4 theming
├── qt5ct/qt5ct.conf        # Qt 5 theming
└── hyprflux/
    └── themes/              # Theme files + active.conf symlink
```

---

## Customisation

### Monitor setup

Edit `~/.config/hypr/monitors.conf`. Run `hyprctl monitors` to list your displays:

```ini
# Single 1440p at 144Hz
monitor = DP-1, 2560x1440@144, 0x0, 1

# Dual monitor
monitor = DP-1,    2560x1440@144, 0x0,    1
monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1

# Laptop HiDPI
monitor = eDP-1, 2560x1600@120, 0x0, 2
```

After editing, reload with `Super + Shift + R`.

### Default apps

Edit `~/.config/hypr/keybinds.conf` — the `$terminal`, `$browser`, `$filesrv`, `$editor` variables at the top:

```ini
$terminal   = kitty
$browser    = firefox
$filesrv    = nautilus
$editor     = kitty -e nvim
```

### Adding window rules

Edit `~/.config/hypr/windowrules.conf`. Find an app's class with:

```bash
hyprctl clients | grep class
# or launch the app and watch:
hyprctl -j clients | python3 -c "import json,sys; [print(c['class'],c['title']) for c in json.load(sys.stdin)]"
```

### Changing gaps and borders

Edit `~/.config/hypr/hyprland.conf`:

```ini
general {
    gaps_in   = 4    # gap between windows
    gaps_out  = 10   # gap from screen edge
    border_size = 2  # border width in pixels
}
```

### Disabling animations

Edit `~/.config/hypr/animations.conf`:

```ini
animations {
    enabled = false
}
```

---

## GPU Notes

### AMD (recommended)
Works out of the box. No extra steps needed.

### Intel
Works out of the box. If you experience tearing, add to `~/.config/hypr/environment.conf`:
```ini
env = WLR_DRM_NO_ATOMIC,1
```

### NVIDIA
Requires proprietary drivers. Add to `~/.config/hypr/environment.conf`:
```ini
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = NVD_BACKEND,direct
```

And add `nvidia-drm.modeset=1` to your kernel parameters. See the [Hyprland NVIDIA wiki](https://wiki.hyprland.org/Nvidia/) for full details.

---

## Troubleshooting

### Hyprland doesn't start

```bash
# Check the Hyprland log
cat ~/.local/share/hyprland/hyprland.log | tail -50

# Verify GPU drivers are loaded
lsmod | grep -E 'amdgpu|i915|nvidia'

# Test with a minimal config
Hyprland --config /dev/null
```

### Black screen / no wallpaper

```bash
# Verify hyprpaper is running
pgrep hyprpaper || hyprpaper &

# Check the hyprpaper config
cat ~/.config/hypr/hyprpaper.conf

# Set a wallpaper manually
wallpaper set ~/Pictures/Wallpapers/your.jpg
```

### Waybar not appearing

```bash
# Check for syntax errors in config
waybar --log-level debug 2>&1 | head -30

# Restart waybar
pkill waybar; waybar &

# Validate the JSONC config
python3 -c "
import json, re
raw = open('~/.config/waybar/config.jsonc'.replace('~', __import__('os').path.expanduser('~'))).read()
clean = re.sub(r'//[^\n]*', '', raw)
json.loads(clean)
print('OK')
"
```

### No audio

```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# List audio devices
pactl list sinks short
```

### CAVA visualizer not working

```bash
# Verify cava is installed
pacman -Q cava || sudo pacman -S cava

# Test cava standalone
cava

# Check PipeWire pulse source exists
pactl list sources short | grep monitor
```

### Rofi not launching

```bash
# Test directly
rofi -show drun -config ~/.config/rofi/launcher.rasi

# Check for theme syntax errors
rofi -show drun -config ~/.config/rofi/launcher.rasi -log-level debug
```

### Notifications not showing

```bash
# Restart dunst
pkill dunst; dunst &

# Test a notification
notify-send "Test" "Hello from HyprFlux"
```

### Bluetooth not working

```bash
# Enable the service
sudo systemctl enable --now bluetooth

# Open the manager
blueman-manager
```

### Screen recording fails

```bash
# Verify wf-recorder
pacman -Q wf-recorder || sudo pacman -S wf-recorder

# Test manually
wf-recorder -f /tmp/test.mkv
# Ctrl+C to stop
```

### Fonts look wrong / missing icons

```bash
# Rebuild font cache
fc-cache -fv

# Verify Nerd Font is installed
fc-list | grep "JetBrainsMono"

# Install if missing
sudo pacman -S ttf-jetbrains-mono-nerd
```

---

## Updating HyprFlux

```bash
# Pull the latest changes
cd ~/hyprflux
git pull

# Re-run the installer (safe to re-run — backs up before copying)
./install.sh
```

### Update system packages

```bash
# Full system update (pacman + AUR + orphan cleanup + cache prune)
update-system

# Check for updates without installing
update-system --check
```

---

## Project Structure

```
hyprflux/
├── install.sh              Main installer
├── uninstall.sh            Safe removal
├── README.md               This file
├── LICENSE                 MIT
├── assets/
│   └── hyprflux-banner.txt ASCII banner
├── configs/                All configuration files
│   ├── hypr/               Hyprland (10 files)
│   ├── waybar/             Waybar (3 files)
│   ├── rofi/               Rofi (5 files)
│   ├── kitty/              Terminal
│   ├── dunst/              Notifications
│   ├── swaync/             Notification centre
│   ├── wlogout/            Power screen
│   ├── fastfetch/          System info
│   ├── fish/               Fish shell
│   ├── zsh/                Zsh
│   ├── gtk/                GTK theming
│   ├── qt/                 Qt theming
│   └── wallpapers/         Wallpaper directory
├── docs/                   Additional documentation
├── packages/
│   ├── required.txt        67 required packages
│   └── optional.txt        32 optional packages
├── scripts/                10 utility scripts
└── themes/                 8 colour themes
```

---

## Dependencies

### Core (required — 67 packages)

Hyprland, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk, wayland-protocols, qt5-wayland, qt6-wayland, hyprlock, hypridle, hyprpaper, hyprpicker, hyprcursor, waybar, rofi-wayland, kitty, fish, zsh + plugins, starship, dunst, libnotify, grim, slurp, swappy, wf-recorder, pipewire stack, wireplumber, pavucontrol, playerctl, networkmanager + applet, bluez + blueman, brightnessctl, upower, wl-clipboard, cliphist, polkit-gnome, xdg-user-dirs, imagemagick, jq, bc, curl, socat, python, cava, fastfetch, nwg-look, qt5ct, qt6ct, kvantum, papirus-icon-theme, xcursor-themes, bibata-cursor-theme (AUR), swaynotificationcenter (AUR), wlogout (AUR), nerd fonts.

### Optional (32 packages)

Nautilus + plugins, neovim, code, imv, mpv, vlc, zathura, firefox, chromium, libreoffice, thunderbird, btop, nvtop, git, docker, swww (AUR), vesktop (AUR), extra fonts.

---

## Credits & Inspiration

HyprFlux is an original project, but draws design inspiration from the broader Hyprland community:

- [ML4W](https://github.com/mylinuxforwork/dotfiles) — installation system design philosophy
- [HyDE](https://github.com/prasanthrangan/hyprdots) — theme switching architecture ideas
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) — default colour palette
- [Catppuccin](https://github.com/catppuccin/catppuccin) — Mocha and Latte palettes
- [Rosé Pine](https://github.com/rose-pine/rose-pine-theme) — rose-pine palette
- [Dracula](https://github.com/dracula/dracula-theme) — dracula palette
- [Nord](https://github.com/nordtheme/nord) — nord palette
- [Gruvbox](https://github.com/morhetz/gruvbox) — gruvbox palette
- [Everforest](https://github.com/sainnhe/everforest) — everforest palette
- The [Hyprland wiki](https://wiki.hyprland.org) and its contributors

---

## License

MIT License — see [LICENSE](LICENSE) for full text.

```
Copyright (c) 2024 HyprFlux Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

<div align="center">

**Made with ❤️ for the Hyprland community**

*If HyprFlux helps you, consider starring the repository ⭐*

</div>
