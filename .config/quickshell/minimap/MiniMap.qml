import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Io
import "../helpers"

WlrLayershell {
    id: minimap
    layer: WlrLayer.Top
    namespace: "minimap"
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    anchors {
        bottom: true
        left: true
    }

    implicitHeight: 306
    implicitWidth: 300 * Screen.width / Screen.height + 6

    color: "transparent"

    // ---------- Фон с градиентом (как в BaseBar) ----------
    Rectangle {
        id: background
        anchors.fill: parent
        anchors.bottomMargin: 6
        anchors.leftMargin: 6
        color: "transparent"
        radius: mainRad   // глобальная переменная, определена в корневом QML

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: 0.85
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: col.background3 }
                GradientStop { position: 0.05; color: col.background2 }
                GradientStop { position: 0.3; color: col.background1 }
                GradientStop { position: 0.7; color: col.background1 }
                GradientStop { position: 0.95; color: col.background2 }
                GradientStop { position: 1.0; color: col.background3 }
            }
        }

        // ---------- Контейнер для окон ----------
        Rectangle {
            id: windowsContainer
            anchors.fill: parent
            radius: mainRad - 3
            anchors.margins: 3
            color: "transparent"
            clip: true

            // Параметры камеры
            property real cameraX: 0
            property real cameraY: 0
            property real cameraZoom: 1.0

            // Масштаб мини-карты – в 20 раза меньше камеры
            property real mapZoom: cameraZoom / 20.0

            // Центр области рисования
            property real centerX: width / 2
            property real centerY: height / 2

            ListModel { id: windowModel }

            Repeater {
                model: windowModel
                delegate: Rectangle {
                    // Центр окна на мини-карте
                    property real centerX: (model.posX - windowsContainer.cameraX) * windowsContainer.mapZoom + windowsContainer.centerX
                    property real centerY: (windowsContainer.cameraY - model.posY) * windowsContainer.mapZoom + windowsContainer.centerY
                    property real relW: model.width * windowsContainer.mapZoom
                    property real relH: model.height * windowsContainer.mapZoom
                    clip: true
            
                    x: centerX - relW / 2
                    y: centerY - relH / 2
                    width: Math.max(relW, 5)
                    height: Math.max(relH, 5)
                    radius: mainRad * windowsContainer.mapZoom * 10
                    color: model.is_focused ? "#555555" : col.backgroundAlt1
                    opacity: 0.65
                    border.color: model.is_focused ? "#FFFFFF" : "transparent"
                    border.width: model.is_focused ? 2 : 0
           
                    Behavior on color { ColorAnimation { duration: 100 }}
                }
            }

            // ---------- Получение данных через JsonListen ----------
            JsonListen {
                id: minimapJson
                command: "~/.config/quickshell/scripts/minimap-driftwm.sh stream-json"
                // debug: true  // при необходимости можно включить

                onDataChanged: {
                    if (typeof data === 'object' && data !== null) {
                        // Обновляем камеру
                        if (data.camera) {
                            windowsContainer.cameraX = data.camera.x || 0
                            windowsContainer.cameraY = data.camera.y || 0
                            windowsContainer.cameraZoom = data.camera.zoom || 1.0
                        }

                        // Обновляем список окон
                        windowModel.clear()
                        if (data.windows && Array.isArray(data.windows)) {
                            for (var i = 0; i < data.windows.length; i++) {
                                var win = data.windows[i]
                                windowModel.append({
                                    posX: win.position[0],
                                    posY: win.position[1],
                                    width: win.size[0],
                                    height: win.size[1],
                                    app_id: win.app_id || "",
                                    title: win.title || "",
                                    is_focused: win.is_focused || false
                                })
                                    console.log(windowModel.height)
                            }
                        }
                    }
                }
            }

            // (Опционально) если процесс упал – JsonListen сам перезапустится,
            // так как его свойство running по умолчанию true, и он перезапускается при изменении command.
            // Можно добавить таймер для принудительного перезапуска, но обычно не требуется.
        }
    }
}
