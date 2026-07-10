<div align="center">
  <img src="https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="GitHub last commit">
  <img src="https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=bbbbbb&label=Project%20size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
  <img src="https://img.shields.io/github/stars/ORFLEM/just_enough_shell?color=bbbbbb&label=Project%20stars&logo=andela&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
	<img src="./images/preview.webp" width="900px">
	<h1>Just Enough Shell</h1>
	<p>Built for everyday use, not for screenshots.</p>
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
		<td>NixOS 26.05</td>
	</tr>
	<tr>
		<td>WM</td>
		<td>SwayFX / Hyprland / niri / DriftWM</td>
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
  <i>JES</i> uses <b>QuickShell</b> for rendering the interface.<br>
  <br>
	<i>JES</i> supports:
	<ul>
  	<li>SwayFX</li>
  	<li>Hyprland</li>
  	<li>Niri</li>
		<li>DriftWM</li>
		<li>Any other WM via 3 scripts and one QML file</li>
	</ul>
	<b>Niri</b> has no transparency support and has a bug with workspaces on the bar due to its architecture.<br>
	<br>
	The project has some optimization, but it hasn't been tested on weak hardware.<br>
	Go binaries are used for scripts where fast processing of large data streams matters — this keeps CPU usage at 5–10% (only <i>JES</i> - 1-2% CPU and ~400 MB RAM) idle instead of 35–45%.<br>
  <br>
	The project has a simple plugin system, making it extensible.<br>
	<br>
	<i>JES</i> was designed for desktop PCs, allowing it to be better tailored to those machines.<br>
	The author's monitor is UWQHD (3440×1440); tested resolutions: FHD (1920×1080) and above. (FHD is supported natively, <b>but</b> with minibar enabled there may be bugs, since the size doesn't change but the display model does.)<br>
	On those resolutions the bar has no issues with module placement.<br>
	Project supports multi-monitor setups.<br>
	<br>
	The project uses bash with custom output, and updates faster for SwayFX and DriftWM, since it's oriented toward the author's everyday use.<br>
	This also gives the project longevity — as long as the author goes about his business, the project will keep evolving and improving.<br>
	<br>
	For faster loading, the author chose not to bundle live wallpapers from the screenshots, leaving a link to them instead.<br>
	<br>
	The <i>zenburn</i> theme does <b>not</b> apply to <i>JES</i> itself — only to external apps, tty (NixOS only), and similar. <i>JES</i> has a built-in generated theme + base16 theme support via base16.json.<br>
	<br>
  <i>JES is oriented not toward trends, but toward practicality and convenience in everyday use.</i><br>
	</p>
	<h3>-- acknowledgements -- :</h3>
	<p>
	Thanks to <b><a href="https://github.com/binarylinuxx/dots">Blxshell</a> and its author</b> for help with learning Quickshell and hosting the website.<br>
	Thanks to <b><a href="https://github.com/f026/">f026</a></b> for the <a href="https://github.com/f026/activate-linux-plugin">first plugin</a> for JES.<br>
	Thanks to <b><a href="https://github.com/malbiruk/driftwm">DriftWM</a></b> for help with DriftWM IPC, adding new features to the WM for JES, and in general for being supportive of the project.<br>
    Thanks to <b><a href="https://github.com/frosti-4">frosti-4</a></b> for the script for Arch Linux.<br>
	</p>
	<h3>-- Roadmap -- :</h3>
	<p>
	<b>[c]</b> Add <b>Hyprland</b> support<br>
  <b>[c]</b> Add <b>Niri</b> support<br>
	<b>[c]</b> Add <b>DriftWM</b> support<br>
	<b>[c]</b> base16 theme support in JES<br>
  <b>[c]</b> Soft Material You<br>
	<b>[c]</b> Display info for devices connected via KDE Connect<br>
	<b>[c]</b> Nice screen picker<br>
	<b>[c]</b> Animated album art in the player when no cover is available<br>
	<b>[c]</b> Protection against static wallpapers with wrong format in the wallpaper picker<br>
	<b>[c]</b> Calendar widget<br>
	<b>[c]</b> Multi-monitor support<br>
  <b>[c]</b> Settings installer<br>
	<b>[c]</b> Neutral / vibrant style toggle<br>
	<b>[c]</b> Popup minimap for <b>driftwm</b><br>
	<b>[c]</b> Add waypoints to map<br>
	<b>[c]</b> Add full map<br>
	<b>[c]</b> Add normal ui in full map<br>
  <b>[c]</b> Development of API for working with launcher<br>
  <b>[c]</b> Development of API for working with plugin center<br>
	<b>[i]</b> Migrate <b>Hyprland</b> config to Lua<br>
	<b>[i]</b> Fix <b>Niri</b><br>
	<b>[p]</b> Weather widget<br>
  <b>[p]</b> Development of API for working with bar<br>
	<b>[n]</b> Dark / light theme toggle<br>
	c = completed; n = not completed; i = in progress; p = planned.<br>
	</p>
