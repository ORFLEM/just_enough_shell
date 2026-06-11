import Quickshell
import "components"
import "../helpers"

BaseBar {
    JsonListen {
        id: cameraStream
        command: "~/.config/quickshell/scripts/camera-driftwm.sh stream-json"
        debug: false
        
        onDataChanged: {
            // console.log("[SwayBar] ==================")
            // console.log("[SwayBar] Workspaces updated!")
            // console.log("[SwayBar] Type:", typeof data)
            // console.log("[SwayBar] Data:", JSON.stringify(data))
            // if (data.ws1) console.log("[SwayBar] ws1.class:", data.ws1.class)
            // if (data.ws2) console.log("[SwayBar] ws2.class:", data.ws2.class)
            // console.log("[SwayBar] ==================")
            cameraData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: "~/.config/quickshell/scripts/active_window-driftwm.sh stream-window"
        debug: false       
        onDataChanged: {
            // console.log("[SwayBar] Active window:", data)
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: "~/.config/quickshell/scripts/kb_layout-driftwm.sh stream-layout"
        debug: false
        
        onDataChanged: {
            // console.log("[SwayBar] KB Layout:", data)
            kbLayout = typeof data === 'string' ? data : ""
        }
    }   
}
