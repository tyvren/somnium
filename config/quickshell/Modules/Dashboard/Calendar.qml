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
    anchors.bottomMargin: 10
    spacing: 10

    readonly property var calendarLocale: Qt.locale("en_US")
    readonly property int borderWidth: Config.data.borderSize || 1

    property date today: new Date()
    property date selectedDate: new Date()
    property int viewMonth: today.getMonth()
    property int viewYear: today.getFullYear()

    readonly property bool viewingToday: selectedDate.toDateString() === today.toDateString()
        && viewMonth === today.getMonth()
        && viewYear === today.getFullYear()

    function shiftMonth(delta: int): void {
        const target = new Date(viewYear, viewMonth + delta, 1)
        viewMonth = target.getMonth()
        viewYear = target.getFullYear()
    }

    function goToToday(): void {
        const now = new Date()
        today = now
        selectedDate = now
        viewMonth = now.getMonth()
        viewYear = now.getFullYear()
    }

    function selectDate(value: var): void {
        selectedDate = value
        viewMonth = value.getMonth()
        viewYear = value.getFullYear()
    }

    function isoWeek(value: var): int {
        const target = new Date(value.getFullYear(), value.getMonth(), value.getDate())
        target.setDate(target.getDate() - ((target.getDay() + 6) % 7) + 3)
        const firstThursday = new Date(target.getFullYear(), 0, 4)
        return 1 + Math.round(((target - firstThursday) / 86400000 - 3 + ((firstThursday.getDay() + 6) % 7)) / 7)
    }

    function dayOfYear(value: var): int {
        const start = new Date(value.getFullYear(), 0, 0)
        return Math.round((value - start) / 86400000)
    }

    function daysInYear(year: int): int {
        return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 ? 366 : 365
    }

    function relativeText(value: var): string {
        const startToday = new Date(today.getFullYear(), today.getMonth(), today.getDate())
        const startValue = new Date(value.getFullYear(), value.getMonth(), value.getDate())
        const diff = Math.round((startValue - startToday) / 86400000)
        if (diff === 0)
            return "Today"
        if (diff === 1)
            return "Tomorrow"
        if (diff === -1)
            return "Yesterday"
        if (diff > 0)
            return "In " + diff + " days"
        return Math.abs(diff) + " days ago"
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.today = new Date()
    }

    Timer {
        id: wheelCooldown
        interval: 180
    }

    Item {
        Layout.fillWidth: true
    }

    Rectangle {
        id: infoCard
        Layout.preferredWidth: 200
        Layout.fillHeight: true
        radius: 10
        color: "transparent"
        border.width: root.borderWidth
        border.color: Theme.colAccent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 2

            StyledText {
                text: root.selectedDate.getDate()
                color: Theme.colAccent
                size: 34
            }

            StyledText {
                text: root.calendarLocale.dayName(root.selectedDate.getDay(), Locale.LongFormat)
                size: 16
            }

            StyledText {
                text: root.calendarLocale.monthName(root.selectedDate.getMonth(), Locale.LongFormat) + " " + root.selectedDate.getFullYear()
                color: Theme.colMuted
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                height: 1
                color: Theme.colAccent
                opacity: 0.3
            }

            StyledText {
                text: root.relativeText(root.selectedDate)
                color: Theme.colAccent
            }

            Item {
                Layout.fillHeight: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: Config.data.rounding
                color: todayMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                border.width: root.borderWidth
                border.color: Theme.colAccent
                visible: !root.viewingToday

                StyledText {
                    anchors.centerIn: parent
                    text: "Back to today"
                    color: Theme.colAccent
                }

                MouseArea {
                    id: todayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goToToday()
                }
            }
        }
    }

    ColumnLayout {
        id: calendarColumn
        Layout.preferredWidth: 350
        Layout.fillHeight: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: Config.data.rounding
                color: previousMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                border.width: root.borderWidth
                border.color: Theme.colAccent

                StyledText {
                    anchors.centerIn: parent
                    text: "‹"
                    color: Theme.colAccent
                    size: 16
                }

                MouseArea {
                    id: previousMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.shiftMonth(-1)
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                StyledText {
                    anchors.centerIn: parent
                    text: root.calendarLocale.monthName(root.viewMonth, Locale.LongFormat) + " " + root.viewYear
                    size: 14
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goToToday()
                }
            }

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: Config.data.rounding
                color: nextMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                border.width: root.borderWidth
                border.color: Theme.colAccent

                StyledText {
                    anchors.centerIn: parent
                    text: "›"
                    color: Theme.colAccent
                    size: 16
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.shiftMonth(1)
                }
            }
        }

        DayOfWeekRow {
            locale: root.calendarLocale
            Layout.fillWidth: true
            delegate: StyledText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: model.shortName
                color: Theme.colMuted
            }
        }

        MonthGrid {
            id: grid
            month: root.viewMonth
            year: root.viewYear
            locale: root.calendarLocale
            spacing: 3
            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Rectangle {
                id: dayCell
                required property var model
                readonly property bool inView: model.month === root.viewMonth
                readonly property bool isToday: model.date.toDateString() === root.today.toDateString()
                readonly property bool isSelected: model.date.toDateString() === root.selectedDate.toDateString()

                radius: Config.data.rounding
                color: isSelected ? Theme.colAccent : dayMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                border.width: isToday && !isSelected ? root.borderWidth : 0
                border.color: Theme.colAccent

                StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: dayCell.model.day
                    color: dayCell.isSelected ? Theme.colBg : dayCell.isToday ? Theme.colAccent : Theme.colText
                    opacity: dayCell.inView ? 1 : 0.3
                }

                MouseArea {
                    id: dayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectDate(dayCell.model.date)
                }
            }
        }

        WheelHandler {
            onWheel: event => {
                if (wheelCooldown.running)
                    return
                root.shiftMonth(event.angleDelta.y > 0 ? -1 : 1)
                wheelCooldown.start()
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
