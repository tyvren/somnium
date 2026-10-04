import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services
import qs.Themes

ColumnLayout {
    id: displayPane
    spacing: 20

    property bool active: false
    property var monitors: []
    property int selectedMonitorIdx: 0

    property string currentMode: ""
    property string currentPos: "auto"
    property string currentScale: "1"
    property string currentGdk: "1"

    function updateCurrentSettings() {
        if (monitors.length > 0 && monitors[selectedMonitorIdx]) {
            let m = monitors[selectedMonitorIdx];
            currentMode = m.width + "x" + m.height + "@" + m.refreshRate.toFixed(2) + "Hz";
            currentPos = "auto"
            currentScale = m.scale.toString();
        }
    }

    onSelectedMonitorIdxChanged: updateCurrentSettings()

    Process {
        id: getMonitors
        command: ["hyprctl", "monitors", "-j"]
        running: displayPane.active
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    displayPane.monitors = JSON.parse(text);
                    displayPane.updateCurrentSettings();
                } catch(e) {}
            }
        }
    }

    ColumnLayout {
        spacing: 10
        Layout.fillWidth: true

        StyledText {
            text: "Display Configuration"
            color: Theme.colAccent
            size: 16
        }

        DividerLine {
            Layout.fillWidth: true
        }
    }

    RowLayout {
        spacing: 15
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        Repeater {
            model: displayPane.monitors

            Item {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter

                MultiEffect {
                    anchors.fill: monitorRect
                    source: monitorRect
                    shadowEnabled: true
                    shadowBlur: 0.2
                    shadowColor: Theme.colAccent
                    shadowVerticalOffset: 1
                    shadowHorizontalOffset: 0
                    opacity: 0.8
                }

                Rectangle {
                    id: monitorRect
                    anchors.fill: parent
                    radius: Config.data.rounding
                    color: (displayPane.selectedMonitorIdx === index || monitorMa.containsMouse) ? Theme.colAccent : Theme.colMuted
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize 

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        StyledText {
                            text: modelData.name
                            color: (displayPane.selectedMonitorIdx === index || monitorMa.containsMouse) ? Theme.colBg : Theme.colText
                            bold: true
                            size: 11
                            Layout.alignment: Qt.AlignHCenter
                        }

                        StyledText {
                            text: modelData.width + "x" + modelData.height
                            color: (displayPane.selectedMonitorIdx === index || monitorMa.containsMouse) ? Theme.colBg : Theme.colText
                            size: 9
                            Layout.alignment: Qt.AlignHCenter
                        }

                        StyledText {
                            text: modelData.refreshRate.toFixed(2) + "Hz"
                            color: (displayPane.selectedMonitorIdx === index || monitorMa.containsMouse) ? Theme.colBg : Theme.colText
                            size: 8
                            opacity: 0.7
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: monitorMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: displayPane.selectedMonitorIdx = index
                    }
                }
            }
        }
    }

    DividerLine {
        Layout.fillWidth: true
    }

    GridLayout {
        columns: 2
        rowSpacing: 40
        columnSpacing: 80
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "Resolution & Refresh Rate"
                color: Theme.colAccent
                size: 10
            }

            Item {
                Layout.preferredWidth: 220
                Layout.preferredHeight: 35
                Layout.alignment: Qt.AlignHCenter

                ComboBox {
                    id: modeSelector
                    anchors.fill: parent
                    model: displayPane.monitors.length > 0 ? displayPane.monitors[displayPane.selectedMonitorIdx].availableModes : []

                    currentIndex: {
                        if (displayPane.monitors.length === 0 || !displayPane.currentMode) return -1;
                        let modes = displayPane.monitors[displayPane.selectedMonitorIdx].availableModes;
                        for (let i = 0; i < modes.length; i++) {
                            let btnParts = modes[i].split('@');
                            let curParts = displayPane.currentMode.split('@');
                            if (btnParts[0] === curParts[0] && btnParts[1].substring(0,3) === curParts[1].substring(0,3)) return i;
                        }
                        return 0;
                    }

                    onActivated: (index) => { displayPane.currentMode = model[index]; }

                    delegate: ItemDelegate {
                        width: modeSelector.width

                        contentItem: StyledText {
                            text: modelData
                            color: highlighted ? Theme.colBg : Theme.colText
                            size: 10
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: Theme.colMuted
                            opacity: 0.2
                            border.color: Theme.colAccent
                            border.width: Config.data.borderSize 
                            radius: Config.data.rounding
                        }
                    }

                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: modeSelector.displayText
                        size: 11
                    }

                    background: Rectangle {
                        id: modeSelectorBackground
                        color: Theme.colMuted
                        opacity: 0.2
                        radius: Config.data.rounding
                    }

                    popup: Popup {
                        y: modeSelector.height + 5
                        width: modeSelector.width
                        implicitHeight: Math.min(contentItem.implicitHeight, 250)
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: modeSelector.popup.visible ? modeSelector.delegateModel : null
                            currentIndex: modeSelector.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: Theme.colBg
                            border.color: Theme.colAccent
                            radius: Config.data.rounding
                        }
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "Monitor Position"
                color: Theme.colAccent
                size: 10
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: ["auto", "left", "right"]

                    StyledButton {
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 35
                        text: modelData
                        active: displayPane.currentPos === modelData

                        onClicked: displayPane.currentPos = modelData
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "Hyprland Scaling"
                color: Theme.colAccent
                size: 10
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: ["1", "1.5", "2"]

                    StyledButton {
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 35
                        text: modelData
                        active: displayPane.currentScale === modelData

                        onClicked: displayPane.currentScale = modelData
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "GDK App Scaling"
                color: Theme.colAccent
                size: 10
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: ["1", "2"]

                    StyledButton {
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 35
                        text: modelData + "x"
                        active: displayPane.currentGdk === modelData

                        onClicked: displayPane.currentGdk = modelData
                    }
                }
            }
        }
    }

    Item {
        id: menuSpacer
        Layout.fillHeight: true
    }

    StyledButton {
        id: applyBtn
        Layout.alignment: Qt.AlignRight
        Layout.preferredWidth: 90
        Layout.preferredHeight: 35
        text: "Apply"

        onClicked: {
            let monitor = displayPane.monitors[displayPane.selectedMonitorIdx];
            Quickshell.execDetached([
                Quickshell.env("HOME") + "/.config/somnium/modules/quickshell/qs_apply_monitors.sh",
                monitor.name,
                displayPane.currentMode,
                displayPane.currentPos,
                displayPane.currentScale,
                displayPane.currentGdk
            ]);
        }
    }
}
