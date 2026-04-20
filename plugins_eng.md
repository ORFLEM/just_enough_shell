# Plugin Creation Guide

## Rule № 1
- A plugin **always** resides in its own separate folder.

## Rule № 2
- The plugin **must not** consume many system resources. Any language is allowed for optimization, but **Go is recommended**.

## Rule № 3
- File names inside the plugin should briefly explain their purpose, and the file to be included **must be specified in the plugin installation instructions**.
- If the plugin has complex functionality in a separate window, the instructions must include a ready‑to‑use LazyLoader to load that window.

## Visual guidelines
- For the main background of a plugin, use:
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

- For button backgrounds and similar elements, use:
```qml
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
Rectangle {
    id: <some_meaningful_name>
    anchors.fill: parent
    anchors.margins: 2
    radius: mainRad - <margins_plus_margin_in_this_module>
    color: "transparent"
    Behavior on color { ColorAnimation { duration: 200 } }
}
// code
MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
        <some_meaningful_name>.color = col.accent
    }
    onExited: {
        <some_meaningful_name>.color = "transparent"
    }
}
```

- For radii, use radius: mainRad. If you use margins, write `radius: mainRad - <margin_value> in the following block`.
- All colours must be taken from the global col object (defined in `colors.json` and accessible via `shell.qml`).
- Also JES supported base16 themes (`base.base<01-16>`)
- Main font: `Mononoki Nerd Font Propo` size **17px**.

## Passing data to the interface
- For continuous streams (recommended for performance) use `JsonListen`. For periodic one‑time requests use `JsonPoll`.
- Data is passed in JSON format. For visual programs without functions – just a plain string (e.g., cava in the bar).

## If something is unclear, refer to BaseBar.qml in the bar/ folder – it is the visual reference for the entire UI.
