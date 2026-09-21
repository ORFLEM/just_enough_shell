# Anleitung zur Plugin-Erstellung

## Regel Nr. 1
- Ein Plugin befindet sich **immer** in einem eigenen, separaten Ordner.

## Regel Nr. 2
- Ein Plugin **darf nicht** viele Ressourcen des Geräts verbrauchen; zur Optimierung ist jede Sprache erlaubt, aber **Go wird empfohlen**.

## Regel Nr. 3
- Dateinamen im Plugin erklären kurz, wozu sie dienen, und die einzubindende Datei **wird in der Installationsanleitung des Plugins angegeben**.
- Wenn das Plugin komplexe Funktionalität in einem separaten Fenster hat, muss das Fenster in einem lazyLoader sein.

## Regel Nr. 4
- Im Plugin werden **ausschließlich relative Pfade** verwendet.

## Erstellen, Bauen und Dekompilieren eines Plugins

- In der Konsole folgenden Befehl eingeben:
```bash
jes-cli initPlugin <PluginName>
```

Dies erstellt eine Plugin-Vorlage.

- Nachdem das Plugin zur Veröffentlichung bereit ist, eingeben:
```bash
jes-cli makePlugin <PluginName>
```

- Wenn die Quellen gelöscht wurden oder ein fremdes Plugin geändert werden soll, eingeben:
```bash
jes-cli debuildPlugin <PluginName>
```

- Plugin-Status kann mit folgendem Befehl abgefragt werden:
```bash
jes-cli getPlugin
```

- Wenn ein Plugin zur Laufzeit kaputt geht, landet es auf der Start-Blacklist; zum Prüfen der Details gibt es:
  blacklistAdd <name>          - Plugin zur Blacklist hinzufügen (status=broken)
  blacklistRemove <name>       - Plugin von der Blacklist entfernen
  blacklistList                - Blacklist anzeigen
  blacklistClear               - Gesamte Blacklist löschen

## Visueller Teil
- Für den Haupt-Hintergrund im Plugin verwendet man:
```qml
Rectangle {
    opacity: 0.85
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: col.background3 }
        GradientStop { position: 0.05; color: col.background2 }
        GradientStop { position: 0.3; color: col.background1 }
        GradientStop { position: 0.7; color: col.background1 }
        GradientStop { position: 0.95; color: col.background2 }
        GradientStop { position: 1.0; color: col.background3 }
    }
}
```
- Und für Schaltflächen-Hintergründe und ähnliches:
```qml
Rectangle {
    opacity: 0.65
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: col.backgroundAlt2 }
        GradientStop { position: 0.275; color: col.backgroundAlt1 }
        GradientStop { position: 0.725; color: col.backgroundAlt1 }
        GradientStop { position: 1.0; color: col.backgroundAlt2 }
    }
}
```
- Für Hover-Effekte verwendet man:
```qml
Item {
    id: button
    property bool hovered: false
    Rectangle {
        anchors.fill: parent
        radius: mainRad - root.margins
        opacity: 0.65
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: col.backgroundAlt2 }
            GradientStop { position: 0.275; color: col.backgroundAlt1 }
            GradientStop { position: 0.725; color: col.backgroundAlt1 }
            GradientStop { position: 1.0; color: col.backgroundAlt2 }
        }
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: mainRad - 2 - root.margins // alle margins zusammenzählen
        color: button.hovered ? col.accent : "transparent"
        Behavior on color { ColorAnimation { duration: 200 * root.animations } }
    }
    // code
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            button.hovered = true
        }
        onExited: {
            button.hovered = false
        }
    }
}
```

> Der Hintergrund kann anders sein; im Beispiel wurde der Hintergrund für Schaltflächen verwendet.

- Für Radien verwendet man `radius: mainRad`; wenn man margins macht, schreibt man im nächsten Block `radius: mainRad - <margin_zahl>`.
- Alle Farben werden aus dem globalen Objekt `col` genommen (definiert in `colors.json` und verfügbar über `shell.qml`).
- JES unterstützt auch base16-Themen (`base.base<01-16>`).
- Die Schriftart wird mit **fontFamily** und **fontSize** gesetzt.
- JES hat 2 Akzentfarben — dunkel und hell.
- Alle Animationen müssen mit `root.animations` multipliziert werden.
- `root` ist in JES durch `shell.qml` reserviert; seine Verwendung ist strengstens untersagt.

