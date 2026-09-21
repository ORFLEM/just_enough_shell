pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Единая точка запуска JsonListen-потоков.
// Ключ = нормализованная команда; на каждую уникальную команду — один Process,
// независимо от того, сколько JsonListen (в JES или в плагинах) её слушают.
QtObject {
    id: manager

    property var _streams: ({})

    function _normalize(cmd) {
        // Паритет со старым JsonListen: раскрываем ~ (первое вхождение)
        return cmd.replace("~", Quickshell.env("HOME"))
    }

    // Вернуть entry-объект с сигналом line(var value). Не null только при непустой команде.
    function acquire(command) {
        if (!command)
            return null
        const key = _normalize(command)
        let e = _streams[key]
        if (!e) {
            e = streamComponent.createObject(manager, { key: key })
            _streams[key] = e
        }
        e.refs++
        return e
    }

    function release(command) {
        if (!command)
            return
        const key = _normalize(command)
        const e = _streams[key]
        if (!e)
            return
        e.refs--
        if (e.refs <= 0) {
            delete _streams[key]
            e.destroy()   // уничтожение Process убивает дочерний процесс
        }
    }

    // Через property — QtObject не принимает голых дочерних объектов
    property Component streamComponent: Component {
        QtObject {
            id: stream
            property string key: ""
            property int refs: 0
            signal line(var value)

            property Process proc: Process {
                command: ["bash", "-c", stream.key]
                running: true

                stdout: SplitParser {
                    onRead: rawData => {
                        let trimmed = rawData.trim()
                        if (!trimmed)
                            return

                        let value
                        if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
                            try {
                                value = JSON.parse(trimmed)
                            } catch (e) {
                                // Паритет со старым JsonListen: не-JSON → сырой текст
                                value = trimmed
                            }
                        } else {
                            value = trimmed
                        }
                        stream.line(value)
                    }
                }

                stderr: SplitParser {
                    onRead: errorData =>
                        console.error("[StreamManager] STDERR:", stream.key, "->", errorData)
                }

                onExited: (code, status) => {
                    if (code !== 0)
                        console.error("[StreamManager] Process died! Code:", code, "Cmd:", stream.key)
                }
            }
        }
    }
}
