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
    spacing: 10

    property bool calendarOpen: false

    Clock {
        id: clock
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.topMargin: 5
        orientation: "horizontalFull"
        visible: States.timeDateVisible
    }

    Rectangle {
        id: container
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: 5
        color: "transparent" 
        visible: calendarOpen

        GridLayout {
            columns: 1
            anchors.fill: parent
            anchors.margins: 10

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

