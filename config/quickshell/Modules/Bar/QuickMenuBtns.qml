import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services

RowLayout {
    id: mainMenuRoot
    spacing: 15

    StyledButton {
          icon: ""
          Layout.preferredWidth: 10
          Layout.preferredHeight: 10
          onClicked: {
              settingsProcess.startDetached()
          }
    }

    StyledButton {
          icon: "󰌾"
          Layout.preferredWidth: 10
          Layout.preferredHeight: 10
          onClicked: {
              lockProcess.startDetached()
          }
    }

    StyledButton {
        icon: "󰜉"
        Layout.preferredWidth: 10
        Layout.preferredHeight: 10
        onClicked: {
            restartProcess.startDetached()
        }
    }

    StyledButton {
        icon: "󰐥"
        Layout.preferredWidth: 10
        Layout.preferredHeight: 10
        onClicked: {
            shutdownProcess.startDetached()
        }
    }

    Process { id: lockProcess; command: ["sh", "-c", "qs ipc call lockscreen lock"] }
    Process { id: restartProcess; command: ["systemctl", "reboot"] }
    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }
    Process { id: settingsProcess; command: ["sh", "-c", "qs ipc call settingsMenu toggle"] }
}
