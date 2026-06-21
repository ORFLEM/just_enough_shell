import Quickshell
import Quickshell.Wayland
import QtQuick
import QtMultimedia
import Quickshell.Io

Variants {
    model: Quickshell.screens
    WlrLayershell {
        required property ShellScreen modelData
        id: wallpaper
        layer: WlrLayer.Background
        namespace: "wallpaper"
        exclusiveZone: -1
        screen: modelData
        anchors {
            bottom: true
            top: true
            left: true
            right: true
        }
        mask: Region { }
        color: "#1b1b1b"
    
        property string shaderName: ""
    
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
                        wallpaperType = s.wallType
                        if (s.shader && s.shader !== "") wallpaper.shaderName = s.shader
                        console.log(wallpaper.shaderName)
                    } catch(e) { console.warn("[shell] wallState:", e) }
                }
            }
        }
        Component.onCompleted: {
            wallStateProc.running = false
            wallStateProc.running = true
        }
        property int type: wallpaperType
        property string staticBust: ""
        property string videoBust: ""
        property string videoPath: "file://" + Quickshell.env("HOME") + "/.cache/walls/live-bg.mp4"
    
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
        ShaderEffectSource {
            id: shaderSource
            anchors.fill: parent
            live: true
            sourceItem: Rectangle {
                anchors.fill: parent
                color: "transparent"
            }
        }
        
        ShaderEffect {
            id: shaderEffect
            visible: type === 2
            anchors.fill: parent
        
            property real time: 0.0
            property var source: shaderSource
        
            // Счётчик для гарантированного обновления URL
            property int reloadCounter: 0
        
            // Вычисляем URL с учётом имени и счётчика
            property url shaderUrl: {
                var name = wallpaper.shaderName
                if (name === "") name = "aurora_drift"
                var base = Qt.resolvedUrl("wallpapers/shaders/" + name + ".qsb")
                // Добавляем фиктивный параметр, чтобы URL менялся и кэш сбрасывался
                return base + "?r=" + reloadCounter
            }
        
            fragmentShader: shaderUrl
        
            // При изменении имени шейдера инкрементируем счётчик
            Connections {
                target: wallpaper
                function onShaderNameChanged() {
                    if (wallpaper.type === 2) {
                        shaderEffect.reloadCounter++
                    }
                }
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
}
