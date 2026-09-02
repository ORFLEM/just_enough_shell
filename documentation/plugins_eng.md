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
        radius: mainRad - 2 - root.margins // sum up all margins
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
- Data about the Window Manager is passed via the `wm_connect` parameter. If you need data about coordinates/workspaces/active program/layout – call `wm_connect`. For a list of available data, see `BaseBar.qml`.

## JES Libraries
- To simplify plugin creation, libraries `JES.Helpers` and `JES.Bar` were created. The first is required for using `JsonListen`, `JsonPoll`, and `MarqueeText`; the second is for integration with `BaseBar.qml`, i.e., for creating plugins that connect WMs to JES (see below).

### If anything is unclear, refer to `BaseBar.qml` in the bar/ folder — it is the visual reference for all UI.

## Connecting the plugin to JES

To connect to JES, the plugin must have a `manifest.json`. Below is the maximum basic variant for JES without third‑party extensions:
```json
{
  "api_version": "0.1.1",
  "plugin_version": "1.0",
  "name": "plugin name",
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

To activate the plugin in `config.toml` located in `~/.config/JES/`, you need to specify the following:
```toml
[[plugin]]
name = "plugin name" # data in property name from manifest.json
active = true
```

## Connecting to the JES launcher
- To connect to the launcher, we use a JSON file with the following structure:
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

- In `info` we can pass any list containing the following items: `{"id", "name", "icon", "exec"}` – these are the JSON parameter names.

- In `id` we pass the required parameter for a script or a serial number; it must be a string version.
- In `name` the text that will be displayed in the block.
- In `icon` the icon, if any.
- In `exec` the command to be executed. If an `id` is used, you can call it in the command as `$id`, which takes the `id` specified in the JSON.

### `id` is optional if you specify full commands for the object. It is required if you created a script that should run different objects.

## Connecting to the JES plugin center
- To connect to the plugin center, we use a JSON file with the following structure:
```json
[
    {"source": "Content.qml", "colSpan": 1, "rowSpan": 1}
]
```

- Maximum dimensions: `colSpan: 3, rowSpan: 7`
- Any module can be passed in `source`.

## Connecting to JES OSD
- To connect to OSD, we use a JSON file with the following structure:
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
- `type` determines the display format: `text` – displays text information, `percent` – displays a bar and percentage information; you can prefix with an icon.
- In `command` we pass scripts that output for `text` – a text message:
  ```json
  {
      "text": "hi"
  }
  ```
  and for `percent` we output:
  ```json
  {
      "value": 55,
      "sign": "󱄅"
  }
  ```

## Connecting to JES Jwindow
- To connect to Jwindow, we also use JSON with the following information:
```json
[
 {
      "name": "API Test",
      "source": "JwindowTabTester.qml"
  }
]
```
- In `source`, as in the plugin center, you can specify any module, but the maximum dimensions are limited to FHD.

## Connecting other WMs to JES
- In `manifest.json` we specify `wm_connect` in `api_request`, so that the system loads not only the plugin itself but also the panel data, allowing access to WM data.
- For connecting WMs to JES, I have left an example plugin in `for-documentation` that provides a template for connecting other WMs – you just need to add a few commands to the scripts and you are done.

## Extending the JES API
- To extend the API, your plugin must subscribe to the main cache of the entire plugin system:
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
and then in the function we define the required tasks for checking, including checking the `api_request` flag for the required request.

### If you integrate new functionality for the API, your plugin must call `notify-send` with a warning or display a warning panel indicating that the API has been extended by such‑and‑such a plugin.
