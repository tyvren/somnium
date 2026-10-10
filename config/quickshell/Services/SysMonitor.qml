pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {
    id: root

    readonly property string scriptPath: Config.installDir + "/modules/quickshell"

    readonly property real cpuUsage: _cpuUsage
    readonly property real ramUsage: _ramUsage

    property real _cpuUsage: 0
    property real _ramUsage: 0

    Timer {
        id: statsTimer
        interval: 2000
        repeat: true
        onTriggered: statsProc.running = true
    }

    Process {
        id: statsProc
        command: ["/bin/bash", root.scriptPath + "/sysmonitor.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                _cpuUsage = parseFloat(parts[0]) || 0
                _ramUsage = (parseFloat(parts[1]) || 0) / 100
            }
        }
    }

    Component.onCompleted: statsTimer.running = true
}
