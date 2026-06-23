# Architektur und modulare Struktur von *JES*

##  Architekturprinzipien
- **Trennung von UI und Logik**: QML (Quickshell) ist ausschließlich für Rendering und Eingabe zuständig. Die gesamte Datenverarbeitung, das IPC-Parsing und Systemaufrufe sind in separate Module ausgelagert.
- **Modularität nach Zweck**: Jede Komponente der Oberfläche (Leiste, Launcher, Benachrichtigungen usw.) ist in einem eigenen Ordner isoliert. Minimale Querabhängigkeiten.
- **Ereignisbasiertes Modell (subscribe)**: Statt Polling in bash-Schleifen werden langlebige Verbindungen über Go-Binärdateien verwendet, die Ereignisse von WM/MPD/System abonnieren.
- **Stabile Shell-Schicht**: Die Skripte sind in POSIX sh/bash geschrieben. Keine Abhängigkeiten von der fish/zsh-Runtime, Plugins oder interaktiven Features.
- **Dynamisches Theme**: `base16.json` verwendet die zenburn-Palette. `colors.json` ist für Gradienten-Hintergründe, Text und Akzentfarben zuständig – alles wird über `matugen` aus dem Hintergrundbild extrahiert.

## -- Verzeichnisbaum des Projekts und Aufgaben der Module --:
```
.
├── shell.qml                 # Einstiegspunkt von Quickshell. Registriert und positioniert die Module.
├── colors.json               # Haupttheme der Oberfläche.
├── base16.json               # Zusätzliches Theme der Oberfläche.
├── bar/                      # Leiste.
├── launcher/                 # App-Launcher: Suche, Kategorien, Hintergrund-Shader, Go-Backend.
├── wallpaper/                # Auswahl und Rendering von Hintergründen: Vorschau, Anwendung, TOML-Konfiguration, Hintergrund-Rendering.
├── notifications/            # Benachrichtigungs-Daemon.
├── popSysInf/                # Popup für Systeminformationen (Helligkeit, Lautstärke).
├── power/                    # Sitzungsmenü: Herunterfahren, Neustart, Ruhezustand, Abmelden, Sperren.
├── helpers/                  # QML-Hilfsfunktionen.
├── scripts/                  # Kernlogik: kompilierte Go-Binärdateien + bash-Skripte.
└── images/                   # Statische Icons, Assets. (derzeit im Verzeichnis bar/ verschachtelt, wird später korrigiert)
```

## -- Datenfluss und IPC --:
1. **Initialisierung**: `shell.qml` startet die Module. Jedes Modul ruft beim Start das entsprechende Skript aus `scripts/` auf.
2. **Datenerfassung**: 
   - Go-Binärdateien (`music`, `Cava-internal`, `cal`) übernehmen die Logik für große Datenmengen, die verarbeitet werden müssen.
   - Bash-Skripte (`brightness.sh`, `vol.sh`, `workspace-*.sh`) bilden die Kernlogik – aus Gründen der Portabilität und Lesbarkeit.
3. **Übermittlung an die UI**: Die Daten werden über `stdout` übertragen (JSON oder bei visuellen Programmen einfach ein String (wie bei cava)) → werden in QML über `JsonListen`/`JsonPoll` geparst → aktualisieren die Eigenschaften der Widgets.
4. **Rückkopplung**: Benutzeraktionen (Klick, Hotkey) → Aufruf eines Skripts/Binärfiles → Senden eines Befehls an WM/MPD/pipewire → ein Ereignis aktualisiert die UI.

## -- Stack und Optimierung --:
| Schicht | Technologie | Rolle |
|------|------------|------|
| WM | swayfx (primary), Hyprland, Niri (WIP) | Tiling, Effekte, IPC |
| UI | Quickshell (Qt Quick / QML) | Rendering, Animationen, Eingabe |
| Backend | Go 1.21+ | Logik zur Verarbeitung großer Datenmengen |
| Shell | Bash 5.x / POSIX sh | Kernlogik |
| Theme | base16 + matugen | Statische Palette + dynamisches Theme |
| Lock | Hyprlock | Sperrbildschirm |
| Audio | PipeWire + wpctl/pavucontrol | Mixing, MPRIS, Cava |

**Metriken**: CPU im Leerlauf ~5–11% (Go subscribe) gegenüber 35–45% (bash polling). Die Binärdateien sind statisch gebaut, das Gewicht der Logik beträgt ~8-8.5 MB.

## -- WM-Kompatibilitätsschicht --:
Die Abstraktion vom Tiling wird über drei Skript-Paare und eine Datei zur Anbindung an shell.qml realisiert:
- `active_window-{sway,hypr,niri}.sh`
- `kb_layout-{sway,hypr,niri}.sh`
- `workspace-{sway,hypr,niri}.sh`
- `{Sway,Hypr,niri}Bar.qml` im Quickshell-Ordner, Unterverzeichnis bar/

Quickshell ermittelt den aktuellen WM über `$XDG_CURRENT_DESKTOP` und leitet die Aufrufe an das passende Skript weiter. Um auf einen neuen Tiling-WM zu portieren, genügt es, die Ausgabe im gleichen JSON-Format zu implementieren und das Mapping zu ergänzen.

## -- Erweiterung --:
1. **Neues Widget**: Ordner `widget_name/` erstellen → QML-Komponente + Backend (Go/sh) → in `shell.qml` registrieren.
2. **Theme wechseln**: Die `matugen`-Konfiguration bearbeiten (optional kann auch `base16.json` angepasst werden, hat aber kaum Einfluss auf die visuelle Seite von *JES*) → Palette neu generieren.
3. **WM hinzufügen**: Einen IPC-Parser gemäß der Ausgabespezifikation der bestehenden Skripte implementieren → ins Routing aufnehmen.
4. **Optimierung**: Das Polling-Skript durch eine Go-Binärdatei mit `subscribe` ersetzen → den Aufruf in QML aktualisieren.

## -- Sonstiges --:
- UI-Schicht (QML): GPL-3.0
- Skripte und Binärdateien: GPL-3.0
- Für bessere Performance wird eine kontinuierliche Ausgabe der Skripte/Binärdateien bevorzugt
- Assets (Shader, Go-Quellcode, leere Platzhalter-Skripte sowie eine Platzhalter-qml-Datei zur Anbindung eines anderen Tiling-WM): siehe `for-quickshell/`

## -- Plugins --:
### Installation
```
1. Öffnen Sie ~/.config/quickshell/
2. Legen Sie den Plugin-Ordner dort ab
3. Öffnen Sie config.toml
4. Tragen Sie folgende Zeilen ein:
   [plugin.name-plugin]
   source = "Plugin-Ordner/Hauptdatei-des-Plugins.qml"
   active = true
```

### [Ausführliche Anleitung zur Plugin-Erstellung](./plugins_deu.md)
