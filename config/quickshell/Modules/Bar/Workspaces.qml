import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Components
import qs.Themes

RowLayout {
    spacing: 15

    Repeater {
        model: 9

        Item {
            id: wsbutton
            implicitWidth: icon.implicitWidth
            implicitHeight: icon.implicitHeight

            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            StyledRect {
                id: icon
                implicitWidth: 9
                implicitHeight: 9
                color: isActive ? "transparent" : (ws ? Theme.colAccent : "transparent")
                border.color: isActive ? Theme.colAccent : (ws ? Theme.colMuted : "transparent") 
                layer.enabled: true
            }

            MultiEffect {
                anchors.fill: parent
                source: icon
                shadowEnabled: true
                shadowBlur: 0.2
                shadowOpacity: 0.8
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${index + 1} })`)
            }
        }
    }
}

