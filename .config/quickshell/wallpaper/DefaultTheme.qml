import QtQuick

QtObject {
  readonly property color bgBase: "#121318"
  readonly property color bgSurface: "#1e1f25"
  readonly property color bgOverlay: "#000000"
  readonly property color bgHover: "#282a2f"
  readonly property color bgSelected: "#304578"
  readonly property color bgBorder: "#45464f"

  readonly property color textPrimary: "#e2e2e9"
  readonly property color textSecondary: "#c5c6d0"
  readonly property color textMuted: "#8f909a"

  readonly property color accentPrimary: "#b2c5ff"
  readonly property color accentCyan: "#e1bbdd"
  readonly property color accentGreen: "#c0c6dd"
  readonly property color accentOrange: "#5a3d59"
  readonly property color accentRed: "#ffb4ab"

  readonly property color urgencyLow: textMuted
  readonly property color urgencyNormal: accentPrimary
  readonly property color urgencyCritical: accentRed
  readonly property color batteryGood: accentGreen
  readonly property color batteryWarning: accentOrange
  readonly property color batteryCritical: accentRed
}