</div>

> **Who is *JES* for?**
> - Desktop PCs with FHD+ resolution (the author uses UWQHD)
> - Users of SwayFX / Hyprland / Niri / DriftWM, or enthusiasts willing to invest time in initial setup (the shell itself works on any WM, but keybinds and tiling config won't be included)
> - Those who value performance and architecture over trends
> - Anyone who wants a pleasant, CPU/GPU-lightweight interface
>
> If you fall into this audience — welcome.
> If not — this project might not be for you, and that's okay.

## -- IMPORTANT -- :
- Nvidia graphics cards work TERRIBLY, **everything can freeze instantly for no reason**, the author is not going to fix this issue, because it's **problems on the driver side**!
- The author has no experience with Arch Linux; installation on Arch may be incorrect. If that's the case, please describe the issue in an Issue and, if possible, suggest a fix.
- Installation instructions are at the very bottom.
- The author is open to suggestions and helps with onboarding; for issues, open an [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new).

```
If you want live video wallpapers, there are both video wallpapers and shaders available
(the latter may work poorly with JES's auto theme generation)
```
#### **Wallpapers from screenshots**: [click](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [*JES* structure](./structure_eng.md)

## -- What you can configure in *JES* -- :
- `wm` — auto, but for WMs not in the supported list you need to specify the name with a capital letter
- `wm_type` — auto, but for unsupported WMs choose between `workspaces` or `coordinates`
- `mainRad` — corner radius, default 10, works best in the range 0–25
- `barOnTop` — control bar on top along with adjacent widgets, enabled by default
- `minibar` — constrains the bar width to 1920px, disabled by default
- `BarHeight` — bar height, default 30
- `fontSize` — font size, default 17
- `fontFamily` — font, default Mononoki Nerd Font Propo
- `custom_wallpaper_engine` — disable the built-in wallpaper engine, default false
- `disableGenerate` - replace JES matugen theme on base16, default false
- `doNotDisturb` — silent mode, default false
- `timezone` — the city for the weather widget; it is not present by default, the value is taken from the `user-config.toml` file of the NixOS configuration.

```
Note: config.toml lives in the Quickshell folder (~/.config/quickshell/)
The author left an alias in .bashrc — if you don't want to type the path, just run:
    edit-JES
The alias uses micro; to quit press Ctrl+Q, to save press Ctrl+S
```

## [JES for DriftWM](./DriftWM_eng.md)

## -- Keybindings for SwayFX, Hyprland and Niri -- :
| keybinding | action |
| :--- | :---: |
| `super + e` | file manager |
| `super + q` \| `super + enter` | terminal |
| `super + p` | power buttons |
| `super + 1-0` or `super + scroll up \| scroll down` | switch workspaces |
| `super + shift + 1-0` or `super + shift + arrows` | move windows between workspaces |
| `super + RMB` | resize windows |
| `super + shift + arrows` or `super + LMB` | move window |
| `super + arrows` | switch between windows |
| `super + alt + LMB` | toggle window type: floating or tiling |
| `super + w` | restart the interface |
| `home` | fullscreen screenshot |
| `shift + home` | screenshot of selected area |
| `super + d` | open app launcher |
| `super + g` | create group |
| `super + ctrl + g` | ungroup windows |
| `super + tab` | previous workspace |
| `capslock` or `shift + alt` | switch language |
| `shift + capslock` | toggle caps lock |
| `super + space` | raise window above others |
| `ctrl + /` | play \| pause music |
| `ctrl + .` | next track |
| `ctrl + ,` | previous track |
| `alt + pgup` | increase brightness |
| `alt + pgdn` | decrease brightness |
| `alt + F9` | mute |
| `alt + F10` | volume down |
| `alt + F11` | volume up |
| `alt + F12` | open \| close player |

- To open the plugin center, right-click on the power button.
- To open the calendar, right-click on the time; left-click swaps the time and date.

### The screenshot key is configurable since not everyone has a convenient `Home` key — the author's keyboard doesn't have Print Screen either.

### [Keybindings for DriftWM](./DriftWM_eng.md)

## -- How *JES* looks -- :
### Desktop
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Control bar (DriftWM version differs, see [`DriftWM_eng.md`](./DriftWM_eng.md))
![alt_image](./images/3.webp)

### Wallpaper picker
![alt_image](./images/4.webp)

### Player
![alt_image](./images/5.webp)
![alt_image](./images/6.webp)

### Power buttons
![alt_image](./images/7.webp)

### fastfetch
![alt_image](./images/8.webp)

### Volume / audio popup
![alt_image](./images/9.webp)

### App launcher
![alt_image](./images/10.webp)

### Lock screen
![alt_image](./images/11.webp)
![alt_image](./images/12.webp)

### bash prompt
```
1 [02:00 - orflem:~]$  cd gits/just_enough_shell/
2 [02:00 - orflem:~/gits/just_enough_shell main]$  
```
command number, time, user, directory, git status (when inside a git-tracked project)

## -- Plugins -- :
### Installation
```
1. open ~/.config/quickshell/
2. drop the plugin folder there
3. open config.toml
4. add the following lines:
   [plugin.plugin-name]
   source = "plugin folder/Main plugin file.qml"
   active = true
```

### [Detailed plugin creation guide](./plugins_eng.md)

### [Plugin Repository](./plugin_repo.md)
### Important: the repository is only available in English, as this part is heavily influenced by the project community, and translating all short descriptions into multiple languages is extremely difficult.

## -- Installing JES -- :
### NixOS
- install NixOS
- start JES installer:
```bash
nix-shell -p git --run "git clone https://github.com/ORFLEM/just_enough_shell.git && cd just_enough_shell && ./install.sh"
```
- reboot

### Arch Linux or Arch-based (may be incorrect; if so, please open an [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new))

- Install Arch Linux (EndeavourOS is recommended for simplicity)
- Start JES installer:
```bash
git clone https://github.com/ORFLEM/just_enough_shell.git && cd just_enough_shell && ./install_arch.sh
```

- In case of errors, install manually:
```
1. Install Arch Linux (EndeavourOS is recommended for simplicity)
2. Install yay or paru (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Install official packages (sudo pacman -Syu && pacman -S $(cat ./arch_official.txt))
4. Install AUR packages (yay -S $(cat ./arch_aur.txt))
5. Install the zenburn theme for Qt and GTK
6. Optionally configure system themes (GTK/Qt) to zenburn and install the ter-v32n font
7. Back up user configs (cp -r ~/.config/ ~/backups/ && cp ~/.bashrc ~/backups)
8. Copy files from ".config/" to "~/.config" and from ".local/" to "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/ && cp ./.bashrc ~/.bashrc)
9. reboot
```

## -- License -- :
Notifications were taken from the [blxshell](https://github.com/binarylinuxx/dots) project and improved both visually and partially technically. License: **GNU GPL v3**.
Worth checking out.

These configurations are distributed under the **GNU GPL v3** license.

In plain terms:
- You are free to use, study, and modify this code.
- If you share your modifications or derivative work with others (e.g. by publishing a fork), you **must** make your source code open and available to everyone under the same license.

This ensures that all improvements and derivative works remain free and open, just like the original.

Full license text: [LICENSE](./LICENSE).

[![boosty](https://img.shields.io/badge/Support_on_boosty-8b3d30?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)

##### Created by \_ORFLEM\_
