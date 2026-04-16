![last_commit](https://img.shields.io/github/last-commit/ORFLEM/orflem_nixos_configs?&style=for-the-badge&color=bbbbbb&label=Last%20commit&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![repo_size](https://img.shields.io/github/repo-size/ORFLEM/orflem_nixos_configs?color=cccccc&label=Project%20size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

<div align="center">
	<img src="./images/preview.webp" width="900px">
	<h1>My NixOS Configs</h1>
	<p><b>NixOS</b> configurations for a desktop environment based on <b>quickshell</b>, <b>swayfx</b> with a custom interface for ultrawide monitors (21:9) and optimisation via <b>Go binaries</b>.</p>
</div>

***

<table align="right">
	<tr>
		<td colspan="2" align="center">System parameters</td>
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
		<td>quickshell</td>
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
		<td>Optimisation</td>
		<td>Go binaries</td>
	</tr>
	<tr>
		<td>Accent changer</td>
		<td>wallust</td>
	</tr>
</table>

<div align="left">
	<h3>-- About the project -- :</h3>
	<p>
  These configs are built on Quickshell.<br>
  <br>
  <b>SwayFX</b> is available, and work is underway to add support for <b>Hyprland and Niri</b>.<br>
  By editing 3 stub scripts, you can also run this interface on any Wayland tiling WM that supports the subscribe protocols for workspace data, active window and keyboard layout.<br>
  <br>
  I tried to see if I could create the entire UI only with <b>Quickshell</b> without heavily impacting performance.<br>
  But I can't say for sure about weaker PCs, since my PC is quite powerful.<br>
  Go binaries are used for scripts where fast reading of a large data stream matters — CPU load in idle is now around 5–7%, previously it was 35–45%.<br>
  <br>
  The project is not trend-oriented, but focused on everyday practicality and convenience.<br>
	</p>
	<h3>-- Future plans -- :</h3>
	<p>
	<b>[i]</b> Add support for <b>Hyprland</b><br>
  <b>[p]</b> Add support for <b>Niri</b><br>
  <b>[p]</b> Create a config installer<br>
	<b>[p]</b> Create a weather widget<br>
	<b>[p]</b> Create a calendar widget<br>
	c = completed; n = not complited; i = in progress; p = planned.<br> 
	</p>
</div>

>[!WARNING]
> **These configurations are intended for a DESKTOP computer!**
> - These configs include controversial or conservative choices (bash instead of fish/zsh, priority on SwayFX)
> - The freshest updates will arrive on SwayFX first, as it is my primary WM and the project is tightly tied to my daily use.
> - Configs include **static wallpapers only** — visuals may differ from what you see in screenshots due to different wallpapers!
> - All settings are confirmed to work on ultrawide (21:9) monitors or monitors with a resolution wider than 3440px; other resolutions may work worse.
> - The main theme is fixed; only the accent colour is pulled from the wallpaper.

```
If you want live video wallpapers, you can choose between video wallpapers and shaders (the latter may work poorly)
```

## -- Keybindings -- :
| Keybinding | Action |
| :--- | :---: |
| `super + e` | file manager |
| `super + q` | terminal |
| `super + o` | power menu |
| `super + 1` or `super + scroll up \| scroll down` | switch between workspaces |
| `super + shift + 1` or `super + shift + arrow keys` | move windows between workspaces |
| `super + RMB` | resize windows |
| `super + shift + arrow keys` or `super + LMB` | move windows |
| `super + arrow keys` | switch between windows |
| `super + alt + LMB` | toggle window type: floating or tiling |
| `super + w` | restart interface |
| `super + s` | full‑screen screenshot |
| `super + d` | selected area screenshot |
| `super` | open application launcher |
| `super + g` | create a group |
| `super + ctrl + g` | ungroup windows |
| `super + tab` | previous workspace |
| `capslock` or `shift + alt` | switch language |
| `shift + capslock` | toggle Caps Lock |
| `super + space` | expand window above others |
| `ctrl + /` | play / pause music |
| `ctrl + .` | next track |
| `ctrl + ,` | previous track |
| `alt + pgup` | increase brightness |
| `alt + pgdn` | decrease brightness |
| `alt + F9` | mute audio |
| `alt + F10` | volume down |
| `alt + F11` | volume up |
| `alt + F12` | open / close media player |

# What the configs look like:
### Desktop
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Control Panel
![alt_image](./images/3.webp)

### Wallpaper picker
![alt_image](./images/4.webp)

### Media player
![alt_image](./images/5.webp)
![alt_image](./images/6.webp)

### Power Menu
![alt_image](./images/7.webp)

### fastfetch
![alt_image](./images/8.webp)

### Volume and brightness popups
![alt_image](./images/9.webp)

### Application Launcher
![alt_image](./images/10.webp)

### Lock screen
![alt_image](./images/11.webp)
![alt_image](./images/12.webp)

# Installation
```
1. Install NixOS.
2. Customise the NixOS config to your needs: remember to add your user and any additional disks.
3. Replace the NixOS config or add the missing parts to make these configs work (almost my entire config is needed).
4. Move the files from the config folder to "~/.config" and from local to "~/.local".
5. Run sudo nixos-rebuild switch.
6. Good luck trying to understand the author's logic :)
```

#### License
The notifications were taken from the [blxshell](https://github.com/binarylinuxx/dots) project and modernised both visually and partly technically; the license is unknown.

These configurations are distributed under the **GNU GPL v3** license.

In simple terms, this means:
- You are free to use, study, and modify this code.
- If you share your modifications or code based on this work with others (e.g., by publishing a fork), you **must** make your source code equally open and available to everyone under this same license.

This ensures that all improvements and derivative works remain free and open, just like the original.

For the full license text, see the [LICENSE](./LICENSE) file.

[![boosty](https://img.shields.io/badge/Support_on_boosty-8b3d30?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)
