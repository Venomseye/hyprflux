# HyprFlux — Keybind Reference

Complete list of all keyboard and mouse bindings.
`Super` = Windows / Meta key.

---

## Core

| Keybind | Action |
|---|---|
| `Super + Return` | Open terminal (kitty) |
| `Super + Space` | App launcher (Rofi drun) |
| `Super + R` | Run command (Rofi run) |
| `Super + E` | File manager (Nautilus) |
| `Super + B` | Browser |
| `Super + Q` | Close focused window |
| `Super + Shift + Q` | Force kill focused window |
| `Super + Shift + R` | Reload Hyprland config |
| `Super + Shift + Escape` | Exit Hyprland (emergency) |
| `Super + Shift + E` | Power menu |
| `Super + Delete` | Lock screen |

---

## Windows — Focus

| Keybind | Action |
|---|---|
| `Super + H` | Focus left |
| `Super + J` | Focus down |
| `Super + K` | Focus up |
| `Super + L` | Focus right |
| `Super + Left` | Focus left |
| `Super + Down` | Focus down |
| `Super + Up` | Focus up |
| `Super + Right` | Focus right |
| `Alt + Tab` | Cycle focus forward |
| `Alt + Shift + Tab` | Cycle focus backward |
| `Super + U` | Focus urgent window |

## Windows — Move

| Keybind | Action |
|---|---|
| `Super + Shift + H/J/K/L` | Move window in direction |
| `Super + Shift + Arrow` | Move window in direction |

## Windows — Resize

| Keybind | Action |
|---|---|
| `Super + Ctrl + H` | Shrink width |
| `Super + Ctrl + L` | Grow width |
| `Super + Ctrl + K` | Shrink height |
| `Super + Ctrl + J` | Grow height |
| `Super + Ctrl + Arrow` | Resize (arrow variant) |

## Windows — State

| Keybind | Action |
|---|---|
| `Super + F` | Toggle float |
| `Super + Alt + F` | Pin floating window on top |
| `Super + C` | Centre floating window |
| `Super + M` | Real fullscreen |
| `Super + Alt + M` | Maximise (keep gaps) |
| `Super + P` | Toggle pseudotile (dwindle) |
| `Super + T` | Toggle split direction (dwindle) |
| `Super + Shift + M` | Swap with master (master layout) |

## Windows — Groups (Tabs)

| Keybind | Action |
|---|---|
| `Super + G` | Toggle group |
| `Super + Tab` | Next tab in group |
| `Super + Shift + Tab` | Previous tab in group |
| `Super + Alt + H/J/K/L` | Move window into group |
| `Super + Alt + U` | Move window out of group |

## Windows — Mouse

| Keybind | Action |
|---|---|
| `Super + LMB` (drag) | Move floating window |
| `Super + RMB` (drag) | Resize window |

---

## Workspaces — Navigate

| Keybind | Action |
|---|---|
| `Super + 1–0` | Switch to workspace 1–10 |
| `Super + [` | Previous workspace |
| `Super + ]` | Next workspace |
| `Super + ,` | Previous workspace |
| `Super + .` | Next workspace |
| `Super + grave` | Toggle last two workspaces |
| `Super + S` | Toggle scratchpad |

## Workspaces — Move Windows

| Keybind | Action |
|---|---|
| `Super + Shift + 1–0` | Move window to workspace 1–10 |
| `Super + Ctrl + Shift + 1–0` | Move silently (stay on current workspace) |
| `Super + Shift + S` | Send to scratchpad |
| `Super + Shift + >` | Move workspace to right monitor |
| `Super + Shift + <` | Move workspace to left monitor |

---

## Media & Hardware

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume −5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness −5% |
| `XF86AudioPlay` | Play / pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioStop` | Stop |

---

## Screenshots

| Keybind | Action | Output |
|---|---|---|
| `Print` | Full screen capture | File + clipboard |
| `Shift + Print` | Region select → swappy | File + clipboard |
| `Super + Print` | Active window | File + clipboard |
| `Ctrl + Print` | Region select | Clipboard only |

Screenshots are saved to `~/Pictures/Screenshots/`.

---

## Desktop Utilities

| Keybind | Action |
|---|---|
| `Super + W` | Wallpaper picker |
| `Super + Shift + W` | Random wallpaper |
| `Super + Shift + T` | Cycle theme |
| `Super + N` | Toggle notification centre |
| `Super + V` | Clipboard history (cliphist + Rofi) |
| `Super + Shift + C` | Colour picker (hyprpicker) |
| `Super + Ctrl + S` | SSH session picker (Rofi) |
| `Super + grave` | Window switcher (Rofi) |

---

## Rofi Menus

| Keybind | Action |
|---|---|
| `Super + Space` | App launcher |
| `Super + R` | Run command |
| `Super + grave` | Window switcher |
| `Super + Ctrl + S` | SSH picker |

---

## Waybar Interactions

| Module | Left click | Right click | Scroll |
|---|---|---|---|
| Workspaces | Activate | — | Switch workspace |
| Volume | Mute toggle | pavucontrol | ±2% |
| Microphone | Mute toggle | pavucontrol | — |
| Backlight | — | — | ±5% brightness |
| Network | NM Editor | nmtui | — |
| Bluetooth | blueman | rfkill toggle | — |
| Now playing | Play/pause | Next track | Next/prev |
| Clock | Toggle format | Toggle calendar | — |
| CPU / RAM | btop | — | — |
| Notifications | Toggle centre | Toggle DND | — |

---

## Inside Rofi

| Key | Action |
|---|---|
| `Type` | Filter results |
| `↑ / ↓` | Navigate |
| `Ctrl + P / N` | Navigate (Emacs style) |
| `Return` | Launch / select |
| `Shift + Return` | Launch in terminal |
| `Escape` | Close |
| `Super + Space` | Close (alternate) |
| `Ctrl + A` | Move to start of input |
| `Ctrl + E` | Move to end of input |
| `Ctrl + W` | Delete word |
| `Ctrl + BackSpace` | Delete word backward |
| `Page Up/Down` | Page through results |

---

## Inside kitty

| Key | Action |
|---|---|
| `Ctrl + Shift + C` | Copy |
| `Ctrl + Shift + V` | Paste |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + W` | Close tab |
| `Ctrl + Shift + Right/Left` | Next / previous tab |
| `Ctrl + Shift + Enter` | New window (split) |
| `Ctrl + Shift + ]` / `[` | Next / previous window |
| `Ctrl + Shift + =` | Font size up |
| `Ctrl + Shift + -` | Font size down |
| `Ctrl + Shift + 0` | Reset font size |
| `Ctrl + Shift + K/J` | Scroll up / down |
| `Ctrl + Shift + Home/End` | Scroll to top / bottom |
| `Ctrl + Shift + U` | Unicode input |
| `Ctrl + Shift + F2` | Edit kitty.conf |
| `Ctrl + Shift + Delete` | Clear terminal |
| `Ctrl + Shift + F11` | Toggle fullscreen |
