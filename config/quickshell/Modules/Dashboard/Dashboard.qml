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
                                duration: 350
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
                                duration: 350
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
                                duration: 350
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
                                duration: 350
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
                                case "launcher": return launcherView
                                case "network": return networkView
                            }
                        }
                    }  

                    Rectangle {
                        id: dashHomeScreen
                        anchors.fill: parent
                        color: "transparent"
                        opacity: States.dashboardOpen && States.currentView === "home" ? 1 : 0
                        visible: opacity > 0 && dashboard.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.InOutCubic
                            }
                        }

                        ColumnLayout {
                            id: homeScreenColumn
                            anchors.fill: parent
                            visible: States.dashboardOpen && dashboard.monitorFocused

                            RowLayout {
                                id: buttonRow
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 15
                                spacing: 10
                                
                                StyledButton {
                                    id: calendarBtn
                                    icon: ""
                                    buttonWidth: 50
                                    buttonHeight: 35
                                    onClicked: {
                                        calendar.visible = true
                                        controls.visible = false
                                        performance.visible = false
                                        notificationPane.visible = false
                                        dashboardMedia.visible = false
                                    }
                                }

                                StyledButton {
                                    id: controlsBtn
                                    icon: ""
                                    buttonWidth: 50
                                    buttonHeight: 35
                                    onClicked: {
                                        controls.visible = true
                                        calendar.visible = false
                                        performance.visible = false
                                        notificationPane.visible = false
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
                                        controls.visible = false
                                        dashboardMedia.visible = false
                                        notificationPane.visible = false
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
                                        controls.visible = false
                                        notificationPane.visible = false
                                        performance.visible = false
                                    }
                                }

                                StyledButton {
                                    id: notificationsBtn
                                    icon: ""
                                    buttonWidth: 50
                                    buttonHeight: 35
                                    onClicked: { 
                                        notificationPane.visible = true
                                        calendar.visible = false
                                        controls.visible = false
                                        dashboardMedia.visible = false
                                        performance.visible = false
                                    }     
                                }  
                            }

                            StyledRect {
                                id: menuWindow
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                                Layout.bottomMargin: 15
                                Layout.preferredWidth: 400
                                Layout.preferredHeight: 220
                                color: "transparent"
                                border.color: "transparent"
                                
                                Calendar {
                                    id: calendar
                                    visible: true

                                    onVisibleChanged:
                                        if (calendar.visible) {
                                            calendarBtn.active = true
                                        } else {
                                            calendarBtn.active = false
                                        }
                                }

                                Controls {
                                    id: controls
                                    visible: false

                                    onVisibleChanged:
                                        if (controls.visible) {
                                            controlsBtn.active = true
                                        } else {
                                            controlsBtn.active = false
                                        }
                                }

                                Performance {
                                    id: performance
                                    visible: false

                                    onVisibleChanged:
                                        if (performance.visible) {
                                            systemStatsBtn.active = true
                                        } else {
                                            systemStatsBtn.active = false
                                        }
                                }

                                MediaPlayer {
                                    id: dashboardMedia
                                    width: 400
                                    height: 220
                                    visible: false

                                    onVisibleChanged:
                                        if (dashboardMedia.visible) {
                                            mediaBtn.active = true
                                        } else {
                                            mediaBtn.active = false
                                        }
                                }

                                NotificationPane {
                                    id: notificationPane
                                    visible: false

                                    onVisibleChanged:
                                        if (notificationPane.visible) {
                                            notificationsBtn.active = true
                                        } else {
                                            notificationsBtn.active = false
                                        }
                                }
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
