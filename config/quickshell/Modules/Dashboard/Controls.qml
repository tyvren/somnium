import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Themes
import qs.Services

ColumnLayout {
    anchors.fill: parent

    StyledText {
        text: "Display Brightness"
        Layout.leftMargin: 10
    }

    Item {
        id: brightnessControl
        Layout.fillWidth: true
        Layout.preferredHeight: 32

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            StyledText {
                color: Theme.colAccent
                size: 14
                text: brightnessSlider.value === 0 ? "󰃞" : "󰃠"
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
                        color: brightnessSlider.value === 0 ? Theme.colMuted : Theme.colAccent
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
                    if (typeof root !== "undefined" && root.requestShow) {
                        root.requestShow(4000)
                    }
                }
            }
        }
    }

    StyledText {
      text: "Keyboard Backlight"
      Layout.leftMargin: 10
    }

    Item {
        id: kbdBrightnessControl
        Layout.fillWidth: true
        Layout.preferredHeight: 32

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            StyledText {
                color: Theme.colAccent
                size: 14
                text: "󰌌"
            }

            Slider {
                id: kbdBrightnessSlider
                Layout.fillWidth: true
                value: KeyboardBacklight.brightness
                from: 0.0
                to: 1.0

                Connections {
                    target: KeyboardBacklight
                    function onBrightnessChanged() {
                        if (!kbdBrightnessSlider.pressed) {
                            kbdBrightnessSlider.value = KeyboardBacklight.brightness
                        }
                    }
                }

                background: Rectangle {
                    x: kbdBrightnessSlider.leftPadding
                    y: kbdBrightnessSlider.topPadding + kbdBrightnessSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: kbdBrightnessSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Theme.colMuted
                    opacity: 0.5

                    Rectangle {
                        width: kbdBrightnessSlider.visualPosition * parent.width
                        height: parent.height
                        color: kbdBrightnessSlider.value === 0 ? Theme.colMuted : Theme.colAccent
                        radius: 3
                    }
                }

                handle: Rectangle {
                    x: kbdBrightnessSlider.leftPadding + kbdBrightnessSlider.visualPosition * (kbdBrightnessSlider.availableWidth - width)
                    y: kbdBrightnessSlider.topPadding + kbdBrightnessSlider.availableHeight / 2 - height / 2
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: Config.data.rounding
                    color: kbdBrightnessSlider.pressed ? Theme.colAccent : Theme.colBg
                    border.color: Theme.colAccent
                    border.width: 1
                }

                onMoved: {
                    KeyboardBacklight.setBrightness(kbdBrightnessSlider.value)
                    if (typeof root !== "undefined" && root.requestShow) {
                        root.requestShow(4000)
                    }
                }
            }
        }
    }
}
