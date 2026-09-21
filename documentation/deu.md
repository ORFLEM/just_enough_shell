<div align="center">
	<img src="https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Letzter%20Commit&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="GitHub last commit">
    <img src="https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=bbbbbb&label=Projektgr%C3%B6%C3%9Fe&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
    <img src="https://img.shields.io/github/stars/ORFLEM/just_enough_shell?color=bbbbbb&label=Projekt-Sterne&logo=andela&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
	<img src="./images/preview.webp" width="900px">
	<h1>> Just Enough Shell _</h1>
	<p>Für den Alltag gebaut, nicht für Screenshots.</p>
</div>

***

<div align="center">
	<h3>-- Über -- :</h3>
	<p>
	<i>JES</i> - WM-agnostische Rolling-Release Desktop-Shell, die das native Anbinden beliebiger WM unterstützt, auch selbstgeschriebene.<br>
  <br>
	<i>JES</i> unterstützt out of the box:
	<ul>
  	<li><a href="https://github.com/wlrfx/swayfx">SwayFX</a></li>
  	<li><a href="https://hypr.land/">Hyprland</a></li>
  	<li><a href="https://github.com/niri-wm/niri">Niri</a></li>
		<li><a href="https://github.com/malbiruk/driftwm">DriftWM</a></li>
		<li><a href="https://github.com/binarylinuxx/zwwm">ZWWM</a></li>
		<li>Jeden anderen über das Plugin-System (siehe <a href="./plugin_repo.md">plugin_repo.md</a>)</li>
	</ul>
	<br>
	Das Projekt ist optimiert, wurde aber nicht auf <b>sehr</b> schwachen PCs getestet.<br>
	Go-Binaries werden für Skripte verwendet, bei denen schnelles Lesen großer Datenströme wichtig ist; dank dessen beträgt die CPU-Last im Leerlauf für <i>JES</i> 1–2 % und ~450 MB RAM, statt 35–45 %.<br>
  <br>
	Das Projekt hat ein einfaches Plugin-System, das es erweiterbar macht.<br>
	<br>
	<i>JES</i> wurde für Desktop-PCs entwickelt, weshalb es bei Laptops zu architektonischen Problemen kommen kann.<br>
	Verifizierte Auflösungen: FHD (1920×1080) und höher.<br>
	Bei diesen hat die Leiste keine Probleme mit der Platzierung der Module.<br>
	Mehrere Monitore werden nativ unterstützt.<br>
	<br>
	Das Projekt hat den Wechsel von eww zu qs überlebt und wird nicht aufgegeben, da es untrennbar mit dem Alltag des Autors und den Anfragen der Community verbunden ist; es wird sich weiterentwickeln und verbessern.<br>
	<br>
  <i>JES orientiert sich nicht an Trends, sondern an Praktikabilität im Alltag und Bequemlichkeit.</i><br>
	</p>
	<h3>-- Danksagungen -- :</h3>
	<p>
	Danke an <b><a href="https://github.com/binarylinuxx/dots">Blxshell</a> und seinen Autor</b> für die Hilfe beim Erlernen von Quickshell und die Domain für die Website.<br>
	Danke an <b><a href="https://github.com/f026/">f026</a></b> für das <a href="https://github.com/f026/activate-linux-plugin">erste Plugin</a> für JES.<br>
	Danke an <b><a href="https://github.com/malbiruk/driftwm">DriftWM-Autor (malbiruk)</a></b> für die Hilfe mit DriftWM-IPC, das Hinzufügen neuer Funktionen zum WM für JES und im Allgemeinen die Loyalität zum Projekt.<br>
  Danke an <b><a href="https://github.com/frosti-4">frosti-4</a></b> für das Arch-Linux-Skript.<br>
  Danke an <b><a href="https://github.com/Gegs8">Gegs8</a></b> für das Finden von Installer-Bugs.<br>
	</p>
	<h3>-- Zukünftige Richtung -- :</h3>
	<p>
  <b>[c]</b> API-Entwicklung für die Arbeit mit dem Launcher<br>
  <b>[c]</b> API-Entwicklung für die Arbeit mit dem Plugin-Center<br>
	<b>[c]</b> Erstellung eines Wetter-Widgets<br>
	<b>[c]</b> Erstellung einer vollständigen API<br>
	<b>[c]</b> JES-Installation über Flake<br>
	<b>[c]</b> Überarbeitung der Unterleiste<br>
	<b>[c]</b> Neue Methode zum Anbinden benutzerdefinierter WM<br>
	<b>[c]</b> Neues Plugin-Format<br>
	<b>[i]</b> Entwicklung der Community und Infrastruktur<br>
	<b>[i]</b> Systemmodul `CoreAura` zur PC-Zustandskontrolle (Kernel-Fehler, Service-Abstürze, Lastüberwachung)<br>
  <b>[n]</b> API-Entwicklung für die Arbeit mit der Bar<br>
	<b>[n]</b> Dunkel-/Hell-Themenauswahl<br>
	c = abgeschlossen; n = nicht abgeschlossen; i = in Arbeit; p = geplant.<br>
	</p>
