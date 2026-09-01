import Quickshell
import QtQuick
import Quickshell.Io

    
// ===== Встроенный компонент About System =====
Item {
    id: aboutItem
    implicitWidth: infoColumn.implicitWidth
    implicitHeight: infoColumn.implicitHeight + logoText.height + root.spacing * 2

    Text {
        id: logoText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        font.family: fontFamily
        font.pixelSize: fontSize * 1.5
        color: col.font
        text: logoType == 1 ? "> Just Enough Shell  " : "> Just Enough Shell _"
    }

    Column {
        id: infoColumn
        // anchors.centerIn: parent
        anchors.bottom: parent.bottom
        spacing: root.spacing

        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "JES version:     rolling release" }
        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "JES api version: " + root.apiVersion }

        Rectangle { width: parent.width; height: 2; color: col.font; opacity: 0.15 }

        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "OS:      " + osText }
        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "Kernel:  " + kernelText }
        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "CPU:     " + cpuText }
        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "GPU:     " + gpuText }
        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "RAM:     " + ramText }
        Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "Disk:    " + diskText }

        Row {
            spacing: 8
            Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; text: "Pkgs:   " }
            Column {
                spacing: 4
                Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; visible: pkgsSystemText !== ""; text: "system: " + pkgsSystemText }
                Text { font.family: fontFamily; font.pixelSize: fontSize; color: col.font; visible: pkgsUserText !== ""; text: "user:   " + pkgsUserText }
            }
        }
    }
}
