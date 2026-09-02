# Anleitung zur Plugin-Erstellung

## Regel Nr. 1
- Ein Plugin befindet sich **immer** in einem eigenen, separaten Ordner.

## Regel Nr. 2
- Ein Plugin darf **nicht** viele Geräteressourcen verbrauchen. Zur Optimierung ist jede Sprache erlaubt, empfohlen wird jedoch **Go** (Golang).

## Regel Nr. 3
- Die Dateinamen im Plugin erklären kurz, wofür sie sind; die einzubindende Datei wird **in der Installationsanleitung des Plugins angegeben**.
- Wenn das Plugin komplexe Funktionalität in einem separaten Fenster hat, muss dieses Fenster in einem `lazyLoader` eingebettet werden.

## Visuelle Gestaltung
- Für den Haupthintergrund eines Plugins verwenden Sie:
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
- Für den Hintergrund von Schaltflächen und ähnlichen Elementen:
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
- Für Hover-Effekte verwenden Sie:
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
        radius: mainRad - 2 - root.margins // Summe aller Ränder
        color: button.hovered ? col.accent : "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    // Code
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

#### Sie können auch einen anderen Hintergrund verwenden – im obigen Beispiel wurde der Schaltflächenhintergrund verwendet.

- Für Radien verwenden Sie `radius: mainRad`. Wenn Sie Ränder (margins) setzen, schreiben Sie im inneren Block `radius: mainRad - <Randwert>`.
- Alle Farben müssen aus dem globalen Objekt `col` stammen (definiert in `colors.json` und über `shell.qml` verfügbar).
- JES unterstützt außerdem base16‑Themen (`base.base<01-16>`).
- Die Schriftart wird über **fontFamily** und **fontSize** festgelegt.
- JES hat 2 Akzentfarben – dunkel und hell.

## Datenübergabe an die Oberfläche
- Verwenden Sie `JsonListen` für einen kontinuierlichen Datenstrom (aus Leistungsgründen empfohlen) und `JsonPoll` für eine einmalige Abfrage in festgelegten Intervallen.
- Die Daten werden im JSON‑Format übergeben. Bei rein visuellen Programmen ohne Logik (z. B. Cava in der Leiste) genügt ein einfacher String.
- Fenstermanager‑Daten werden über den Parameter `wm_connect` übergeben. Wenn Sie Daten zu Koordinaten/Arbeitsflächen/aktivem Programm/Tastaturlayout benötigen, rufen Sie `wm_connect` auf. Eine Liste der verfügbaren Daten finden Sie in `BaseBar.qml`.

## JES‑Bibliotheken
- Um die Plugin‑Erstellung zu vereinfachen, wurden die Bibliotheken `JES.Helpers` und `JES.Bar` geschaffen. Ersteres wird für die Verwendung von `JsonListen`, `JsonPoll` und `MarqueeText` benötigt, letzteres für die Integration mit `BaseBar.qml`, d. h. für die Erstellung von Plugins, die Fenstermanager an JES anbinden (siehe unten).

### Falls etwas unklar ist, schauen Sie in die Datei `BaseBar.qml` im Ordner `bar/` – sie ist die visuelle Referenz für die gesamte Benutzeroberfläche.

## Anbindung des Plugins an JES

Um eine Verbindung zu JES herzustellen, muss das Plugin eine `manifest.json` besitzen. Nachfolgend die maximale Basisvariante für JES ohne Drittanbieter‑Erweiterungen:
```json
{
  "api_version": "0.1.1",
  "plugin_version": "1.0",
  "name": "Pluginname",
  "api_request": [
    "launcher",
    "plugin_center",
    "osd",
    "Jwindow",
    "wm_connect"
  ],
  "main_source": "Main.qml",
  "json_files": {
    "launcher": "launch_list.json",
    "plugin_center": "load_list.json",
    "osd": "osd_list.json",
    "Jwindow": "Jwindow.json"
  }
}
```

Um das Plugin in der `config.toml` (unter `~/.config/JES/`) zu aktivieren, müssen Sie Folgendes angeben:
```toml
[[plugin]]
name = "Pluginname" # entspricht dem name-Eintrag in der manifest.json
active = true
```

