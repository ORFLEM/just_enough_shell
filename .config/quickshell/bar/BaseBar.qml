import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "components"
import "../helpers"
import "../"

WlrLayershell {
    id: panel
    layer: WlrLayer.Top
    namespace: "bar"
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]
    
    property var workspacesData: ({})
    property var cameraData: ({})
    property bool wsHover: false
    property bool sttngsHover: false
    property string activeWindow: ""
    property string kbLayout: ""
    property string cava: ""
    property string timed: ""
    property real coeff: mainRad > 16 ? 1.06363636 + 0.005 * mainRad : 1.1

    anchors {
        top: barOnTop
        bottom: !barOnTop
    }
    
    implicitHeight: barHeight
    implicitWidth: Screen.width <= 3840 ? (minibar ? 1920 : (mainRad > (height-6)/2 ? Screen.width + (height - 6)/2 - mainRad * coeff : Screen.width)) : (minibar ? 1920 : 3440)
    Behavior on implicitWidth { NumberAnimation { duration: 100 } }
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: barOnTop ? 6 : 0
        anchors.bottomMargin: !barOnTop ? 6 : 0
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        radius: mainRad
        color: "transparent"
        
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
            
            // Left section
            Row {
                id: leftSection
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                
                // Launcher
                Item {
                    id: launcherItem
                    property bool hovered: false
                    width: launcherContent.width + 4
                    height: panel.height - 12
                    
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
                        id: launcherBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: launcherItem.hovered ? col.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: launcherContent
                        anchors.centerIn: parent

                        ClippingRectangle {
                            radius: mainRad - 6
                            height: panel.height - 16
                            width: height
                            color: "transparent"
                            Image {
                                sourceSize.width: parent.height * 2
                                sourceSize.height: parent.height * 2
                                source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/bar/images/hui.jpg" 
                                height: parent.height
                                width: height
                            }
                            Image {
                                sourceSize.width: parent.height * 2
                                sourceSize.height: parent.height * 2
                                id: launcherIcon
                                source: "file:///var/lib/AccountsService/icons/" + Quickshell.env("USER")
                                height: parent.height
                                width: height
                            }
                        }
                        Rectangle {
                            width: launchertext.width + 8
                            height: panel.height - 16
                            color: "transparent"
                            Text {
                                id: launchertext
                                anchors.centerIn: parent
                                text: Quickshell.env("USER")
                                color: launcherItem.hovered ? col.fontDark : col.accent
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                font.weight: Font.Bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: launcherItem.hovered = true
                        onExited: launcherItem.hovered = false
                        onClicked: launchOpen = !launchOpen
                    }
                }

                // wallpaper picker
                Item {
                    id: wallItem
                    property bool hovered: false
                    width: wallRow.width + 12
                    height: panel.height - 12
                    
                    Rectangle {
                        anchors.fill: parent
                        radius:  mainRad - 3
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
                        id: wallBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: wallItem.hovered ? col.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: wallRow
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Text {
                            id: wallText
                            text: ""
                            color: wallItem.hovered ? col.fontDark : col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: wallItem.hovered = true
                        onExited: wallItem.hovered = false
                        onClicked: wallPickerOpen = !wallPickerOpen
                    }
                }
                
                // Workspaces - переопределяется в наследниках
                Item {
                    id: workspacesItem
                    width: workspacesRow.width + 4
                    height: panel.height - 12
                    visible: wm_type == "workspaces"
                    
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

                    ClippingRectangle {
                        anchors.fill: parent
                        radius: mainRad - 5
                        anchors.margins: 2
                        color: "transparent"
                        Row {
                            id: workspacesRow
                            anchors.centerIn: parent
                            spacing: 2
                            clip: true
                         
                            Repeater {
                                model: 5
                             
                                WsButton {
                                    wsId: index + 1
                                    wsState: workspacesData["ws" + (index + 1)]?.class || "empty"
                                    icon: workspacesData["ws" + (index + 1)]?.icon || ""
                                 
                                    onClicked: {
                                        changeWorkspace(wsId)
                                    }
                                }
                            }

                            Repeater {
                                model: 5

                                WsButton {
                                    wsId: index + 6
                                    wsState: wsHover ? workspacesData["ws" + (index + 6)]?.class || "empty" : "invisible"
                                    icon: workspacesData["ws" + (index + 6)]?.icon || ""

                                    onClicked: {
                                        changeWorkspace(wsId)
                                    }
                                }
                            }
                        }
                        HoverHandler {
                            onHoveredChanged: wsHover = hovered
                        }
                    }
                }

                // Camera
                Item {
                    id: cameraItem
                    width: cameraRow.width + 8
                    height: panel.height - 12
                    visible: wm_type == "coordinates"
                    
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

                    Text {
                        id: cameraRow
                        anchors.centerIn: parent
                        text: "x: " + cameraData.x + " y: " + cameraData.y + " zoom: " + cameraData.zoom
                        color: col.font
                        font.family: fontFamily
                        font.pixelSize: fontSize
                    }
                }
                
                // Active Window
                Item {
                    width: awText.width + 12
                    height: panel.height - 12
                    visible: activeWindow !== ""
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: mainRad - 3
                        opacity: 0.65
                        color: col.backgroundAlt1
                    }
                    
                    Text {
                        id: awText
                        anchors.centerIn: parent
                        text: activeWindow
                        color: col.font
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            // center section
            Row {
                anchors.centerIn: parent
                spacing: 3

                //weather
                Item {
                    id: weatherItem
                    property bool hovered: false
                    width: weatherRow.width + 12
                    height: panel.height - 12

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
                        id: weatherBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: weatherItem.hovered ? col.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    Row {
                        id: weatherRow
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            id: weatherIcon
                            text: vars.wthr.icon
                            color: weatherItem.hovered ? col.fontDark : col.font
                            font.family: fontFamily
                            font.weight: Font.bold
                            font.pixelSize: fontSize
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: weatherText
                            text: vars.wthr.temp + "°C"
                            color: weatherItem.hovered ? col.fontDark : col.font
                            font.family: fontFamily
                            font.weight: Font.bold
                            font.pixelSize: fontSize
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/popup.sh wthr"])
                        }

                        onEntered: weatherItem.hovered = true
                        onExited: weatherItem.hovered = false
                    }
                }
                
                // Time
                Item {
                    id: timeItem
                    property bool hovered: false
                    property bool dateInfo: false
                    width: timeRow.width + 12
                    height: panel.height - 12

                    SystemClock {
                      id: clock
                      precision: SystemClock.Seconds
                    }

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
                        id: timeBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: timeItem.hovered ? col.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: timeRow
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            id: timeIcon
                            text: timeItem.dateInfo ? "" : "󱑎"
                            color: timeItem.hovered ? col.fontDark : col.accent
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        Text {
                            id: timeText
                            color: timeItem.hovered ? col.fontDark : col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            text: timeItem.dateInfo ? Qt.formatDateTime(clock.date, "yyyy-MM-dd") : Qt.formatDateTime(clock.date, "hh:mm:ss")
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                   
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.AllButtons

                        onEntered: timeItem.hovered = true
                        onExited: timeItem.hovered = false
                        
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.LeftButton) {
                                timeItem.dateInfo = !timeItem.dateInfo
                            }
                            if (mouse.button === Qt.RightButton) {
                                calOpen = !calOpen
                                Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/cal reset"])
                            }
                        }
                    }
                }
            }
                
            // Right section
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                // cava
                Item {
                    width: cavaText.width + 4
                    height: panel.height - 12
                    visible: panel.width >= 2560

                    JsonListen {
                        id: cavaStream
                        command: "~/.config/quickshell/scripts/Cava-internal"
                        onDataChanged: {
                            cava = typeof data === 'string' ? data : ""
                        }
                    }
                    
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
                    ClippingRectangle {
                        anchors.fill: parent
                        radius: mainRad - 5
                        anchors.margins: 2
                        color: "transparent"
                        Text {
                            id: cavaText
                            text: cava
                            color: col.font
                            anchors.centerIn: parent
                            font.family: fontFamily
                            font.pixelSize: fontSize + ((fontSize % 2 === 0) ? 3 : 4)
                        }
                    }
                }

                // player
                Item {
                    id: playerItem
                    property bool hovered: false
                    width: plrRow.width + 12
                    height: panel.height - 12
                 
                    ClippingRectangle {
                        anchors.fill: parent
                        radius: mainRad - 3
                        opacity: 0.65
                        
                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: vars.plr.art !== "" ? "file://" + vars.plr.art + "?v=" + vars.plr.ver : ""
                        }
                    }
                    
                    Rectangle {
                        id: plrBg
                        anchors.fill: parent
                        radius: mainRad - 5
                        anchors.margins: 2
                        opacity: 0.65
                        color: playerItem.hovered ? col.accent : col.backgroundAlt1
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Item {
                        id: plrRow
                        anchors.centerIn: parent
                        opacity: 0.55
                        height: fontSize
                        clip: true
                        width: plrText1.implicitWidth + sep1.implicitWidth + plrText2.implicitWidth + sep2.implicitWidth + titleLoader.width

                        Text {
                            id: plrText1
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: vars.plr.status
                            color: playerItem.hovered ? col.fontDark : col.accent
                            font.family: "Eurostile Extended"
                            font.pixelSize: fontSize - 2
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            id: sep1
                            anchors.left: plrText1.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: ' '
                            font.family: "Eurostile Extended"
                            font.pixelSize: fontSize
                            color: playerItem.hovered ? col.fontDark : col.font
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            id: plrText2
                            anchors.left: sep1.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: vars.plr.artist.length > 15 ? vars.plr.artist.substring(0, 15) + "…" : vars.plr.artist
                            color: playerItem.hovered ? col.fontDark : col.font
                            font.family: "Eurostile Extended"
                            font.pixelSize: fontSize
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            id: sep2
                            anchors.left: plrText2.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: '      '
                            font.family: "Eurostile Extended"
                            font.pixelSize: fontSize
                            color: playerItem.hovered ? col.fontDark : col.font
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Loader {
                            id: titleLoader
                            anchors.left: sep2.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height
                            width: vars.plr.title.length > (panel.width >= 2560 ? 35 : 25)
                                   ? (panel.width >= 2560 ? 380 : 220)
                                   : (item ? item.implicitWidth : 0)

                            sourceComponent: vars.plr.title.length > 35 ? marqueeComp : textComp

                            Component {
                                id: textComp
                                Text {
                                    id: plrText3
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: vars.plr.title
                                    color: playerItem.hovered ? col.fontDark : col.font
                                    font.family: "Eurostile Extended"
                                    font.pixelSize: fontSize
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }

                            Component {
                                id: marqueeComp
                                MarqueeText {
                                    id: plrMar3
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 380
                                    height: parent.height
                                    text: vars.plr.title
                                    color: playerItem.hovered ? col.fontDark : col.font
                                    font.family: "Eurostile Extended"
                                    font.pixelSize: fontSize
                                }
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.AllButtons

                        onEntered: playerItem.hovered = true
                        onExited: playerItem.hovered = false
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.LeftButton) {
                                Quickshell.execDetached(["sh", "-c", "playerctl play-pause"])
                            }
                            if (mouse.button === Qt.RightButton) {
                                playerOpen = !playerOpen
                            }
                        }
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y > 0) {
                                Quickshell.execDetached(["sh", "-c", "playerctl next"])
                            } else if (wheel.angleDelta.y < 0) {
                                Quickshell.execDetached(["sh", "-c", "playerctl previous"])
                            }
                        }
                    }
                }

                // settings (audio, network, bluetooth)
                Item {
                    id: settingsItem
                    property bool hovered: false
                    width: audioButton.width + networkButton.width + bluetoothButton.width + settingsIcon.width
                    height: panel.height - 12

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
                        anchors.fill: parent
                        spacing: 2
                        anchors.margins: 2
                        Rectangle {
                            id: audioButton
                            color: audioButton.hovered ? col.accent : "transparent" 
                            implicitWidth: settingsItem.hovered ? audioText.width + 12 : 0
                            radius: mainRad - 5
                            implicitHeight: parent.height
                            opacity: settingsItem.hovered ? 1 : 0
                            clip: true
                            
                            property bool hovered: false
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on implicitWidth { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Text {
                                text: "󰗅"
                                anchors.centerIn: parent
                                id: audioText
                                color: audioButton.hovered ? col.fontDark : col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                font.weight: Font.bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: audioButton.hovered = true
                                onExited: audioButton.hovered = false
                                // Но здесь тоже нужно убрать присвоение цвета тексту,
                                // текст уже привязан к settingsItem.hovered
                                onClicked: {
                                    Quickshell.execDetached(["sh", "-c", "pavucontrol"])
                                }
                            }
                        }
                        
                        Rectangle {
                            id: networkButton
                            color: networkButton.hovered ? col.accent : "transparent"
                            implicitWidth: settingsItem.hovered ? networkText.width + 12 : 0
                            radius: mainRad - 5
                            implicitHeight: parent.height
                            opacity: settingsItem.hovered ? 1 : 0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on implicitWidth { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            property bool hovered: false

                            Text {
                                text: "󰈀"
                                anchors.centerIn: parent
                                id: networkText
                                color: networkButton.hovered ? col.fontDark : col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                font.weight: Font.bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: networkButton.hovered = true
                                onExited: networkButton.hovered = false

                                onClicked: {
                                    Quickshell.execDetached(["sh", "-c", "foot ~/.config/quickshell/scripts/recolor.sh"])
                                }
                            }
                        }

                        Rectangle {
                            id: bluetoothButton
                            color: bluetoothButton.hovered ? col.accent : "transparent"
                            implicitWidth: settingsItem.hovered ? bluetoothText.width + 12 : 0
                            radius: mainRad - 5
                            implicitHeight: parent.height
                            opacity: settingsItem.hovered ? 1 : 0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on implicitWidth { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            property bool hovered: false

                            Text {
                                text: "󰂯"
                                anchors.centerIn: parent
                                id: bluetoothText
                                color: bluetoothButton.hovered ? col.fontDark : col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize
                                font.weight: Font.bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: bluetoothButton.hovered = true
                                onExited: bluetoothButton.hovered = false

                                onClicked: {
                                    Quickshell.execDetached(["sh", "-c", "blueman-manager"])
                                }
                            }
                        }
                    }
                    Text {
                        id: settingsIcon
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "  "
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        font.weight: Font.bold
                        color: col.font
                    }
                    HoverHandler {
                        onHoveredChanged: settingsItem.hovered = hovered
                    } 
                }

                // volume
                Item {
                    width: volText.width + 12
                    height: panel.height - 12

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
                        id: volText
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Text {
                            text: vars.vol.sign
                            color: col.accent
                            font.family: "Mononoki Nerd font Propo"
                            font.pixelSize: fontSize
                        }

                        Text {
                            text: vars.vol.vol + "%"
                            color: col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            font.weight: Font.bold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.AllButtons

                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y > 0) {
                                Quickshell.execDetached(["sh", "-c", "pamixer -i 5"])
                            } else if (wheel.angleDelta.y < 0) {
                                Quickshell.execDetached(["sh", "-c", "pamixer -d 5"])
                            }
                        }
                    }
                }
                
                // Keyboard Layout
                Item {
                    width: kbRow.width + 12
                    height: panel.height - 12
                   
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
                        id: kbRow
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "󰌏"
                            color: col.accent
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: kbLayout
                            color: col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                // Power
                Item {
                    id: powerItem
                    property bool hovered: false
                    width: powerText.width + 12
                    height: panel.height - 12
                    
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
                        id: powerBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: powerItem.hovered ? col.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Text {
                        id: powerText
                        anchors.centerIn: parent
                        text: vars.bat.name == "null" ? "" : ( panel.width >= 2560 ? vars.bat.name + "  " + vars.bat.charge + "% " + vars.bat.icon : vars.bat.charge + "% " + vars.bat.icon )
                        color: powerItem.hovered ? col.fontDark : col.font
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: powerItem.hovered = true
                        onExited: powerItem.hovered = false
                        onClicked: powerOpen = !powerOpen
                    }
                }
            }
        }
    }
}
