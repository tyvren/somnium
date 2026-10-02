import QtQuick
import Quickshell
import qs.Themes
import qs.Services

PopupWindow {
    id: root

    property Item targetItem: null
    property string tooltipText: ""
    property int delay: 1500

    anchor.item: targetItem
    anchor.rect.x: targetItem ? (targetItem.width - width) / 2 : 0
    anchor.rect.y: targetItem ? targetItem.height + 6 : 0
    width: tooltipLabel.implicitWidth + 16
    height: tooltipLabel.implicitHeight + 8
    color: "transparent"
    visible: false 

    function show(item, text) {
        targetItem = item
        tooltipText = text
        tooltipDelay.restart()
    }

    function hide() {
        tooltipDelay.stop()
        visible = false
        targetItem = null
    }

    Timer {
        id: tooltipDelay
        interval: root.delay
        onTriggered: {
            if (root.targetItem !== null && root.tooltipText !== "") {
                root.visible = true
            }
        }
    }

    Rectangle {
        id: customTooltip
        anchors.fill: parent
        color: Theme.colBg
        border.color: Theme.colAccent
        border.width: Config.data.borderSize
        radius: Config.data.rounding
        opacity: root.visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        StyledText {
            id: tooltipLabel
            anchors.centerIn: parent
            text: root.tooltipText
            size: 11
            color: Theme.colText
        }
    }
}
