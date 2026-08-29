import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: bluetoothRoot

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        RowLayout {
            Layout.fillWidth: true

            StyledText { 
                text: "Bluetooth"
                color: Theme.colAccent
                size: 16 
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
            
            StyledSwitch {
                id: btToggle
                checked: Bluetooth.enabled
                onToggled: Bluetooth.togglePower()
                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 12
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                model: Bluetooth.devices
                spacing: 8
                delegate: ItemDelegate {
                    id: deviceDelegate
                    width: parent.width
                    height: 55

                    background: Rectangle {
                        color: modelData.connected ? Theme.colAccent : Theme.colMuted
                        border.color: modelData.connected ? Theme.colHilight : Theme.colAccent 
                        border.width: Config.data.borderSize 
                        opacity: modelData.connected ? 0.3 : 0.6
                        radius: Config.data.rounding 

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Bluetooth.connectDevice(modelData)
                        }
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        StyledText { 
                            id: btIcon
                            text: Bluetooth.getIcon(modelData)
                            color: Theme.colAccent
                            size: 14 
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                        }

                        Column {
                            id: btLabelColumn
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: btIcon.right
                            anchors.leftMargin: 15
                            spacing: 0

                            StyledText { 
                                text: modelData.name
                                bold: modelData.connected 
                            }
                            StyledText { 
                                text: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                                size: 8
                            }
                        }

                        StyledButton {
                            visible: true 
                            width: 75
                            height: 26
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            text: modelData.connected ? "Forget" : "Connect"
                            
                            onClicked: modelData.connected ? Bluetooth.forgetDevice(modelData) : Bluetooth.connectDevice(modelData)
                        }
                    }
                }
            }
        }

        StyledButton {
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: 100
            Layout.preferredHeight: 35
            text: Bluetooth.scanning ? "Scanning..." : "Scan"
            active: Bluetooth.scanning

            onClicked: Bluetooth.toggleScan()
        }
    }
}
