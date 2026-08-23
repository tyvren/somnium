import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Services
import qs.Themes

Item {
    id: osdRoot

    property bool active: false
    readonly property string barLayout: Config.data.barLayout
    default property alias data: osdContainer.data

    onActiveChanged: {
        if (active) {
            osdRoot.visible = true
        }
    }

    Rectangle {
        id: osdContainer
        anchors.fill: parent
        anchors.topMargin: 1 
        anchors.bottomMargin: 1
        radius: Config.data.rounding
        color: Theme.colBg
        border.color: Theme.colAccent
        border.width: Config.data.borderSize
        state: osdRoot.active ? "visible" : "hidden"

        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: osdContainer
                    opacity: 0
                    y: 0
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: osdContainer
                    opacity: 1
                    y: 28
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    NumberAnimation {
                        properties: "opacity, y"
                        duration: 500
                        easing.type: Easing.InOutCubic
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    NumberAnimation {
                        properties: "opacity, y"
                        duration: 550
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        ]
    }
}
