import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Services
import qs.Themes

ClippingRectangle {
    id: clippingRect
    radius: Config.data.rounding
    color: Theme.colBg
    border.color: Theme.colAccent
    border.width: Config.data.borderSize
}
