import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import JES.Helpers

WlrLayershell {
    id: launcher
    layer: WlrLayer.Overlay
    namespace: "launcher"
    implicitWidth: 1000
    implicitHeight: 513
    color: "transparent"

    property int currentTab: 0

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

    property var pluginModel: ([])

    ListModel {
        id: fInfo
    }

    keyboardFocus: WlrKeyboardFocus.Exclusive

    // --- Рекурсивный универсальный поиск ---
    function itemMatchesSearch(obj, term) {
        if (obj === null || obj === undefined) return false;

        if (typeof obj === "string" || typeof obj === "number" || typeof obj === "boolean") {
            return obj.toString().toLowerCase().indexOf(term) !== -1;
        }

        if (Array.isArray(obj)) {
            for (var i = 0; i < obj.length; i++) {
                if (itemMatchesSearch(obj[i], term)) return true;
            }
            return false;
        }

        if (typeof obj === "object") {
            for (var key in obj) {
                if (obj.hasOwnProperty(key)) {
                    if (key.startsWith("_") || key === "objectName") continue;
                    if (itemMatchesSearch(obj[key], term)) return true;
                }
            }
        }

        return false;
    }

    // --- filter ---
    function filterInfo() {
        var fullList = tabModel[currentTab].info || []
        var searchText = searchInput.text.trim().toLowerCase()

        fInfo.clear()

        if (searchText === "") {
            for (var i = 0; i < fullList.length; i++) {
                fInfo.append(fullList[i])
            }
            return
        }

        for (var j = 0; j < fullList.length; j++) {
            var item = fullList[j]
            if (itemMatchesSearch(item, searchText)) {
                fInfo.append(item)
            }
        }
    }

    function closeLauncher() {
        searchInput.text = ""
        root.toggleLaunch()
    }

    function runProgram() {
        var idx = list.currentIndex;
        if (idx < 0 || idx >= fInfo.count) return;
        var item = fInfo.get(idx);
        console.log("Executing:", item.exec, item.id);
        Quickshell.execDetached(["bash", "-c", `id=${item.id}; ${item.exec}`]);
        closeLauncher();
    }

    // --- plugin Loader ---
    FileView {
        id: pluginLoader
        path: Quickshell.env("HOME") + "/.cache/JES/JES_launcher_modes.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            loadPluginsApps(text())
        }
    }

    function loadPluginsApps(raw) {
        try {
            var data = raw.trim()
            if (data === "") return
            var newTabs = JSON.parse(data)
            if (!Array.isArray(newTabs) || newTabs.length === 0) return
    
            var baseTabs = tabModel.slice(0, 2)
            tabModel = baseTabs.concat(newTabs)
            filterInfo()
        } catch(e) {
            console.warn("Ошибка загрузки плагинов:", e)
        }
    }               

    // --- Applications ---
    Process {
        id: appProc
        running: false
        command: ["sh", "-c", localPath(Qt.resolvedUrl("launch"))]
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

    // --- Clipboard ---
    Process {
        id: clipProc
        running: false
        command: ["sh", "-c", localPath(Qt.resolvedUrl("cliphist-json"))]
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

    Component.onCompleted: {
        appProc.running = true
        searchInput.forceActiveFocus()
        if (root.pluginListModel && root.pluginListModel.count > 0) {
            loadPluginsApps()
        }
    }

    // --- tabs ---
    onCurrentTabChanged: {
        fInfo.clear()
        if (currentTab === 0) {
            clipProc.running = false
            if (!appProc.running) {
                appProc.command = ["sh", "-c", localPath(Qt.resolvedUrl("launch"))]
                appProc.running = true
            }
        } else if (currentTab === 1) {
            appProc.running = false
            clipProc.running = false
            clipProc.running = true
        }
        list.currentIndex = -1
        filterInfo()
        if (tabListView) {
            Qt.callLater(function() {
                tabListView.positionViewAtIndex(currentTab, ListView.Center)
            })
        }
    }

    // --- UI ---
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

            ClippingRectangle {
                Layout.preferredWidth: 480
                Layout.fillHeight: true
                radius: mainRad
                color: "transparent"
                
                ShaderEffect {
                    id: shaderEffect
                    anchors.fill: parent
                    property color accent: col.accent
                    property color dark: col.backgroundAlt1
                    property color mid: col.background1
                    property vector2d resolution: Qt.vector2d(width, height)
                    property real time: 0.0
                    property real patternScale: 3.2
                    property real evolutionSpeed: 0.004

                    Timer {
                        interval: 16
                        running: launcher.visible && root.animations > 0.0
                        repeat: true
                        onTriggered: {
                            var speedMult = Math.max(root.animations, 0.3)
                            shaderEffect.time = shaderEffect.time + (0.016 * speedMult)
                        }
                    }

                    fragmentShader: Qt.resolvedUrl("bg.frag.qsb")
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.margins
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: mainRad - root.margins
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
                                        else if (event.key === Qt.Key_Right) currentTab = Math.min(tabModel.length - 1, currentTab + 1)
                                    }
                                }
                                Keys.onReturnPressed: runProgram()

                                onTextChanged: {
                                    list.currentIndex = -1
                                    filterInfo()
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: mainRad - root.margins
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
                            radius: mainRad - root.margins - 3
                            color: "transparent"
                            ListView {
                                id: tabListView
                                anchors.fill: parent
                                orientation: ListView.Horizontal
                                spacing: 3
                                clip: true
                                model: ScriptModel { values: tabModel }
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
                                    radius: mainRad - root.margins - 2
                                    color: currentTab === index ? col.accent : col.backgroundAlt1
                                    Behavior on color { ColorAnimation { duration: 150 * root.animations } }
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
                                    acceptedButtons: Qt.NoButton
                                    onWheel: {
                                        var delta = wheel.angleDelta.x || wheel.angleDelta.y
                                        var velocity = -delta * 2
                                        tabListView.flick(velocity, 0)
                                        wheel.accepted = true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ClippingRectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                Layout.margins: root.margins
                radius: mainRad - root.margins
                ListView {
                    id: list
                    anchors.fill: parent
                    spacing: root.spacing
                    clip: true
                    model: fInfo
                    currentIndex: -1
                    delegate: Rectangle {
                        width: list.width
                        height: 48
                        radius: mainRad - root.margins
                        opacity: 0.95
                        property bool isCurrent: ListView.isCurrentItem
                        color: isCurrent ? col.accent : col.backgroundAlt1
                        Behavior on color { ColorAnimation { duration: 150 * root.animations } }
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
