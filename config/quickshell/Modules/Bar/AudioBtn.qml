import QtQuick
import Quickshell.Io
import qs.Components
import qs.Themes
import qs.Services

Item {
    id: audiobutton
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    BarButton {
        id: button
        icon: {
            if (Audio.sinkMuted) return ""
            if (Audio.sinkVolume < 0.25) return ""
            if (Audio.sinkVolume < 0.50) return ""
            return ""
        } 

        Process {
            id: openAudio
            command: ["qs", "ipc", "call", "dashboard", "openAudio"]
        }
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Audio.toggleSinkMute()
                } else {
                    openAudio.running = true
                }
            }
        }
    }
}
