import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Components
import qs.Services
import qs.Themes

ColumnLayout {
    id: wallpaperPane
    spacing: 10

    property bool active: false
    property string currentWallpaper: Config.data.wallpaper
    
    property string wallpaperDir: Config.data.wallpaperDir.slice(7)
    property var wallpaperList: []

    readonly property string folderName: Theme.activeId.charAt(0).toUpperCase() + Theme.activeId.slice(1)
    property string themeWallpaperDir: Quickshell.env("HOME") + "/.config/somnium/wallpapers/" + folderName
    property var themeWallpaperList: []

    Process {
        id: scanWallpapers
        command: ["find", "-L", wallpaperPane.wallpaperDir, "-type", "f", "!", "-name", ".*"]
        running: wallpaperPane.active
        stdout: StdioCollector {
            onStreamFinished: {
                const wallList = text.trim().split('\n').filter(p => p.length > 0);
                wallpaperPane.wallpaperList = wallList;
            }
        }
    }

    Process {
        id: scanThemeWallpapers
        command: ["find", "-L", wallpaperPane.themeWallpaperDir, "-type", "f", "!", "-name", ".*"]
        running: wallpaperPane.active
        stdout: StdioCollector {
            onStreamFinished: {
                const wallList = text.trim().split('\n').filter(p => p.length > 0);
                wallpaperPane.themeWallpaperList = wallList;
            }
        }
    }

    ScrollView {
        id: scrollRoot
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: scrollRoot.width
            spacing: 5

            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                RowLayout {
                    spacing: 10
                    
                    StyledText { 
                        text: "Current Wallpaper"
                        color: Theme.colAccent
                        size: 11
                    }
                }
  
                DividerLine { Layout.fillWidth: true }

                Item {
                  Layout.alignment: Qt.AlignHCenter
                  Layout.preferredHeight: 150
                  Layout.topMargin: 5

                    Rectangle {
                        id: currentWall
                        anchors.centerIn: parent
                        width: 260
                        height: 160
                        color: "transparent"
                        border.color: Theme.colAccent 
                        border.width: Config.data.borderSize
                        radius: Config.data.rounding

                        ClippingRectangle {
                            id: clipCurrentWall
                            anchors.fill: parent 
                            anchors.margins: 2
                            color: "transparent"
                            radius: 15
                    
                            Image {
                                anchors.fill: parent
                                source: "file://" + currentWallpaper
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                RowLayout {
                    spacing: 10
                    
                    StyledText { 
                        text: "Wallpapers"
                        color: Theme.colAccent
                        size: 11
                    }
                    
                    StyledButton {
                        id: directoryPicker
                        buttonWidth: 30
                        buttonHeight: 20
                        icon: "" 
                        onClicked: folderDialog.open()

                        FolderDialog {
                            id: folderDialog
                            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                            selectedFolder: folderDialog.selectedFolder
                            
                            onSelectedFolderChanged: {
                                if (folderDialog.selectedFolder != "") {
                                    Config.data.wallpaperDir = folderDialog.selectedFolder
                                    scanWallpapers.running = true
                                }
                            }
                        }
                    }
                }
                DividerLine { Layout.fillWidth: true }
            }

            GridView {
                id: customGrid
                Layout.fillWidth: true
                Layout.preferredHeight: 320
                interactive: true
                clip: true
                cellWidth:  240
                cellHeight: 140
                model: wallpaperPane.wallpaperList
                delegate: wallpaperDelegate
            }

            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                RowLayout {
                    spacing: 10
                    
                    StyledText { 
                        text: "Theme Wallpapers"
                        color: Theme.colAccent
                        size: 11
                    }
                    
                    StyledText {
                        text: "somnium/wallpapers/" + wallpaperPane.folderName
                        color: Theme.colMuted
                        size: 11 
                    }
                }
                DividerLine { Layout.fillWidth: true }
            }

            GridView {
                id: themeGrid
                Layout.fillWidth: true
                Layout.preferredHeight: 620
                interactive: true
                clip: true
                cellWidth: 240
                cellHeight: 140
                model: wallpaperPane.themeWallpaperList
                delegate: wallpaperDelegate
            }
        }
    }

    Component {
        id: wallpaperDelegate
        Item {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            Rectangle {
                id: imageBox
                anchors.centerIn: parent
                width: 200
                height: 120
                color: "transparent"
                border.color: wallMouse.containsMouse ? Theme.colAccent : "transparent"
                border.width: Config.data.borderSize
                radius: Config.data.rounding

                ClippingRectangle {
                    id: clipImage
                    anchors.fill: imageBox
                    anchors.margins: 2
                    color: "transparent"
                    radius: Config.data.rounding
                    
                    Image {
                        anchors.fill: parent
                        source: "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                MouseArea {
                    id: wallMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Config.updateWallpaper(modelData);
                        Quickshell.execDetached([
                            Quickshell.env("HOME") + "/.config/somnium/modules/style/wallpaper_changer.sh",
                            modelData
                        ]);
                    }
                }
            }
        }
    }
}
