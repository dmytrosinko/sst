pragma Singleton
import QtQuick

QtObject {
    id: palette

    // Typography
    readonly property string fontFamily: "Euclid Circular B"

    property FontLoader fontRegular: FontLoader { source: "qrc:/qt/qml/app/assets/fonts/EuclidCircularB-Regular.ttf" }
    property FontLoader fontMedium: FontLoader { source: "qrc:/qt/qml/app/assets/fonts/EuclidCircularB-Medium.ttf" }
    property FontLoader fontSemiBold: FontLoader { source: "qrc:/qt/qml/app/assets/fonts/EuclidCircularB-SemiBold.ttf" }
    property FontLoader fontBold: FontLoader { source: "qrc:/qt/qml/app/assets/fonts/EuclidCircularB-Bold.ttf" }

    // Logo Colors
    readonly property color logoWhite: "#FFFFFF"
    readonly property color logoBlack: "#000000"

    // Logo Gradient Colors (For Dark Background)
    readonly property var logoGradientColors: [
        "#85A7FF", "#D885FF", "#FF85E4", "#FFB885", 
        "#FFCE85", "#85FFA0", "#85FFB6", "#85BDFF"
    ]

    // Mascot Color
    readonly property color mascotColor: "#B896D6"

    // Background Flat Colors
    readonly property color backgroundLightGrey: "#F0F3F7"
    readonly property color backgroundBlack: "#000000"

    // Dark Theme Surface Colors
    readonly property color darkSurfacePrimary: "#0A0A0F"
    readonly property color darkSurfaceSecondary: "#141419"
    readonly property color darkSurfaceHover: "#1E1E28"
    readonly property color darkSurfacePressed: "#2A2A38"

    // UI Structure Colors
    readonly property color borderBright: "#808090"
    readonly property color textMainLight: "#ECEFF4"
    readonly property color textLabelGrey: "#A0A0B0"
    readonly property color textHeadingPurple: "#B0A4D4"
    readonly property color accentPurpleBase: "#9B8EC4"
    readonly property color accentPurplePressed: "#8578B0"
    readonly property color statusGreen: "#A3BE8C"
    readonly property color statusYellow: "#EBCB8B"

    // Background Gradient Colors (Gradient direction 45°)
    readonly property var backgroundGradient1: ["#FFFCAD", "#FFA799"]
    readonly property var backgroundGradient2: ["#F8CDFF", "#C1BCFF"]
    readonly property var backgroundGradient3: ["#FFADED", "#FF9393"]
    readonly property var backgroundGradient4: ["#FFFBA3", "#C1F5A6"]
    readonly property var backgroundGradient5: ["#ADF5FF", "#AEFFAD"]
    readonly property var backgroundGradient6: ["#EFFFC2", "#BEFFD8","#70DFDF"]
    readonly property var backgroundGradient7: ["#A5FFD4","#59CDFF"]
    readonly property var backgroundGradient8: ["#B8FFB8","#7DE075"]
    readonly property var backgroundGradient9: ["#FEE1CD","#9C776C"]
    readonly property var backgroundGradient10: ["#C9CBDE","#8081A0"]
    readonly property var backgroundGradient11: ["#E9CFF5", "#9E8BC6"]
    readonly property var backgroundGradient12: ["#CCFFAD","#91B851"]
    readonly property var backgroundGradient13: ["#DFE0B2","#A8A373"]
    readonly property var backgroundGradient14: ["#EFBDB2","#CD8B8B"]
    readonly property var backgroundGradient15: ["#FFADAD","#E57777"]
    readonly property var backgroundGradient16: ["#98C7FE","#A5F6FF", "#ADFFF0"]
    readonly property var backgroundGradient17: ["#EEFFBD", "#89E5DA","#99A9FF"]


    // Secondary Colors
    readonly property color secondarySalmon: "#FF6B6B"
    readonly property color secondaryJuicypeach: "#FF957A"
    readonly property color secondaryLightorange: "#FF9D57"
    readonly property color secondaryTuscansun: "#F5BD4E"
    readonly property color secondaryOlivegreen: "#C7C758"
    readonly property color secondaryYellowgreen: "#88C758"
    readonly property color secondaryTurquoise: "#39CC7E"
    readonly property color secondaryTurkish: "#18CCB4"
    readonly property color secondaryLightskyblue: "#4BC5EB"
    readonly property color secondaryBlueocean: "#5297FF"
    readonly property color secondarySlateblue: "#7A80FF"
    readonly property color secondaryMediumpurple: "#A983FB"
    readonly property color secondarySweettomato: "#FF7092"
    readonly property color secondaryHotpink: "#FF75D0"
    readonly property color secondaryIndianred: "#D16976"
    readonly property color secondarySienna: "#9D7067"
    readonly property color secondaryBurlywood: "#CCA966"
    readonly property color secondaryPersian: "#51B8B1"
    readonly property color secondaryIndependence: "#566DCC"
    readonly property color secondarySlategray: "#8095A8"
    readonly property color secondaryGreenapple: "#00C74C"
    readonly property color secondaryRedsalmon: "#F5473B"
    readonly property color secondaryOrangepeach: "#F5A631"
    readonly property color secondaryCobaltblue: "#0974FF"
    readonly property color secondaryBlack: "#000000"

    readonly property var allBackgroundGradients: [
        backgroundGradient1, backgroundGradient2, backgroundGradient3, backgroundGradient4, backgroundGradient5,
        backgroundGradient6, backgroundGradient7, backgroundGradient8, backgroundGradient9, backgroundGradient10,
        backgroundGradient11, backgroundGradient12, backgroundGradient13, backgroundGradient14, backgroundGradient15,
        backgroundGradient16, backgroundGradient17
    ]

    readonly property var allSecondaryColors: [
        backgroundLightGrey, logoBlack,
        secondarySalmon, secondaryJuicypeach, secondaryLightorange, secondaryTuscansun,
        secondaryOlivegreen, secondaryYellowgreen, secondaryTurquoise, secondaryTurkish,
        secondaryLightskyblue, secondaryBlueocean, secondarySlateblue, secondaryMediumpurple,
        secondarySweettomato, secondaryHotpink, secondaryIndianred, secondarySienna,
        secondaryBurlywood, secondaryPersian, secondaryIndependence, secondarySlategray,
        secondaryGreenapple, secondaryRedsalmon, secondaryOrangepeach, secondaryCobaltblue
    ]
}
