//@ pragma UseQApplication
//@ pragma Env QT_QPA_PLATFORMTHEME=gtk3
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import QtQuick

import "app-launcher"
import "wallpaper"

Scope {
    Component {
        id: appLauncherComponent

        AppLauncher {}
    }

    Loader {
        id: appLauncherLoader
        active: true
        sourceComponent: appLauncherComponent
    }

    Connections {
        target: WallpaperService

        function onThemeUpdated() {
            appLauncherLoader.active = false
            appLauncherLoader.active = true
        }
    }

    WallpaperManager {}
}
