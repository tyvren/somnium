import QtQuick
import Quickshell
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: leftSidebar

    required property var frameWindow

    visible: Config.data.sideBarsEnabled
    width: frameWindow.leftInset

    anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom
    }

    MouseArea {
        anchors.fill: parent
        onClicked: leftSidebar.frameWindow.leftSidebarOpen = !leftSidebar.frameWindow.leftSidebarOpen
    }

    Image {
        id: leftSidebarLogo
        anchors.left: parent.left
        anchors.leftMargin: -48
        anchors.verticalCenter: parent.verticalCenter
        width: 120
        height: 120
        source: Theme.logoPath
        mipmap: true
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        opacity: leftSidebar.frameWindow.leftSidebarOpen ? 1 : 0
        scale: leftSidebar.frameWindow.leftSidebarOpen ? 1.5 : 0.5
        rotation: leftSidebar.frameWindow.leftSidebarOpen ? -360 : 0

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
        id: leftSidebarTools
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.left: parent.left
        anchors.leftMargin: 30
        width: Math.max(0, leftSidebar.width - 62)
        spacing: 14
        opacity: leftSidebar.frameWindow.leftSidebarOpen ? 1 : 0
        visible: opacity > 0
        enabled: leftSidebar.frameWindow.leftSidebarOpen

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        StyledText {
            text: "Quick Access"
            color: Theme.colAccent
        }

        Repeater {
            model: [
                { label: "Applications", glyph: "▦", command: "qs ipc call dashboard openLauncher" },
                { label: "Settings", glyph: "⚙", command: "qs ipc call settingsMenu toggle" },
                { label: "Terminal", glyph: ">_", command: "ghostty" },
                { label: "Files", glyph: "▤", command: "thunar" }
            ]

            delegate: StyledRect {
                width: leftSidebarTools.width
                height: 38

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 11

                    StyledText {
                        width: 22
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.glyph
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["sh", "-c", modelData.command])
                }
            }
        }
    }

    Column {
        id: leftSidebarSystem
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        anchors.left: parent.left
        anchors.leftMargin: 30
        width: Math.max(0, leftSidebar.width - 62)
        spacing: 14
        opacity: leftSidebar.frameWindow.leftSidebarOpen ? 1 : 0
        visible: opacity > 0
        enabled: leftSidebar.frameWindow.leftSidebarOpen

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        StyledText {
            text: "System"
            color: Theme.colAccent
        }

        Rectangle {
            width: leftSidebarSystem.width
            height: systemStatsColumn.implicitHeight + 20
            radius: 10
            color: "transparent"
            border.width: Config.data.borderSize
            border.color: Theme.colAccent

            Column {
                id: systemStatsColumn
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Repeater {
                    model: [
                        {
                            show: true,
                            label: "CPU",
                            value: Math.round(SysMonitor.cpuUsage) + "%",
                            fraction: SysMonitor.cpuUsage / 100
                        },
                        {
                            show: true,
                            label: "RAM",
                            value: SysMonitor.ramUsedGb.toFixed(1) + " / " + SysMonitor.ramTotalGb.toFixed(1) + " GB",
                            fraction: SysMonitor.ramUsage
                        },
                        {
                            show: SysMonitor.gpuAvailable,
                            label: "GPU",
                            value: Math.round(SysMonitor.gpuUsage * 100) + "%",
                            fraction: SysMonitor.gpuUsage
                        },
                        {
                            show: SysMonitor.gpuAvailable,
                            label: "VRAM",
                            value: SysMonitor.vramUsedGb.toFixed(1) + " / " + SysMonitor.vramTotalGb.toFixed(1) + " GB",
                            fraction: SysMonitor.vramUsage
                        },
                        {
                            show: true,
                            label: "Disk",
                            value: SysMonitor.diskUsedGb.toFixed(0) + " / " + SysMonitor.diskTotalGb.toFixed(0) + " GB",
                            fraction: SysMonitor.diskUsage
                        }
                    ]

                    delegate: Column {
                        width: systemStatsColumn.width
                        spacing: 4
                        visible: modelData.show

                        Row {
                            width: parent.width
                            spacing: 5

                            Text {
                                text: modelData.label
                                color: Theme.colText
                                font.pixelSize: 11
                            }

                            Text {
                                text: modelData.value
                                color: Theme.colAccent
                                font.pixelSize: 11
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 5
                            radius: 3
                            color: Theme.colAccent
                            opacity: 0.2

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(1, modelData.fraction))
                                height: parent.height
                                radius: parent.radius
                                color: Theme.colAccent
                            }
                        }
                    }
                }

                Text {
                    text: "CPU " + Math.round(SysMonitor.cpuTemp) + "°C" + (SysMonitor.gpuAvailable ? "   GPU " + Math.round(SysMonitor.gpuTemp) + "°C" : "")
                    color: Theme.colText
                    font.pixelSize: 11
                }

                Text {
                    text: "Uptime " + SysMonitor.uptimeText
                    color: Theme.colText
                    font.pixelSize: 11
                }
            }
        }
    }
}