</div>

Vergangene abgeschlossene Aufgaben ansehen — [complited.md (nur englisch)](./complited.md)

> **Für wen ist *JES*?**
> - Desktop-PCs mit FHD+-Auflösung (der Autor nutzt UWQHD — 3440×1440 und betrachtet dies als Benchmark für das Projekt)
> - Nutzer von SwayFX / Hyprland / Niri / DriftWM / ZWWM oder Enthusiasten mit Zeit für die Ersteinrichtung (die Shell selbst funktioniert mit jedem WM, aber Tiling-Binds und -Einstellungen fehlen dann)
> - Ein WM-Entwickler, der eine Basisumgebung für seinen WM braucht, ohne monatelang mit waybar, rofi und anderen Programmen zu arbeiten
> - Diejenigen, die Performance und Architektur über Trends stellen
> - Wer eine angenehme und leichtgewichtige CPU/RAM-Oberfläche braucht
>
> Wenn du zu dieser Zielgruppe gehörst — willkommen.
> Wenn nicht — das Projekt ist vielleicht nichts für dich, und das ist okay.

## -- WICHTIG -- :
- Alle Performance-Tests wurden auf r7 5700x und r5 3600 durchgeführt; auf beiden CPUs war der Prozentsatz gleich: 1–2 %, aber es ist besser, über KI oder Vergleichsseiten die Leistung der eigenen CPU zu prüfen, um die ungefähre Last zu verstehen.
- Nvidia-Grafikkarten funktionieren SCHRECKLICH, **alles kann sofort ohne Grund einfrieren**, der Autor wird dieses Problem nicht lösen, da es sich um ein **Treiberproblem** handelt!
- Der Autor hat keine Erfahrung mit Arch Linux; die Installation auf Arch kann fehlerhaft sein, falls ja, bitte das Problem in einem Issue beschreiben und falls möglich einen Fix vorschlagen.
- Die Installationsanleitung befindet sich ganz unten.
- Der Autor ist offen für Vorschläge und hilft beim Einstieg in das Projekt; bei Problemen bitte in [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new) schreiben.
- Der Autor wäre dankbar für Hilfe bei der Unterstützung anderer Distributionen und nimmt neue Pull Requests sofort an, wobei der Autor der Unterstützung genannt wird; gefragt sind unter anderem void linux, alt linux und debian.

## [JES-Struktur](./structure_de.md)

## -- Was sich in *JES* ändert --:
- `wm` — auto, aber für die Anbindung eines WM, der nicht in der Liste steht, muss der Name mit Großbuchstabe geschrieben werden
- `wm_type` — auto, aber für WM, die nicht in der Liste stehen, wähle workspaces oder coordinates
- `mainRad` — Eckenradius, Standard 10, funktioniert perfekt mit Werten 0–25
- `barOnTop` — Steuerleiste oben sowie angrenzende Widgets, standardmäßig aktiviert
- `minibar` — macht die Leiste 1920 px breit, standardmäßig deaktiviert
- `BarHeight` — Leistenhöhe, Standard 30
- `fontSize` — Schriftgröße, Standard 17
- `fontFamily` — Schriftart, Standard Mononoki Nerd Font Propo
- `custom_wallpaper_engine` — integrierte Hintergrundbilder deaktivieren, Standard false
- `disableGenerate` — JES-matugen-Theme auf base16 umschalten, Standard false
- `doNotDisturb` — Ruhemodus, Standard false
- `timezone` — Stadt für das Wetter-Widget, standardmäßig nicht vorhanden, Daten werden aus der `user-config.toml`-Konfiguration von NixOS bezogen
- `animation` — Animationsgeschwindigkeit, Fließkommazahl, Standard 1.0
- `wtw` — Abstand von Widget zu Widget, Standard 6
- `spacing` — Abstand zwischen Blöcken innerhalb eines Widgets, Standard 3
- `margins` — Ränder in Widgets, Standard 3
- `disableCorners` — Monitor-Eckenabrundung deaktivieren, standardmäßig deaktiviert
- `openweather_key` — Schlüssel für die OpenWeather-API, keine Standarddaten
- `do_not_sync_rad` — WM-Radien nicht mit JES-Radius synchronisieren, Standard false
- `changeShader` — Standard-Shader durch einen anderen ersetzen, Standard leer, aber es muss der Pfad zu einer **qsb**-Datei eingegeben werden
- `nanoPlayer` — Kompakter Player-Modus in der Bar, Standard false
- `nanoPlrSize` — Größe des kompakten Players, Standard 200
- `disableCava` — Equalizer in der Bar deaktivieren, Standard false
- `enableFolders` - Plugins im Ordnerformat starten, Standard false
- `changeShader` - den Shader im Launcher durch einen eigenen ersetzen, standardmäßig leer

