import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: root
    implicitWidth: 480
    implicitHeight: 28

    property bool shouldShowOsd: false
    property string currentSummary: ""
    property string currentBody: ""
    
    onShouldShowOsdChanged: {
      if (shouldShowOsd) {
          States.notificationOSDOpen = true
        } else {
          States.notificationOSDOpen = false
        }
    }

    Scope {
        id: notificationScope

        Connections {
            target: Notifications

            function onNotification(n) {
                root.currentSummary = n.summary
                root.currentBody = n.body
                root.shouldShowOsd = true
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 3500
        onTriggered: root.shouldShowOsd = false
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 12

        StyledText {
            text: root.currentSummary
            bold: true
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.Wrap
        }

        StyledText {
            text: root.currentBody
            size: 11
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            visible: text !== ""
        }
    }
}

