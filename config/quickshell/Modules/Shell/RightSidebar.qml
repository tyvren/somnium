import QtQuick
import Quickshell
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: rightSidebar

    required property var frameWindow

    visible: Config.data.sideBarsEnabled
    width: frameWindow.rightInset

    anchors {
        right: parent.right
        top: parent.top
        bottom: parent.bottom
    }

    MouseArea {
        anchors.fill: parent
        onClicked: rightSidebar.frameWindow.rightSidebarOpen = !rightSidebar.frameWindow.rightSidebarOpen
    }

    Image {
        id: rightSidebarLogo
        anchors.right: parent.right
        anchors.rightMargin: -48
        anchors.verticalCenter: parent.verticalCenter
        width: 120
        height: 120
        source: Theme.logoPath
        mipmap: true
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        opacity: rightSidebar.frameWindow.rightSidebarOpen ? 1 : 0
        scale: rightSidebar.frameWindow.rightSidebarOpen ? 1.5 : 0.5
        rotation: rightSidebar.frameWindow.rightSidebarOpen ? 360 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: 650
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
    }

    Column {
        id: rightSidebarTools
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.right: parent.right
        anchors.rightMargin: 30
        width: Math.max(0, rightSidebar.width - 62)
        spacing: 14
        opacity: rightSidebar.frameWindow.rightSidebarOpen ? 1 : 0
        visible: opacity > 0
        enabled: rightSidebar.frameWindow.rightSidebarOpen

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        StyledText {
            text: "Capture"
            color: Theme.colAccent
        }

        Grid {
            columns: 3
            spacing: 4

            Repeater {
                model: [
                    { glyph: "󰹑", label: "Select", command: ["flameshot", "gui"] },
                    { glyph: "󰹑", label: "Fullscreen", command: ["flameshot", "full", "--clipboard"] },
                    { glyph: "󰻂", label: "Record", command: ["obs", "--startrecording"] }
                ]

                delegate: StyledRect {
                    width: 55
                    height: 55

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.glyph
                            color: Theme.colAccent
                            font.pixelSize: 20
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            color: Theme.colText
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            rightSidebar.frameWindow.rightSidebarOpen = false;
                            Quickshell.execDetached(modelData.command)
                        }
                    }
                }
            }
        }
    }
}
