<div align="center">
	<img src="https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Last%20commit&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="GitHub last commit">
  <img src="https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=bbbbbb&label=Project%20size&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
  <img src="https://img.shields.io/github/stars/ORFLEM/just_enough_shell?color=bbbbbb&label=Project%20stars&logo=andela&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
	<img src="https://github.com/ORFLEM/dots/blob/main/images/7.webp?raw=true" width="900px">
	<h1>> Just Enough Shell _</h1>
	<p>Built for daily use, not for screenshots.</p>
</div>

***

<div align="left">
	<h3>-- About -- :</h3>
	<p>
	<i>JES</i> - WM-agnostic rolling release desktop shell that supports connecting any WM natively, even self-written ones.<br>
  <br>
	<i>JES</i> supports out of the box:
	<ul>
  	<li><a href="https://github.com/wlrfx/swayfx">SwayFX</a></li>
  	<li><a href="https://hypr.land/">Hyprland</a></li>
  	<li><a href="https://github.com/niri-wm/niri">Niri</a></li>
		<li><a href="https://github.com/malbiruk/driftwm">DriftWM</a></li>
		<li><a href="https://github.com/binarylinuxx/zwwm">ZWWM</a></li>
		<li>Any other via the plugin system (see <a href="./wm_eng.md">wm_eng.md</a> and <a href="./wm_repo.md">wm_repo.md</a>)</li>
	</ul>
	<br>
	The project has optimization, but it has not been tested on <b>very</b> weak PCs.<br>
	Go binaries are used for scripts where fast reading of a large data stream matters; thanks to this, idle CPU load for <i>JES</i> is 1-2% and ~450 MB RAM.<br>
  <br>
	The project has a simple plugin system, making it extensible.<br>
	<br>
	<b>JES modules:</b>
	<ul>
	<li>Control panel (bar) with a component-based widget system</li>
	<li>Application launcher</li>
	<li>Wallpaper picker and built-in wallpaper engine with shaders</li>
	<li>Media player with cava equalizer</li>
	<li>Calendar</li>
	<li>Power menu</li>
	<li>Mini-map</li>
	<li>Jwindow — content-adaptive window</li>
	<li>Lock screen</li>
	<li>Volume and brightness popup</li>
	<li>Screen picker — screenshot utility</li>
	<li>Weather widget</li>
	<li>Plugin system (.jes.pb format) with plugin center API</li>
	<li>jes-cli — shell management from the terminal</li>
	<li>CoreAura — monitoring daemon (kernel errors, service crashes, load)</li>
	</ul>
	<br>
	<i>JES</i> was designed for desktop PCs, so there can be problems with laptops (semi-working indicator), as the author has no laptop.<br>
	Verified resolutions: FHD (1920x1080) and above.<br>
	On these the panel has no problems with module placement.<br>
	Multiple monitors are natively supported.<br>
	<br>
	The project survived a switch from eww to qs and will not be abandoned, as it is inseparably tied to the author's daily life and community requests; it will keep evolving and improving.<br>
	<br>
  <i>JES is oriented not toward trends, but toward practicality in everyday use and convenience.</i><br>
	</p>
	<h3>-- Support the project -- :</h3>
	The main support is motivational support for the author — mentioning the project in the README of your projects (for example, in a community block in your WM) or feedback about the project, such as a plugin or a piece of advice, even a simple issue makes the author's day.<br>
	There is no secondary support, because the author sees no point in monetary support for now; it will appear only if there are requests for it, and not just a couple.
	<h3>-- Thanks -- :</h3>
	<p>
	Thanks to <b><a href="https://github.com/binarylinuxx/dots">Blxshell</a> and its author</b> for help with learning Quickshell.<br>
	Thanks to <b><a href="https://github.com/f026/">f026</a></b> for the <a href="https://github.com/f026/activate-linux-plugin">first plugin</a> for JES.<br>
	Thanks to <b><a href="https://github.com/malbiruk/driftwm">DriftWM author (malbiruk)</a></b> for help with DriftWM IPC, adding new features to the WM for JES, and in general loyalty to the project.<br>
  Thanks to <b><a href="https://github.com/frosti-4">frosti-4</a></b> for the Arch Linux script.<br>
  Thanks to <b><a href="https://github.com/Gegs8">Gegs8</a></b> for finding installer bugs.<br>
	</p>
	<h3>-- Future direction -- :</h3>
	<p>
	<b>[i]</b> Community and infrastructure development<br>
	c = completed; n = not completed; i = in progress; p = planned.<br>
	</p>
