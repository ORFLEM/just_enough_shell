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

    property bool playerOpen:     false
    property bool powerOpen:      false
    property bool launchOpen:     false
    property bool wallPickerOpen: false
    property int  wallpaperType:  1
    property int  mainRad:        10
    property string wallShaderName: "bg"

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
