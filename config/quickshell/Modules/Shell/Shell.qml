import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
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

    component EdgeReservation: PanelWindow {
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        mask: Region {}
    }

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenFrame
            required property var modelData

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.top: true
                exclusiveZone: frameWindow.dashboardAtBottom ? frameWindow.rimThickness : frameWindow.dashboardClosedHeight
            }

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.bottom: true
                exclusiveZone: frameWindow.dashboardAtBottom ? frameWindow.dashboardClosedHeight : frameWindow.rimThickness
            }

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.left: true
                exclusiveZone: frameWindow.sidebarRestWidth
            }

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.right: true
                exclusiveZone: frameWindow.sidebarRestWidth
            }

            PanelWindow {
                id: frameWindow
                screen: screenFrame.modelData
                focusable: true
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                readonly property int rimThickness: 10
                readonly property int sidebarClosedWidth: 25
                readonly property int dashboardClosedHeight: 30
                readonly property int sidebarExpandedWidth: 220
                readonly property int sidebarShoulderLength: 40
                readonly property int dashboardFlare: 50
                readonly property int dashboardCompactHeight: 300
                readonly property int dashboardOpenHeight: 400
                readonly property int osdFadeDuration: 350

                readonly property int dashboardClosedWidth: 1000
                readonly property int dashboardHomeWidth: 700
                readonly property int dashboardAudioWidth: 600
                readonly property int dashboardBluetoothWidth: 600
                readonly property int dashboardLauncherWidth: 600
                readonly property int dashboardNetworkWidth: 600

                property bool leftSidebarOpen: false
                property bool rightSidebarOpen: false

                readonly property bool dashboardAtBottom: Config.data.barLayout === "bottom"
                readonly property bool monitorFocused: !!Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === screen.name
                readonly property bool dashboardShown: States.dashboardOpen && monitorFocused
                readonly property real borderWidth: Config.data.borderSize || 1
                readonly property real sidebarRestWidth: Config.data.sideBarsEnabled ? sidebarClosedWidth : rimThickness

                readonly property real dashboardTargetWidth: {
                    if (!dashboardShown)
                        return dashboardClosedWidth
                    switch (States.currentView) {
                        case "audio": return dashboardAudioWidth
                        case "bluetooth": return dashboardBluetoothWidth
                        case "launcher": return dashboardLauncherWidth
                        case "network": return dashboardNetworkWidth
                        default: return dashboardHomeWidth
                    }
                }

                property real dashboardContentWidth: dashboardTargetWidth

                readonly property real dashboardWidth: dashboardContentWidth + dashboardFlare * 2
                readonly property real dashboardLeft: (width - dashboardWidth) / 2
                readonly property real dashboardRight: dashboardLeft + dashboardWidth
                readonly property real dashboardTargetHeight: {
                    if (!dashboardShown)
                        return dashboardClosedHeight
                    if (States.currentView === "home")
                        return dashboardCompactHeight
                    return dashboardOpenHeight
                }

                property real dashboardHeight: dashboardTargetHeight
                property real leftInset: leftSidebarOpen && Config.data.sideBarsEnabled ? sidebarExpandedWidth : sidebarRestWidth
                property real rightInset: rightSidebarOpen && Config.data.sideBarsEnabled ? sidebarExpandedWidth : sidebarRestWidth

                readonly property real leftWallX: Math.max(sidebarRestWidth, leftInset)
                readonly property real rightWallX: width - Math.max(sidebarRestWidth, rightInset)

                Behavior on dashboardContentWidth {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

                Behavior on dashboardHeight {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

                Behavior on leftInset {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

                Behavior on rightInset {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

                mask: Region {
                    x: 0
                    y: 0
                    width: frameWindow.width
                    height: frameWindow.height

                    Region {
                        x: frameWindow.leftWallX
                        y: frameWindow.rimThickness
                        width: frameWindow.rightWallX - frameWindow.leftWallX
                        height: frameWindow.height - frameWindow.rimThickness * 2
                        intersection: Intersection.Subtract
                    }

                    Region {
                        x: frameWindow.dashboardLeft
                        y: frameWindow.dashboardAtBottom ? frameWindow.height - frameWindow.dashboardHeight : 0
                        width: frameWindow.dashboardWidth
                        height: frameWindow.dashboardHeight
                    }
                }

                HyprlandFocusGrab {
                    windows: [frameWindow]
                    active: frameWindow.dashboardShown || frameWindow.leftSidebarOpen || frameWindow.rightSidebarOpen
                    onCleared: {
                        States.dashboardOpen = false
                        frameWindow.leftSidebarOpen = false
                        frameWindow.rightSidebarOpen = false
                    }
                }

                FrameShape {
                    frameWindow: frameWindow
                }

                TopDashboard {
                    frameWindow: frameWindow
                }

                LeftSidebar {
                    frameWindow: frameWindow
                }

                RightSidebar {
                    frameWindow: frameWindow
                }
            }
        }
    }
}