</div>

View past completed tasks — [completed.md (eng only)](./completed.md)

> **Who is *JES* for?**
> - Desktop PCs with FHD+ resolution (the author uses UWQHD - 3440x1440 and considers it the project benchmark)
> - Users of SwayFX / Hyprland / Niri / DriftWM / ZWWM or enthusiasts with time for initial setup (the shell itself works on any WM, but tiling binds and settings will then be missing)
> - A WM developer who needs a basic environment for their WM without months of work with waybar, rofi and other programs
> - Those who value performance and architecture above trends
> - Anyone needing a pleasant and lightweight CPU/RAM interface
>
> If you fit this audience — welcome.
> If not — the project may not be for you, and that's okay.

## -- IMPORTANT -- :
- All performance tests were conducted on **r7 5700x and r5 3600**; on both CPUs the percentage was the same: 1-2%, but it's better to check your CPU's power via AI or comparison sites to understand the approximate load
- Nvidia graphics cards work TERRIBLY, **everything can freeze instantly for no reason**; the author is not going to solve this, as it is a **driver-side problem**!
- Arch Linux support is provided via a PKGBUILD (see the installation section); if you have problems with the package, describe them in an [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new) and, if possible, suggest a fix — pull requests adding distribution support are welcome
- Installation instructions are at the very bottom
- The author is open to suggestions and helps newcomers get into the project; in case of problems, write to [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new)
- The author will be grateful for help with supporting other distributions and will immediately accept new pull requests naming the author who added the support; in demand are void linux, alt linux and debian

## [JES structure](./structure_eng.md)

## -- What changes in *JES* --:
- `wm` -                      auto, but to connect a WM not from the available list you need to write the name with a capital letter
- `wm_type` -                 auto, but for WMs not from the available list choose workspaces or coordinates
- `mainRad` -                 corner radius, default 10, works perfectly with values 0-25
- `barOnTop` -                control panel on top, as well as adjacent widgets, enabled by default
- `minibar` -                 makes the panel 1920px wide, disabled by default
- `barHeight` -               panel height, default 30
- `fontSize` -                font size, default 17
- `fontFamily` -              font, default Mononoki Nerd Font Propo
- `custom_wallpaper_engine` - disable built-in wallpapers, default false
- `disableGenerate` -         switch the JES matugen theme to base16, default false
- `doNotDisturb` -            quiet mode, default false
- `timezone` -                city for the weather widget, not present by default, data is taken from the `user-config.toml` of the NixOS configuration
- `animation` -               animation speed, float number, default 1.0
- `wtw` -                     distance from widget to widget, default 6
- `spacing` -                 distance between blocks inside a widget, default 3
- `margins` -                 margins in widgets, default 3
- `disableCorners` -          disable monitor corner rounding, disabled by default
- `openweather_key` -         key for the openweather api, no default data
- `do_not_sync_rad` -         do not sync WM radii with the JES radius, default false
- `changeShader` -            replace the default shader with another one, empty by default, but you need to enter the path to a **qsb** file
- `nanoPlayer` -              compact player mode in the bar, default false
- `nanoPlrSize` -             compact player size, default 200
- `disableCava` -             disable the equalizer in the bar, default false
- `enableFolders` -           enable launching plugins in folder format, default false

```
Important: config.toml is located in the JES folder (~/.config/JES/)
and can also be edited by calling:
	jes-cli editConf
In jes-cli, micro is used for config editing; to exit use Ctrl+Q, and to save — Ctrl+S
```

## -- What *JES* looks like --:
### Control panel
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/1.webp?raw=true)

