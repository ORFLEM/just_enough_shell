<div align="center">
	<img src="https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Letzter%20Commit&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="GitHub last commit">
  <img src="https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=bbbbbb&label=Projektgr%C3%B6%C3%9Fe&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
  <img src="https://img.shields.io/github/stars/ORFLEM/just_enough_shell?color=bbbbbb&label=Projekt-Sterne&logo=andela&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
	<img src="https://github.com/ORFLEM/dots/blob/main/images/7.webp?raw=true" width="900px">
	<h1>> Just Enough Shell _</h1>
	<p>Für den Alltag gebaut, nicht für Screenshots.</p>
</div>

***

<div align="left">
	<h3>-- Über -- :</h3>
	<p>
	<i>JES</i> - WM-agnostische Rolling-Release Desktop-Shell, die das native Anbinden beliebiger WM unterstützt, auch selbstgeschriebener.<br>
  <br>
	<i>JES</i> unterstützt out of the box:
	<ul>
  	<li><a href="https://github.com/wlrfx/swayfx">SwayFX</a></li>
  	<li><a href="https://hypr.land/">Hyprland</a></li>
  	<li><a href="https://github.com/niri-wm/niri">Niri</a></li>
		<li><a href="https://github.com/malbiruk/driftwm">DriftWM</a></li>
		<li><a href="https://github.com/binarylinuxx/zwwm">ZWWM</a></li>
		<li>Jeden anderen über das Plugin-System (siehe <a href="./wm_deu.md">wm_deu.md</a> und <a href="./wm_repo.md">wm_repo.md</a>)</li>
	</ul>
	<br>
	Das Projekt ist optimiert, wurde aber nicht auf <b>sehr</b> schwachen PCs getestet.<br>
	Go-Binaries werden für Skripte verwendet, bei denen das schnelle Lesen großer Datenströme wichtig ist; dank dessen beträgt die CPU-Last im Leerlauf für <i>JES</i> 1-2% und ~450 MB RAM.<br>
  <br>
	Das Projekt hat ein einfaches Plugin-System, das es erweiterbar macht.<br>
	<br>
	<b>JES-Module:</b>
	<ul>
	<li>Steuerleiste (bar) mit komponentenbasiertem Widget-System</li>
	<li>Anwendungsstarter</li>
	<li>Hintergrundbildauswahl und eingebaute Wallpaper-Engine mit Shadern</li>
	<li>Mediaplayer mit Cava-Equalizer</li>
	<li>Kalender</li>
	<li>Power-Menü</li>
	<li>Mini-Map</li>
	<li>Jwindow — inhaltlich adaptives Fenster</li>
	<li>Sperrbildschirm</li>
	<li>Popup für Lautstärke und Helligkeit</li>
	<li>Screen Picker — Screenshot-Dienstprogramm</li>
	<li>Wetter-Widget</li>
	<li>Plugin-System (Format .jes.pb) mit Plugin-Center-API</li>
	<li>jes-cli — Shell-Verwaltung vom Terminal aus</li>
	<li>CoreAura — Überwachungs-Daemon (Kernel-Fehler, Service-Abstürze, Last)</li>
	</ul>
	<br>
	<i>JES</i> wurde für Desktop-PCs entwickelt, weshalb es bei Laptops zu Problemen kommen kann (halbfunktdionierende Anzeige), da der Autor keinen Laptop hat.<br>
	Verifizierte Auflösungen: FHD (1920x1080) und höher.<br>
	Auf diesen hat die Leiste keine Probleme mit der Platzierung der Module.<br>
	Mehrere Monitore werden nativ unterstützt.<br>
	<br>
	Das Projekt hat den Wechsel von eww zu qs überlebt und wird nicht aufgegeben, da es untrennbar mit dem Alltag des Autors und den Anfragen der Community verbunden ist; es wird sich weiterentwickeln und verbessern.<br>
	<br>
  <i>JES orientiert sich nicht an Trends, sondern an Praktikabilität im Alltag und Bequemlichkeit.</i><br>
	</p>
	<h3>-- Projektunterstützung -- :</h3>
	Die Hauptsupportart ist die motivationale Unterstützung des Autors — die Nennung des Projekts in der README deiner Projekte (zum Beispiel in einem Community-Block in deinem WM) oder ein Feedback über das Projekt, wie ein Plugin oder ein Rat, sogar ein einfaches Issue freut den Autor.<br>
	Es gibt keine sekundäre Unterstützung, da der Autor derzeit keinen Sinn in monetärer Unterstützung sieht; sie wird erscheinen, nur wenn es entsprechende Anfragen gibt, und nicht nur ein paar.
	<h3>-- Danksagungen -- :</h3>
	<p>
	Danke an <b><a href="https://github.com/binarylinuxx/dots">Blxshell</a> und seinen Autor</b> für die Hilfe beim Erlernen von Quickshell.<br>
	Danke an <b><a href="https://github.com/f026/">f026</a></b> für das <a href="https://github.com/f026/activate-linux-plugin">erste Plugin</a> für JES.<br>
	Danke an den <b><a href="https://github.com/malbiruk/driftwm">Autor von DriftWM (malbiruk)</a></b> für die Hilfe mit DriftWM-IPC, das Hinzufügen neuer Funktionen zum WM für JES und im Allgemeinen die Loyalität zum Projekt.<br>
  Danke an <b><a href="https://github.com/frosti-4">frosti-4</a></b> für das Arch-Linux-Skript.<br>
  Danke an <b><a href="https://github.com/Gegs8">Gegs8</a></b> für das Finden von Installer-Bugs.<br>
	</p>
	<h3>-- Zukünftige Richtung -- :</h3>
	<p>
	<b>[i]</b> Entwicklung der Community und Infrastruktur<br>
	c = abgeschlossen; n = nicht abgeschlossen; i = in Arbeit; p = geplant.<br>
	</p>
