pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightness: 0
    property string device: ""

    function setBrightness(value) {
        if (device === "") return
        const normalized = Math.max(0, Math.min(1, value))
        const percent = Math.floor(normalized * 100)
        Quickshell.execDetached(["brightnessctl", "-d", device, "s", percent + "%"])
        brightness = normalized
    }

    function initBrightness() {
        if (device === "") return
        initProc.command = ["sh", "-c", `echo a b c $(brightnessctl -d '${root.device}' g) $(brightnessctl -d '${root.device}' m)`]
        initProc.running = true
    }

    onDeviceChanged: {
        if (device !== "") initBrightness()
    }

    readonly property Process detectProc: Process {
        running: true
        command: ["sh", "-c", "brightnessctl -c backlight -l | grep -oP \"Device '\\K[^']+\" | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const name = text.trim()
                if (name !== "") root.device = name
            }
        }
    }

    readonly property Process initProc: Process {
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                if (parts.length >= 5) {
                    const c = parseInt(parts[3])
                    const m = parseInt(parts[4])
                    if (m > 0) root.brightness = c / m
                }
            }
        }
    }

    IpcHandler {
        target: "brightness"

        function stepUp() {
            root.setBrightness(root.brightness + 0.05)
        }

        function stepDown() {
            root.setBrightness(root.brightness - 0.05)
        }
    }
}
