import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Components
import qs.Themes
import qs.Services

Scope {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bar
                required property var modelData
                screen: modelData
                color: "transparent"
                implicitHeight: 30

                property bool monitorFocused: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === screen.name

                anchors {
                    top: Config.data.barLayout === "top" 
                    bottom: Config.data.barLayout === "bottom"
                    left: true
                    right: true
                }

                margins.left: 2
                margins.right: 2

                Rectangle {
                    id: leftBar
                    width: bar.width / 2 - 350
                    height: bar.height - 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Config.data.rounding
                    color: "transparent"
                    border.color: "transparent" 
                }

                Rectangle {
                    id: rightBar
                    x: bar.width / 2 + 350
                    width: bar.width / 2 - 350
                    height: bar.height - 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Config.data.rounding
                    color: "transparent" 
                    border.color: "transparent" 
                }

                Item {
                    id: barContent
                    anchors.fill: parent

                    MainMenuBtn {
                        id: mainMenuButtonTop
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QuickMenuBtns {
                        id: quickMenuButtons
                        anchors.left: parent.left
                        anchors.leftMargin: 60
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: States.mainMenuOpen && bar.monitorFocused ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutCubic
                            }
                        }
                          
                        Timer {
                            id: menuTimer
                            running: States.mainMenuOpen
                            interval: 5000
                            onTriggered: States.mainMenuOpen = false
                        }
              
                        HoverHandler {
                            id: quickMenuHH
                            onHoveredChanged: {
                                if (hovered) {
                                    menuTimer.running = false
                                } else {
                                    menuTimer.running = true
                                }
                            }
                        }
                    }

                    Workspaces {
                        id: workspacesButtonTop
                        anchors.left: parent.left
                        anchors.leftMargin: (States.mainMenuOpen && bar.monitorFocused) ? 210 : 60
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    SystemTrayApps {
                        id: systemTrayAppsTop
                        anchors.right: parent.right
                        anchors.rightMargin: batteryBtnTop.visible ? 165 : 100
                        anchors.verticalCenter: parent.verticalCenter 
                    }

                    BatteryBtn {
                        id: batteryBtnTop
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 100
                    }

                    AudioBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 70
                    }

                    BluetoothBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 40
                    }

                    NetworkBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                    }
                }
            } 
        }
    }
}
