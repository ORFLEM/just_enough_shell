import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root
    
    property string command: ""
    property var data: ({})
    property bool debug: false
    
    property Process _process: Process {
        command: {
            if (!root.command) return []
            
            // Раскрываем ~
            let cmd = root.command.replace("~", Quickshell.env("HOME"))
            
            if (root.debug) {
                console.log("[JsonListen] Starting command:", cmd)
            }
            
            return ["bash", "-c", cmd]
        }
        
        running: root.command !== ""
        
        stdout: SplitParser {
            onRead: rawData => {
                if (root.debug) {
                    console.log("[JsonListen] Raw data:", rawData)
                }
                
                let trimmed = rawData.trim()
                if (!trimmed) return
                
                // Пробуем парсить JSON
                if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
                    try {
                        root.data = JSON.parse(trimmed)
                        
                        if (root.debug) {
                            console.log("[JsonListen] Parsed JSON successfully")
                        }
                    } catch (e) {
                        console.error("[JsonListen] Parse error:", e)
                        root.data = trimmed
                    }
                } else {
                    // Просто текст
                    root.data = trimmed
                }
            }
        }
        
        stderr: SplitParser {
            onRead: errorData => {
                console.error("[JsonListen] STDERR:", errorData)
            }
        }
        
        onExited: (code, status) => {
            if (code !== 0) {
                console.error("[JsonListen] Process died! Code:", code)
            }
        }
    }
}