```
Wichtig: config.toml liegt im JES-Ordner (~/.config/JES/)
und kann auch durch Aufruf bearbeitet werden:
	jes-cli editConf
In jes-cli wird micro zur Bearbeitung der Config verwendet; zum Beenden Ctrl+Q, zum Speichern — Ctrl+S
```

## -- Wie *JES* aussieht --:
### Steuerleiste
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Hintergrundbildauswahl
![alt_image](./images/3.webp)

### Player
![alt_image](./images/4.webp)
![alt_image](./images/5.webp)

### Power-Tasten
![alt_image](./images/6.webp)

### Jwindow
![alt_image](./images/7.webp)

### Popup für Lautstärke und Helligkeit
![alt_image](./images/8.webp)

### Anwendungsstarter
![alt_image](./images/9.webp)

### Sperrbildschirm
![alt_image](./images/10.webp)
![alt_image](./images/11.webp)

\* Screenshots aufgenommen auf den [Dotfiles des Autors](https://github.com/ORFLEM/dots)

## -- Plugins --:
### Installation
```
1. ~/.config/JES/ öffnen
2. Plugin-Ordner hineinkopieren
3. config.toml öffnen
4. diese Zeilen eintragen:
   [[plugin]]
   name = "plugin name" # data in property name from manifest.json
   active = true
```

### [Ausführliche Anleitung zur Plugin-Erstellung](./plugins_de.md)

### [Plugin-Repository](./plugin_repo.md)
### Wichtig: das Repository ist nur auf Englisch verfügbar, da dieser Teil stark von der Community des Projekts beeinflusst wird und die Übersetzung aller Kurzbeschreibungen in verschiedene Sprachen unerträglich aufwendig ist.

## -- JES-Installation --:
### NixOS
- In `flake` folgendes hinzufügen:
```nix
{{
	inputs = {{
    jes.url = "github:ORFLEM/just_enough_shell";
	}}
	outputs = {{ your inputs, jes, ... }}@inputs:
  let
    system = "x86_64-linux";
    hostname = "nixos";

    specialArgs = {{ inherit inputs system hostname; }};

  in {{
    nixosConfigurations.${{hostname}} = nixpkgs.lib.nixosSystem {{
      inherit system specialArgs;
      modules = [
				jes.nixosModules.default
			];
		}};
	}};
}}
```
- Flake neu bauen
- In `configuration.nix` hinzufügen:
```nix
services.jes = {{
  enable = true;
  users = [ "your user" ];
}};
```
- NixOS neu bauen

### Arch Linux oder Arch-basiert (kann fehlerhaft sein; bei Problemen bitte in [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new) schreiben)
- Arch Linux installieren (zur Vereinfachung empfehle ich EndeavourOS)
<!-- - Installer ausführen (nicht überarbeitet): -->
<!-- ```bash -->
<!-- git clone https://github.com/ORFLEM/just_enough_shell.git && cd just_enough_shell && ./install_arch.sh -->
<!-- ``` -->

<!-- - Bei Fehlern manuell installieren: -->
- Installation ist nur manuell möglich, automatisch ist defekt:
```
1. Arch Linux installieren (zur Vereinfachung empfehle ich EndeavourOS)
2. yay oder paru installieren (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Offizielle Software installieren (sudo pacman -Syu && pacman -S $(cat ./installer/arch_official.txt))
4. Benutzer-Software installieren (yay -S $(cat ./installer/arch_aur.txt))
```

## -- Lizenz --:
Die Benachrichtigungen wurden aus dem Projekt [blxshell](https://github.com/binarylinuxx/dots) übernommen und sowohl visuell als auch teilweise technisch modernisiert; Lizenz der Benachrichtigungen — **GNU GPL v3**
Ich empfehle, es sich anzusehen.

Diese Konfigurationen werden unter der **BSD 3-Clause License** verbreitet.

In einfachen Worten bedeutet das:
- Du kannst mit dem Code alles machen, aber der Autor behält die Urheberrechte am Projekt.
- Du bist verpflichtet, das Originalprojekt und den Autor in einem Fork anzugeben, auch wenn er Closed-Source ist.
- Du darfst die Person des Autors (Nickname, andere Erwähnungen) nicht ohne Erlaubnis zur Promotion deiner Version des Projekts verwenden.

Dies garantiert, dass der Name des Autors und des Projekts immer genannt werden und der Name des Autors nicht zum Werkzeug zur Promotion fremder Forks wird.

Vollständiger Lizenztext siehe in der Datei [LICENSE](./LICENSE).

##### Created by [\_ORFLEM\_](https://github.com/ORFLEM)

##### Translated by [Kimi K3](https://www.kimi.com/en?chat_enter_method=new_chat)
