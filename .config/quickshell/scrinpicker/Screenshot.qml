import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root

    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    color:   "transparent"
    visible: false

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace:     "scrinpicker"
    WlrLayershell.exclusiveZone: -1

    // Данные от Go (плоские массивы)
    property var verts: []      // [x1,y1, x2,y2, ...]
    property var tris: []       // [i1,i2,i3, i4,i5,i6, ...]
    property var bbox: []       // [minX1,maxX1,minY1,maxY1, ...]
    property var hidden: []     // bool для каждого треугольника

    // Параметры выделения
    property real selX: 0
    property real selY: 0
    property real selW: 0
    property real selH: 0
    property bool selecting: false

    // Визуальные параметры (переименовано)
    property real triAlpha: 0.45
    property string triColor: "#7F77DD"

    // Активация оверлея
    function activate() {
        opacityKiller.running = true
    }

    // Убиваем старый скрипт прозрачности
    Process {
        id: opacityKiller
        command: ["pkill", "-f", ".config/sway/opacity-changer.sh"]
        running: false
        onExited: {
            var scr = Quickshell.screens[0]
            var w   = scr ? scr.width  : 1920
            var h   = scr ? scr.height : 1080
            genProc.command = [
                Quickshell.env("HOME") + "/.config/quickshell/scrinpicker/scrinpicker",
                w.toString(), h.toString()
            ]
            genProc.running = false
            genProc.running = true
        }
    }

    // Генерация треугольников (один раз)
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
                    // Проверяем формат: если parsed.verts существует, то новый формат
                    if (parsed.verts !== undefined && parsed.tris !== undefined) {
                        root.verts = parsed.verts
                        root.tris  = parsed.tris
                        root.bbox  = parsed.bbox
                        root.triAlpha = parsed.alpha
                        root.triColor = parsed.color
                        root.hidden = new Array(root.tris.length / 3).fill(false)
                    } else {
                        // Старый формат (массив треугольников) – конвертируем для совместимости
                        console.warn("Old format detected, converting...")
                        var oldTris = parsed
                        root.verts = []
                        root.tris = []
                        root.bbox = []
                        var vertMap = {}
                        function addVert(x, y) {
                            var key = x + "," + y
                            if (vertMap[key] !== undefined) return vertMap[key]
                            var idx = root.verts.length / 2
                            root.verts.push(x, y)
                            vertMap[key] = idx
                            return idx
                        }
                        for (var i = 0; i < oldTris.length; i++) {
                            var t = oldTris[i]
                            var i1 = addVert(t.a.x, t.a.y)
                            var i2 = addVert(t.b.x, t.b.y)
                            var i3 = addVert(t.c.x, t.c.y)
                            root.tris.push(i1, i2, i3)
                            var minX = Math.min(t.a.x, t.b.x, t.c.x)
                            var maxX = Math.max(t.a.x, t.b.x, t.c.x)
                            var minY = Math.min(t.a.y, t.b.y, t.c.y)
                            var maxY = Math.max(t.a.y, t.b.y, t.c.y)
                            root.bbox.push(minX, maxX, minY, maxY)
                        }
                        root.triAlpha = 0.45
                        root.triColor = "#7F77DD"
                        root.hidden = new Array(root.tris.length / 3).fill(false)
                    }
                    root.visible = true
                    triCanvas.requestPaint()
                } catch(e) { console.warn("[scrinpicker]", e) }
            }
        }
        stderr: SplitParser { onRead: d => console.warn("[scrinpicker err]", d) }
    }

    Process { id: grimProc; running: false; command: [] }
    Process {
        id: opacityRestorer
        command: ["/bin/sh", "-c", "~/.config/sway/opacity-changer.sh &"]
        running: false
    }

    function closeOverlay() {
        // Останавливаем процессы
        if (genProc.running) genProc.running = false
        if (grimProc.running) grimProc.running = false
        if (opacityKiller.running) opacityKiller.running = false

        root.visible   = false
        root.verts     = []
        root.tris      = []
        root.bbox      = []
        root.hidden    = []
        root.selecting = false
        root.selW = 0; root.selH = 0
    }

    // Функция обновления скрытых треугольников
    function updateHidden(rx1, ry1, rx2, ry2) {
        var trisCount = root.tris.length / 3
        var bboxData  = root.bbox
        var hiddenArr = root.hidden
        var dirty = false

        for (var i = 0; i < trisCount; i++) {
            var minX = bboxData[i*4]
            var maxX = bboxData[i*4+1]
            var minY = bboxData[i*4+2]
            var maxY = bboxData[i*4+3]

            if (maxX < rx1 || minX > rx2 || maxY < ry1 || minY > ry2) {
                if (hiddenArr[i] !== false) {
                    hiddenArr[i] = false
                    dirty = true
                }
                continue
            }

            var i1 = root.tris[i*3]
            var i2 = root.tris[i*3+1]
            var i3 = root.tris[i*3+2]

            var ax = root.verts[i1*2],   ay = root.verts[i1*2+1]
            var bx = root.verts[i2*2],   by = root.verts[i2*2+1]
            var cx = root.verts[i3*2],   cy = root.verts[i3*2+1]

            var touches = triTouchesRect(ax, ay, bx, by, cx, cy, rx1, ry1, rx2, ry2)

            if (touches !== hiddenArr[i]) {
                hiddenArr[i] = touches
                dirty = true
            }
        }
        return dirty
    }

    // Проверка пересечения треугольника и прямоугольника (полная реализация)
    function triTouchesRect(ax, ay, bx, by, cx, cy, rx1, ry1, rx2, ry2) {
        function inR(x,y) { return x>=rx1 && x<=rx2 && y>=ry1 && y<=ry2 }
        if (inR(ax,ay)||inR(bx,by)||inR(cx,cy)) return true

        function ptInTri(px,py) {
            var d1 = (px-bx)*(ay-by) - (ax-bx)*(py-by)
            var d2 = (px-cx)*(by-cy) - (bx-cx)*(py-cy)
            var d3 = (px-ax)*(cy-ay) - (cx-ax)*(py-ay)
            return !((d1<0||d2<0||d3<0) && (d1>0||d2>0||d3>0))
        }
        if (ptInTri(rx1,ry1)||ptInTri(rx2,ry1)||ptInTri(rx2,ry2)||ptInTri(rx1,ry2)) return true

        function seg(ax,ay,bx,by,cx,cy,dx,dy) {
            var d1x = bx-ax, d1y = by-ay, d2x = dx-cx, d2y = dy-cy
            var cr = d1x*d2y - d1y*d2x
            if (Math.abs(cr)<1e-10) return false
            var ex = cx-ax, ey = cy-ay
            var t = (ex*d2y - ey*d2x)/cr
            var u = (ex*d1y - ey*d1x)/cr
            return t>=0 && t<=1 && u>=0 && u<=1
        }
        var pts = [[ax,ay],[bx,by],[cx,cy]]
        var re = [[rx1,ry1,rx2,ry1],[rx2,ry1,rx2,ry2],[rx2,ry2,rx1,ry2],[rx1,ry2,rx1,ry1]]
        for (var ei=0; ei<3; ei++) {
            var e0 = pts[ei], e1 = pts[(ei+1)%3]
            for (var ri=0; ri<4; ri++)
                if (seg(e0[0],e0[1],e1[0],e1[1], re[ri][0],re[ri][1], re[ri][2],re[ri][3]))
                    return true
        }
        return false
    }

    // Таймер для throttle обновления hidden
    Timer {
        id: updateTimer
        interval: 16   // ~60 fps
        repeat: false
        onTriggered: {
            if (!root.selecting) return
            var rx1 = Math.min(root.selX, root.selX+root.selW)
            var ry1 = Math.min(root.selY, root.selY+root.selH)
            var rx2 = Math.max(root.selX, root.selX+root.selW)
            var ry2 = Math.max(root.selY, root.selY+root.selH)
            var dirty = root.updateHidden(rx1, ry1, rx2, ry2)
            if (dirty && !paintTimer.running) {
                paintTimer.start()
            }
        }
    }

    // Таймер для throttling перерисовки
    Timer {
        id: paintTimer
        interval: 16
        repeat: false
        onTriggered: triCanvas.requestPaint()
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        focus: true
        preventStealing: true

        Keys.onEscapePressed: {
            root.closeOverlay()
            opacityRestorer.running = true
        }

        onPressed: function(mouse) {
            root.selX = mouse.x; root.selY = mouse.y
            root.selW = 0;       root.selH = 0
            root.selecting = true
            // Сброс hidden
            for (var i=0; i<root.hidden.length; i++) root.hidden[i] = false
            triCanvas.requestPaint()
        }

        onPositionChanged: function(mouse) {
            if (!root.selecting) return
            root.selW = mouse.x - root.selX
            root.selH = mouse.y - root.selY
            // Не обновляем hidden напрямую, а запускаем таймер
            if (!updateTimer.running) {
                updateTimer.start()
            }
        }

        onReleased: function(mouse) {
            root.selecting = false
            var x1 = Math.round(Math.min(root.selX, root.selX+root.selW))
            var y1 = Math.round(Math.min(root.selY, root.selY+root.selH))
            var w = Math.round(Math.abs(root.selW))
            var h = Math.round(Math.abs(root.selH))
            if (w>5 && h>5) {
                grimTimer.region = x1+","+y1+" "+w+"x"+h
                grimTimer.start()
            } else {
                root.closeOverlay()
                opacityRestorer.running = true
            }
        }
    }

    Timer {
        id: grimTimer
        property string region: ""
        interval: 150; repeat: false
        onTriggered: {
            root.closeOverlay()
            grimProc.command = ["/bin/sh","-c",
                "FILE=~/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S')_screenshot.png" +
                " && mkdir -p ~/Screenshots" +
                " && grim -g '" + grimTimer.region + "' - | tee \"$FILE\" | wl-copy" +
                " && { [ -s \"$FILE\" ] || rm -f \"$FILE\"; }" +
                " && ~/.config/sway/opacity-changer.sh &"]
            grimProc.running = true
        }
    }

    Canvas {
        id: triCanvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Threaded

        onPaint: {
            if (root.tris.length === 0) return

            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            // Рисуем все видимые треугольники одним path
            ctx.globalAlpha = root.triAlpha
            ctx.fillStyle   = root.triColor
            ctx.beginPath()

            var trisCount = root.tris.length / 3
            for (var i = 0; i < trisCount; i++) {
                if (root.hidden[i]) continue

                var i1 = root.tris[i*3]
                var i2 = root.tris[i*3+1]
                var i3 = root.tris[i*3+2]

                var ax = root.verts[i1*2], ay = root.verts[i1*2+1]
                var bx = root.verts[i2*2], by = root.verts[i2*2+1]
                var cx = root.verts[i3*2], cy = root.verts[i3*2+1]

                ctx.moveTo(ax, ay)
                ctx.lineTo(bx, by)
                ctx.lineTo(cx, cy)
                ctx.closePath()
            }
            ctx.fill()
            ctx.globalAlpha = 1.0

            // Рамка выделения
            if (root.selecting && (Math.abs(root.selW)>2 || Math.abs(root.selH)>2)) {
                ctx.strokeStyle = Qt.rgba(1,1,1,0.6)
                ctx.lineWidth   = 1
                ctx.setLineDash([4,4])
                ctx.strokeRect(root.selX, root.selY, root.selW, root.selH)
                ctx.setLineDash([])
            }
        }
    }
}
