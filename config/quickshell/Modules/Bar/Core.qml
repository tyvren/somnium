import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Components
import qs.Themes

PanelWindow {
    id: core 
    anchors {
        left: true
    }
    color: "transparent"
    implicitWidth: 110
    implicitHeight: 240
    exclusionMode: ExclusionMode.Ignore
    
    mask: Region { 
        item: interactiveContent
    }

    property bool open: false
    property bool showButtons: false

    Item {
        id: interactiveContent
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: core.open ? parent.width : 30

        RectangularShadow {
            id: coreAreaShadow
            anchors.fill: coreArea
            color: Theme.colAccent
            height: coreArea.height
            width: coreArea.width
            radius: 150
            blur: 5
            spread: 1
        }

        Rectangle {
            id: coreArea
            color: Theme.colBg
            border.color: Theme.colAccent
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            x: -52
            width: 80
            height: 80
            radius: 150
            scale: 1

            RotationAnimation on rotation {
                id: spinAnim
                running: false
                loops: 1
                from: 0
                to: -360
                duration: 6000
            }

            RotationAnimation on rotation {
                id: infiniteSpinAnim
                running: false
                loops: Animation.Infinite
                from: 0
                to: -360
                duration: 6000
            }

            Image {
                id: logo
                anchors.fill: coreArea
                source: Theme.logoPath
                mipmap: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: coreAreaMouse
                anchors.fill: coreArea
                hoverEnabled: true
                onEntered: {
                    if (!core.open) {
                        spinAnim.start()
                    }
                }
                onClicked: {
                    core.open = !core.open
                }
            }

            states: [
                State {
                    name: "closed"
                    when: !core.open
                    PropertyChanges {
                        target: coreArea
                        scale: 1
                    }
                },
                State {
                    name: "open"
                    when: core.open
                    PropertyChanges {
                        target: coreArea
                        scale: 3
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "closed"
                    to: "open"
                    SequentialAnimation {
                        ScriptAction {
                            script: { 
                                infiniteSpinAnim.start()
                            }
                        }
                        NumberAnimation {
                            properties: "scale"
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                        ScriptAction {
                            script: {
                                core.showButtons = true
                            }
                        }
                    }
                },
                Transition {
                    from: "open"
                    to: "closed"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                infiniteSpinAnim.stop()
                                spinAnim.start()
                                core.showButtons = false
                            }
                        }
                        NumberAnimation {
                            properties: "scale"
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            ]
        }

        Loader {
            id: buttonLoader
            active: core.showButtons
            anchors.fill: parent
            sourceComponent: Component {
                Item {
                    id: buttons
                    property bool ready: false
                    Component.onCompleted: ready = true

                    StyledButton {
                        id: appsButton
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        buttonWidth: 40
                        buttonHeight: 40
                        text: "󰀻"
                        onClicked: {
                            core.open = false
                            appsProcess.startDetached()
                        }
                        opacity: (buttons.ready && core.open && coreArea.scale === 3) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 250 }
                        }
                    }

                    StyledButton {
                        id: lockButton
                        anchors.top: parent.top
                        anchors.topMargin: 55
                        anchors.left: parent.left
                        anchors.leftMargin: 40
                        buttonWidth: 40
                        buttonHeight: 40
                        text: ""
                        onClicked: {
                            core.open = false
                            lockProcess.startDetached()
                        }
                        opacity: (buttons.ready && core.open && coreArea.scale === 3) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 250 }
                        }
                    }

                    StyledButton {
                        id: shutdownButton
                        anchors.top: parent.top
                        anchors.topMargin: 96
                        anchors.left: parent.left
                        anchors.leftMargin: 56
                        buttonWidth: 40
                        buttonHeight: 40
                        text: ""
                        onClicked: {
                            core.open = false
                            shutdownProcess.startDetached()
                        }
                        opacity: (buttons.ready && core.open && coreArea.scale === 3) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 250 }
                        }
                    }

                    StyledButton {
                        id: restartButton
                        anchors.top: parent.top
                        anchors.topMargin: 145
                        anchors.left: parent.left
                        anchors.leftMargin: 40
                        buttonWidth: 40
                        buttonHeight: 40
                        text: ""
                        onClicked: { 
                            core.open = false
                            restartProcess.startDetached()
                        }
                        opacity: (buttons.ready && core.open && coreArea.scale === 3) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 250 }
                        }
                    }

                    StyledButton {
                        id: settingsButton
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 20
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        buttonWidth: 40
                        buttonHeight: 40
                        text: "󰍜"
                        onClicked: {
                            core.open = false
                            settingsProcess.startDetached()
                        }
                        opacity: (buttons.ready && core.open && coreArea.scale === 3) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 250 }
                        }
                    }
                
                    Process { id: appsProcess; command: ["sh", "-c", "qs ipc call launcher open"]}
                    Process { id: lockProcess; command: ["hyprlock"] }
                    Process { id: restartProcess; command: ["systemctl", "reboot"] }
                    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }
                    Process { id: settingsProcess; command: ["sh", "-c", "qs ipc call settingsMenu toggle"]}
                }
            }
        }
    }
}
