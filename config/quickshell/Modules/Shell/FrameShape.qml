import QtQuick
import QtQuick.Shapes
import qs.Themes

Item {
    id: frameShape
    anchors.fill: parent

    required property var frameWindow

    readonly property string innerContourPath: buildInnerContourPath()
    readonly property string filledFramePath: moveTo(0, 0) + lineTo(0, frameWindow.height) + lineTo(frameWindow.width, frameWindow.height) + lineTo(frameWindow.width, 0) + "Z " + innerContourPath

    function point(x: real, y: real): string {
        return x.toFixed(2) + " " + y.toFixed(2)
    }

    function moveTo(x: real, y: real): string {
        return "M " + point(x, y) + " "
    }

    function lineTo(x: real, y: real): string {
        return "L " + point(x, y) + " "
    }

    function curveTo(control1X: real, control1Y: real, control2X: real, control2Y: real, x: real, y: real): string {
        return "C " + point(control1X, control1Y) + " " + point(control2X, control2Y) + " " + point(x, y) + " "
    }

    function shoulderCurveTo(wallX: real, wallY: real, cornerX: real, cornerY: real, towardCorner: bool): string {
        const verticalSpan = cornerY - wallY
        const nearWallY = wallY + verticalSpan * 0.3
        const nearCornerX = cornerX + (wallX - cornerX) * 0.02
        const nearCornerY = wallY + verticalSpan * 0.4

        if (towardCorner)
            return curveTo(wallX, nearWallY, nearCornerX, nearCornerY, cornerX, cornerY)
        return curveTo(nearCornerX, nearCornerY, wallX, nearWallY, wallX, wallY)
    }

    function buildInnerContourPath(): string {
        const innerLeft = frameWindow.rimThickness
        const innerRight = frameWindow.width - frameWindow.rimThickness
        const innerTop = frameWindow.rimThickness
        const innerBottom = frameWindow.height - frameWindow.rimThickness
        const shoulderTopY = innerTop + frameWindow.sidebarShoulderLength
        const shoulderBottomY = innerBottom - frameWindow.sidebarShoulderLength
        const dashboardBottomY = Math.max(frameWindow.dashboardClosedHeight, frameWindow.dashboardHeight)
        const dashboardDrop = dashboardBottomY - innerTop
        const flare = frameWindow.dashboardFlare
        const dashboardLeft = frameWindow.dashboardLeft
        const dashboardRight = frameWindow.dashboardRight
        const leftWallX = frameWindow.leftWallX
        const rightWallX = frameWindow.rightWallX

        return moveTo(innerLeft, innerTop)
            + lineTo(dashboardLeft, innerTop)
            + curveTo(dashboardLeft + flare * 0.6, innerTop + dashboardDrop * 0.18,
                      dashboardLeft + flare * 0.7, dashboardBottomY,
                      dashboardLeft + flare, dashboardBottomY)
            + lineTo(dashboardRight - flare, dashboardBottomY)
            + curveTo(dashboardRight - flare * 0.7, dashboardBottomY,
                      dashboardRight - flare * 0.6, innerTop + dashboardDrop * 0.18,
                      dashboardRight, innerTop)
            + lineTo(innerRight, innerTop)
            + shoulderCurveTo(rightWallX, shoulderTopY, innerRight, innerTop, false)
            + lineTo(rightWallX, shoulderBottomY)
            + shoulderCurveTo(rightWallX, shoulderBottomY, innerRight, innerBottom, true)
            + lineTo(innerLeft, innerBottom)
            + shoulderCurveTo(leftWallX, shoulderBottomY, innerLeft, innerBottom, false)
            + lineTo(leftWallX, shoulderTopY)
            + shoulderCurveTo(leftWallX, shoulderTopY, innerLeft, innerTop, true)
    }

    Shape {
        id: frameFill
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 5
        transform: Scale {
            origin.y: frameFill.height / 2
            yScale: frameShape.frameWindow.dashboardAtBottom ? -1 : 1
        }

        ShapePath {
            fillRule: ShapePath.WindingFill
            fillColor: Theme.colBg
            strokeWidth: -1

            PathSvg {
                path: frameShape.filledFramePath
            }
        }
    }

    Shape {
        id: frameOutline
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        transform: Scale {
            origin.y: frameOutline.height / 2
            yScale: frameShape.frameWindow.dashboardAtBottom ? -1 : 1
        }

        ShapePath {
            strokeWidth: frameShape.frameWindow.borderWidth
            strokeColor: Theme.colAccent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg {
                path: frameShape.innerContourPath
            }
        }
    }
}
