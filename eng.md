![last_commit](https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Last%20commit&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![repo_size](https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=cccccc&label=Repository%20size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

<div align="center">
	<img src="./images/preview.webp" width="900px">
	<h1>Just Enough Shell</h1>
	<p>Created for every day, not for show.</p>
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
		<td>NixOS 26.05</td>
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
		<td>theme changer</td>
		<td>matugen</td>
	</tr>
</table>

<div align="left">
	<h3>-- About the project -- :</h3>
	<p>
  <i>JES</i> uses <b>QuickShell</b> to render the interface.<br>
  <br>
	<b>SwayFX / Hyprland / niri</b> are supported, but <b>Niri</b> lacks blur and also has a bug with workspaces; the script works incorrectly with it.<br>
  Also, by editing 3 stub scripts, you can run this interface on any Wayland tiling WM that supports subscribe protocols for workspace, active window, and layout data.<br>
  <br>
	The project includes optimizations, but it hasn't been tested on low-end PCs.<br>
	Go binaries are used for scripts that require fast reading of large data streams, reducing CPU idle load to 7-11% instead of 35-45%.<br>
  <br>
	<i>JES</i> is designed for desktop PCs, allowing deeper refinement for such machines.<br>
	The author's monitor is UWQHD (3440x1440); tested resolutions: FHD (1920x1080) and above. (FHD is natively supported, <b>but</b> when minibar is enabled, there may be bugs because the size does not adapt while the display model does.)<br>
	On these resolutions, the panel has no module positioning issues.<br>
	<br>
	The project uses bash with custom output and updates faster for SwayFX, as it is oriented toward the author's daily use.<br>
	This fact also gives the project consistency: as long as the author works on their own tasks, the project will evolve and improve.<br>
	<br>
	For faster distribution, the author decided not to include video wallpapers but instead provides a link to them.<br>
	<br>
	The <i>zenburn</i> theme <b>does not</b> apply to <i>JES</i> itself, only to programs, tty (NixOS only), and so on. JES has a built-in generated theme + base16 theme support via base16.json.<br>
	<br>
  <i>JES is focused not on trends, but on practicality in daily use and convenience.</i><br>
	</p>
	<h3>-- Future direction -- :</h3>
	<p>
	<b>[c]</b> Add <b>Hyprland</b> support<br>
  <b>[c]</b> Add <b>Niri</b> support<br>
  <b>[p]</b> Create a settings installer<br>
	<b>[c]</b> Support base16 themes in JES<br>
  <b>[c]</b> Soft material you<br>
	<b>[i]</b> Choose style: neutral / vibrant<br>
	<b>[p]</b> Choose theme: dark / light<br>
	<b>[c]</b> Display device info connected via kdeconnect<br>
	<b>[i]</b> Migrate <b>Hyprland</b> to lua configs<br>
	<b>[p]</b> Fix <b>Niri</b><br>
	<b>[c]</b> Beautiful screen picker<br>
	<b>[c]</b> Animated cover in player when no cover exists<br>
	<b>[c]</b> Protection against static wallpapers with incorrect format in wallpaper picker<br>
	<b>[p]</b> Create a weather widget<br>
	<b>[c]</b> Create a calendar widget<br>
	c = completed; n = not completed; i = in progress; p = planned.<br> 
	</p>
</div>

> **Who is *JES* for?** 
> - Desktop PCs with FHD+ resolution (author uses UWQHD)
> - SwayFX / Hyprland / Niri users or enthusiasts with time for initial setup (the shell itself works on any WM, but tiling binds and settings will be absent)
> - Those who value performance and architecture over trends
> - Need a pleasant and CPU/GPU-light interface
> 
> If you fit this audience — welcome. 
> If not — maybe the project isn't for you, and that's fine.

```
If you want live video wallpapers, you can choose between video wallpapers and shaders (the latter may work poorly with JES's theme auto‑generation).
```

#### **Wallpapers from screenshots**: [click](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [*JES* structure](./structure.md)

## -- What can be changed in *JES* --:
- `mainRad` - corner rounding, default is 10, works ideally with values 0-25
- `barOnTop` - control panel at the top, as well as adjacent widgets, enabled by default
- `minibar` - makes the panel 1920px wide, disabled by default
- `BarHeight` - panel height, default is 30
- `fontSize` - font size, default is 17
- `fontFamily` - font, default is Mononoki Nerd Font Propo

## -- Keybindings -- :
| binding | action |
| :--- | :---: |
| `super + e` | file manager |
| `super + q` \| `super + enter` | terminal |
| `super + o` | power buttons |
| `super + 1` or `super + scroll up \| scroll down` | switch between workspaces |
| `super + shift + 1` or `super + shift + arrows` | move programs between workspaces |
| `super + right mouse button` | resize windows |
| `super + shift + arrows` or `super + left mouse button` | move window |
| `super + arrows` | switch between windows |
| `super + alt + left mouse button` | change window type: floating or tiling |
| `super + w` | restart the interface |
| `home` | full-screen screenshot |
| `shift + home` | screenshot of selected area |
| `super` | open app launcher |
| `super + g` | create a group |
| `super + ctrl + g` | ungroup programs |
| `super + tab` | previous workspace |
| `capslock` or `shift + alt` | change language |
| `shift + capslock` | enable \| disable caps lock |
| `super + space` | toggle window always on top |
| `ctrl + /` | play \| pause music |
| `ctrl + .` | next track |
| `ctrl + ,` | previous track |
| `alt + pgup` | increase brightness |
| `alt + pgdn` | decrease brightness |
| `alt + F9` | mute audio |
| `alt + F10` | volume down |
| `alt + F11` | volume up |
| `alt + F12` | open \| close player |

### The screenshot key choice is at the top because not everyone has a convenient home key or may lack it (like the author's keyboard – print screen)

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
