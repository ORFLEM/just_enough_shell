// Translator.qml
// Попап-переводчик — отдельное WlrLayershell окно.
// Открывается через: quickshell ipc call root toggleTranslator
//
// Переводит через translate-shell (trans):
//   pacman -S translate-shell   /   nix-env -iA nixpkgs.translate-shell
//
// Структура:
//   translator/
//     Translator.qml          ← этот файл
//     TranslatorButton.qml    ← кнопка в бар
//     scripts/
//       translate.sh <from> <to> <text>  ← возвращает строку перевода

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../helpers"

WlrLayershell {
    id: translator
    layer: WlrLayer.Overlay
    namespace: "translator"
    width: 500
    height: 560
    color: "transparent"

    keyboardFocus: WlrKeyboardFocus.Exclusive

    // ── состояние ──────────────────────────────────────────────────────────────
    property string fromLang: "auto"
    property string toLang:   "ru"
    property string inputText:  ""
    property string resultText: ""
    property bool   translating: false
    property int    mode: 0    // 0=клавиатура  1=быстрые фразы

    // ── доступные языки ────────────────────────────────────────────────────────
    property var langs: [
        { code: "auto", label: "auto", flag: "󰌏" },
        { code: "en",   label: "EN",   flag: "󰗊" },
        { code: "ru",   label: "RU",   flag: "󰗊" },
        { code: "de",   label: "DE",   flag: "󰗊" },
        { code: "fr",   label: "FR",   flag: "󰗊" },
        { code: "zh",   label: "ZH",   flag: "󰗊" },
        { code: "ja",   label: "JA",   flag: "󰗊" },
        { code: "es",   label: "ES",   flag: "󰗊" },
        { code: "ar",   label: "AR",   flag: "󰗊" },
        { code: "it",   label: "IT",   flag: "󰗊" },
        { code: "tr",   label: "TR",   flag: "󰗊" },
    ]

    // ── быстрые фразы ──────────────────────────────────────────────────────────
    property var quickPhrases: [
        "Where is the toilet?",
        "How much does it cost?",
        "I'm lost. Can you help?",
        "Please call an ambulance",
        "Do you speak English?",
        "A table for two, please",
        "The bill, please",
        "I am allergic to...",
        "Where is the nearest pharmacy?",
        "What time does it close?",
        "Can you write it down?",
        "I need a doctor",
    ]

    // ── процесс перевода ───────────────────────────────────────────────────────
    property Process _transProc: Process {
        id: transProc
        running: false

        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim()
                if (trimmed) {
                    translator.resultText = trimmed
                    translator.translating = false
                }
            }
        }
        stderr: SplitParser {
            onRead: err => {
                translator.resultText = "Ошибка: " + err
                translator.translating = false
            }
        }
        onExited: translator.translating = false
    }

    function doTranslate(text) {
        if (!text.trim()) return
        translating = true
        resultText  = ""
        inputText   = text
        transProc.running = false
        transProc.command = [
            "bash", "-c",
            Quickshell.env("HOME") +
            "/.config/quickshell/translator/scripts/translate.sh " +
            fromLang + " " + toLang + " " + JSON.stringify(text)
        ]
        transProc.running = true
    }

    function swapLangs() {
        if (fromLang === "auto") return
        let tmp = fromLang
        fromLang = toLang
        toLang   = tmp
        let tmpT = inputText
        inputText  = resultText
        resultText = tmpT
    }

    function closeTranslator() {
        Quickshell.execDetached(["sh", "-c",
            "quickshell ipc call root toggleTranslator"])
    }

    // ── клик снаружи закрывает ─────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        onClicked: closeTranslator()
    }

    // ── основное окно ──────────────────────────────────────────────────────────
    Rectangle {
        id: win
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        radius: mainRad
        opacity: 0.97

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0;   color: col.background3 }
            GradientStop { position: 0.05;  color: col.background2 }
            GradientStop { position: 0.3;   color: col.background1 }
            GradientStop { position: 0.7;   color: col.background1 }
            GradientStop { position: 0.95;  color: col.background2 }
            GradientStop { position: 1.0;   color: col.background3 }
        }

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            // ── Шапка ────────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: mainRad - 3
                opacity: 0.65
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0;   color: col.backgroundAlt2 }
                    GradientStop { position: 0.275; color: col.backgroundAlt1 }
                    GradientStop { position: 0.725; color: col.backgroundAlt1 }
                    GradientStop { position: 1.0;   color: col.backgroundAlt2 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: "󰗊  Переводчик"
                        color: col.font
                        font.family: "Mononoki Nerd Font Propo"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    // Режим: клавиатура / фразы
                    Repeater {
                        model: [
                            { icon: "󰌌", label: "Ввод",   idx: 0 },
                            { icon: "󱀀", label: "Фразы",  idx: 1 },
                        ]
                        delegate: Rectangle {
                            width: modeLabel.width + 20
                            height: 28
                            radius: mainRad - 5
                            color: mode === modelData.idx
                                ? col.accent
                                : (modeHover.containsMouse ? col.backgroundAlt2 : "transparent")
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: modelData.icon
                                    color: mode === modelData.idx ? col.fontDark : col.font
                                    font.family: "Mononoki Nerd Font Propo"
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                Text {
                                    id: modeLabel
                                    text: modelData.label
                                    color: mode === modelData.idx ? col.fontDark : col.font
                                    font.family: "Mononoki Nerd Font Propo"
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                            HoverHandler { id: modeHover }
                            TapHandler { onTapped: mode = modelData.idx }
                        }
                    }

                    // Закрыть
                    Rectangle {
                        width: 28; height: 28
                        radius: mainRad - 5
                        color: xHover.containsMouse ? col.backgroundAlt2 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 14
                        }
                        HoverHandler { id: xHover }
                        TapHandler { onTapped: closeTranslator() }
                    }
                }
            }

            // ── Выбор языков ─────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: mainRad - 3
                color: col.backgroundAlt1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 0

                    // From
                    Flickable {
                        Layout.fillWidth: true
                        height: parent.height
                        contentWidth: fromRow.width
                        clip: true

                        Row {
                            id: fromRow
                            height: parent.height
                            spacing: 4

                            Repeater {
                                model: translator.langs
                                delegate: Rectangle {
                                    width: fromChipLabel.width + 12
                                    height: 30
                                    radius: mainRad - 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: fromLang === modelData.code
                                        ? col.accent
                                        : (fromHover.containsMouse ? col.backgroundAlt2 : "transparent")
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        id: fromChipLabel
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: fromLang === modelData.code ? col.fontDark : col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    HoverHandler { id: fromHover }
                                    TapHandler { onTapped: fromLang = modelData.code }
                                }
                            }
                        }
                    }

                    // Кнопка swap
                    Rectangle {
                        width: 34; height: 34
                        radius: mainRad - 5
                        color: swapHover.containsMouse ? col.backgroundAlt2 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "󰁔"
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 16
                        }
                        HoverHandler { id: swapHover }
                        TapHandler { onTapped: swapLangs() }
                    }

                    // To
                    Flickable {
                        Layout.fillWidth: true
                        height: parent.height
                        contentWidth: toRow.width
                        clip: true

                        Row {
                            id: toRow
                            height: parent.height
                            spacing: 4

                            Repeater {
                                // auto не нужен в "куда"
                                model: translator.langs.filter(l => l.code !== "auto")
                                delegate: Rectangle {
                                    width: toChipLabel.width + 12
                                    height: 30
                                    radius: mainRad - 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: toLang === modelData.code
                                        ? col.accent
                                        : (toHover.containsMouse ? col.backgroundAlt2 : "transparent")
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        id: toChipLabel
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: toLang === modelData.code ? col.fontDark : col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    HoverHandler { id: toHover }
                                    TapHandler { onTapped: toLang = modelData.code }
                                }
                            }
                        }
                    }
                }
            }

            // ── Режим: ввод текста ────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                visible: mode === 0

                // Поле ввода
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: mainRad - 3
                    color: col.backgroundAlt1
                    border.color: inputArea.activeFocus ? col.accent : "transparent"
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        TextArea {
                            id: inputArea
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: translator.inputText
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 15
                            placeholderText: "Введите текст..."
                            placeholderTextColor: Qt.rgba(col.font.r, col.font.g, col.font.b, 0.3)
                            background: Item {}
                            wrapMode: TextArea.Wrap

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) closeTranslator()
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Return) {
                                    doTranslate(inputArea.text)
                                }
                            }

                            onTextChanged: {
                                translator.inputText = text
                                if (resultText !== "") resultText = ""
                            }
                        }

                        RowLayout {
                            spacing: 6

                            // Очистить
                            Rectangle {
                                width: 28; height: 24
                                radius: mainRad - 5
                                color: clearHover.containsMouse ? col.backgroundAlt2 : "transparent"
                                visible: inputArea.text !== ""
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    color: col.font
                                    font.family: "Mononoki Nerd Font Propo"
                                    font.pixelSize: 12
                                    opacity: 0.5
                                }
                                HoverHandler { id: clearHover }
                                TapHandler { onTapped: { inputArea.text = ""; translator.inputText = ""; translator.resultText = "" } }
                            }

                            Text {
                                text: inputArea.length + " симв."
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 10
                                opacity: 0.3
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Ctrl+Enter"
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 10
                                opacity: 0.3
                            }
                        }
                    }
                }

                // Кнопка перевести
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: mainRad - 3
                    color: translating
                        ? col.backgroundAlt2
                        : (translateBtnHover.containsMouse ? Qt.lighter(col.accent, 1.1) : col.accent)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: translating ? "󰔟" : "󰗊"
                            color: translating ? col.font : col.fontDark
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter

                            RotationAnimation on rotation {
                                running: translating
                                from: 0; to: 360
                                duration: 800
                                loops: Animation.Infinite
                            }
                        }
                        Text {
                            text: translating ? "Перевод..." : "Перевести"
                            color: translating ? col.font : col.fontDark
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    HoverHandler { id: translateBtnHover }
                    TapHandler {
                        enabled: !translating
                        onTapped: doTranslate(inputArea.text)
                    }
                }

                // Результат
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: mainRad - 3
                    color: col.backgroundAlt1
                    border.color: resultText !== "" ? Qt.rgba(col.accent.r, col.accent.g, col.accent.b, 0.3) : "transparent"
                    border.width: 1
                    visible: resultText !== "" || translating

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        Text {
                            text: "󰗊  " + toLang.toUpperCase()
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 11
                            opacity: 0.7
                        }

                        // Текст результата с прокруткой
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentHeight: resultLabel.implicitHeight
                            clip: true

                            Text {
                                id: resultLabel
                                width: parent.width
                                text: resultText
                                color: col.font
                                font.family: "Mononoki Nerd Font Propo"
                                font.pixelSize: 17
                                font.weight: Font.Bold
                                wrapMode: Text.WordWrap
                            }
                        }

                        RowLayout {
                            spacing: 6
                            Item { Layout.fillWidth: true }

                            // Копировать результат
                            Rectangle {
                                width: copyLabel.width + 16; height: 24
                                radius: mainRad - 5
                                color: copyHover.containsMouse ? col.backgroundAlt2 : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    Text {
                                        text: "󰆏"
                                        color: col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 12
                                        opacity: 0.6
                                    }
                                    Text {
                                        id: copyLabel
                                        text: "Копировать"
                                        color: col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 11
                                        opacity: 0.6
                                    }
                                }
                                HoverHandler { id: copyHover }
                                TapHandler {
                                    onTapped: Quickshell.execDetached([
                                        "sh", "-c",
                                        "echo " + JSON.stringify(resultText) + " | wl-copy"
                                    ])
                                }
                            }

                            // TTS результата
                            Rectangle {
                                width: ttsLabel.width + 16; height: 24
                                radius: mainRad - 5
                                color: ttsHover.containsMouse ? col.backgroundAlt2 : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    Text {
                                        text: "󰗗"
                                        color: col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 12
                                        opacity: 0.6
                                    }
                                    Text {
                                        id: ttsLabel
                                        text: "Читать"
                                        color: col.font
                                        font.family: "Mononoki Nerd Font Propo"
                                        font.pixelSize: 11
                                        opacity: 0.6
                                    }
                                }
                                HoverHandler { id: ttsHover }
                                TapHandler {
                                    onTapped: Quickshell.execDetached([
                                        "sh", "-c",
                                        "espeak-ng -v " + toLang + " " + JSON.stringify(resultText)
                                    ])
                                }
                            }
                        }
                    }
                }
            }

            // ── Режим: быстрые фразы ──────────────────────────────────────────
            GridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: mode === 1
                clip: true
                cellWidth:  (width - 6) / 2
                cellHeight: 56
                model: quickPhrases

                delegate: Rectangle {
                    width:  GridView.view.cellWidth - 6
                    height: GridView.view.cellHeight - 6
                    radius: mainRad - 3
                    color: phraseHover.containsMouse ? col.backgroundAlt2 : col.backgroundAlt1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: "󰗊"
                            color: col.accent
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 14
                            opacity: 0.6
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData
                            color: col.font
                            font.family: "Mononoki Nerd Font Propo"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    HoverHandler { id: phraseHover }
                    TapHandler {
                        onTapped: {
                            mode = 0
                            translator.inputText = modelData
                            doTranslate(modelData)
                        }
                    }
                }
            }

        }
    }
}
