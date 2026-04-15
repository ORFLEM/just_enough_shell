import Quickshell
import Quickshell.Wayland
import QtQuick

WlrLayershell {
    id: root
    namespace: "power"
    layer: WlrLayer.Overlay
    implicitHeight: 300
    implicitWidth: 1488
    color: "transparent"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    function closePower() {
        Quickshell.execDetached(["sh", "-c", "quickshell ipc call root togglePower"])
    }

    // ESC на корневом Item ловится через FocusScope
    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: root.closePower()

        // фон — клик мимо кнопок закрывает
        MouseArea {
            anchors.fill: parent
            onClicked: root.closePower()
        }

        Rectangle {
            anchors.fill: parent
            radius: mainRad
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: mainRad
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

            Row {
                anchors.centerIn: parent
                spacing: 3

                Repeater {
                    model: [
                        { icon: "",   cmd: "systemctl poweroff" },
                        { icon: "",   cmd: "systemctl reboot" },
                        { icon: "󰗽",   cmd: "~/.config/quickshell/scripts/exit.sh" },
                        { icon: "󰤄",   cmd: "systemctl suspend" },
                        { icon: "",   cmd: "hyprlock" },
                    ]

                    delegate: Item {
                        width: height
                        height: 294

                        Rectangle {
                            anchors.fill: parent
                            radius: mainRad - 3
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
                            id: btnBg
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            id: btnIcon
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            renderType: Text.NativeRendering
                            font.pixelSize: 225
                            font.weight: Font.Bold
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                btnBg.color = col.accent
                                btnIcon.color = col.fontDark
                                btnIcon.font.pixelSize = 250
                            }
                            onExited: {
                                btnBg.color = "transparent"
                                btnIcon.color = col.accent
                                btnIcon.font.pixelSize = 225
                            }
                            onClicked: {
                                Quickshell.execDetached(["sh", "-c", modelData.cmd])
                                closePower()
                            }
                        }
                    }
                }
            }
        }
    }
}
