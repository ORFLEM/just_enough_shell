import Quickshell
import JES.Helpers

BaseBar {
    // клик по кнопке воркспейса в баре
    function changeWorkspace(id) {
        Quickshell.execDetached(["zwwmctl", "dispatch", "tag", id.toString()])
    }

    JsonListen {
        id: wsStream
        command: localPath(Qt.resolvedUrl("../scripts/workspace-zwwm.sh stream-json"))
        debug: false
        onDataChanged: {
            workspacesData = data
        }
    }
    JsonListen {
        id: cameraStream
        command: localPath(Qt.resolvedUrl("../scripts/camera-zwwm.sh stream-json"))
        debug: false
        onDataChanged: {
            cameraData = data
        }
    }
    JsonListen {
        id: activeWindowStream
        command: localPath(Qt.resolvedUrl("../scripts/active_window-zwwm.sh stream-window"))
        debug: false
        onDataChanged: {
            activeWindow = data
        }
    }
    JsonListen {
        id: kbLayoutStream
        command: localPath(Qt.resolvedUrl("../scripts/kb_layout-zwwm.sh stream-layout"))
        debug: false
        onDataChanged: {
            kbLayout = data
        }
    }
}
