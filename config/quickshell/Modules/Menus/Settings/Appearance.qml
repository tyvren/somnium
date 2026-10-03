import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Components
import qs.Themes
import qs.Services

ScrollView {
    id: scrollRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    ColumnLayout {
        id: appearancePane
        width: scrollRoot.width
        spacing: 15

        property string barLayout: Config.data.barLayout
        property bool sysMonitor: Config.data.sysMonitor === "true"
        property string theme: Config.data.theme

        function applyHypr() {
            Quickshell.execDetached([
                Quickshell.env("HOME") + "/.config/somnium/modules/quickshell/qs_apply_hyprland.sh",
                Config.data.gapsIn.toString(),
                Config.data.gapsOut.toString(),
                Config.data.windowBorderSize.toString(),
                Config.data.rounding.toString(),
                Config.data.activeOpacity.toString(),
                Config.data.inactiveOpacity.toString(),
                Config.data.allowTearing.toString(),
                Config.data.shadowEnabled.toString(),
                Config.data.blurEnabled.toString(),
                Config.data.blurSize.toString(),
                Config.data.blurPasses.toString(),
                Config.data.disableHyprlandLogo.toString(),
                Config.data.forceDefaultWallpaper.toString()
            ]);
        }

        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true

            StyledText {
                text: "Appearance"
                color: Theme.colAccent
                size: 16
            }

            DividerLine {
                Layout.fillWidth: true
            }
        }

        GridLayout {
            columns: 2
            rowSpacing: 30
            columnSpacing: 60
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                StyledText {
                    text: "General Layout"
                    color: Theme.colAccent
                    size: 12
                    bold: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Gaps In"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.gapsIn
                        fromValue: 0
                        toValue: 20
                        stepSizeValue: 1
                        onMoved: (val) => { Config.data.gapsIn = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: gapsInTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10
                        
                        StyledText {
                            text: Config.data.gapsIn
                            anchors.centerIn: parent
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Gaps Out"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.gapsOut
                        fromValue: 0 
                        toValue: 20
                        stepSizeValue: 1
                        onMoved: (val) => { Config.data.gapsOut = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: gapsOutTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.gapsOut
                            anchors.centerIn: parent
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Window Border Size"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.windowBorderSize
                        fromValue: 0
                        toValue: 2
                        stepSizeValue: 1
                        onMoved: (val) => { Config.data.windowBorderSize = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: windowBSizeTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.windowBorderSize
                            anchors.centerIn: parent
                        }
                    }
                }
                  
                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Shell Border Size"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.borderSize
                        fromValue: 0
                        toValue: 2
                        stepSizeValue: 0.10
                        onMoved: (val) => { Config.data.borderSize = val; }
                    }

                    Rectangle {
                        id: shellBorderSizeTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.borderSize
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.rightMargin: 5

                StyledText {
                    text: "Decoration"
                    color: Theme.colAccent
                    size: 12
                    bold: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Rounding"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.rounding
                        fromValue: 0
                        toValue: 20
                        stepSizeValue: 1
                        onMoved: (val) => { Config.data.rounding = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: roundingTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.rounding
                            anchors.centerIn: parent
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Active Window Opacity"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.activeOpacity
                        fromValue: 0.5
                        toValue: 1.0
                        stepSizeValue: 0.1
                        onMoved: (val) => { Config.data.activeOpacity = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: activeOpacityTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.activeOpacity.toFixed(1)
                            anchors.centerIn: parent
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Inactive Window Opacity"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.inactiveOpacity
                        fromValue: 0.2
                        toValue: 1.0
                        stepSizeValue: 0.1
                        onMoved: (val) => { Config.data.inactiveOpacity = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: inactiveOpacityTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.inactiveOpacity.toFixed(1)
                            anchors.centerIn: parent
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Shell Transparency"
                        color: Theme.colText
                        Layout.fillWidth: true
                      }

                    StyledSlider {
                        inputValue: Config.data.qsTransparency
                        fromValue: 0.0
                        toValue: 0.9
                        stepSizeValue: 0.05
                        onMoved: (val) => { Config.data.qsTransparency = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: shellTransparencyTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.qsTransparency.toFixed(2)
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                StyledText {
                    text: "Blur Settings"
                    color: Theme.colAccent
                    size: 12
                    bold: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Blur Enabled"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        checked: Config.data.blurEnabled
                        onToggled: { Config.data.blurEnabled = checked; appearancePane.applyHypr(); }
                        Layout.alignment: Qt.AlignRight
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    opacity: Config.data.blurEnabled ? 1.0 : 0.4
                    enabled: Config.data.blurEnabled

                    StyledText {
                        text: "Blur Size"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.blurSize
                        fromValue: 0
                        toValue: 5
                        stepSizeValue: 1
                        onMoved: (val) => { Config.data.blurSize = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: blurSizeTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.blurSize
                            anchors.centerIn: parent
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    opacity: Config.data.blurEnabled ? 1.0 : 0.4
                    enabled: Config.data.blurEnabled

                    StyledText {
                        text: "Blur Passes"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSlider {
                        inputValue: Config.data.blurPasses
                        fromValue: 0
                        toValue: 5
                        stepSizeValue: 1
                        onMoved: (val) => { Config.data.blurPasses = val; appearancePane.applyHypr(); }
                    }

                    Rectangle {
                        id: blurPassesTextContainer
                        width: 20
                        height: 10
                        color: "transparent"
                        Layout.leftMargin: 10

                        StyledText {
                            text: Config.data.blurPasses
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                StyledText {
                    text: "Miscellaneous"
                    color: Theme.colAccent
                    size: 12
                    bold: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Tearing"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        checked: Config.data.allowTearing
                        onToggled: { Config.data.allowTearing = checked; appearancePane.applyHypr(); }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Shadows"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        checked: Config.data.shadowEnabled
                        onToggled: { Config.data.shadowEnabled = checked; appearancePane.applyHypr(); }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Hyprland Logo"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        checked: !Config.data.disableHyprlandLogo
                        onToggled: { Config.data.disableHyprlandLogo = !checked; appearancePane.applyHypr(); }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Force Default Wallpaper"
                        color: Theme.colText
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        checked: Config.data.forceDefaultWallpaper === 1
                        onToggled: { Config.data.forceDefaultWallpaper = checked ? 1 : 0; appearancePane.applyHypr(); }
                    }
                }
            }
        }

        DividerLine {
            Layout.fillWidth: true
        }

        StyledText {
            text: "Bar Layout"
            color: Theme.colAccent
            size: 12
            bold: true
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: [
                    { name: "Top Bar", value: "top", icon: "󱔓" },
                    { name: "Bottom Bar", value: "bottom", icon: "󱂩" }
                ]

                StyledButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: modelData.name
                    icon: modelData.icon
                    active: appearancePane.barLayout === modelData.value

                    onClicked: {
                        appearancePane.barLayout = modelData.value
                        Config.data.barLayout = appearancePane.barLayout
                    }
                }
            }
        }

        DividerLine {
            Layout.fillWidth: true
        }

        StyledText {
            text: "Themes"
            color: Theme.colAccent
            size: 12
            bold: true
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: [
                    { name: "Somnium",   themeId: "somnium",   script: "Somnium" },
                    { name: "Mocha",      themeId: "mocha",      script: "Mocha" },
                    { name: "Emberforge", themeId: "emberforge", script: "Emberforge" },
                    { name: "Dracula",    themeId: "dracula",    script: "Dracula" },
                    { name: "Arcadia",    themeId: "arcadia",    script: "Arcadia" },
                    { name: "Eden",       themeId: "eden",       script: "Eden" },
                    { name: "Ghost",      themeId: "ghost",      script: "Ghost" },
                    { name: "Verdant",    themeId: "verdant",    script: "Verdant" }
                ]

                StyledButton {
                    id: btnShell
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: modelData.name
                    active: appearancePane.theme === modelData.themeId

                    onClicked: {
                        Config.updateTheme(modelData.themeId, modelData.script)
                        Config.updateWallpaper("")
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 22
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Repeater {
                            model: [
                                Theme.themes[modelData.themeId].colBg,
                                Theme.themes[modelData.themeId].colAccent,
                                Theme.themes[modelData.themeId].colHilight
                            ]

                            Rectangle {
                                width: 15
                                height: 15
                                radius: Config.data.rounding
                                color: modelData
                                border.color: "white"
                                border.width: Config.data.borderSize
                            }
                        }
                    }
                }
            }
        }
    }
}
