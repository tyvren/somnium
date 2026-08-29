pragma Singleton
import QtQuick
import qs.Services

QtObject {
    id: windowStates

    property bool bluetoothOpen: false
    property bool brightnessOSDOpen: false
    property bool dashboardOpen: false
    property bool launcherOpen: false
    property bool mediaPlayerOpen: false
    property bool mediaPlayerInGracePeriod: false
    property bool networkOpen: false
    property bool notificationOSDOpen: false
    property bool timeDateVisible: true
    property bool volumeOSDOpen: false

    function restoreDefaultState() {
        bluetoothOpen = false
        launcherOpen = false
        networkOpen = false

        if (Players.isPlaying || mediaPlayerInGracePeriod) {
            mediaPlayerOpen = true
            timeDateVisible = false
        } else {
            mediaPlayerOpen = false
            timeDateVisible = true
        }
    }

    onBluetoothOpenChanged: {
        if (bluetoothOpen) {
            launcherOpen = false
            mediaPlayerOpen = false
            networkOpen = false
            notificationOSDOpen = false
            timeDateVisible = false
            volumeOSDOpen = false
        } else {
            restoreDefaultState()
        }
      }

    onBrightnessOSDOpenChanged: {
        if (brightnessOSDOpen) {
            bluetoothOpen = false
            launcherOpen = false
            mediaPlayerOpen = false
            networkOpen = false
            notificationOSDOpen = false
            timeDateVisible = false
            volumeOSDOpen = false
        } else if (!notificationOSDOpen) {
            restoreDefaultState()
        }
    }

    onLauncherOpenChanged: {
        if (launcherOpen) {
            bluetoothOpen = false
            mediaPlayerOpen = false
            networkOpen = false
            notificationOSDOpen = false
            timeDateVisible = false
            volumeOSDOpen = false
        } else {
            restoreDefaultState()
        }
    }

    onMediaPlayerOpenChanged: {
        if (mediaPlayerOpen) {
            bluetoothOpen = false
            launcherOpen = false
            networkOpen = false
            notificationOSDOpen = false
            timeDateVisible = false
            volumeOSDOpen = false
        }
    }

    onNetworkOpenChanged: {
        if (networkOpen) {
            bluetoothOpen = false
            launcherOpen = false
            mediaPlayerOpen = false
            notificationOSDOpen = false
            timeDateVisible = false
            volumeOSDOpen = false
        } else {
            restoreDefaultState()
        }
    }

    onNotificationOSDOpenChanged: {
        if (notificationOSDOpen) {
            bluetoothOpen = false
            dashboardOpen = false
            launcherOpen = false
            mediaPlayerOpen = false
            networkOpen = false
            timeDateVisible = false
            volumeOSDOpen = false
        } else {
            restoreDefaultState()
        }
    }

    onVolumeOSDOpenChanged: {
        if (volumeOSDOpen) {
            bluetoothOpen = false
            launcherOpen = false
            mediaPlayerOpen = false
            networkOpen = false
            notificationOSDOpen = false
            timeDateVisible = false
        } else {
            restoreDefaultState()
        }
    }
}