</div>

Vergangene abgeschlossene Aufgaben ansehen — [completed.md (nur englisch)](./completed.md)

> **Für wen ist *JES*?**
> - Desktop-PCs mit FHD+-Auflösung (der Autor nutzt UWQHD - 3440x1440 und betrachtet dies als Benchmark für das Projekt)
> - Nutzer von SwayFX / Hyprland / Niri / DriftWM / ZWWM oder Enthusiasten mit Zeit für die Ersteinrichtung (die Shell selbst funktioniert mit jedem WM, aber Tiling-Binds und -Einstellungen fehlen dann)
> - Ein WM-Entwickler, der eine Basisumgebung für seinen WM braucht, ohne monatelang mit waybar, rofi und anderen Programmen zu arbeiten
> - Diejenigen, die Performance und Architektur über Trends stellen
> - Wer eine angenehme und für CPU/RAM leichtgewichtige Oberfläche braucht
>
> Wenn du zu dieser Zielgruppe gehörst — willkommen.
> Wenn nicht — das Projekt ist vielleicht nichts für dich, und das ist okay.

## -- WICHTIG -- :
- Alle Performance-Tests wurden auf **r7 5700x und r5 3600** durchgeführt; auf beiden CPUs war der Prozentsatz gleich: 1-2%, aber es ist besser, über KI oder Vergleichsseiten die Leistung der eigenen CPU zu prüfen, um die ungefähre Last zu verstehen.
- Nvidia-Grafikkarten funktionieren SCHRECKLICH, **alles kann sofort ohne Grund einfrieren**; der Autor wird dieses Problem nicht lösen, da es sich um ein **Treiberproblem** handelt!
- Die Unterstützung von Arch Linux erfolgt über ein PKGBUILD (siehe Installationsabschnitt); bei Problemen mit dem Paket beschreibe sie bitte in einem [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new) und schlage falls möglich einen Fix vor — Pull Requests mit Distributions-Support sind willkommen.
- Die Installationsanleitung befindet sich ganz unten.
- Der Autor ist offen für Vorschläge und hilft beim Einstieg in das Projekt; bei Problemen bitte in ein [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new) schreiben.
- Der Autor wäre für Hilfe bei der Unterstützung anderer Distributionen dankbar und nimmt neue Pull Requests sofort an, wobei der Autor der Unterstützung genannt wird; gefragt sind unter anderem void linux, alt linux und debian.

