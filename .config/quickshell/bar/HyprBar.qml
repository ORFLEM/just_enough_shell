import Quickshell
import "components"
import "../helpers"

BaseBar {
    
    JsonListen {
        id: workspacesStream
        command: "~/.config/quickshell/scripts/workspace-hypr.sh stream-ws-json"
        debug: true
        
        onDataChanged: {
            console.log("[HyprBar] ==================")
            console.log("[HyprBar] Workspaces updated!")
            console.log("[HyprBar] Type:", typeof data)
            console.log("[HyprBar] Data:", JSON.stringify(data))
            if (data.ws1) console.log("[HyprBar] ws1.class:", data.ws1.class)
            if (data.ws2) console.log("[HyprBar] ws2.class:", data.ws2.class)
            console.log("[HyprBar] ==================")
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: "~/.config/quickshell/scripts/active_window-hypr.sh"
        debug: true       
        onDataChanged: {
            console.log("[HyprBar] Active window:", data)
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: "~/.config/quickshell/scripts/kb_layout-hypr.sh"
        debug: true
        
        onDataChanged: {
            console.log("[HyprBar] KB Layout:", data)
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    
    function changeWorkspace(id) {
        console.log("[HyprBar] Changing workspace to:", id)
        Quickshell.execDetached(["hyprctl", "changeworkspace", "number", id.toString()])
    }
}
