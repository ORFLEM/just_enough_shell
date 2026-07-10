# Anleitung zur Plugin-Erstellung

## Regel Nr. 1
- Ein Plugin befindet sich **immer** in einem eigenen, separaten Ordner

## Regel Nr. 2
- Ein Plugin darf **nicht** viele Geräteressourcen verbrauchen; zur Optimierung ist jede Sprache erlaubt, empfohlen wird jedoch **golang**

## Regel Nr. 3
- Die Dateinamen im Plugin erklären kurz, wofür sie sind, und die einzubindende Datei wird **in der Installationsanleitung des Plugins angegeben**
- Wenn das Plugin komplexe Funktionalität in einem separaten Fenster hat, muss dieses Fenster im lazyLoader liegen

## Visuelle Komponente
- Für den Haupthintergrund wird im Plugin Folgendes verwendet:
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
- Und für den Hintergrund von Buttons und Ähnlichem:
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
- Für Hover-Effekte wird Folgendes verwendet:
```qml
Item {
    id: button
    property bool hovered: false
    Rectangle {
        anchors.fill: parent
        radius: mainRad - 3
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
        radius: mainRad - 5 // Wir addieren alle Margins
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

#### Es kann auch ein anderer Hintergrund verwendet werden, in diesem Beispiel wurde der Button-Hintergrund verwendet

- Für Radien wird `radius: mainRad` verwendet; wenn Sie margins setzen, schreiben Sie im nächsten Block `radius: mainRad - <Margin-Wert>`
- Alle Farben werden aus dem globalen Objekt `col` bezogen (definiert in `colors.json` und über `shell.qml` verfügbar).
- JES unterstützt außerdem base16-Themes (`base.base<01-16>`)
- Die Schrift wird mit **fontFamily** und **fontSize** festgelegt
- JES hat 2 Akzentfarben - dunkel und hell

## Datenübertragung an die Oberfläche
- Für einen kontinuierlichen Datenstrom (aus Performance-Gründen empfohlen) `JsonListen` verwenden, für eine einmalige Abfrage in festgelegten Zeitabständen `JsonPoll`
- Die Daten werden im JSON-Format übertragen; bei visuellen Programmen ohne Funktionen genügt einfach ein String (zum Beispiel cava in der Leiste)
- Fensterverwaltungsdaten werden über den Parameter `bar` übergeben. Wenn Sie Daten zu Koordinaten/Arbeitsflächen/aktivem Programm/Tastaturlayout benötigen – rufen Sie `bar` auf. Welche Daten verfügbar sind, entnehmen Sie der `BaseBar.qml`.

### Falls etwas unklar ist, schauen Sie sich die Datei `BaseBar.qml` im Ordner bar an, das ist der visuelle Maßstab für die gesamte UI

## Anbindung an den JES-Launcher
- Um eine Verbindung zum Launcher herzustellen, rufen wir folgende Funktion auf:
```qml
property var api: launchLoader ? launchLoader.item : null

function ensureTab() {
    if (!api) return

    var exists = false
    for (var i = 0; i < api.tabModel.length; i++) {
        if (api.tabModel[i].name === "Name des Tabs") {
            exists = true
            break
        }
    }
    if (!exists) {
        api.tabModel.push({
            name: "Name des Tabs",
            icon: "Symbol für die Suche, nur aus Nerd Font verwenden",
            placeholder: "Text eingeben...",
            info: []
        })
    }
}

onApiChanged: {
    if (api && launchLoader && launchLoader.active) {
        ensureTab()
        firstOpen = false
    }
}
```
- In `info` können wir eine beliebige Liste übergeben, die folgende Elemente enthält: `{"id", "name", "icon", "exec"}` – das ist ein Pseudo‑JSON, nur Namen für Objekte.

- In `id` übergeben wir die fortlaufende Nummer.
- In `name` der Text, der im Block angezeigt wird.
- In `icon` das Symbol, falls vorhanden.
- In `exec` der auszuführende Befehl.

### `id` ist optional, wenn Sie vollständige Befehle für das Objekt angeben. Es ist erforderlich, wenn Sie ein Skript erstellt haben, das verschiedene Objekte starten soll.

## Anbindung an das JES-Plugin-Center
- Um eine Verbindung zum Plugin-Center herzustellen, rufen wir folgende Funktion auf:
```qml
property var api: pluginPopupLoader ? pluginPopupLoader.item : null

function ensurePlugins() {
    if (!api) return

    var modules = [
        { source: Qt.resolvedUrl("Content.qml"), colSpan: 1, rowSpan: 1 }
    ]

    for (var i = 0; i < modules.length; i++) {
        var mod = modules[i]
        var exists = false
        for (var j = 0; j < api.pluginInfo.length; j++) {
            if (api.pluginInfo[j].source === mod.source) {
                exists = true
                break
            }
        }
        if (!exists) {
            api.pluginInfo.push(mod)
            console.log("[ExamplePlugin] Modul hinzugefügt:", mod.source)
        }
    }
}

onApiChanged: {
    ensurePlugins()
}
```
- Maximale Größen: `colSpan: 3, rowSpan: 7`
- In `source` kann ein beliebiges Modul übergeben werden.
