import QtQuick
import Quickshell.Widgets
import qs.Components
import qs.Services
import qs.Themes

Item {
    id: root
    implicitWidth: 48
    implicitHeight: 18
    visible: available

    property real percentage: Battery.percentage
    property bool isCharging: Battery.isCharging
    property bool isFull: Battery.isFull
    property bool available: Battery.available
     
    readonly property string icon: {
        if (isCharging) return ""
        const icons = ["", "", "", "", ""]
        return icons[Math.min(Math.floor(percentage * 5), 4)]
    } 
    
    Rectangle { 
        anchors.fill: parent
        color: Theme.colMuted 
        radius: Config.data.rounding
        border.color: Theme.colAccent
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: Config.data.rounding
        color: "transparent"
        
        Rectangle {
          color: Theme.colAccent
          height: parent.height
          width: parent.width * root.percentage
          opacity: 0.5
          Behavior on width { 
              NumberAnimation { 
                duration: 250 
                easing.type: Easing.OutCubic 
              } 
          }
        }
    }
    
    Row {
        anchors.fill: parent
        anchors.leftMargin: 4
        spacing: 2
            
        StyledText {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.percentage <= 0.10 ? Theme.colAccent : Theme.colBg
            size: 8
        }
            
        StyledText {
          id: percentageText
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(root.percentage * 100) + "%"
          color: root.percentage < 0.5 ? Theme.colAccent : Theme.colBg
          size: 9
          bold: false
        }
    } 
}
