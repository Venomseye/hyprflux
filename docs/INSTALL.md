# HyprFlux — Detailed Installation Guide

This document covers every installation scenario in depth.
For the quick path, see the main [README](../README.md).

---

## Table of Contents

1. [Before You Begin](#before-you-begin)
2. [Fresh Arch Install](#fresh-arch-install)
3. [Running the Installer](#running-the-installer)
4. [Display Manager Setup](#display-manager-setup)
5. [Starting Without a Display Manager](#starting-without-a-display-manager)
6. [GPU-Specific Setup](#gpu-specific-setup)
7. [Post-Install Checklist](#post-install-checklist)
8. [Re-running the Installer](#re-running-the-installer)

---

## Before You Begin

Ensure your system meets these conditions before running the installer:

```bash
# Verify Arch Linux
cat /etc/arch-release

# Verify internet access
ping -c 2 archlinux.org

# Verify sudo access
sudo true

# Verify you are NOT root
echo "Running as: $USER (UID=$UID)"
# UID should NOT be 0
```

### Required baseline packages

The installer handles everything, but your base system should have at minimum:

```bash
sudo pacman -S --needed base-devel git curl
```

---

## Fresh Arch Install

If you are starting from a minimal Arch installation (just booted the ISO
and ran `archinstall` or installed manually):

```bash
# 1. Verify you have a non-root user
whoami        # should NOT be root
id            # should show your user

# 2. Make sure base-devel is installed (needed to build AUR packages)
sudo pacman -S --needed base-devel git

# 3. Clone HyprFlux
git clone https://github.com/yourusername/hyprflux.git
cd hyprflux

# 4. Run
./install.sh
```

The installer will bootstrap `yay` (AUR helper) automatically if it isn't present.

---

## Running the Installer

### Interactive (recommended)

```bash
./install.sh
```

You will be prompted to:
- Authenticate with sudo (once)
- Select optional packages from a checklist
- Choose your default shell (Fish / Zsh / keep current)

### Flags

| Flag | Effect |
|---|---|
| `--yes` | Skip all confirmation prompts |
| `--skip-optional` | Skip optional package selection entirely |
| `--skip-backup` | Do not back up existing configs |
| `--help` | Show usage |

### Example: automated install on a CI / second machine

```bash
./install.sh --yes --skip-optional
```

### Install log

Every run writes a complete log to:
```
hyprflux/install.log
```

If something fails, check here first.

---

## Display Manager Setup

### SDDM (recommended)

```bash
sudo pacman -S sddm
sudo systemctl enable sddm
```

SDDM will automatically detect Hyprland from its `.desktop` file at
`/usr/share/wayland-sessions/hyprland.desktop` (installed with the
`hyprland` package). Select **Hyprland** from the session menu at login.

### GDM (GNOME Display Manager)

```bash
sudo pacman -S gdm
sudo systemctl enable gdm
```

GDM supports Wayland sessions. Select **Hyprland** from the gear icon
on the login screen.

### LightDM

```bash
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
```

LightDM will list Hyprland as a Wayland session option.

---

## Starting Without a Display Manager

If you prefer to start Hyprland from a TTY (no display manager):

```bash
# Log in at TTY1 (Ctrl+Alt+F1)
# Then simply run:
Hyprland
```

To autostart Hyprland when you log into TTY1, add this to your shell profile:

### For Fish (`~/.config/fish/config.fish`):

```fish
# Auto-start Hyprland on TTY1 login
if status is-login
    if test (tty) = /dev/tty1
        exec Hyprland
    end
end
```

### For Zsh (`~/.zprofile`):

```zsh
# Auto-start Hyprland on TTY1 login
if [[ "$(tty)" == "/dev/tty1" ]]; then
    exec Hyprland
fi
```

### For Bash (`~/.bash_profile`):

```bash
# Auto-start Hyprland on TTY1 login
if [[ "$(tty)" == "/dev/tty1" ]]; then
    exec Hyprland
fi
```

---

## GPU-Specific Setup

### AMD (no extra steps needed)

AMD GPUs work out of the box with the open-source `amdgpu` driver.
For best performance, ensure the Vulkan driver is installed:

```bash
sudo pacman -S vulkan-radeon libva-mesa-driver
```

### Intel (no extra steps needed)

Intel integrated graphics work out of the box.
For hardware video acceleration:

```bash
sudo pacman -S intel-media-driver libva-intel-driver
```

If you experience tearing or rendering glitches, add to
`~/.config/hypr/environment.conf`:

```ini
env = WLR_DRM_NO_ATOMIC,1
```

### NVIDIA (requires extra configuration)

NVIDIA support on Wayland requires the proprietary driver and kernel parameters.

**Step 1: Install the proprietary driver**

```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings
# Or for older cards:
sudo pacman -S nvidia-470xx-dkms  # check AUR for your specific series
```

**Step 2: Enable DRM kernel mode-setting**

Add to your bootloader kernel parameters:

```
nvidia-drm.modeset=1
```

For GRUB, edit `/etc/default/grub`:
```
GRUB_CMDLINE_LINUX_DEFAULT="... nvidia-drm.modeset=1"
```
Then run: `sudo grub-mkconfig -o /boot/grub/grub.cfg`

**Step 3: Add environment variables**

Uncomment or add these in `~/.config/hypr/environment.conf`:

```ini
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = NVD_BACKEND,direct
env = ELECTRON_OZONE_PLATFORM_HINT,wayland
```

**Step 4: Add kernel modules to initramfs**

Edit `/etc/mkinitcpio.conf`:
```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```
Then run: `sudo mkinitcpio -P`

**Step 5: Reboot**

```bash
sudo reboot
```

See the full [Hyprland NVIDIA wiki page](https://wiki.hyprland.org/Nvidia/)
for troubleshooting.

---

## Post-Install Checklist

After running `./install.sh` and logging into Hyprland, verify:

- [ ] **Compositor loads** — you see the desktop with Waybar at the top
- [ ] **Wallpaper appears** — if not, run `wallpaper random`
- [ ] **Waybar is visible** — all modules show values
- [ ] **Audio works** — press volume keys, OSD notification appears
- [ ] **Notifications work** — run `notify-send "Test" "HyprFlux is working"`
- [ ] **Terminal opens** — press `Super + Return`
- [ ] **Launcher opens** — press `Super + Space`
- [ ] **Screenshots work** — press `Print` key
- [ ] **CAVA visualizer** — play music, watch the bars in Waybar centre
- [ ] **Theme switch** — press `Super + Shift + T` to cycle themes

### Setting your wallpaper

```bash
# Add wallpapers to:
~/Pictures/Wallpapers/

# Then open the picker:
# Super + W
```

### Setting your browser

Edit `~/.config/hypr/keybinds.conf`:

```ini
$browser = firefox   # change to: chromium, brave, etc.
```

Reload with `Super + Shift + R`.

---

## Re-running the Installer

The installer is safe to re-run. It will:

1. Create a **new timestamped backup** of your current HyprFlux configs
2. Overwrite configs with the latest versions from the repo
3. Skip packages that are already installed (`--needed` flag)
4. Re-apply the active theme

```bash
cd ~/hyprflux
git pull
./install.sh
```

Your **personal customisations** (monitor layout, custom keybinds, wallpapers)
will be backed up to `~/.config/hyprflux-backup/<timestamp>/` before being overwritten.
To keep customisations permanent, keep them in a fork of this repo.
