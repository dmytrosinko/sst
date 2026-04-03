pragma Singleton
import QtQuick

QtObject {
    // ── Background colors ──
    readonly property color background:         "#D8DEE9"   // Window/page background
    readonly property color surfacePrimary:     "#2E3440"   // Cards, panels, input fields
    readonly property color surfaceSecondary:   "#3B4252"   // Elevated surfaces, button default
    readonly property color surfaceHover:       "#434C5E"   // Hovered interactive surfaces
    readonly property color surfacePressed:     "#4C566A"   // Pressed interactive surfaces

    // ── Border / outline colors ──
    readonly property color borderDefault:      "#4C566A"   // Default border
    readonly property color borderAccent:       "#88C0D0"   // Focused / accent border
    readonly property color borderStrong:       "#2E3440"   // Strong/dark border

    // ── Text colors ──
    readonly property color textPrimary:        "#ECEFF4"   // Main text on dark surfaces
    readonly property color textSecondary:      "#D8DEE9"   // Secondary / label text
    readonly property color textOnAccent:       "#2E3440"   // Text on accent/hovered buttons
    readonly property color textHeading:        "#8FBCBB"   // Section headings

    // ── Accent / status colors ──
    readonly property color accentPrimary:      "#88C0D0"   // Primary accent (frost)
    readonly property color accentSecondary:    "#81A1C1"   // Selection highlight
    readonly property color statusSuccess:      "#A3BE8C"   // Positive / success values
    readonly property color statusWarning:      "#EBCB8B"   // Warning / attention values

    // ── Typography ──
    readonly property int fontSizeSmall:        14
    readonly property int fontSizeNormal:       16
    readonly property int fontSizeLarge:        18
    readonly property int fontSizeXLarge:       24
}
