import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

WlrLayershell {
    id: screenCorner

    // Enum-like property for corner direction
    property int cornerDirection: ScreenCorner.TopLeft

    // Size properties
    property int cornerWidth: 25
    property int cornerHeight: 25

    // Color property
    property color cornerColor: "black"

    // Enum values for corner directions
    enum CornerDirection {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    // Set dimensions
    implicitWidth: cornerWidth
    implicitHeight: cornerHeight

    // WlrLayershell properties - respect exclusive zones
    exclusionMode: ExclusionMode.Ignore  // Don't claim exclusive zone
    layer: WlrLayer.Overlay
    color: "transparent"
    focusable: false
    namespace: "screen-corner"

    // Helper properties for cleaner code
    property bool isTopLeft: cornerDirection === ScreenCorner.CornerDirection.TopLeft
    property bool isTopRight: cornerDirection === ScreenCorner.CornerDirection.TopRight
    property bool isBottomLeft: cornerDirection === ScreenCorner.CornerDirection.BottomLeft
    property bool isBottomRight: cornerDirection === ScreenCorner.CornerDirection.BottomRight
    property bool isTop: isTopLeft || isTopRight
    property bool isBottom: isBottomLeft || isBottomRight
    property bool isLeft: isTopLeft || isBottomLeft
    property bool isRight: isTopRight || isBottomRight

    // Set anchors based on corner direction using WlrLayershell Edges
    anchors {
        top: isTop
        bottom: isBottom
        left: isLeft
        right: isRight
    }

    // Shape for drawing the corner
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer
        
        ShapePath {
            id: shapePath
            fillColor: screenCorner.cornerColor
            strokeWidth: 0
            pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting

            // Start position for the arc
            startX: {
                switch (screenCorner.cornerDirection) {
                    case ScreenCorner.CornerDirection.TopLeft: return 0
                    case ScreenCorner.CornerDirection.TopRight: return screenCorner.cornerWidth
                    case ScreenCorner.CornerDirection.BottomLeft: return 0
                    case ScreenCorner.CornerDirection.BottomRight: return screenCorner.cornerWidth
                }
            }
            
            startY: {
                switch (screenCorner.cornerDirection) {
                    case ScreenCorner.CornerDirection.TopLeft: return 0
                    case ScreenCorner.CornerDirection.TopRight: return 0
                    case ScreenCorner.CornerDirection.BottomLeft: return screenCorner.cornerHeight
                    case ScreenCorner.CornerDirection.BottomRight: return screenCorner.cornerHeight
                }
            }

            PathAngleArc {
                moveToStart: false
                centerX: screenCorner.cornerWidth - shapePath.startX
                centerY: screenCorner.cornerHeight - shapePath.startY
                radiusX: screenCorner.cornerWidth
                radiusY: screenCorner.cornerHeight
                startAngle: {
                    switch (screenCorner.cornerDirection) {
                        case ScreenCorner.CornerDirection.TopLeft: return 180
                        case ScreenCorner.CornerDirection.TopRight: return -90
                        case ScreenCorner.CornerDirection.BottomLeft: return 90
                        case ScreenCorner.CornerDirection.BottomRight: return 0
                    }
                }
                sweepAngle: 90
            }
            
            PathLine {
                x: shapePath.startX
                y: shapePath.startY
            }
        }
    }
}
