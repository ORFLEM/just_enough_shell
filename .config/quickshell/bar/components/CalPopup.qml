import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../../"
import "../../helpers"

WlrLayershell {
    id: calPopup
    layer:  WlrLayer.Top
    namespace: "calendar"
    exclusiveZone: -1
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    property bool isOpen: false


    anchors {
        top: true
    }

    implicitHeight: isOpen ? 290 : 0
    implicitWidth: 360
    color: "transparent"

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: barOnTop ? barHeight : 0
        clip: true
        
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: isOpen ? 6 : -6
            radius: mainRad
            color: "transparent"
            
            Behavior on anchors.topMargin {
                NumberAnimation {
                    duration: 350
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

            Column {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 3
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: (mainRad - 3) <= 15 ? parent.width : parent.width - mainRad + 15 
                    height: 30

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
                    
                    Row {
                        width: parent.width
                        Repeater {
                            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                            Text {
                                width: parent.width / 7
                                height: 28
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                color: col.font
                            }
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7
                    rows: 6
                    columnSpacing: 3
                    rowSpacing: 3
                    clip: true
                
                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            // Переносим dayObj внутрь делегата — теперь index доступен
                            property var dayObj: vars.cal.Days ? vars.cal.Days["day" + index] : null
                
                            width: (parent.width - parent.columnSpacing * 6) / 7
                            height: (parent.parent.height - 60 - parent.rowSpacing * 5 - 6) / 6
                            color: {
                                if (!dayObj) return "transparent"
                                if (dayObj.style === "today")
                                    return col.accent
                                if (dayObj.style === "tholiday")
                                    return base.base12
                                return "transparent"
                            }
                            radius: 4
                
                            Text {
                                anchors.centerIn: parent
                                text: dayObj ? dayObj.day : ""
                                color: {
                                    if (!dayObj) return col.font
                                    if (dayObj.style === "omonth")
                                        return base.base05
                                    if (dayObj.style === "today")
                                        return col.fontDark
                                    if (dayObj.style === "tholiday")
                                        return col.font
                                    if (dayObj.style === "oholiday")
                                        return base.base09
                                    if (dayObj.style === "oweekend")
                                        return base.base09
                                    if (dayObj.style === "tweekend")
                                        return base.base15
                                    return col.font
                                }
                                // Защита от нулевого размера шрифта
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                ToolTip {
                                    // Привязываем текст и видимость так же, как вы делали
                                    visible: (dayObj.style === "oholiday" || dayObj.style === "tholiday") && ma.containsMouse
                                    delay: 500
                                
                                    // Кастомизация фона
                                    background: Rectangle {
                                        radius: mainRad   // тот же радиус, что у календаря
                                        opacity: 0.85
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: col.backgroundAlt2 }
                                            GradientStop { position: 0.275; color: col.backgroundAlt1 }
                                            GradientStop { position: 0.725; color: col.backgroundAlt1 }
                                            GradientStop { position: 1.0; color: col.backgroundAlt2 }
                                        }
                                    }
                                
                                    // Кастомизация содержимого (текста)
                                    contentItem: Text {
                                        text: dayObj.holiday
                                        font.family: fontFamily
                                        font.pixelSize: fontSize
                                        color: col.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                        rightPadding: 8
                                        topPadding: 4
                                        bottomPadding: 4
                                    }
                                }
                            }
                
                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: base.base12
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 2
                                visible: dayObj.style === "oholiday"
                            }
                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true // Нужно для отслеживания наведения
                            }
                        }
                    }
                }
                
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: (mainRad - 3) <= 15 ? parent.width : parent.width - mainRad + 15 
                    height: 30
                
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
                
                    Row {
                        anchors.centerIn: parent
                        spacing: 12
                
                        Text {
                            text: " << "
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: col.font
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal prev_year"])
                            }
                        }
                        Text {
                            text: " < "
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: col.font
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal prev"])
                            }
                        }
                        Text {
                            text: vars.cal.month_name + " | " + vars.cal.year
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: col.font
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal today"])
                            }
                        }                        Text {
                            text: " > "
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: col.font
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal next"])
                            }
                        }
                        Text {
                            text: " >> "
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: col.font
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal next_year"])
                            }
                        }
                    }
                }
            }
        }
    }                                             
}
