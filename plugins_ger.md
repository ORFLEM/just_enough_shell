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
}
```
- Für Hover-Effekte wird Folgendes verwendet:
```qml
Item {
    id: <Blockname>
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
        id: <aussagekräftiger_name>
        anchors.fill: parent
        anchors.margins: 2
        radius: mainRad - <margins_plus_margin_in_diesem_modul>
        color: <Trigger> ? col.accent : "transparent" 
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    // Code
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            <Trigger> = true
        }
        onExited: {
            <Trigger> = false
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

## Falls etwas unklar ist, schauen Sie sich die Datei BaseBar.qml im Ordner bar an, das ist der visuelle Maßstab für die gesamte UI
