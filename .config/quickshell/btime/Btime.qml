import Quickshell
import Quickshell.Wayland
import QtQuick
import "../"
import "components"

WlrLayershell {
    id: btime
    layer: WlrLayer.Bottom
    namespace: "time"
    implicitWidth: 12 + textWeekday.width
    implicitHeight: 120
    color: "transparent"
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
