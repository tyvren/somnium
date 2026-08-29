import QtQuick
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Themes

Item {
    id: bluetoothbutton
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    BarButton {
        id: button
        icon: ""
        
        Process {
            id: openBluetooth
            command: ["qs", "ipc", "call", "dashboard", "openBluetooth"]
        }

        onClicked: openBluetooth.running = true
    }
}
