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

    readonly property string projectId: "Just Enough Shell"

    // ── Colors ──────────────────────────────────────────────────────────────
    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.local/state/JES_colors.json"
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
        path: Quickshell.env("HOME") + "/.config/JES/base16.json"
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
    QtObject {
        id: col
        readonly property string background1:    enable_base16 ? base.base05 : colorsJson.background1
        readonly property string background2:    enable_base16 ? base.base04 : colorsJson.background2
        readonly property string background3:    enable_base16 ? base.base03 : colorsJson.background3
        readonly property string backgroundAlt1: enable_base16 ? base.base01 : colorsJson.backgroundAlt1
        readonly property string backgroundAlt2: enable_base16 ? base.base02 : colorsJson.backgroundAlt2
        readonly property string font:           enable_base16 ? base.base06 : colorsJson.font
        readonly property string fontDark:       enable_base16 ? base.base01 : colorsJson.fontDark
        readonly property string accent:         enable_base16 ? base.base08 : colorsJson.accent
        readonly property string accent2:        enable_base16 ? base.base05 : colorsJson.accent2
    }

        // ── UI states ──
    FileView {
        id: statesFileView
        path: Quickshell.env("HOME") + "/.cache/JES/states_cached.json"
        
        onLoaded: {
            try {
                var textData = text().trim();
                if (textData === "") return;
                
                var states_c = JSON.parse(textData);
                playerOpen =     states_c.playerOpen ?? false;
                pluginOpen =     states_c.pluginOpen ?? false;
                calOpen =        states_c.calOpen ?? false;
                scrpicOpen =     states_c.scrpicOpen ?? false;
                powerOpen =      states_c.powerOpen ?? false;
                launchOpen =     states_c.launchOpen ?? false;
                wallPickerOpen = states_c.wallPickerOpen ?? false;
                minimapOpen =    states_c.minimapOpen ?? false;
                weatherOpen =    states_c.weatherOpen ?? false;
                wallpaperType =  states_c.wallpaperType ?? 1;
                wallpaperType =  states_c.user_matugen ?? 1;
                wallShaderName = states_c.wallShaderName ?? "";
            } catch (e) {
                console.log("JES Error parsing states_cached.json at boot:", e);
            }
        }
    }

    property bool   playerOpen:     false
    property bool   pluginOpen:     false
    property bool   calOpen:        false
    property bool   scrpicOpen:     false
    property bool   powerOpen:      false
    property bool   launchOpen:     false
    property bool   wallPickerOpen: false
    property bool   minimapOpen:    false
    property bool weatherOpen: false
    property int    wallpaperType:  1
    property string wallShaderName: ""

    function saveStatesToDisk() {
        var data = {
            "playerOpen":     playerOpen,
            "pluginOpen":     pluginOpen,
            "calOpen":        calOpen,
            "scrpicOpen":     scrpicOpen,
            "powerOpen":      powerOpen,
            "launchOpen":     launchOpen,
            "wallPickerOpen": wallPickerOpen,
            "minimapOpen":    minimapOpen,
            "weatherOpen":    weatherOpen,
            "wallpaperType":  wallpaperType,
            "wallShaderName": wallShaderName
        };
        statesFileView.setText(JSON.stringify(data, null, 2));
    }

    function toggleWeather() {
        weatherOpen = !weatherOpen;
        saveStatesToDisk();
    }

    function toggleLaunch() {
        launchOpen = !launchOpen;
        saveStatesToDisk();
    }

    function toggleWallPicker() {
        wallPickerOpen = !wallPickerOpen;
        saveStatesToDisk();
    }

    function togglePlayer() {
        playerOpen = !playerOpen;
        saveStatesToDisk();
    }

    function toggleCal() {
        calOpen = !calOpen;
        saveStatesToDisk();
        Quickshell.execDetached([localPath(Qt.resolvedUrl("scripts/cal")), "reset"]);
    }

    function togglePower() {
        powerOpen = !powerOpen;
        saveStatesToDisk();
    }

    function togglePlugin() {
        pluginOpen = !pluginOpen;
        saveStatesToDisk();
    }

    function toggleMap() {
        minimapOpen = !minimapOpen;
        saveStatesToDisk();
    }

    function wallShader(name: string) {
        wallShaderName = name;
        saveStatesToDisk();
    }

    function wallType(n: int) {
        wallpaperType = n;
        saveStatesToDisk();
    }

    function localPath(url) {
        var str = String(url);
        if (str.startsWith("file://"))
            str = str.substring(7);
        return str;
    }

    // ── Toml-config -> Json-config ───────────────────────────────────
    FileView {
        id: tomlWatcher
        path: Quickshell.env("HOME") + "/.config/JES/config.toml"
        watchChanges: true
        onFileChanged: {
            Quickshell.execDetached(["sh", "-c", localPath(Qt.resolvedUrl("scripts/change-rad.sh"))])
            Quickshell.execDetached(["sh", "-c", localPath(Qt.resolvedUrl("scripts/plugin_list.sh 0.1.0"))])
            Quickshell.execDetached(["sh", "-c", "taplo get -f ~/.config/JES/config.toml -o json > ~/.cache/JES/JES_config.json"])
        }
        Component.onCompleted: {
            Quickshell.execDetached(["sh", "-c", localPath(Qt.resolvedUrl("scripts/change-rad.sh"))])
            Quickshell.execDetached(["sh", "-c", localPath(Qt.resolvedUrl("scripts/plugin_list.sh 0.1.0"))])
            Quickshell.execDetached(["sh", "-c", "taplo get -f ~/.config/JES/config.toml -o json > ~/.cache/JES/JES_config.json"])
        }
    }

    // ── Json-config parsing ──────────────────────────────
    FileView {
        id: configView
        path: Quickshell.env("HOME") + "/.cache/JES/JES_config.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            let content = text()
            console.log("[shell] configView loaded, text length:", content.length)
            root._parseConfig(content)
        }
    }
    FileView {
        id: pluginView
        path: Quickshell.env("HOME") + "/.cache/JES/JES_plugin_list.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            let content = text()
            console.log("[shell] configView loaded, text length:", content.length)
            root._parseList(content)
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
            root._cfg_enable_base16   = s.enable_base16           ?? false
            root._cfg_doNotDisturb    = s.doNotDisturb            ?? false
            root._cfg_customWallpaper = s.custom_wallpaper_engine ?? false
            root._cfg_user_matugen = s.user_matugen ?? false
            root._cfg_API_key         = s.openweather_key         ?? ""

        } catch(e) {
            console.error("[shell] Config parse error:", e, "| raw:", raw)
        }
    }

    function _parseList(raw) {
        let trimmed = (raw ?? "").trim()
        console.log("[shell] _parseList called, length:", trimmed.length)
        if (!trimmed) {
            console.error("[shell] list is empty!")
            return
        }
        try {
            let entries = JSON.parse(trimmed)
            if (!Array.isArray(entries)) {
                console.warn("[shell] plugin list is not an array")
                return
            }
            console.log("[shell] Got", entries.length, "plugin entries")
    
            pluginListModel.clear()
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
                // Просто добавляем объект как есть
                pluginListModel.append(entry)
                console.log("[shell] Added plugin entry:", JSON.stringify(entry))
            }
            console.log("[shell] _parseList finished, pluginListModel count:", pluginListModel.count)
        } catch(e) {
            console.error("[shell] Error parsing plugin list:", e)
        }
    }

    // ia ne ebu chto eto    
    Component {
        id: processComponent
        Process {
            stdout: StdioCollector {
                waitForEnd: true
            }
        }
    }

    // ── Backing properties ─────────────────────────────────────────────────
    property string _cfg_wm:              "auto"
    property string _cfg_wm_type:         "auto"
    property int    _cfg_mainRad:         10
    property bool   _cfg_barOnTop:        true
    property bool   _cfg_minibar:         false
    property int    _cfg_barHeight:       30
    property int    _cfg_fontSize:        17
    property string _cfg_fontFamily:      "Mononoki Nerd Font Propo"
    property bool   _cfg_enable_base16:   false
    property bool   _cfg_doNotDisturb:    false
    property bool   _cfg_customWallpaper: false
    property bool   _cfg_user_matugen: false
    property string _cfg_pluginDir:       ""
    property string _cfg_API_key:         ""
    property var    _pluginConfigList:    []   // penis { name, active } from config

    // ── Public properties ─────────────────────────────────────────────────
    property int    mainRad:         _cfg_mainRad
    property bool   barOnTop:        _cfg_barOnTop
    property bool   minibar:         _cfg_minibar
    property int    fontSize:        _cfg_fontSize
    property int    barHeight:       _cfg_barHeight + 6
    property string fontFamily:      _cfg_fontFamily
    property bool   enable_base16:   _cfg_enable_base16
    property bool   show_wallpaper:  !_cfg_customWallpaper
    property bool   doNotDisturb:    _cfg_doNotDisturb
    property bool   user_matugen:    _cfg_user_matugen
    property string owm_key:        _cfg_API_key
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
            source: model.active ? "file://" + model.source + "/" + model.main_source : ""
            onLoaded: {
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

    LazyLoader {
        id: pluginPopupLoader
        active: pluginOpen
        PluginPopup {}
    }

        

    Btime {}

    PlayerPopup { isOpen: playerOpen }
    CalPopup    { isOpen: calOpen }
    WeatherPopup { isOpen: weatherOpen }
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
            root.wallShader(name);
        }
        function toggleWallPicker(): void {
            root.toggleWallPicker();
        }
        function wallType(n: int): void {
            root.wallType(n);
        }
        function togglePlayer() {
            root.togglePlayer();
        }
        function toggleCal() {
            root.toggleCal();
        }
        function toggleWeather() {
            root.toggleWeather();
        }
        function togglePower() {
            root.togglePower();
        }
        function toggleLaunch() {
            root.toggleLaunch();
        }
        function toggleMap() {
            root.toggleMap();
        }
        function togglePlugin() {
            root.togglePlugin();
        }
        function screenpicker(): void {
            screenpicker.activate();
        }
        function getPlugin() {
            Quickshell.execDetached(["notify-send", pluginModel]);
        }
    }
    property var bar: barLoader.item

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


// sosal?
