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

PanelWindow {
    id: dashboard
    focusable: true
    implicitWidth: dashboard.containerWidth
    implicitHeight: dashboard.containerHeight 
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: dashboardBackground }

    property int containerWidth: 480
    property int containerHeight: 400
    property string currentView: "timeDate"

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
                dashboard.currentView = "timeDate"
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
        height: States.dashboardOpen ? dashboard.containerHeight : 28
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
                    States.dashboardOpen = true
                    focusGrab.active = true
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
                    easing.type: Easing.InOutQuad
                }
            }
        }

        MediaPlayer {
            id: media
            opacity: States.mediaPlayerOpen ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.InOutQuad
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
                    easing.type: Easing.InOutQuad
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
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Component {
            id: timeDateView
            TimeDateCal {
                id: timedateCal
                calendarOpen: States.dashboardOpen && dashboard.currentView === "timeDate"
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
            anchors.margins: dashboard.currentView === "timeDate" ? 0 : 10
            active: dashboard.currentView != null

            sourceComponent: {
                switch (dashboard.currentView) {
                    case "audio": return audioView
                    case "bluetooth": return bluetoothView
                    case "launcher": return launcherView
                    case "network": return networkView
                    case "timeDate": return timeDateView
                    default: return timeDateView
                }
            }
        }

        state: States.dashboardOpen ? "open" : "closed"

        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: dashboardBackground
                    height: 28 
                }
            },
            State {
                name: "open"
                PropertyChanges {
                    target: dashboardBackground
                    height: dashboard.containerHeight
                }
            }
        ]

        transitions: [
            Transition {
                from: "closed"
                to: "open"
                
                NumberAnimation {
                    properties: "height"
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            },
            Transition {
                from: "open"
                to: "closed"

                NumberAnimation {
                    properties: "height"
                    duration: 250
                    easing.type: Easing.InCubic
                }
            }
        ]
    }
}
