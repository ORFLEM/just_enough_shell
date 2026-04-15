import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import "../../"
import "../../helpers"

WlrLayershell {
    id: playerPopup
    layer: WlrLayer.Top
    namespace: "player"

    anchors {
        top: true
        right: true
    }

    property bool isOpen: false
    property bool showimage: false
    
    implicitHeight: isOpen ? (showimage ? 530 : 230) : 0
    implicitWidth: showimage ? 689 : 389
    color: "transparent"

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: isOpen ? 6 : -6
        anchors.rightMargin: isOpen ? 0 : 8
        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        
        // opacity: isOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Rectangle {
            id: popupRect
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            anchors.bottomMargin: 6
            color: "transparent"
            radius: mainRad
            clip: true

            // Обложка как фон + тёмный оверлей
            ClippingRectangle {
                anchors.fill: parent
                radius: mainRad
                opacity: 0.85
                color: "#2b2b2b"
                
                Image {
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    anchors.centerIn: parent
                    sourceSize.width: showimage ? 700 : 400
                    sourceSize.height: showimage ? 700 : 400
                    fillMode: Image.PreserveAspectCrop
                    source: vars.plr.art !== "" ? "file://" + vars.plr.art + "?v=" + vars.plr.ver : ""
                }
                
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: col.background3 }
                        GradientStop { position: 0.05; color: col.background2 }
                        GradientStop { position: 0.3; color: col.background1 }
                        GradientStop { position: 0.7; color: col.background1 }
                        GradientStop { position: 0.95; color: col.background2 }
                        GradientStop { position: 1.0; color: col.background3 }
                    }

                    opacity: 0.75
                }
            }

            // Обложка слева — абсолютный якорь
            ClippingRectangle {
                id: artBox
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 3
                width: height  // квадрат
                radius: mainRad - 3
                color: "#2b2b2b"

                Image {
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    anchors.centerIn: parent
                    sourceSize.width: showimage ? 512 : 212
                    sourceSize.height: showimage ? 512 : 212
                    fillMode: Image.PreserveAspectCrop
                    source: vars.plr.art !== "" ? "file://" + vars.plr.art + "?v=" + vars.plr.ver : ""
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: showimage = !showimage
                }          
            }

            // Правая часть — заполняет всё что осталось
            Item {
                anchors.top: parent.top
                anchors.left: artBox.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 3
                anchors.leftMargin: 3

                // Инфо блок — от верха до кнопок
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: navBox.top
                    anchors.bottomMargin: 3
                    radius: mainRad - 3
                    opacity: 0.8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: col.backgroundAlt2 }
                        GradientStop { position: 0.275; color: col.backgroundAlt1 }
                        GradientStop { position: 0.725; color: col.backgroundAlt1 }
                        GradientStop { position: 1.0; color: col.backgroundAlt2 }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 3
                        anchors.rightMargin: 3
                        spacing: 35

                        MarqueeText {
                            width: parent.width
                            text: vars.plr.title
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                        }

                        Text {
                            width: parent.width
                            text: vars.plr.artist
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // Кнопки — прижаты к низу
                Rectangle {
                    id: navBox
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 36
                    radius: mainRad - 3
                    color: col.accent
                    opacity: 0.85

                    Row {
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: [
                                { icon: "󰒮", cmd: "playerctl previous" },
                                { icon: vars.plr.status, cmd: "playerctl play-pause" },
                                { icon: "󰒭", cmd: "playerctl next" }
                            ]

                            delegate: Item {
                                width: 48
                                height: 30

                                Rectangle {
                                    id: btnBg
                                    anchors.fill: parent
                                    anchors.margins: 0
                                    radius: mainRad - 5
                                    color: "transparent"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                Text {
                                    id: btnIcon
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    color: col.fontDark
                                    font.family: "Mononoki Nerd Font Propo"
                                    font.pixelSize: 25
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        btnBg.color = col.backgroundAlt1
                                        btnIcon.color = col.accent
                                    }
                                    onExited: {
                                        btnBg.color = "transparent"
                                        btnIcon.color = col.fontDark
                                    }
                                    onClicked: Quickshell.execDetached(["sh", "-c", modelData.cmd])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
