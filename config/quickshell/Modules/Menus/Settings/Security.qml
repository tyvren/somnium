import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Themes
import qs.Services

ColumnLayout {
    id: securityPane
    spacing: 10

    property string scriptDir: Config.installDir + "/modules/security/"

    StyledText {
        text: "System Security"
        color: Theme.colAccent
        size: 16
    }

    DividerLine {
        Layout.fillWidth: true
    }

    ColumnLayout {
        spacing: 10
        Layout.fillWidth: true

        Repeater {
            model: [{ 
                name: "Enroll Fingerprint", 
                icon: "󰈷", 
                isImage: false, 
                message: " - enrolls fingerprint with fprintd", 
                script: "fprintd_enroll.sh" 
            }]

            StyledButtonLeftText {
                id: btn
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                
                icon: ""
                text: ""

                onClicked: {
                    proc.startDetached()
                }

                StyledText {
                    id: fontIcon
                    visible: !modelData.isImage
                    text: modelData.icon
                    size: 14
                    color: btn.active ? Theme.colAccent : Theme.colText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                }

                Image {
                    id: imageIcon
                    visible: modelData.isImage
                    source: modelData.isImage ? modelData.icon : ""
                    width: 16
                    height: 16
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    asynchronous: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 13
                }

                RowLayout {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 14

                    StyledText {
                        text: modelData.name
                        size: 12
                        color: btn.active ? Theme.colAccent : Theme.colText
                    }

                    StyledText {
                        text: modelData.message
                        size: 11
                        color: btn.active ? Theme.colAccent : Theme.colText
                        opacity: 0.4
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                Process {
                    id: proc
                    command: ["sh", "-c", "ghostty -e " + securityPane.scriptDir + modelData.script]
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
