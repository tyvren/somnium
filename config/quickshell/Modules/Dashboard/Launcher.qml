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
    id: launcherMenu
    anchors.fill: parent

    property string query: ""
    property var filteredApps: DesktopEntries.applications.values

    onQueryChanged: {
        if (query === "") {
            filteredApps = DesktopEntries.applications.values
        } else {
            filteredApps = DesktopEntries.applications.values.filter(app =>
                app.name.toLowerCase().includes(query.toLowerCase())
            )
        }
    }

    Component.onCompleted: {
        searchField.forceActiveFocus()
    }

    Image {
        id: logoImage
        anchors.centerIn: parent
        width: 400
        height: 375
        source: Theme.logoPath
        mipmap: true
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        opacity: 0.3
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Config.data.barLayout === "top" ? 6 : 10
        anchors.bottomMargin: Config.data.barLayout === "top" ? 10 : 6
        spacing: 20

        Rectangle {
            Layout.row: Config.data.barLayout === "top" ? 0 : 1
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 50
            height: 28
            radius: Config.data.rounding
            color: Theme.colBg
            border.color: Theme.colAccent
            border.width: Config.data.borderSize

            StyledInput {
                id: searchField
                anchors.fill: parent
                text: launcherMenu.query

                onTextChanged: {
                    launcherMenu.query = text
                }

                Keys.onPressed: event => {
                    if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                            && gridview.currentIndex >= 0) {
                        const app = gridview.model[gridview.currentIndex]
                        Quickshell.execDetached({
                            command: ["sh", "-c", app.execute()]
                        })
                        States.dashboardOpen = false
                        event.accepted = true
                    }

                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                        gridview.forceActiveFocus()
                        event.accepted = true
                    }
                }
            }
        }

        GridView {
            id: gridview
            Layout.row: Config.data.barLayout === "top" ? 1 : 0
            Layout.fillHeight: true
            Layout.preferredWidth: 390
            Layout.alignment: Qt.AlignHCenter
            model: launcherMenu.filteredApps
            clip: true
            keyNavigationEnabled: true
            cellWidth: 78
            cellHeight: 85
            currentIndex: launcherMenu.filteredApps.length > 0 ? 0 : -1

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Keys.onPressed: event => {
                if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        && currentIndex >= 0) {
                    const app = model[currentIndex]
                    Quickshell.execDetached({
                        command: ["sh", "-c", app.execute()]
                    })
                    States.dashboardOpen = false
                    event.accepted = true
                }
            }

            delegate: Item {
                id: appDelegate
                width: 70
                height: 70
                property bool isHighlighted: GridView.isCurrentItem || mouseArea.containsMouse

                MultiEffect {
                    anchors.fill: delegateRectangle
                    source: delegateRectangle
                    shadowEnabled: true
                    shadowBlur: appDelegate.isHighlighted ? 0.8 : 0
                    shadowColor: Theme.colAccent
                    shadowVerticalOffset: 1
                    shadowHorizontalOffset: 1
                    opacity: appDelegate.isHighlighted ? 1 : 1
                    
                    Behavior on shadowBlur { NumberAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Rectangle {
                    id: delegateRectangle
                    width: 70
                    height: 70
                    anchors.centerIn: parent
                    radius: Config.data.rounding
                    color: Theme.colBg 
                    border.color: Theme.colAccent
                    border.width: Config.data.borderSize
                    
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width - 15
                        spacing: 5

                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true) || ""
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            Layout.alignment: Qt.AlignHCenter
                        }

                        StyledText {
                            text: modelData.name
                            color: mouseArea.containsMouse ? Theme.colAccent : Theme.colText
                            size: 7
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Quickshell.execDetached({
                                command: ["sh", "-c", modelData.execute()]
                            })
                            States.dashboardOpen = false
                        }
                    }
                }
            }
        }
    }
}
