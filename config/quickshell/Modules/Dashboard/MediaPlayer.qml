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

    property int btnTextSize: 18
    property int artistTextSize: 11
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
        radius: 10
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

    Rectangle {
        id: cardOutline
        anchors.fill: parent
        radius: Config.data.rounding
        color: "transparent"
        border.width: Config.data.borderSize
        border.color: Theme.colAccent
    }

    RowLayout {
        id: rootRow
        anchors.fill: parent
        anchors.margins: 12
        spacing: 24

        Item {
            Layout.fillWidth: true
        }

        ColumnLayout {
            id: leftColumn
            Layout.alignment: Qt.AlignVCenter
            spacing: 10

            Item {
                id: albumArt
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: root.albumWidth
                Layout.preferredHeight: root.albumHeight

                ClippingRectangle {
                    anchors.fill: parent
                    radius: 10
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
                Layout.maximumWidth: root.albumWidth + 40
                size: root.artistTextSize
                text: Players.active ? Players.artist(Players.active) : "No media playing"
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            id: rightColumn
            Layout.alignment: Qt.AlignVCenter
            spacing: 16

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
                spacing: 12

                Rectangle {
                    id: prevButton
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: Config.data.rounding
                    color: prevMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                    border.width: Config.data.borderSize
                    border.color: Theme.colAccent

                    StyledText {
                        anchors.centerIn: parent
                        color: Theme.colAccent
                        size: root.btnTextSize
                        text: "󰒮"
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Players.active) {
                                Players.active.previous()
                            }
                        }
                    }
                }

                Rectangle {
                    id: playButton
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: Config.data.rounding
                    color: playMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                    border.width: Config.data.borderSize
                    border.color: Theme.colAccent

                    StyledText {
                        anchors.centerIn: parent
                        color: Theme.colAccent
                        size: root.btnTextSize
                        text: Players.isPlaying ? "󰏤" : "󰐊"
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Players.active) {
                                Players.active.togglePlaying()
                            }
                        }
                    }
                }

                Rectangle {
                    id: nextButton
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: Config.data.rounding
                    color: nextMouse.containsMouse ? Qt.alpha(Theme.colAccent, 0.2) : "transparent"
                    border.width: Config.data.borderSize
                    border.color: Theme.colAccent

                    StyledText {
                        anchors.centerIn: parent
                        color: Theme.colAccent
                        size: root.btnTextSize
                        text: "󰒭"
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Players.active) {
                                Players.active.next()
                            }
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
                    size: 11
                    color: Theme.colAccent
                }

                Item {
                    id: progressVisual
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 150
                    implicitHeight: 14

                    readonly property real length: Math.max(1, trackProgressContainer.lengthSeconds)
                    readonly property real pos: Math.min(length, Math.max(0, trackProgressContainer.positionSeconds))
                    readonly property real progressRatio: pos / length

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        radius: 2
                        color: Qt.alpha(Theme.colAccent, 0.2)
                    }

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
                    size: 11
                    color: Theme.colAccent
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
