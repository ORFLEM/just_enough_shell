![last_commit](https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Last%20Commit&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![repo_size](https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=cccccc&label=Project%20Size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

<div align="center">
	<img src="./images/preview.webp" width="900px">
	<h1>Just Enough Shell</h1>
	<p>Built for daily use, not for screenshots.</p>
</div>

***

<table align="right">
	<tr>
		<td colspan="2" align="center">System Parameters</td>
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
		<td>SwayFX / Hyprland / niri</td>
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
	<h3>-- About the project -- :</h3>
	<p>
  <i>JES</i> uses <b>QuickShell</b> to render the interface.<br>
  <br>
	<b>SwayFX / Hyprland / niri</b> are available, but <b>Niri</b> lacks blur and also has a workspace bug; the script works incorrectly with it.<br>
  Also, by editing 3 stub scripts, you can run this interface on any wayland tiling WM that supports subscribe protocols for workspace data, active window, and keyboard layout.<br>
  <br>
	The project includes optimizations, but it hasn't been tested on low-end PCs.<br>
	Go binaries are used for scripts where fast reading of large data streams is important, which reduces CPU idle load to 5-7% instead of 35-45%.<br>
  <br>
	<i>JES</i> was designed for desktop PCs, allowing better refinement for such wonderful machines.<br>
	The author's monitor is UWQHD (3440x1440); tested resolutions: QHD (2560x1440) and above.<br>
	On these, the panel has no issues with module placement.<br>
	<br>
	The project uses bash with custom output, updates faster for SwayFX because it's geared toward the author and his daily usage.<br>
	This fact also gives the project continuity: as long as the author is busy with his own tasks, the project will continue to evolve and improve.<br>
	<br>
	For faster downloading, the author decided not to include video wallpapers, leaving a link to them instead.<br>
	<br>
	The `zenburn` theme <b>does not</b> apply to <i>JES</i> itself, only to programs, tty (NixOS only), and other things. <i>JES</i> has a built-in theme + support for base16 themes via base16.json.<br>
	<br>
  <i>JES is not oriented toward trends, but toward practicality in daily use and convenience.</i><br>
	</p>
	<h3>-- Future direction -- :</h3>
	<p>
	<b>[c]</b> Add support for <b>Hyprland</b><br>
  <b>[i]</b> Add support for <b>Niri</b><br>
  <b>[p]</b> Create a settings installer<br>
	<b>[c]</b> Support base16 themes in JES<br>
	<b>[p]</b> Create a weather widget<br>
	<b>[p]</b> Create a calendar widget<br>
	c = completed; n = not completed; i = in progress; p = planned.<br> 
	</p>
</div>

> **Who is *JES* for?** 
> - Desktop PCs with QHD+ resolution (the author uses UWQHD)
> - SwayFX / Hyprland users (Niri in progress) or skilled enthusiasts (the shell itself works on any wm, but tiling binds and settings will be missing then)
> - Those who value performance and architecture over trends
> 
> If you fit into this audience — welcome. 
> If not — maybe the project isn't for you, and that's fine.

```
If you want live video wallpapers, you can choose between video wallpapers and shaders (the latter may work poorly)
```

#### **Wallpapers from screenshots**: [click](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [*JES* structure](./structure_eng.md)

## -- What can be changed in *JES* -- :
- `mainRad` - corner rounding, default is 10, works perfectly with values 0-15
- `barOnTop` - places the control panel at the top, along with its adjacent widgets, enabled by default

## -- Keybindings -- :
| keybind | action |
| :--- | :---: |
| `super + e` | file manager |
| `super + q` | terminal |
| `super + o` | power buttons |
| `super + 1` or `super + scrll up \| scrll dwn` | switch workspaces |
| `super + shift + 1` or `super + shift + arrows` | move programs between workspaces |
| `super + rmb` | resize windows |
| `super + shift + arrows` or `super + lmb` | move window |
| `super + arrows` | switch between windows |
| `super + alt + lmb` | change window type: floating or tiling |
| `super + w` | restart interface |
| `super + s` | full-screen screenshot |
| `super + d` | screenshot of selected area |
| `super` | open app launcher |
| `super + g` | create group |
| `super + ctrl + g` | ungroup programs |
| `super + tab` | previous workspace |
| `capslock` or `shift + alt` | change language |
| `shift + capslock` | toggle caps lock |
| `super + space` | make window floating on top |
| `ctrl + /` | play \| pause music |
| `ctrl + .` | next track |
| `ctrl + ,` | previous track |
| `alt + pgup` | increase brightness |
| `alt + pgdn` | decrease brightness |
| `alt + F9` | mute audio |
| `alt + F10` | volume down |
| `alt + F11` | volume up |
| `alt + F12` | open \| close player |

## -- What *JES* looks like -- :
### Desktop
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Bar
![alt_image](./images/3.webp)

### Wallpaper picker
![alt_image](./images/4.webp)

### Popup player
![alt_image](./images/5.webp)
![alt_image](./images/6.webp)

### Power buttons
![alt_image](./images/7.webp)

### fastfetch
![alt_image](./images/8.webp)

### Volume and brightness popup
![alt_image](./images/9.webp)

### Launcher
![alt_image](./images/10.webp)

### Screen lock
![alt_image](./images/11.webp)
![alt_image](./images/12.webp)

### Bash prompt
```
1 [02:00 - orflem:~]$ cd gits/just_enough_shell/
2 [02:00 - orflem:~/gits/just_enough_shell main]$
```

command number, date, user, directories, git status (when inside a git repo)

## -- Installation -- :
### NixOS
```
1. Install NixOS
2. Backup system files (sudo mkdir -p /etc/nixos/backups && sudo cp /etc/nixos/* /etc/nixos/backups/*.backup)
3. Move config to "/etc/nixos" (sudo cp ./*.nix /etc/nixos/)
4. Backup user configs (cp -r ~/.config/ ~/backups/ && cp ~/.bashrc ~/backups)
5. Customize the NixOS config for your needs: add your user in the "USER ACCOUNT" section, localization and region in "LOCALISATION", and additional disks in "FILESYSTEMS" (if any)
6. Copy files from ".config/" to "~/.config", and from ".local/" to "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/ && cp ./.bashrc ~/.bashrc)
7. sudo nixos-rebuild switch
8. reboot
```

### Arch Linux or Arch based
```
1. Install Arch Linux (for simplicity, I recommend EndeavourOS)
2. Install yay or paru (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Install official software (sudo pacman -Syu && pacman -S $(cat ./arch_official.txt))
4. Install user software (yay -S $(cat ./arch_aur.txt))
5. Install the zenburn theme for qt and gtk
6. With the help of AI, try to recolor the entire system to zenburn and set ter-v32n (skip if you don't want an exact 1:1 result like on NixOS)
7. Backup user configs (cp -r ~/.config/ ~/backups/ && cp ~/.bashrc ~/backups)
8. Copy files from ".config/" to "~/.config", and from ".local/" to "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/ && cp ./.bashrc ~/.bashrc)
9. reboot
```

## -- License -- :
The notices were taken from the [blxshell](https://github.com/binarylinuxx/dots) project and modernized both visually and partially technically, under the **GNU GPL v3** license.
I recommend checking it out.

These configurations are distributed under the **GNU GPL v3** license.

In simple terms:
- You are free to use, study, and modify this code.
- If you share your changes or code built upon this with others (e.g., you publish a fork), you **must** make your source code open and available to everyone under the same license.

This ensures that all improvements and derivative works remain free and open, just like the original.

See the full license text in the [LICENSE](./LICENSE) file.

[![boosty](https://img.shields.io/badge/Support_on_boosty-8b3d30?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)

##### Created by \_ORFLEM\_
