![](https://img.shields.io/github/last-commit/ORFLEM/My-NixOS-Hyprland-eww-configs?&style=for-the-badge&color=bbbbbb&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![](https://img.shields.io/github/repo-size/ORFLEM/My-NixOS-Hyprland-eww-configs?color=cccccc&label=Project%20size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

# Important
```
These configs are for a DESKTOP computer!!

Hyprland WITHOUT modifications will work ONLY on NixOS; the hy3 plugin is NOT available in the ALT Linux repository!

All new features are released in the Russian localization first, as my English proficiency is limited and supporting it is challenging for me!!!

These configs include controversial choices that not everyone may like:
  using NixOS without Home Manager;
  bash instead of fish;
  swaybg and mpvpaper;
  strange ideas in keybindings and UI;
  using Go binaries for optimization;
But these are customizable.
```

# About the Configs
```
These configs are built on eww and rofi.

Sway and Hyprland are available, but Sway is more stable and optimized, and I'm currently using it - its config will 100% work. With Hyprland you might need to tweak things. I recommend Sway.

I tried to see if I could create the entire UI using only eww and rofi without heavily impacting performance, but I can't say for sure about weaker PCs since my PC is quite powerful.

Please don't judge too harshly.
```

## -- Core Software -- :
* Tiling: `Hyprland | swayfx` (niri support temporarily discontinued, reasons: poor understanding of config and incomplete replacement of rofi with eww launcher)
* Terminal: `Kitty`
* Launcher: `Rofi` (being replaced with eww, available for testing but currently not working - help appreciated!)
* Screen Locker: `Hyprlock`
* System Monitoring: `Btop | htop` (also available in dashboard)
* Interface: `eww`
* File Manager: `ranger | yazi | thunar | pcmanfm`
* Editors: `micro | helix`
* Shells: `bash | fish`
* Wallpaper: `mpvpaper | swaybg` (hyprpaper replaced with swaybg due to flickering on AMD cards; working on adding hyprlax, current blocker: manual package building)
* Main theme for terminals, GTK, etc.: `adw-gtk3`; TTY: `kanagawa` + matugen support for eww, with GTK support coming later (work in progress)
* Icons: `Tela Nord`

```
If you want animated video wallpapers, use zoom or no-zoom modes in wallpaper picker, and stat mode for static images.
```

```
Testing a new mini player type in the bar that uses album artwork as background.
Not sure if it's a good idea, but feel free to try it out.
```

## -- Keybindings -- :
* `Super + e` - File Manager
* `Super + q` - Terminal
* `Super + o` - Power Menu
* `Super + l` - Dashboard
* `Super + 1-0` or `Super + Scroll Up | Scroll Down` - Switch between workspaces
* `Super + Shift + 1-0` or `Super + Shift + Arrow Keys` - Move windows between workspaces
* `Super + RMB` - Resize windows
* `Super + Shift + Arrow Keys` or `Super + LMB` - Move windows
* `Super + Arrow Keys` - Switch between windows
* `Super + Alt + LMB` - Toggle window type: floating or tiling
* `Super + w` - Restart eww
* `Super + s` - Fullscreen screenshot
* `Super + d` - Selected area screenshot
* `Super` - Open application launcher
* `Super + g` - Create group
* `Super + Ctrl + g` - Ungroup windows
* `Super + Tab` - Open workspace overview
* `CapsLock` or `Shift + Alt` - Switch language
* `Shift + CapsLock` - Toggle Caps Lock
* `Super + Space` - Expand window above others
* `Ctrl + /` - Play | Pause music
* `Ctrl + >` - Next track
* `Ctrl + <` - Previous track
* `Alt + PgUp` - Increase brightness
* `Alt + PgDn` - Decrease brightness

# What the configs look like:
### Desktop
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Control Panel
![alt_image](./images/3.webp)
![alt_image](./images/4.webp)
![alt_image](./images/5.webp)

### Dashboard
![alt_image](./images/6.webp)

### Power Menu
![alt_image](./images/7.webp)

### Fastfetch
![alt_image](./images/8.webp)

### Volume and Brightness Popups
![alt_image](./images/9.webp)

### Application Launcher
![alt_image](./images/10.webp)

### Lock Screen
![alt_image](./images/11.webp)
![alt_image](./images/12.webp)

# Installation

```
1. Install NixOS.
2. Customize the NixOS config for your needs: make sure to add your user and additional disks (if any).
3. Replace the NixOS config or add missing parts to make these configs work (almost my entire config is needed).
4. Move files from the config folder to "~/.config" and from local to "~/.local".
5. Run sudo nixos-rebuild switch.
6. Good luck trying to understand the not-quite-comprehensible "genius" :)
```

#### License
The notification code (in the eww/notif folder) is written by Vimjoyer and includes their MIT license.

These configurations are distributed under the **GNU GPL v3** license.

In simple terms, this means:
- You are free to use, study, and modify this code.
- If you share your modifications or code based on this work (e.g., by forking it), you **must** make your source code equally open and available to everyone under this same license.

This ensures that all improvements and derivative works remain free and open, just like the original.

For the full license text, see the [LICENSE](./LICENSE) file.

[![boosty](https://img.shields.io/badge/support_me_on_boosty-F16061?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)
