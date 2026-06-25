import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
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

    // ---------- Фон ----------
    Rectangle {
        id: background
        anchors.fill: parent
        anchors.bottomMargin: 6
        anchors.leftMargin: 6
        color: "transparent"
        radius: mainRad

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

        // ---------- Контейнер для окон и waypoints ----------
        ClippingRectangle {
            id: windowsContainer
            anchors.fill: parent
            radius: mainRad - 3
            anchors.margins: 3
            color: "transparent"
            clip: true

            // Параметры камеры
            property real cameraX: bar.cameraData.x
            property real cameraY: bar.cameraData.y
            property real cameraZoom: bar.cameraData.zoom
            property real mapZoom: cameraZoom / 20.0
            property real centerX: width / 2
            property real centerY: height / 2

            // ---------- Модель окон ----------
            ListModel { id: windowModel }

            // ---------- Модель waypoints ----------
            ListModel { id: waypointModel }

            // ---------- Окна ----------
            Repeater {
                model: windowModel
                delegate: Rectangle {
                    property real centerX: (model.posX - windowsContainer.cameraX) * windowsContainer.mapZoom + windowsContainer.centerX
                    property real centerY: (windowsContainer.cameraY - model.posY) * windowsContainer.mapZoom + windowsContainer.centerY
                    property real relW: model.width * windowsContainer.mapZoom
                    property real relH: model.height * windowsContainer.mapZoom
                    
                    x: centerX - relW / 2
                    y: centerY - relH / 2
                    width: Math.max(relW, 5)
                    height: Math.max(relH, 5)
                    radius: mainRad * windowsContainer.mapZoom * 10
                    color: model.is_focused ? col.background1 : col.backgroundAlt1
                    opacity: 0.65
                    border.color: model.is_focused ? col.accent : "transparent"
                    border.width: model.is_focused ? 2 : 0

                    IconImage {
                        x: 2
                        y: 2
                        width: Math.min(64 * windowsContainer.mapZoom * 10, parent.width - 4)
                        height: Math.min(64 * windowsContainer.mapZoom * 10, parent.height - 4)
                        source: Quickshell.iconPath(model.app_id ?? "", true)
                        smooth: true
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                    // Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                    // Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.Linear } }


                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Quickshell.execDetached(["driftwm", "msg", "camera", model.posX, model.posY])
                        }
                    }
                }
            }

            // ---------- Точки waypoints ----------
            Repeater {
                model: waypointModel
                delegate: Rectangle {
                    property real px: (model.x - windowsContainer.cameraX) * windowsContainer.mapZoom + windowsContainer.centerX
                    property real py: (windowsContainer.cameraY - model.y) * windowsContainer.mapZoom + windowsContainer.centerY

                    x: px - width/2
                    y: py - height/2
                    width: waypointText.width + 8
                    height: waypointText.height + 4
                    radius: mainRad * windowsContainer.mapZoom * 10
                    color: col.backgroundAlt1
                    border.color: col.accent
                    border.width: 1
                    // Подпись (если есть label)
                    Text {
                        id: waypointText
                        anchors.centerIn: parent
                        text: model.label || ""
                        color: col.font
                        font.pixelSize: fontSize
                        font.family: fontFamily
                        visible: model.label ? true : false
                    }

                    // Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                    // Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.Linear } }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // При клике на waypoint перемещаем камеру
                            Quickshell.execDetached(["driftwm", "msg", "camera", model.x, model.y])
                        }
                    }
                }
            }

            // ---------- Источник окон (JsonListen) ----------
            JsonListen {
                id: minimapJson
                command: "~/.config/quickshell/scripts/minimap-driftwm.sh stream-json"
                onDataChanged: {
                    if (typeof data === 'object' && data !== null) {
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
                            }
                        }
                    }
                }
            }

            // ---------- Источник waypoints (TextFile) ----------
            FileView {
                id: waypointFile
                path: Qt.resolvedUrl("./waypoints.json")
                watchChanges: true

                onFileChanged: reload()
                
                onTextChanged: {
                    // text – это функция, вызываем её
                    var content = text()
                    if (!content || content.trim() === "") {
                        waypointModel.clear()
                        return
                    }
                    try {
                        var data = JSON.parse(content)
                        if (Array.isArray(data)) {
                            waypointModel.clear()
                            for (var i = 0; i < data.length; i++) {
                                waypointModel.append({
                                    x: data[i].x || 0,
                                    y: data[i].y || 0,
                                    label: data[i].label || ""
                                })
                            }
                            // Если есть Canvas для линий – перерисовать
                            // if (typeof waypointLines !== 'undefined') waypointLines.requestPaint()
                        }
                    } catch (e) {
                        console.warn("Ошибка парсинга waypoints.json:", e)
                    }
                }
            }
        }
    }
}
