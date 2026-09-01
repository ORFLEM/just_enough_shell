import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../helpers"

PanelWindow {
    id: notificationsWindow
    
    // Сквозной проход кликов в местах, где нет карточек
    mask: Region {
        item: notifsListView
    }

    exclusiveZone: 0
    visible: notificationServer.trackedNotifications.values.length > 0

    anchors {
        top: true
        right: true
    }

    // Внешние отступы от краев экрана через root.wtw
    margins {
        right: root.wtw
        top: root.wtw
    }

    // Проверяем, есть ли хоть одно уведомление с картинкой
    property bool hasImages: {
        let notifs = notificationServer.trackedNotifications.values
        for (let i = 0; i < notifs.length; i++) {
            if (notifs[i] && (notifs[i].image || notifs[i].appIcon)) return true
        }
        return false
    }

    // Ширина окна подстраивается так, чтобы ничего не обрезалось
    implicitWidth: (hasImages ? 380 : 360) + root.wtw
    implicitHeight: notifsListView.contentHeight + root.margins * 2

    color: "transparent"

    property int defaultTimeout: 5000
    property var knownNotifications: ({})
    property var notificationOrder: []

    Component.onCompleted: markAllAsKnown()

    function markAllAsKnown() {
        notificationOrder = []
        let notifs = notificationServer.trackedNotifications.values
        for (let i = 0; i < notifs.length; i++) {
            let notification = notifs[i]
            if (notification && notification.id) {
                let id = notification.id.toString()
                knownNotifications[id] = Date.now()
                notificationOrder.push(id)
            }
        }
    }

    function cleanupNotificationTracking(notificationId) {
        if (notificationId) {
            let id = notificationId.toString()
            delete knownNotifications[id]
            let index = notificationOrder.indexOf(id)
            if (index > -1) notificationOrder.splice(index, 1)
        }
    }

    NotificationServer {
        id: notificationServer
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        inlineReplySupported: false
        imageSupported: true
        actionIconsSupported: true
        persistenceSupported: false

        onNotification: function(notification) {
            try {
                notification.tracked = true
                if (notification.id) {
                    let id = notification.id.toString()
                    knownNotifications[id] = "NEW_" + Date.now()
                    notificationOrder.unshift(id)
                }
            } catch (error) {
                console.error("Error in onNotification handler: " + error)
            }
        }
    }

    ListView {
        id: notifsListView
        anchors.fill: parent
        spacing: root.spacing
        clip: false
        model: notificationServer.trackedNotifications.values

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250 * root.animations
                easing.type: Easing.OutQuart
            }
        }

        delegate: Rectangle {
            id: notificationRect
            
            // Карточка строго по ширине списка
            width: notifsListView.width
            implicitHeight: contentRow.implicitHeight + (root.margins * 2)
            height: implicitHeight
            radius: mainRad
            opacity: 0.85
            color: "transparent"

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: col.background3 }
                GradientStop { position: 0.05; color: col.background2 }
                GradientStop { position: 0.3; color: col.background1 }
                GradientStop { position: 0.7; color: col.background1 }
                GradientStop { position: 0.95; color: col.background2 }
                GradientStop { position: 1.0; color: col.background3 }
            }

            property var parentWindow: notificationsWindow
            property string notificationId: (modelData && modelData.id) ? modelData.id.toString() : ""
            property bool isExpiring: false
            property int totalDuration: modelData && modelData.expireTimeout > 0 ?
                (modelData.expireTimeout * 1000) : notificationsWindow.defaultTimeout

            x: notifsListView.width

            Component.onCompleted: {
                if (notificationId) {
                    let trackingValue = parentWindow.knownNotifications[notificationId]
                    let isNew = trackingValue && trackingValue.toString().startsWith("NEW_")

                    if (isNew) {
                        parentWindow.knownNotifications[notificationId] = Date.now()
                        slideInAnimation.start()
                        Quickshell.execDetached(["sh", "-c", "pw-play ~/.config/quickshell/notifications/mes.ogg"])
                    } else {
                        x = 0
                        autoExpireTimer.start()
                    }
                } else {
                    x = 0
                    autoExpireTimer.start()
                }
            }

            // Анимация появления
            SequentialAnimation {
                id: slideInAnimation
                NumberAnimation {
                    target: notificationRect
                    property: "x"
                    from: notifsListView.width
                    to: 0
                    duration: 350 * root.animations
                    easing.type: Easing.OutCubic
                }
                ScriptAction { script: autoExpireTimer.start() }
            }

            // Анимация ухода
            SequentialAnimation {
                id: dismissAnimation
                ScriptAction { script: notificationRect.isExpiring = true }
                NumberAnimation {
                    target: notificationRect
                    property: "x"
                    to: notifsListView.width
                    duration: 300 * root.animations
                    easing.type: Easing.InCubic
                }
                ScriptAction {
                    script: {
                        try {
                            notificationRect.parentWindow.cleanupNotificationTracking(notificationRect.notificationId)
                            if (modelData) modelData.dismiss()
                        } catch (error) {
                            console.error("Error dismissing notification:", error)
                        }
                    }
                }
            }

            Timer {
                id: autoExpireTimer
                interval: notificationRect.totalDuration
                running: false
                repeat: false
                onTriggered: {
                    if (!notificationRect.isExpiring) dismissAnimation.start()
                }
            }

            // Главная кликабельная область
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onEntered: autoExpireTimer.stop()
                onExited: {
                    if (!notificationRect.isExpiring) autoExpireTimer.start()
                }

                onClicked: function(mouse) {
                    if (notificationRect.isExpiring) return

                    if (mouse.button === Qt.LeftButton) {
                        if (modelData) {
                            if (modelData.hasDefaultAction) {
                                modelData.invokeDefaultAction()
                            }
                            dismissAnimation.start()
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        try {
                            let notifs = notificationServer.trackedNotifications.values
                            parentWindow.knownNotifications = {}
                            parentWindow.notificationOrder = []
                            for (let i = 0; i < notifs.length; ++i) {
                                if (notifs[i]) notifs[i].dismiss()
                            }
                        } catch (e) {
                            console.error("Error dismissing all:", e)
                        }
                    }
                }
            }

            // Контейнер контента
            RowLayout {
                id: contentRow
                anchors.fill: parent
                anchors.margins: root.margins
                spacing: root.spacing

                // 1. Изображение/Аватарка
                ClippingRectangle {
                    id: imageContainer
                    Layout.preferredWidth: visible ? 52 : 0
                    Layout.preferredHeight: 52
                    Layout.alignment: Qt.AlignVCenter
                    radius: mainRad - root.margins
                    color: "transparent"
                    visible: modelData && (modelData.image || modelData.appIcon)

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        source: modelData ? (modelData.image || modelData.appIcon || "") : ""
                    }
                }

                // 2. Основной текстовый и интерактивный блок
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: root.spacing

                    // Шапка: Имя приложения + Капсула «Время + Закрытие»
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.spacing

                        Text {
                            Layout.fillWidth: true
                            text: (modelData && modelData.appName) || "Notification"
                            font.pixelSize: fontSize - 1
                            font.weight: Font.Bold
                            font.family: fontFamily
                            color: col.accent
                            elide: Text.ElideRight
                        }

                        Item {
                            implicitWidth: headerPillContent.implicitWidth + (root.margins * 2)
                            implicitHeight: headerPillContent.implicitHeight + (root.margins / 2)

                            Rectangle {
                                anchors.fill: parent
                                radius: mainRad - root.margins
                                opacity: 0.65
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: col.backgroundAlt2 }
                                    GradientStop { position: 0.275; color: col.backgroundAlt1 }
                                    GradientStop { position: 0.725; color: col.backgroundAlt1 }
                                    GradientStop { position: 1.0; color: col.backgroundAlt2 }
                                }
                            }

                            RowLayout {
                                id: headerPillContent
                                anchors.centerIn: parent
                                spacing: root.spacing

                                Text {
                                    text: Qt.formatTime(new Date(), "hh:mm:ss")
                                    font.pixelSize: fontSize - 3
                                    font.family: fontFamily
                                    color: base.base05
                                }

                                Item {
                                    width: 16
                                    height: 16

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        font.pixelSize: 11
                                        font.family: fontFamily
                                        color: closeArea.containsMouse ? col.accent : col.font
                                    }

                                    MouseArea {
                                        id: closeArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: dismissAnimation.start()
                                    }
                                }
                            }
                        }
                    }

                    // Текст сообщения
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: (modelData && modelData.summary) || ""
                            font.pixelSize: fontSize
                            font.weight: Font.Bold
                            font.family: fontFamily
                            color: col.font
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (modelData && modelData.body) || ""
                            font.pixelSize: fontSize - 1
                            font.family: fontFamily
                            color: col.font
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            visible: text !== ""
                        }
                    }

                    // Кнопки с MarqueeText
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.spacing
                        visible: modelData && modelData.actions && modelData.actions.length > 0

                        Repeater {
                            model: modelData ? modelData.actions : []
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                radius: mainRad - root.margins
                                color: actionArea.containsMouse ? col.accent : col.backgroundAlt1
                                opacity: 0.9

                                MarqueeText {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 6
                                    text: modelData.text
                                    font.pixelSize: fontSize - 2
                                    font.bold: true
                                    color: actionArea.containsMouse ? col.fontDark : col.font
                                }

                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        modelData.invoke()
                                        dismissAnimation.start()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
