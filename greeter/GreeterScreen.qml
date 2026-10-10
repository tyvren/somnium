import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    title: "Somnium Greeter"
    color: root.colBg

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property color colBg: "#0c0c27"
    property color colSurface: "#214154"
    property color colText: "#e0def4"
    property color colHilight: "#517187"
    property color colSelect: "#214154"
    property color colAccent: "#01A2FC"
    property color colMuted: "#444b6a"
    property int radius: 10
    property int borderWidth: 1

    readonly property string fontFamily: "Roboto"
    readonly property int fontSize: 14

    property var userList: []
    property var userHomeDirs: []
    property int currentUserIndex: 0

    property var sessionList: []
    property var sessionExecs: []
    property var sessionDesktopIds: []
    property int currentSessionIndex: 0

    property string authStatusText: ""

    readonly property string selectedUser: userList[currentUserIndex] ?? ""
    readonly property string selectedUserHome: userHomeDirs[currentUserIndex] ?? ""
    readonly property string selectedExec: sessionExecs[currentSessionIndex] ?? ""
    readonly property string selectedDesktop: sessionDesktopIds[currentSessionIndex] ?? ""

    function triggerLogin() {
        if (passwordBox.text.length === 0 || root.selectedUser === "") return;
        authStatusText = "Authenticating..."
        Greetd.createSession(root.selectedUser)
    }

    Connections {
        target: Greetd

        function onStateChanged() {
            switch (Greetd.state) {
            case GreetdState.Inactive:
                break
            case GreetdState.Authenticating:
                root.authStatusText = "Authenticating..."
                break
            case GreetdState.ReadyToLaunch:
                root.authStatusText = "Launching session..."
                let cmdArray = root.selectedExec.trim().split(/\s+/);
                Greetd.launch(cmdArray);
                break
            case GreetdState.Launching:
                root.authStatusText = "Starting..."
                break
            case GreetdState.Launched:
                root.authStatusText = ""
                break
            }
        }

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired) {
                Greetd.respond(passwordBox.text)
            }
        }

        function onAuthFailure(message) {
            root.authStatusText = message || "Authentication failed"
            passwordBox.text = ""
            Greetd.cancelSession()
        }

        function onError(message) {
            root.authStatusText = message || "Greetd error"
            passwordBox.text = ""
            Greetd.cancelSession()
        }
    }

    Process { id: restartProcess; command: ["systemctl", "reboot"] }
    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }

    Process {
        id: userFetcher
        command: [
            "sh", "-c",
            "awk -F: '$3 >= 1000 && $7 !~ /(nologin|false)$/ {print $1 \"|\" $6}' /etc/passwd"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                let users = [];
                let homes = [];

                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split("|");
                    if (parts.length >= 2) {
                        let username = parts[0].trim();
                        let homedir = parts[1].trim();
                        if (username.length > 0 && username !== "nobody") {
                            users.push(username);
                            homes.push(homedir);
                        }
                    }
                }

                if (users.length === 0) {
                    users = [Quickshell.env("USER") || "root"];
                    homes = [Quickshell.env("HOME") || "/root"];
                }

                root.userList = users;
                root.userHomeDirs = homes;

                let lastUser = Quickshell.env("USER");
                let matchedIdx = users.indexOf(lastUser);
                root.currentUserIndex = matchedIdx !== -1 ? matchedIdx : 0;
            }
        }
    }

    Process {
        id: sessionFetcher
        command: [
            "sh", "-c",
            "for d in /usr/share/wayland-sessions /usr/share/xsessions; do " +
            "  if [ -d \"$d\" ]; then " +
            "    for f in \"$d\"/*.desktop; do " +
            "      if [ -f \"$f\" ]; then " +
            "        desktop=$(basename \"$f\" .desktop); " +
            "        name=$(awk -F'=' '/^Name=/ {print $2; exit}' \"$f\"); " +
            "        if [ -z \"$name\" ]; then name=$(awk -F'=' '/^Name/ {print $2; exit}' \"$f\"); fi; " +
            "        if [ -z \"$name\" ]; then name=\"$desktop\"; fi; " +
            "        exec=$(awk -F'=' '/^Exec=/ {print $2; exit}' \"$f\"); " +
            "        if [ -n \"$exec\" ]; then echo \"$name|$exec|$desktop\"; fi; " +
            "      fi; " +
            "    done; " +
            "  fi; " +
            "done"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                let names = [];
                let execs = [];
                let desktops = [];

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line) continue;
                    let parts = line.split("|");
                    if (parts.length >= 3) {
                        let name = parts[0].trim();
                        let exec = parts[1].trim();
                        let desktop = parts[2].trim();

                        if (!desktops.includes(desktop)) {
                            names.push(name);
                            execs.push(exec);
                            desktops.push(desktop);
                        }
                    }
                }

                if (names.length === 0) {
                    names = ["Hyprland (uwsm-managed)"];
                    execs = ["uwsm start -e -D Hyprland hyprland.desktop"];
                    desktops = ["hyprland-uwsm"];
                }

                root.sessionList = names;
                root.sessionExecs = execs;
                root.sessionDesktopIds = desktops;

                let uwsmIdx = desktops.findIndex(d => d.includes("uwsm"));
                let hyprIdx = desktops.findIndex(d => d.includes("hyprland"));

                if (uwsmIdx !== -1) {
                    root.currentSessionIndex = uwsmIdx;
                } else if (hyprIdx !== -1) {
                    root.currentSessionIndex = hyprIdx;
                } else {
                    root.currentSessionIndex = 0;
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.colBg

        Rectangle {
            id: dialogContainer
            anchors.centerIn: parent
            width: 520
            height: 660
            color: Qt.alpha(root.colBg, 0.85)
            border.color: root.authStatusText.toLowerCase().includes("fail") ? root.colHilight : root.colAccent
            border.width: root.borderWidth
            radius: root.radius
            clip: true

            Image {
                id: bgLogo
                anchors.fill: parent
                source: "file:///usr/local/share/somnium/greeter/spiral_somnium.png"
                fillMode: Image.PreserveAspectCrop
                opacity: 0.12
                mipmap: true
                asynchronous: true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 24

                Text {
                    id: clockText
                    Layout.alignment: Qt.AlignHCenter
                    color: root.colText
                    font.family: root.fontFamily
                    font.pointSize: 42
                    font.bold: true
                    text: Qt.formatTime(new Date(), "hh:mm")

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
                    }
                }

                ClippingRectangle {
                    id: userIconBox
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 100
                    Layout.alignment: Qt.AlignHCenter
                    color: root.colSurface
                    radius: 50
                    clip: true

                    Image {
                        id: userIcon
                        anchors.fill: parent
                        source: root.selectedUserHome !== "" ? "file://" + root.selectedUserHome + "/.face" : ""
                        fillMode: Image.PreserveAspectCrop
                        mipmap: true
                        asynchronous: true
                    }
                }

                ComboBox {
                    id: userSelector
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    model: root.userList
                    currentIndex: root.currentUserIndex

                    onActivated: (index) => {
                        root.currentUserIndex = index;
                        passwordBox.text = "";
                    }

                    delegate: ItemDelegate {
                        width: userSelector.width
                        hoverEnabled: true

                        contentItem: Text {
                            text: modelData
                            color: (highlighted || hovered) ? root.colBg : root.colText
                            font.family: root.fontFamily
                            font.pointSize: root.fontSize - 2
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 14

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        background: Rectangle {
                            color: (highlighted || hovered) ? root.colAccent : root.colSurface
                            opacity: (highlighted || hovered) ? 1.0 : 0.2
                            border.color: root.colAccent
                            border.width: root.borderWidth
                            radius: root.radius

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }
                        }
                    }

                    contentItem: Text {
                        leftPadding: 14
                        text: userSelector.displayText
                        color: root.colText
                        verticalAlignment: Text.AlignVCenter
                        font.family: root.fontFamily
                        font.pointSize: root.fontSize - 2
                    }

                    background: Rectangle {
                        color: root.colMuted
                        opacity: 0.2
                        border.color: root.colAccent
                        border.width: root.borderWidth
                        radius: root.radius
                    }

                    popup: Popup {
                        y: userSelector.height + 5
                        width: userSelector.width
                        implicitHeight: Math.min(contentItem.implicitHeight, 250)
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: userSelector.popup.visible ? userSelector.delegateModel : null
                            currentIndex: userSelector.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: root.colBg
                            border.color: root.colAccent
                            border.width: root.borderWidth
                            radius: root.radius
                        }
                    }
                }

                TextField {
                    id: passwordBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    leftPadding: 14
                    rightPadding: 14
                    echoMode: TextInput.Password
                    placeholderText: "Enter Password"
                    placeholderTextColor: Qt.rgba(root.colText.r, root.colText.g, root.colText.b, 0.4)
                    color: root.colText
                    font.family: root.fontFamily
                    font.pointSize: root.fontSize - 2
                    inputMethodHints: Qt.ImhSensitiveData

                    onAccepted: root.triggerLogin()

                    background: Rectangle {
                        color: root.colMuted
                        opacity: 0.2
                        border.color: root.colAccent
                        border.width: root.borderWidth
                        radius: root.radius
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.authStatusText
                    color: root.colHilight
                    font.family: root.fontFamily
                    font.pointSize: root.fontSize - 3
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.authStatusText !== ""
                }

                ComboBox {
                    id: sessionSelector
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    model: root.sessionList
                    currentIndex: root.currentSessionIndex

                    onActivated: (index) => { root.currentSessionIndex = index; }

                    delegate: ItemDelegate {
                        width: sessionSelector.width
                        hoverEnabled: true

                        contentItem: Text {
                            text: modelData
                            color: (highlighted || hovered) ? root.colBg : root.colText
                            font.family: root.fontFamily
                            font.pointSize: root.fontSize - 2
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 14

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        background: Rectangle {
                            color: (highlighted || hovered) ? root.colAccent : root.colSurface
                            opacity: (highlighted || hovered) ? 1.0 : 0.2
                            border.color: root.colAccent
                            border.width: root.borderWidth
                            radius: root.radius

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }
                        }
                    }

                    contentItem: Text {
                        leftPadding: 14
                        text: sessionSelector.displayText
                        color: root.colText
                        verticalAlignment: Text.AlignVCenter
                        font.family: root.fontFamily
                        font.pointSize: root.fontSize - 2
                    }

                    background: Rectangle {
                        color: root.colMuted
                        opacity: 0.2
                        border.color: root.colAccent
                        border.width: root.borderWidth
                        radius: root.radius
                    }

                    popup: Popup {
                        y: sessionSelector.height + 5
                        width: sessionSelector.width
                        implicitHeight: Math.min(contentItem.implicitHeight, 250)
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                            currentIndex: sessionSelector.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: root.colBg
                            border.color: root.colAccent
                            border.width: root.borderWidth
                            radius: root.radius
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        id: unlockButton
                        text: "Log In"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        enabled: passwordBox.text !== ""
                        hoverEnabled: true
                        onClicked: root.triggerLogin()

                        contentItem: Text {
                            text: parent.text
                            color: unlockButton.hovered ? root.colAccent : root.colText
                            font.family: root.fontFamily
                            font.pointSize: root.fontSize - 2
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: !parent.enabled ? root.colMuted : (unlockButton.pressed ? root.colBg : (unlockButton.hovered ? root.colSelect : root.colSurface))
                            border.color: unlockButton.hovered ? root.colAccent : root.colAccent
                            border.width: root.borderWidth
                            radius: root.radius
                            opacity: parent.enabled ? 1.0 : 0.6
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.colMuted
                    opacity: 0.5
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 24

                    Button {
                        id: restartButton
                        text: "⟳"
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        padding: 0
                        hoverEnabled: true
                        onClicked: restartProcess.startDetached()

                        contentItem: Text {
                            text: parent.text
                            color: restartButton.hovered ? root.colAccent : root.colText
                            font.family: root.fontFamily
                            font.pointSize: 22
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        background: Rectangle {
                            color: "transparent"
                        }
                    }

                    Button {
                        id: shutdownButton
                        text: "⏻"
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        padding: 0
                        hoverEnabled: true
                        onClicked: shutdownProcess.startDetached()

                        contentItem: Text {
                            text: parent.text
                            color: shutdownButton.hovered ? root.colAccent : root.colText
                            font.family: root.fontFamily
                            font.pointSize: 22
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        background: Rectangle {
                            color: "transparent"
                        }
                    }
                }
            }
        }
    }
}
