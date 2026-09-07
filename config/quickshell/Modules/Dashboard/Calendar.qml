import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Themes
import qs.Services

RowLayout {
    id: root
    anchors.fill: parent
    anchors.topMargin: 10

    ColumnLayout {
      id: calendarColumn
      Layout.alignment: Qt.AlignHCenter

        StyledText {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
            Layout.leftMargin: 60
            text: grid.today.toLocaleDateString(grid.locale, "MMMM yyyy")
            size: 14
        }

        DayOfWeekRow {
            locale: grid.locale
            Layout.preferredWidth: 240
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
            Layout.preferredWidth: 240
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
