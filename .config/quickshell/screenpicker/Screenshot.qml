import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Shapes

PanelWindow {
    id: root

    anchors.top: true; anchors.bottom: true; anchors.left: true; anchors.right: true
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "screenpicker"
    WlrLayershell.exclusiveZone: -1

    // Данные от Go-программы
    property var verts: []
    property var tris: []
    property var bbox: []

    // Выделение мышью
    property real selX: 0
    property real selY: 0
    property real selW: 0
    property real selH: 0
    property bool selecting: false

    property var triTargetAlpha: []   // цель: 0 или 0.45
    property var triAlpha: []         // текущая плавная альфа

    property var triMinX: []
    property var triMinY: []
    property var triMaxX: []
    property var triMaxY: []
    
    function cacheBounds() {
        var cnt = root.tris.length / 3
        triMinX = new Array(cnt)
        triMinY = new Array(cnt)
        triMaxX = new Array(cnt)
        triMaxY = new Array(cnt)
        for (var i = 0; i < cnt; i++) {
            var i1 = root.tris[i*3], i2 = root.tris[i*3+1], i3 = root.tris[i*3+2]
            var x1 = root.verts[i1*2], y1 = root.verts[i1*2+1]
            var x2 = root.verts[i2*2], y2 = root.verts[i2*2+1]
            var x3 = root.verts[i3*2], y3 = root.verts[i3*2+1]
            triMinX[i] = Math.min(x1, x2, x3)
            triMaxX[i] = Math.max(x1, x2, x3)
            triMinY[i] = Math.min(y1, y2, y3)
            triMaxY[i] = Math.max(y1, y2, y3)
        }
    }
    
    // Когда загрузились треугольники — инициализируем массивы
    function initAlphaArrays() {
        var cnt = root.tris.length / 3
        triTargetAlpha = new Array(cnt).fill(0.55)
        triAlpha = new Array(cnt).fill(0.55)
        animTimer.stop()
    }
    
        // Запуск (больше не трогаем прозрачность)
    function activate() {
        // Сбросить старые данные и очистить Canvas
        grimTimer.stop()
        root.verts = []
        root.tris = []
        root.bbox = []
        triCanvas.requestPaint()   // очистить экран
    
        var scr = Quickshell.screens[0]
        var w = scr ? scr.width : 1920
        var h = scr ? scr.height : 1080
        root.triMinX = []
        root.triMaxX = []
        root.triMinY = []
        root.triMaxY = []
        if (genProc.running) genProc.running = false
        genProc.command = [
            Quickshell.env("HOME") + "/.config/quickshell/screenpicker/screenpicker",
            w.toString(), h.toString()
        ]
        genProc.running = true
    }

    function updateTargetAlpha() {
        if (!triTargetAlpha.length) return
        var selActive = root.selecting && (Math.abs(root.selW) > 2 || Math.abs(root.selH) > 2)
        var rx1 = 0, ry1 = 0, rx2 = 0, ry2 = 0
        if (selActive) {
            rx1 = Math.min(root.selX, root.selX + root.selW)
            ry1 = Math.min(root.selY, root.selY + root.selH)
            rx2 = Math.max(root.selX, root.selX + root.selW)
            ry2 = Math.max(root.selY, root.selY + root.selH)
        }
    
        var changed = false
        for (var i = 0; i < triTargetAlpha.length; i++) {
            var overlap = false
            if (selActive) {
                // вычисляем bounding box треугольника
                overlap = !(triMaxX[i] < rx1 || triMinX[i] > rx2 || triMaxY[i] < ry1 || triMinY[i] > ry2)
            }
            var target = overlap ? 0.0 : 0.45
            if (Math.abs(triTargetAlpha[i] - target) > 0.001) {
                triTargetAlpha[i] = target
                changed = true
            }
        }
        if (changed) animTimer.start()
    }
    Timer {
        id: animTimer
        interval: 15
        repeat: true
        onTriggered: {
            var any = false
            for (var i = 0; i < triAlpha.length; i++) {
                var cur = triAlpha[i]
                var tgt = triTargetAlpha[i]
                if (Math.abs(cur - tgt) < 0.005) {
                    triAlpha[i] = tgt
                } else {
                    triAlpha[i] = cur + (tgt - cur) * 0.45  // скорость сглаживания
                    any = true
                }
            }
            triCanvas.requestPaint()
            if (!any) stop()
        }
    }
    
    // Запуск screenpicker и чтение JSON
    Process {
        id: genProc
        running: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text.trim()
                if (!raw) return
                try {
                    var parsed = JSON.parse(raw)
                    if (parsed.verts !== undefined && parsed.tris !== undefined) {
                        root.verts = parsed.verts
                        root.tris = parsed.tris
                        root.bbox = parsed.bbox
                        initAlphaArrays()
                        cacheBounds()
                        console.log("Loaded", root.tris.length / 3, "triangles")
                        triCanvas.requestPaint()
                    }
                    root.visible = true
                } catch(e) { console.warn("[screenpicker]", e) }
            }
        }
        stderr: SplitParser { onRead: d => console.warn("[screenpicker err]", d) }
    }

    Process {
        id: grimProc
        running: false
        command: []
        onExited: {
            root.closeOverlay()
        }
    }

    // Сброс состояния и скрытие окна
    function closeOverlay() {
        if (genProc.running) genProc.running = false
        if (grimProc.running) grimProc.running = false
        grimTimer.stop()
        root.visible = false
        root.verts = []
        root.tris = []
        root.bbox = []
        root.triTargetAlpha = []
        root.triAlpha = []
        animTimer.stop()
        root.selecting = false
        root.selW = 0; root.selH = 0
        root.triMinX = []
        root.triMaxX = []
        root.triMinY = []
        root.triMaxY = []
        triCanvas.requestPaint()
    }

    // ----- Отрисовка треугольников с плавным исчезновением -----
    Canvas {
        id: triCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            // Если данных нет – ничего не рисуем
            if (!root.verts.length || !root.tris.length) return

            var v = root.verts
            var t = root.tris
            var triCount = t.length / 3
            // ctx.fillStyle = "#C8C8C8"
            ctx.fillStyle = col.accent

            // Если у нас есть анимированная прозрачность – рисуем с ней,
            // иначе (например, в первый момент) используем старую логику.
            // Безопасно проверяем, есть ли массив triAlpha нужной длины.
            var useAlphaAnim = (root.triAlpha && root.triAlpha.length === triCount)

            // Прямоугольник выделения (та же логика, что и раньше)
            var selActive = root.selecting && (Math.abs(root.selW) > 2 || Math.abs(root.selH) > 2)
            var rx1 = 0, ry1 = 0, rx2 = 0, ry2 = 0
            if (selActive) {
                rx1 = Math.min(root.selX, root.selX + root.selW)
                ry1 = Math.min(root.selY, root.selY + root.selH)
                rx2 = Math.max(root.selX, root.selX + root.selW)
                ry2 = Math.max(root.selY, root.selY + root.selH)
            }

            for (var i = 0; i < triCount; ++i) {
                var i1 = t[i*3]
                var i2 = t[i*3+1]
                var i3 = t[i*3+2]

                var x1 = v[i1*2]
                var y1 = v[i1*2+1]
                var x2 = v[i2*2]
                var y2 = v[i2*2+1]
                var x3 = v[i3*2]
                var y3 = v[i3*2+1]

                // Если анимация прозрачности активна – просто берём текущую альфу
                // (пересечение с рамкой уже учтено в расчёте цели)
                if (useAlphaAnim) {
                    ctx.globalAlpha = root.triAlpha[i]
                } else {
                    // Старое поведение: если треугольник пересекается с рамкой – пропускаем,
                    // иначе рисуем с постоянной прозрачностью 0.45
                    if (selActive) {
                        var overlap = !(triMaxX[i] < rx1 || triMinX[i] > rx2 || triMaxY[i] < ry1 || triMinY[i] > ry2)
                        if (overlap) continue
                    }
                    ctx.globalAlpha = 0.55
                }

                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.lineTo(x3, y3)
                ctx.closePath()
                ctx.fill()
            }
        }

        // Перерисовка при изменении размеров или свойств
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        // Эти сигналы будут дёргать и перерисовку, и обновление целевых альф
        Connections {
            target: root
            function onVertsChanged() { triCanvas.requestPaint() }
            function onTrisChanged() { triCanvas.requestPaint() }
            function onVisibleChanged() { if (root.visible) triCanvas.requestPaint() }
            // Добавляем вызов обновления целей при изменении рамки
            function onSelXChanged() { updateTargetAlpha(); triCanvas.requestPaint() }
            function onSelYChanged() { updateTargetAlpha(); triCanvas.requestPaint() }
            function onSelWChanged() { updateTargetAlpha(); triCanvas.requestPaint() }
            function onSelHChanged() { updateTargetAlpha(); triCanvas.requestPaint() }
            function onSelectingChanged() {
                if (!root.selecting) updateTargetAlpha()
                triCanvas.requestPaint()
            }
        }
    }

    // ----- Рамка выделения -----
    Rectangle {
        visible: root.selecting && (Math.abs(root.selW) > 2 || Math.abs(root.selH) > 2)
        x: Math.min(root.selX, root.selX + root.selW)
        y: Math.min(root.selY, root.selY + root.selH)
        width: Math.abs(root.selW)
        height: Math.abs(root.selH)
        color: "transparent"
        border.color: Qt.rgba(1,1,1,0.6)
        border.width: 2
    }

    // ----- Мышь и клавиатура -----
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        focus: true
        preventStealing: true

        onPressed: (mouse) => {
            root.selX = mouse.x
            root.selY = mouse.y
            root.selW = 0
            root.selH = 0
            root.selecting = true
        }

        onPositionChanged: (mouse) => {
            if (!pressed) return
            root.selW = mouse.x - root.selX
            root.selH = mouse.y - root.selY
        }

        onReleased: {
            root.selecting = false
            // Нормализуем прямоугольник
            var x1 = root.selX
            var y1 = root.selY
            var x2 = root.selX + root.selW
            var y2 = root.selY + root.selH
            var normX = Math.min(x1, x2)
            var normY = Math.min(y1, y2)
            var normW = Math.abs(root.selW)
            var normH = Math.abs(root.selH)
        
            if (normW > 5 && normH > 5) {
                var region = Math.round(normX) + "," + Math.round(normY) + " " +
                             Math.round(normW) + "x" + Math.round(normH)
                grimTimer.region = region
                root.visible = false
                grimTimer.start()
            } else {
                root.closeOverlay()
            }
        }
            
        Keys.onEscapePressed: {
            root.closeOverlay()
        }
    }

    Timer {
        id: grimTimer
        property string region: ""
        interval: 150
        repeat: false
        onTriggered: {
            grimProc.command = ["/bin/sh","-c",
                "FILE=~/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S')_screenshot.png" +
                " && mkdir -p ~/Screenshots" +
                " && grim -g '" + grimTimer.region + "' - | tee \"$FILE\" | wl-copy" +
                " && { [ -s \"$FILE\" ] || rm -f \"$FILE\"; }"]
            grimProc.running = true
        }
    }
}
