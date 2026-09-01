import QtQuick
import "helpers"

Item {
    property var wthr: ({})
    property var plr: ({})
    property var vol: ({})
    property var cal: ({})
    property var bat: ({})
    property bool showConnect: false
    property string oldname: "null"

    JsonListen {
        command: localPath(Qt.resolvedUrl("scripts/vol.sh"))
        onDataChanged: {
            vol = data
        }
    }

    JsonListen {
        id: plrStream
        command: localPath(Qt.resolvedUrl("scripts/music"))
        onDataChanged: {
            plr = data
        }
    }

    JsonListen {
        id: calStream
        command: localPath(Qt.resolvedUrl("scripts/cal")) + " listen"
        onDataChanged: {
            cal = data
        }
    }

    JsonPoll {
        command: localPath(Qt.resolvedUrl("scripts/weather_wid.sh"))
        interval: 900000
        onDataChanged: {
            wthr = data
        }
    }

    JsonListen {
        command: localPath(Qt.resolvedUrl("scripts/phone.sh"))
        onDataChanged: {
            bat = data
            bat.name != oldname ? showConnect = true : showConnect = false
            oldname = bat.name
            connectTimer.restart()
        }
    }

    Timer {
        id: connectTimer
        interval: 2000
        onTriggered: vars.showConnect = false
    }
}
