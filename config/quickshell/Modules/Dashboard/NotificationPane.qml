import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.Components
import qs.Services
import qs.Themes

ColumnLayout {
    id: paneRoot
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            text: "Notifications"
            color: Theme.colAccent
            size: 11
            bold: true
        }

        Item { Layout.fillWidth: true }

        StyledButton {
            text: "󰎟"
            textSize: 11
            implicitWidth: 50
            implicitHeight: 30
            onClicked: Notifications.clearAll()
        }
    }

    DividerLine {
        Layout.fillWidth: true
    }

    ListView {
        id: notifList
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: Notifications.notifications
        spacing: 5
        clip: true

        delegate: Item {
            id: notifDelegate
            width: notifList.width
            height: contentLayout.implicitHeight + 30

            StyledButton {
                anchors.fill: parent

                ColumnLayout {
                    id: contentLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 15
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Image {
                            source: modelData.appIcon !== "" ? Quickshell.iconPath(modelData.appIcon, true) : ""
                            sourceSize.width: 18
                            sourceSize.height: 18
                            Layout.maximumWidth: 18
                            Layout.maximumHeight: 18
                            visible: modelData.appIcon !== ""
                            fillMode: Image.PreserveAspectFit
                        }

                        StyledText {
                            text: modelData.summary
                            bold: true
                            size: 11
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            id: dismissBox
                            Layout.preferredWidth: 15
                            Layout.preferredHeight: 15
                            radius: Config.data.rounding
                            color: Theme.colBg
                            border.color: dismissMa.containsMouse ? Theme.colAccent : Theme.colMuted
                            border.width: Config.data.borderSize

                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            StyledText {
                                anchors.centerIn: parent
                                text: ""
                                size: 7
                                color: dismissMa.containsMouse ? Theme.colAccent : Theme.colText

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            MouseArea {
                                id: dismissMa
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.dismiss()
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Image {
                            source: modelData.image !== "" ? modelData.image : ""
                            sourceSize.width: 45
                            sourceSize.height: 45
                            Layout.maximumWidth: 45
                            Layout.maximumHeight: 45
                            Layout.alignment: Qt.AlignTop
                            visible: modelData.image !== ""
                            fillMode: Image.PreserveAspectFit
                        }

                        StyledText {
                            text: modelData.body
                            size: 10
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            opacity: 0.85
                            visible: text !== ""
                        }
                    }
                }
            }
        }
    }
}
