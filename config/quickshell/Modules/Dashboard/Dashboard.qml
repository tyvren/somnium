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

Scope {
    IpcHandler {
        target: "dashboard"

        function openAudio(): void {
            States.dashboardOpen = true
            States.currentView = "audio"
        }

        function openBluetooth(): void {
            States.dashboardOpen = true
            States.currentView = "bluetooth"
        }

        function openLauncher(): void {
            States.dashboardOpen = true
            States.currentView = "launcher"
        }

        function openNetwork(): void {
            States.dashboardOpen = true
            States.currentView = "network"
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: dashboard
                required property var modelData
                screen: modelData
                focusable: true
                implicitWidth: dashboard.containerWidth
                implicitHeight: dashboard.containerHeight 
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                
                mask: Region { 
                    item: dashboardBackground 
                }

                property int osdAnimSpeed: 300
                property int containerWidth: 480
                property int containerHeight: 400
                property int compactHeight: 300
                property int closedHeight: 28
                property int openHeight: 400
                property bool monitorFocused: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === screen.name

                anchors {
                    top: Config.data.barLayout === "top" 
                    bottom: Config.data.barLayout === "bottom"
                }

                margins {
                    top: Config.data.barLayout === "top" ? 4 : 0
                    bottom: Config.data.barLayout === "bottom" ? 4 : 0
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [dashboard]
                    active: States.dashboardOpen && dashboard.monitorFocused
                    onCleared: {
                        States.dashboardOpen = false
                    }
                }

                Rectangle {
                    id: dashboardBackground
                    width: dashboard.containerWidth
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
                            if (!States.dashboardOpen) {
                                States.currentView = "home"
                                States.dashboardOpen = true
                            }
                        } 
                    }

                    Clock {
                        id: clock
                        anchors.centerIn: parent
                        orientation: "horizontalFull"
                        opacity: States.timeDateVisible && !States.dashboardOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: dashboard.osdAnimSpeed
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    BrightnessOSD {
                        id: brightnessOSD
                        opacity: States.brightnessOSDOpen ? 1 : 0
                        visible: opacity > 0 && dashboard.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: dashboard.osdAnimSpeed
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    MediaOSD {
                        id: mediaOSD
                        opacity: !States.dashboardOpen && States.mediaPlayerOpen ? 1 : 0
                        visible: opacity > 0 && dashboard.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: dashboard.osdAnimSpeed
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }
                    
                    NotificationOSD {
                        id: notificationOSD
                        opacity: States.notificationOSDOpen ? 1 : 0
                        visible: opacity > 0 && dashboard.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: dashboard.osdAnimSpeed
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    VolumeOSD {
                        id: volumeOSD
                        opacity: States.volumeOSDOpen ? 1 : 0
                        visible: opacity > 0 && dashboard.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: dashboard.osdAnimSpeed
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Component {
                        id: bluetoothView
                        BluetoothSettings {}
                    }
                    
                    Component {
                        id: homeView
                        HomeScreen {}
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
                        anchors.margins: States.currentView === "bluetooth" || States.currentView === "network" || States.currentView === "audio" ? 10 : 0
                        active: States.dashboardOpen && dashboard.monitorFocused
                        opacity: States.dashboardOpen ? 1 : 0
                        visible: opacity > 0 && dashboard.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }

                        sourceComponent: {
                            switch (States.currentView) {
                                case "audio": return audioView
                                case "bluetooth": return bluetoothView
                                case "home": return homeView
                                case "launcher": return launcherView
                                case "network": return networkView
                            }
                        }
                    }

                    state: {
                        if (!States.dashboardOpen || !dashboard.monitorFocused) return "closed"
                        if (States.currentView === "home") return "compact"
                        return "open"
                    }

                    states: [
                        State {
                            name: "closed"
                            PropertyChanges {
                                target: dashboardBackground
                                height: dashboard.closedHeight
                            }
                          },
                        State {
                            name: "compact"
                            PropertyChanges {
                                target: dashboardBackground
                                height: dashboard.compactHeight
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
                            from: "*"
                            to: "*"
                            
                            NumberAnimation {
                                properties: "height"
                                duration: 250
                                easing.type: Easing.InOutCubic
                            }
                        }
                    ]
                }
            }
        }
    }
}
