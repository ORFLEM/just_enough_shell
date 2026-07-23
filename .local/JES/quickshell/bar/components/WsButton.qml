import Quickshell
import QtQuick

Item {
    id: button
    
    property int wsId: 1
    property string wsState: "empty"  // active/occupied/empty/urgent
    property string icon: ""
    
    signal clicked()
    
    width: bg.width
    height: panel.height - 12
    
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
                case "active": return height * 2
                case "occupied": return height
                case "urgent": return height
                case "empty": return height
                case "invisible": return 0
                default: return height
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
                case "empty": return col.accent2
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
            font.family: fontFamily
            font.pixelSize: fontSize
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
