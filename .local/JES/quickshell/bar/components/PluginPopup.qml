import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

WlrLayershell {
    id: pluginCenter
    namespace: "Plugin center"
    layer: WlrLayer.Top
    screen: Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    anchors {
        top: barOnTop
        right: true
        bottom: !barOnTop
    }
    implicitHeight: 506
    implicitWidth: 706
    color: "transparent"

    property var pluginInfo: []   // плоский массив блоков { source, qmlFile, colSpan, rowSpan }

    FileView {
        id: pluginLoader
        path: Quickshell.env("HOME") + "/.cache/JES_center_loaders.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            loadPlugins(text())
        }
    }

    // Загружает данные, разворачивает структуру в плоский список
    function loadPlugins(raw) {
        try {
            var data = raw.trim()
            if (data === "") {
                pluginInfo = []
                return
            }
            var newTabs = JSON.parse(data)
            if (!Array.isArray(newTabs) || newTabs.length === 0) {
                pluginInfo = []
                return
            }

            var flatItems = []
            for (var i = 0; i < newTabs.length; i++) {
                var plugin = newTabs[i]
                var pluginSource = plugin.source
                if (!pluginSource) {
                    console.warn("Плагин без source, пропускаем")
                    continue
                }
                var items = plugin.info
                if (!Array.isArray(items)) continue
                for (var j = 0; j < items.length; j++) {
                    var item = items[j]
                    if (!item.source) {
                        console.warn("Блок без source, пропускаем")
                        continue
                    }
                    flatItems.push({
                        source: pluginSource,
                        qmlFile: item.source,
                        colSpan: item.colSpan || 1,
                        rowSpan: item.rowSpan || 1
                    })
                }
            }
            pluginInfo = flatItems
        } catch(e) {
            console.warn("Ошибка загрузки плагинов:", e)
            pluginInfo = []
        }
    }

    property int currentPage: 0
    readonly property int pageCells: 21   // 3*7 ячеек

    property var pages: []      // массив страниц (каждая – массив элементов)
    property var currentItems: [] // упакованные элементы для текущей страницы

    // Упаковка элементов в сетку с учётом colSpan/rowSpan
    function packItems(items, cols, rows) {
        if (!items || items.length === 0) return []
        var occupied = [];
        for (var r = 0; r < rows; r++) {
            occupied[r] = [];
            for (var c = 0; c < cols; c++) occupied[r][c] = false;
        }
        var packed = [];
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            // Защита от undefined
            if (!item || typeof item !== "object") {
                console.warn("Элемент не является объектом, пропускаем")
                continue
            }
            var colSpan = item.colSpan || 1;
            var rowSpan = item.rowSpan || 1;
            var placed = false;
            for (var r = 0; r <= rows - rowSpan; r++) {
                for (var c = 0; c <= cols - colSpan; c++) {
                    var canPlace = true;
                    for (var dr = 0; dr < rowSpan; dr++) {
                        for (var dc = 0; dc < colSpan; dc++) {
                            if (occupied[r + dr][c + dc]) { canPlace = false; break; }
                        }
                        if (!canPlace) break;
                    }
                    if (canPlace) {
                        for (var dr = 0; dr < rowSpan; dr++) {
                            for (var dc = 0; dc < colSpan; dc++) {
                                occupied[r + dr][c + dc] = true;
                            }
                        }
                        packed.push({
                            source: item.source || "",
                            qmlFile: item.qmlFile || "",
                            row: r,
                            col: c,
                            rowSpan: rowSpan,
                            colSpan: colSpan
                        });
                        placed = true;
                        break;
                    }
                }
                if (placed) break;
            }
            if (!placed) {
                console.warn("⚠️ Не удалось разместить блок:", item.source, item.qmlFile);
            }
        }
        return packed;
    }

    // Перестроить страницы на основе pluginInfo
    function rebuildPages() {
        if (pluginInfo.length === 0) {
            pages = []
            currentItems = []
            return
        }
        var pagesArray = [];
        var currentPageItems = [];
        var cellsUsed = 0;
        for (var i = 0; i < pluginInfo.length; i++) {
            var item = pluginInfo[i];
            var size = (item.colSpan || 1) * (item.rowSpan || 1);
            if (cellsUsed + size > pageCells && cellsUsed > 0) {
                pagesArray.push(currentPageItems);
                currentPageItems = [];
                cellsUsed = 0;
            }
            currentPageItems.push(item);
            cellsUsed += size;
            if (cellsUsed >= pageCells) {
                pagesArray.push(currentPageItems);
                currentPageItems = [];
                cellsUsed = 0;
            }
        }
        if (currentPageItems.length > 0) {
            pagesArray.push(currentPageItems);
        }
        pages = pagesArray;
        if (currentPage >= pages.length) currentPage = Math.max(0, pages.length - 1);
        if (currentPage < 0) currentPage = 0;
        updateCurrentItems();
    }

    // Обновить currentItems для текущей страницы
    function updateCurrentItems() {
        if (pages.length === 0) {
            currentItems = [];
            return;
        }
        if (currentPage >= pages.length) currentPage = pages.length - 1;
        var pageItems = pages[currentPage] || [];
        currentItems = packItems(pageItems, 3, 7);
    }

    // Следим за изменениями
    onPluginInfoChanged: rebuildPages()
    onCurrentPageChanged: updateCurrentItems()

    Component.onCompleted: {
        rebuildPages()
        console.log("pages.length =", pages.length, "pluginInfo.length =", pluginInfo.length)
    }

    // ------------------- Внешний вид -------------------
    Item {
        anchors.fill: parent
        anchors.topMargin: barOnTop ? 6 : 0
        anchors.bottomMargin: !barOnTop? 6 : 0
        anchors.rightMargin: 6

        Rectangle {
            anchors.fill: parent
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

            Column {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 3

                ClippingRectangle {
                    id: gridContainer
                    width: parent.width
                    height: parent.height - tabsRow.height - parent.spacing
                    radius: mainRad - 3
                    color: "transparent"
                
                    readonly property int cols: 3
                    readonly property int rows: 7
                    readonly property real spacing: 3
                
                    readonly property real cellWidth: (gridContainer.width - spacing * (cols - 1)) / cols
                    readonly property real cellHeight: (gridContainer.height - spacing * (rows - 1)) / rows
                
                    Item {
                        anchors.fill: parent
                
                        Repeater {
                            model: currentItems
                            delegate: Item {
                                // Защита от undefined в modelData
                                visible: modelData && typeof modelData === "object"
                                x: modelData ? modelData.col * (gridContainer.cellWidth + gridContainer.spacing) : 0
                                y: modelData ? modelData.row * (gridContainer.cellHeight + gridContainer.spacing) : 0
                                width: modelData ? modelData.colSpan * gridContainer.cellWidth + (modelData.colSpan - 1) * gridContainer.spacing : 0
                                height: modelData ? modelData.rowSpan * gridContainer.cellHeight + (modelData.rowSpan - 1) * gridContainer.spacing : 0
                
                                Loader {
                                    anchors.fill: parent
                                    source: modelData && modelData.source && modelData.qmlFile ? "file://" + modelData.source + "/" + modelData.qmlFile : ""
                                    asynchronous: true
                                }
                            }
                        }
                    }
                }

                // Панель вкладок (индикатор страниц)
                Item {
                    id: tabsRow
                    height: 8
                    width: parent.width
                    visible: pages.length > 1
                    Row {
                        spacing: 3
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: pages.length
                            delegate: Rectangle {
                                width: index === currentPage ? 16 : 8
                                height: 8
                                radius: 4
                                color: index === currentPage ? col.accent : col.accent2
                                Behavior on width { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    onClicked: currentPage = index
                                }
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y > 0) {
                                if (currentPage > 0) currentPage--
                            } else if (wheel.angleDelta.y < 0) {
                                if (currentPage < pages.length - 1) currentPage++
                            }
                        }
                    }
                }
            }
        }
    }
}
