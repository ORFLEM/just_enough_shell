![last_commit](https://img.shields.io/github/last-commit/ORFLEM/orflem_nixos_configs?&style=for-the-badge&color=bbbbbb&label=Last%20Commit&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![repo_size](https://img.shields.io/github/repo-size/ORFLEM/orflem_nixos_configs?color=cccccc&label=Repo%20Size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

<div align="center">
	<img src="./images/preview.webp" width="900px">
	<h1>Just Enough Shell</h1>
	<p>Created for everyday, not show.</p>
</div>

***

<table align="right">
	<tr>
		<td colspan="2" align="center">System Info</td>
	</tr>
	<tr>
		<th>Component</th>
		<th>Value</th>
	</tr>
	<tr>
		<td>OS</td>
		<td>NixOS 25.11</td>
	</tr>
	<tr>
		<td>WM</td>
		<td>swayfx</td>
	</tr>
	<tr>
		<td>Shell</td>
		<td>bash</td>
	</tr>
	<tr>
		<td>Terminal</td>
		<td>Foot</td>
	</tr>
	<tr>
		<td>Interface</td>
		<td>QuickShell</td>
	</tr>
	<tr>
		<td>Screen Locker</td>
		<td>Hyprlock</td>
	</tr>
	<tr>
		<td>Monitoring</td>
		<td>Btop</td>
	</tr>
	<tr>
		<td>Audio</td>
		<td>PipeWire</td>
	</tr>
	<tr>
		<td>Browser</td>
		<td>Zen browser</td>
	</tr>
	<tr>
		<td>File Manager</td>
		<td>ranger / yazi / dolphin</td>
	</tr>
	<tr>
		<td>Editor</td>
		<td>micro / helix</td>
	</tr>
	<tr>
		<td>Theme</td>
		<td>zenburn</td>
	</tr>
	<tr>
		<td>Icons</td>
		<td>Tela Gray</td>
	</tr>
	<tr>
		<td>Bootloader</td>
		<td>Grub</td>
	</tr>
	<tr>
		<td>Optimization</td>
		<td>Go binaries</td>
	</tr>
	<tr>
		<td>Accent changer</td>
		<td>wallust</td>
	</tr>
</table>

<div align="left">
	<h3>-- About --:</h3>
	<p>
	<i>JES</i> uses <b>QuickShell</b> for rendering the interface.<br>
	<br>
	<b>SwayFX</b> is currently supported. Work is in progress on <b>Hyprland and Niri</b>.<br>
	By editing 3 stub scripts, this interface can run on any Wayland tiling compositor that supports subscribe protocols for workspace, active window, and keyboard layout data.<br>
	<br>
	The project includes optimization but has not been tested on low-end hardware.<br>
	Go binaries handle data-heavy logic by subscribing to system events rather than polling — this drops idle CPU usage from 35–45% down to 5–7%.<br>
	<br>
	<i>JES</i> is designed for UWQHD (3440x1440) monitors. Tested resolutions: QHD (2560x1440) and above.<br>
	At these resolutions the bar has no layout issues.<br>
	<br>
	<i>JES is built for everyday practicality, not trends.</i><br>
	</p>
	<h3>-- Roadmap --:</h3>
	<p>
	<b>[i]</b> Hyprland support<br>
	<b>[p]</b> Niri support<br>
	<b>[p]</b> Setup installer<br>
	<b>[p]</b> Weather widget<br>
	<b>[p]</b> Calendar widget<br>
	c = completed; n = not completed; i = in progress; p = planned.<br>
	</p>
</div>

> [!WARNING]
> **These configs are intended for DESKTOP use only.**
> - Includes opinionated or conservative choices (bash over fish/zsh, SwayFX as primary WM).
> - SwayFX gets updates first — it's my daily driver and the project is tied to my personal workflow.
> - Only **static** wallpapers are included. Screenshots may look different due to different wallpapers.
> - Fully tested on UWQHD (3440x1440) monitors and displays from QHD and above. May behave differently at other resolutions.
> - The base theme is fixed. Only the accent color is pulled from the wallpaper.

```
Live wallpapers are supported — video wallpapers and shaders are both available (shaders may be unstable).
```
#### **Wallpapers from screenshots**: [here](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [Structure *JES*](./structure_eng.md)

## -- Keybindings --:
| Keybind | Action |
| :--- | :---: |
| `super + e` | file manager |
| `super + q` | terminal |
| `super + o` | power menu |
| `super + 1` or `super + scroll up/down` | switch workspaces |
| `super + shift + 1` or `super + shift + arrows` | move window to workspace |
| `super + RMB` | resize window |
| `super + shift + arrows` or `super + LMB` | move window |
| `super + arrows` | focus window |
| `super + alt + LMB` | toggle floating / tiling |
| `super + w` | restart interface |
| `super + s` | fullscreen screenshot |
| `super + d` | area screenshot |
| `super` | app launcher |
| `super + g` | create group |
| `super + ctrl + g` | ungroup windows |
| `super + tab` | previous workspace |
| `capslock` or `shift + alt` | switch keyboard layout |
| `shift + capslock` | toggle caps lock |
| `super + space` | float window on top |
| `ctrl + /` | play / pause music |
| `ctrl + .` | next track |
| `ctrl + ,` | previous track |
| `alt + pgup` | increase brightness |
| `alt + pgdn` | decrease brightness |
| `alt + F9` | mute |
| `alt + F10` | volume down |
| `alt + F11` | volume up |
| `alt + F12` | open / close player |

## -- How *JES* looks --:
### Desktop
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Control panel
![alt_image](./images/3.webp)

### Wallpaper picker
![alt_image](./images/4.webp)

### Player
![alt_image](./images/5.webp)
![alt_image](./images/6.webp)

### Power menu
![alt_image](./images/7.webp)

### Fastfetch
![alt_image](./images/8.webp)

### Volume / brightness popup
![alt_image](./images/9.webp)

### App launcher
![alt_image](./images/10.webp)

### Lock screen
![alt_image](./images/11.webp)
![alt_image](./images/12.webp)

## -- Installation --:
```
1. Install NixOS
2. Back up system files (sudo mkdir -p /etc/nixos/backups && sudo cp /etc/nixos/* /etc/nixos/backups/*.backup)
3. Move the config to "/etc/nixos" (sudo cp ./*.nix /etc/nixos/)
4. Back up your user configs (cp -r ~/.config/ ~/backups/)
5. Adjust the NixOS config for your setup — set your username in "USER ACCOUNT", locale and region in "LOCALISATION", and additional drives in "FILESYSTEMS" (if any)
6. Copy files from ".config/" to "~/.config" and from ".local/" to "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/)
7. sudo nixos-rebuild switch
```

## -- License --:
Notifications were taken from the [blxshell](https://github.com/binarylinuxx/dots) project and reworked both visually and partially technically. Original license unknown.

These configs are distributed under **GNU GPL v3**.

In plain terms:
- You are free to use, study, and modify this code.
- If you share your changes or anything built on top of this (e.g. a fork), you **must** make your source code open and available under the same license.

This ensures all improvements and derivative works remain free and open, just like the original.

Full license text: [LICENSE](./LICENSE).

[![boosty](https://img.shields.io/badge/Support_on_Boosty-8b3d30?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)

##### Created by \_ORFLEM\_