## Datenübertragung an die UI
- Für einen permanenten Stream (empfohlen für Performance) verwendet man `JsonListen`, für eine einmalige Anfrage in einem bestimmten Intervall `JsonPoll`.
- Daten werden im JSON-Format übertragen; für visuelle Programme ohne Funktionen — einfach eine Zeichenkette (z. B. cava in der Bar).
- WM-Daten werden über den Parameter `wm_connect` übertragen; wenn Koordinaten/Workspaces/aktives Programm/Layout benötigt werden — ruft man `wm_connect` auf, welche Daten daraus entnommen werden können, siehe `BaseBar.qml`.

## JES-Bibliotheken
- Zur Vereinfachung der Plugin-Erstellung wurden die Bibliotheken `JES.Helpers` und `JES.Bar` erstellt — die erste wird für Aufrufe von `JsonListen`, `JsonPoll` und `MarqueeText` benötigt, die zweite — für Integration mit `BaseBar.qml`, d. h. zum Erstellen von Plugins zum Anbinden von WMs an JES (siehe unten).

### Wenn etwas unklar ist, schaue in die Datei `baseBar.qml` im Ordner bar; sie ist der visuelle Maßstab für die gesamte UI.

## Anbindung eines Plugins an JES

- Für die Anbindung an JES muss das Plugin eine `manifest.json` haben; unten ist die maximale Basisvariante für JES ohne Drittanbieter-Erweiterungen:
```json
{
  "api_version": "0.2.0",
  "plugin_version": "1.0",
  "name": "plugin name",
  "api_request": [
    "api_extending",
    "launcher",
    "plugin_center",
    "osd",
    "Jwindow",
    "wm_connect"
  ],
  "main_source": "Main.qml",
  "required_settings": [],
  "json_files": {
    "launcher": "launch_list.json",
    "plugin_center": "load_list.json",
    "osd": "osd_list.json",
    "Jwindow": "Jwindow.json"
  }
}
```

- `api_version` ist die API, mit der das Plugin arbeitet; sie muss mit der aktuellen API nach semver übereinstimmen; beim Wechsel auf eine neue API sollte diese Datei überprüft werden.
- **Die API ist derzeit instabil; jedes 5. Minor-Update ist ein Major-Update.**
- *Semver bedeutet major.minor.patch, wobei major = breaking changes, minor = Ergänzungen, patch = Bugfixes.*

- Zur Aktivierung des Plugins in `config.toml` in `~/.config/JES/` folgendes angeben:
```toml
[[plugin]]
name = "plugin name" # data in property name from manifest.json
active = true
```

- Darüber hinaus können im selben toml-Block eigene Parameter angegeben werden, indem deren Namen in der JSON-Liste `required_settings` aufgeführt werden.
- Zur Übernahme der Daten wird folgende QML-Verbindung verwendet:
```qml
Item {
    id: confParameters

    // Hier legt JES die Werte aus dem [[plugin]]-Block von config.toml ab
    property var requiredSettings: ({})

    readonly property int      numbers:      requiredSettings["numbers"]      ?? 3
    readonly property bool     enabled:      requiredSettings["enabled"]      ?? false
    readonly property real     float:        requiredSettings["float"]        ?? 1.0
    readonly property string   text:         requiredSettings["text"]         ?? "hi"

    // Debug
    onRequiredSettingsChanged: {
        console.log("[myplugin] settings:", JSON.stringify(requiredSettings))
    }
}
```
- Damit diese Schlüssel das Plugin erreichen, listet der Autor sie im Manifest auf:
```json
"required_settings": ["numbers", "enabled", "float", "text"]
```

- Und der Benutzer füllt sie im `[[plugin]]`-Block von `config.toml` aus:
```toml
[[plugin]]
name = "myplugin"
active = true
numbers = 5
enabled = true
float = 3.14
text = "hello"
```

