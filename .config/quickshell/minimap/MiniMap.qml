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

    property bool openMap: false

    anchors {
        bottom: true
        left: true
    }

    implicitHeight: openMap ? Screen.height - barHeight - 6 : 306
    implicitWidth: openMap ? Screen.width - 6 : 300 * Screen.width / Screen.height + 6
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

            // Локальные копии камеры (независимы от bar)
            property int localCameraX: barLoader.item?.cameraData?.x ?? 0
            property int localCameraY: barLoader.item?.cameraData?.y ?? 0
            property real localCameraZoom: barLoader.item?.cameraData?.zoom ?? 1.0

            // Дополнительный зум от колёсика
            property real resizeZoom: 0

            // Итоговый масштаб
            property real mapZoom: (localCameraZoom + resizeZoom) / 20.0

            property real centerX: width / 2
            property real centerY: height / 2

            // Флаг активности drag
            property bool dragActive: false

            // Обновляем локальные данные из бара, если не активен drag
            Connections {
                target: barLoader.item
                onCameraDataChanged: {
                    if (!windowsContainer.dragActive) {
                        windowsContainer.localCameraX = barLoader.item.cameraData.x
                        windowsContainer.localCameraY = barLoader.item.cameraData.y
                        windowsContainer.localCameraZoom = barLoader.item.cameraData.zoom
                    }
                }
            }

            // ---------- Модель окон ----------
            ListModel { id: windowModel }

            // ---------- Модель waypoints ----------
            ListModel { id: waypointModel }

            // ---------- Окна ----------
            Repeater {
                model: windowModel
                delegate: Rectangle {
                    property real centerX: (model.posX - windowsContainer.localCameraX) * windowsContainer.mapZoom + windowsContainer.centerX
                    property real centerY: (windowsContainer.localCameraY - model.posY) * windowsContainer.mapZoom + windowsContainer.centerY
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

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Quickshell.execDetached(["driftwm", "msg", "camera", model.posX, model.posY])
                            // Сброс зума при клике на окно (опционально)
                            // windowsContainer.resizeZoom = 0
                        }
                    }
                }
            }

            // ---------- Точки waypoints ----------
            Repeater {
                model: waypointModel
                delegate: Rectangle {
                    property real px: (model.x - windowsContainer.localCameraX) * windowsContainer.mapZoom + windowsContainer.centerX
                    property real py: (windowsContainer.localCameraY - model.y) * windowsContainer.mapZoom + windowsContainer.centerY

                    x: px - width/2
                    y: py - height/2
                    width: waypointText.width + 8
                    height: waypointText.height + 4
                    radius: mainRad * windowsContainer.mapZoom * 10
                    color: col.backgroundAlt1
                    border.color: col.accent
                    border.width: 1

                    Text {
                        id: waypointText
                        anchors.centerIn: parent
                        text: model.label || ""
                        color: col.font
                        font.pixelSize: fontSize
                        font.family: fontFamily
                        visible: model.label ? true : false
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Quickshell.execDetached(["driftwm", "msg", "camera", model.x, model.y])
                        }
                    }
                }
            }

            // ---------- World Map overlay ----------
            
            Item {
                visible: openMap
                anchors.fill: parent

                Rectangle {
                    anchors.centerIn: parent
                    color: "transparent"
                    width: 10
                    height: width
                    border.width: 2
                    border.color: col.accent2
                }

                Item {
                    anchors.bottom: parent.bottom
                    width: textMap.width + 8
                    height: textMap.height + 4
                    Rectangle {
                        anchors.fill: parent
                        radius: mainRad - 3
                        opacity: 0.65
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: col.backgroundAlt2 }
                            GradientStop { position: 0.275; color: col.backgroundAlt1 }
                            GradientStop { position: 0.725; color: col.backgroundAlt1 }
                            GradientStop { position: 1.0; color: col.backgroundAlt2 }
                            
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        id: textMap
                        font.pixelSize: fontSize
                        font.family: fontFamily
                        color: col.font
                        text: "x: " + windowsContainer.localCameraX + " y: " + windowsContainer.localCameraY + " zoom: " + windowsContainer.mapZoom
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

            // ---------- Источник waypoints ----------
            FileView {
                id: waypointFile
                path: Qt.resolvedUrl("./waypoints.json")
                watchChanges: true

                onFileChanged: reload()

                onTextChanged: {
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
                        }
                    } catch (e) {
                        console.warn("Ошибка парсинга waypoints.json:", e)
                    }
                }
            }

            // ---------- Drag для правой кнопки ----------
            MouseArea {
                id: dragArea
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                hoverEnabled: false

                property int startX: 0
                property int startY: 0
                property int origX: 0
                property int origY: 0

                onPressed: {
                    startX = mouse.x
                    startY = mouse.y
                    origX = windowsContainer.localCameraX
                    origY = windowsContainer.localCameraY
                    windowsContainer.dragActive = true
                }

                onPositionChanged: {
                    if (pressedButtons & Qt.RightButton) {
                        var dx = (mouse.x - startX) / windowsContainer.mapZoom
                        var dy = (mouse.y - startY) / windowsContainer.mapZoom
                        windowsContainer.localCameraX = origX - dx
                        windowsContainer.localCameraY = origY + dy
                    }
                }

                onReleased: {
                    windowsContainer.dragActive = false
                }
            }
        }

        // ---------- Фоновая MouseArea для кликов левой кнопкой и колёсика ----------
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton | Qt.NoButton
            hoverEnabled: true

            onPressed: function(mouse) {
                if (mouse.button === Qt.MiddleButton) {
                    openMap = !openMap
                    windowsContainer.resizeZoom = 0
                    windowsContainer.localCameraX = barLoader.item?.cameraData?.x ?? 0
                    windowsContainer.localCameraY = barLoader.item?.cameraData?.y ?? 0
                    windowsContainer.localCameraZoom = barLoader.item?.cameraData?.zoom ?? 1.0
                }
            }

            onExited: {
                // Сброс зума и позиции
                windowsContainer.resizeZoom = 0
                windowsContainer.localCameraX = barLoader.item?.cameraData?.x ?? 0
                windowsContainer.localCameraY = barLoader.item?.cameraData?.y ?? 0
                windowsContainer.localCameraZoom = barLoader.item?.cameraData?.zoom ?? 1.0
            }

            onWheel: function(wheel) {
                if (wheel.angleDelta.y > 0) {
                    windowsContainer.resizeZoom = Math.min(windowsContainer.resizeZoom + 0.1, 10) // ограничим
                } else if (wheel.angleDelta.y < 0) {
                    windowsContainer.resizeZoom = Math.max(windowsContainer.resizeZoom - 0.1, -1) // ограничим
                }
            }
        }
    }
}
