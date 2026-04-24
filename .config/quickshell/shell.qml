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
// import "scrinpicker"
// add under this comment import with plugins

ShellRoot {
    FileView {
        id: colors
        path: Qt.resolvedUrl("./colors.json")
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
    property bool powerOpen:      false
    property bool launchOpen:     false
    property bool wallPickerOpen: false
    property int  wallpaperType:  1
    property string wallShaderName: "bg"

    // this you can change
    property int  mainRad:        10
    property bool barOnTop:       true
    property bool minibar:        false

    property string wm: Quickshell.env("XDG_CURRENT_DESKTOP") ?? "sway"

    Process {
        id: wallStateProc
        running: false
        command: [
            Quickshell.env("HOME") + "/.config/quickshell/wallpaper/wallpaper-picker",
            "get-state"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text.trim()
                if (!raw) return
                try {
                    var s = JSON.parse(raw)
                    wallpaperType  = s.wallType
                    if (s.shader && s.shader !== "") wallShaderName = s.shader
                } catch(e) { console.warn("[shell] wallState:", e) }
            }
        }
    }
    Component.onCompleted: {
        wallStateProc.running = false
        wallStateProc.running = true
    }

    Loader {
        id: barLoader
        Component.onCompleted: {
            if      (wm === "Hyprland") source = Qt.resolvedUrl("bar/HyprBar.qml")
            else if (wm === "niri")     source = Qt.resolvedUrl("bar/NiriBar.qml")
            else if (wm === "sway")     source = Qt.resolvedUrl("bar/SwayBar.qml")
            else if (wm === "zwm")      source = Qt.resolvedUrl("bar/ZwmBar.qml")
            else if (wm === "mango")    source = Qt.resolvedUrl("bar/MangoBar.qml")
        }
    }

    Walls {}

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

    PopupSys {}

    LazyLoader {
        id: powerLoader
        active: powerOpen
        Power {}
    }

    Variables { id: vars }

    // Screenshot {
    //     id: scrinPicker
    // }

    // add under this comment your plugins

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
        function togglePower() {
            powerOpen = !powerOpen
        }
        function toggleLaunch() {
            launchOpen = !launchOpen
        }
        function scrinpicker(): void {
            scrinPicker.activate()
        }
        // add under this comment your ipc for plugins
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
}
