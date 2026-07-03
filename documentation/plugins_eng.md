# Plugin Creation Guide

## Rule #1
- A plugin **always** lives in its own dedicated folder.

## Rule #2
- A plugin **must not** consume significant device resources. Any language is allowed for performance reasons, but **Go is recommended**.

## Rule #3
- File names inside a plugin should briefly describe its purpose. The file to be loaded is **specified in the plugin's installation instructions**.
- If a plugin has complex functionality in a separate window, that window must be wrapped in a `lazyLoader`.

## Visual style
- For the main background of a plugin, use:
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
- For button backgrounds and similar elements:
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
- For hover effects, use:
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
        radius: mainRad - 5 // sum up all margins
        color: button.hovered ? col.accent : "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }
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

#### A different background can be used — the example above used the button background style.

- For radii, use `radius: mainRad`. If you apply margins, write `radius: mainRad - <margin_value>` in the inner block.
- All colors must come from the global `col` object (defined in `colors.json` and available via `shell.qml`).
- JES also supports base16 themes (`base.base<01-16>`).
- Font is set via **fontFamily** and **fontSize**.
- JES has 2 accent colors — dark and light.

## Passing data to the interface
- Use `JsonListen` for a continuous stream (recommended for performance), and `JsonPoll` for a one-time request on a fixed interval.
- Data is passed as JSON. For visual-only programs with no logic (e.g. cava in the bar), a plain string is sufficient.

## If anything is unclear, refer to BaseBar.qml in the bar/ folder — it is the visual reference for all UI.
