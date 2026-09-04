import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Themes
import qs.Services

ColumnLayout {
    id: root
    anchors.fill: parent
    spacing: 5

    Rectangle {
        id: container
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent" 

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            DayOfWeekRow {
                locale: grid.locale
                Layout.fillWidth: true
                delegate: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.shortName
                }
            }

            MonthGrid {
                id: grid
                readonly property date today: new Date()
                month: today.getMonth()
                year: today.getFullYear()
                locale: Qt.locale("en_US")
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: Rectangle {
                    required property var model
                    color: model.month === grid.month ? Theme.colBg : "transparent"
                    border.color: model.today ? Theme.colAccent : "transparent"
                    radius: Config.data.rounding

                    StyledText {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.day
                        color: model.today ? Theme.colText : model.month === grid.month ? Theme.colAccent : "transparent"
                    }
                }      
            }
        }
    }
}

