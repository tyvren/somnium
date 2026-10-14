import Quickshell
import qs.Modules
import qs.Modules.Bar
import qs.Modules.Dashboard
import qs.Modules.LockScreen
import qs.Modules.Menus.Settings
import qs.Modules.Shell

ShellRoot {
    Shell {}
    Launcher {}
    LockContext {
        id: lockContext
        onLockRequested: lockScreen.locked = true
    }

    LockScreen {
        id: lockScreen
        context: lockContext
    }
    Settings {}
    Wallpaper {}
}
