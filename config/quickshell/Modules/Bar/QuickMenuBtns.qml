import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services

RowLayout {
    id: mainMenuRoot
    spacing: 20

    StyledButton {
          icon: ""
          Layout.preferredWidth: 10
          Layout.preferredHeight: 10
          color: "transparent"
          onClicked: {
              States.mainMenuOpen = false
              settingsProcess.startDetached()
          }
    }

    StyledButton {
          icon: "󰌾"
          Layout.preferredWidth: 10
          Layout.preferredHeight: 10
          color: "transparent"
          onClicked: {
              States.mainMenuOpen = false
              lockProcess.startDetached()
          }
    }

    StyledButton {
          icon: "󰍃"
          Layout.preferredWidth: 10
          Layout.preferredHeight: 10
          color: "transparent"
          onClicked: {
              States.mainMenuOpen = false
              logoutProcess.startDetached()
          }
    }

    StyledButton {
        icon: "󰜉"
        Layout.preferredWidth: 10
        Layout.preferredHeight: 10
        color: "transparent"
        onClicked: {
            States.mainMenuOpen = false
            restartProcess.startDetached()
        }
    }

    StyledButton {
        icon: "󰐥"
        Layout.preferredWidth: 10
        Layout.preferredHeight: 10
        onClicked: {
            States.mainMenuOpen = false
            shutdownProcess.startDetached()
        }
    }

    Process { id: lockProcess; command: ["sh", "-c", "qs ipc call lockscreen lock"] }
    Process { id: logoutProcess; command: ["hyprctl", "dispatch", "exit"] }
    Process { id: restartProcess; command: ["systemctl", "reboot"] }
    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }
    Process { id: settingsProcess; command: ["sh", "-c", "qs ipc call settingsMenu toggle"] }
}
