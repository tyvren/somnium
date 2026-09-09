import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
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
            Layout.alignment: Qt.AlignHCenter
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
            Layout.alignment: Qt.AlignHCenter
            spacing: 33

            StyledText {
                id: titleText
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 220
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

            RowLayout {
                id: trackProgressContainer
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                property real positionSeconds: Players.active ? Players.active.position : 0
                property real lengthSeconds: Players.active ? Players.length(Players.active) : 0

                StyledText {
                    id: currentTimeText
                    Layout.alignment: Qt.AlignVCenter
                    text: Players.formatTime(trackProgressContainer.positionSeconds)
                    size: 10
                    color: Theme.colAccent
                    opacity: 0.8
                }

                Item {
                    id: progressVisual
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 150
                    implicitHeight: 14

                    readonly property real length: Math.max(1, trackProgressContainer.lengthSeconds)
                    readonly property real pos: Math.min(length, Math.max(0, trackProgressContainer.positionSeconds))
                    readonly property real progressRatio: pos / length

                    Item {
                        id: played
                        objectName: "playedWave"
                        width: parent.width * progressVisual.progressRatio
                        height: parent.height
                        clip: true

                        Shape {
                            id: wave
                            objectName: "seekWave"
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: progressVisual.width
                            preferredRendererType: Shape.CurveRenderer

                            property real amplitude: 3
                            Behavior on amplitude { NumberAnimation { duration: 400 } }

                            ShapePath {
                                strokeColor: Theme.colAccent
                                strokeWidth: 3
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathPolyline {
                                    path: {
                                        let points = []
                                        for (let x = 0; x <= wave.width; x += 3) {
                                            points.push(Qt.point(x, 7 + wave.amplitude * Math.sin(x * Math.PI / 14)))
                                        }
                                        return points
                                    }
                                }
                            }
                        }
                    }
                }

                StyledText {
                    id: totalTimeText
                    Layout.alignment: Qt.AlignVCenter
                    text: Players.formatTime(trackProgressContainer.lengthSeconds)
                    size: 10
                    color: Theme.colAccent
                    opacity: 0.8
                }
            }
        }
    }
}
