import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Components
import qs.Themes
import qs.Services

Variants {
    model: Quickshell.screens
    delegate: Component {
        Item {
            id: root
            required property var modelData

            PanelWindow {
                id: leftBar
                screen: modelData
                color: "transparent"
                visible: Config.data.sideBarsEnabled
                implicitWidth: 30
                anchors {
                    left: true
                    top: true
                    bottom: true
                }

                Shape {
                    id: leftBarShape
                    anchors.fill: parent
                    layer.enabled: true
                    layer.samples: 5

                    ShapePath {
                        strokeWidth: Config.data.borderSize
                        strokeColor: "transparent"
                        fillColor: Theme.colBg

                        startX: 0
                        startY: 0

                        PathCubic {
                            x: 28
                            y: 50
                            control1X: 5
                            control1Y: 30
                            control2X: 28
                            control2Y: 35
                        }
                        PathLine {
                            x: 28
                            y: leftBar.height - 50
                        }
                        PathCubic {
                            x: 0
                            y: leftBar.height
                            control1X: 28
                            control1Y: leftBar.height - 35
                            control2X: 5
                            control2Y: leftBar.height - 30
                        }
                        PathLine {
                            x: 0
                            y: 0
                        }
                    }
                }

                Shape {
                    id: leftBarOutline
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeWidth: Config.data.borderSize
                        strokeColor: Theme.colAccent
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        startX: 0
                        startY: 0

                        PathCubic { 
                            x: 27
                            y: 50 
                            control1X: 5
                            control1Y: 30 
                            control2X: 27 
                            control2Y: 35 
                        }
                        PathLine { 
                            x: 27
                            y: leftBar.height - 50 
                        }
                        PathCubic { 
                            x: 0
                            y: leftBar.height
                            control1X: 27
                            control1Y: leftBar.height - 35
                            control2X: 5
                            control2Y: leftBar.height - 30 
                        }
                    }
                }

                Item {
                    id: leftBarContent
                    anchors.fill: parent
                }
            }

            PanelWindow {
                id: rightBar
                screen: modelData
                color: "transparent"
                visible: Config.data.sideBarsEnabled
                implicitWidth: 30
                anchors {
                    right: true
                    top: true
                    bottom: true
                }

                Shape {
                    id: rightBarShape
                    anchors.fill: parent
                    layer.enabled: true
                    layer.samples: 5

                    ShapePath {
                        strokeWidth: Config.data.borderSize
                        strokeColor: "transparent"
                        fillColor: Theme.colBg

                        startX: rightBar.width
                        startY: 0

                        PathCubic {
                            x: rightBar.width - 28
                            y: 50
                            control1X: rightBar.width - 5
                            control1Y: 30
                            control2X: rightBar.width - 28
                            control2Y: 35
                        }
                        PathLine {
                            x: rightBar.width - 28
                            y: rightBar.height - 50
                        }
                        PathCubic {
                            x: rightBar.width
                            y: rightBar.height
                            control1X: rightBar.width - 28
                            control1Y: rightBar.height - 35
                            control2X: rightBar.width - 5
                            control2Y: rightBar.height - 30
                        }
                        PathLine {
                            x: rightBar.width
                            y: 0
                        }
                    }
                }

                Shape {
                    id: rightBarOutline
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeWidth: Config.data.borderSize
                        strokeColor: Theme.colAccent
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        startX: rightBar.width
                        startY: 0

                        PathCubic { 
                            x: rightBar.width - 27
                            y: 50; control1X: rightBar.width - 5
                            control1Y: 30
                            control2X: rightBar.width - 27
                            control2Y: 35 
                        }
                        PathLine { 
                            x: rightBar.width - 27
                            y: rightBar.height - 50 
                        }
                        PathCubic { 
                            x: rightBar.width
                            y: rightBar.height
                            control1X: rightBar.width - 27
                            control1Y: rightBar.height - 35
                            control2X: rightBar.width - 5
                            control2Y: rightBar.height - 30 
                        }
                    }
                }

                Item {
                    id: rightBarContent
                    anchors.fill: parent

                }
            }
            LazyLoader {
                active: Config.data.sideBarsEnabled
                //Core {}
            }
        }
    }
}
