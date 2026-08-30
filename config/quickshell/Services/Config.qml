pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string scriptPath: homeDir + "/.config/somnium/modules/quickshell"
    readonly property string themeScript: homeDir + "/.config/somnium/modules/style"
    readonly property string configPath: Quickshell.shellDir + "/config.json"
    readonly property alias data: adapter

    Process {
        id: syncFromHypr
        command: [root.scriptPath + "/qs_source_hypr.sh"]
        running: true 
    }

    FileView {
        id: stateFileView
        path: root.configPath
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter
            property string theme: "somnium"
            property string wallpaper: ""
            property string wallpaperDir: ""

            property string barLayout: "top"
            property int barMargin: 10

            property int gapsIn: 5
            property int gapsOut: 10
            property int borderSize: 2
            property int rounding: 10
            property real activeOpacity: 1.0
            property real inactiveOpacity: 0.8
            property real qsTransparency: 0.0
            property bool allowTearing: false
            property bool shadowEnabled: true
            property bool blurEnabled: true
            property int blurSize: 8
            property int blurPasses: 2
            property bool disableHyprlandLogo: true
            property int forceDefaultWallpaper: 0
            property string sysMonitor: "true"

            property string mainMod: ""
            property string terminal: ""
            property string fileManager: ""
            property string appLauncher: ""
            property string killActive: ""
            property string toggleFloating: ""
            property string toggleSplit: ""
            property string pseudo: "" 
            property string lockScreen: ""
            property string screenshot: ""
            property string enableIdle: ""
            property string disableIdle: ""

            property string focusLeft: ""
            property string focusRight: ""
            property string focusUp: ""
            property string focusDown: ""
        }

        onLoaded: console.log("Config loaded from: " + root.configPath)
    }

    Component.onCompleted: {
        stateFileView.reload()
    }

    function updateTheme(themeId, scriptName) {
        adapter.theme = themeId
        if (scriptName) {
            Quickshell.execDetached([root.themeScript + "/theme_changer.sh", scriptName])
        }
    }

    function updateWallpaper(wallpaperPath) {
        adapter.wallpaper = wallpaperPath
        Quickshell.execDetached([root.themeScript + "/wallpaper_changer.sh", wallpaperPath])
    }
}
