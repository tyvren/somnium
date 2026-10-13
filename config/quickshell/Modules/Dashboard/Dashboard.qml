import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
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

                WlrLayershell.layer: WlrLayer.Overlay

                mask: Region {
                    item: dashboardBackground
                }

                property int osdAnimSpeed: 250
                property int flare: 50
                property int contentWidth: 580
                property int containerWidth: contentWidth + flare * 2
                property int containerHeight: 400
                property int compactHeight: 300
                property int closedHeight: 30
                property int openHeight: 400
                property bool monitorFocused: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === screen.name

                anchors {
                    top: Config.data.barLayout === "top"
                    bottom: Config.data.barLayout === "bottom"
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [dashboard]
                    active: States.dashboardOpen && dashboard.monitorFocused
                    onCleared: {
                        States.dashboardOpen = false
                    }
                }

                Item {
                    id: dashboardBackground
                    width: dashboard.containerWidth
                    y: Config.data.barLayout === "bottom" ? dashboard.containerHeight - height : 0

                    readonly property bool flipped: Config.data.barLayout === "bottom"

                    function fy(v) {
                        return flipped ? height - v : v
                    }

                    Keys.onEscapePressed: States.dashboardOpen = false

                    Shape {
                        id: dashboardShape
                        anchors.fill: parent
                        layer.enabled: true
                        layer.samples: 5

                        ShapePath {
                            strokeWidth: Config.data.borderSize
                            strokeColor: "transparent"
                            fillColor: Theme.colBg

                            startX: 0
                            startY: dashboardBackground.fy(0)

                            PathCubic {
                                x: dashboard.flare
                                y: dashboardBackground.fy(dashboardBackground.height)
                                control1X: dashboard.flare * 0.6
                                control1Y: dashboardBackground.fy(dashboardBackground.height * 0.18)
                                control2X: dashboard.flare * 0.7
                                control2Y: dashboardBackground.fy(dashboardBackground.height)
                            }
                            PathLine {
                                x: dashboardBackground.width - dashboard.flare
                                y: dashboardBackground.fy(dashboardBackground.height)
                            }
                            PathCubic {
                                x: dashboardBackground.width
                                y: dashboardBackground.fy(0)
                                control1X: dashboardBackground.width - dashboard.flare * 0.7
                                control1Y: dashboardBackground.fy(dashboardBackground.height)
                                control2X: dashboardBackground.width - dashboard.flare * 0.6
                                control2Y: dashboardBackground.fy(dashboardBackground.height * 0.18)
                            }
                            PathLine {
                                x: dashboardBackground.width
                                y: dashboardBackground.fy(0)
                            }
                        }
                    }

                    Shape {
                        id: dashboardOutline
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer

                        ShapePath {
                            strokeWidth: Config.data.borderSize
                            strokeColor: Theme.colAccent
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin

                            startX: 0
                            startY: dashboardBackground.fy(0)

                            PathCubic {
                                x: dashboard.flare
                                y: dashboardBackground.fy(dashboardBackground.height - 1)
                                control1X: dashboard.flare * 0.6
                                control1Y: dashboardBackground.fy(dashboardBackground.height * 0.18)
                                control2X: dashboard.flare * 0.7
                                control2Y: dashboardBackground.fy(dashboardBackground.height - 1)
                            }
                            PathLine {
                                x: dashboardBackground.width - dashboard.flare
                                y: dashboardBackground.fy(dashboardBackground.height - 1)
                            }
                            PathCubic {
                                x: dashboardBackground.width
                                y: dashboardBackground.fy(0)
                                control1X: dashboardBackground.width - dashboard.flare * 0.7
                                control1Y: dashboardBackground.fy(dashboardBackground.height - 1)
                                control2X: dashboardBackground.width - dashboard.flare * 0.6
                                control2Y: dashboardBackground.fy(dashboardBackground.height * 0.18)
                            }
                        }
                    }

                    Item {
                        id: dashboardContent
                        anchors.fill: parent
                        anchors.leftMargin: dashboard.flare
                        anchors.rightMargin: dashboard.flare

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
                            textSize: 15
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
                            anchors.centerIn: parent
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
                            anchors.fill: parent
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
                            anchors.centerIn: parent
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
