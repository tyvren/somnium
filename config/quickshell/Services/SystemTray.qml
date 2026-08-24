pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    readonly property var items: SystemTray.items

    function triggerItem(item) {
        if (item) {
            item.activate();
        }
    }

    function triggerSecondary(item) {
        if (item) {
            item.secondaryActivate();
        }
    }

    function openMenu(item, visualParent) {
        if (item && item.menu) {
            item.menu.open(visualParent);
        }
    }
}
