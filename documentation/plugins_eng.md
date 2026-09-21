# Plugin creation guide

## Rule No. 1
- A plugin **must always** reside in its own separate folder.

## Rule No. 2
- A plugin **must not** consume a lot of device resources; for optimization any language is allowed, but **Go is recommended**.

## Rule No. 3
- File names in the plugin briefly explain what they are for, and the file to be connected **is specified in the plugin installation instructions**.
- If the plugin has complex functionality in a separate window, the window must be in a lazyLoader.

## Rule No. 4
- **Only relative paths** are used inside the plugin.

## Creating, building and decompiling a plugin

- In the console run:
```bash
jes-cli initPlugin <PluginName>
```

This will create a plugin stub.

- After the plugin is ready for release, run:
```bash
jes-cli makePlugin <PluginName>
```

- If the sources were deleted or you want to modify someone else's plugin, run:
```bash
jes-cli debuildPlugin <PluginName>
```

- Plugin status can be checked with:
```bash
jes-cli getPlugin
```

- If a plugin breaks at runtime, it is added to the launch blacklist; to inspect details use:
  blacklistAdd <name>          - Add plugin to blacklist (status=broken)
  blacklistRemove <name>       - Remove plugin from blacklist
  blacklistList                - Show blacklisted plugins
  blacklistClear               - Wipe the whole blacklist

## Visual part
- For the main background in a plugin use:
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
- And for button backgrounds and similar:
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
- For hover effects use:
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
        radius: mainRad - 2 - root.margins // sum all margins
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

> You may use a different background; the example above uses the button background.

- For radii use `radius: mainRad`; if you add margins, write `radius: mainRad - <margin_number>` in the next block.
- All colors are taken from the global object `col` (defined in `colors.json` and available via `shell.qml`).
- JES also supports base16 themes (`base.base<01-16>`).
- Font is set using **fontFamily** and **fontSize**.
- JES has 2 accent colors — dark and light.
- All animations must be multiplied by `root.animations`.
- `root` is reserved by `shell.qml` in JES; using it is strictly prohibited.

## Data delivery to the UI
- For a permanent stream (recommended for performance) use `JsonListen`; for a one-off request at a set interval use `JsonPoll`.
- Data is passed in JSON format; for visual programs without functions — just a plain string (for example, cava in the bar).
- WM data is passed via the `wm_connect` parameter; if you need coordinates/workspaces/active program/layout data — call `wm_connect`, and what data can be extracted from it — see `BaseBar.qml`.

## JES libraries
- To simplify plugin creation, the libraries `JES.Helpers` and `JES.Bar` were created — the first is required for calling `JsonListen`, `JsonPoll` and `MarqueeText`, and the second — for integration with `BaseBar.qml`, i.e. for creating plugins that connect WMs to JES (see below).

### If something is unclear, look at the `baseBar.qml` file in the bar folder; it is the visual standard for the entire UI.

## Connecting a plugin to JES

- To connect to JES the plugin must have a `manifest.json`; below is the maximum basic variant for JES without third-party extensions:
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

- `api_version` is the API the plugin works with; it must match the current API according to semver; when upgrading to a new API this file should be reviewed.
- **The API is currently unstable; every 5th minor is a major update.**
- *Semver implies major.minor.patch, where major = breaking changes, minor = additions, patch = bug fixes.*

- To activate a plugin in `config.toml` in `~/.config/JES/` add the following:
```toml
[[plugin]]
name = "plugin name" # data in property name from manifest.json
active = true
```

- You can also specify your own parameters below in the same toml block, listing their names in the JSON list `required_settings`.
- To receive the data use the following QML connection:
```qml
Item {
    id: confParameters

    // JES will put values from the [[plugin]] block of config.toml here
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
- For these keys to reach the plugin, the author lists them in the manifest:
```json
"required_settings": ["numbers", "enabled", "float", "text"]
```

- And the user fills them in the `[[plugin]]` block of `config.toml`:
```toml
[[plugin]]
name = "myplugin"
active = true
numbers = 5
enabled = true
float = 3.14
text = "hello"
```

## Connecting to the JES launcher
- To connect to the launcher we use a JSON file with this structure:
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

- In `info` we can pass any list containing the following fields: `{"id", "name", "icon", "exec"}` — these are the JSON parameter names.

- In `id` we pass the needed parameter for the script or a serial number; it must be a string.
- In `name` the text that will be shown in the block.
- In `icon` the icon if present.
- In `exec` the command that will be executed; if `id` is used, it can be referenced in the command as `$id`, which is taken from the `id` specified in the JSON.

### `id` is not required if you specify full commands for the object. It is needed if you created a script that should launch different objects.

## Connecting to the JES plugin center
- To connect to the plugin center we use a JSON file with this structure:
```json
[
    {"source": "Content.qml", "colSpan": 1, "rowSpan": 1}
]
```

- Maximum sizes are `colSpan: 3, rowSpan: 7`.
- Any module can be passed in `source`.

## Connecting to JES OSD
- To connect to OSD we use a JSON file with the following structure:
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
- `type` controls the display format: `text` — text information display, `percent` — bar and percentage display; an icon can be placed at the beginning.
- In `command` we pass scripts that output for `text` — a text message:
  ```json
  {
      "text": "hi"
  }
  ```
  and for `percent` we pass:
  ```json
  {
      "value": 55,
      "sign": "󱄅"
  }
  ```

## Connecting to JES Jwindow
- To connect to Jwindow we also use JSON with the following information:
```json
[
 {
      "name": "API Test",
      "source": "JwindowTabTester.qml"
  }
]
```
- In `source`, as in the plugin center, any module can be specified, but maximum sizes are limited to FHD.

## Connecting other WMs to JES
- In `manifest.json` specify `wm_connect` in `api_request` so that the system loads not only the plugin itself but also the panel data so that WM data can be accessed.
- For connecting WMs to JES I left an example plugin in `for-documentation` that provides a template for connecting other WMs; it is enough to add a couple of commands to the scripts and that's it.
- `wm_connect` also allows loading your own modified versions of Bar; it is enough to repeat all available properties from `BaseBar.qml`.

## Extending the JES API
- To extend the API, your plugin must subscribe to the main cache of the entire plugin system:
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
- In `manifest.json` in `api_request` specify `api_extending`.

### If you are integrating new functionality for the API, your plugin must call notify-send with a warning or show a warning banner that the API was extended by such-and-such plugin on first connection.