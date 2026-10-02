import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: root
    property string icon: ""
    property string text: ""
    property string tooltipText: ""
    property string color: Theme.colBg
    property string borderColor: Theme.colMuted
    property int iconSize: 14
    property int textSize: 12
    property int buttonWidth: 180
    property int buttonHeight: 40
    property bool active: false

    signal clicked()
    signal entered()
    signal exited()

    implicitWidth: root.buttonWidth
    implicitHeight: root.buttonHeight

    Rectangle {
        id: buttonBackground
        anchors.fill: parent
        radius: Config.data.rounding 
        color: root.color
        border.color: root.borderColor
        border.width: Config.data.borderSize

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            anchors.rightMargin: 14
            spacing: 20

            StyledText {
                text: root.icon
                size: root.iconSize
                color: (root.active || mouseArea.containsMouse) ? Theme.colAccent : Theme.colText
                visible: root.icon !== ""
                Layout.preferredWidth: 24 
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                text: root.text
                size: root.textSize
                color: (root.active || mouseArea.containsMouse) ? Theme.colAccent : Theme.colText
                visible: root.text !== ""
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.clicked()
            onEntered: root.entered()
            onExited: root.exited()
        }
    }
}
