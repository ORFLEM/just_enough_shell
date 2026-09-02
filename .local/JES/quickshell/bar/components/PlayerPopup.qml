import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../"
import JES.Helpers

WlrLayershell {
    id: playerPopup
    layer: WlrLayer.Top
    namespace: "player"
    exclusiveZone: -1
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    anchors {
        top: barOnTop
        bottom: !barOnTop
        right: true
    }
    
    margins {
        top: barOnTop ? barHeight : 0
        bottom: !barOnTop ? barHeight : 0
    }

    property bool isOpen: false
    property bool showimage: false
    
    // Выделяем максимальный запас по высоте под раскрытую обложку
    implicitHeight: 524 + root.wtw
    implicitWidth: artBox.width + 172 + root.wtw - 6
    color: "transparent"

    // Передаем клики только в область popupBody
    mask: Region { item: popupBody }

    Item {
        anchors.fill: parent
        clip: true
        
        Item {
            id: popupBody
            implicitHeight: showimage ? 518 : 218 
            implicitWidth: artBox.width + 172 + root.wtw - 6
            
            // Динамический выезд из-за панели
            y: isOpen 
               ? (barOnTop ? root.wtw : parent.height - height - root.wtw)
               : (barOnTop ? -height : parent.height)

            Behavior on y {
                NumberAnimation {
                    duration: 250 * root.animations
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 250 * root.animations
                    easing.type: Easing.OutCubic
                }
            }
            
            Rectangle {
                id: popupRect
                anchors.fill: parent
                anchors.rightMargin: isOpen ? root.wtw : mainRad + root.wtw
                color: "transparent"
                radius: mainRad
                clip: true
                
                Behavior on anchors.rightMargin {
                    NumberAnimation {
                        duration: 250 * root.animations
                        easing.type: Easing.Linear
                    }
                }
                
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
                        source: vars.plr.art ? "file://" + vars.plr.art + "?v=" + vars.plr.ver : ""
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

                // Обложка слева
                ClippingRectangle {
                    id: artBox
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: root.margins

                    width: coverImage.width

                    radius: mainRad - root.margins
                    color: base.base02

                    Image {
                        id: coverImage
                        asynchronous: true
                        smooth: true
                        mipmap: true
                        anchors.centerIn: parent
                        sourceSize.width: {
                            let sw = sourceSize.width
                            let sh = sourceSize.height
                            return (sw > 0 && sh > 0) ? height * sw / sh : 0
                        }
                        sourceSize.height: showimage ? 512 : 212
                        fillMode: Image.PreserveAspectCrop
                        source: vars.plr.art ? "file://" + vars.plr.art + "?v=" + vars.plr.ver : ""
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: showimage = !showimage
                    }          
                }

                // Правая часть
                Item {
                    anchors.top: parent.top
                    anchors.left: artBox.right
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: root.margins
                    anchors.leftMargin: root.margins
                
                    // Инфо блок
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: navBox.top
                        anchors.bottomMargin: root.margins
                        radius: mainRad - root.margins
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
                            anchors.leftMargin: root.margins
                            anchors.rightMargin: root.margins
                            spacing: 30
                
                            Item {
                                width: parent.width
                                height: fontSize
                                MarqueeText {
                                    width: parent.width
                                    text: vars.plr.title ?? ""
                                    color: col.font
                                    font.family: fontFamily
                                    font.pixelSize: fontSize
                                }
                            }
                
                            Text {
                                width: parent.width
                                text: vars.plr.artist ?? ""
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        
                        RowLayout {
                            width: parent.width - root.margins * 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.margins: root.margins
                            spacing: root.spacing - 2

                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                radius: mainRad - root.margins - 2
                                color: prevPlrArea.containsMouse ? col.accent : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "<"
                                    color: prevPlrArea.containsMouse ? col.fontDark : col.font
                                    font.family: fontFamily
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: prevPlrArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Quickshell.execDetached([localPath(Qt.resolvedUrl("../../scripts/music")), "prev-player"])
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: vars.plr.player ?? "No Player"
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize - 4
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                radius: mainRad - root.margins - 2
                                color: nextPlrArea.containsMouse ? col.accent : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: ">"
                                    color: nextPlrArea.containsMouse ? col.fontDark : col.font
                                    font.family: fontFamily
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: nextPlrArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Quickshell.execDetached([localPath(Qt.resolvedUrl("../../scripts/music")), "next-player"])
                                }
                            }
                        }
                    }
                
                    // Кнопки управления
                    Rectangle {
                        id: navBox
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 40
                        radius: mainRad - root.margins
                        color: col.accent
                        opacity: 0.85
                
                        Row {
                            anchors.centerIn: parent
                            spacing: root.spacing
                
                            Repeater {
                                model: [
                                    { icon: "󰒮", cmd: "previous" },
                                    { icon: vars.plr.status, cmd: "play-pause" },
                                    { icon: "󰒭", cmd: "next" }
                                ]
                
                                delegate: Item {
                                    id: playerButton
                                    width: (navBox.width - root.margins * 2 - root.spacing * 2) / 3
                                    height: 34 - root.margins * 2 + 6
                                    property bool hovered: false
                
                                    Rectangle {
                                        id: btnBg
                                        anchors.fill: parent
                                        radius: mainRad - root.margins - 2
                                        color: playerButton.hovered ? col.fontDark : "transparent"
                                        Behavior on color { ColorAnimation { duration: 150 * root.animations } }
                                    }
                                    Text {
                                        id: btnIcon
                                        anchors.centerIn: parent
                                        text: modelData.icon ?? ""
                                        color: playerButton.hovered ? col.font : col.fontDark
                                        font.family: fontFamily
                                        font.pixelSize: 25
                                        Behavior on color { ColorAnimation { duration: 150 * root.animations } }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: playerButton.hovered = true
                                        onExited: playerButton.hovered = false
                                        onClicked: Quickshell.execDetached([localPath(Qt.resolvedUrl("../../scripts/music")), modelData.cmd])
                                    }
                                }
                            }
                        }
                    }
                }         
            }
        }
    }
}
