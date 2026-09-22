import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.Components
import qs.Services
import qs.Themes

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
            Layout.topMargin: 10
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

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            color: "transparent"
            border.color: "transparent"

            Calendar {
                id: calendar

                visible: true
                onVisibleChanged: calendarBtn.active = calendar.visible
            }

            Controls {
                id: controls

                visible: false
                onVisibleChanged: controlsBtn.active = controls.visible
            }

            Performance {
                id: performance

                visible: false
                onVisibleChanged: systemStatsBtn.active = performance.visible
            }

            MediaPlayer {
                id: dashboardMedia

                visible: false
                onVisibleChanged: mediaBtn.active = dashboardMedia.visible
            }

            NotificationPane {
                id: notificationPane

                visible: false
                onVisibleChanged: notificationsBtn.active = notificationPane.visible
            }
        }
    }
}
