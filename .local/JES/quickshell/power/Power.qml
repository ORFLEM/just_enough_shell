import Quickshell
import Quickshell.Wayland
import QtQuick

WlrLayershell {
    id: power
    namespace: "power"
    layer: WlrLayer.Overlay
    color: "transparent"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        right: true
        left: true
    }
    property int current: 0
    property var model: [
                        { current: 1, icon: "", cmd: "systemctl poweroff" },
                        { current: 2, icon: "", cmd: "systemctl reboot" },
                        { current: 3, icon: "󰗽", cmd: localPath(Qt.resolvedUrl("../scripts/exit.sh")) },
                        { current: 4, icon: "󰤄", cmd: "systemctl suspend" },
                        { current: 5, icon: "", cmd: "hyprlock" }]

    function closePower() {
        root.togglePower()
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: power.closePower()
        Keys.onRightPressed: power.current = Math.min(power.current + 1, 5)
        Keys.onLeftPressed: power.current = Math.max(power.current - 1, 0)
        Keys.onReturnPressed: {
            Quickshell.execDetached(["sh", "-c", power.model[power.current - 1].cmd])
            power.closePower()
        }

        MouseArea {
            anchors.fill: parent
            onClicked: power.closePower()
        }

        Rectangle {
            id: powerBtn
            anchors.centerIn: parent
            height: 260
            width: powerRow.width + 6
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
                id: powerRow
                anchors.centerIn: parent
                spacing: 3

                Repeater {
                    id: pwrRepeater
                    model: power.model

                    delegate: Item {
                        width: height
                        height: powerBtn.height - 6

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
                            color: modelData.current == power.current ? col.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            id: btnIcon
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: modelData.current == power.current ? col.fontDark : col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            renderType: Text.NativeRendering
                            font.pixelSize: modelData.current == power.current ? 250 : 225
                            font.weight: Font.Bold
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                power.current = modelData.current
                            }
                            onExited: {
                                power.current = 0
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

// a cho ti chotel tut? eto prosto knopki pitania, vso
