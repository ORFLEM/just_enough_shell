import Quickshell
import JES.Helpers
import JES.Bar

    BaseBar {
        JsonListen {
            id: cameraStream
            command: localPath(Qt.resolvedUrl("./workspace.sh stream-ws-json"))
            debug: false
            
            onDataChanged: {
                cameraData = data
            }
        }
        
        JsonListen {
            id: activeWindowStream
            command: localPath(Qt.resolvedUrl("./active_window.sh stream-window"))
            debug: false       
            onDataChanged: {
                activeWindow = typeof data === 'string' ? data : ""
            }
        }
        
        JsonListen {
            id: kbLayoutStream
            command: localPath(Qt.resolvedUrl("./kb_layout.sh stream-layout"))
            debug: false
            
            onDataChanged: {
                kbLayout = typeof data === 'string' ? data : ""
            }
        }   
    }
