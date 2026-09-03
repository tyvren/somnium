import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Modules.Menus
import qs.Themes
import qs.Services

Item {
    id: mainMenuBtn
    implicitWidth: 25 
    implicitHeight: 25

    BarButton {
        id: mainMenuComponent
        icon: "     "
        onClicked: {
          if (!States.mainMenuOpen) {
              States.mainMenuOpen = true
            } else {
              States.mainMenuOpen = false
            }
          }
        onEntered: spinAnimBottom.start()
    }

    RotationAnimation on rotation {
        id: spinAnimBottom
        running: false
        loops: 1
        from: 0
        to: -360
        duration: 6000
    }

    Image {
        id: buttonLogo
        width: 25
        height: 25
        anchors.verticalCenter: parent.verticalCenter
        source: Theme.logoPath
        mipmap: true
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: buttonLogo
        shadowEnabled: true
        shadowBlur: 0.2
        shadowOpacity: 0.7
    } 
}
