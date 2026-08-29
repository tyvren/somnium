import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: networkRoot
    property var selectedNetwork: null

    Connections {
        target: Network
        function onNetworksChanged() {
            if (selectedNetwork && Network.isConnected(selectedNetwork.ssid)) {
                selectedNetwork = null
                Network.errorMessage = ""
                passInput.text = ""
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        opacity: selectedNetwork !== null ? 0.4 : 1.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Rectangle {
            id: ethernetBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Network.ethernetConnected ? Theme.colMuted : Theme.colAccent
            opacity: Network.ethernetConnected ? 1 : 0.2
            radius: Config.data.rounding
            visible: Network.ethernetConnected

            Item {
                anchors.fill: parent

                StyledText {
                    id: ethIcon
                    text: "󰈀"
                    color: Theme.colAccent
                    size: 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                }

                StyledText {
                    text: "Ethernet (" + Network.ethernetInterface + ")"
                    size: 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: ethIcon.right
                    anchors.leftMargin: 10
                }

                StyledText {
                    text: "Connected"
                    size: 9
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText { 
                text: "Wi-Fi"
                color: Theme.colAccent
                size: 16 
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
            
            StyledSwitch {
                id: wifiToggle
                checked: Network.wifiEnabled
                onToggled: Network.setWifiEnabled(checked)
                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 12
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                model: Object.values(Network.networks).sort((a,b) => b.signal - a.signal)
                spacing: 8

                delegate: ItemDelegate {
                    id: delegateItem
                    width: parent.width
                    height: 55
                    enabled: selectedNetwork === null

                    onClicked: {
                        if (modelData.connected) return
                        if (modelData.secured) {
                            Network.errorMessage = ""
                            networkRoot.selectedNetwork = modelData
                        } else {
                            Network.connect(modelData.ssid)
                        }
                    }

                    background: Rectangle {
                        color: modelData.connected ? Theme.colAccent : (delegateItem.hovered ? Theme.colMuted : "transparent")
                        border.color: modelData.connected ? Theme.colHilight : Theme.colAccent 
                        border.width: Config.data.borderSize
                        opacity: modelData.connected ? 0.3 : 0.6
                        radius: Config.data.rounding
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        StyledText { 
                            id: signalIcon
                            text: Network.signalIcon(modelData.signal)
                            color: Theme.colAccent
                            size: 14 
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                        }

                        Column {
                            id: labelColumn
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: signalIcon.right
                            anchors.leftMargin: 15
                            spacing: 0

                            StyledText { 
                                text: modelData.ssid
                                bold: modelData.connected 
                            }
                            StyledText { 
                                text: modelData.connected ? "Connected" : (modelData.secured ? "Secured" : "Open")
                                size: 8
                            }
                        }

                        StyledButton {
                            width: 75
                            height: 26
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            text: modelData.connected ? "Forget" : "Connect"
                            
                            onClicked: {
                                if (modelData.connected) {
                                    Network.forget(modelData.ssid)
                                } else if (modelData.secured) {
                                    Network.errorMessage = ""
                                    networkRoot.selectedNetwork = modelData
                                } else {
                                    Network.connect(modelData.ssid)
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledButton {
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: 100
            Layout.preferredHeight: 35
            text: Network.scanning ? "Scanning..." : "Rescan"
            active: Network.scanning

            onClicked: Network.scan()
        }
    }

    Rectangle {
        id: authModal
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: 260
        color: Theme.colBg
        visible: selectedNetwork !== null
        radius: Config.data.rounding
        border.color: Theme.colAccent
        border.width: Config.data.borderSize 

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            StyledText {
                Layout.fillWidth: true
                text: "Authentication"
                color: Theme.colAccent
                size: 14
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                Layout.fillWidth: true
                text: selectedNetwork ? selectedNetwork.ssid : ""
                color: Theme.colMuted
                size: 10
                horizontalAlignment: Text.AlignHCenter
            }

            StyledInput {
                id: passInput
                Layout.fillWidth: true
                placeholderText: "Password..."
                placeholderTextColor: Theme.colMuted
                echoMode: TextInput.Password
                color: Theme.colAccent
                font.family: Theme.fontFamily
                padding: 10
                background: Rectangle {
                    color: Theme.colMuted
                    opacity: 0.1
                    radius: 3
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize 
                }
                onAccepted: if (!Network.connecting) Network.connect(selectedNetwork.ssid, passInput.text)
            }

            StyledText {
                visible: Network.errorMessage !== ""
                text: Network.errorMessage
                color: "#ff5555"
                size: 9
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15

                StyledButton {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 40
                    enabled: !Network.connecting
                    text: "Cancel"

                    onClicked: {
                        networkRoot.selectedNetwork = null
                        Network.errorMessage = ""
                        passInput.text = ""
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 40
                    text: Network.connecting ? "..." : "Connect"
                    active: Network.connecting

                    onClicked: {
                        if (Network.connecting) return
                        Network.connect(selectedNetwork.ssid, passInput.text)
                    }
                }
            }
        }
    }
}
