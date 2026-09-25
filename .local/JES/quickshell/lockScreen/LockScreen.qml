import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

Scope {
    id: lockscreen

    // ── Public state ──────────────────────────────────────────────────
    property alias locked: sessionLock.locked
    property string password: ""
    property bool authenticating: false
    property bool authFailed: false
    property int failedAttempts: 0

    // Last input snapshot — the randomizer only fires when it actually changed.
    property string lastInput: ""

    // Discrete opacity ladder for the bar: 7 steps of 0.07, 0.58 … 1.00.
    // (For 0.1 steps use: 0.6 + Math.floor(Math.random() * 4) * 0.1.)
    property int opacityStep: 6

    function nextOpacity() {
        var next = Math.floor(Math.random() * 6)
        if (next >= opacityStep)
            next += 1
        opacityStep = next
        return 0.58 + next * 0.07
    }

    // How long the failure state (red bar + message) stays visible.
    property int failTimeout: 2000

    // The screen that gets the clock and the bar: the top-left (0,0)
    // monitor, falling back to the first screen.
    readonly property ShellScreen primaryScreen:
        Quickshell.screens.find(s => s.x === 0 && s.y === 0) ?? Quickshell.screens[0]

    signal unlocked()

    // ── Public API ────────────────────────────────────────────────────
    function lock() {
        sessionLock.locked = true
    }

    function unlock() {
        sessionLock.locked = false
    }

    function submitPassword() {
        if (authenticating || password.length === 0)
            return
        authenticating = true
        pam.start()
    }

    function clearPassword() {
        password = ""
    }

    // ── PAM ───────────────────────────────────────────────────────────
    // Uses /etc/pam.d/login — the system's own authentication stack,
    // i.e. the same password as your login manager / sudo.
    PamContext {
        id: pam
        configDirectory: "/etc/pam.d"
        config: "login"

        // NOTE: pamMessage carries no parameters. The pending message,
        // its flags and respond() all live on the PamContext itself.
        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(lockscreen.password)
        }

        onCompleted: result => {
            lockscreen.authenticating = false
            if (result === PamResult.Success) {
                lockscreen.unlock()
            } else {
                lockscreen.password = ""
                lockscreen.failedAttempts += 1
                lockscreen.authFailed = true
                bar.pulseAnim.start()
                failResetTimer.restart()
            }
        }
    }

    Timer {
        id: failResetTimer
        interval: lockscreen.failTimeout
        repeat: false
        onTriggered: lockscreen.authFailed = false
    }

    // ── Session lock ──────────────────────────────────────────────────
    // One lock surface is created per screen automatically.
    WlSessionLock {
        id: sessionLock

        WlSessionLockSurface {
            id: lockSurface

            Rectangle {
                anchors.fill: parent
                color: "#000000"

                // ── Hidden cursor ──
                // BlankCursor under everything; clicks refocus the input.
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.BlankCursor
                    onClicked: input.forceActiveFocus()
                }

                // ── Clock, bar and failure message: primary screen only ──
                // WlSessionLock clones this surface component onto every
                // screen automatically; this gate hides the content elsewhere.
                Item {
                    id: primaryContent
                    anchors.fill: parent
                    visible: lockSurface.screen === lockscreen.primaryScreen

                    // ── Clock ──
                    SystemClock {
                        id: clock
                        precision: SystemClock.Seconds
                    }

                    Text {
                        id: clockText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -40
                        renderType: Text.NativeRendering
                        width: parent.width / 3        // clock occupies 1/3 of the screen
                        fontSizeMode: Text.Fit         // font scales to fill that width
                        minimumPixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDateTime(clock.date, "HH:mm:ss")
                        font.family: fontFamily
                        font.pixelSize: 300            // upper bound for Text.Fit
                        color: col.font
                    }

                    // ── Bar under the clock ──
                    // Hidden until the first keystroke; opacity randomizes
                    // on every input change; pulses on keypresses.
                    Rectangle {
                        id: bar
                        anchors.horizontalCenter: clockText.horizontalCenter
                        anchors.top: clockText.bottom
                        anchors.topMargin: 10
                        width: clockText.width / 2
                        height: 8
                        radius: 4
                        transformOrigin: Item.Center

                        // Randomized per keystroke, 0.55 … 1.0.
                        property real fillOpacity: 1.0

                        opacity: lockscreen.authFailed ? 1
                               : lockscreen.password !== "" ? bar.fillOpacity
                               : 0
                        Behavior on opacity { NumberAnimation { duration: 200 * root.animations } }

                        color: lockscreen.authFailed ? base.base10 : col.accent
                        Behavior on color { ColorAnimation { duration: 400 * root.animations } }

                        // Kick on every keypress / failure.
                        NumberAnimation {
                            id: pulseAnim
                            target: bar
                            property: "scale"
                            from: 1.3
                            to: 1.0
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    // ── Failure message ──
                    Text {
                        anchors.top: bar.bottom
                        anchors.topMargin: 12
                        anchors.horizontalCenter: bar.horizontalCenter
                        visible: lockscreen.authFailed
                        opacity: lockscreen.authFailed ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 * root.animations } }
                        text: "Authentication failed (" + lockscreen.failedAttempts + ")"
                        font.family: fontFamily
                        font.pixelSize: 13
                        font.italic: true
                        color: col.accent
                    }

                }

                // ── Invisible full-screen password input ──
                TextInput {
                    id: input
                    anchors.fill: parent
                    focus: true
                    opacity: 0
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                    enabled: !lockscreen.authenticating

                    text: lockscreen.password
                    onTextChanged: {
                        if (text !== lockscreen.password)
                            lockscreen.password = text

                        // Randomize only when the input actually changed.
                        if (lockscreen.password === lockscreen.lastInput)
                            return

                        bar.fillOpacity = lockscreen.nextOpacity()
                        if (lockscreen.password !== "")
                            bar.pulseAnim.start()
                        lockscreen.lastInput = lockscreen.password
                    }
                    onAccepted: lockscreen.submitPassword()
                    Keys.onEscapePressed: lockscreen.clearPassword()
                }
            }
        }
    }

    // Notify the rest of the shell only on a REAL unlock, i.e. when the
    // compositor confirms the lock is gone.
    Connections {
        target: sessionLock
        function onLockedChanged() {
            if (!sessionLock.locked) {
                lockscreen.password = ""
                lockscreen.authFailed = false
                lockscreen.authenticating = false
                lockscreen.unlocked()
            }
        }
    }
}
