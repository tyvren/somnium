pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    property int currentProfile: PowerProfiles.profile
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile ?? false

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
