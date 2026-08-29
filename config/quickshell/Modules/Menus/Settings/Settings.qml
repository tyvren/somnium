import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Components
import qs.Services
import qs.Themes

FloatingWindow {
    id: settingsMenu
    visible: false
    implicitWidth: 825
    implicitHeight: 900
    color: "transparent"
    property int activeIndex: 0

    onClosed: (close) => {
        visible = false
    }

    IpcHandler {
        target: "settingsMenu"
    
        function toggle(): void { 
            if (!settingsMenu.visible) {
                settingsMenu.activeIndex = 0
            }
            settingsMenu.visible = !settingsMenu.visible 
        }

        function openTo(index: int): void {
            settingsMenu.activeIndex = index
            settingsMenu.visible = true
        }
    }

    Rectangle {
        id: menuWindow
        anchors.fill: parent
        width: 825
        height: 900
        color: Theme.colBg

        RowLayout {
            anchors.centerIn: parent
            spacing: 10
            width: parent.width - 30
            height: parent.height - 30

            Rectangle {
                id: sidePane
                color: Theme.colBg
                border.color: Theme.colAccent
                border.width: Config.data.borderSize
                Layout.preferredWidth: 203
                Layout.fillHeight: true
                radius: Config.data.rounding

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.topMargin: 10
                            anchors.leftMargin: 2
                            anchors.rightMargin: 2
                            spacing: 10

                            Repeater {
                                model: [ 
                                    {icon: "", text: "About"},
                                    {icon: "", text: "Appearance"},
                                    {icon: "", text: "Apps"},
                                    {icon: "", text: "Audio"},
                                    {icon: "", text: "Bluetooth"},
                                    {icon: "󰍹", text: "Displays"},
                                    {icon: "", text: "Keybinds"},
                                    {icon: "󰖩", text: "Network"},
                                    {icon: "󰒃", text: "Security"},
                                    {icon: "󰚰", text: "Updates"},
                                    {icon: "󰸉", text: "Wallpaper"},
                                ]

                                StyledButtonLeftText {
                                    width: parent.width
                                    icon: modelData.icon
                                    text: modelData.text
                                    active: settingsMenu.activeIndex === index
                                    onClicked: settingsMenu.activeIndex = index
                                }
                            }
                        }
                    }

                    DividerLine {
                        Layout.fillWidth: true
                    }

                    StyledButtonLeftText {
                        icon: "" 
                        text: "Close"
                        onClicked: settingsMenu.visible = false
                    }
                }
            }

            Rectangle {
                id: contentPane
                color: Theme.colBg
                border.color: Theme.colAccent
                border.width: Config.data.borderSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Config.data.rounding

                LazyLoader {
                    id: menuLoader
                    active: settingsMenu.visible
                    
                    StackLayout {
                        parent: contentPane
                        anchors.fill: parent
                        anchors.margins: 20
                        currentIndex: settingsMenu.activeIndex

                        SystemInfo {
                            active: settingsMenu.visible && settingsMenu.activeIndex === 0
                        }
                        Appearance {}
                        AppSettings {}
                        AudioSettings {}
                        BluetoothSettings {}
                        DisplaySettings {
                            active: settingsMenu.visible && settingsMenu.activeIndex === 5
                        }
                        Keybinds {}  
                        NetworkSettings {}
                        Security {}
                        UpdateSettings {}
                        WallpaperSettings {
                            active: settingsMenu.visible && settingsMenu.activeIndex === 10
                        }
                    }
                }
            }
        }
    }
}
