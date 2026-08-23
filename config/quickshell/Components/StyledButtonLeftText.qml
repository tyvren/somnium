import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Themes

Item {
    id: root
    property string icon: ""
    property string text: ""
    property string color: Theme.colBg
    property string borderColor: Theme.colMuted
    property int iconSize: 14
    property int textSize: 12
    property int buttonWidth: 180
    property int buttonHeight: 40
    property bool active: false
    signal clicked()

    implicitWidth: root.buttonWidth
    implicitHeight: root.buttonHeight

    MultiEffect {
        anchors.fill: buttonBackground
        source: buttonBackground
        shadowEnabled: true
        shadowBlur: (root.active || mouseArea.containsMouse) ? 0.8 : 0
        shadowColor: Theme.colAccent
        shadowVerticalOffset: 0
        shadowHorizontalOffset: 0
        
        Behavior on shadowBlur { NumberAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Rectangle {
        id: buttonBackground
        anchors.fill: parent
        radius: Config.data.rounding 
        color: root.color
        border.color: root.borderColor
        border.width: Config.data.borderSize

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            anchors.rightMargin: 14
            spacing: 16

            StyledText {
                text: root.icon
                size: root.iconSize
                color: (root.active || mouseArea.containsMouse) ? Theme.colAccent : Theme.colText
                visible: root.icon !== ""
                Layout.preferredWidth: 24 
                horizontalAlignment: Text.AlignHCenter
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            StyledText {
                text: root.text
                size: root.textSize
                color: (root.active || mouseArea.containsMouse) ? Theme.colAccent : Theme.colText
                visible: root.text !== ""
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                elide: Text.ElideRight
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.clicked()
        }
    }
}