## [JES-Struktur](./structure_deu.md)

## -- Was sich in *JES* ändert --:
- `wm` -                      auto, aber für die Anbindung eines WM, der nicht in der Liste steht, muss der Name mit Großbuchstabe geschrieben werden
- `wm_type` -                 auto, aber für WM, die nicht in der Liste stehen, stehen workspaces oder coordinates zur Auswahl
- `mainRad` -                 Eckenradius, Standard 10, funktioniert perfekt mit Werten 0-25
- `barOnTop` -                Steuerleiste oben sowie die angrenzenden Widgets, standardmäßig aktiviert
- `minibar` -                 macht die Leiste 1920px breit, standardmäßig deaktiviert
- `barHeight` -               Leistenhöhe, Standard 30
- `fontSize` -                Schriftgröße, Standard 17
- `fontFamily` -              Schriftart, Standard Mononoki Nerd Font Propo
- `custom_wallpaper_engine` - integrierte Hintergrundbilder deaktivieren, Standard false
- `disableGenerate` -         JES-matugen-Theme auf base16 umschalten, Standard false
- `doNotDisturb` -            Ruhemodus, Standard false
- `timezone` -                Stadt für das Wetter-Widget, standardmäßig nicht vorhanden, Daten werden aus der `user-config.toml`-Konfiguration von NixOS bezogen
- `animation` -               Animationsgeschwindigkeit, Fließkommazahl, Standard 1.0
- `wtw` -                     Abstand von Widget zu Widget, Standard 6
- `spacing` -                 Abstand zwischen Blöcken innerhalb eines Widgets, Standard 3
- `margins` -                 Ränder in Widgets, Standard 3
- `disableCorners` -          Monitor-Eckenabrundung deaktivieren, standardmäßig deaktiviert
- `openweather_key` -         Schlüssel für die OpenWeather-API, ohne Standarddaten
- `do_not_sync_rad` -         WM-Radien nicht mit dem JES-Radius synchronisieren, Standard false
- `changeShader` -            Standard-Shader durch einen anderen ersetzen, standardmäßig leer, aber es muss der Pfad zu einer **qsb**-Datei eingegeben werden
- `nanoPlayer` -              kompakter Player-Modus in der Bar, Standard false
- `nanoPlrSize` -             Größe des kompakten Players, Standard 200
- `disableCava` -             Equalizer in der Bar deaktivieren, Standard false
- `enableFolders` -           Starten von Plugins im Ordnerformat aktivieren, Standard false

```
Wichtig: config.toml liegt im JES-Ordner (~/.config/JES/)
und kann auch durch Aufruf bearbeitet werden:
	jes-cli editConf
In jes-cli wird micro zur Bearbeitung der Config verwendet; zum Beenden Ctrl+Q, zum Speichern — Ctrl+S
```

## -- Wie *JES* aussieht --:
### Steuerleiste
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/1.webp?raw=true)

### Hintergrundbildauswahl
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/3.webp?raw=true)

### Player
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/4.webp?raw=true)
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/5.webp?raw=true)

### Power-Tasten
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/6.webp?raw=true)

### Jwindow
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/7.webp?raw=true)

### Popup für Lautstärke und Helligkeit
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/8.webp?raw=true)

### Anwendungsstarter
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/9.webp?raw=true)

