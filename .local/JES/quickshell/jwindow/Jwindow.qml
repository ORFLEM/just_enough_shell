import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

WlrLayershell {
    id: jwindow
    namespace: "Jwindow"
    exclusiveZone: -1
    layer: WlrLayer.Top

    anchors {
        bottom: true
        left: true
    }

    implicitWidth: Math.max(Math.min(contentRow.implicitWidth + root.margins * 2, 1920), 500)
    implicitHeight: Math.max(Math.min(contentRow.implicitHeight + root.margins * 2, 720), 250)

    margins {
        bottom: !barOnTop ? root.wtw + barHeight : root.wtw
        left: root.wtw
    }

    color: "transparent"

    // ===== Данные системы =====
    property int logoType: 1
    property var sysData: null
    property string osText: "..."
    property string kernelText: "..."
    property string cpuText: "..."
    property string gpuText: "..."
    property string ramText: "..."
    property string diskText: "..."
    property string pkgsSystemText: ""
    property string pkgsUserText: ""
    
    // ===== Вкладки: About System — всегда первая =====
    property var tabs: [{ name: "About System", source: "Fetch.qml" }]
    property int currentTabIndex: 0

    // ===== Загрузка плагинов =====
    FileView {
        id: tabsLoader
        path: Quickshell.env("HOME") + "/.cache/JES/JES_Jwindow_tabs.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            loadTabs(text())
        }
    }

    function loadTabs(raw) {
        try {
            var data = raw.trim()
            if (data === "") {
                tabs = [{ name: "About System", source: "Fetch.qml" }]
                return
            }
            var parsed = JSON.parse(data)
            if (!Array.isArray(parsed) || parsed.length === 0) {
                tabs = [{ name: "About System", source: "Fetch.qml" }]
                return
            }

            var pluginTabs = []
            for (var i = 0; i < parsed.length; i++) {
                var tab = parsed[i]
                if (tab.name) {
                    pluginTabs.push({
                        name: tab.name,
                        source: tab.source || ""
                    })
                }
            }

            var baseTabs = [{ name: "About System", source: "Fetch.qml" }]
            tabs = baseTabs.concat(pluginTabs)

            if (currentTabIndex >= tabs.length) currentTabIndex = 0

        } catch(e) {
            console.warn("Ошибка загрузки вкладок:", e)
            tabs = [{ name: "About System", source: "" }]
        }
    }
        
    // ===== Процесс fetch.sh =====
    Process {
        id: fetchProc
        command: ["sh", "-c", localPath(Qt.resolvedUrl("../scripts/fetch.sh"))]
        running: true
    
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    jwindow.sysData = data;
    
                    if (data.os) {
                        jwindow.osText = data.os.distro + " " + data.os.arch;
                        jwindow.kernelText = data.os.kernel;
                    }
    
                    if (data.cpu) {
                        var freq = data.cpu.freq_mhz ? (data.cpu.freq_mhz / 1000).toFixed(2) + " GHz" : "";
                        jwindow.cpuText = data.cpu.model + " (" + data.cpu.cores + ")" + (freq ? " @ " + freq : "");
                    }
    
                    if (data.gpu && data.gpu.model !== "null") {
                        jwindow.gpuText = data.gpu.model;
                    } else {
                        jwindow.gpuText = "N/A";
                    }
    
                    if (data.ram) {
                        jwindow.ramText = jwindow.formatBytes(data.ram.used_bytes) + " / " + jwindow.formatBytes(data.ram.total_bytes);
                    }
    
                    if (data.disk) {
                        var used = jwindow.formatBytes(data.disk.used_bytes);
                        var total = jwindow.formatBytes(data.disk.total_bytes);
                        var pct = data.disk.total_bytes > 0 ? ((data.disk.used_bytes / data.disk.total_bytes) * 100).toFixed(0) : 0;
                        jwindow.diskText = used + " / " + total + " (" + pct + "%)";
                    }
    
                    if (data.packages && data.packages.length > 0) {
                        var systemParts = [];
                        var userParts = [];
                        for (var i = 0; i < data.packages.length; i++) {
                            var p = data.packages[i];
                            var entry = p.count + " [" + p.manager + "]";
                            if (p.scope === "system") systemParts.push(entry);
                            else if (p.scope === "user") userParts.push(entry);
                        }
                        jwindow.pkgsSystemText = systemParts.join(", ");
                        jwindow.pkgsUserText = userParts.join(", ");
                    } else {
                        jwindow.pkgsSystemText = "";
                        jwindow.pkgsUserText = "";
                    }   
                } catch (e) {
                    console.log("JSON parse error:", e);
                }
            }
        }
    }
    
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: fetchProc.running = true
    }
    
    function formatBytes(bytes) {
        if (bytes === null || bytes === undefined || bytes === 0) return "0 B";
        var units = ["B", "KB", "MB", "GB", "TB", "PB"];
        var i = 0;
        var value = bytes;
        while (value >= 1024 && i < units.length - 1) {
            value /= 1024;
            i++;
        }
        return i >= 3 ? value.toFixed(2) + " " + units[i] : Math.round(value) + " " + units[i];
    }
    

    // ===== Анимация логотипа =====
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            logoType = (logoType == 1 ? 2 : 1)
        }
    }

    
    // ===== Интерфейс =====
    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
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
        }

        Item {
            anchors.fill: parent
            anchors.margins: root.margins

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: root.spacing

                // ===== Левая панель (список вкладок) =====
                Rectangle {
                    id: leftPanel
                    implicitWidth: 200
                    implicitHeight: rightPanel.implicitHeight
                    radius: mainRad - root.margins
                    opacity: 0.65
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: col.backgroundAlt2 }
                        GradientStop { position: 0.275; color: col.backgroundAlt1 }
                        GradientStop { position: 0.725; color: col.backgroundAlt1 }
                        GradientStop { position: 1.0; color: col.backgroundAlt2 }
                    }
                    Item {
                        y: 3
                        width: parent.width - root.margins * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: parent.height - root.spacing - root.margins - logoTextLeft.height
                    ListView {
                        anchors.fill: parent
                        id: tabListView
                        spacing: root.spacing
                        clip: true
                        model: tabs
                        currentIndex: currentTabIndex

                        delegate: Rectangle {
                            id: delegateItem
                            implicitWidth: leftPanel.width - root.margins * 2
                            implicitHeight: fontSize + root.margins * 2
                            radius: mainRad - root.margins * 2
                            property bool isCurrent: ListView.isCurrentItem
                            color: isCurrent ? col.accent : col.background1
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                text: modelData.name
                                color: parent.isCurrent ? col.fontDark : col.font
                                font.pixelSize: fontSize
                                font.family: fontFamily
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    tabListView.currentIndex = index
                                    currentTabIndex = index
                                }
                            }
                        }
                    }
                    }
                    
                    Text {
                        id: logoTextLeft
                        visible: tabListView.currentIndex == 0 ? false : true
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.margins: root.margins
                        font.family: fontFamily
                        font.pixelSize: 15
                        color: col.font
                        text: logoType == 1 ? "> Just Enough Shell  " : "> Just Enough Shell _"
                    }
                }

                // ===== Правая панель (контент) =====
                Item {
                    id: rightPanel
                    implicitWidth: Math.max(loader.implicitWidth, 500)
                    implicitHeight: Math.max(Math.min(loader.implicitHeight, 720), 250)

                    Loader {
                        id: loader
                        anchors.centerIn: parent
                        // width: item ? item.width : 500   // если компонент загружен – берём его ширину
                        // height: item ? item.height : 250
                    
                        // Для внешних плагинов — source (URL)
                        // Для встроенной вкладки — sourceComponent (Component)
                        // Оба свойства имеют binding, но только одно из них "активно" в каждый момент

                        // source: {
                        //     if (currentTabIndex < tabs.length) {
                        //         var tab = tabs[currentTabIndex]
                        //         if (tab.source && tab.source !== "") {
                        //             return ("file://" + tab.source)
                        //         }
                        //     }
                        //     return ""  // пустая строка = выгрузить внешний файл
                        // }

                        source: Qt.resolvedUrl(tabs[currentTabIndex].source)
                    
                        // sourceComponent: {
                        //     if (currentTabIndex < tabs.length) {
                        //         var tab = tabs[currentTabIndex]
                        //         if (!tab.source || tab.source === "") {
                        //             return aboutSystemComponent  // встроенный компонент
                        //         }
                        //     }
                        //     return null  // нет встроенного компонента
                        // }
                    
                        onStatusChanged: {
                            if (status === Loader.Error) {
                                console.warn("Ошибка загрузки плагина:", source, errorString())
                                // При ошибке сбрасываем на встроенную вкладку
                                source = ""
                                sourceComponent = aboutSystemComponent
                            }
                        }
                    
                        onLoaded: {
                            rightPanel.implicitWidthChanged()
                            rightPanel.implicitHeightChanged()
                            contentRow.implicitWidthChanged()
                            contentRow.implicitHeightChanged()
                        }
                    }
                }
            }
        }
    }
}
