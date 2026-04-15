import Quickshell
import "components"
import "../helpers"

BaseBar {
    
    JsonListen {
        id: workspacesStream
        command: "~/.config/quickshell/scripts/workspace-niri.sh stream-ws-json"
        debug: true
        
        onDataChanged: {
            console.log("[NiriBar] ==================")
            console.log("[NiriBar] Workspaces updated!")
            console.log("[NiriBar] Type:", typeof data)
            console.log("[NiriBar] Data:", JSON.stringify(data))
            if (data.ws1) console.log("[NiriBar] ws1.class:", data.ws1.class)
            if (data.ws2) console.log("[NiriBar] ws2.class:", data.ws2.class)
            console.log("[NiriBar] ==================")
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: "~/.config/quickshell/scripts/active_window-niri.sh"
        debug: true       
        onDataChanged: {
            console.log("[NiriBar] Active window:", data)
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: "~/.config/quickshell/scripts/kb_layout-niri.sh"
        debug: true
        
        onDataChanged: {
            console.log("[NiriBar] KB Layout:", data)
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    function changeWorkspace(id) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", id.toString()])
    }    
}
