import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
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
    locked: true

    required property LockContext context

    Process { id: restartProcess; command: ["systemctl", "reboot"] }
    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }

    WlSessionLockSurface {
        id: surface

        Rectangle {
            anchors.fill: parent
            color: Theme.colBg

            Image {
                id: wallpaper
                anchors.fill: parent
                source: Theme.wallpaperPath
                mipmap: true
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
            }

            MultiEffect {
                anchors.fill: wallpaper
                source: wallpaper
                brightness: -0.1
                contrast: -0.1
            }

            MultiEffect {
                anchors.fill: dialogContainer
                source: dialogContainer
                shadowEnabled: true
                shadowBlur: 0.4
                shadowColor: Theme.colAccent
                shadowVerticalOffset: 1
                shadowHorizontalOffset: 1
            }

            Rectangle {
                id: dialogContainer
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 150
                anchors.horizontalCenter: parent.horizontalCenter
                width: 440
                height: 380
                color: Theme.colBg
                border.color: root.context.showFailure ? Theme.colHilight : Theme.colAccent
                border.width: Config.data.borderSize
                radius: Config.data.rounding

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 16

                    Clock {
                        id: lockScreenClock
                        Layout.alignment: Qt.AlignHCenter
                        textSize: 40
                        orientation: "horizontal"
                    }

                    StyledInput {
                        id: passwordBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        Layout.alignment: Qt.AlignHCenter
                        echoMode: TextInput.Password
                        placeholderText: "Enter password"
                        placeholderTextColor: Theme.colMuted
                        font.pointSize: 14
                        inputMethodHints: Qt.ImhSensitiveData
                        text: root.context.currentText

                        onTextChanged: {
                            if (root.context.currentText !== text) {
                                root.context.currentText = text
                            }
                        }

                        onAccepted: root.context.tryUnlock()
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        StyledButton {
                            id: unlockButton
                            focusPolicy: Qt.NoFocus
                            text: "Unlock"
                            icon: "󰌾"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            enabled: root.context.currentText !== ""
                            onClicked: root.context.tryUnlock()
                        }

                        StyledButton {
                            id: fingerprintButton
                            focus: true
                            icon: "󰈷"
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            onActiveFocusChanged: root.context.tryFingerprintUnlock()
                            onClicked: root.context.tryFingerprintUnlock()
                        }
                    }

                    DividerLine {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        StyledButton {
                            text: "Restart"
                            icon: "󰜉"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            onClicked: restartProcess.startDetached()
                        }

                        StyledButton {
                            text: "Shutdown"
                            icon: "󰐥"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            onClicked: shutdownProcess.startDetached()
                        }
                    }
                }
            }
        }
    }
}
