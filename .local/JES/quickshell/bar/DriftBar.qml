import Quickshell
import "components"
import "../helpers"

BaseBar {
    JsonListen {
        id: cameraStream
        command: localPath(Qt.resolvedUrl("../scripts/camera-driftwm.sh stream-json"))
        debug: false
        
        onDataChanged: {
            cameraData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: localPath(Qt.resolvedUrl("../scripts/active_window-driftwm.sh stream-window"))
        debug: false       
        onDataChanged: {
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: localPath(Qt.resolvedUrl("../scripts/kb_layout-driftwm.sh stream-layout"))
        debug: false
        
        onDataChanged: {
            kbLayout = typeof data === 'string' ? data : ""
        }
    }   
}