### Wallpaper selection
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/3.webp?raw=true)

### Player
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/4.webp?raw=true)
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/5.webp?raw=true)

### Power buttons
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/6.webp?raw=true)

### Jwindow
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/7.webp?raw=true)

### Volume and brightness popup
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/8.webp?raw=true)

### Application launcher
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/9.webp?raw=true)

### Lock screen
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/10.webp?raw=true)

\* Screenshots were taken on the [author's dotfiles](https://github.com/ORFLEM/dots); the base setup may differ from the screenshots in wallpapers and the launcher shader

## -- Plugins --:
### Installation
```
1. open ~/.config/JES/
2. drop the plugin folder in
3. open config.toml
4. add these lines:
   [[plugin]]
   name = "plugin name" # data in property name from manifest.json
   uuid = "uuidv4" # data in property uuid from manifest.json
   active = true
```

### [Detailed plugin creation guide](./plugins_eng.md)
### [WM adapter creation guide](./wm_eng.md)

### [Plugin repository](./plugin_repo.md)
### [Supported WMs](./wm_repo.md)
### Important: the plugin repository and supported WMs are documented in English only, because this part is heavily influenced by the project community, and translating all short descriptions into different languages is unbearably difficult

## -- JES installation --:
### NixOS
- in `flake` add the following:
```nix
{
	inputs = {
    jes.url = "github:ORFLEM/just_enough_shell";
	}
	outputs = { your inputs, jes, ... }@inputs:
  let
    system = "x86_64-linux";
    hostname = "nixos";

    specialArgs = { inherit inputs system hostname; };

  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
				jes.nixosModules.default
			];
		};
	};
}
```
- rebuild the flake
- in `configuration.nix` add:
```nix
programs.jes = {
  enable = true;
  # autoStart = true;  # default - false
};
```
- rebuild NixOS

### Fedora
Ready-made RPMs (and SRPMs) are published on [GitHub Releases](https://github.com/ORFLEM/just_enough_shell/releases) for every tag.
Building from source: `packaging/fedora/jes.spec`.

### ALT Linux
Ready-made RPMs (and SRPMs) are published on [GitHub Releases](https://github.com/ORFLEM/just_enough_shell/releases) for every tag marked alt1.
Building from source: `packaging/alt/jes-shell.spec`.

### Debian / Ubuntu
A ready-made `.deb` is published on [GitHub Releases](https://github.com/ORFLEM/just_enough_shell/releases) for every tag.

### After installation (all distributions except NixOS)
- start: `jes-cli start-daemon`
- autostart: `systemctl --user enable --now jes`

### Arch Linux
```bash
git clone https://github.com/ORFLEM/just_enough_shell.git
cd just_enough_shell/packaging/arch
makepkg -si
```

### Manual installation on Arch (fallback option)
```
1. Install Arch Linux (for simplicity I recommend EndeavourOS)
2. Install yay or paru (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Install official software (sudo pacman -Syu && pacman -S $(cat ./installer/arch_official.txt))
4. Install user software (yay -S $(cat ./installer/arch_aur.txt))
5. Clone .local and .config into the corresponding folders
6. Build all the Go software from for-quickshell; see flake.nix for what goes where
```

## -- Neighboring projects --:
- [blxshell](https://github.com/binarylinuxx/dots/tree/main) - dots like desktop shell from the author of ZWWM

## -- License --:
These configurations are distributed under the **BSD 3-Clause License**.

In simple terms this means:
- You can do anything with the code, but the author retains copyright on the project.
- You are required to indicate the original project and author in a fork, even if it is closed-source.
- You may not use the author's persona (nickname, other mentions) to promote your version of the project without permission.

This guarantees that the author's name and project will always be credited, and the author's name will not become a tool for promoting other forks.

Full license text see in the [LICENSE](./LICENSE) file.

##### Created by [\_ORFLEM\_](https://github.com/ORFLEM)

##### Translated by [Kimi K3](https://www.kimi.com/en?chat_enter_method=new_chat)
