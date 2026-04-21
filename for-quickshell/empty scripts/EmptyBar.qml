import Quickshell
import "components"
import "../helpers"

BaseBar {
    JsonListen {
        id: workspacesStream
        command: "~/.config/quickshell/scripts/<your_script> stream-ws-json"
        debug: false
        
        onDataChanged: {
            workspacesData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: "~/.config/quickshell/scripts/<your_script>"
        debug: false       
        onDataChanged: {
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: "~/.config/quickshell/scripts/<your_script>"
        debug: false
        
        onDataChanged: {
            kbLayout = typeof data === 'string' ? data : ""
        }
    }
    
    function changeWorkspace(id) {
        Quickshell.execDetached(["<your_wm>", "<workspace>", "<change>", id.toString()])
    }
}