## Anbindung an den JES‑Launcher
- Für die Anbindung an den Launcher verwenden wir eine JSON‑Datei mit folgender Struktur:
```json
{
  "name": "Tab",
  "icon": "",
  "placeholder": "In Tab suchen...",
  "info": [
    {
      "id": "app_1",
      "name": "App 1",
      "exec": "Skript starten $id"
    },
    {
      "id": "2",
      "name": "Screenshot erstellen",
      "exec": "grim ~/Screenshots"
    }
  ]
}
```

- In `info` können wir eine beliebige Liste übergeben, die folgende Elemente enthalten kann: `{"id", "name", "icon", "exec"}` – das sind die JSON‑Parameternamen.

- In `id` übergeben wir den gewünschten Parameter für ein Skript oder eine fortlaufende Nummer (zwingend als Zeichenkette).
- In `name` steht der Text, der im Block angezeigt wird.
- In `icon` das Symbol, falls vorhanden.
- In `exec` der auszuführende Befehl. Wenn eine `id` verwendet wird, kann diese im Befehl als `$id` aufgerufen werden, wobei der Wert aus der JSON‑Datei übernommen wird.

### `id` ist optional, wenn Sie vollständige Befehle für das Objekt angeben. Sie ist erforderlich, wenn Sie ein Skript erstellt haben, das verschiedene Objekte starten soll.

## Anbindung an das JES‑Plugin‑Center
- Für die Anbindung an das Plugin‑Center verwenden wir eine JSON‑Datei mit folgender Struktur:
```json
[
    {"source": "Content.qml", "colSpan": 1, "rowSpan": 1}
]
```

- Maximale Abmessungen: `colSpan: 3, rowSpan: 7`
- In `source` kann ein beliebiges Modul angegeben werden.

## Anbindung an das JES‑OSD
- Für die Anbindung an das OSD verwenden wir eine JSON‑Datei mit folgender Struktur:
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
- `type` gibt das Anzeigeformat an: `text` – zeigt Textinformationen an, `percent` – zeigt einen Balken und Prozentwert an; Sie können ein Symbol voranstellen.
- In `command` übergeben wir Skripte, die für `text` eine Textmeldung ausgeben:
  ```json
  {
      "text": "hallo"
  }
  ```
  und für `percent`:
  ```json
  {
      "value": 55,
      "sign": "󱄅"
  }
  ```

## Anbindung an das JES‑Jwindow
- Für die Anbindung an Jwindow verwenden wir ebenfalls JSON mit folgender Information:
```json
[
 {
      "name": "API-Test",
      "source": "JwindowTabTester.qml"
  }
]
```
- In `source` können Sie, wie im Plugin‑Center, ein beliebiges Modul angeben, aber die maximalen Abmessungen sind auf FHD begrenzt.

## Anbindung anderer Fenstermanager an JES
- In der `manifest.json` geben Sie bei `api_request` den Eintrag `wm_connect` an, damit das System nicht nur das Plugin selbst, sondern auch die Daten aus der Leiste lädt, sodass auf Fenstermanager‑Daten zugegriffen werden kann.
- Für die Anbindung von Fenstermanagern an JES habe ich im Ordner `for-documentation` ein Beispiel‑Plugin hinterlassen, das eine Vorlage für die Anbindung anderer WM bietet – Sie müssen lediglich ein paar Befehle in den Skripten ergänzen, und schon ist es erledigt.

## Erweiterung der JES‑API
- Um die API zu erweitern, muss Ihr Plugin den Hauptcache des gesamten Pluginsystems abonnieren:
```qml
FileView {
    id: pluginView
    path: Quickshell.env("HOME") + "/.cache/JES_plugin_list.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
        yourFunction(text())
    }
}
```
und dann definieren wir in der Funktion die erforderlichen Aufgaben für die Prüfung, einschließlich der Überprüfung des `api_request`-Flags auf die gewünschte Anfrage.

### Wenn Sie neue Funktionalität für die API integrieren, muss Ihr Plugin `notify-send` mit einer Warnung aufrufen oder eine Warnmeldung anzeigen, die darauf hinweist, dass die API um dieses bestimmte Plugin erweitert wurde.
