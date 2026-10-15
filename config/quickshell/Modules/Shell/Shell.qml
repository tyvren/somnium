import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Components
import qs.Modules.Bar
import qs.Modules.Dashboard
import qs.Modules.Menus.Settings
import qs.Services
import qs.Themes

Scope {
    IpcHandler {
        target: "dashboard"

        function openAudio(): void {
            States.dashboardOpen = true
            States.currentView = "audio"
        }

        function openBluetooth(): void {
            States.dashboardOpen = true
            States.currentView = "bluetooth"
        }

        function openLauncher(): void {
            States.dashboardOpen = true
            States.currentView = "launcher"
        }

        function openNetwork(): void {
            States.dashboardOpen = true
            States.currentView = "network"
        }
    }

    component EdgeReservation: PanelWindow {
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        mask: Region {}
    }

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenFrame
            required property var modelData

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.top: true
                exclusiveZone: frameWindow.dashboardAtBottom ? frameWindow.rimThickness : frameWindow.dashboardClosedHeight
            }

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.bottom: true
                exclusiveZone: frameWindow.dashboardAtBottom ? frameWindow.dashboardClosedHeight : frameWindow.rimThickness
            }

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.left: true
                exclusiveZone: frameWindow.sidebarRestWidth
            }

            EdgeReservation {
                screen: screenFrame.modelData
                anchors.right: true
                exclusiveZone: frameWindow.sidebarRestWidth
            }

            PanelWindow {
                id: frameWindow
                screen: screenFrame.modelData
                focusable: true
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                readonly property int rimThickness: 10
                readonly property int sidebarClosedWidth: 25
                readonly property int dashboardClosedHeight: 30
                readonly property int sidebarExpandedWidth: 220
                readonly property int sidebarShoulderLength: 40
                readonly property int dashboardContentWidth: 1000
                readonly property int dashboardFlare: 50
                readonly property int dashboardCompactHeight: 300
                readonly property int dashboardOpenHeight: 400
                readonly property int osdFadeDuration: 350

                property bool leftSidebarOpen: false
                property bool rightSidebarOpen: false

                readonly property bool dashboardAtBottom: Config.data.barLayout === "bottom"
                readonly property bool monitorFocused: !!Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === screen.name
                readonly property bool dashboardShown: States.dashboardOpen && monitorFocused
                readonly property real borderWidth: Config.data.borderSize || 1
                readonly property real sidebarRestWidth: Config.data.sideBarsEnabled ? sidebarClosedWidth : rimThickness

                readonly property real dashboardWidth: dashboardContentWidth + dashboardFlare * 2
                readonly property real dashboardLeft: (width - dashboardWidth) / 2
                readonly property real dashboardRight: dashboardLeft + dashboardWidth
                readonly property real dashboardTargetHeight: {
                    if (!dashboardShown)
                        return dashboardClosedHeight
                    if (States.currentView === "home")
                        return dashboardCompactHeight
                    return dashboardOpenHeight
                }

                property real dashboardHeight: dashboardTargetHeight
                property real leftInset: leftSidebarOpen && Config.data.sideBarsEnabled ? sidebarExpandedWidth : sidebarRestWidth
                property real rightInset: rightSidebarOpen && Config.data.sideBarsEnabled ? sidebarExpandedWidth : sidebarRestWidth

                readonly property real leftWallX: Math.max(sidebarRestWidth, leftInset)
                readonly property real rightWallX: width - Math.max(sidebarRestWidth, rightInset)

                readonly property string innerContourPath: buildInnerContourPath()
                readonly property string filledFramePath: moveTo(0, 0) + lineTo(0, height) + lineTo(width, height) + lineTo(width, 0) + "Z " + innerContourPath

                Behavior on dashboardHeight {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

                Behavior on leftInset {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

                Behavior on rightInset {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }

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
                    const innerLeft = rimThickness
                    const innerRight = width - rimThickness
                    const innerTop = rimThickness
                    const innerBottom = height - rimThickness
                    const shoulderTopY = innerTop + sidebarShoulderLength
                    const shoulderBottomY = innerBottom - sidebarShoulderLength
                    const dashboardBottomY = Math.max(dashboardClosedHeight, dashboardHeight)
                    const dashboardDrop = dashboardBottomY - innerTop
                    const flare = dashboardFlare

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

                mask: Region {
                    x: 0
                    y: 0
                    width: frameWindow.width
                    height: frameWindow.height

                    Region {
                        x: frameWindow.leftWallX
                        y: frameWindow.rimThickness
                        width: frameWindow.rightWallX - frameWindow.leftWallX
                        height: frameWindow.height - frameWindow.rimThickness * 2
                        intersection: Intersection.Subtract
                    }

                    Region {
                        x: frameWindow.dashboardLeft
                        y: frameWindow.dashboardAtBottom ? frameWindow.height - frameWindow.dashboardHeight : 0
                        width: frameWindow.dashboardWidth
                        height: frameWindow.dashboardHeight
                    }
                }

                HyprlandFocusGrab {
                    windows: [frameWindow]
                    active: frameWindow.dashboardShown || frameWindow.leftSidebarOpen || frameWindow.rightSidebarOpen
                    onCleared: {
                        States.dashboardOpen = false
                        frameWindow.leftSidebarOpen = false
                        frameWindow.rightSidebarOpen = false
                    }
                }

                Shape {
                    id: frameFill
                    anchors.fill: parent
                    layer.enabled: true
                    layer.samples: 5
                    transform: Scale {
                        origin.y: frameFill.height / 2
                        yScale: frameWindow.dashboardAtBottom ? -1 : 1
                    }

                    ShapePath {
                        fillRule: ShapePath.WindingFill
                        fillColor: Theme.colBg
                        strokeWidth: -1

                        PathSvg {
                            path: frameWindow.filledFramePath
                        }
                    }
                }

                Shape {
                    id: frameOutline
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer
                    transform: Scale {
                        origin.y: frameOutline.height / 2
                        yScale: frameWindow.dashboardAtBottom ? -1 : 1
                    }

                    ShapePath {
                        strokeWidth: frameWindow.borderWidth
                        strokeColor: Theme.colAccent
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        PathSvg {
                            path: frameWindow.innerContourPath
                        }
                    }
                }

                Item {
                    id: dashboardContent
                    x: frameWindow.dashboardLeft + frameWindow.dashboardFlare
                    y: frameWindow.dashboardAtBottom ? frameWindow.height - height : 0
                    width: frameWindow.dashboardContentWidth
                    height: frameWindow.dashboardHeight

                    Keys.onEscapePressed: States.dashboardOpen = false

                    MainMenuBtn {
                        id: mainMenuButton
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !States.dashboardOpen
                    }

                    QuickMenuBtns {
                        id: quickMenuButtons
                        anchors.left: parent.left
                        anchors.leftMargin: 60
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: States.mainMenuOpen ? 1 : 0
                        visible: opacity > 0 && !States.dashboardOpen

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutCubic
                            }
                        }

                        Timer {
                            interval: 5000
                            running: States.mainMenuOpen && !quickMenuHoverHandler.hovered
                            onTriggered: States.mainMenuOpen = false
                        }

                        HoverHandler {
                            id: quickMenuHoverHandler
                        }
                    }

                    Workspaces {
                        id: workspaces
                        anchors.left: parent.left
                        anchors.leftMargin: States.mainMenuOpen ? 210 : 60
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !States.dashboardOpen

                        Behavior on anchors.leftMargin {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Clock {
                        id: clock
                        anchors.centerIn: parent
                        orientation: "horizontalFull"
                        textSize: 15
                        opacity: States.timeDateVisible && !States.dashboardOpen ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: frameWindow.osdFadeDuration
                                easing.type: Easing.InOutCubic
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!States.dashboardOpen) {
                                    States.currentView = "home"
                                    States.dashboardOpen = true
                                }
                            }
                        }
                    }

                    SystemTrayApps {
                        id: systemTray
                        anchors.right: parent.right
                        anchors.rightMargin: batteryButton.visible ? 165 : 100
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !States.dashboardOpen
                    }

                    BatteryBtn {
                        id: batteryButton
                        anchors.right: parent.right
                        anchors.rightMargin: 100
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Battery.available && !States.dashboardOpen
                    }

                    AudioBtn {
                        anchors.right: parent.right
                        anchors.rightMargin: 70
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !States.dashboardOpen
                    }

                    BluetoothBtn {
                        anchors.right: parent.right
                        anchors.rightMargin: 40
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !States.dashboardOpen
                    }

                    NetworkBtn {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !States.dashboardOpen
                    }

                    BrightnessOSD {
                        anchors.centerIn: parent
                        opacity: States.brightnessOSDOpen ? 1 : 0
                        visible: opacity > 0 && frameWindow.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: frameWindow.osdFadeDuration
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    MediaOSD {
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: !States.dashboardOpen && States.mediaPlayerOpen ? 1 : 0
                        visible: opacity > 0 && frameWindow.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: frameWindow.osdFadeDuration
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    NotificationOSD {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 500
                        opacity: States.notificationOSDOpen ? 1 : 0
                        visible: opacity > 0 && frameWindow.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: frameWindow.osdFadeDuration
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    VolumeOSD {
                        anchors.centerIn: parent
                        opacity: States.volumeOSDOpen ? 1 : 0
                        visible: opacity > 0 && frameWindow.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: frameWindow.osdFadeDuration
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Component {
                        id: audioSettingsView
                        AudioSettings {}
                    }

                    Component {
                        id: bluetoothSettingsView
                        BluetoothSettings {}
                    }

                    Component {
                        id: homeScreenView
                        HomeScreen {}
                    }

                    Component {
                        id: launcherView
                        Launcher {}
                    }

                    Component {
                        id: networkSettingsView
                        NetworkSettings {}
                    }

                    Loader {
                        id: dashboardViewLoader
                        anchors.fill: parent
                        anchors.margins: States.currentView === "bluetooth" || States.currentView === "network" || States.currentView === "audio" ? 10 : 0
                        active: States.dashboardOpen && frameWindow.monitorFocused
                        opacity: States.dashboardOpen ? 1 : 0
                        visible: opacity > 0 && frameWindow.monitorFocused

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutCubic
                            }
                        }

                        sourceComponent: {
                            switch (States.currentView) {
                                case "audio": return audioSettingsView
                                case "bluetooth": return bluetoothSettingsView
                                case "home": return homeScreenView
                                case "launcher": return launcherView
                                case "network": return networkSettingsView
                            }
                        }
                    }
                }

                Item {
                    id: leftSidebar
                    visible: Config.data.sideBarsEnabled
                    width: frameWindow.leftInset

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: frameWindow.leftSidebarOpen = !frameWindow.leftSidebarOpen
                    }

                    Image {
                        id: leftSidebarLogo
                        anchors.left: parent.left
                        anchors.leftMargin: -48
                        anchors.verticalCenter: parent.verticalCenter
                        width: 120
                        height: 120
                        source: Theme.logoPath
                        mipmap: true
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        opacity: frameWindow.leftSidebarOpen ? 1 : 0
                        scale: frameWindow.leftSidebarOpen ? 1.5 : 0.5
                        rotation: frameWindow.leftSidebarOpen ? -360 : 0

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 650
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 450
                                easing.type: Easing.OutBack
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }

                    Column {
                        id: leftSidebarTools
                        anchors.top: parent.top
                        anchors.topMargin: 100
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        width: Math.max(0, leftSidebar.width - 62)
                        spacing: 14
                        opacity: frameWindow.leftSidebarOpen ? 1 : 0
                        visible: opacity > 0
                        enabled: frameWindow.leftSidebarOpen

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }

                        StyledText {
                            text: "Quick Access"
                            color: Theme.colAccent
                        }

                        Repeater {
                            model: [
                                { label: "Applications", glyph: "▦", command: "qs ipc call dashboard openLauncher" },
                                { label: "Settings", glyph: "⚙", command: "qs ipc call settingsMenu toggle" },
                                { label: "Terminal", glyph: ">_", command: "ghostty" },
                                { label: "Files", glyph: "▤", command: "thunar" }
                            ]

                            delegate: StyledRect {
                                width: leftSidebarTools.width
                                height: 38

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    spacing: 11

                                    StyledText {
                                        width: 22
                                        anchors.verticalCenter: parent.verticalCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData.glyph
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.label
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["sh", "-c", modelData.command])
                                }
                            }
                        }
                    }

                    Column {
                        id: leftSidebarSystem
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 100
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        width: Math.max(0, leftSidebar.width - 62)
                        spacing: 14
                        opacity: frameWindow.leftSidebarOpen ? 1 : 0
                        visible: opacity > 0
                        enabled: frameWindow.leftSidebarOpen

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }

                        StyledText {
                            text: "System"
                            color: Theme.colAccent
                        }

                        Rectangle {
                            width: leftSidebarSystem.width
                            height: systemStatsColumn.implicitHeight + 20
                            radius: 10
                            color: "transparent"
                            border.width: Config.data.borderSize
                            border.color: Theme.colAccent

                            Column {
                                id: systemStatsColumn
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Repeater {
                                    model: [
                                        {
                                            show: true,
                                            label: "CPU",
                                            value: Math.round(SysMonitor.cpuUsage) + "%",
                                            fraction: SysMonitor.cpuUsage / 100
                                        },
                                        {
                                            show: true,
                                            label: "RAM",
                                            value: SysMonitor.ramUsedGb.toFixed(1) + " / " + SysMonitor.ramTotalGb.toFixed(1) + " GB",
                                            fraction: SysMonitor.ramUsage
                                        },
                                        {
                                            show: SysMonitor.gpuAvailable,
                                            label: "GPU",
                                            value: Math.round(SysMonitor.gpuUsage * 100) + "%",
                                            fraction: SysMonitor.gpuUsage
                                        },
                                        {
                                            show: SysMonitor.gpuAvailable,
                                            label: "VRAM",
                                            value: SysMonitor.vramUsedGb.toFixed(1) + " / " + SysMonitor.vramTotalGb.toFixed(1) + " GB",
                                            fraction: SysMonitor.vramUsage
                                        },
                                        {
                                            show: true,
                                            label: "Disk",
                                            value: SysMonitor.diskUsedGb.toFixed(0) + " / " + SysMonitor.diskTotalGb.toFixed(0) + " GB",
                                            fraction: SysMonitor.diskUsage
                                        }
                                    ]

                                    delegate: Column {
                                        width: systemStatsColumn.width
                                        spacing: 4
                                        visible: modelData.show

                                        Row {
                                            width: parent.width
                                            spacing: 5

                                            Text {
                                                text: modelData.label
                                                color: Theme.colText
                                                font.pixelSize: 11
                                            }

                                            Text {
                                                text: modelData.value
                                                color: Theme.colAccent
                                                font.pixelSize: 11
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 5
                                            radius: 3
                                            color: Theme.colAccent
                                            opacity: 0.2

                                            Rectangle {
                                                width: parent.width * Math.max(0, Math.min(1, modelData.fraction))
                                                height: parent.height
                                                radius: parent.radius
                                                color: Theme.colAccent
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "CPU " + Math.round(SysMonitor.cpuTemp) + "°C" + (SysMonitor.gpuAvailable ? "   GPU " + Math.round(SysMonitor.gpuTemp) + "°C" : "")
                                    color: Theme.colText
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: "Uptime " + SysMonitor.uptimeText
                                    color: Theme.colText
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                Item {
                    id: rightSidebar
                    visible: Config.data.sideBarsEnabled
                    width: frameWindow.rightInset

                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: frameWindow.rightSidebarOpen = !frameWindow.rightSidebarOpen
                    }

                    Image {
                        id: rightSidebarLogo
                        anchors.right: parent.right
                        anchors.rightMargin: -48
                        anchors.verticalCenter: parent.verticalCenter
                        width: 120
                        height: 120
                        source: Theme.logoPath
                        mipmap: true
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        opacity: frameWindow.rightSidebarOpen ? 1 : 0
                        scale: frameWindow.rightSidebarOpen ? 1.5 : 0.5
                        rotation: frameWindow.rightSidebarOpen ? 360 : 0

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 650
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 450
                                easing.type: Easing.OutBack
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }

                    Column {
                        id: rightSidebarTools
                        anchors.top: parent.top
                        anchors.topMargin: 100
                        anchors.right: parent.right
                        anchors.rightMargin: 30
                        width: Math.max(0, rightSidebar.width - 62)
                        spacing: 14
                        opacity: frameWindow.rightSidebarOpen ? 1 : 0
                        visible: opacity > 0
                        enabled: frameWindow.rightSidebarOpen

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }

                        StyledText {
                            text: "Capture"
                            color: Theme.colAccent
                        }

                        Grid {
                            columns: 3
                            spacing: 4

                            Repeater {
                                model: [
                                    { glyph: "󰹑", label: "Select", command: ["flameshot", "gui"] },
                                    { glyph: "󰹑", label: "Fullscreen", command: ["flameshot", "full", "--clipboard"] },
                                    { glyph: "󰻂", label: "Record", command: ["obs", "--startrecording"] }
                                ]

                                delegate: StyledRect {
                                    width: 55
                                    height: 55

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 10

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.glyph
                                            color: Theme.colAccent
                                            font.pixelSize: 20
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.label
                                            color: Theme.colText
                                            font.pixelSize: 10
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            frameWindow.rightSidebarOpen = false;
                                            Quickshell.execDetached(modelData.command)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
