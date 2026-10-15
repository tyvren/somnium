import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: audioPane

    ColumnLayout {
        anchors.fill: parent

        Process {
            id: openAudio
            command: ["pavucontrol"]
        }

        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true

            StyledText {
                text: "Audio Configuration"
                color: Theme.colAccent
                size: 16
            }

            DividerLine {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            spacing: 20
            Layout.fillWidth: true

            AudioControlRow {
                title: "Output Device"
                currentDevice: Audio.sink
                deviceList: Audio.sinkNodes
                volume: Audio.sinkVolume
                isMuted: Audio.sinkMuted
                muteIcon: "󰝟"
                unmuteIcon: "󰓃"
                onVolumeSet: (val) => Audio.setSinkVolume(val)
                onToggleMute: Audio.toggleSinkMute()
                onDeviceSelected: (node) => Audio.selectSink(node)
            }

            DividerLine {
                Layout.fillWidth: true
            }

            AudioControlRow {
                title: "Input Device"
                currentDevice: Audio.source
                deviceList: Audio.sourceNodes
                volume: Audio.sourceVolume
                isMuted: Audio.sourceMuted
                muteIcon: "󰍭"
                unmuteIcon: "󰍬"
                onVolumeSet: (val) => Audio.setSourceVolume(val)
                onToggleMute: Audio.toggleSourceMute()
                onDeviceSelected: (node) => Audio.selectSource(node)
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            
            StyledButton {
                text: "Additional Settings"
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                onClicked: openAudio.startDetached()
            }
        }

        component AudioControlRow : ColumnLayout {
            property string title
            property var currentDevice
            property var deviceList
            property real volume
            property bool isMuted
            property string muteIcon
            property string unmuteIcon
            
            signal volumeSet(real val)
            signal toggleMute()
            signal deviceSelected(var node)

            spacing: 12
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: title
                        color: Theme.colAccent
                        font.pointSize: 10
                        font.family: Theme.fontFamily
                    }

                    Item {
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 45

                        ComboBox {
                            id: deviceSelector
                            anchors.fill: parent
                            model: deviceList
                            textRole: "description"

                            currentIndex: {
                                if (!currentDevice || !deviceList || deviceList.length === 0) return -1;
                                for (let i = 0; i < deviceList.length; i++) {
                                    if (deviceList[i] && deviceList[i].id === currentDevice.id) return i;
                                }
                                return -1;
                            }

                            onActivated: (index) => {
                                const node = deviceList[index];
                                if (node) deviceSelected(node);
                            }

                            delegate: ItemDelegate {
                                width: deviceSelector.width

                                contentItem: Text {
                                    text: modelData.description || "Unknown Device"
                                    color: highlighted ? Theme.colBg : Theme.colText
                                    font.pointSize: 10
                                    font.family: Theme.fontFamily
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                background: Rectangle {
                                    color: highlighted ? Theme.colAccent : "transparent"
                                    radius: Config.data.rounding 
                                }
                            }

                            contentItem: Text {
                                leftPadding: 15
                                rightPadding: 30
                                text: deviceSelector.displayText
                                font.pointSize: 11
                                font.family: Theme.fontFamily
                                color: Theme.colText
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                id: comboBackground
                                color: Theme.colMuted
                                opacity: 0.2
                                radius: Config.data.rounding 
                                border.color: deviceSelector.activeFocus ? Theme.colAccent : "transparent"
                                border.width: Config.data.borderSize
                            }

                            popup: Popup {
                                y: deviceSelector.height + 5
                                width: deviceSelector.width
                                implicitHeight: Math.min(contentItem.implicitHeight, 250)
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: deviceSelector.popup.visible ? deviceSelector.delegateModel : null
                                    currentIndex: deviceSelector.highlightedIndex
                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }

                                background: Rectangle {
                                    color: Theme.colBg
                                    border.color: Theme.colAccent
                                    border.width: Config.data.borderSize
                                    radius: Config.data.rounding 
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: Math.round(volume * 100) + "%"
                    color: isMuted ? Theme.colMuted : Theme.colAccent
                    size: 11
                    bold: true
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 10
                }
            }

            RowLayout {
                spacing: 15
                Layout.fillWidth: true

                StyledButton {
                    Layout.preferredWidth: 55
                    Layout.preferredHeight: 45
                    icon: isMuted ? muteIcon : unmuteIcon
                    active: isMuted

                    onClicked: toggleMute()
                }

                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    value: volume || 0
                    from: 0
                    to: 1
                    
                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: volSlider.availableWidth
                        height: implicitHeight
                        radius: Config.data.rounding 
                        color: Theme.colMuted
                        opacity: 0.5

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            color: isMuted ? Theme.colMuted : Theme.colAccent
                            radius: Config.data.rounding 
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: Config.data.rounding
                        color: volSlider.pressed ? Theme.colAccent : Theme.colBg
                        border.color: Theme.colAccent
                        border.width: Config.data.borderSize
                    }

                    onMoved: volumeSet(value)
                }
            }
        }
    }
}
