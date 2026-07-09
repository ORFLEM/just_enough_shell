import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtMultimedia
import "../../"
import "../../helpers"

WlrLayershell {
    id: playerPopup
    layer: WlrLayer.Top
    namespace: "player"
    exclusiveZone: -1
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    anchors {
        top: true
        right: true
    }

    property bool isOpen: false
    property bool showimage: false
    
    implicitHeight: isOpen ? (barOnTop && !minibar && screen.width <= 3480 ? (showimage ? 530 + barHeight : 230 + barHeight) : (showimage ? 530 : 230)) : 0
    implicitWidth: artBox.width + 171
    color: "transparent"

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: barOnTop && !minibar && screen.width <= 3480 ? barHeight : 0
        anchors.bottomMargin: isOpen ? 6 : 0

        Rectangle {
            id: popupRect
            anchors.fill: parent
            anchors.rightMargin: isOpen ? 6 : 16
            anchors.topMargin: isOpen ? 6 : -6
            color: "transparent"
            radius: mainRad
            clip: true
            
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

            // Обложка как фон + тёмный оверлей
            ClippingRectangle {
                anchors.fill: parent
                radius: mainRad
                opacity: 0.85
                color: base.base02
                
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

                // --- ВЫЧИСЛЯЕМАЯ ШИРИНА ---
                width: coverImage.width

                radius: mainRad - 3
                color: base.base02

                MediaPlayer {
                    id: animatedPlayer
                    source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/bar/images/sticker.webm"   // Укажи свой путь
                    videoOutput: videoOutputpl
                    loops: MediaPlayer.Infinite
                    autoPlay: true
                }

                VideoOutput {
                    id: videoOutputpl
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectFit
                    
                    visible: playerPopup.isOpen && vars.plr.art === Quickshell.env("HOME") + "/.config/quickshell/bar/images/music.png"
                    onVisibleChanged: {
                        if (!visible) {
                            animatedPlayer.stop()
                        } else {
                            animatedPlayer.play()
                        }
                    }
                }
                
                Image {
                    id: coverImage
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    visible: vars.plr.art !== Quickshell.env("HOME") + "/.config/quickshell/bar/images/music.png"
                    anchors.centerIn: parent
                    sourceSize.width: {
                        let sw = sourceSize.width
                        let sh = sourceSize.height
                        return (sw > 0 && sh > 0) ? height * sw / sh : 0
                    }
                    sourceSize.height: showimage ? 512 : 212
                    fillMode: Image.PreserveAspectCrop
                    source: vars.plr.art !== "" ? "file://" + vars.plr.art + "?v=" + vars.plr.ver : ""
                    onSourceChanged: {
                        if (vars.plr.art === Quickshell.env("HOME") + "/.config/quickshell/bar/images/music.png") {
                            animatedPlayer.stop()
                        } else {
                            animatedPlayer.play()
                        }
                    }
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

                        Item {
                            width: parent.width
                            height: fontSize
                            MarqueeText {
                                width: parent.width
                                text: vars.plr.title
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize
                            }
                        }

                        Text {
                            width: parent.width
                            text: vars.plr.artist
                            color: col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize
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
                    height: 40
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
                                id: playerButton
                                width: 48
                                height: 34
                                property bool hovered: false

                                Rectangle {
                                    id: btnBg
                                    anchors.fill: parent
                                    anchors.margins: 0
                                    radius: mainRad - 5
                                    color: playerButton.hovered ? col.fontDark : "transparent"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                Text {
                                    id: btnIcon
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    color: playerButton.hovered ? col.font : col.fontDark
                                    font.family: fontFamily
                                    font.pixelSize: 25
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        playerButton.hovered = true
                                    }
                                    onExited: {
                                        playerButton.hovered = false
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
