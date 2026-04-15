import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import "../helpers"

WlrLayershell {
    id: launcher
    layer: WlrLayer.Overlay
    namespace: "launcher"
    width: 1000
    height: 513
    color: "transparent"

    property int currentTab: 0
    property var apps: []
    property var clips: []

    keyboardFocus: WlrKeyboardFocus.Exclusive

    function closeLauncher() {
        searchInput.text = ""
        Quickshell.execDetached(["sh", "-c", "quickshell ipc call root toggleLaunch"])
    }

    function launchApp(app) {
        Quickshell.execDetached(["sh", "-c",
            Quickshell.env("HOME") + "/.config/quickshell/launcher/launch --launched '" + app.name + "'"])
        if (app.terminal) {
            Quickshell.execDetached(["sh", "-c", Quickshell.env("TERMINAL") + " -e " + app.exec])
        } else {
            Quickshell.execDetached(["sh", "-c", app.exec])
        }
        closeLauncher()
    }

    function pasteClip(clip) {
        Quickshell.execDetached(["sh", "-c",
            Quickshell.env("HOME") + "/.config/quickshell/launcher/cliphist-json " + clip.id])
        closeLauncher()
    }

    // Проги
    Process {
        id: appProc
        running: false
        command: ["sh", "-c", Quickshell.env("HOME") + "/.config/quickshell/launcher/launch " + searchInput.text]
        stdout: SplitParser {
            onRead: data => {
                try { launcher.apps = JSON.parse(data) } catch(e) {}
            }
        }
    }

    // Буфер
    Process {
        id: clipProc
        running: false
        command: [Quickshell.env("HOME") + "/.config/quickshell/launcher/cliphist-json"]
        stdout: SplitParser {
            onRead: data => {
                try { launcher.clips = JSON.parse(data) } catch(e) {}
            }
        }
    }

    onCurrentTabChanged: {
        if (currentTab === 0) {
            clipProc.running = false
            appProc.running = false
            appProc.running = true
        } else if (currentTab === 1) {
            appProc.running = false
            clipProc.running = false
            clipProc.running = true
        }
        activeList.currentIndex = -1
    }

    Component.onCompleted: {
        appProc.running = true
        searchInput.forceActiveFocus()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: closeLauncher()
    }

    Rectangle {
        id: win
        width: 1000
        height: 513
        anchors.centerIn: parent
        radius: mainRad
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: col.background3 }
            GradientStop { position: 0.05; color: col.background2 }
            GradientStop { position: 0.3; color: col.background1 }
            GradientStop { position: 0.7; color: col.background1 }
            GradientStop { position: 0.95; color: col.background2 }
            GradientStop { position: 1.0; color: col.background3 }
        }

        MouseArea { anchors.fill: parent; onClicked: {} }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ========== ЛЕВАЯ ПАНЕЛЬ ==========
            ClippingRectangle {
                Layout.preferredWidth: 480
                Layout.fillHeight: true
                radius: mainRad
                color: "transparent"
                ShaderEffect {
                    anchors.fill: parent
                    property color accent: col.accent
                    property color dark: "#2b2b2b"
                    property color mid: col.background1
                    property vector2d resolution: Qt.vector2d(width, height)
                    property real time: 0.0
                    property real patternScale: 3.2
                    property real evolutionSpeed: 0.004
                
                    NumberAnimation on time {
                        from: 0; to: 1000
                        duration: 1000000
                        loops: Animation.Infinite
                        running: launcher.visible
                    }
                
                    fragmentShader: Qt.resolvedUrl("bg.frag.qsb")
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 0

                        Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: mainRad - 3
                        gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: col.background3 }
                                    GradientStop { position: 0.05; color: col.background2 }
                                    GradientStop { position: 0.3; color: col.background1 }
                                    GradientStop { position: 0.7; color: col.background1 }
                                    GradientStop { position: 0.95; color: col.background2 }
                                    GradientStop { position: 1.0; color: col.background3 }
                                }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Text {
                                text: currentTab === 1 ? "󰅍" : ""
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 15
                                placeholderText: currentTab === 1 ? "Буфер обмена..." : "Поиск..."
                                placeholderTextColor: col.font
                                background: Item {}

                                Keys.onEscapePressed: closeLauncher()
                                Keys.onUpPressed: activeList.decrementCurrentIndex()
                                Keys.onDownPressed: activeList.incrementCurrentIndex()
                                Keys.onPressed: event => {
                                    if (event.modifiers & Qt.ShiftModifier) {
                                        if (event.key === Qt.Key_Left) currentTab = Math.max(0, currentTab - 1)
                                        else if (event.key === Qt.Key_Right) currentTab = Math.min(1, currentTab + 1)
                                    }
                                }
                                Keys.onReturnPressed: {
                                    if (currentTab === 0 && activeList.currentIndex >= 0 && apps.length > 0)
                                        launchApp(apps[activeList.currentIndex])
                                    else if (currentTab === 1 && activeList.currentIndex >= 0 && clips.length > 0)
                                        pasteClip(clips[activeList.currentIndex])
                                }

                                onTextChanged: {
                                    activeList.currentIndex = -1
                                    if (currentTab === 0) {
                                        appProc.running = false
                                        appProc.running = true
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                    

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: mainRad - 3
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: col.background3 }
                            GradientStop { position: 0.05; color: col.background2 }
                            GradientStop { position: 0.3; color: col.background1 }
                            GradientStop { position: 0.7; color: col.background1 }
                            GradientStop { position: 0.95; color: col.background2 }
                            GradientStop { position: 1.0; color: col.background3 }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 3
                            spacing: 3

                            Repeater {
                                model: ["Программы","Буфер обмена"]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    height: 30
                                    radius: mainRad - 5
                                    color: currentTab === index ? col.accent : col.backgroundAlt1
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: currentTab === index ? col.fontDark : col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: currentTab = index
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ========== ПРАВАЯ ПАНЕЛЬ ==========
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                // Проги (tab 0)
                ListView {
                    id: appList
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3
                    clip: true
                    visible: currentTab === 0
                    model: apps
                    currentIndex: -1

                    delegate: Rectangle {
                        width: appList.width
                        height: 48
                        radius: mainRad - 3
                        property bool isCurrent: ListView.isCurrentItem
                        color: isCurrent ? col.accent : col.backgroundAlt1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 15

                            IconImage {
                                width: 32
                                height: 32
                                source: Quickshell.iconPath(modelData.icon ?? "", true)
                                smooth: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name ?? ""
                                color: parent.parent.isCurrent ? col.fontDark : col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 14
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (appList.currentIndex === index) launchApp(apps[index])
                                else appList.currentIndex = index
                            }
                        }
                    }
                }

                // Буфер (tab 1)
                ListView {
                    id: clipList
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3
                    clip: true
                    visible: currentTab === 1
                    currentIndex: -1

                    // фильтр по поиску на стороне QML
                    model: {
                        if (searchInput.text === "") return clips
                        return clips.filter(c =>
                            c.text.toLowerCase().includes(searchInput.text.toLowerCase()))
                    }

                    delegate: Rectangle {
                        width: clipList.width
                        height: modelData.type === "image" ? 80 : 48
                        radius: mainRad - 3
                        property bool isCurrent: ListView.isCurrentItem
                        color: isCurrent ? col.accent : col.backgroundAlt1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 15

                            // картинка или иконка текста
                            Image {
                                visible: modelData.type === "image"
                                width: 64
                                height: 64
                                sourceSize.width: 64
                                sourceSize.height: 64
                                source: modelData.type === "image" ? "file://" + modelData.icon : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                visible: modelData.type === "text"
                                text: "󰅍"
                                color: isCurrent ? col.fontDark : col.accent
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 24
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.text ?? ""
                                color: parent.parent.isCurrent ? col.fontDark : col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                maximumLineCount: modelData.type === "image" ? 1 : 2
                                wrapMode: Text.WordWrap
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (clipList.currentIndex === index) pasteClip(clipList.model[index])
                                else clipList.currentIndex = index
                            }
                        }
                    }
                }
            }
        }
    }

    // activeList — для навигации стрелками независимо от таба
    property var activeList: currentTab === 0 ? appList : clipList
}
