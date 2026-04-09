import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Dialogs
import modules.style
import app

Window {
    id: root
    width: 1200
    height: 680
    title: "Style Configurator"
    visible: true

    // ── Color utilities ────────────────────────────────────────────────

    // Used for the live swatch display only.
    function colorToHex(c) {
        if (!c) return "#000000"
        var hex = Qt.color(c).toString().toUpperCase()
        if (hex.length === 9) {
            var alpha = parseInt(hex.substring(1, 3), 16)
            if (alpha >= 255) return "#" + hex.substring(3)
        }
        return hex
    }

    // Build a hex→"SimbankPallete.xxx" reverse lookup from every named
    // flat-color property in SimbankPallete.
    function buildPaletteMap() {
        var names = [
            "logoWhite", "logoBlack",
            "backgroundLightGrey", "backgroundBlack",
            "darkSurfacePrimary", "darkSurfaceSecondary",
            "darkSurfaceHover", "darkSurfacePressed",
            "borderBright", "textMainLight", "textLabelGrey",
            "textHeadingPurple", "accentPurpleBase", "accentPurplePressed",
            "statusGreen", "statusYellow", "mascotColor",
            "secondarySalmon", "secondaryJuicypeach", "secondaryLightorange",
            "secondaryTuscansun", "secondaryOlivegreen", "secondaryYellowgreen",
            "secondaryTurquoise", "secondaryTurkish", "secondaryLightskyblue",
            "secondaryBlueocean", "secondarySlateblue", "secondaryMediumpurple",
            "secondarySweettomato", "secondaryHotpink", "secondaryIndianred",
            "secondarySienna", "secondaryBurlywood", "secondaryPersian",
            "secondaryIndependence", "secondarySlategray", "secondaryGreenapple",
            "secondaryRedsalmon", "secondaryOrangepeach", "secondaryCobaltblue",
            "secondaryBlack"
        ]
        var map = {}
        for (var i = 0; i < names.length; i++) {
            var hex = colorToHex(SimbankPallete[names[i]])
            if (hex && !map[hex])           // first match wins
                map[hex] = "SimbankPallete." + names[i]
        }
        return map
    }

    // Return a QML rvalue for a color: either "SimbankPallete.xxx" or "\"#RRGGBB\"".
    function colorToRef(c, map) {
        if (!c) return "\"#000000\""
        var hex = colorToHex(c)
        return map[hex] ? map[hex] : ("\"" + hex + "\"")
    }

    // Return a QML rvalue for a gradient array.
    // Tries to match one of the 17 named backgroundGradients; falls back to inline array.
    function gradientToRef(grad) {
        // normalise grad to uppercase hex strings for comparison
        var norm = []
        for (var k = 0; k < grad.length; k++)
            norm.push(colorToHex(grad[k]))

        for (var n = 1; n <= 17; n++) {
            var pg = SimbankPallete["backgroundGradient" + n]
            if (!pg || pg.length !== norm.length) continue
            var match = true
            for (var j = 0; j < pg.length; j++) {
                if (colorToHex(pg[j]) !== norm[j]) { match = false; break }
            }
            if (match) return "SimbankPallete.backgroundGradient" + n
        }
        // Fallback: inline array of quoted hex strings
        return "[" + norm.map(function(h) { return "\"" + h + "\"" }).join(", ") + "]"
    }

    function generateQml() {
        var s   = Style.currentStyle
        var pm  = buildPaletteMap()
        var c   = function(v) { return colorToRef(v, pm) }
        return [
            "pragma Singleton",
            "import QtQuick",
            "",
            "QtObject {",
            "    // ── Background colors ──",
            "    property color background:         " + c(s.background),
            "    property color surfacePrimary:     " + c(s.surfacePrimary),
            "    property color surfaceSecondary:   " + c(s.surfaceSecondary),
            "    property color surfaceHover:       " + c(s.surfaceHover),
            "    property color surfacePressed:     " + c(s.surfacePressed),
            "",
            "    // ── Border / outline colors ──",
            "    property color borderDefault:      " + c(s.borderDefault),
            "    property color borderAccent:       " + c(s.borderAccent),
            "    property color borderStrong:       " + c(s.borderStrong),
            "",
            "    // ── Text colors ──",
            "    property color textPrimary:        " + c(s.textPrimary),
            "    property color textSecondary:      " + c(s.textSecondary),
            "    property color textOnAccent:       " + c(s.textOnAccent),
            "    property color textHeading:        " + c(s.textHeading),
            "",
            "    // ── Accent / status colors ──",
            "    property color accentPrimary:      " + c(s.accentPrimary),
            "    property color accentSecondary:    " + c(s.accentSecondary),
            "    property color statusSuccess:      " + c(s.statusSuccess),
            "    property color statusWarning:      " + c(s.statusWarning),
            "",
            "    // ── Dynamic Themed Colors ──",
            "    property var   backgroundGradient:      " + gradientToRef(s.backgroundGradient),
            "    property color tileColor:               " + c(s.tileColor),
            "    property color categoryTileColor:       " + c(s.categoryTileColor),
            "    property color buttonColor:             " + c(s.buttonColor),
            "    property color buttonDisabledColor:     " + c(s.buttonDisabledColor),
            "    property color backButtonColor:         " + c(s.backButtonColor),
            "    property color backButtonDisabledColor: " + c(s.backButtonDisabledColor),
            "    property color languageToggleColor:     " + c(s.languageToggleColor),
            "",
            "    // ── Per-component text colors ──",
            "    property color tileTextColor:               " + c(s.tileTextColor),
            "    property color categoryTileTextColor:       " + c(s.categoryTileTextColor),
            "    property color buttonTextColor:             " + c(s.buttonTextColor),
            "    property color buttonTextDisabledColor:     " + c(s.buttonTextDisabledColor),
            "    property color backButtonTextColor:         " + c(s.backButtonTextColor),
            "    property color backButtonTextDisabledColor: " + c(s.backButtonTextDisabledColor),
            "    property color languageToggleTextColor:           " + c(s.languageToggleTextColor),
            "    property color languageToggleUnselectedTextColor: " + c(s.languageToggleUnselectedTextColor),
            "",
            "    // ── Keyboard colors ──",
            "    property color keyboardBackground:      " + c(s.keyboardBackground),
            "    property color keyColor:                " + c(s.keyColor),
            "    property color keyHoverColor:           " + c(s.keyHoverColor),
            "    property color keyPressedColor:         " + c(s.keyPressedColor),
            "    property color keyTextColor:            " + c(s.keyTextColor),
            "    property color keyHighlightTextColor:   " + c(s.keyHighlightTextColor),
            "    property color keyHighlightColor:       " + c(s.keyHighlightColor),
            "    property color keyAccentTextColor:      " + c(s.keyAccentTextColor),
            "    property color keyPopupTextColor:       " + c(s.keyPopupTextColor),
            "    property color keyPopupActiveTextColor: " + c(s.keyPopupActiveTextColor),
            "",
            "    // ── Input field colors ──",
            "    property color inputTextColor:          " + c(s.inputTextColor),
            "    property color inputPlaceholderColor:   " + c(s.inputPlaceholderColor),
            "    property color inputBackgroundColor:    " + c(s.inputBackgroundColor),
            "    property color inputBorderColor:        " + c(s.inputBorderColor),
            "",
            "    // ── Typography ──",
            "    readonly property string fontFamily:  SimbankPallete.fontFamily",
            "    readonly property int fontSizeSmall:  14",
            "    readonly property int fontSizeNormal: 16",
            "    readonly property int fontSizeLarge:  18",
            "    readonly property int fontSizeXLarge: 24",
            "}"
        ].join("\n")
    }

    // ── Groups definition ──────────────────────────────────────────────
    property int activeGroup: 0

    readonly property var groups: [
        {
            name: "Background",
            isGradient: true,
            items: []
        },
        {
            name: "Tiles & Buttons",
            isGradient: false,
            items: [
                { key: "tileColor",               label: "Tile Color" },
                { key: "categoryTileColor",        label: "Category Tile" },
                { key: "buttonColor",              label: "Button BG" },
                { key: "buttonDisabledColor",      label: "Btn Disabled BG" },
                { key: "backButtonColor",          label: "Back Button" },
                { key: "backButtonDisabledColor",  label: "Back Btn Disabled" },
                { key: "languageToggleColor",      label: "Lang Toggle" }
            ]
        },
        {
            name: "Surfaces & Borders",
            isGradient: false,
            items: [
                { key: "background",       label: "Background" },
                { key: "surfacePrimary",   label: "Surface Primary" },
                { key: "surfaceSecondary", label: "Surface Secondary" },
                { key: "surfaceHover",     label: "Surface Hover" },
                { key: "surfacePressed",   label: "Surface Pressed" },
                { key: "borderDefault",    label: "Border Default" },
                { key: "borderAccent",     label: "Border Accent" },
                { key: "borderStrong",     label: "Border Strong" }
            ]
        },
        {
            name: "Text Colors",
            isGradient: false,
            items: [
                { key: "textPrimary",                          label: "Text Primary" },
                { key: "textSecondary",                        label: "Text Secondary" },
                { key: "textHeading",                          label: "Text Heading" },
                { key: "textOnAccent",                         label: "Text On Accent" },
                { key: "tileTextColor",                        label: "Tile Text" },
                { key: "categoryTileTextColor",                label: "Cat Tile Text" },
                { key: "buttonTextColor",                      label: "Button Text" },
                { key: "buttonTextDisabledColor",              label: "Btn Text Disabled" },
                { key: "backButtonTextColor",                  label: "Back Btn Text" },
                { key: "backButtonTextDisabledColor",          label: "Back Btn Disabled" },
                { key: "languageToggleTextColor",              label: "Lang Toggle Text" },
                { key: "languageToggleUnselectedTextColor",    label: "Lang Unselected Text" }
            ]
        },
        {
            name: "Accent & Status",
            isGradient: false,
            items: [
                { key: "accentPrimary",   label: "Accent Primary" },
                { key: "accentSecondary", label: "Accent Secondary" },
                { key: "statusSuccess",   label: "Status Success" },
                { key: "statusWarning",   label: "Status Warning" }
            ]
        },
        {
            name: "Keyboard",
            isGradient: false,
            items: [
                { key: "keyboardBackground",      label: "Key Background" },
                { key: "keyColor",                label: "Key Default" },
                { key: "keyHoverColor",           label: "Key Hover" },
                { key: "keyPressedColor",         label: "Key Pressed" },
                { key: "keyTextColor",            label: "Key Text" },
                { key: "keyHighlightColor",       label: "Key Highlight" },
                { key: "keyHighlightTextColor",   label: "Highlight Text" },
                { key: "keyAccentTextColor",      label: "Accent Text" },
                { key: "keyPopupTextColor",       label: "Popup Text" },
                { key: "keyPopupActiveTextColor", label: "Popup Active" }
            ]
        },
        {
            name: "Input Fields",
            isGradient: false,
            items: [
                { key: "inputTextColor",        label: "Input Text" },
                { key: "inputPlaceholderColor", label: "Placeholder" },
                { key: "inputBackgroundColor",  label: "Input Background" },
                { key: "inputBorderColor",      label: "Input Border" }
            ]
        }
    ]

    // ── Inline components ──────────────────────────────────────────────

    component ColorPickerColumn: ColumnLayout {
        id: cpc
        required property string propKey
        required property string label

        Layout.preferredWidth: 130
        Layout.fillHeight: true
        spacing: 4

        Text {
            text: cpc.label
            font.pixelSize: 11
            font.bold: true
            color: "#c8c8ff"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 26
            radius: 5
            color: Style.currentStyle[cpc.propKey] || "transparent"
            border.color: "#ffffff"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: Style.currentStyle[cpc.propKey]
                      ? root.colorToHex(Style.currentStyle[cpc.propKey]) : ""
                color: {
                    var col = Style.currentStyle[cpc.propKey]
                    return col ? (Qt.color(col).hslLightness < 0.45 ? "#ffffff" : "#000000") : "#000000"
                }
                font.pixelSize: 9
                font.family: "Courier New"
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: SimbankPallete.allSecondaryColors

            delegate: Item {
                width: ListView.view.width
                height: 36

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    color: modelData
                    radius: 4
                    border.color: {
                        var cur = Style.currentStyle[cpc.propKey]
                        return cur ? (Qt.color(modelData).toString() === Qt.color(cur).toString() ? "white" : "transparent") : "transparent"
                    }
                    border.width: 2
                }
                Text {
                    anchors.fill: parent
                    text: modelData
                    color: Qt.color(modelData).hslLightness < 0.45 ? "#ffffff" : "#000000"
                    font.pixelSize: 9
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Style.currentStyle[cpc.propKey] = modelData
                }
            }
        }
    }

    component GradientPickerColumn: ColumnLayout {
        id: gCol
        Layout.preferredWidth: 130
        Layout.fillHeight: true
        spacing: 4

        Text {
            text: "Background\nGradient"
            font.pixelSize: 11
            font.bold: true
            color: "#c8c8ff"
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: SimbankPallete.allBackgroundGradients

            delegate: Item {
                id: gDelegate
                width: ListView.view.width
                height: 52

                // Capture modelData locally — GradientStop runs in document
                // scope (not delegate scope) so it cannot see modelData directly.
                property var colors: modelData

                Shape {
                    anchors.fill: parent
                    anchors.margins: 2
                    ShapePath {
                        PathLine { x: gDelegate.width; y: 0 }
                        PathLine { x: gDelegate.width; y: gDelegate.height }
                        PathLine { x: 0;               y: gDelegate.height }
                        PathLine { x: 0;               y: 0 }
                        fillGradient: LinearGradient {
                            x1: 0; y1: gDelegate.height
                            x2: gDelegate.width; y2: 0
                            GradientStop { position: 0.0; color: gDelegate.colors[0] }
                            GradientStop {
                                position: gDelegate.colors.length === 3 ? 0.5 : 1.0
                                color: gDelegate.colors[1]
                            }
                            GradientStop {
                                position: 1.0
                                color: gDelegate.colors.length === 3 ? gDelegate.colors[2] : gDelegate.colors[1]
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "G" + (index + 1)
                    color: "black"
                    font.pixelSize: 10
                    font.bold: true
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: "transparent"
                    border.color: JSON.stringify(gDelegate.colors) === JSON.stringify(Style.currentStyle.backgroundGradient)
                                  ? "white" : "transparent"
                    border.width: 2
                    radius: 3
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Style.currentStyle.backgroundGradient = gDelegate.colors

                }
            }
        }
    }


    // ── File save dialog ───────────────────────────────────────────────
    FileDialog {
        id: saveDialog
        fileMode:      FileDialog.SaveFile
        defaultSuffix: "qml"
        nameFilters:   ["QML Files (*.qml)"]
        title:         "Save Style as QML"

        onAccepted: {
            var ok = FileWriter.writeFile(selectedFile, root.generateQml())
            toast.show(ok
                ? "\u2713  Saved: " + selectedFile.toString().replace(/.*\//, "")
                : "\u2717  Failed to write file")
        }
    }

    // ── Toast notification ─────────────────────────────────────────────
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        width: toastText.implicitWidth + 32
        height: 38
        radius: 8
        z: 9999
        opacity: 0
        color: toastText.text.startsWith("\u2713") ? "#1d5c1d" : "#5c1d1d"

        Text {
            id: toastText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 13
            font.bold: true
        }

        function show(msg) {
            toastText.text = msg
            toastAnim.restart()
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toast; property: "opacity"; to: 1; duration: 180 }
            PauseAnimation  { duration: 2800 }
            NumberAnimation { target: toast; property: "opacity"; to: 0; duration: 400 }
        }
    }


    // ── Main layout ────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Left sidebar ──────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 174
                Layout.fillHeight: true
                color: "#11112a"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Title
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: "#0e0e22"

                        Text {
                            anchors.centerIn: parent
                            text: "Style Configurator"
                            color: "#7a80ff"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a4e" }

                    // Group buttons
                    Repeater {
                        model: root.groups
                        delegate: Item {
                            id: groupBtn
                            Layout.fillWidth: true
                            height: 44

                            property bool hovered: false
                            property bool active: root.activeGroup === index

                            Rectangle {
                                anchors.fill: parent
                                color: groupBtn.active ? "#22224e"
                                     : groupBtn.hovered ? "#1a1a3e"
                                     : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }

                                // Active accent bar
                                Rectangle {
                                    width: 3
                                    height: 24
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: 2
                                    color: groupBtn.active ? "#7a80ff" : "transparent"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    color: groupBtn.active ? "#ffffff" : "#9090b8"
                                    font.pixelSize: 13
                                    font.bold: groupBtn.active
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: groupBtn.hovered = true
                                onExited:  groupBtn.hovered = false
                                onClicked: root.activeGroup = index
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Save button in sidebar footer
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#2a2a4e"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 54
                        color: "#0e0e22"

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - 20
                            height: 36
                            radius: 7
                            color: saveHover.containsMouse ? "#3a60d0" : "#2a50c0"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "💾  Save Style"
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                id: saveHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: saveDialog.open()
                            }
                        }
                    }
                }
            }

            // Vertical separator
            Rectangle { width: 1; Layout.fillHeight: true; color: "#2a2a4e" }

            // ── Content area ──────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Group header bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    color: "#14143a"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.groups[root.activeGroup].name
                        color: "#ffffff"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            var g = root.groups[root.activeGroup]
                            return g.isGradient
                                ? SimbankPallete.allBackgroundGradients.length + " gradients"
                                : g.items.length + " colors"
                        }
                        color: "#666688"
                        font.pixelSize: 12
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a4e" }

                // Horizontal color pickers scroll
                ScrollView {
                    id: colorScrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: pickerRow.implicitWidth + 24
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

                    RowLayout {
                        id: pickerRow
                        // Reference the ScrollView directly — parent inside ScrollView
                        // is the Flickable's internal contentItem whose height is 0.
                        height: colorScrollView.height - 20
                        spacing: 8
                        x: 12
                        y: 10

                        // Gradient picker — only for Background group
                        GradientPickerColumn {
                            visible: root.groups[root.activeGroup].isGradient
                            Layout.preferredWidth: visible ? 130 : 0
                        }

                        // Dynamic color pickers for the active group's items
                        Repeater {
                            model: root.groups[root.activeGroup].items
                            delegate: Item {
                                id: wrapper
                                // 'required' forces the Repeater to inject modelData;
                                // inline components don't receive it automatically.
                                required property var modelData
                                Layout.preferredWidth: 130
                                Layout.fillHeight: true

                                ColorPickerColumn {
                                    anchors.fill: parent
                                    propKey: wrapper.modelData ? wrapper.modelData.key   : ""
                                    label:   wrapper.modelData ? wrapper.modelData.label : ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
