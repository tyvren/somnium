import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Themes
import qs.Services

ColumnLayout {
    id: keybinds 
    spacing: 20
    Layout.fillWidth: true

    property string mainMod: Config.data.mainMod
    property string terminal: Config.data.terminal
    property string fileManager: Config.data.fileManager
    property string appLauncher: Config.data.appLauncher
    property string killActive: Config.data.killActive
    property string toggleFloating: Config.data.toggleFloating
    property string toggleSplit: Config.data.toggleSplit
    property string pseudo: Config.data.pseudo 
    property string lockScreen: Config.data.lockScreen
    property string screenshot: Config.data.screenshot
    property string enableIdle: Config.data.enableIdle
    property string disableIdle: Config.data.disableIdle

    property string focusLeft: Config.data.focusLeft
    property string focusRight: Config.data.focusRight
    property string focusUp: Config.data.focusUp
    property string focusDown: Config.data.focusDown

    ColumnLayout {
        spacing: 10
        Layout.fillWidth: true

        StyledText {
            text: "Keybinds"
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
                text: "General Bindings" 
                color: Theme.colAccent
                size: 10 
                bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Main Modifier"
                    Layout.fillWidth: true 
                }

                StyledInput { 
                    text: keybinds.mainMod
                    onUserEdited: (val) => keybinds.mainMod = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Terminal"
                    Layout.fillWidth: true 
                }
                
                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                }
                
                StyledInput { 
                    text: keybinds.terminal
                    onUserEdited: (val) => keybinds.terminal = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "File Manager"
                    Layout.fillWidth: true 
                }
                
                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent 
                }

                StyledInput { 
                    text: keybinds.fileManager
                    onUserEdited: (val) => keybinds.fileManager = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "App Launcher" 
                    Layout.fillWidth: true 
                }
                
                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.appLauncher
                    onUserEdited: (val) => keybinds.appLauncher = val 
                }
            }
        }

        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            StyledText { 
                text: "Window Management" 
                color: Theme.colAccent
                size: 10 
                bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Kill Active"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.killActive
                    onUserEdited: (val) => keybinds.killActive = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Toggle Floating"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.toggleFloating
                    onUserEdited: (val) => keybinds.toggleFloating = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Toggle Split"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.toggleSplit
                    onUserEdited: (val) => keybinds.toggleSplit = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Pseudo"
                    Layout.fillWidth: true 
                }
                
                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.pseudo
                    onUserEdited: (val) => keybinds.pseudo = val 
                }
            }
        }

        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            StyledText { 
                text: "System Controls" 
                color: Theme.colAccent 
                size: 10 
                bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Lock Screen"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.lockScreen
                    onUserEdited: (val) => keybinds.lockScreen = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Screenshot"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.screenshot
                    onUserEdited: (val) => keybinds.screenshot = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Enable Idle"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod + SHIFT +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.enableIdle
                    onUserEdited: (val) => keybinds.enableIdle = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Disable Idle"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.disableIdle
                    onUserEdited: (val) => keybinds.disableIdle = val 
                }
            }
        }

        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            StyledText { 
                text: "Navigation" 
                color: Theme.colAccent
                size: 10 
                bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Focus Left"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.focusLeft
                    onUserEdited: (val) => keybinds.focusLeft = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Focus Right"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent 
                    size: 11
                }

                StyledInput { 
                    text: keybinds.focusRight
                    onUserEdited: (val) => keybinds.focusRight = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Focus Up"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent 
                    size: 11
                }

                StyledInput { 
                    text: keybinds.focusUp
                    onUserEdited: (val) => keybinds.focusUp = val 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                StyledText { 
                    text: "Focus Down"
                    Layout.fillWidth: true 
                }

                StyledText {
                    text: "mainMod +"
                    color: Theme.colAccent
                    size: 11
                }

                StyledInput { 
                    text: keybinds.focusDown
                    onUserEdited: (val) => keybinds.focusDown = val 
                }
            }
        }
    }

    Item { 
        Layout.fillHeight: true 
    }

    StyledButton {
        text: "Apply"
        Layout.alignment: Qt.AlignRight
        Layout.preferredWidth: 90
        Layout.preferredHeight: 35
        textSize: 10

        onClicked: {
            Config.data.mainMod = keybinds.mainMod
            Config.data.terminal = keybinds.terminal
            Config.data.fileManager = keybinds.fileManager
            Config.data.appLauncher = keybinds.appLauncher
            Config.data.killActive = keybinds.killActive
            Config.data.toggleFloating = keybinds.toggleFloating
            Config.data.toggleSplit = keybinds.toggleSplit
            Config.data.pseudo = keybinds.pseudo
            Config.data.lockScreen = keybinds.lockScreen
            Config.data.screenshot = keybinds.screenshot
            Config.data.enableIdle = keybinds.enableIdle
            Config.data.disableIdle = keybinds.disableIdle
            Config.data.focusLeft = keybinds.focusLeft
            Config.data.focusRight = keybinds.focusRight
            Config.data.focusUp = keybinds.focusUp
            Config.data.focusDown = keybinds.focusDown

            Quickshell.execDetached([
                Config.installDir + "/modules/quickshell/qs_apply_keybinds.sh",
                keybinds.mainMod,
                keybinds.terminal,
                keybinds.fileManager,
                keybinds.appLauncher,
                keybinds.killActive,
                keybinds.toggleFloating,
                keybinds.toggleSplit,
                keybinds.pseudo,
                keybinds.lockScreen,
                keybinds.screenshot,
                keybinds.enableIdle,
                keybinds.disableIdle,
                keybinds.focusLeft,
                keybinds.focusRight,
                keybinds.focusUp,
                keybinds.focusDown
            ]);
        }
    }
}
