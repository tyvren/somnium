
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Components
import qs.Services
import qs.Themes

WlSessionLock {
    id: root
    locked: false

    required property LockContext context

    WlSessionLockSurface {
        id: surface
        color: Theme.colBg

        Process {
            id: restartProcess
            command: ["systemctl", "reboot"]
        }

        Process {
            id: shutdownProcess
            command: ["systemctl", "poweroff"]
        }

        Connections {
            target: root.context

            function onUnlocked() {
                if (!scene.unlocking) {
                    scene.unlocking = true
                    unlockAnimation.start()
                }
            }
        }

        SequentialAnimation {
            id: unlockAnimation

            NumberAnimation {
                target: scene
                property: "panelDrawProgress"
                to: 0
                duration: 120
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: scene
                property: "frameDrawProgress"
                to: 0
                duration: 150
                easing.type: Easing.InCubic
            }

            ParallelAnimation {
                NumberAnimation {
                    target: scene
                    property: "opacity"
                    to: 0
                    duration: 240
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: scene
                    property: "scale"
                    to: 1.04
                    duration: 240
                    easing.type: Easing.InCubic
                }
            }

            onFinished: root.locked = false
        }

        Item {
            id: scene
            anchors.fill: parent
            clip: true

            property bool introComplete: false
            property bool unlocking: false
            property real frameDrawProgress: 0
            property real panelDrawProgress: 0
            property real buildFlash: 0
            property real framePulse: 0

            Rectangle {
                anchors.fill: parent
                color: Theme.colBg
            }

            Image {
                id: wallpaper
                anchors.fill: parent
                source: Theme.wallpaperPath
                mipmap: true
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                scale: scene.introComplete ? 1.04 : 1.12
                opacity: scene.introComplete ? 0.72 : 0.25

                Behavior on scale {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MultiEffect {
                anchors.fill: wallpaper
                source: wallpaper
                brightness: -0.2
                contrast: -0.08
                saturation: -0.2
                blurEnabled: true
                blur: scene.introComplete ? 0.48 : 0.7
                blurMax: 64

                Behavior on blur {
                    NumberAnimation {
                        duration: 650
                        easing.type: Easing.OutCubic
                    }
                }
            }

            function buildTabbedContourPath(
                left: real,
                top: real,
                right: real,
                bottom: real,
                tabWidth: real,
                tabHeight: real,
                cornerRadius: real,
                bottomTab: bool,
                sideTabs: bool
            ): string {
                const contourWidth = right - left
                const contourHeight = bottom - top

                const horizontalCorner = Math.min(cornerRadius, contourWidth * 0.12)
                const verticalCorner = Math.min(cornerRadius, contourHeight * 0.12)

                const tabStart = left + (contourWidth - tabWidth) / 2
                const tabEnd = tabStart + tabWidth
                const tabCurveWidth = Math.min(32, tabWidth * 0.16)

                const topTabBottom = top + tabHeight
                const bottomTabTop = bottom - tabHeight

                const topShoulderControlY = top + tabHeight * 0.18
                const bottomShoulderControlY = bottom - tabHeight * 0.18

                const leftTabControlX = tabStart + tabCurveWidth * 0.6
                const rightTabControlX = tabEnd - tabCurveWidth * 0.6

                const sideTabLength = Math.min(150, contourHeight * 0.32)
                const sideTabDepth = Math.min(18, contourWidth * 0.045)

                const sideTabStart = top + (contourHeight - sideTabLength) / 2
                const sideTabEnd = sideTabStart + sideTabLength
                const sideCurveHeight = Math.min(28, sideTabLength * 0.18)

                const sideTopControlY = sideTabStart + sideCurveHeight * 0.6
                const sideBottomControlY = sideTabEnd - sideCurveHeight * 0.6

                const path = [
                    buildTopEdge(),
                    buildRightSide(),
                    buildBottomEdge(),
                    buildLeftSide()
                ]

                function buildTopEdge(): string {
                    return [
                        `M ${left + horizontalCorner} ${top}`,
                        `L ${tabStart} ${top}`,
                        `C ${leftTabControlX} ${topShoulderControlY} ${leftTabControlX} ${topTabBottom} ${tabStart + tabCurveWidth} ${topTabBottom}`,
                        `L ${tabEnd - tabCurveWidth} ${topTabBottom}`,
                        `C ${rightTabControlX} ${topTabBottom} ${rightTabControlX} ${topShoulderControlY} ${tabEnd} ${top}`,
                        `L ${right - horizontalCorner} ${top}`,
                        `C ${right - horizontalCorner * 0.35} ${top} ${right} ${top + verticalCorner * 0.35} ${right} ${top + verticalCorner}`
                    ].join(" ")
                }

                function buildRightSide(): string {
                    let commands = []

                    if (sideTabs) {
                        commands.push(
                            `L ${right} ${sideTabStart}`,
                            `C ${right - sideTabDepth * 0.15} ${sideTopControlY} ${right - sideTabDepth} ${sideTopControlY} ${right - sideTabDepth} ${sideTabStart + sideCurveHeight}`,
                            `L ${right - sideTabDepth} ${sideTabEnd - sideCurveHeight}`,
                            `C ${right - sideTabDepth} ${sideBottomControlY} ${right - sideTabDepth * 0.15} ${sideBottomControlY} ${right} ${sideTabEnd}`
                        )
                    }

                    commands.push(
                        `L ${right} ${bottom - verticalCorner}`,
                        `C ${right} ${bottom - verticalCorner * 0.35} ${right - horizontalCorner * 0.35} ${bottom} ${right - horizontalCorner} ${bottom}`
                    )

                    return commands.join(" ")
                }

                function buildBottomEdge(): string {
                    if (bottomTab) {
                        return [
                            `L ${tabEnd} ${bottom}`,
                            `C ${rightTabControlX} ${bottomShoulderControlY} ${rightTabControlX} ${bottomTabTop} ${tabEnd - tabCurveWidth} ${bottomTabTop}`,
                            `L ${tabStart + tabCurveWidth} ${bottomTabTop}`,
                            `C ${leftTabControlX} ${bottomTabTop} ${leftTabControlX} ${bottomShoulderControlY} ${tabStart} ${bottom}`
                        ].join(" ")
                    }

                    return `L ${left + horizontalCorner} ${bottom}`
                }

                function buildLeftSide(): string {
                    let commands = [
                        `L ${left + horizontalCorner} ${bottom}`,
                        `C ${left + horizontalCorner * 0.35} ${bottom} ${left} ${bottom - verticalCorner * 0.35} ${left} ${bottom - verticalCorner}`
                    ]

                    if (sideTabs) {
                        commands.push(
                            `L ${left} ${sideTabEnd}`,
                            `C ${left + sideTabDepth * 0.15} ${sideBottomControlY} ${left + sideTabDepth} ${sideBottomControlY} ${left + sideTabDepth} ${sideTabEnd - sideCurveHeight}`,
                            `L ${left + sideTabDepth} ${sideTabStart + sideCurveHeight}`,
                            `C ${left + sideTabDepth} ${sideTopControlY} ${left + sideTabDepth * 0.15} ${sideTopControlY} ${left} ${sideTabStart}`
                        )
                    }

                    commands.push(
                        `L ${left} ${top + verticalCorner}`,
                        `C ${left} ${top + verticalCorner * 0.35} ${left + horizontalCorner * 0.35} ${top} ${left + horizontalCorner} ${top}`,
                        "Z"
                    )

                    return commands.join(" ")
                }

                return path.join(" ")
            }

            Shape {
                id: frameShape
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeWidth: Math.max(1, Config.data.borderSize || 1) * (1 + scene.buildFlash * 0.7)
                    strokeColor: Qt.tint(Theme.colAccent, Qt.rgba(1, 1, 1, scene.buildFlash * 0.8))
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    strokeStyle: ShapePath.DashLine
                    dashPattern: [
                        Math.max(0.01, scene.frameDrawProgress * 4000 / Math.max(1, Config.data.borderSize || 1)),
                        Math.max(0.01, (1 - scene.frameDrawProgress) * 8000 / Math.max(1, Config.data.borderSize || 1))
                    ]
                    dashOffset: -scene.framePulse * 120

                    PathSvg {
                        path: scene.buildTabbedContourPath(
                            dialogStage.x - 30,
                            dialogStage.y - 24,
                            dialogStage.x + dialogStage.width + 30,
                            dialogStage.y + dialogStage.height + 24,
                            Math.min(190, dialogStage.width * 0.48),
                            20,
                            34,
                            false,
                            true
                        )
                    }
                }
            }

            MultiEffect {
                anchors.fill: frameShape
                source: frameShape
                shadowEnabled: true
                shadowColor: Theme.colAccent
                shadowBlur: 0.9
                shadowOpacity: 0.15 + scene.buildFlash * 0.85
                shadowScale: 1.02
            }

            Row {
                id: leftFrameTab
                x: scene.introComplete ? dialogStage.x + dialogStage.width * 0.25 - width : dialogStage.x - width - 40
                y: dialogStage.y - 22
                spacing: 6
                opacity: scene.introComplete ? 1 : 0

                Behavior on x {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.65
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colAccent
                }

                Rectangle {
                    width: 36
                    height: 2
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colAccent
                }
            }

            Row {
                id: rightFrameTab
                x: scene.introComplete ? dialogStage.x + dialogStage.width * 0.75 : dialogStage.x + dialogStage.width + 40
                y: dialogStage.y - 22
                spacing: 6
                opacity: scene.introComplete ? 1 : 0

                Behavior on x {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.65
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    width: 36
                    height: 2
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colAccent
                }

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colAccent
                }
            }

            ColumnLayout {
                id: clockBlock
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: Math.max(32, parent.width * 0.055)
                anchors.topMargin: Math.max(30, parent.height * 0.055)
                spacing: 8
                opacity: scene.introComplete ? 1 : 0
                y: scene.introComplete ? 0 : -18

                Behavior on opacity {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.3
                    }
                }

                Clock {
                    id: lockScreenClock
                    textSize: 52
                    orientation: "horizontal"
                }

                Rectangle {
                    id: clockDivider
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 3
                    radius: 2
                    color: Theme.colAccent
                }

                Text {
                    text: Qt.formatDate(new Date(), "dddd, MMMM d")
                    color: Theme.colText
                    opacity: 0.8
                    font.pixelSize: 22
                }
            }

            Item {
                id: dialogStage
                anchors.centerIn: parent
                width: Math.min(500, parent.width - 40)
                height: Math.min(560, parent.height - 60)
                opacity: 1
                scale: 1
                y: 0

                Rectangle {
                    id: dialogContainer
                    anchors.fill: parent
                    radius: Config.data.rounding
                    color: "transparent"
                }

                MultiEffect {
                    anchors.fill: dialogContainer
                    source: dialogContainer
                    shadowEnabled: true
                    shadowBlur: 0.8
                    shadowColor: Qt.alpha(Theme.colAccent, 0.45)
                    shadowVerticalOffset: 12
                    shadowHorizontalOffset: 0
                }

                Shape {
                    id: loginPanelContour
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeWidth: Math.max(1, Config.data.borderSize || 1) * (1 + scene.buildFlash * 0.35)
                        strokeColor: Qt.tint(Theme.colAccent, Qt.rgba(1, 1, 1, scene.buildFlash * 0.65))
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        strokeStyle: ShapePath.DashLine
                        dashPattern: [
                            Math.max(0.01, scene.panelDrawProgress * 4000 / Math.max(1, Config.data.borderSize || 1)),
                            Math.max(0.01, (1 - scene.panelDrawProgress) * 8000 / Math.max(1, Config.data.borderSize || 1))
                        ]
                        dashOffset: -scene.framePulse * 80

                        PathSvg {
                            path: scene.buildTabbedContourPath(
                                1,
                                1,
                                loginPanelContour.width - 1,
                                loginPanelContour.height - 1,
                                Math.min(170, loginPanelContour.width * 0.42),
                                18,
                                Config.data.rounding + 8,
                                false,
                                true
                            )
                        }
                    }
                }

                MultiEffect {
                    anchors.fill: loginPanelContour
                    source: loginPanelContour
                    shadowEnabled: true
                    shadowColor: Theme.colAccent
                    shadowBlur: 0.65
                    shadowOpacity: 0.1 + scene.buildFlash * 0.65
                    shadowScale: 1.01
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 28
                    anchors.rightMargin: 28
                    anchors.topMargin: 30
                    anchors.bottomMargin: 24
                    spacing: 14
                    opacity: scene.introComplete ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 240
                            easing.type: Easing.OutCubic
                        }
                    }

                    StyledClippingRect {
                        id: userIconBox
                        Layout.preferredWidth: 112
                        Layout.preferredHeight: 112
                        Layout.alignment: Qt.AlignHCenter
                        radius: Config.data.rounding + 4
                        border.width: 2
                        border.color: Theme.colAccent
                        scale: scene.introComplete ? 1 : 0.7
                        opacity: scene.introComplete ? 1 : 0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 320
                                easing.type: Easing.OutBack
                                easing.overshoot: 0.55
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Image {
                            anchors.fill: parent
                            source: Quickshell.env("HOME") + "/.face"
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 512
                            sourceSize.height: 512
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Quickshell.env("USER") || Quickshell.env("USERNAME") || "User"
                        color: Theme.colText
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.preferredHeight: 4
                    }

                    StyledInput {
                        id: passwordBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        echoMode: TextInput.Password
                        placeholderText: "Enter password"
                        placeholderTextColor: Qt.alpha(Theme.colText, 0.45)
                        font.pointSize: 14
                        inputMethodHints: Qt.ImhSensitiveData
                        text: root.context.currentText

                        onTextChanged: {
                            if (root.context.currentText !== text)
                                root.context.currentText = text
                        }

                        onAccepted: root.context.tryUnlock()
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        StyledButton {
                            id: unlockButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            focusPolicy: Qt.NoFocus
                            icon: "󰌾"
                            iconSize: 17
                            color: "transparent"
                            text: "Unlock"
                            enabled: root.context.currentText !== ""
                            onClicked: root.context.tryUnlock()
                        }

                        StyledButton {
                            id: fingerprintButton
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 42
                            focus: true
                            icon: "󰈷"
                            iconSize: 18
                            color: "transparent"
                            onClicked: root.context.tryFingerprintUnlock()
                            onActiveFocusChanged: {
                                if (activeFocus)
                                    root.context.tryFingerprintUnlock()
                            }
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Enter password or touch to unlock"
                        opacity: 0.45
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.minimumHeight: 4
                    }

                    DividerLine {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 28

                        StyledButton {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 42
                            text: ""
                            icon: "󰜉"
                            iconSize: 22
                            color: "transparent"
                            borderColor: "transparent"
                            onClicked: restartProcess.startDetached()
                        }

                        StyledButton {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 42
                            text: ""
                            icon: "󰐥"
                            iconSize: 22
                            color: "transparent"
                            borderColor: "transparent"
                            onClicked: shutdownProcess.startDetached()
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 26
                spacing: 8
                opacity: scene.introComplete ? 0.65 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    width: 5
                    height: 5
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colAccent
                }
            }

            SequentialAnimation {
                running: true

                ScriptAction {
                    script: scene.introComplete = true
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: scene
                        property: "frameDrawProgress"
                        from: 0
                        to: 1
                        duration: 520
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: scene
                        property: "panelDrawProgress"
                        from: 0
                        to: 1
                        duration: 460
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: scene
                        property: "framePulse"
                        from: 0
                        to: 12
                        duration: 520
                        easing.type: Easing.OutCubic
                    }

                    SequentialAnimation {
                        NumberAnimation {
                            target: scene
                            property: "buildFlash"
                            from: 0
                            to: 1
                            duration: 130
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            target: scene
                            property: "buildFlash"
                            to: 0.25
                            duration: 220
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            target: scene
                            property: "buildFlash"
                            to: 0
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Timer {
                interval: 650
                running: true
                repeat: false
                onTriggered: passwordBox.forceActiveFocus()
            }
        }
    }
}
