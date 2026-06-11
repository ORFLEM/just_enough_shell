import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Shapes
import "roundCorners"
import "bar"
import "navbar"
import "helpers"
import "btime"
import "bar/components"
import "popSysInf"
import "power"
import "notifications"
import "launcher"
import "wallpaper"
import "screenpicker"

ShellRoot {
    id: root
    FileView {
        id: colors
        path: darkTheme ? Qt.resolvedUrl("./colors.json") : Qt.resolvedUrl("./colors_light.json")
        watchChanges: true
        onFileChanged: reload()
        JsonAdapter {
            id: col
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
    
    property bool playerOpen:     false
    property bool calOpen:        false
    property bool scrpicOpen:     false
    property bool powerOpen:      false
    property bool launchOpen:     false
    property bool wallPickerOpen: false
    property int  wallpaperType:  1
    property string wallShaderName: ""


    

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

    LazyLoader {
        active: wm != "driftwm"
        Walls {}
    }

    // Walls {}
    
    Notifications {}

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

    Btime {}

    PlayerPopup {
        isOpen: playerOpen
    }
    
    CalPopup {
        isOpen: calOpen
    }

    PopupSys {}

    LazyLoader {
        id: powerLoader
        active: powerOpen
        Power {}
    }

    Variables { id: vars }

    Screenshot { id: screenpicker }

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
        function screenpicker(): void {
            screenpicker.activate()
        }
    }

    property int size: mainRad > 0 ? mainRad + 6 : 0
    ScreenCorner {
        cornerDirection: ScreenCorner.TopLeft
        cornerWidth: size; cornerHeight: size
        cornerColor: "#000000"
    }
    ScreenCorner {
        cornerDirection: ScreenCorner.TopRight
        cornerWidth: size; cornerHeight: size
        cornerColor: "#000000"
    }
    ScreenCorner {
        cornerDirection: ScreenCorner.BottomLeft
        cornerWidth: size; cornerHeight: size
        cornerColor: "#000000"
    }
    ScreenCorner {
        cornerDirection: ScreenCorner.BottomRight
        cornerWidth: size; cornerHeight: size
        cornerColor: "#000000"
    }

    property var pluginModel: []

    // Убираем весь блок Process и configWatcher, вставляем:

    FileView {
        id: tomlWatcher
        path: Qt.resolvedUrl("./config.toml")
        watchChanges: true
        onFileChanged: generateJsonConfig()
        Component.onCompleted: generateJsonConfig()
    }
    
    Process {
        id: taploProcess
        command: ["sh", "-c", "taplo get -f ~/.config/quickshell/config.toml -o json > ~/.cache/qs_config.json"]
        running: true
        function reload() {
            if (running) terminate();
            running = true;
        }
    }

    // Функция, запускающая генерацию JSON
    function generateJsonConfig() {
        taploProcess.reload();
    }
    
    FileView {
        id: configView
        path: Quickshell.env("HOME") + "/.cache/qs_config.json"
        watchChanges: true
        onFileChanged: reload()
        JsonAdapter {
            id: configJson
            // Вместо плоских свойств создаём вложенный объект "settings",
            // структура которого будет зеркально отражать json-файл.
            property JsonObject settings: JsonObject {
                property string wm: "auto"
                property string wm_type: "auto"
                property int mainRad: 10
                property bool barOnTop: true
                property bool minibar: false
                property int barHeight: 30
                property int fontSize: 17
                property string fontFamily: "Mononoki Nerd Font Propo"
                property bool darkTheme: true
            }
            property list<JsonObject> plugin: []
        }
    }
    property int mainRad: configJson.settings.mainRad
    property bool barOnTop: configJson.settings.barOnTop
    property bool minibar: configJson.settings.minibar
    property int fontSize: configJson.settings.fontSize
    property int barHeight: configJson.settings.barHeight + 6
    property string fontFamily: configJson.settings.fontFamily
    property bool darkTheme: configJson.settings.darkTheme
    property string wm: configJson.settings.wm == "auto" ? Quickshell.env("XDG_CURRENT_DESKTOP") ?? "sway" : configJson.settings.wm
    property string wm_type: configJson.settings.wm_type == "auto" ? (wm == "driftwm" ? "coordinates" : "workspaces" ) : configJson.settings.wm_type
    Behavior on mainRad { NumberAnimation { duration: 200 } }
    
    Repeater {
        model: configJson.plugin
        delegate: LazyLoader {
            id: pluginLoader
            active: false
            source: Qt.resolvedUrl(modelData.source)
    
            Component.onCompleted: {
                pluginLoader.active = true;
            }
        }
    }
}
