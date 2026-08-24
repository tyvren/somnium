import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Components
import qs.Modules.Menus
import qs.Modules.OSD
import qs.Themes
import qs.Services

Variants {
    model: Quickshell.screens
    delegate: Component {
        Item {
            id: root
            required property var modelData

            PanelWindow {
                id: topBar
                screen: modelData
                color: "transparent"
                visible: Config.data.barLayout === "top"
                implicitHeight: 32
                anchors {
                    top: true
                    left: true
                    right: true
                }
                margins.top: 2
                margins.left: 2
                margins.right: 2

                Rectangle {
                    id: topLeftBar
                    width: topBar.width / 2 - 250
                    height: topBar.height - 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Config.data.rounding
                    color: Theme.colBg
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize 
                }
                
                Rectangle {
                    id: topRightBar
                    x: topBar.width / 2 + 250
                    width: topBar.width / 2 - 250
                    height: topBar.height - 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Config.data.rounding
                    color: Theme.colBg
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize
                }

                Item {
                    id: topBarContent
                    anchors.fill: parent

                    MediaPlayer {
                        id: mediaOSDTop
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
    
                    BrightnessOSD {
                        id: brightnessOSD
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    NotificationOSD {
                        id: notificationOSD
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    TimeDateOSD {
                        id: timeDate
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    VolumeOSD {
                        id: volumeOSD
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MainMenuBtn {
                        id: mainMenuButtonTop
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Workspaces {
                        id: workspacesButtonTop
                        anchors.left: parent.left
                        anchors.leftMargin: 60
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SystemTrayApps {
                        id: systemTrayAppsTop
                        anchors.right: parent.right
                        anchors.rightMargin: batteryBtnTop.visible ? 190 : 130
                        anchors.verticalCenter: parent.verticalCenter 
                    }

                    BatteryBtn {
                        id: batteryBtnTop
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 130
                    }

                    AudioBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 100
                    }

                    BluetoothBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 70
                    }

                    NetworkBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 40
                    }

                    SidePaneBtn {
                       anchors.right: parent.right
                       anchors.verticalCenter: parent.verticalCenter
                       anchors.rightMargin: 10
                    }
                }
            } 

            PanelWindow {
                id: bottomBar
                screen: modelData
                color: "transparent"
                visible: Config.data.barLayout === "bottom"
                implicitHeight: 32
                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                margins.bottom: 2
                margins.left: 2
                margins.right: 2

                Rectangle {
                    id: bottomLeftBar
                    width: bottomBar.width / 2 - 250
                    height: bottomBar.height - 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Config.data.rounding
                    color: Theme.colBg
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize
                }

                Rectangle {
                    id: bottomRightBar
                    x: bottomBar.width / 2 + 250
                    width: bottomBar.width / 2 - 250
                    height: bottomBar.height - 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Config.data.rounding
                    color: Theme.colBg
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize
                }

                Item {
                    id: bottomBarContent
                    anchors.fill: parent

                    MediaPlayer {
                        id: mediaOSDBottom
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    BrightnessOSD {
                        id: brightnessOSDbottom
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    NotificationOSD {
                        id: notificationOSDBottom
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    TimeDateOSD {
                        id: timeDateBottom
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    VolumeOSD {
                        id: volumeOSDBottom
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MainMenuBtn {
                        id: mainMenuButtonBottom
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Workspaces {
                        id: workspacesButtonBottom
                        anchors.left: parent.left
                        anchors.leftMargin: 60
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SystemTrayApps {
                        id: systemTrayAppsBottom
                        anchors.right: parent.right
                        anchors.rightMargin: batteryBtnBottom.visible ? 190 : 130
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    BatteryBtn {
                        id: batteryBtnBottom
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 130
                    }

                    AudioBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 100
                    }

                    BluetoothBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 70
                    }

                    NetworkBtn {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 40
                    }

                    SidePaneBtn {
                       anchors.right: parent.right
                       anchors.verticalCenter: parent.verticalCenter
                       anchors.rightMargin: 10
                    }
                }
            }
        }
    }
}
