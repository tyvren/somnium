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
    implicitWidth: 480
    implicitHeight: 28

    function requestShow(customInterval) {
        States.brightnessOSDOpen = true
        hideTimer.interval = customInterval || 1500
        hideTimer.restart()
    }

    Connections {
        target: States
        function onBrightnessOSDOpenChanged() {
            if (!States.brightnessOSDOpen) {
                hideTimer.stop()
            }
        }
    }

    Connections {
        target: Brightness

        function onBrightnessChanged() {
            if (!brightnessSlider.pressed) {
                root.requestShow(1500)
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: States.brightnessOSDOpen = false
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 10
        enabled: States.brightnessOSDOpen

        StyledText {
            color: Theme.colAccent
            size: 14
            text: Brightness.brightness === 0 ? "󰃞" : "󰃠"
        }

        Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            value: Brightness.brightness
            from: 0.0
            to: 1.0

            background: Rectangle {
                x: brightnessSlider.leftPadding
                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 6
                width: brightnessSlider.availableWidth
                height: implicitHeight
                radius: 3
                color: Theme.colMuted
                opacity: 0.5

                Rectangle {
                    width: brightnessSlider.visualPosition * parent.width
                    height: parent.height
                    color: Brightness.brightness === 0 ? Theme.colMuted : Theme.colAccent
                    radius: 3
                }
            }

            handle: Rectangle {
                x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 3
                color: brightnessSlider.pressed ? Theme.colAccent : Theme.colBg
                border.color: Theme.colAccent
                border.width: 1
            }

            onMoved: {
                Brightness.setBrightness(brightnessSlider.value)
                root.requestShow(4000)
            }
        }
    }
}

