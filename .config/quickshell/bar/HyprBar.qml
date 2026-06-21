import Quickshell
import "components"
import "../helpers"

BaseBar {
    
    JsonListen {
        id: workspacesStream
        command: "~/.config/quickshell/scripts/workspace-hypr.sh stream-ws-json"
        debug: false
        
        onDataChanged: {
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: "~/.config/quickshell/scripts/active_window-hypr.sh"
        debug: false       
        onDataChanged: {
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: "~/.config/quickshell/scripts/kb_layout-hypr.sh"
        debug: false
        
        onDataChanged: {
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    
    function changeWorkspace(id) {
        console.log("[HyprBar] Changing workspace to:", id)
        Quickshell.execDetached(["hyprctl", "changeworkspace", "number", id.toString()])
    }
}
