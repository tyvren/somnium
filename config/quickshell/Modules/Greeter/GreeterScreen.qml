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

Item {
    id: root

    Process { id: restartProcess; command: ["systemctl", "reboot"] }
    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }

    FloatingWindow {
        id: surface
        width: 1920
        height: 1200

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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: 800
                height: 650
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
                        orientation: "horizontalFull"
                    }

                    StyledRect {
                        id: userIconBox
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100
                        Layout.alignment: Qt.AlignHCenter

                        Image {
                            id: userIcon
                            anchors.fill: parent
                            source: Quickshell.env("HOME") + "/.face"
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 1920
                            sourceSize.height: 1080
                        }
                    }

                    StyledInput {
                        id: passwordBox
                        Layout.preferredWidth: 300
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
                            id: sessionDropdown
                            focusPolicy: Qt.NoFocus
                            text: "Session:"
                            icon: ""
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                        }

                        StyledButton {
                            id: unlockButton
                            focusPolicy: Qt.NoFocus
                            text: "Log In"
                            icon: "󰌾"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
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
