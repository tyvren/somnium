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

    property int btnTextSize: 20
    property int artistTextSize: 12
    property int titleTextSize: 12
    property int albumWidth: 100
    property int albumHeight: 100

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
        radius: Config.data.rounding
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

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: albumArt
            width: root.albumWidth
            height: root.albumHeight
            Layout.alignment: Qt.AlignHCenter

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
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            StyledButton {
                id: prevText
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                color: "transparent"
                borderColor: "transparent" 
                textSize: root.btnTextSize
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
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                color: "transparent"
                borderColor: "transparent" 
                textSize: root.btnTextSize
                text: Players.active && Players.active.isPlaying ? "" : ""
                onClicked: {
                    if (Players.active) {
                        Players.active.togglePlaying()
                    }
                }
            }

            StyledButton {
                id: nextText
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                color: "transparent"
                borderColor: "transparent" 
                textSize: root.btnTextSize
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
            Layout.alignment: Qt.AlignHCenter
            color: Theme.colAccent
            size: root.artistTextSize
            text: Players.active ? (Players.active.trackArtist) : "No media playing"
            elide: Text.ElideRight
        }

        StyledText {
            id: titleText
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width
            Layout.leftMargin: 5
            color: Theme.colAccent
            size: root.titleTextSize
            bold: true
            text: Players.active ? (Players.active.trackTitle) : ""
            elide: Text.ElideRight
        }
    }
}

