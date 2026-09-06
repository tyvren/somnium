import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Themes
import qs.Services

RowLayout {
    anchors.fill: parent
    spacing: 10

    Item {
        id: brightnessControl
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 300
        Layout.preferredHeight: 50

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
                    radius: Config.data.rounding
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
}
