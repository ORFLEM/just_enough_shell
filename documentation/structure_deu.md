# Architektur und modulare Struktur von *JES*

## Architekturprinzipien
- **Trennung von UI und Logik**: QML (Quickshell) ist nur für Rendering und Eingabe verantwortlich. Die gesamte Datenverarbeitung, das IPC-Parsing und Systemaufrufe sind in separate Module ausgelagert.
- **Zweckbasierte Modularität**: Jede UI-Komponente (Bar, Launcher, Benachrichtigungen usw.) ist in einem eigenen Ordner isoliert. Minimale gegenseitige Abhängigkeiten.
- **Ereignisgesteuertes Modell (subscribe)**: Statt Polling in Bash-Schleifen werden langlebige Verbindungen über Go-Binaries verwendet, die auf Ereignisse von WM/MPD/System subscribieren.
- **Stabile Shell-Schicht**: Skripte sind in POSIX sh/bash geschrieben. Keine Abhängigkeit von fish/zsh-Runtime, Plugins oder interaktiven Features.
- **Dynamisches Theme**: `base16.json` verwendet die Zenburn-Palette. `colors.json` ist für Verlaufshintergründe, Text- und Akzentfarben verantwortlich; alles wird dank `matugen` aus dem Hintergrundbild extrahiert.

## -- Projektbaum und Zweck der Module --:
```
./quickshell/
├── shell.qml                 # Quickshell-Einstiegspunkt. Registriert und positioniert Module.
├── bar/                      # Leiste.
│   ├── components/           # Panel-Popups + Workspace-Schaltflächen.
│   └── images/               # Statische Icons, Assets.
├── launcher/                 # Anwendungsstarter: Suche, Kategorien, Hintergrund-Shader, Go-Backend.
├── wallpaper/                # Auswahl und Rendering von Hintergrundbildern: Vorschau, Anwendung, TOML-Config, Rendering.
├── notifications/            # Benachrichtigungs-Daemon.
├── popSysInf/                # Popup mit Systeminformationen (Helligkeit, Lautstärke).
├── power/                    # Sitzungsmenü: Herunterfahren, Neustart, Standby, Abmelden, Sperren.
├── helpers/                  # QML-Helfer.
├── screenpicker/             # Screenshot-Tool.
├── lockScreen/               # Sperrbildschirm.
├── CoreAura/                 # Peripheres Benachrichtigungssystem für den Benutzer über Systemfehler oder dessen Zustand.
└── scripts/                  # Logik-Kern: kompilierte Go-Binaries + Bash-Skripte.
```

## -- Datenfluss und IPC --:
1. **Initialisierung**: `shell.qml` startet das Modul. Jedes Modul ruft beim Start das entsprechende Skript aus `scripts/` auf.
2. **Datenerfassung**:
   - Go-Binaries (`music`, `Cava-internal`, `cal`) übernehmen Logik mit großen Datenmengen, die verarbeitet werden müssen.
   - Bash-Skripte (`brightness.sh`, `vol.sh`, `workspace-*.sh`, ...) sind die Hauptlogik, gemacht für Systemportabilität und Lesbarkeit.
3. **Lieferung an die UI**: Daten werden über `stdout` übertragen (JSON, oder für visuelle Programme einfach eine Zeichenkette wie bei cava) → in QML über `JsonListen`/`JsonPoll` geparst → aktualisieren Widget-Eigenschaften.
4. **Rückmeldung**: Benutzeraktionen (Klick, Hotkey) → Aufruf von Skript/Binary → Befehl an WM/MPD/PipeWire → Ereignis aktualisiert die UI.

## -- Stack und Optimierung --:
| Schicht | Technologie | Rolle |
|------|------------|------|
| WM | swayfx, DriftWM, Hyprland, Niri | Tiling, Effekte, IPC |
| UI | Quickshell (Qt Quick / QML) | Rendering, Animationen, Eingabe |
| Backend | Go 1.21+ | Logik, die große Datenmengen verarbeitet |
| Shell | Bash 5.x / POSIX sh | Hauptlogik |
| Theme | base16 + matugen | Statische Palette + dynamisches Theme |
| Audio | PipeWire (pamixer & pactl) + JES music service | Lautstärkeanzeige, Backend der Audioeinstellungen, MPRIS |

**Metriken**: CPU im Leerlauf ~1-2% & ~450 MB RAM. Binaries sind statisch gelinkt, Logikgröße ~3,5-4,5 MB.

## -- WM-Kompatibilitätsschicht --:
Die Tiling-Abstraktion ist über drei Skriptpaare und eine Datei zur Anbindung an shell.qml realisiert:
- `active_window-{sway,hypr,niri,driftwm,zwwm}.sh`
- `kb_layout-{sway,hypr,niri,driftwm,zwwm}.sh`
- `workspace-{sway,hypr,niri,zwwm}.sh`
- `camera-{driftwm,zwwm}.sh`
- `{Sway,Hypr,niri,Drift,ZWWM}Bar.qml` im Unterordner quickshell/bar/

Quickshell erkennt den aktuellen WM über `$XDG_CURRENT_DESKTOP` und routet Aufrufe zum passenden Skript. Für ein Portieren auf einen neuen Tiling-WM genügt es, die Ausgabe im gleichen JSON-Format zu implementieren und ein Mapping hinzuzufügen.

## -- Erweiterung --:
1. **Neues Widget**: Ordner `widget_name/` anlegen → QML-Komponente + Backend (Go/sh) → in `shell.qml` registrieren.
2. **Theme wechseln**: `matugen`-Config bearbeiten (man kann auch `base16.json` umschreiben, aber es beeinflusst den visuellen Teil von *JES* kaum) → Palette neu generieren.
3. **WM hinzufügen**: IPC-Parser nach der Ausgabespezifikation bestehender Skripte implementieren → ins Routing aufnehmen.
4. **Optimierung**: Polling-Skript durch Go-Binary mit `subscribe` ersetzen → Aufruf in QML aktualisieren.

## -- Sonstiges --:
- UI-Schicht (QML): **BSD 3-Clause Licence**
- Skripte und Binaries: **BSD 3-Clause Licence**
- Persistente Ausgabe von Skripten/Binaries wird zur Performanceverbesserung bevorzugt
- Assets (Shader, Go-Quellen, leere Skript-Stubs und eine QML-Stub-Datei zum Anbinden eines anderen Tiling-WMs): siehe `for-quickshell/`

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
