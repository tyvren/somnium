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
                color: isActive ? Theme.colBg : (ws ? Theme.colMuted : "transparent")
                border.color: isActive ? Theme.colAccent : (ws ? Theme.colMuted : "transparent") 
                layer.enabled: true
                visible: false
            }

            Image {
                id: workspaceLogo
                width: 25
                height: 25
                y: -3
                x: -5
                source: Theme.logoPath
                mipmap: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                layer.enabled: true
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: icon
                shadowEnabled: true
                shadowBlur: 0.2
                shadowOpacity: 0.7
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${index + 1} })`)
            }
        }
    }
}

