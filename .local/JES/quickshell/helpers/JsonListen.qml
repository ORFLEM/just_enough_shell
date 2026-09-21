import Quickshell
import QtQuick

// API идентичен старому: command, data, debug.
// Внутри — подписка на общий поток StreamManager (дедупликация по команде).
QtObject {
    id: root

    property string command: ""
    property var data: ({})
    property bool debug: false

    property var _entry: null
    property string _boundCommand: ""

    function _resubscribe() {
        if (_boundCommand !== "") {
            StreamManager.release(_boundCommand)
            _entry = null
            _boundCommand = ""
        }
        if (command !== "") {
            _entry = StreamManager.acquire(command)
            _boundCommand = command
        }
    }

    onCommandChanged: _resubscribe()
    Component.onCompleted: _resubscribe()
    Component.onDestruction: {
        if (_boundCommand !== "")
            StreamManager.release(_boundCommand)
    }

    // Через property — QtObject не принимает голых дочерних объектов
    property Connections _conn: Connections {
        target: root._entry
        ignoreUnknownSignals: true

        function onLine(value) {
            root.data = value
            if (root.debug)
                console.log("[JsonListen]", root.command, "->", JSON.stringify(value))
        }
    }
}
