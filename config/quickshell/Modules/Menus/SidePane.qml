import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Components
import qs.Services
import qs.Themes

PanelWindow {
    id: sidePane
    visible: false
    focusable: true
    color: "transparent"
    anchors.top: true
    anchors.bottom: true
    anchors.right: true
    implicitWidth: 350
    margins.right: 10
    margins.top: 35
    margins.bottom: 35

    exclusionMode: ExclusionMode.Ignore

    HyprlandFocusGrab {
        id: focusGrab
        windows: [sidePane]
        onCleared: sidePane.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(() => paneRoot.forceActiveFocus())
            focusGrab.active = true
        } else {
            focusGrab.active = false
        }
    }

    Rectangle {
        id: paneRoot
        anchors.fill: parent
        color: Theme.colBg
        radius: Config.data.rounding
        border.color: Theme.colAccent
        border.width: Config.data.borderSize

        Keys.onEscapePressed: sidePane.visible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Rectangle {
                Layout.fillWidth: true
                height: controlsColumn.implicitHeight + 24
                color: Theme.colMuted
                radius: Config.data.rounding

                ColumnLayout {
                    id: controlsColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 14
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        StyledText {
                            text: {
                                const b = Brightness.brightness
                                if (b < 0.25) return "󰃞"
                                if (b < 0.6)  return "󰃟"
                                return "󰃠"
                            }
                            color: Theme.colAccent
                            size: 13
                        }

                        Item {
                            Layout.fillWidth: true
                            height: 20

                            Rectangle {
                                id: trackBg
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 5
                                radius: Config.data.rounding
                                color: Qt.rgba(1, 1, 1, 0.12)
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: trackBg.left
                                width: trackBg.width * Brightness.brightness
                                height: 5
                                radius: Config.data.rounding
                                color: Theme.colAccent

                                Behavior on width {
                                    NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                                }
                            }

                            Rectangle {
                                id: thumb
                                anchors.verticalCenter: parent.verticalCenter
                                x: (trackBg.width * Brightness.brightness) - (width / 2)
                                width: 14
                                height: 14
                                radius: Config.data.rounding
                                color: Theme.colAccent
                                border.color: Theme.colBg
                                border.width: Config.data.borderSize

                                Behavior on x {
                                    NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                                }
                            }

                            MouseArea {
                                anchors.fill: trackBg
                                anchors.margins: -8
                                hoverEnabled: true
                                preventStealing: true

                                function updateBrightness(mouse) {
                                    const val = Math.max(0, Math.min(1, mouse.x / trackBg.width))
                                    Brightness.setBrightness(val)
                                }

                                onPressed: (mouse) => updateBrightness(mouse)
                                onPositionChanged: (mouse) => {
                                    if (pressed) updateBrightness(mouse)
                                }
                            }
                        }

                        StyledText {
                            text: Math.round(Brightness.brightness * 100) + "%"
                            color: Theme.colAccent
                            size: 9
                            opacity: 0.75
                            horizontalAlignment: Text.AlignRight
                            Layout.minimumWidth: 32
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                StyledButton {
                    id: powerSave
                    Layout.preferredHeight: 45
                    Layout.fillWidth: true
                    visible: true
                    icon: "󰌪"
                    text: "Power Saving"
                    textSize: 8

                    Process { id: powerSaveNotification; command: ["notify-send", "Power Save Mode Enabled"] }

                    onClicked: {
                        PowerProfiles.setPowerSaver();
                        powerSaveNotification.startDetached(); 
                    }
                  } 

                StyledButton {
                    id: balanced
                    Layout.preferredHeight: 45
                    Layout.fillWidth: true
                    visible: true 
                    icon: "󰗑"
                    text: "Balanced"
                    textSize: 8

                    Process { id: balancedNotification; command: ["notify-send", "Balanced Mode Enabled"] }

                    onClicked: {
                        PowerProfiles.setBalanced();
                        balancedNotification.startDetached(); 
                    }
                  }

                StyledButton {
                    id: performance
                    Layout.preferredHeight: 45
                    Layout.fillWidth: true
                    visible: true
                    icon: "󰊚"
                    text: "Performance"
                    textSize: 8

                    Process { id: performanceNotification; command: ["notify-send", "Performance Mode Enabled"] }

                    onClicked: {
                        PowerProfiles.setPerformance();
                        performanceNotification.startDetached(); 
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: "Notifications"
                    color: Theme.colAccent
                    size: 11
                    bold: true
                }

                Item { Layout.fillWidth: true }

                StyledButton {
                    text: "Clear All"
                    textSize: 9
                    implicitWidth: 80
                    implicitHeight: 30
                    onClicked: Notifications.clearAll()
                }
            }

            DividerLine {
                Layout.fillWidth: true
            }

            ListView {
                id: notifList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: Notifications.notifications
                spacing: 12
                clip: true

                delegate: Item {
                    id: notifDelegate
                    width: notifList.width
                    height: contentLayout.implicitHeight + 30

                    StyledButton {
                        anchors.fill: parent

                        ColumnLayout {
                            id: contentLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 15
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Image {
                                    source: modelData.appIcon !== "" ? Quickshell.iconPath(modelData.appIcon, true) : ""
                                    sourceSize.width: 18
                                    sourceSize.height: 18
                                    Layout.maximumWidth: 18
                                    Layout.maximumHeight: 18
                                    visible: modelData.appIcon !== ""
                                    fillMode: Image.PreserveAspectFit
                                }

                                StyledText {
                                    text: modelData.summary
                                    bold: true
                                    size: 11
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    id: dismissBox
                                    Layout.preferredWidth: 15
                                    Layout.preferredHeight: 15
                                    radius: Config.data.rounding
                                    color: Theme.colBg
                                    border.color: dismissMa.containsMouse ? Theme.colAccent : Theme.colMuted
                                    border.width: Config.data.borderSize

                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "" 
                                        size: 7
                                        color: dismissMa.containsMouse ? Theme.colAccent : Theme.colText

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    MouseArea {
                                        id: dismissMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: modelData.dismiss()
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Image {
                                    source: modelData.image !== "" ? modelData.image : ""
                                    sourceSize.width: 45
                                    sourceSize.height: 45
                                    Layout.maximumWidth: 45
                                    Layout.maximumHeight: 45
                                    Layout.alignment: Qt.AlignTop
                                    visible: modelData.image !== ""
                                    fillMode: Image.PreserveAspectFit
                                }

                                StyledText {
                                    text: modelData.body
                                    size: 10
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    opacity: 0.85
                                    visible: text !== ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
