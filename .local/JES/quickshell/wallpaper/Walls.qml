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
            top: true
            bottom: true
            left: true
            right: true
        }
        
        mask: Region { }
        color: "#1b1b1b"
    
        property string shaderName: "aurora_drift"
    
        Process {
            id: wallStateProc
            running: false
            command: [
                localPath(Qt.resolvedUrl("wallpaper-picker")),
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
        property string videoPath: "file://" + Quickshell.env("HOME") + "/.cache/JES/walls/live-bg.mp4"
    
        onTypeChanged: {
            if (type === 3) {
                player.source = videoPath
                player.play()
            } else {
                player.stop()
                player.source = ""
            }
        }
    
        FileView {
            path: Quickshell.env("HOME") + "/.cache/JES/walls/no-live-bg.jpg"
            watchChanges: true
            onFileChanged: staticBust = "?" + Date.now()
        }
    
        FileView {
            path: Quickshell.env("HOME") + "/.cache/JES/walls/live-bg.mp4"
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

        // --- Безопасный хот-релоад стейта через TOML ---
        FileView {
            path: Quickshell.env("HOME") + "/.config/JES/wallpaper.toml"
            watchChanges: true
            onFileChanged: {
                if (!wallStateProc.running) {
                    wallStateProc.running = true
                }
            }
        }
    
        // --- Статика ---
        Image {
            id: staticImg
            visible: type === 1
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: "file://" + Quickshell.env("HOME") + "/.cache/JES/walls/no-live-bg.jpg" + staticBust
        }
    
        // --- Шейдер с фоллбеком и защитой от пустого имени ---
        Item {
            anchors.fill: parent
            visible: type === 2

            ShaderEffect {
                id: shaderEffect
                anchors.fill: parent

                property real time: 0.0
                property vector2d resolution: Qt.vector2d(width, height)

                fragmentShader: {
                    var name = wallpaper.shaderName !== "" ? wallpaper.shaderName : "aurora_drift"
                    return "file://" + Quickshell.env("HOME") + "/.config/JES/wallpapers/shaders/" + name + ".qsb"
                }

                Timer {
                    interval: 16
                    running: wallpaper.type === 2
                    repeat: true
                    onTriggered: {
                        shaderEffect.time = shaderEffect.time + 0.016
                    }
                }
            }
        }
        
        // --- Видео ---
        MediaPlayer {
            id: player
            loops: MediaPlayer.Infinite
            videoOutput: wallpaper.type === 3 ? videoOut : null
        }

        Item {
            anchors.fill: parent
            visible: type === 3

            VideoOutput {
                id: videoOut
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
                antialiasing: false
            }
        }
    }
}
