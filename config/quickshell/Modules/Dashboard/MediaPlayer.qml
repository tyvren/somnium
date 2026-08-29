import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: root
    implicitWidth: 480
    implicitHeight: 28

    Timer {
        id: pauseTimer
        interval: 30000
        repeat: false
        onTriggered: {
            States.mediaPlayerInGracePeriod = false
            States.restoreDefaultState()
        }
    }

    Connections {
        target: Players
        function onIsPlayingChanged() {
            if (Players.isPlaying) {
                pauseTimer.stop()
                States.mediaPlayerInGracePeriod = false
            } else {
                States.mediaPlayerInGracePeriod = true
                pauseTimer.restart()
            }
            States.restoreDefaultState()
        }
    }

    ClippingRectangle {
        id: bgImageContainer
        anchors.fill: parent 
        anchors.margins: 2
        opacity: 0.2
        radius: 2
        color: "transparent"

        Image {
            id: backgroundImage
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            visible: false
            source: {
                const url = Players.active ? Players.active.trackArtUrl : "";
                if (!url || url === "") {
                    return backgroundImage.source;
                }
                return (url.startsWith("/") && !url.startsWith("file://")) ? "file://" + url : url;
            }
        }

        MultiEffect {
            id: bgImageEffect
            anchors.fill: parent
            source: backgroundImage
            blurEnabled: true
            blur: 0.5
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 15
        spacing: 10

        Item {
            id: albumArt
            width: 20
            height: 20
            Layout.alignment: Qt.AlignVCenter

            ClippingRectangle {
                anchors.fill: parent
                radius: 4
                color: "transparent"

                Image {
                    id: albumImage
                    anchors.fill: parent
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    source: {
                        const url = Players.active ? Players.active.trackArtUrl : "";
                        if (!url || url === "") {
                            return albumImage.source;
                        }
                        return (url.startsWith("/") && !url.startsWith("file://")) ? "file://" + url : url;
                    }
                }
            }
        }

        RowLayout {
            id: playerControls
            spacing: 5

            StyledButton {
                id: prevText
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                color: "transparent"
                borderColor: "transparent" 
                textSize: 10
                text: "󰒮"
                onClicked: {
                    if (Players.active) {
                          Players.active.previous()
                    }
                }
            }

            StyledButton {
                id: playText
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                color: "transparent"
                borderColor: "transparent" 
                textSize: 8
                text: Players.active && Players.active.isPlaying ? " " : " "
                onClicked: {
                    if (Players.active) {
                        Players.active.togglePlaying()
                    }
                }
            }

            StyledButton {
                id: nextText
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                color: "transparent"
                borderColor: "transparent" 
                textSize: 10
                text: "󰒭"
                onClicked: {
                    if (Players.active) {
                        Players.active.next()
                    }
                }
            }
        }

        StyledText {
            id: artistText
            Layout.alignment: Qt.AlignVCenter
            color: Theme.colAccent
            size: 10
            text: Players.active ? (Players.active.trackArtist) : ""
            elide: Text.ElideRight
        }

        StyledText {
            id: titleText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: Theme.colAccent
            size: 10
            bold: true
            text: Players.active ? (Players.active.trackTitle) : ""
            elide: Text.ElideRight
        }
    }
}

