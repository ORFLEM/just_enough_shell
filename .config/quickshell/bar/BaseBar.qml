import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import "components"
import "../helpers"
import "../"

WlrLayershell {
    id: panel
    layer: WlrLayer.Top
    namespace: "bar"
    
    property var workspacesData: ({})
    property bool wsHover: false
    property bool sttngsHover: false
    property string activeWindow: ""
    property string kbLayout: ""
    property string wm: ""
    property string cava: ""
    property string timed: ""
 
    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: 36
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 6
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
                    width: launcherContent.width + 4
                    height: 24
                    
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
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: launcherContent
                        anchors.centerIn: parent

                        ClippingRectangle {
                            radius: mainRad - 5
                            height: parent.height
                            width: height
                            color: "transparent"
                            Image {
                                sourceSize.width: 40
                                sourceSize.height: 40
                                id: launcherIcon
                                source: "file:///var/lib/AccountsService/icons/" + Quickshell.env("USER")
                                height: parent.height
                                width: height

                            }
                        }
                        Rectangle {
                            width: launchertext.width + 8
                            height: 20
                            color: "transparent"
                            Text {
                                id: launchertext
                                anchors.centerIn: parent
                                text: Quickshell.env("USER")
                                color: col.accent
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 17
                                font.weight: Font.Bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            launcherBg.color = col.accent
                            launchertext.color = col.fontDark
                        }
                        onExited: {
                            launcherBg.color = "transparent"
                            launchertext.color = col.accent
                        }
                        onClicked: {
                            launchOpen = !launchOpen
                        }
                    }
                }

                // wallpaper picker
                Item {
                    width: wallRow.width + 12
                    height: 24
                    
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
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: wallRow
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Text {
                            id: wallText
                            text: ""
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            wallBg.color = col.accent
                            wallText.color = col.fontDark
                        }
                        onExited: {
                            wallBg.color = "transparent"
                            wallText.color = col.font
                        }
                        onClicked: {
                            wallPickerOpen = !wallPickerOpen
                        }
                    }
                }
                
                // Workspaces - переопределяется в наследниках
                Item {
                    id: workspacesContainer
                    width: workspacesRow.width + 4
                    height: 24
                    
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
                
                
                // Active Window
                Item {
                    width: awText.width + 12
                    height: 24
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
                        font.family: "Mononoki Nerd Font Propo"
                        font.pixelSize: 17
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
                    id: weather
                    width: weatherRow.width + 12
                    height: 24

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
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    Row {
                        id: weatherRow
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            id: weatherIcon
                            text: vars.wthr.icon
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.weight: Font.bold
                            font.pixelSize: 17
                        Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: weatherText
                            text: vars.wthr.temp + "°C"
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.weight: Font.bold
                            font.pixelSize: 17
                        Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/popup.sh wthr"])
                        }

                        onEntered: {
                            weatherBg.color = col.accent
                            weatherIcon.color = col.fontDark
                            weatherText.color = col.fontDark
                        }

                        onExited: {
                            weatherBg.color = "transparent"
                            weatherIcon.color = col.font
                            weatherText.color = col.font
                        }
                    }
                }
                
                // Time
                Item {
                    id: time
                    width: timeRow.width + 12
                    height: 24

                    JsonListen {
                        command: "~/.config/quickshell/scripts/timed show"
                        onDataChanged: {
                            timed = typeof data === 'string' ? data : ""
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
                    
                    Rectangle {
                        id: timeBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: timeRow
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            id: timeIcon
                            text: "󱑎"
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            id: timeText
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            text: timed
                        }
                    }
                   
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.AllButtons

                        onEntered: {
                            timeBg.color = col.accent
                            timeIcon.color = col.fontDark
                            timeText.color = col.fontDark
                        }
                            
                        onExited: {
                            timeBg.color = "transparent"
                            timeIcon.color = col.accent
                            timeText.color = col.font                            
                        }
                        
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.LeftButton) {
                                Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/timed t-d"])
                            }
                            if (mouse.button === Qt.RightButton) {
                                Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/popup.sh cal"])
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
                    height: 24

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
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 19
                            font.weight: Font.Bold
                        }
                    }
                }

                // player
                Item {
                    width: plrRow.width + 12
                    height: 24
                 
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
                    
                    Rectangle{
                        id: plrBg
                        anchors.fill: parent
                        radius: mainRad - 5
                        anchors.margins: 2
                        opacity: 0.65
                        // gradient: Gradient {
                        //     orientation: Gradient.Horizontal
                        //     GradientStop { position: 0.0; color: col.backgroundAlt2 }
                        //     GradientStop { position: 0.275; color: col.backgroundAlt1 }
                        //     GradientStop { position: 0.725; color: col.backgroundAlt1 }
                        //     GradientStop { position: 1.0; color: col.backgroundAlt2 }
                        // }
                        color: col.backgroundAlt1
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Row {
                        id: plrRow
                        anchors.centerIn: parent
                        opacity: 0.55
                        
                        Text {
                            id: plrText1
                            text: vars.plr.status
                            color: col.accent
                            font.family: "Eurostile Extended"
                            font.pixelSize: 15
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        Text {
                            text: ' '
                        }
                        
                        Text {
                            id: plrText2
                            text: vars.plr.artist.length > 15 ? vars.plr.artist.substring(0, 15) + "…" : vars.plr.artist
                            color: col.font
                            font.family: "Eurostile Extended"
                            font.pixelSize: 15
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        Text {
                            text: '      '
                            font.family: "Eurostile Extended"
                        }
                        
                        Loader {
                                id: titleLoader
                                width: vars.plr.title.length > 35 ? 380 : item ? item.implicitWidth : 0
                                height: 20
                                
                                sourceComponent: vars.plr.title.length > 35 ? marqueeComp : textComp
                                
                                Component {
                                    id: textComp
                                    Text {
                                        id: plrText3
                                        text: vars.plr.title
                                        color: col.font
                                        font.family: "Eurostile Extended"
                                        font.pixelSize: 15
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }
                                
                                Component {
                                    id: marqueeComp
                                    MarqueeText {
                                        id: plrMar3
                                        width: 380
                                        text: vars.plr.title
                                        color: col.font
                                        font.family: "Eurostile Extended"
                                        font.pixelSize: 15
                                    }
                                }
                            }
                        }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.AllButtons

                        onEntered: {
                            plrBg.color = col.accent
                            plrText1.color = col.fontDark
                            plrText2.color = col.fontDark
                            if (titleLoader.item) titleLoader.item.color = col.fontDark
                        }
                        onExited: {
                            plrBg.color = col.backgroundAlt1
                            plrText1.color = col.accent
                            plrText2.color = col.font
                            if (titleLoader.item) titleLoader.item.color = col.font
                        }
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

                // settings
                Item {
                    width: audioButton.width + networkButton.width + bluetoothButton.width + settingsIcon.width
                    height: 24

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
                            color: "transparent"
                            implicitWidth: sttngsHover ? audioText.width + 12 : 0
                            radius: mainRad - 5
                            implicitHeight: parent.height
                            clip: true
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on implicitWidth { NumberAnimation { duration: 200 } }

                            Text {
                                text: "󰗅"
                                anchors.centerIn: parent
                                id: audioText
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 17
                                font.weight: Font.bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: {
                                    audioButton.color = col.accent
                                    audioText.color = col.fontDark
                                }
                                    
                                onExited: {
                                    audioButton.color = "transparent"
                                    audioText.color = col.font                            
                                }

                                onClicked: {
                                    Quickshell.execDetached(["sh", "-c", "pavucontrol"])
                                }
                            }
                        }
                        
                        Rectangle {
                            id: networkButton
                            color: "transparent"
                            implicitWidth: sttngsHover ? networkText.width + 12 : 0
                            radius: mainRad - 5
                            implicitHeight: parent.height
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on implicitWidth { NumberAnimation { duration: 200 } }

                            Text {
                                text: "󰈀"
                                anchors.centerIn: parent
                                id: networkText
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 17
                                font.weight: Font.bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: {
                                    networkButton.color = col.accent
                                    networkText.color = col.fontDark
                                }
                                    
                                onExited: {
                                    networkButton.color = "transparent"
                                    networkText.color = col.font                            
                                }

                                onClicked: {
                                    Quickshell.execDetached(["sh", "-c", "foot nmtui"])
                                }
                            }
                        }

                        Rectangle {
                            id: bluetoothButton
                            color: "transparent"
                            implicitWidth: sttngsHover ? bluetoothText.width + 12 : 0
                            radius: mainRad - 5
                            implicitHeight: parent.height
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on implicitWidth { NumberAnimation { duration: 200 } }

                            Text {
                                text: "󰂯"
                                anchors.centerIn: parent
                                id: bluetoothText
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 17
                                font.weight: Font.bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: {
                                    bluetoothButton.color = col.accent
                                    bluetoothText.color = col.fontDark
                                }
                                    
                                onExited: {
                                    bluetoothButton.color = "transparent"
                                    bluetoothText.color = col.font                            
                                }

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
                        font.family: "Mononoki Nerd Font Propo"
                        font.pixelSize: 17
                        font.weight: Font.bold
                        color: col.font
                    }
                    HoverHandler {
                        onHoveredChanged: sttngsHover = hovered
                    } 
                    
                }

                // volume
                Item {
                    width: volText.width + 12
                    height: 24

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
                            font.pixelSize: 17
                        }

                        Text {
                            text: vars.vol.vol + "%"
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
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
                    height: 24
                   
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
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: kbLayout
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                // Power
                Item {
                    width: powerText.width + 12
                    height: 24
                    
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
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    Text {
                        id: powerText
                        anchors.centerIn: parent
                        text: ""
                        color: col.font
                        font.family: "Mononoki Nerd Font Propo"
                        font.pixelSize: 17
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            powerBg.color = col.accent
                            powerText.color = col.fontDark
                        }
                        onExited: {
                            powerBg.color = "transparent"
                            powerText.color = col.font
                        }
                        onClicked: {
                            powerOpen = !powerOpen
                        }
                    }
                }
            }
        }
    }
}
