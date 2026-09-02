import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import JES.Helpers

Variants {
    model: Quickshell.screens

    WlrLayershell {
        id: osdLayer
        required property ShellScreen modelData
        layer: WlrLayer.Overlay
        namespace: "osd-popups"
        exclusiveZone: -1
        screen: modelData

        implicitWidth: 220
        implicitHeight: 120
        color: "transparent"
        anchors.bottom: true

        readonly property bool isFullscreen: {
            return ToplevelManager.toplevels.values.some(top => {
                if (!top.fullscreen) return false;
                if (top.screens && top.screens.values) {
                    return top.screens.values.includes(modelData);
                }
                return top.screen === modelData;
            });
        }

        margins.bottom: (!barOnTop && !modelData.isFullscreen) ? (barHeight + root.wtw) : root.wtw

        mask: Region {
            item: contentCol
        }

        // ----- Базовые встроенные OSD -----
        property var baseOsdModel: [
            {
                id: "volume",
                type: "percent",
                command: "../scripts/vol.sh"
            },
            {
                id: "brightness",
                type: "percent",
                command: "../scripts/brightness.sh stream"
            }
        ]

        // Итоговый плоский массив для Repeater
        property var osdModel: baseOsdModel

        // ----- Подгрузка плагинов из JSON API -----
        FileView {
            id: pluginLoader
            path: Quickshell.env("HOME") + "/.cache/JES/JES_osd_plugins.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: loadOsdPlugins(text())
        }

        function loadOsdPlugins(raw) {
            try {
                var data = raw.trim()
                if (data === "") return
                var pluginGroups = JSON.parse(data)
                if (!Array.isArray(pluginGroups)) return

                var extractedPlugins = []

                for (var i = 0; i < pluginGroups.length; i++) {
                    var group = pluginGroups[i]
                    var sourceDir = group.source || ""
                    var items = group.info || []

                    if (!Array.isArray(items)) items = [items]

                    for (var j = 0; j < items.length; j++) {
                        var item = items[j]
                        var cmd = item.command || ""
                        
                        if (cmd !== "" && !cmd.startsWith("/")) {
                            cmd = sourceDir + "/" + cmd
                        }

                        extractedPlugins.push({
                            id: item.id || ("plugin_" + i + "_" + j),
                            type: item.type || "text",
                            icon: item.icon || "",
                            command: cmd
                        })
                    }
                }

                osdModel = baseOsdModel.concat(extractedPlugins)
            } catch(e) {
                console.warn("Ошибка подгрузки OSD-плагинов:", e)
            }
        }

        Component.onCompleted: {
            pluginLoader.reload()
        }

        // ----- ВЕРСТКА -----
        Column {
            id: contentCol
            anchors.bottom: parent.bottom
            width: parent.width
            spacing: root.wtw

            // ИСКЛЮЧЕНИЕ: Изначальный модуль подключенных устройств
            Rectangle {
                id: connectBox
                width: parent.width
                height: vars.showConnect ? 16 : 0
                clip: true
                radius: 8
                color: "transparent"

                property string connectText: (vars.bat && vars.bat.name === "null") 
                                             ? "device was disconnected" 
                                             : "+ " + (vars.bat ? vars.bat.name : "")

                Behavior on height {
                    NumberAnimation {
                        duration: 200 * root.animations
                        easing.type: Easing.OutCubic
                    }
                }

                // Таймер скрытия подключений
                Timer {
                    id: connectTimer
                    interval: 1500
                    onTriggered: {
                        if (root.vars) {
                            root.vars.showConnect = false
                        }
                    }
                }

                // Метрика для расчёта ширины строки подключения
                TextMetrics {
                    id: connectMeasurer
                    font.family: "Mononoki Nerd Font Propo"
                    font.pixelSize: 14
                    text: connectBox.connectText
                }

                // Перезапуск таймера при появлении оверлея или изменении текста
                onConnectTextChanged: recalculateTimer()
                onHeightChanged: {
                    if (height > 0) recalculateTimer()
                }

                function recalculateTimer() {
                    if (!vars.showConnect) return

                    var availableWidth = osdLayer.implicitWidth - 10 // 210px (с учётом отступов 5px)
                    var textWidth = connectMeasurer.width

                    if (textWidth > availableWidth) {
                        var overflow = textWidth - availableWidth
                        var scrollDuration = (overflow / 40) * 1000
                        var totalDisplayTime = scrollDuration + 1600 + 2000

                        connectTimer.interval = Math.max(1500, totalDisplayTime)
                    } else {
                        connectTimer.interval = 1500
                    }

                    connectTimer.restart()
                }

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

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3

                    MarqueeText {
                        anchors.fill: parent
                        text: connectBox.connectText
                        color: col.accent
                        font.family: connectMeasurer.font.family
                        font.pixelSize: connectMeasurer.font.pixelSize
                    }
                }
            }

            // РЕНДЕР МОДЕЛЕЙ (Дефолт + Плагины из osdModel)
            Repeater {
                model: osdModel
                delegate: Loader {
                    width: parent.width
                    property var itemConfig: modelData

                    sourceComponent: {
                        if (modelData.type === "percent") return percentDelegate
                        if (modelData.type === "text") return textDelegate
                        return null
                    }
                }
            }
        }

        // ----- ДЕЛЕГАТ ДЛЯ PERCENT (Громкость, Яркость и др.) -----
        Component {
            id: percentDelegate
            Item {
                width: parent.width
                height: isVisible ? 16 : 0
                clip: true

                property var valData: ({})
                property bool isVisible: false

                Behavior on height {
                    NumberAnimation {
                        duration: 200 * root.animations
                        easing.type: Easing.OutCubic
                    }
                }

                Timer {
                    id: hideTimer
                    interval: 1500
                    onTriggered: isVisible = false
                }

                property var lastBright: ({})

                JsonListen {
                    command: itemConfig.command ? localPath(Qt.resolvedUrl(itemConfig.command)) : ""
                    onDataChanged: {
                        if (!data) return
                        
                        if (itemConfig.id === "brightness") {
                            var monitor = data.monitor
                            var newBright = parseInt(data.bright)
                            var oldBright = lastBright[monitor] !== undefined ? lastBright[monitor] : -1
                            lastBright[monitor] = newBright

                            if (monitor !== modelData.name || oldBright === -1 || newBright === oldBright) {
                                return
                            }
                        }

                        valData = data
                        isVisible = true
                        hideTimer.restart()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 16
                    anchors.top: parent.top
                    radius: 8
                    color: "transparent"

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

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 3
                        anchors.bottomMargin: 3

                        Text {
                            id: iconText
                            anchors.verticalCenter: parent.verticalCenter
                            text: valData.sign ?? itemConfig.icon ?? ""
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 14
                        }

                        Rectangle {
                            implicitHeight: parent.height
                            implicitWidth: 156
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: iconText.right
                            anchors.leftMargin: 6
                            radius: 5
                            opacity: 0.65
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: col.backgroundAlt2 }
                                GradientStop { position: 0.275; color: col.backgroundAlt1 }
                                GradientStop { position: 0.725; color: col.backgroundAlt1 }
                                GradientStop { position: 1.0; color: col.backgroundAlt2 }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.margins: 2
                                implicitHeight: parent.height - 4
                                implicitWidth: Math.max(0, Math.min(152, ((parseInt(valData.vol ?? valData.bright ?? valData.value ?? 0)) / 100) * 152))
                                color: col.accent
                                radius: 3

                                Behavior on implicitWidth {
                                    NumberAnimation {
                                        duration: 200 * root.animations
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            text: (valData.vol ?? valData.bright ?? valData.value ?? 0) + "%"
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
        }

        // ----- ДЕЛЕГАТ ДЛЯ TEXT -----
        Component {
            id: textDelegate
            Item {
                width: parent.width
                height: isVisible ? 16 : 0
                clip: true

                property string textMessage: ""
                property bool isVisible: false

                Behavior on height {
                    NumberAnimation {
                        duration: 200 * root.animations
                        easing.type: Easing.OutCubic
                    }
                }

                Timer {
                    id: hideTimer
                    interval: 1500
                    onTriggered: isVisible = false
                }

                // Вспомогательный TextMetrics для точного расчёта ширины текста
                TextMetrics {
                    id: textMeasurer
                    font.family: "Mononoki Nerd Font Propo"
                    font.pixelSize: 14
                    text: textMessage
                }

                JsonListen {
                    command: itemConfig.command ? localPath(Qt.resolvedUrl(itemConfig.command)) : ""
                    onDataChanged: {
                        if (!data) return
                        var msg = data.text ?? data.message ?? ""
                        if (msg !== "") {
                            textMessage = msg
                            isVisible = true

                            // Доступная ширина внутри плашки (220 - 5px слева - 5px справа = 210px)
                            var availableWidth = osdLayer.implicitWidth - 10
                            var textWidth = textMeasurer.width

                            if (textWidth > availableWidth) {
                                // Рассчитываем время на прокрутку длинного текста:
                                // Скорость скролла ~40px/sec + паузы на старте/финише по 800ms
                                var overflow = textWidth - availableWidth
                                var scrollDuration = (overflow / 40) * 1000
                                var totalDisplayTime = scrollDuration + 1600 + 2000 // pause + запас

                                hideTimer.interval = Math.max(1500, totalDisplayTime)
                            } else {
                                hideTimer.interval = 1500
                            }

                            hideTimer.restart()
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 16
                    anchors.top: parent.top
                    radius: 8
                    color: "transparent"

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

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 3
                        anchors.bottomMargin: 3

                        MarqueeText {
                            anchors.fill: parent
                            text: textMessage
                            color: col.accent
                            font.family: textMeasurer.font.family
                            font.pixelSize: textMeasurer.font.pixelSize
                        }
                    }
                }
            }
        }
    }
}
