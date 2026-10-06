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
    locked: false

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
                blurEnabled: true
                blur: 0.5
                blurMax: 64
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

            Clock {
                id: lockScreenClock
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 40
                anchors.leftMargin: 40
                textSize: 40
                orientation: "horizontalFull"
            }

            Rectangle {
                id: dialogContainer
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.15
                anchors.horizontalCenter: parent.horizontalCenter
                height: parent.height * 0.35
                width: parent.width * 0.25
                color: "transparent"
                radius: Config.data.rounding

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20

                    StyledClippingRect {
                        id: userIconBox
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 120
                        Layout.alignment: Qt.AlignHCenter
                        border.color: Theme.colAccent
                        radius: Config.data.rounding
 
                        Image {
                            id: userIcon
                            anchors.fill: parent
                            source: Quickshell.env("HOME") + "/.face"
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 1920
                            sourceSize.height: 1080
                        }
                    }

                    StyledInput {
                        id: passwordBox
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignHCenter
                        echoMode: TextInput.Password
                        placeholderText: "Enter password"
                        placeholderTextColor: Qt.alpha(Theme.colBg, 0.50)
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
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        spacing: 12

                        StyledButton {
                            id: unlockButton
                            focusPolicy: Qt.NoFocus
                            icon: "󰌾"
                            iconSize: 16
                            Layout.preferredWidth: 105
                            Layout.preferredHeight: 35

                            enabled: root.context.currentText !== ""
                            onClicked: root.context.tryUnlock()
                        }

                        StyledButton {
                            id: fingerprintButton
                            focus: true
                            icon: "󰈷"
                            iconSize: 16
                            Layout.preferredWidth: 35
                            Layout.preferredHeight: 35

                            onActiveFocusChanged: root.context.tryFingerprintUnlock()
                            onClicked: root.context.tryFingerprintUnlock()
                        }
                    }

                    DividerLine {
                        Layout.preferredWidth: parent.width * 0.5
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 50

                        StyledButton {
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 45
                            text: ""
                            icon: "󰜉"
                            iconSize: 24
                            color: "transparent"
                            borderColor: "transparent"
                            onClicked: restartProcess.startDetached()
                        }

                        StyledButton {
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 45
                            text: ""
                            icon: "󰐥"
                            iconSize: 24
                            color: "transparent"
                            borderColor: "transparent"
                            onClicked: shutdownProcess.startDetached()
                        }
                    }
                }
            }
        }
    }
}
