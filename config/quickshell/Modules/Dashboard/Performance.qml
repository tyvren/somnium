import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Themes
import qs.Services

ColumnLayout {
    id: performanceRoot
    anchors.fill: parent
    spacing: 10

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        spacing: 10

        StyledButton {
            id: powerSave
            Layout.preferredHeight: 50
            Layout.preferredWidth: 100
            icon: "󰌪"
            text: "Power Saving"
            textSize: 8

            Process { id: powerSaveNotification; command: ["notify-send", "Power Save Mode Enabled"] }

            onClicked: {
                PowerProfiles.setPowerSaver();
                powerSaveNotification.startDetached(); 
            }
        } 

        StyledButton {
            id: balanced
            Layout.preferredHeight: 50
            Layout.preferredWidth: 100
            icon: "󰗑"
            text: "Balanced"
            textSize: 8

            Process { id: balancedNotification; command: ["notify-send", "Balanced Mode Enabled"] }

            onClicked: {
                PowerProfiles.setBalanced();
                balancedNotification.startDetached(); 
            }
        }

        StyledButton {
            id: performance
            Layout.preferredHeight: 50
            Layout.preferredWidth: 100
            icon: "󰊚"
            text: "Performance"
            textSize: 8

            Process { id: performanceNotification; command: ["notify-send", "Performance Mode Enabled"] }

            onClicked: {
                PowerProfiles.setPerformance();
                performanceNotification.startDetached(); 
            }
        }
    }


    RowLayout {
        id: statsRow
        anchors.fill: parent

        Rectangle {
            id: cpuBadge
            Layout.alignment: Qt.AlignHCenter
            width: 150
            height: 80
            radius: Config.data.rounding
            color: Theme.colMuted

            Row {
                id: cpuRow
                spacing: 5
                anchors.centerIn: parent

                StyledText {
                    text: ""
                    color: Theme.colAccent
                    size: 20
                    Layout.alignment: Qt.AlignHCenter 
                }

                StyledText {
                    text: Math.round(SysMonitor.cpuUsage) + "%"
                    color: Theme.colAccent
                    bold: true
                    size: 20
                    Layout.alignment: Qt.AlignHCenter 
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 6
                height: 10
                radius: 1
                color: Theme.colMuted

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.min(Math.max(SysMonitor.cpuUsage / 100, 0), 1)
                    color: Theme.colAccent
                    radius: 1
                }
            }
        }

        Rectangle {
            id: ramBadge
            Layout.alignment: Qt.AlignHCenter
            width: 150
            height: 80
            radius: Config.data.rounding
            color: Theme.colMuted

            Row {
                id: ramRow
                spacing: 5
                anchors.centerIn: parent

                StyledText {
                    text: ""
                    color: Theme.colAccent
                    size: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: Math.round(SysMonitor.ramUsage * 100) + "%"
                    color: Theme.colAccent
                    bold: true
                    size: 20
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 6
                height: 10
                radius: 1
                color: Theme.colMuted

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.min(Math.max(SysMonitor.ramUsage, 0), 1)
                    color: Theme.colAccent
                    radius: 1
                }
            }
        }
    }
}
