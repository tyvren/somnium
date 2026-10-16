import QtQuick
import qs.Components
import qs.Modules.Bar
import qs.Modules.Dashboard
import qs.Modules.Menus.Settings
import qs.Services

Item {
    id: dashboardContent

    required property var frameWindow

    x: frameWindow.dashboardLeft + frameWindow.dashboardFlare
    y: frameWindow.dashboardAtBottom ? frameWindow.height - height : 0
    width: frameWindow.dashboardContentWidth
    height: frameWindow.dashboardHeight

    Keys.onEscapePressed: States.dashboardOpen = false

    MainMenuBtn {
        id: mainMenuButton
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        visible: !States.dashboardOpen
    }

    QuickMenuBtns {
        id: quickMenuButtons
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.verticalCenter: parent.verticalCenter
        opacity: States.mainMenuOpen ? 1 : 0
        visible: opacity > 0 && !States.dashboardOpen

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }

        Timer {
            interval: 5000
            running: States.mainMenuOpen && !quickMenuHoverHandler.hovered
            onTriggered: States.mainMenuOpen = false
        }

        HoverHandler {
            id: quickMenuHoverHandler
        }
    }

    Workspaces {
        id: workspaces
        anchors.left: parent.left
        anchors.leftMargin: States.mainMenuOpen ? 210 : 60
        anchors.verticalCenter: parent.verticalCenter
        visible: !States.dashboardOpen

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
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
                duration: dashboardContent.frameWindow.osdFadeDuration
                easing.type: Easing.InOutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!States.dashboardOpen) {
                    States.currentView = "home"
                    States.dashboardOpen = true
                }
            }
        }
    }

    SystemTrayApps {
        id: systemTray
        anchors.right: parent.right
        anchors.rightMargin: batteryButton.visible ? 165 : 100
        anchors.verticalCenter: parent.verticalCenter
        visible: !States.dashboardOpen
    }

    BatteryBtn {
        id: batteryButton
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        visible: Battery.available && !States.dashboardOpen
    }

    AudioBtn {
        anchors.right: parent.right
        anchors.rightMargin: 70
        anchors.verticalCenter: parent.verticalCenter
        visible: !States.dashboardOpen
    }

    BluetoothBtn {
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        visible: !States.dashboardOpen
    }

    NetworkBtn {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        visible: !States.dashboardOpen
    }

    BrightnessOSD {
        anchors.centerIn: parent
        opacity: States.brightnessOSDOpen ? 1 : 0
        visible: opacity > 0 && dashboardContent.frameWindow.monitorFocused

        Behavior on opacity {
            NumberAnimation {
                duration: dashboardContent.frameWindow.osdFadeDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    MediaOSD {
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: !States.dashboardOpen && States.mediaPlayerOpen ? 1 : 0
        visible: opacity > 0 && dashboardContent.frameWindow.monitorFocused

        Behavior on opacity {
            NumberAnimation {
                duration: dashboardContent.frameWindow.osdFadeDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    NotificationOSD {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 500
        opacity: States.notificationOSDOpen ? 1 : 0
        visible: opacity > 0 && dashboardContent.frameWindow.monitorFocused

        Behavior on opacity {
            NumberAnimation {
                duration: dashboardContent.frameWindow.osdFadeDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    VolumeOSD {
        anchors.centerIn: parent
        opacity: States.volumeOSDOpen ? 1 : 0
        visible: opacity > 0 && dashboardContent.frameWindow.monitorFocused

        Behavior on opacity {
            NumberAnimation {
                duration: dashboardContent.frameWindow.osdFadeDuration
                easing.type: Easing.InOutCubic
            }
        }
    }

    Component {
        id: audioSettingsView
        AudioSettings {}
    }

    Component {
        id: bluetoothSettingsView
        BluetoothSettings {}
    }

    Component {
        id: homeScreenView
        HomeScreen {}
    }

    Component {
        id: launcherView
        Launcher {}
    }

    Component {
        id: networkSettingsView
        NetworkSettings {}
    }

    Loader {
        id: dashboardViewLoader
        anchors.fill: parent
        anchors.margins: States.currentView === "bluetooth" || States.currentView === "network" || States.currentView === "audio" ? 10 : 0
        active: States.dashboardOpen && dashboardContent.frameWindow.monitorFocused
        opacity: States.dashboardOpen ? 1 : 0
        visible: opacity > 0 && dashboardContent.frameWindow.monitorFocused

        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InOutCubic
            }
        }

        sourceComponent: {
            switch (States.currentView) {
                case "audio": return audioSettingsView
                case "bluetooth": return bluetoothSettingsView
                case "home": return homeScreenView
                case "launcher": return launcherView
                case "network": return networkSettingsView
            }
        }
    }
}
