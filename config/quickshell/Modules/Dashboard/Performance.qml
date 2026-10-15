import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Themes
import qs.Services

RowLayout {
    id: performanceRoot
    anchors.fill: parent
    spacing: 20

    function statData(key: string): var {
        switch (key) {
            case "cpu":
                return {
                    show: true,
                    label: "CPU",
                    value: Math.round(SysMonitor.cpuUsage) + "%",
                    fraction: SysMonitor.cpuUsage / 100
                }
            case "ram":
                return {
                    show: true,
                    label: "RAM",
                    value: SysMonitor.ramUsedGb.toFixed(1) + " / " + SysMonitor.ramTotalGb.toFixed(1) + " GB",
                    fraction: SysMonitor.ramUsage
                }
            case "gpu":
                return {
                    show: SysMonitor.gpuAvailable,
                    label: "GPU",
                    value: Math.round(SysMonitor.gpuUsage * 100) + "%",
                    fraction: SysMonitor.gpuUsage
                }
            case "vram":
                return {
                    show: SysMonitor.gpuAvailable,
                    label: "VRAM",
                    value: SysMonitor.vramUsedGb.toFixed(1) + " / " + SysMonitor.vramTotalGb.toFixed(1) + " GB",
                    fraction: SysMonitor.vramUsage
                }
            case "disk":
                return {
                    show: true,
                    label: "Disk",
                    value: SysMonitor.diskUsedGb.toFixed(0) + " / " + SysMonitor.diskTotalGb.toFixed(0) + " GB",
                    fraction: SysMonitor.diskUsage
                }
        }
        return { show: false, label: "", value: "", fraction: 0 }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 150
        spacing: 10

        StyledText {
            id: currentProfile
            text: "Current profile: " + PowerProfiles.profileName
            size: 9
        }

        StyledButtonLeftText {
            id: powerSave
            Layout.preferredHeight: 40
            Layout.preferredWidth: 150
            icon: "󰌪"
            text: "Power Saving"
            iconSize: 12
            textSize: 9

            Process { id: powerSaveNotification; command: ["notify-send", "Power Save Mode Enabled"] }

            onClicked: {
                PowerProfiles.setPowerSaver();
                powerSaveNotification.startDetached();
            }
        }

        StyledButtonLeftText {
            id: balanced
            Layout.preferredHeight: 40
            Layout.preferredWidth: 150
            icon: "󰗑"
            text: "Balanced"
            iconSize: 12
            textSize: 9

            Process { id: balancedNotification; command: ["notify-send", "Balanced Mode Enabled"] }

            onClicked: {
                PowerProfiles.setBalanced();
                balancedNotification.startDetached();
            }
        }

        StyledButtonLeftText {
            id: performance
            Layout.preferredHeight: 40
            Layout.preferredWidth: 150
            icon: "󰊚"
            text: "Performance"
            iconSize: 12
            textSize: 9

            Process { id: performanceNotification; command: ["notify-send", "Performance Mode Enabled"] }

            onClicked: {
                PowerProfiles.setPerformance();
                performanceNotification.startDetached();
            }
        }
    }

    Rectangle {
        id: statsCard
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.preferredHeight: statsContent.implicitHeight + 20
        radius: 10
        color: "transparent"
        border.width: Config.data.borderSize
        border.color: Theme.colAccent

        ColumnLayout {
            id: statsContent
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            GridLayout {
                id: statsGrid
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 20
                rowSpacing: 8

                Repeater {
                    model: ["cpu", "ram", "gpu", "vram", "disk"]

                    delegate: Column {
                        id: statRow
                        required property var modelData
                        readonly property var stat: performanceRoot.statData(modelData)

                        visible: stat.show
                        Layout.fillWidth: true
                        Layout.preferredWidth: 150
                        spacing: 4

                        Row {
                            width: parent.width
                            spacing: 5

                            Text {
                                text: statRow.stat.label
                                color: Theme.colText
                                font.pixelSize: 11
                            }

                            Text {
                                text: statRow.stat.value
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
                                width: parent.width * Math.max(0, Math.min(1, statRow.stat.fraction))
                                height: parent.height
                                radius: parent.radius
                                color: Theme.colAccent
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Text {
                    text: "Temp  CPU " + Math.round(SysMonitor.cpuTemp) + "°C" + (SysMonitor.gpuAvailable ? "   GPU " + Math.round(SysMonitor.gpuTemp) + "°C" : "")
                    color: Theme.colText
                    font.pixelSize: 11
                }

                Text {
                    visible: SysMonitor.cpuPowerAvailable || SysMonitor.gpuPower > 0
                    text: "Power  " + (SysMonitor.cpuPowerAvailable ? "CPU " + SysMonitor.cpuPower.toFixed(1) + " W" : "") + (SysMonitor.gpuPower > 0 ? "   GPU " + SysMonitor.gpuPower.toFixed(1) + " W" : "")
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
