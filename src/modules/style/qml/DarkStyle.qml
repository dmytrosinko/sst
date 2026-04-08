pragma Singleton
import QtQuick

QtObject {
    // ── Background colors ──
    readonly property color background:         "#000000"   // Window/page background (Header black)
    readonly property color surfacePrimary:     "#0A0A0F"   // Cards, panels, tiles
    readonly property color surfaceSecondary:   "#141419"   // Elevated surfaces, button default
    readonly property color surfaceHover:       "#1E1E28"   // Hovered interactive surfaces
    readonly property color surfacePressed:     "#2A2A38"   // Pressed interactive surfaces

    // ── Border / outline colors ──
    readonly property color borderDefault:      "#808090"   // Default border (bright)
    readonly property color borderAccent:       "#9B8EC4"   // Focused / accent border (LanguageToggle purple)
    readonly property color borderStrong:       "#000000"   // Strong/dark border

    // ── Text colors ──
    readonly property color textPrimary:        "#ECEFF4"   // Main text on dark surfaces
    readonly property color textSecondary:      "#A0A0B0"   // Secondary / label text
    readonly property color textOnAccent:       "#FFFFFF"   // Text on accent/hovered buttons
    readonly property color textHeading:        "#B0A4D4"   // Section headings (light purple)

    // ── Accent / status colors ──
    readonly property color accentPrimary:      "#9B8EC4"   // Primary accent (LanguageToggle purple)
    readonly property color accentSecondary:    "#8578B0"   // Pressed accent
    readonly property color statusSuccess:      "#A3BE8C"   // Positive / success values
    readonly property color statusWarning:      "#EBCB8B"   // Warning / attention values

    // ── Typography ──
    readonly property string fontFamily:              SimbankPallete.fontFamily
    readonly property int fontSizeSmall:        14
    readonly property int fontSizeNormal:       16
    readonly property int fontSizeLarge:        18
    readonly property int fontSizeXLarge:       24
}

