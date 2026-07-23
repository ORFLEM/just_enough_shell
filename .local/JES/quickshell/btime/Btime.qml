import Quickshell
import Quickshell.Wayland
import QtQuick
import "../"

WlrLayershell {
    id: btime
    layer: WlrLayer.Bottom
    namespace: "time"
    implicitWidth: 12 + textWeekday.width
    implicitHeight: 120
    color: "transparent"
    exclusiveZone: minibar && Screen.width >= 3440 ? -1 : 0
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]
    mask: Region { }
    anchors {
        bottom: true
        right: true
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    property string day: Qt.formatDate(clock.date, "dd-MM-yy")
    property string weekday: Qt.formatDate(clock.date, "dddd")

    Rectangle {
        color: "transparent"
        anchors {
            fill: parent
            bottomMargin: 15
            rightMargin: 15
            right: parent.right
        }
        Column {
            spacing: 3
            anchors.right: parent.right
            Text {
                horizontalAlignment: Text.AlignRight
                width: textWeekday.width
                text: day
                color: col.accent
                font.pixelSize: 35
                font.family: "FauxHanamin"
                font.weight: Font.Black
                opacity: 0.45
            }
            
            Text {
                horizontalAlignment: Text.AlignRight
                anchors.topMargin: 38
                id: textWeekday
                text: weekday
                color: col.accent
                font.pixelSize: 70
                font.family: "FauxHanamin"
                font.weight: Font.Black
                opacity: 0.6
            }
        }
    }
}


// ono prosto krasivoe, no po faktu eto sami bespolezni widjet v JES
