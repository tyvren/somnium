import Quickshell
import Quickshell.Wayland
import qs.Modules
import qs.Modules.Bar
import qs.Modules.Dashboard
import qs.Modules.LockScreen
import qs.Modules.Menus
import qs.Modules.Menus.Settings

ShellRoot {
    Bar {}
    Dashboard {}
    Launcher {}
    LockContext {
        id: lockContext

        onLockRequested: lock.locked = true
		    onUnlocked: lock.locked = false
    }
    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockScreen {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
    Settings {}
    SidePane {}
    Wallpaper {}
}
