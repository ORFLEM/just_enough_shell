import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../helpers"

WlrLayershell {
    id: root
    layer: WlrLayer.Overlay
    namespace: "wall-picker"
    exclusiveZone: 0
    color: "transparent"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Состояние
    property string bin: Quickshell.env("HOME") + "/.config/quickshell/wallpaper/wallpaper-picker"
    property string activeTab: "image"   // "image" | "video" | "shader"
    property string searchTerm: ""
    property var items: []
    property bool loading: false
    property string currentScheme: "classic"   // "classic" или "vibrant"

    // Процесс для получения состояния при старте
    Process {
        id: stateProc
        running: false
        command: [root.bin, "get-state"]
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text.trim()
                if (!raw) return
                try {
                    var obj = JSON.parse(raw)
                    // obj.colorscheme должно быть добавлено в Go
                    if (obj.colorscheme) root.currentScheme = obj.colorscheme
                } catch (e) { console.warn("[WallPicker] state parse:", e) }
            }
        }
    }

    function setScheme(scheme) {
        Quickshell.execDetached([root.bin, "set-scheme", scheme])
        root.currentScheme = scheme
    }

    // Один процесс на весь пикер
    Process {
        id: listProc
        running: false
        // command выставляется явно в reload() — не биндинг,
        // чтобы не было гонки когда activeTab меняется раньше
        // чем binding успевает обновиться
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                var raw = text.trim()
                if (!raw) { root.items = []; return }
                try       { root.items = JSON.parse(raw) }
                catch (e) { console.warn("[WallPicker] parse:", e); root.items = [] }
            }
        }
        stderr: SplitParser { onRead: d => console.warn("[WallPicker]", d) }
    }

    function reload() {
        root.loading = true
        root.items = []
        listProc.running = false
        // Выставляем command здесь — activeTab и searchTerm уже актуальны
        listProc.command = searchTerm !== ""
            ? [root.bin, "list-tab", root.activeTab, root.searchTerm]
            : [root.bin, "list-tab", root.activeTab]
        listProc.running = true
    }

    onActiveTabChanged: reload()
    onSearchTermChanged: searchDebounce.restart()

    Timer {
        id: searchDebounce
        interval: 250
        onTriggered: reload()
    }

    // LazyLoader создаёт компонент — сразу грузим и фокусируем
    Component.onCompleted: {
        reload()
        searchInput.forceActiveFocus()
        stateProc.running = true   // получить текущую схему
    }
    

    // Действие: применить обои
    // setProc живёт в shell.qml — здесь только сигнал через execDetached
    // execDetached не привязан к жизненному циклу компонента
    function applyWall(entry) {
        if (entry.type === "shader") {
            Quickshell.execDetached([root.bin, "set-shader", entry.name])
        } else {
            Quickshell.execDetached([root.bin, "set", entry.path])
        }
        wallPickerOpen = false
    }

    // Кэш превью
    Process {
        id: cacheProc
        running: false
        command: [root.bin, "cache-all"]
        onExited: (code, _) => { if (code === 0) reload() }
    }

    // Фон — клик закрывает
    MouseArea {
        anchors.fill: parent
        onClicked: wallPickerOpen = false
    }

    // Панель
    Rectangle {
        id: panel
        width: 900
        height: 620
        anchors.top: barOnTop ? parent.top : false
        anchors.bottom: !barOnTop ? parent.bottom : false
        anchors.left: parent.left
        anchors.topMargin: 6
        anchors.leftMargin: 6
        anchors.bottomMargin: 6
        radius: mainRad
        color: "transparent"

        // Градиент — точно как у BaseBar
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

        MouseArea { anchors.fill: parent; onClicked: {} }

        // Внутренний контейнер — margin 3 как у бара
        Item {
            anchors.fill: parent
            anchors.margins: 3

            // Заголовок
            Item {
                id: headerRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 30

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

                // Иконка + заголовок — слева
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        text: "󰸉"
                        color: col.accent
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Wallpaper picker"
                        color: col.font
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Кнопки — справа
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    // Кэш превью
                    Item {
                        width: cacheIcon.width + 12
                        height: 26

                        Rectangle {
                            id: cacheBg
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: cacheIcon
                            anchors.centerIn: parent
                            text: cacheProc.running ? "󰑓" : "󰑐"
                            color: col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                cacheBg.color = col.accent
                                cacheIcon.color = col.fontDark
                            }
                            onExited: {
                                cacheBg.color = "transparent"
                                cacheIcon.color = col.font
                            }
                            onClicked: {
                                if (!cacheProc.running) {
                                    cacheProc.running = false
                                    cacheProc.running = true
                                }
                            }
                        }
                    }

                    // Закрыть
                    Item {
                        width: closeIcon.width + 12
                        height: 26

                        Rectangle {
                            id: closeBg
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: closeIcon
                            anchors.centerIn: parent
                            text: "󰅗"
                            color: col.font
                            font.family: fontFamily
                            font.pixelSize: fontSize

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                closeBg.color = "#c0392b"
                                closeIcon.color = "#fff"
                            }
                            onExited: {
                                closeBg.color = "transparent"
                                closeIcon.color = col.font
                            }
                            onClicked: wallPickerOpen = false
                        }
                    }
                }
            }

            // Табы + поиск
            Item {
                id: tabRow
                anchors.top: headerRow.bottom
                anchors.topMargin: 3
                anchors.left: parent.left
                anchors.right: parent.right
                height: 30

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Repeater {
                        model: [ { tab: "image",  label: "Static" }, { tab: "video",  label: "Video"  }, { tab: "shader", label: "Shader" }, ]
                        delegate: Item {
                            id: tabItem
                            width: tabLabel.width + 24
                            height: 30

                            property bool isActive: root.activeTab === modelData.tab
                            // Активный режим совпадает с этим табом
                            property bool isCurrent: {
                                if (modelData.tab === "image")  return wallpaperType === 1
                                if (modelData.tab === "video")  return wallpaperType === 3
                                if (modelData.tab === "shader") return wallpaperType === 2
                                return false
                            }

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
                                id: tabBg
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: mainRad - 5

                                states: [
                                    State {
                                        name: "active"
                                        when: tabItem.isActive && !tabMa.containsMouse
                                        PropertyChanges { target: tabBg; color: col.accent }
                                    },
                                    State {
                                        name: "hovered"
                                        when: tabMa.containsMouse && !tabItem.isActive
                                        PropertyChanges { target: tabBg; color: col.backgroundAlt1 }
                                    },
                                    State {
                                        name: "normal"
                                        when: !tabItem.isActive && !tabMa.containsMouse
                                        PropertyChanges { target: tabBg; color: "transparent" }
                                    }
                                ]
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            Text {
                                id: tabLabel
                                anchors.centerIn: parent
                                text: modelData.label
                                color: tabItem.isActive ? col.fontDark : col.font
                                font.family: fontFamily
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            // Точка — этот таб сейчас активен как режим обоев
                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 4
                                color: tabItem.isActive ? col.fontDark : col.accent
                                visible: tabItem.isCurrent
                            }

                            MouseArea {
                                id: tabMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeTab = modelData.tab
                            }
                        }
                    }
                }
                

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    // Кнопка Classic
                    Item {
                        width: schemeLabel.width + 24
                        height: 26

                        property bool isActive: root.currentScheme === "scheme-tonal-spot" || root.currentScheme === "classic"

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
                            id: classicBg
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: parent.isActive ? col.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: schemeLabel
                            anchors.centerIn: parent
                            text: "Classic"
                            color: parent.isActive ? col.fontDark : col.font
                            font.family: fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setScheme("classic")
                        }
                    }

                    // Кнопка Vibrant
                    Item {
                        width: schemeLabel2.width + 24
                        height: 26

                        property bool isActive: root.currentScheme === "scheme-vibrant" || root.currentScheme === "vibrant"

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
                            id: vibrantBg
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: mainRad - 5
                            color: parent.isActive ? col.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Text {
                            id: schemeLabel2
                            anchors.centerIn: parent
                            text: "Vibrant"
                            color: parent.isActive ? col.fontDark : col.font
                            font.family: fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setScheme("vibrant")
                        }
                    }
                }
                // Поиск — справа
                Item {
                    width: 210
                    height: 30
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

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
                        id: searchBg
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: mainRad - 5
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            id: searchIcon
                            text: "󰍉"
                            color: col.accent
                            font.family: fontFamily
                            font.pixelSize: fontSize

                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Item {
                            width: parent.width - searchIcon.width - parent.spacing
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "search..."
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: 15
                                visible: searchInput.text === ""
                            }
                            TextInput {
                                id: searchInput
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: 15
                                clip: true
                                // Обновляем searchTerm — дебаунс сам вызовет reload()
                                onTextChanged: root.searchTerm = text
                                Keys.onEscapePressed: wallPickerOpen = false
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            searchBg.color = col.backgroundAlt1
                            searchIcon.color = col.font
                        }
                        onExited: {
                            searchBg.color = "transparent"
                            searchIcon.color = col.accent
                        }
                        onClicked: searchInput.forceActiveFocus()
                    }
                }
            }

            // Контент
            // Один ClippingRectangle — Loader переключает GridView / ListView
            ClippingRectangle {
                id: contentArea
                anchors.top: tabRow.bottom
                anchors.topMargin: 3
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                radius: mainRad - 5
                color: "transparent"

                // Текст загрузки / пусто — поверх контента
                Text {
                    anchors.centerIn: parent
                    visible: root.loading || root.items.length === 0
                    text: root.loading ? "󰑐  update..." : "noting("
                    color: col.backgroundAlt2
                    font.family: fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    z: 1
                }

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    // Меняем компонент при смене таба —
                    // предыдущий полностью уничтожается из дерева
                    sourceComponent: root.activeTab === "shader" ? shaderComp : gridComp
                }
                ClippingRectangle {
                    // Общий скроллбар поверх всего
                    ScrollBar {
                        id: commonScrollBar
                        policy: ScrollBar.AlwaysOn   // или AsNeeded, как нравится
                        orientation: Qt.Vertical
                        interactive: true
                        z: 10
                    parent: contentArea
    
                        // Размер и положение берём напрямую из Flickable (GridView/ListView)
                        size: contentLoader.item ? contentLoader.item.height / contentLoader.item.contentHeight : 0
                        position: contentLoader.item ? contentLoader.item.visibleArea.yPosition : 0
                    active: contentLoader.item ? contentLoader.item.movingVertically : false
    
                        // Привязываем скроллбар к Flickable для прокрутки при перетаскивании
                        Connections {
                            target: contentLoader.item
                            enabled: contentLoader.item !== null
                            function onContentYChanged() {
                                commonScrollBar.position = contentLoader.item.visibleArea.yPosition
                            }
                            function onContentHeightChanged() {
                                commonScrollBar.size = contentLoader.item.height / contentLoader.item.contentHeight
                            }
                    }
    
                        // Обработка перетаскивания скроллбара
                        onPositionChanged: {
                            if (contentLoader.item && (pressed || moving)) {
                                contentLoader.item.contentY = position * contentLoader.item.contentHeight
                            }
                    }
    
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                    anchors.margins: 2
    
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: commonScrollBar.pressed ? col.accent : Qt.darker(col.accent, 1.3)
                            Behavior on color { ColorAnimation { duration: 150 } }
                    }
    
                        background: Rectangle {
                            anchors.fill: parent
                            radius: mainRad - 3
                            opacity: 0.45
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: col.backgroundAlt2 }
                                GradientStop { position: 0.275; color: col.backgroundAlt1 }
                                GradientStop { position: 0.725; color: col.backgroundAlt1 }
                                GradientStop { position: 1.0; color: col.backgroundAlt2 }
                            }
                        }
                    }
                }
            }
        }
    }

    // Компоненты контента — вне панели, не создаются пока не нужны

    // Грид: Static / Видео
    Component {
        id: gridComp

        GridView {
            anchors.fill: parent
            clip: true
            cacheBuffer: 0
            model: root.items

            // cellWidth делим на 3 колонки без остатка
            cellWidth: Math.floor(width / 3)
            cellHeight: Math.floor(cellWidth * Screen.height / Screen.width) + 28

            delegate: Item {
                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                // Пилюля — внешний градиент
                Item {
                    anchors.fill: parent
                    anchors.bottomMargin: 4
                    anchors.leftMargin: (index % 3 === 0) ? 0 : 2
                    anchors.rightMargin: (index % 3 === 2) ? 0 : 2

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

                    // Внутренний — clip + hover
                    ClippingRectangle {
                        id: cardBg
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: mainRad - 6
                        color: "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }

                        // Превью
                        ClippingRectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: Math.floor(parent.width * Screen.height / Screen.width)
                            radius: mainRad - 6

                            Image {
                                anchors.fill: parent
                                source: modelData.thumb !== "" ? "file://" + modelData.thumb : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                // Не грузим полный файл — только нужный размер
                                sourceSize.width: 320
                                sourceSize.height: (Screen.height / Screen.width) * sourceSize.width
                                opacity: cardMa.containsMouse ? 0.72 : 1.0
                                Behavior on opacity { NumberAnimation { duration: 200 } }

                                Rectangle {
                                    anchors.fill: parent
                                    color: col.background1
                                    visible: parent.status !== Image.Ready
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.type === "video" ? "󰨜" : "󰸉"
                                        color: col.backgroundAlt2
                                        font.family: fontFamily
                                        font.pixelSize: 20
                                    }
                                }
                            }
                        }

                        // VIDEO бейдж
                        Item {
                            visible: modelData.type === "video"
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 28
                            width: vidBadgeText.width + 10
                            height: 16

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
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
                            Text {
                                id: vidBadgeText
                                anchors.centerIn: parent
                                text: "󰨜 VIDEO"
                                font.family: fontFamily
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: "#fff"
                            }
                        }

                        // Имя файла
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 2
                            spacing: 4

                            Text {
                                id: cardIcon
                                text: modelData.type === "video" ? "󰨜" : "󰸉"
                                color: cardMa.containsMouse ? col.fontDark : col.accent
                                font.family: fontFamily
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            Text {
                                id: cardName
                                width: parent.width - cardIcon.width - parent.spacing
                                text: modelData.name
                                color: cardMa.containsMouse ? col.fontDark : col.font
                                font.family: fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }

                    MouseArea {
                        id: cardMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: cardBg.color = col.accent
                        onExited: cardBg.color = "transparent"
                        onClicked: root.applyWall(modelData)
                    }
                }
            }
        }
    }

    // Список шейдеров
    Component {
        id: shaderComp

        ListView {
            anchors.fill: parent
            clip: true
            cacheBuffer: 0
            spacing: 3
            model: root.items

            delegate: Item {
                width: ListView.view.width
                height: 34

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
                    id: shBg
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: mainRad - 5
                    color: "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        id: shIcon
                        text: "󰔯"
                        color: col.accent
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    Text {
                        id: shName
                        width: parent.width - shIcon.width - shDot.width - 20
                        text: modelData.name
                        color: col.font
                        font.family: fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    // Точка — этот шейдер сейчас активен
                    Rectangle {
                        id: shDot
                        width: 7
                        height: 7
                        radius: 4
                        color: col.accent
                        anchors.verticalCenter: parent.verticalCenter
                        visible: wallpaperType === 2 && wallShaderName === modelData.name
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        shBg.color = col.accent
                        shIcon.color = col.fontDark
                        shName.color = col.fontDark
                    }
                    onExited: {
                        shBg.color = "transparent"
                        shIcon.color = col.accent
                        shName.color = col.font
                    }
                    onClicked: root.applyWall(modelData)
                }
            }
        }
    }
}
