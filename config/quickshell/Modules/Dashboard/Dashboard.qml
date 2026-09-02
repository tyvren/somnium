import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Components
import qs.Modules.Menus.Settings
import qs.Services
import qs.Themes

Variants {
    model: Quickshell.screens
    delegate: Component {
        Item {
            id: root
            required property var modelData

            PanelWindow {
                id: dashboard
                screen: root.modelData
                focusable: true
                implicitWidth: dashboard.containerWidth
                implicitHeight: dashboard.containerHeight 
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                mask: Region { item: dashboardBackground }

                property int containerWidth: 480
                property int containerHeight: 400
                property int closedHeight: 28
                property int openHeight: 400

                property string currentView: "calendar"

                anchors {
                    top: Config.data.barLayout === "top" 
                    bottom: Config.data.barLayout === "bottom"
                }

                margins {
                    top: Config.data.barLayout === "top" ? 4 : 0
                    bottom: Config.data.barLayout === "bottom" ? 4 : 0
                }

                Connections {
                    target: States
                    function onDashboardOpenChanged() {
                        if (!States.dashboardOpen) {
                            dashboard.currentView = "calendar"
                        }
                    }
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [dashboard]
                    onCleared: {
                        States.dashboardOpen = false
                    }
                }

                onCurrentViewChanged: {
                    if (States.dashboardOpen) {
                        focusGrab.active = true
                    } else {
                        focusGrab.active = false
                    }
                } 

                IpcHandler {
                    target: "dashboard"

                    function openAudio(): void {
                        States.dashboardOpen = true
                        dashboard.currentView = "audio"
                    }

                    function openBluetooth(): void {
                        States.dashboardOpen = true
                        dashboard.currentView = "bluetooth"
                    }

                    function openLauncher(): void {
                        States.dashboardOpen = true
                        dashboard.currentView = "launcher"
                    }

                    function openNetwork(): void {
                        States.dashboardOpen = true
                        dashboard.currentView = "network"
                    }
                }

                Rectangle {
                    id: dashboardBackground
                    width: dashboard.containerWidth
                    height: States.dashboardOpen ? dashboard.openHeight : dashboard.closedHeight 
                    y: Config.data.barLayout === "bottom" ? dashboard.containerHeight - height : 0
                    radius: Config.data.rounding
                    color: Theme.colBg
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize

                    Keys.onEscapePressed: States.dashboardOpen = false

                    MouseArea {
                        id: dashboardMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!States.dashboardOpen && States.timeDateVisible) {
                                States.dashboardOpen = true
                                focusGrab.active = true
                            }
                        } 
                    }

                    Clock {
                        id: clock
                        anchors.centerIn: parent
                        anchors.top: parent
                        orientation: "horizontalFull"
                        opacity: States.timeDateVisible && !States.dashboardOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    BrightnessOSD {
                        id: brightnessOSD
                        opacity: States.brightnessOSDOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    MediaPlayer {
                        id: media
                        opacity: !States.dashboardOpen && States.mediaPlayerOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }
                    
                    NotificationOSD {
                        id: notificationOSD
                        opacity: States.notificationOSDOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    VolumeOSD {
                        id: volumeOSD
                        opacity: States.volumeOSDOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Rectangle {
                        id: dashHomeScreen
                        anchors.fill: parent
                        color: "transparent"
                        opacity: States.dashboardOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.InOutCubic
                            }
                        }

                        Component {
                            id: calendar
                            Calendar {}
                        }

                        Component {
                            id: bluetoothView
                            BluetoothSettings {}
                        }

                        Component {
                            id: launcherView
                            Launcher {}
                        }

                        Component {
                            id: networkView
                            NetworkSettings {}
                        }

                        Component {
                            id: audioView
                            AudioSettings {}
                        }

                        Loader {
                            id: viewLoader
                            anchors.fill: parent
                            anchors.margins: dashboard.currentView === "bluetooth" || dashboard.currentView === "network" ? 10 : 0
                            active: States.dashboardOpen

                            sourceComponent: {
                                switch (dashboard.currentView) {
                                    case "audio": return audioView
                                    case "bluetooth": return bluetoothView 
                                    case "calendar": return calendar
                                    case "launcher": return launcherView
                                    case "network": return networkView
                                    default: return timeDateView
                                }
                            }
                        }
                    }

                    state: States.dashboardOpen ? "open" : "closed"

                    states: [
                        State {
                            name: "closed"
                            PropertyChanges {
                                target: dashboardBackground
                                height: dashboard.closedHeight
                            }
                        },
                        State {
                            name: "open"
                            PropertyChanges {
                                target: dashboardBackground
                                height: dashboard.openHeight
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: "closed"
                            to: "open"
                            
                            NumberAnimation {
                                properties: "height"
                                duration: 250
                                easing.type: Easing.InOutCubic
                            }
                        },
                        Transition {
                            from: "open"
                            to: "closed"

                            NumberAnimation {
                                properties: "height"
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }
                    ]
                }
            }
        }
    }
}
