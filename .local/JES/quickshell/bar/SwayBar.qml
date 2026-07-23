import Quickshell
import "components"
import "../helpers"

BaseBar {
    JsonListen {
        id: workspacesStream
        command: localPath(Qt.resolvedUrl("../scripts/workspace-sway.sh stream-ws-json"))
        debug: false
        
        onDataChanged: {
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: localPath(Qt.resolvedUrl("../scripts/active_window-sway.sh"))
        debug: false       
        onDataChanged: {
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: localPath(Qt.resolvedUrl("../scripts/kb_layout-sway.sh"))
        debug: false
        
        onDataChanged: {
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    
    function changeWorkspace(id) {
        Quickshell.execDetached(["swaymsg", "workspace", "number", id.toString()])
    }
}
