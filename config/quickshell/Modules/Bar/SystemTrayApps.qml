import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Services

RowLayout {
    spacing: 10

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: trayItemArea
            required property var modelData

            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            IconImage {
                anchors.fill: parent
                source: trayItemArea.modelData.icon ?? ""
            }

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    SystemTray.triggerItem(trayItemArea.modelData);
                } else if (mouse.button === Qt.RightButton) {
                    SystemTray.openMenu(trayItemArea.modelData, trayItemArea);
                } else if (mouse.button === Qt.MiddleButton) {
                    SystemTray.triggerSecondary(trayItemArea.modelData);
                }
            }
        }
    }
}
