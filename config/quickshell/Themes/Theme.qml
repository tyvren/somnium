pragma Singleton

import QtQuick
import Quickshell
import qs.Services

QtObject {
    id: theme

    readonly property string activeId: Config.data.theme
    readonly property string fontFamily: "Roboto"
    readonly property int fontSize: 14

    readonly property real currentAlpha: 1.0 - ((Config.data.qsTransparency ?? 0.0) * 0.75)

    readonly property var themes: ({
        mocha: {
            colBg: "#1e1e2e",
            colText: "#cdd6f4",
            colSelect: "#2a2a44",
            colHilight: "#cdd6f4",
            colAccent: "#b4befe",
            colMuted: "#404063",
            logo: "spiral_mocha.png",
            wall: "mocha.png"
        },
        arcadia: {
            colBg: "#403E44",
            colText: "#f2eff5",
            colHilight: "#AC4262",
            colSelect: "#505154",
            colAccent: "#B3A3AD",
            colMuted: "#67636E",
            logo: "spiral_arcadia.png",
            wall: "arcadia.png"
        },
        dracula: {
            colBg: "#282a36",
            colText: "#F8F8F2",
            colHilight: "#50fa7b",
            colSelect: "#44475a",
            colAccent: "#bd93f9",
            colMuted: "#44475a",
            logo: "spiral_dracula.png",
            wall: "oni.png"
        },
        eden: {
            colBg: "#D1CDC2",
            colText: "#1a1a1a",
            colHilight: "#feffff",
            colSelect: "#E0DED6",
            colAccent: "#0D0D0D",
            colMuted: "#B9B3A2",
            logo: "spiral_eden.png",
            wall: "10_rain.png"
        },
        emberforge: {
            colBg: "#3B3B3B",
            colText: "#fff1eb",
            colHilight: "#626262",
            colSelect: "#626262",
            colAccent: "#FD5001",
            colMuted: "#696969",
            logo: "spiral_emberforge.png",
            wall: "emberforge.jpg"
        },
        somnium: {
            colBg: "#0c0c27",
            colText: "#e0def4",
            colHilight: "#517187",
            colSelect: "#214154",
            colAccent: "#01A2FC",
            colMuted: "#444b6a",
            logo: "spiral_somnium.png",
            wall: "somnium.png"
        },
        ghost: {
            colBg: "#000000",
            colText: "#D0D0D0",
            colSelect: "#404040",
            colHilight: "#FFFFFF",
            colAccent: "#80FFFFFF",
            colMuted: "#3B3B3B",
            logo: "spiral_ghost.png",
            wall: "somnium_ghost.png"
        },
        verdant: {
            colBg: "#08110B",
            colText: "#D0D0D0",
            colSelect: "#50AF73",
            colHilight: "#CDEAD4",
            colAccent: "#50AF73",
            colMuted: "#163120",
            logo: "spiral_verdant.png",
            wall: "verdant.jpg"
        }
    })

    readonly property var active: themes[activeId] || themes["somnium"]

    readonly property color colBg: Qt.alpha(active.colBg, theme.currentAlpha)
    readonly property color colText: active.colText
    readonly property color colHilight: Qt.alpha(active.colHilight, theme.currentAlpha)
    readonly property color colSelect: Qt.alpha(active.colSelect, theme.currentAlpha)
    readonly property color colAccent: Qt.alpha(active.colAccent, theme.currentAlpha)
    readonly property color colMuted: Qt.alpha(active.colMuted, theme.currentAlpha)

    readonly property string wallpaperPath: {
        if (Config.data.wallpaper) {
            return "file://" + Config.data.wallpaper
        }
            
        let folder = activeId.charAt(0).toUpperCase() + activeId.slice(1)
        return "file://" + Config.installDir + "/wallpapers/" + folder + "/" + active.wall
    }

    readonly property url logoPath: Config.installDir + "/config/quickshell/Assets/" + active.logo
}
