import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Shapes
import "roundCorners"
import "bar"
import "helpers"
import "btime"
import "bar/components"
import "popSysInf"
import "power"
import "notifications"
import "launcher"
import "wallpaper"
import "screenpicker"
import "minimap"

ShellRoot {
    id: root

    // ── Colors ──────────────────────────────────────────────────────────────
        // ── Colors ──────────────────────────────────────────────────────────────
    FileView {
        id: colorsFile
        path: Qt.resolvedUrl("./colors.json")
        watchChanges: true
        onFileChanged: reload()
        JsonAdapter {
            id: colorsJson
            property string background1
            property string background2
            property string background3
            property string backgroundAlt1
            property string backgroundAlt2
            property string font
            property string fontDark
            property string accent
            property string accent2
        }
    }

    FileView {
        id: baseColors
        path: Qt.resolvedUrl("./base16.json")
        watchChanges: true
        onFileChanged: reload()
        JsonAdapter {
            id: base
            property string base01
            property string base02
            property string base03
            property string base04
            property string base05
            property string base06
            property string base07
            property string base08
            property string base09
            property string base10
            property string base11
            property string base12
            property string base13
            property string base14
            property string base15
            property string base16
        }
    }
    // Унифицированный доступ к цветам
    QtObject {
        id: col
        readonly property string background1:  disableGenerate ? base.base03 : colorsJson.background1
        readonly property string background2:  disableGenerate ? base.base04 : colorsJson.background2
        readonly property string background3:  disableGenerate ? base.base05 : colorsJson.background3
        readonly property string backgroundAlt1: disableGenerate ? base.base02 : colorsJson.backgroundAlt1
        readonly property string backgroundAlt2: disableGenerate ? base.base01 : colorsJson.backgroundAlt2
        readonly property string font:         disableGenerate ? base.base06 : colorsJson.font
        readonly property string fontDark:     disableGenerate ? base.base01 : colorsJson.fontDark
        readonly property string accent:       disableGenerate ? base.base08 : colorsJson.accent
        readonly property string accent2:      disableGenerate ? base.base05 : colorsJson.accent2
    }


    // ── UI states ───────────────────────────────────────────────────────
    property bool playerOpen:     false
    property bool calOpen:        false
    property bool scrpicOpen:     false
    property bool powerOpen:      false
    property bool launchOpen:     false
    property bool wallPickerOpen: false
    property bool minimapOpen:    false
    property int  wallpaperType:  1
    property string wallShaderName: ""

    // ── Toml-config -> Json-config ───────────────────────────────────
    FileView {
        id: tomlWatcher
        path: Qt.resolvedUrl("./config.toml")
        watchChanges: true
        onFileChanged: {
            generateJsonConfig()
            Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/change-rad.sh"])
        }
        Component.onCompleted: {
            generateJsonConfig()
        }
    }

    Process {
        id: taploProcess
        command: ["sh", "-c", "taplo get -f ~/.config/quickshell/config.toml -o json > ~/.cache/qs_config.json"]
        running: true
        function reload() {
            if (running) kill()
            running = true
        }
        onExited: (code, status) => {
            console.log("[shell] taplo exited, code:", code)
            if (code === 0) {
                configView.reload()
            } else {
                console.error("[shell] taplo failed with code:", code)
            }
        }
    }

    function generateJsonConfig() {
        taploProcess.reload()
    }

    // ── Json-config parcing ──────────────────────────────
    FileView {
        id: configView
        path: Quickshell.env("HOME") + "/.cache/qs_config.json"
        watchChanges: false
        onLoaded: {
            let content = text()
            console.log("[shell] configView loaded, text length:", content.length)
            root._parseConfig(content)
        }
    }

    function _parseConfig(raw) {
        let trimmed = (raw ?? "").trim()
        console.log("[shell] _parseConfig called, length:", trimmed.length)
        if (!trimmed) {
            console.error("[shell] config is empty!")
            return
        }
        try {
            let parsed = JSON.parse(trimmed)
            console.log("[shell] JSON parsed OK, keys:", Object.keys(parsed).join(", "))

            // settings
            let s = parsed.settings ?? {}
            root._cfg_wm              = s.wm                      ?? "auto"
            root._cfg_wm_type         = s.wm_type                 ?? "auto"
            root._cfg_mainRad         = s.mainRad                 ?? 10
            root._cfg_barOnTop        = s.barOnTop                ?? true
            root._cfg_minibar         = s.minibar                 ?? false
            root._cfg_barHeight       = s.barHeight               ?? 30
            root._cfg_fontSize        = s.fontSize                ?? 17
            root._cfg_fontFamily      = s.fontFamily              ?? "Mononoki Nerd Font Propo"
            root._cfg_disableGenerate = s.disableGenerate         ?? false
            root._cfg_doNotDisturb    = s.doNotDisturb            ?? false
            root._cfg_customWallpaper = s.custom_wallpaper_engine ?? false

            // plugin: object { key: { source, acitve } } → list for Repeater
            let p = parsed.plugin ?? {}
            console.log("[shell] plugin keys:", Object.keys(p).join(", "))
            pluginListModel.clear()
            for (let key in p) {
                pluginListModel.append({
                    name: key,
                    source: p[key].source ?? "",
                    active: p[key].active ?? false
                })
            }
            console.log("[shell] pluginListModel parsed, count:", pluginListModel.count)
            console.log("[shell] pluginListModel info:")
            for (var i = 0; i < pluginListModel.count; i++) {
                var item = pluginListModel.get(i)
                console.log("  [" + i + "] name:", item.name, "source:", item.source, "active:", item.active)
            }
        } catch(e) {
            console.error("[shell] Config parse error:", e, "| raw:", raw.substring(0, 200))
        }
    }

    // ── Backing properties ─────────────────────────────────────────────────
    property string _cfg_wm:              "auto"
    property string _cfg_wm_type:         "auto"
    property int    _cfg_mainRad:         10
    property int    _cfg_mainRadOld:      10
    property bool   _cfg_barOnTop:        true
    property bool   _cfg_minibar:         false
    property int    _cfg_barHeight:       30
    property int    _cfg_fontSize:        17
    property string _cfg_fontFamily:      "Mononoki Nerd Font Propo"
    property bool   _cfg_disableGenerate: false
    property bool   _cfg_doNotDisturb:    false
    property bool   _cfg_customWallpaper: false

    // ── Public properties ─────────────────────────────────────────────────
    property int    mainRad:         _cfg_mainRad
    property bool   barOnTop:        _cfg_barOnTop
    property bool   minibar:         _cfg_minibar
    property int    fontSize:        _cfg_fontSize
    property int    barHeight:       _cfg_barHeight + 6
    property string fontFamily:      _cfg_fontFamily
    property bool   disableGenerate: _cfg_disableGenerate
    property bool   show_wallpaper:  !_cfg_customWallpaper
    property bool   doNotDisturb:    _cfg_doNotDisturb
    property string wm:              _cfg_wm      == "auto" ? (Quickshell.env("XDG_CURRENT_DESKTOP") ?? "sway") : _cfg_wm
    property string wm_type:         _cfg_wm_type == "auto" ? (wm == "driftwm" ? "coordinates" : "workspaces") : _cfg_wm_type

    Behavior on mainRad { NumberAnimation { duration: 200 } }

    // ── Plugins ────────────────────────────────────────────────────────────
    ListModel {
        id: pluginListModel
    }
    property var pluginRegistry: ({})

    Repeater {
        model: pluginListModel
        delegate: Loader {
             id: pluginLoader
            active: model.active
            source: model.active ? Qt.resolvedUrl(model.source) : ""
            onLoaded: {
                // remember plugin, it's id
                root.pluginRegistry[model.name] = item
                console.log("[plugin] Плагин зарегистрирован:", model.name)
            }
        }
    }

    // ── Bar ────────────────────────────────────────────────────────────────
    Loader {
        id: barLoader
        Component.onCompleted: {
            if      (wm === "Hyprland") source = Qt.resolvedUrl("bar/HyprBar.qml")
            else if (wm === "niri")     source = Qt.resolvedUrl("bar/NiriBar.qml")
            else if (wm === "sway")     source = Qt.resolvedUrl("bar/SwayBar.qml")
            else if (wm === "zwm")      source = Qt.resolvedUrl("bar/ZwmBar.qml")
            else if (wm === "mango")    source = Qt.resolvedUrl("bar/MangoBar.qml")
            else if (wm === "driftwm")  source = Qt.resolvedUrl("bar/DriftBar.qml")
            else                        source = Qt.resolvedUrl("bar/" + wm + "Bar.qml")
        }
    }

    // ── UI components ─────────────────────────────────────────────────────────
    LazyLoader {
        active: show_wallpaper
        Walls {}
    }

    LazyLoader {
        active: !doNotDisturb
        Notifications {}
    }

    LazyLoader {
        id: wallPickerLoader
        active: wallPickerOpen
        WallpaperPicker {}
    }

    LazyLoader {
        id: launchLoader
        active: launchOpen
        Launch {}
    }

    LazyLoader {
        active: minimapOpen
        MiniMap {}
    }

    Btime {}

    PlayerPopup { isOpen: playerOpen }
    CalPopup    { isOpen: calOpen }
    PopupSys    {}

    LazyLoader {
        id: powerLoader
        active: powerOpen
        Power {}
    }

    Variables  { id: vars }
    Screenshot { id: screenpicker }

    // ── IPC ────────────────────────────────────────────────────────────────
    IpcHandler {
        target: "root"

        function wallShader(name: string): void {
            wallShaderName = name
        }
        function toggleWallPicker(): void {
            wallPickerOpen = !wallPickerOpen
        }
        function wallType(n: int): void {
            wallpaperType = n
        }
        function togglePlayer() {
            playerOpen = !playerOpen
        }
        function toggleCal() {
            calOpen = !calOpen
            Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal reset"])
        }
        function togglePower() {
            powerOpen = !powerOpen
        }
        function toggleLaunch() {
            launchOpen = !launchOpen
        }
        function toggleMap() {
            minimapOpen = !minimapOpen
        }
        function screenpicker(): void {
            screenpicker.activate()
        }
        function getPlugin() {
            Quickshell.execDetached(["notify-send", pluginModel])
        }
    }

    // ── Rounded corners ───────────────────────────────────────────────────
    property int size: mainRad > 0 ? mainRad + 6 : 0
    Variants {
        model: Quickshell.screens

        Item {
            required property ShellScreen modelData
            ScreenCorner {
                cornerDirection: ScreenCorner.TopLeft
                cornerWidth: size; cornerHeight: size
                cornerColor: "#000000"
                screen: modelData
            }
            ScreenCorner {
                cornerDirection: ScreenCorner.TopRight
                cornerWidth: size; cornerHeight: size
                cornerColor: "#000000"
                screen: modelData
            }
            ScreenCorner {
                cornerDirection: ScreenCorner.BottomLeft
                cornerWidth: size; cornerHeight: size
                cornerColor: "#000000"
                screen: modelData
            }
            ScreenCorner {
                cornerDirection: ScreenCorner.BottomRight
                cornerWidth: size; cornerHeight: size
                cornerColor: "#000000"
                screen: modelData
            }
        }
    }
}
