import Quickshell
import Quickshell.Wayland
import QtQuick
import "../helpers"

WlrLayershell {
    layer: WlrLayer.Overlay
    namespace: "sys-popups"
    exclusiveZone: 0

    implicitWidth: 220
    implicitHeight: contentCol.implicitHeight + 6
    color: "transparent"
    anchors.bottom: true

    property var vl: ({})
    property var lght: ({})

    property bool showVol: false
    property bool showBright: false
    
    JsonListen {
        command: "~/.config/quickshell/popSysInf/vol.sh"
        onDataChanged: {
            vl = data
            showVol = true
            volTimer.restart()
        }
    }
    
    JsonListen {
        command: "~/.config/quickshell/popSysInf/birghtness.sh"
        onDataChanged: {
            lght = data
            showBright = true
            brightTimer.restart()
        }
    }
    
    Timer {
        id: volTimer
        interval: 2000
        onTriggered: showVol = false
    }
    
    Timer {
        id: brightTimer
        interval: 2000
        onTriggered: showBright = false
    }
    
    Column {
        id: contentCol
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: parent.width
        spacing: 6

        // Volume
        Rectangle {
            width: parent.width
            height: showVol ? 16 : 0
            clip: true
            radius: 8
            color: "transparent"

            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }


            Rectangle {
                anchors.fill: parent
                radius: parent.radius
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

            Item {
                anchors.fill: parent
                anchors.margins: 3

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: vl.sign ?? ""
                    color: col.accent
                    font.family: "Mononoki Nerd Font Propo"
                    font.pixelSize: 14
                }

                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth: 200
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    radius: 5
                    opacity: 0.65
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: col.backgroundAlt2 }
                        GradientStop { position: 0.275; color: col.backgroundAlt1 }
                        GradientStop { position: 0.725; color: col.backgroundAlt1 }
                        GradientStop { position: 1.0; color: col.backgroundAlt2 }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 2
                        implicitHeight: parent.height - 4
                        implicitWidth: (vl.vol ?? 0) * 2
                        color: col.accent
                        radius: 3
                    }
                }
            }
        }

        // Light
        Rectangle {
            width: parent.width
            height: showBright ? 16 : 0
            clip: true
            radius: 8
            color: "transparent"

            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }


            Rectangle {
                anchors.fill: parent
                radius: parent.radius
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

            Item {
                anchors.fill: parent
                anchors.margins: 3

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: lght.sign ?? ""
                    color: col.accent
                    font.family: "Mononoki Nerd Font Propo"
                    font.pixelSize: 14
                }

                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth: 200
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    radius: 5
                    opacity: 0.65
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: col.backgroundAlt2 }
                        GradientStop { position: 0.275; color: col.backgroundAlt1 }
                        GradientStop { position: 0.725; color: col.backgroundAlt1 }
                        GradientStop { position: 1.0; color: col.backgroundAlt2 }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 2
                        implicitHeight: parent.height - 4
                        implicitWidth: (lght.bright ?? 0) * 2
                        color: col.accent
                        radius: 3
                    }
                }
            }
        }

    }
}
