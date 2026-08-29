import QtQuick
import Quickshell
import qs.Services
import qs.Themes

Rectangle {
    id: styledRect
    radius: Config.data.rounding
    color: Theme.colBg
    border.color: Theme.colAccent
    border.width: Config.data.borderSize
}
