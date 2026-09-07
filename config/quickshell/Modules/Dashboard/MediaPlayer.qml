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
    anchors.fill: parent 

    property int btnTextSize: 20
    property int artistTextSize: 12
    property int titleTextSize: 14
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
        opacity: 0.3
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

    RowLayout {
        id: rootRow
        anchors.fill: parent

        ColumnLayout {
            id: leftColumn
            Layout.alignment: Qt.alignLeft
            Layout.leftMargin: 25
            spacing: 10

            Item {
                id: albumArt
                Layout.alignment: Qt.AlignHCenter
                width: root.albumWidth
                height: root.albumHeight

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

            StyledText {
                id: artistText
                Layout.alignment: Qt.AlignHCenter
                color: Theme.colAccent
                size: root.artistTextSize
                text: Players.active ? Players.artist(Players.active) : "No media playing"
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            id: rightColumn
            Layout.alignment: Qt.alignRight
            spacing: 20

            StyledText {
                id: titleText
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 280
                color: Theme.colAccent
                size: root.titleTextSize
                text: Players.active ? Players.title(Players.active) : ""
                elide: Text.ElideRight
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
                    text: Players.isPlaying ? "" : ""
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

            Item {
                id: trackProgressSlider
                Layout.preferredWidth: 260
                Layout.preferredHeight: 32

                property real positionSeconds: Players.active ? Players.active.position : 0
                property real lengthSeconds: Players.active ? Players.length(Players.active) : 0

                RowLayout {
                    anchors.fill: parent
                    spacing: 12

                    StyledText {
                        id: currentTimeText
                        Layout.alignment: Qt.AlignVCenter
                        text: Players.formatTime(trackProgressSlider.positionSeconds)
                        size: 10
                        color: Theme.colAccent
                        opacity: 0.8
                    }

                    Item {
                        id: trackContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property real progressRatio: trackProgressSlider.lengthSeconds > 0 
                            ? Math.min(1.0, Math.max(0.0, trackProgressSlider.positionSeconds / trackProgressSlider.lengthSeconds)) 
                            : 0

                        Rectangle {
                            id: trackBackground
                            anchors.centerIn: parent
                            width: parent.width
                            height: 4
                            radius: height / 2
                            color: Theme.colMuted 

                            Rectangle {
                                id: filledTrack
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * trackContainer.progressRatio
                                radius: parent.radius
                                color: Theme.colAccent
                            }
                        }
                    }

                    StyledText {
                        id: totalTimeText
                        Layout.alignment: Qt.AlignVCenter
                        text: Players.formatTime(trackProgressSlider.lengthSeconds)
                        size: 10
                        color: Theme.colAccent
                        opacity: 0.8
                    }
                }
            }
        }
    }
}