## Anbindung an den JES-Launcher
- Für die Anbindung an den Launcher verwenden wir eine JSON-Datei mit folgender Struktur:
```json
{
  "name": "tab",
  "icon": "",
  "placeholder": "Search in tab...",
  "info": [
    {
      "id": "app_1",
      "name": "app 1",
      "exec": "script launch $id"
    },
    {
      "id": "2",
      "name": "take screenshot",
      "exec": "grim ~/screenshots"
    }
  ]
}
```

- In `info` können wir eine beliebige Liste übergeben, die folgende Felder enthält: `{"id", "name", "icon", "exec"}` — das sind die Namen der JSON-Parameter.

- In `id` übergeben wir den benötigten Parameter für das Skript oder eine fortlaufende Nummer; zwingend als String.
- In `name` den Text, der im Block angezeigt wird.
- In `icon` das Icon, falls vorhanden.
- In `exec` den Befehl, der ausgeführt wird; wenn `id` verwendet wird, kann er im Befehl als `$id` referenziert werden, der aus der in JSON angegebenen `id` entnommen wird.

### `id` ist nicht erforderlich, wenn du für das Objekt vollständige Befehle angibst. Es wird benötigt, wenn du ein Skript erstellt hast, das verschiedene Objekte starten soll.

## Anbindung an das JES-Plugin-Center
- Für die Anbindung an das Plugin-Center verwenden wir eine JSON-Datei mit folgender Struktur:
```json
[
    {"source": "Content.qml", "colSpan": 1, "rowSpan": 1}
]
```

- Maximale Größen sind `colSpan: 3, rowSpan: 7`.
- In `source` kann ein beliebiges Modul übergeben werden.

## Anbindung an JES OSD
- Für die Anbindung an OSD verwenden wir eine JSON-Datei mit folgender Struktur:
```json
[
  {
    "id": "mic_volume",
    "type": "percent",
    "command": "./mic.sh"
  },
  {
    "id": "media_status",
    "type": "text",
    "command": "./media.sh"
  }
]
```
- `type` steuert das Anzeigeformat: `text` — Anzeige von Textinformationen, `percent` — Anzeige eines Balkens und Prozentwerts; am Anfang kann ein Icon platziert werden.
- In `command` übergeben wir Skripte, die für `text` — eine Textnachricht ausgeben:
  ```json
  {
      "text": "hi"
  }
  ```
  und für `percent` übergeben wir:
  ```json
  {
      "value": 55,
      "sign": "󱄅"
  }
  ```

## Anbindung an JES Jwindow
- Für die Anbindung an Jwindow verwenden wir ebenfalls JSON mit folgenden Informationen:
```json
[
 {
      "name": "API Test",
      "source": "JwindowTabTester.qml"
  }
]
```
- In `source`, wie im Plugin-Center, kann ein beliebiges Modul angegeben werden, aber maximale Größen sind auf FHD begrenzt.

## Anbindung anderer WMs an JES
- In `manifest.json` geben wir in `api_request` `wm_connect` an, damit das System nicht nur das Plugin selbst lädt, sondern auch die Panel-Daten, damit auf WM-Daten zugegriffen werden kann.
- Für die Anbindung von WMs an JES habe ich in `for-documentation` ein Beispiel-Plugin hinterlassen, das eine Vorlage zum Anbinden anderer WMs liefert; es genügt, ein paar Befehle in die Skripte einzufügen, und das war's.
- `wm_connect` erlaubt auch das Laden eigener modifizierter Bar-Versionen; es genügt, alle verfügbaren Properties aus `BaseBar.qml` zu wiederholen.

## Erweiterung der JES-API
- Um die API zu erweitern, muss dein Plugin auf den Haupt-Cache des gesamten Plugin-Systems subscriben:
```qml
FileView {
    id: pluginView
    path: Quickshell.env("HOME") + "/.cache/JES/JES_plugin_list.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
        yourFunction(text())
    }
}
```
- In `manifest.json` in `api_request` geben wir `api_extending` an.

### Wenn du neue Funktionalität für die API integrierst, muss dein Plugin notify-send mit einer Warnung aufrufen oder ein Warnbanner anzeigen, dass die API durch das und das Plugin bei der ersten Verbindung erweitert wurde.