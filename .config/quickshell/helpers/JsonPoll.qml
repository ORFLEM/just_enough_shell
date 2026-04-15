import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root
    
    property string command: ""
    property var data: ({})
    property bool debug: false
    property int interval: 1000
    property bool running: true
    
    property Timer _timer: Timer {
        interval: root.interval
        running: root.running && root.command !== ""
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            if (root.command) {
                _process.running = true
            }
        }
    }
    
    property Process _process: Process {
        command: {
            if (!root.command) return []
            
            let cmd = root.command.replace("~", Quickshell.env("HOME"))
            
            if (root.debug) {
                console.log("[JsonPoll] Executing command:", cmd)
            }
            
            return ["bash", "-c", cmd]
        }
        
        running: false
        
        // ИСПРАВЛЕНО: StdioCollector вместо SplitParser!
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.debug) {
                    console.log("[JsonPoll] Raw output:", text)
                }
                
                let trimmed = text.trim()
                if (!trimmed) return
                
                // Пробуем парсить JSON
                if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
                    try {
                        root.data = JSON.parse(trimmed)
                        
                        if (root.debug) {
                            console.log("[JsonPoll] Parsed JSON successfully:", root.data)
                        }
                    } catch (e) {
                        console.error("[JsonPoll] Parse error:", e)
                        root.data = trimmed
                    }
                } else {
                    // Просто текст
                    root.data = trimmed
                    
                    if (root.debug) {
                        console.log("[JsonPoll] Plain text:", root.data)
                    }
                }
            }
        }
        
        stderr: SplitParser {
            onRead: errorData => {
                console.error("[JsonPoll] STDERR:", errorData)
            }
        }
        
        onExited: (code, status) => {
            if (code !== 0 && root.debug) {
                console.error("[JsonPoll] Process exited with code:", code)
            }
        }
    }
    
    function refresh() {
        if (root.command) {
            _process.running = true
        }
    }
}
