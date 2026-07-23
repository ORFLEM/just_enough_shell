import Quickshell
import "components"
import "../helpers"

BaseBar {
    
    JsonListen {
        id: workspacesStream
        command: localPath(Qt.resolvedUrl("./scripts/workspace-niri.sh stream-ws-json"))
        debug: true
        
        onDataChanged: {
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: localPath(Qt.resolvedUrl("./scripts/active_window-niri.sh"))
        debug: true       
        onDataChanged: {
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: localPath(Qt.resolvedUrl("./scripts/kb_layout-niri.sh"))
        debug: true
        
        onDataChanged: {
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    function changeWorkspace(id) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", id.toString()])
    }    
}
