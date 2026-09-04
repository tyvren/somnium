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
        onLockRequested: lockScreen.locked = true
        onUnlocked: lockScreen.locked = false
    }
    LockScreen {
        id: lockScreen
        context: lockContext
    }
    Settings {}
    SidePane {}
    Wallpaper {}
}
