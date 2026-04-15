// MarqueeText.qml
import QtQuick

Item {
    id: container
    clip: true
    height: animatedText.implicitHeight
    property alias text: animatedText.text
    property alias color: animatedText.color
    property alias font: animatedText.font

    function originX() {
        var ret = container.width - animatedText.implicitWidth
        if(ret > 0) return ret/2
        else        return 0
    }

    function destinationX() {
        var ret = container.width - animatedText.implicitWidth
        if(ret < 0) return ret
        else        return originX()
    }

    function restartAnimation() {
        animation.stop()
        animation1.from = originX()
        animation1.to = originX()
        animation2.to = destinationX()
        animatedText.x = originX()
        animation.start()
    }

    onWidthChanged: restartAnimation()

    Text {
        id: animatedText
        width: implicitWidth
        elide: Text.ElideNone
        onImplicitWidthChanged: restartAnimation()
    }

    SequentialAnimation {
        id: animation
        loops: Animation.Infinite
    
        NumberAnimation { id: animation1; target: animatedText; property: "x"; duration: 100 }
        NumberAnimation { id: animation2; target: animatedText; property: "x"; duration: animatedText.implicitWidth * 20; easing.type: Easing.InOutSine }
        NumberAnimation { target: animatedText; property: "x"; to: container.originX(); duration: animatedText.implicitWidth * 20; easing.type: Easing.InOutSine }
    }
}
