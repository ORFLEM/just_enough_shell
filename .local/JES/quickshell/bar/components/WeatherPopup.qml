import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../../"

WlrLayershell {
    id: weatherPopup
    layer: WlrLayer.Top
    namespace: "weather"
    exclusiveZone: -1
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    property bool isOpen: false

    anchors.top: true

    implicitHeight: isOpen ? 331 : 0
    implicitWidth: 380
    color: "transparent"

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    FileView {
        id: weatherFile
        path: Quickshell.env("HOME") + "/.cache/JES/JES_weather_cache.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                var obj = JSON.parse(text())
                weatherData = obj
            } catch(e) {
                console.warn("[Weather] JSON parse error:", e)
                weatherData = ({})
            }
        }
        Component.onCompleted: reload()
    }

    property var weatherData: ({})

    readonly property string city:     weatherData.city || "—"
    readonly property string temp:     weatherData.temp  || "—"
    readonly property string feels:    weatherData.feels || "—"
    readonly property string humidity: weatherData.humidity || "—"
    readonly property string pressure: weatherData.pressure || "—"
    readonly property string wind:     weatherData.wind  || "—"
    readonly property string icon:     weatherData.icon  || ""
    readonly property string desc:     weatherData.desc  || "—"
    readonly property string updated:  weatherData.updated || "—"
    readonly property var forecast:    weatherData.forecast || []

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
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                spacing: 3

                // Row 1: City | Updated (2 колонки)
                Row {
                    width: parent.width
                    spacing: 3
                    
                    // Левая колонка - City
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 24
                        color: "transparent"
                        
                        Text {
                            id: cityText
                            anchors.leftMargin: 6
                            anchors.left: parent.left
                            text: city
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            color: col.font
                        }
                    }
                    
                    // Правая колонка - Updated
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 24
                        color: "transparent"
                        
                        Text {
                            id: updatedText
                            anchors.right: parent.right
                            text: "Updated " + updated
                            font.family: fontFamily
                            font.pixelSize: fontSize - 2
                            color: base.base05
                        }
                    }
                }

                // Row 2: Temp + Desc | Icon (2 колонки)
                Row {
                    width: parent.width
                    spacing: 3
                    
                    // Левая колонка - Temp + Desc
                    Column {
                        width: (parent.width - 20) / 2
                        spacing: 4
                        
                        Text {
                            text: temp + "°"
                            font.family: "FreeSans"
                            font.pixelSize: fontSize * 4.4
                            font.weight: Font.Bold
                            color: col.accent
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                        
                        Text {
                            text: desc
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            color: col.font
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                    }
                    
                    // Правая колонка - Icon
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 110
                        color: "transparent"
                        
                        Text {
                            text: icon
                            font.family: fontFamily
                            font.pixelSize: fontSize * 5.5
                            font.weight: Font.Bold
                            color: col.font
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            renderType: Text.NativeRendering
                        }
                    }
                }

                // Row 3: Details (2 колонки)
                Row {
                    width: parent.width
                    spacing: 20
                    
                    // Левая колонка - Feels + Humidity
                    Column {
                        width: (parent.width - 20) / 2
                        spacing: 2
                        
                        Text {
                            text: "Feels like " + feels + "°"
                            font.family: fontFamily
                            font.pixelSize: fontSize - 2
                            color: base.base05
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                        
                        Text {
                            text: "Humidity " + humidity + "%"
                            font.family: fontFamily
                            font.pixelSize: fontSize - 2
                            color: base.base05
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                    }
                    
                    // Правая колонка - Wind + Pressure
                    Column {
                        width: (parent.width - 20) / 2
                        spacing: 2
                        
                        Text {
                            text: "Wind " + wind + " m/s"
                            font.family: fontFamily
                            font.pixelSize: fontSize - 2
                            color: base.base05
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                        
                        Text {
                            text: "Pressure " + pressure + " mmHg"
                            font.family: fontFamily
                            font.pixelSize: fontSize - 2
                            color: base.base05
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                    }
                }

                // Forecast block (фулл ширина)
                Rectangle {
                    width: parent.width
                    height: 100
                    radius: mainRad - 3
                    color: col.backgroundAlt1
                    opacity: 0.65
                    
                    ListView {
                        id: forecastList
                        anchors.fill: parent
                        anchors.margins: 3
                        orientation: ListView.Horizontal
                        spacing: 30
                        clip: true
                        model: forecast
                        highlightRangeMode: ListView.NoHighlightRange
                        
                        delegate: Column {
                            width: 70
                            spacing: 4
                            
                            Text {
                                text: modelData.day || ""
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                color: col.font
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                            
                            Text {
                                text: modelData.icon || ""
                                font.family: fontFamily
                                font.pixelSize: fontSize * 2.5
                                font.weight: Font.Bold
                                color: col.font
                                horizontalAlignment: Text.AlignHCenter
                                renderType: Text.NativeRendering
                                width: parent.width
                            }
                            
                            Text {
                                text: (modelData.max || "—") + "/" + (modelData.min || "—")
                                font.family: fontFamily
                                font.pixelSize: fontSize - 2
                                color: base.base05
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: {
                                var delta = wheel.angleDelta.x || wheel.angleDelta.y
                                var velocity = delta * 5.5
                                forecastList.flick(velocity, 0)
                                wheel.accepted = true
                            }
                        }
                    }
                }
            }
        }
    }
}
