pragma Singleton
import QtQuick

QtObject {
    // ── Background colors ──
    property color background:         SimbankPallete.backgroundBlack
    property color surfacePrimary:     SimbankPallete.darkSurfacePrimary
    property color surfaceSecondary:   SimbankPallete.darkSurfaceSecondary
    property color surfaceHover:       SimbankPallete.darkSurfaceHover
    property color surfacePressed:     SimbankPallete.darkSurfacePressed

    // ── Border / outline colors ──
    property color borderDefault:      SimbankPallete.borderBright
    property color borderAccent:       SimbankPallete.accentPurpleBase
    property color borderStrong:       SimbankPallete.logoBlack

    // ── Text colors ──
    property color textPrimary:        SimbankPallete.secondaryCobaltblue
    property color textSecondary:      SimbankPallete.secondaryIndependence
    property color textOnAccent:       SimbankPallete.logoWhite
    property color textHeading:        SimbankPallete.secondaryBlack

    // ── Accent / status colors ──
    property color accentPrimary:      SimbankPallete.accentPurpleBase
    property color accentSecondary:    SimbankPallete.accentPurplePressed
    property color statusSuccess:      SimbankPallete.statusGreen
    property color statusWarning:      SimbankPallete.statusYellow

    // ── Dynamic Themed Colors (Configurable) ──
    property var   backgroundGradient:      SimbankPallete.backgroundGradient17
    property color tileColor:               SimbankPallete.secondaryCobaltblue
    property color categoryTileColor:       SimbankPallete.backgroundBlack
    property color buttonColor:             SimbankPallete.secondaryBlueocean
    property color buttonDisabledColor:     SimbankPallete.backgroundLightGrey
    property color backButtonColor:         SimbankPallete.secondaryBlueocean
    property color backButtonDisabledColor: SimbankPallete.darkSurfaceSecondary
    property color languageToggleColor:     SimbankPallete.secondaryLightskyblue

    // ── Per-component text colors ──
    property color tileTextColor:               SimbankPallete.logoWhite
    property color categoryTileTextColor:       SimbankPallete.logoWhite
    property color buttonTextColor:             SimbankPallete.logoWhite
    property color buttonTextDisabledColor:     SimbankPallete.secondaryBlack
    property color backButtonTextColor:         SimbankPallete.logoWhite
    property color backButtonTextDisabledColor: Qt.rgba(1, 1, 1, 0.35)
    property color languageToggleTextColor:     SimbankPallete.logoWhite

    // ── Keyboard colors ──
    property color keyboardBackground:      SimbankPallete.darkSurfacePrimary
    property color keyColor:                SimbankPallete.darkSurfaceSecondary
    property color keyHoverColor:           SimbankPallete.darkSurfaceHover
    property color keyPressedColor:         SimbankPallete.darkSurfacePressed
    property color keyTextColor:            SimbankPallete.textMainLight
    property color keyHighlightTextColor:   SimbankPallete.logoWhite        // text on highlighted (e.g. active Shift) key
    property color keyHighlightColor:       SimbankPallete.accentPurplePressed
    property color keyAccentTextColor:      SimbankPallete.accentPurpleBase
    property color keyPopupTextColor:       SimbankPallete.textMainLight    // language popup option label
    property color keyPopupActiveTextColor: SimbankPallete.accentPurpleBase // active language option label + indicator

    // ── Input field colors ──
    property color inputTextColor:          SimbankPallete.backgroundLightGrey
    property color inputPlaceholderColor:   SimbankPallete.secondaryTurkish
    property color inputBackgroundColor:    SimbankPallete.darkSurfaceSecondary
    property color inputBorderColor:        SimbankPallete.accentPurpleBase

    // ── Typography ──
    readonly property string fontFamily:              SimbankPallete.fontFamily
    readonly property int fontSizeSmall:        14
    readonly property int fontSizeNormal:       16
    readonly property int fontSizeLarge:        18
    readonly property int fontSizeXLarge:       24
}

