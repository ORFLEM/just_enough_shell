import Quickshell
import "components"
import "../helpers"

BaseBar {
    JsonListen {
        id: workspacesStream
        command: "~/.config/quickshell/scripts/workspace-sway.sh stream-ws-json"
        debug: true
        
        onDataChanged: {
            console.log("[ZwmBar] ==================")
            console.log("[ZwmBar] Workspaces updated!")
            console.log("[ZwmBar] Type:", typeof data)
            console.log("[ZwmBar] Data:", JSON.stringify(data))
            if (data.ws1) console.log("[ZwmBar] ws1.class:", data.ws1.class)
            if (data.ws2) console.log("[ZwmBar] ws2.class:", data.ws2.class)
            console.log("[ZwmBar] ==================")
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: "~/.config/quickshell/scripts/active_window-sway.sh"
        debug: true       
        onDataChanged: {
            console.log("[ZwmBar] Active window:", data)
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: "~/.config/quickshell/scripts/kb_layout-sway.sh"
        debug: true
        
        onDataChanged: {
            console.log("[ZwmBar] KB Layout:", data)
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    
    function changeWorkspace(id) {
        console.log("[ZwmBar] Changing workspace to:", id)
        Quickshell.execDetached(["swaymsg", "workspace", "number", id.toString()])
    }
}
