import Quickshell
import Quickshell.Wayland
import QtQuick
import QtMultimedia
import Quickshell.Io

WlrLayershell {
    id: wallpaper
    layer: WlrLayer.Background
    namespace: "wallpaper"
    exclusiveZone: -1
    anchors {
        bottom: true
        top: true
        left: true
        right: true
    }
    color: "#1b1b1b"

    property int type: wallpaperType
    property string staticBust: ""
    property string videoBust: ""
    property string videoPath: "file://" + Quickshell.env("HOME") + "/.cache/walls/live-bg.mp4"

    // Активный шейдер — имя файла без расширения, напр. "bg"
    // Меняется через: qs ipc call root wallShader "имя"
    // QML подхватывает через Binding на wallShaderName из ShellRoot
    property string shaderName: wallShaderName

    onTypeChanged: {
        if (type === 3) {
            player.source = videoPath
            player.play()
        } else {
            player.stop()
            player.source = ""
        }
    }

    // Следим за сменой шейдера
    onShaderNameChanged: {
        if (type === 2) {
            shaderEffect.updateShader()
        }
    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/walls/no-live-bg.jpg"
        watchChanges: true
        onFileChanged: staticBust = "?" + Date.now()
    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/walls/live-bg.mp4"
        watchChanges: true
        onFileChanged: {
            if (type === 3) {
                player.stop()
                player.source = ""
                player.source = videoPath + "?" + Date.now()
                player.play()
            }
        }
    }

    // --- Статика ---
    Image {
        id: staticImg
        visible: type === 1
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        clip: true
        source: "file://" + Quickshell.env("HOME") + "/.cache/walls/no-live-bg.jpg" + staticBust
    }

    // --- Шейдер ---
    ShaderEffect {
        id: shaderEffect
        visible: type === 2
        anchors.fill: parent

        property color accent:  col.accent
        property color dark:    "#3b3b3b"
        property color mid:     col.background1
        property vector2d resolution: Qt.vector2d(width, height)
        property real time: 0.0
        property real patternScale: 3.2
        property real evolutionSpeed: 0.004

        // Путь к .qsb — берём из папки шейдеров рядом с Walls.qml
        // Если shaderName пустой — фолбэк на дефолтный bg
        fragmentShader: Qt.resolvedUrl(
            "shaders/" + (wallpaper.shaderName !== "" ? wallpaper.shaderName : "bg") + ".frag.qsb"
        )

        function updateShader() {
            // Принудительно обновляем fragmentShader при смене имени
            var s = fragmentShader
            fragmentShader = ""
            fragmentShader = s
        }

        NumberAnimation on time {
            from: 0; to: 1000
            duration: 1000000
            loops: Animation.Infinite
            running: type === 2
        }
    }

    // --- Видео ---
    MediaPlayer {
        id: player
        videoOutput: videoOut
        loops: MediaPlayer.Infinite
    }

    Item {
        anchors.fill: parent
        clip: true
        visible: type === 3

        VideoOutput {
            id: videoOut
            anchors.centerIn: parent
            width: parent.width
            height: parent.width
        }
    }
}