### Sperrbildschirm
![alt_image](https://github.com/ORFLEM/dots/blob/main/images/10.webp?raw=true)

\* Die Screenshots wurden auf den [Dotfiles des Autors](https://github.com/ORFLEM/dots) gemacht; die Basisvariante kann sich in Hintergrundbildern und im Launcher-Shader von den Screenshots unterscheiden

## -- Plugins --:
### Installation
```
1. ~/.config/JES/ öffnen
2. Plugin-Ordner hineinkopieren
3. config.toml öffnen
4. diese Zeilen eintragen:
   [[plugin]]
   name = "plugin name" # data in property name from manifest.json
   uuid = "uuidv4" # data in property uuid from manifest.json
   active = true
```

### [Ausführliche Anleitung zur Plugin-Erstellung](./plugins_deu.md)
### [Anleitung zur Erstellung von WM-Adaptern](./wm_deu.md)

### [Plugin-Repository](./plugin_repo.md)
### [Unterstützte WM](./wm_repo.md)
### Wichtig: das Plugin-Repository und die unterstützten WM sind nur auf Englisch dokumentiert, da dieser Teil stark von der Community des Projekts beeinflusst wird und die Übersetzung aller Kurzbeschreibungen in verschiedene Sprachen unerträglich aufwendig ist

## -- JES-Installation --:
### NixOS
- im `flake` Folgendes angeben:
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
- Flake neu bauen
- in `configuration.nix` Folgendes angeben:
```nix
programs.jes = {
  enable = true;
  # autoStart = true;  # default - false
};
```
- NixOS neu bauen

### Fedora
Fertige RPMs (und SRPMs) werden für jeden Tag auf [GitHub Releases](https://github.com/ORFLEM/just_enough_shell/releases) veröffentlicht.
Build aus dem Quellcode: `packaging/fedora/jes.spec`.

### ALT Linux
Fertige RPMs (und SRPMs) werden für jeden Tag mit der Markierung alt1 auf [GitHub Releases](https://github.com/ORFLEM/just_enough_shell/releases) veröffentlicht.
Build aus dem Quellcode: `packaging/alt/jes-shell.spec`.

### Debian / Ubuntu
Ein fertiges `.deb` wird für jeden Tag auf [GitHub Releases](https://github.com/ORFLEM/just_enough_shell/releases) veröffentlicht.

### Nach der Installation (alle Distributionen außer NixOS)
- Start: `jes-cli start-daemon`
- Autostart: `systemctl --user enable --now jes`

### Arch Linux
```bash
git clone https://github.com/ORFLEM/just_enough_shell.git
cd just_enough_shell/packaging/arch
makepkg -si
```

### Manuelle Installation auf Arch (Reservevariante)
```
1. Arch Linux installieren (zur Vereinfachung empfehle ich EndeavourOS)
2. yay oder paru installieren (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Offizielle Software installieren (sudo pacman -Syu && pacman -S $(cat ./installer/arch_official.txt))
4. Benutzer-Software installieren (yay -S $(cat ./installer/arch_aur.txt))
5. .local und .config in die entsprechenden Ordner klonen
6. Die gesamte Go-Software aus for-quickshell bauen; was wohin geht, siehe flake.nix
```

## -- Nachbarprojekte --:
- [blxshell](https://github.com/binarylinuxx/dots/tree/main) - dots like desktop shell vom Autor von ZWWM

## -- Lizenz --:
Diese Konfigurationen werden unter der **BSD 3-Clause License** verbreitet.

In einfachen Worten bedeutet das:
- Du kannst mit dem Code alles machen, aber der Autor behält die Urheberrechte am Projekt.
- Du bist verpflichtet, das Originalprojekt und den Autor in einem Fork anzugeben, auch wenn er Closed-Source ist.
- Du darfst die Person des Autors (Nickname, andere Erwähnungen) nicht ohne Erlaubnis zur Promotion deiner Version des Projekts verwenden.

Dies garantiert, dass der Name des Autors und des Projekts immer genannt werden und der Name des Autors nicht zum Werkzeug zur Promotion fremder Forks wird.

Vollständiger Lizenztext siehe in der Datei [LICENSE](./LICENSE).

##### Created by [\_ORFLEM\_](https://github.com/ORFLEM)

##### Translated by [Kimi K3](https://www.kimi.com/en?chat_enter_method=new_chat)
