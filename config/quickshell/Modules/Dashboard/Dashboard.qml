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
                property int compactHeight: 300
                property int closedHeight: 28
                property int openHeight: 400

                property string currentView: "home"

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
                            dashboard.currentView = "home"
                        }
                    }
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [dashboard]
                    active: States.dashboardOpen
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
                                dashboard.currentView = "home"
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

                    MediaOSD {
                        id: mediaOSD
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
                        anchors.margins: dashboard.currentView === "bluetooth" || dashboard.currentView === "network" || dashboard.currentView === "audio" ? 10 : 0
                        active: States.dashboardOpen
                        opacity: States.dashboardOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }

                        sourceComponent: {
                            switch (dashboard.currentView) {
                                case "audio": return audioView
                                case "bluetooth": return bluetoothView
                                case "launcher": return launcherView
                                case "network": return networkView
                            }
                        }
                    }  

                    Rectangle {
                        id: dashHomeScreen
                        anchors.fill: parent
                        color: "transparent"
                        opacity: States.dashboardOpen && dashboard.currentView === "home" ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.InOutCubic
                            }
                        }

                        ColumnLayout {
                            id: homeScreenColumn
                            anchors.fill: parent
                            visible: States.dashboardOpen

                            RowLayout {
                                id: buttonRow
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 10
                                spacing: 10
                                
                                StyledButton {
                                    id: calendarBtn
                                    icon: ""
                                    buttonWidth: 50
                                    buttonHeight: 35
                                    onClicked: {
                                        calendar.visible = true
                                        performance.visible = false
                                        dashboardMedia.visible = false
                                    }
                                }

                                StyledButton {
                                    id: systemStatsBtn
                                    icon: "󰊚"
                                    buttonWidth: 50
                                    buttonHeight: 35
                                    onClicked: { 
                                        performance.visible = true
                                        calendar.visible = false
                                        dashboardMedia.visible = false
                                    }      
                                }

                                StyledButton {
                                    id: mediaBtn
                                    icon: "󰝚"
                                    buttonWidth: 50
                                    buttonHeight: 35
                                    onClicked: { 
                                        dashboardMedia.visible = true
                                        calendar.visible = false
                                        performance.visible = false
                                    }     
                                }
                            }

                            StyledRect {
                                id: menuWindow
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                                Layout.bottomMargin: 10
                                Layout.preferredWidth: 400
                                Layout.preferredHeight: 220
                                color: "transparent"
                                
                                Calendar {
                                    id: calendar
                                    anchors.centerIn: parent
                                    visible: false
                                  }

                                Performance {
                                    id: performance
                                    anchors.centerIn: parent
                                    visible: true
                                }

                                MediaPlayer {
                                    id: dashboardMedia
                                    anchors.centerIn: parent
                                    width: 400
                                    height: 220
                                    visible: false
                                }
                            }
                        }
                    }

                    state: {
                        if (!States.dashboardOpen) return "closed"
                        if (dashboard.currentView === "home") return "compact"
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
