pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightness: 0
    property string device: "*kbd_backlight"
    property real maxBrightness: 100

    function setBrightness(value) {
        if (device === "") return
        const normalized = Math.max(0, Math.min(1, value))
        const percent = Math.floor(normalized * 100)
        Quickshell.execDetached(["brightnessctl", "-d", device, "s", percent + "%"])
        brightness = normalized
    }

    function sync() {
        if (device === "") return
        maxProc.running = true
    }

    Component.onCompleted: sync()

    readonly property Process maxProc: Process {
        running: false
        command: ["brightnessctl", "-d", root.device, "m"]

        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim())
                if (!isNaN(val) && val > 0) {
                    root.maxBrightness = val
                    currProc.running = true
                }
            }
        }
    }

    readonly property Process currProc: Process {
        running: false
        command: ["brightnessctl", "-d", root.device, "g"]

        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim())
                if (!isNaN(val)) {
                    root.brightness = val / root.maxBrightness
                }
            }
        }
    }

    IpcHandler {
        target: "kbdbrightness"

        function stepUp() {
            root.setBrightness(root.brightness + 0.1)
        }

        function stepDown() {
            root.setBrightness(root.brightness - 0.1)
        }
    }
}
