pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {
    id: root

    readonly property string scriptPath: Config.installDir + "/modules/quickshell"

    property var _stats: ({})

    readonly property real cpuUsage: _stats.cpu || 0
    readonly property real cpuTemp: _stats.cpu_temp || 0
    readonly property real cpuPower: _stats.cpu_power || 0
    readonly property bool cpuPowerAvailable: (_stats.cpu_power_available || 0) === 1
    readonly property real ramUsage: (_stats.ram || 0) / 100
    readonly property real ramUsedGb: _stats.ram_used || 0
    readonly property real ramTotalGb: _stats.ram_total || 0
    readonly property real diskUsage: (_stats.disk || 0) / 100
    readonly property real diskUsedGb: _stats.disk_used || 0
    readonly property real diskTotalGb: _stats.disk_total || 0
    readonly property bool gpuAvailable: (_stats.gpu_available || 0) === 1
    readonly property real gpuUsage: (_stats.gpu || 0) / 100
    readonly property real gpuTemp: _stats.gpu_temp || 0
    readonly property real gpuPower: _stats.gpu_power || 0
    readonly property real vramUsage: (_stats.vram || 0) / 100
    readonly property real vramUsedGb: _stats.vram_used || 0
    readonly property real vramTotalGb: _stats.vram_total || 0
    readonly property real uptimeSeconds: _stats.uptime || 0

    readonly property string uptimeText: {
        const total = Math.floor(uptimeSeconds)
        const days = Math.floor(total / 86400)
        const hours = Math.floor((total % 86400) / 3600)
        const minutes = Math.floor((total % 3600) / 60)
        if (days > 0)
            return days + "d " + hours + "h"
        if (hours > 0)
            return hours + "h " + minutes + "m"
        return minutes + "m"
    }

    Timer {
        id: statsTimer
        interval: 2000
        repeat: true
        onTriggered: {
            if (!statsProc.running)
                statsProc.running = true
        }
    }

    Process {
        id: statsProc
        command: ["/bin/bash", root.scriptPath + "/sysmonitor.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parsed = {}
                const lines = text.trim().split("\n")
                for (const line of lines) {
                    const separator = line.indexOf("=")
                    if (separator > 0)
                        parsed[line.substring(0, separator)] = parseFloat(line.substring(separator + 1)) || 0
                }
                root._stats = parsed
            }
        }
    }

    Component.onCompleted: statsTimer.running = true
}
