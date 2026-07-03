import Quickshell
import QtQuick
import QtQuick.Controls
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
    property bool showAddPopup: false
    property bool showDeletePopup: false
    
    keyboardFocus: openMap ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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
                    radius: Math.min(mainRad * windowsContainer.mapZoom * 10, 10)
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

                // Список waypoints (справа)
                ClippingRectangle {
                    width: 200
                    radius: mainRad - 3
                    color: "transparent"
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        bottomMargin: btnAdd.height + 3
                    }
                    ListView {
                        anchors.fill: parent
                        spacing: 3
                        clip: true
                        model: waypointModel
                        delegate: Rectangle {
                            id: waypointbtn
                            property bool hovered: false
                            width: parent.width
                            height: waypointbtnText.implicitHeight + 4
                            radius: mainRad - 3
                            color: "transparent"

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

                            Rectangle {
                                id: waypointbtnBg
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: mainRad - 5
                                color: waypointbtn.hovered ? col.accent : "transparent"
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            Text {
                                id: waypointbtnText
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: model.label || ""
                                color: waypointbtn.hovered ? col.fontDark : col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                elide: Text.ElideRight
                                clip: true
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: waypointbtn.hovered = true
                                onExited: waypointbtn.hovered = false
                                onClicked: {
                                    Quickshell.execDetached(["driftwm", "msg", "camera", model.x, model.y])
                                }
                            }
                        }
                    }
                }

                // Кнопки управления внизу справа
                Row {
                    spacing: 3
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right

                    // Кнопка "add waypoints"
                    Item {
                        id: btnAdd
                        property bool hovered: false
                        width: btnAddText.width + 8
                        height: btnAddText.height + 4
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
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: btnAdd.hovered ? col.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: btnAddText
                            anchors.centerIn: parent
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: btnAdd.hovered ? col.fontDark : col.font
                            text: "add waypoints"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: btnAdd.hovered = true
                            onExited: btnAdd.hovered = false
                            onClicked: {
                                showAddPopup = !showAddPopup
                            }
                        }
                    }

                    // Кнопка "delete waypoints"
                    Item {
                        id: btnDelete
                        property bool hovered: false
                        width: btnDeleteText.width + 8
                        height: btnDeleteText.height + 4
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
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: btnDelete.hovered ? col.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: btnDeleteText
                            anchors.centerIn: parent
                            font.pixelSize: fontSize
                            font.family: fontFamily
                            color: btnDelete.hovered ? col.fontDark : col.font
                            text: "delete waypoints"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: btnDelete.hovered = true
                            onExited: btnDelete.hovered = false
                            onClicked: {
                                showDeletePopup = !showDeletePopup
                            }
                        }
                    }
                }

                // ---------- POPUP ДЛЯ СОЗДАНИЯ ----------
                Rectangle {
                    id: addPopup
                    anchors.centerIn: parent
                    width: 300
                    height: 220
                    radius: mainRad
                    color: col.background1
                    border.color: col.accent
                    border.width: 2
                    visible: showAddPopup
                    z: 10
                
                    // Обработка Escape
                    Keys.onEscapePressed: {
                        showAddPopup = false
                        inputLabel.text = ""
                    }
                
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                
                        Text {
                            text: "new waypoint"
                            color: col.font
                            font.pixelSize: fontSize * 1.2
                            font.family: fontFamily
                        }
                
                        Row {
                            spacing: 10
                            Text {
                                text: "X:"
                                color: col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                            }
                            TextField {
                                id: inputX
                                width: 146
                                text: windowsContainer.localCameraX
                                color: col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                validator: IntValidator { bottom: -99999; top: 99999 }
                                background: Rectangle {
                                    color: col.backgroundAlt1
                                    radius: mainRad - 3
                                }
                                onTextChanged: {
                                    // можно добавить валидацию при вводе
                                }
                            }
                        }
                
                        Row {
                            spacing: 10
                            Text {
                                text: "Y:"
                                color: col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                            }
                            TextField {
                                id: inputY
                                width: 146
                                text: windowsContainer.localCameraY
                                color: col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                validator: IntValidator { bottom: -99999; top: 99999 }
                                background: Rectangle {
                                    color: col.backgroundAlt1
                                    radius: mainRad - 3
                                }
                            }
                        }
                
                        Row {
                            spacing: 10
                            Text {
                                text: "Label:"
                                color: col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                            }
                            TextField {
                                id: inputLabel
                                width: 108
                                text: ""
                                color: col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                background: Rectangle {
                                    color: col.backgroundAlt1
                                    radius: mainRad - 3
                                }
                            }
                        }
                
                        Row {
                            spacing: 20
                            // Кнопка OK
                            Item {
                                width: 60
                                height: 30
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: col.accent
                                    opacity: 0.8
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "OK"
                                    color: col.fontDark
                                    font.pixelSize: fontSize
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        var x = parseInt(inputX.text) || 0
                                        var y = parseInt(inputY.text) || 0
                                        var label = inputLabel.text.trim() || "point"
                                        label = label.replace(/"/g, '\\"')
                                        var cmd = `jq '. += [{"x": ${x}, "y": ${y}, "label": "${label}"}]' ~/.config/quickshell/minimap/waypoints.json > ~/.config/quickshell/minimap/tmp.json && mv ~/.config/quickshell/minimap/tmp.json ~/.config/quickshell/minimap/waypoints.json`
                                        Quickshell.execDetached(["sh", "-c", cmd])
                                        showAddPopup = false
                                        inputLabel.text = ""
                                    }
                                }
                            }
                            // Кнопка Cancel
                            Item {
                                width: 68
                                height: 30
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: col.backgroundAlt1
                                    opacity: 0.8
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    color: col.font
                                    font.pixelSize: fontSize
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        showAddPopup = false
                                        inputLabel.text = ""
                                    }
                                }
                            }
                        }
                    }
                }

                // ---------- POPUP ДЛЯ УДАЛЕНИЯ ----------
                Rectangle {
                    id: deletePopup
                    anchors.centerIn: parent
                    width: 320
                    height: 300
                    radius: mainRad
                    color: col.background1
                    border.color: col.accent
                    border.width: 2
                    visible: showDeletePopup
                    z: 10


                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Delete waypoint"
                            color: col.font
                            font.pixelSize: fontSize * 1.2
                            font.family: fontFamily
                        }

                        ClippingRectangle {
                            width: parent.width
                            height: parent.height - fontSize * 1.2 - 9 - fontSize
                            radius: mainRad - 3
                            color: "transparent"
                            
                            ListView {
                                id: deleteListView
                                width: parent.width
                                height: parent.height
                                spacing: 3
                                clip: true
                                model: waypointModel
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 32
                                    color: "transparent"
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

                                    Item {
                                        height: parent.height
                                        width: parent.width - 9 - delText.width 
                                        anchors.leftMargin: 3
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: model.label || "unnamed"
                                            color: col.font
                                            font.family: fontFamily
                                            font.pixelSize: fontSize
                                            width: parent.width
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    Item {
                                        id: btnDelete
                                        width: delText.width + 8
                                        height: parent.height - 6
                                        anchors.rightMargin: 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right
                                        property bool hovered: false
                                        
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: mainRad - 5
                                            color: btnDelete.hovered ? col.accent2 : col.accent
                                            opacity: 0.7
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                        }
                                        
                                        Text {
                                            id: delText
                                            anchors.centerIn: parent
                                            text: "delete"
                                            color: btnDelete.hovered ? col.font : col.fontDark
                                            font.family: fontFamily
                                            font.pixelSize: fontSize
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            
                                            onEntered: btnDelete.hovered = true
                                            onExited: btnDelete.hovered = false
                                            onClicked: {
                                                var idx = index
                                                var cmd = `jq 'del(.[${idx}])' ~/.config/quickshell/minimap/waypoints.json > ~/.config/quickshell/minimap/tmp.json && mv ~/.config/quickshell/minimap/tmp.json ~/.config/quickshell/minimap/waypoints.json`
                                                Quickshell.execDetached(["sh", "-c", cmd])
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            id: btnClose
                            width: 80
                            height: fontSize + 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            property bool hovered: false

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

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: mainRad - 5
                                color: btnClose.hovered ? col.accent : "transparent"
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Close"
                                color: btnClose.hovered ? col.fontDark : col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: btnClose.hovered = true
                                onExited: btnClose.hovered = false
                                onClicked: {
                                    showDeletePopup = false
                                }
                            }
                        }
                    }
                }
            } // конец Item World Map overlay

            // ---------- Источник окон ----------
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

        // ---------- Фоновая MouseArea для средней кнопки и колёсика ----------
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton
            hoverEnabled: false
            propagateComposedEvents: true

            onPressed: function(mouse) {
                if (mouse.button === Qt.MiddleButton) {
                    openMap = !openMap
                    windowsContainer.resizeZoom = 0
                    windowsContainer.localCameraX = barLoader.item?.cameraData?.x ?? 0
                    windowsContainer.localCameraY = barLoader.item?.cameraData?.y ?? 0
                    windowsContainer.localCameraZoom = barLoader.item?.cameraData?.zoom ?? 1.0
                }
            }

            onWheel: function(wheel) {
                if (wheel.modifiers && Qt.ControlModifier) {
                    // Ctrl+колесо — зум
                    if (wheel.angleDelta.y > 0)
                        windowsContainer.resizeZoom = Math.min(windowsContainer.resizeZoom + 0.1, 10)
                    else
                        windowsContainer.resizeZoom = Math.max(windowsContainer.resizeZoom - 0.1, -1)
                    wheel.accepted = true
                } else {
                    // Обычное колесо — пропускаем дальше (ListView сможет скроллить)
                    wheel.accepted = false
                }
            }
        }

        // ---------- HoverHandler для сброса при выходе ----------
        HoverHandler {
            id: backgroundHover
            onHoveredChanged: {
                if (!hovered && !showAddPopup && !showDeletePopup && !openMap) {
                    windowsContainer.resizeZoom = 0
                    windowsContainer.localCameraX = barLoader.item?.cameraData?.x ?? 0
                    windowsContainer.localCameraY = barLoader.item?.cameraData?.y ?? 0
                    windowsContainer.localCameraZoom = barLoader.item?.cameraData?.zoom ?? 1.0
                }
            }
        }
    }
}
