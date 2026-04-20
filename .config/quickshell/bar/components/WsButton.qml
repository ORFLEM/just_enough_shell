import Quickshell
import QtQuick

Item {
    id: button
    
    property int wsId: 1
    property string wsState: "empty"  // active/occupied/empty/urgent
    property string icon: ""
    
    signal clicked()
    
    width: bg.width
    height: 24
    
    Rectangle {
        id: bg
        implicitWidth: getWidth()
        implicitHeight: parent.height - 4
        anchors.margins: 2
        anchors.centerIn: parent
        // radius: mainRad >= 8 ? 3 : 0
        color: getColor()
        
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCirc } }
        Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
                
        function getWidth() {
            switch(wsState) {
                case "active": return 40
                case "occupied": return 20
                case "urgent": return 20
                case "empty": return 20
                case "invisible": return 0
                default: return 20
            }
        }
        
        function getColor() {
            if (mouseArea.containsMouse) {
                return col.accent
            }
            
            switch(wsState) {
                case "active": return col.accent
                case "occupied": return col.font
                case "urgent": return base.base09
                case "empty": return base.base05
                default: return "transparent"
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: icon // || wsId
            color: {
                if (mouseArea.containsMouse) return col.fontDark
                
                switch(wsState) {
                    case "active": return col.fontDark
                    case "occupied": return col.backgroundAlt1
                    case "urgent": return base.base08
                    case "empty": return col.backgroundAlt1
                    default: return col.font
                }
            }
            font.family: "Mononoki Nerd Font Propo"
            font.pixelSize: 17
            font.weight: Font.Bold
            
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }
}
