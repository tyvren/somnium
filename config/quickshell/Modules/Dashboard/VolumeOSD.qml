import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Themes
import qs.Services

Item {
    id: root
    anchors.fill: parent

    function requestShow(customInterval) {
        if (!States.dashboardOpen) {
            States.volumeOSDOpen = true
            hideTimer.interval = customInterval || 1500
            hideTimer.restart()
        }
    }

    Connections {
        target: States
        function onVolumeOSDOpenChanged() {
            if (!States.volumeOSDOpen) {
                hideTimer.stop()
            }
        }
    }

    Connections {
        target: Audio

        function onSinkVolumeChanged() {
            if (!volSlider.pressed) {
                root.requestShow(1500) 
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            States.volumeOSDOpen = false
            dashboard.currentView = "timeDate"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 10
        enabled: States.volumeOSDOpen

        StyledText {
            color: Theme.colAccent
            size: 14
            text: Audio.sinkMuted ? "󰝟" : ""
        }

        Slider {
            id: volSlider
            Layout.fillWidth: true
            value: Audio.sinkVolume
            from: 0
            to: 1
                
            background: Rectangle {
                x: volSlider.leftPadding
                y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 6
                width: volSlider.availableWidth
                height: implicitHeight
                radius: 3
                color: Theme.colMuted
                opacity: 0.5

                Rectangle {
                    width: volSlider.visualPosition * parent.width
                    height: parent.height
                    color: Audio.sinkMuted ? Theme.colMuted : Theme.colAccent
                    radius: 3
                }
            }

            handle: Rectangle {
                x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: Config.data.rounding
                color: volSlider.pressed ? Theme.colAccent : Theme.colBg
                border.color: Theme.colAccent
                border.width: 1
                visible: false
            }

            onMoved: {
                Audio.setSinkVolume(volSlider.value)
                root.requestShow(4000)
            }
        }
    }
}
