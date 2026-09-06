pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    property int currentProfile: PowerProfiles.profile
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile ?? false
    
    readonly property string profileName: {
        switch (root.currentProfile) {
            case 0: return "Power Saver"
            case 1: return "Balanced"
            case 2: return "Performance"
        }
    }

    function setPowerSaver() {
        PowerProfiles.profile = PowerProfile.PowerSaver;
    }

    function setBalanced() {
        PowerProfiles.profile = PowerProfile.Balanced;
    }

    function setPerformance() {
        if (hasPerformanceProfile) {
            PowerProfiles.profile = PowerProfile.Performance;
        }
    }
}
