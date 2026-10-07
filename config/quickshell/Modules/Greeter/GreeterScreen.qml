import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Greetd
import qs.Components
import qs.Services
import qs.Themes

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

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

        stdout: SplitParser {
            onRead: data => {
                let lines = data.trim().split("\n");
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
            "        name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); " +
            "        exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2-); " +
            "        desktop=$(basename \"$f\" .desktop); " +
            "        if [ -n \"$name\" ]; then echo \"$name|$exec|$desktop\"; fi; " +
            "      fi; " +
            "    done; " +
            "  fi; " +
            "done"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                let lines = data.trim().split("\n");
                let names = [];
                let execs = [];
                let desktops = [];

                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split("|");
                    if (parts.length >= 3) {
                        let name = parts[0].trim();
                        let exec = parts[1].trim();
                        let desktop = parts[2].trim();
                        if (name.length > 0 && !names.includes(name)) {
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

                let uwsmIdx = names.findIndex(n => n.toLowerCase().includes("uwsm"));
                let hyprIdx = names.findIndex(n => n.toLowerCase().includes("hyprland"));

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
        color: Theme.colBg

        Image {
            id: wallpaper
            anchors.fill: parent
            source: Quickshell.env("HOME") + "/.config/somnium/wallpapers/Somnium/somnium.png"
            mipmap: true
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
        }

        MultiEffect {
            anchors.fill: dialogContainer
            source: dialogContainer
            shadowEnabled: true
            shadowBlur: 0.5
            shadowColor: Theme.colAccent
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
        }

        Rectangle {
            id: dialogContainer
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.35
            color: Qt.alpha(Theme.colBg, 0.75)
            border.color: root.authStatusText.toLowerCase().includes("fail") ? Theme.colHilight : Theme.colAccent
            border.width: Config.data.borderSize
            radius: Config.data.rounding

            Clock {
                id: lockScreenClock
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                textSize: 42
                orientation: "horizontalFull"
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 32
                spacing: 30

                StyledClippingRect {
                    id: userIconBox
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 110
                    Layout.alignment: Qt.AlignHCenter

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
                    Layout.preferredHeight: 40
                    focusPolicy: Qt.NoFocus
                    model: root.userList
                    currentIndex: root.currentUserIndex

                    onActivated: (index) => {
                        root.currentUserIndex = index;
                        passwordBox.text = "";
                    }

                    delegate: ItemDelegate {
                        width: userSelector.width

                        contentItem: StyledText {
                            text: modelData
                            color: highlighted ? Theme.colBg : Theme.colText
                            size: 10
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: Theme.colMuted
                            opacity: 0.2
                            border.color: Theme.colAccent
                            border.width: Config.data.borderSize
                            radius: Config.data.rounding
                        }
                    }

                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        StyledText {
                            text: "󰏬"
                            size: 12
                            color: Theme.colText
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: userSelector.displayText
                            size: 11
                            color: Theme.colText
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    background: Rectangle {
                        color: Theme.colMuted
                        opacity: 0.2
                        border.color: Theme.colAccent
                        border.width: Config.data.borderSize
                        radius: Config.data.rounding
                    }

                    popup: Popup {
                        y: userSelector.height + 4
                        width: userSelector.width
                        implicitHeight: Math.min(contentItem.implicitHeight, 200)
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: userSelector.popup.visible ? userSelector.delegateModel : null
                            currentIndex: userSelector.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: Theme.colBg
                            border.color: Theme.colAccent
                            border.width: Config.data.borderSize
                            radius: Config.data.rounding
                        }
                    }
                }

                StyledInput {
                    id: passwordBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignHCenter
                    echoMode: TextInput.Password
                    placeholderText: "Enter Password"
                    placeholderTextColor: Theme.colMuted
                    font.pointSize: 13
                    inputMethodHints: Qt.ImhSensitiveData

                    onAccepted: root.triggerLogin()
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.authStatusText
                    color: Theme.colHilight
                    size: 10
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.authStatusText !== ""
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ComboBox {
                        id: sessionSelector
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        focusPolicy: Qt.NoFocus
                        model: root.sessionList
                        currentIndex: root.currentSessionIndex

                        onActivated: (index) => { root.currentSessionIndex = index; }

                        delegate: ItemDelegate {
                            width: sessionSelector.width

                            contentItem: StyledText {
                                text: modelData
                                color: highlighted ? Theme.colBg : Theme.colText
                                size: 10
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: Theme.colMuted
                                opacity: 0.2
                                border.color: Theme.colAccent
                                border.width: Config.data.borderSize
                                radius: Config.data.rounding
                            }
                        }

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            StyledText {
                                text: "󰍹"
                                size: 12
                                color: Theme.colText
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: sessionSelector.displayText
                                size: 11
                                color: Theme.colText
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        background: Rectangle {
                            color: Theme.colMuted
                            opacity: 0.2
                            border.color: Theme.colAccent
                            border.width: Config.data.borderSize
                            radius: Config.data.rounding
                        }

                        popup: Popup {
                            y: sessionSelector.height + 4
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
                                color: Theme.colBg
                                border.color: Theme.colAccent
                                border.width: Config.data.borderSize
                                radius: Config.data.rounding
                            }
                        }
                    }

                    StyledButton {
                        id: unlockButton
                        focusPolicy: Qt.NoFocus
                        text: "Log In"
                        icon: "󰌾"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        enabled: passwordBox.text !== ""
                        onClicked: root.triggerLogin()
                    }
                }

                DividerLine {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    StyledButton {
                        text: "Restart"
                        icon: "󰜉"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        onClicked: restartProcess.startDetached()
                    }

                    StyledButton {
                        text: "Shutdown"
                        icon: "󰐥"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        onClicked: shutdownProcess.startDetached()
                    }
                }
            }
        }
    }
}
