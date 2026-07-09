import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import "../helpers"

WlrLayershell {
    id: launcher
    layer: WlrLayer.Overlay
    namespace: "launcher"
    implicitWidth: 1000
    implicitHeight: 513
    color: "transparent"

    property int currentTab: 0

    // Исходные данные для вкладок (полные списки)
    property var tabModel: ([
        {
            name: "Applications",
            icon: "",
            placeholder: "Search...",
            info: []
        },
        {
            name: "Clipboard",
            icon: "󰅍",
            placeholder: "Clipboard...",
            info: []
        }
    ])

    // Модель для отображения (фильтрованная)
    ListModel {
        id: fInfo
    }

    keyboardFocus: WlrKeyboardFocus.Exclusive

    // Функция фильтрации
    function filterInfo() {
        var fullList = tabModel[currentTab].info || []
        var searchText = searchInput.text.trim().toLowerCase()
        var filtered = []

        if (searchText === "") {
            filtered = fullList
        } else {
            for (var i = 0; i < fullList.length; i++) {
                var item = fullList[i]
                // поиск по имени (можно добавить comment при необходимости)
                if (item.name && item.name.toLowerCase().includes(searchText)) {
                    filtered.push(item)
                }
            }
        }

        fInfo.clear()
        for (var j = 0; j < filtered.length; j++) {
            fInfo.append(filtered[j])
        }
    }

    function closeLauncher() {
        searchInput.text = ""
        Quickshell.execDetached(["sh", "-c", "quickshell ipc call root toggleLaunch"])
    }

    function runProgram() {
        var idx = list.currentIndex;
        if (idx < 0 || idx >= fInfo.count) return;
        var item = fInfo.get(idx);
        console.log("Executing:", item.exec + " " + item.id);
        Quickshell.execDetached(["sh", "-c", item.exec, item.id]);
        closeLauncher();
    }

    // Проги
    Process {
        id: appProc
        running: false
        command: ["sh", "-c", Quickshell.env("HOME") + "/.config/quickshell/launcher/launch " + searchInput.text]
        stdout: SplitParser {
            onRead: data => {
                try {
                    tabModel[0].info = JSON.parse(data)
                    tabModel = [...tabModel] 
                    filterInfo()
                } catch(e) {}
            }
        }
    }

    // Буфер
    Process {
        id: clipProc
        running: false
        command: [Quickshell.env("HOME") + "/.config/quickshell/launcher/cliphist-json"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    tabModel[1].info = JSON.parse(data)
                    tabModel = [...tabModel] 
                    filterInfo()
                } catch(e) {}
            }
        }
    }

    onCurrentTabChanged: {
        fInfo.clear()
        if (currentTab === 0) {
            clipProc.running = false
            appProc.running = false
            appProc.command = ["sh", "-c", Quickshell.env("HOME") + "/.config/quickshell/launcher/launch " + searchInput.text]
            appProc.running = true
        } else if (currentTab === 1) {
            appProc.running = false
            clipProc.running = false
            clipProc.running = true
        }
        list.currentIndex = -1
        filterInfo()
    
        // Прокрутка к активной вкладке с задержкой
        if (tabListView) {
            Qt.callLater(function() {
                tabListView.positionViewAtIndex(currentTab, ListView.Center)
            })
        }
    }
        
    Component.onCompleted: {
        appProc.running = true
        searchInput.forceActiveFocus()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: closeLauncher()
    }

    Rectangle {
        id: win
        width: 1000
        height: 513
        anchors.centerIn: parent
        radius: mainRad
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

        MouseArea { anchors.fill: parent; onClicked: {} }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ========== ЛЕВАЯ ПАНЕЛЬ ==========
            ClippingRectangle {
                Layout.preferredWidth: 480
                Layout.fillHeight: true
                radius: mainRad
                color: "transparent"
                ShaderEffect {
                    anchors.fill: parent
                    property color accent: col.accent
                    property color dark: col.backgroundAlt1
                    property color mid: col.background1
                    property vector2d resolution: Qt.vector2d(width, height)
                    property real time: 0.0
                    property real patternScale: 3.2
                    property real evolutionSpeed: 0.004
                
                    NumberAnimation on time {
                        from: 0; to: 1000
                        duration: 1000000
                        loops: Animation.Infinite
                        running: launcher.visible
                    }
                
                    fragmentShader: Qt.resolvedUrl("bg.frag.qsb")
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 0

                        Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: mainRad - 3
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
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Text {
                                text: tabModel[currentTab].icon
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize - 3
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                color: col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize - 2
                                placeholderText: tabModel[currentTab].placeholder
                                placeholderTextColor: col.font
                                background: Item {}

                                Keys.onEscapePressed: closeLauncher()
                                Keys.onUpPressed: list.decrementCurrentIndex()
                                Keys.onDownPressed: list.incrementCurrentIndex()
                                
                                Keys.onPressed: event => {
                                    if (event.modifiers & Qt.ShiftModifier) {
                                        if (event.key === Qt.Key_Left) currentTab = Math.max(0, currentTab - 1)
                                        else if (event.key === Qt.Key_Right) currentTab = Math.min(tabModel.length  - 1, currentTab + 1)
                                    }
                                }

                                Keys.onReturnPressed: {
                                    runProgram()
                                }      
                                    
                                onTextChanged: {
                                    list.currentIndex = -1
                                    // фильтруем при каждом вводе
                                    filterInfo()
                                    // перезапускаем процесс только для вкладки приложений при изменении текста
                                    if (currentTab === 0) {
                                        appProc.command = ["sh", "-c", Quickshell.env("HOME") + "/.config/quickshell/launcher/launch " + searchInput.text]
                                        appProc.running = false
                                        appProc.running = true
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                    

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: mainRad - 3
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

                        ClippingRectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: mainRad - 5
                            color: "transparent"
                            
                            ListView {
                                id: tabListView
                                anchors.fill: parent
                                orientation: ListView.Horizontal
                                spacing: 3
                                clip: true
                            
                                model: ScriptModel {
                                    values: tabModel
                                }
                            
                                delegate: Rectangle {
                                    width: {
                                        var totalWidth = tabListView.width - (tabListView.count - 1) * tabListView.spacing - 2 * tabListView.anchors.margins;
                                        var neededWidth = text.implicitWidth + 16;
                                        if (totalWidth / tabListView.count >= neededWidth)
                                            return totalWidth / tabListView.count;
                                        else
                                            return neededWidth;
                                    }
                                    height: 30
                                    radius: mainRad - 5
                                    color: currentTab === index ? col.accent : col.backgroundAlt1
                                    Behavior on color { ColorAnimation { duration: 150 } }
                            
                                    Text {
                                        id: text
                                        anchors.centerIn: parent
                                        text: modelData.name
                                        color: currentTab === index ? col.fontDark : col.font
                                        font.family: fontFamily
                                        font.pixelSize: fontSize - 4
                                    }
                            
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: currentTab = index
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.NoButton  // не перехватываем клики, только колёсико
                                    onWheel: {
                                        var delta = wheel.angleDelta.x || wheel.angleDelta.y
                                        // Превращаем дельту в скорость (пикселей в секунду)
                                        // Множитель 2 — подбери под свой вкус
                                        var velocity = -delta * 2
                                        // Имитируем жест с заданной скоростью — ListView сам обработает границы и инерцию
                                        tabListView.flick(velocity, 0)
                                        wheel.accepted = true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ========== ПРАВАЯ ПАНЕЛЬ ==========
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                // Используем fInfo как модель
                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3
                    clip: true
                    model: fInfo
                    currentIndex: -1

                    delegate: Rectangle {
                        width: list.width
                        height: 48
                        radius: mainRad - 3
                        opacity: 0.95
                        property bool isCurrent: ListView.isCurrentItem
                        color: isCurrent ? col.accent : col.backgroundAlt1
                        Behavior on color { ColorAnimation { duration: 150 } }
                    
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 15
                    
                            IconImage {
                                id: iconImg
                                width: 32
                                height: 32
                                smooth: true
                                source: Quickshell.iconPath(model.icon, true)
                                visible: source !== ""
                            }
                    
                            Text {
                                Layout.fillWidth: true
                                text: model.name ?? ""
                                color: parent.parent.isCurrent ? col.fontDark : col.font
                                font.family: fontFamily
                                font.pixelSize: fontSize - 2
                                elide: Text.ElideRight
                            }
                        }
                    
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (list.currentIndex === index) {
                                    runProgram()
                                } else {
                                    list.currentIndex = index
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
