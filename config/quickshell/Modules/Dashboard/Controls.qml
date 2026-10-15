import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Themes
import qs.Services

ColumnLayout {
    anchors.fill: parent
    spacing: 10

    Item {
        Layout.fillHeight: true
    }

    Rectangle {
        id: brightnessCard
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 360
        Layout.preferredHeight: 64
        radius: 10
        color: "transparent"
        border.width: Config.data.borderSize
        border.color: Theme.colAccent

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colAccent
                size: 16
                text: brightnessSlider.value === 0 ? "󰃞" : "󰃠"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Row {
                    spacing: 5

                    Text {
                        text: "Display"
                        color: Theme.colText
                        font.pixelSize: 11
                    }

                    Text {
                        text: Math.round(brightnessSlider.value * 100) + "%"
                        color: Theme.colAccent
                        font.pixelSize: 11
                    }
                }

                Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    implicitHeight: 16
                    value: Brightness.brightness
                    from: 0.0
                    to: 1.0

                    background: Rectangle {
                        x: brightnessSlider.leftPadding
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        width: brightnessSlider.availableWidth
                        height: 5
                        radius: 3
                        color: Qt.alpha(Theme.colAccent, 0.2)

                        Rectangle {
                            width: brightnessSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Theme.colAccent
                        }
                    }

                    handle: Rectangle {
                        x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
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
    }

    Rectangle {
        id: kbdBrightnessCard
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 360
        Layout.preferredHeight: 64
        radius: 10
        color: "transparent"
        border.width: Config.data.borderSize
        border.color: Theme.colAccent

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colAccent
                size: 16
                text: "󰌌"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Row {
                    spacing: 5

                    Text {
                        text: "Keyboard"
                        color: Theme.colText
                        font.pixelSize: 11
                    }

                    Text {
                        text: Math.round(kbdBrightnessSlider.value * 100) + "%"
                        color: Theme.colAccent
                        font.pixelSize: 11
                    }
                }

                Slider {
                    id: kbdBrightnessSlider
                    Layout.fillWidth: true
                    implicitHeight: 16
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
                        width: kbdBrightnessSlider.availableWidth
                        height: 5
                        radius: 3
                        color: Qt.alpha(Theme.colAccent, 0.2)

                        Rectangle {
                            width: kbdBrightnessSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Theme.colAccent
                        }
                    }

                    handle: Rectangle {
                        x: kbdBrightnessSlider.leftPadding + kbdBrightnessSlider.visualPosition * (kbdBrightnessSlider.availableWidth - width)
                        y: kbdBrightnessSlider.topPadding + kbdBrightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
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

    Item {
        Layout.fillHeight: true
    }
}
