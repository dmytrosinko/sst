import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import modules.style

Window {
    id: root
    width: 900
    height: 520
    title: "Theme Selector"
    visible: true

    // ─── reusable color-picker column component ───────────────────────
    component ColorPickerColumn: ColumnLayout {
        id: colRoot
        required property string label
        required property color currentColor
        signal colorPicked(color c)

        Layout.preferredWidth: 130
        Layout.fillHeight: true
        spacing: 4

        Text {
            text: colRoot.label
            font.pixelSize: 11
            font.bold: true
            color: "#ffffff"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 22
            radius: 4
            color: colRoot.currentColor
            border.color: "#ffffff"
            border.width: 1
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
                    border.color: modelData === colRoot.currentColor ? "white" : "transparent"
                    border.width: 2
                }
                Text {
                    anchors.fill: parent
                    text: modelData
                    color: modelData === "#000000" ? "#ffffff" : "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: colRoot.colorPicked(modelData)
                }
            }
        }
    }

    // ─── gradient picker column ────────────────────────────────────────
    component GradientPickerColumn: ColumnLayout {
        id: gCol
        Layout.preferredWidth: 130
        Layout.fillHeight: true
        spacing: 4

        Text {
            text: "Background\nGradient"
            font.pixelSize: 11
            font.bold: true
            color: "#ffffff"
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: SimbankPallete.allBackgroundGradients

            delegate: Item {
                id: gDelegate
                width: ListView.view.width
                height: 50

                Shape {
                    anchors.fill: parent
                    anchors.margins: 2
                    ShapePath {
                        PathLine { x: gDelegate.width; y: 0 }
                        PathLine { x: gDelegate.width; y: gDelegate.height }
                        PathLine { x: 0; y: gDelegate.height }
                        PathLine { x: 0; y: 0 }
                        fillGradient: LinearGradient {
                            x1: 0; y1: gDelegate.height
                            x2: gDelegate.width; y2: 0
                            GradientStop { position: 0.0; color: modelData[0] }
                            GradientStop { position: modelData.length === 3 ? 0.5 : 1.0; color: modelData[1] }
                            GradientStop { position: 1.0; color: modelData.length === 3 ? modelData[2] : modelData[1] }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "G" + (index + 1)
                    color: "black"
                    font.pixelSize: 10
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: "transparent"
                    border.color: JSON.stringify(modelData) === JSON.stringify(Style.currentStyle.backgroundGradient) ? "white" : "transparent"
                    border.width: 2
                    radius: 2
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Style.currentStyle.backgroundGradient = modelData
                }
            }
        }
    }

    // ─── root layout ──────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"

        ScrollView {
            id: scrollView
            anchors.fill: parent
            anchors.margins: 8
            contentWidth: mainRow.implicitWidth
            contentHeight: scrollView.height
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

            RowLayout {
                id: mainRow
                height: scrollView.height - 24
                spacing: 8

                GradientPickerColumn {}

                ColorPickerColumn {
                    label: "Tile Color"
                    currentColor: Style.currentStyle.tileColor
                    onColorPicked: function(c) { Style.currentStyle.tileColor = c }
                }
                ColorPickerColumn {
                    label: "Category Tile"
                    currentColor: Style.currentStyle.categoryTileColor
                    onColorPicked: function(c) { Style.currentStyle.categoryTileColor = c }
                }
                ColorPickerColumn {
                    label: "Button"
                    currentColor: Style.currentStyle.buttonColor
                    onColorPicked: function(c) { Style.currentStyle.buttonColor = c }
                }
                ColorPickerColumn {
                    label: "Back Button"
                    currentColor: Style.currentStyle.backButtonColor
                    onColorPicked: function(c) { Style.currentStyle.backButtonColor = c }
                }
                ColorPickerColumn {
                    label: "Lang Toggle"
                    currentColor: Style.currentStyle.languageToggleColor
                    onColorPicked: function(c) { Style.currentStyle.languageToggleColor = c }
                }

                // ── Separator ──
                Rectangle { width: 1; Layout.fillHeight: true; color: "#444" }

                ColorPickerColumn {
                    label: "Background"
                    currentColor: Style.currentStyle.background
                    onColorPicked: function(c) { Style.currentStyle.background = c }
                }
                ColorPickerColumn {
                    label: "Surface Primary"
                    currentColor: Style.currentStyle.surfacePrimary
                    onColorPicked: function(c) { Style.currentStyle.surfacePrimary = c }
                }
                ColorPickerColumn {
                    label: "Surface Secondary"
                    currentColor: Style.currentStyle.surfaceSecondary
                    onColorPicked: function(c) { Style.currentStyle.surfaceSecondary = c }
                }
                ColorPickerColumn {
                    label: "Surface Hover"
                    currentColor: Style.currentStyle.surfaceHover
                    onColorPicked: function(c) { Style.currentStyle.surfaceHover = c }
                }
                ColorPickerColumn {
                    label: "Surface Pressed"
                    currentColor: Style.currentStyle.surfacePressed
                    onColorPicked: function(c) { Style.currentStyle.surfacePressed = c }
                }

                // ── Separator ──
                Rectangle { width: 1; Layout.fillHeight: true; color: "#444" }

                ColorPickerColumn {
                    label: "Border Default"
                    currentColor: Style.currentStyle.borderDefault
                    onColorPicked: function(c) { Style.currentStyle.borderDefault = c }
                }
                ColorPickerColumn {
                    label: "Border Accent"
                    currentColor: Style.currentStyle.borderAccent
                    onColorPicked: function(c) { Style.currentStyle.borderAccent = c }
                }
                ColorPickerColumn {
                    label: "Border Strong"
                    currentColor: Style.currentStyle.borderStrong
                    onColorPicked: function(c) { Style.currentStyle.borderStrong = c }
                }

                // ── Separator ──
                Rectangle { width: 1; Layout.fillHeight: true; color: "#444" }

                ColorPickerColumn {
                    label: "Text Primary"
                    currentColor: Style.currentStyle.textPrimary
                    onColorPicked: function(c) { Style.currentStyle.textPrimary = c }
                }
                ColorPickerColumn {
                    label: "Text Secondary"
                    currentColor: Style.currentStyle.textSecondary
                    onColorPicked: function(c) { Style.currentStyle.textSecondary = c }
                }
                ColorPickerColumn {
                    label: "Text Heading"
                    currentColor: Style.currentStyle.textHeading
                    onColorPicked: function(c) { Style.currentStyle.textHeading = c }
                }
                ColorPickerColumn {
                    label: "Text On Accent"
                    currentColor: Style.currentStyle.textOnAccent
                    onColorPicked: function(c) { Style.currentStyle.textOnAccent = c }
                }

                // ── Separator ──
                Rectangle { width: 1; Layout.fillHeight: true; color: "#444" }

                ColorPickerColumn {
                    label: "Accent Primary"
                    currentColor: Style.currentStyle.accentPrimary
                    onColorPicked: function(c) { Style.currentStyle.accentPrimary = c }
                }
                ColorPickerColumn {
                    label: "Accent Secondary"
                    currentColor: Style.currentStyle.accentSecondary
                    onColorPicked: function(c) { Style.currentStyle.accentSecondary = c }
                }
                ColorPickerColumn {
                    label: "Status Success"
                    currentColor: Style.currentStyle.statusSuccess
                    onColorPicked: function(c) { Style.currentStyle.statusSuccess = c }
                }
                ColorPickerColumn {
                    label: "Status Warning"
                    currentColor: Style.currentStyle.statusWarning
                    onColorPicked: function(c) { Style.currentStyle.statusWarning = c }
                }

                // ── Separator ──
                Rectangle { width: 1; Layout.fillHeight: true; color: "#444" }

                // ── Per-component text colors ──
                ColorPickerColumn {
                    label: "Tile Text"
                    currentColor: Style.currentStyle.tileTextColor
                    onColorPicked: function(c) { Style.currentStyle.tileTextColor = c }
                }
                ColorPickerColumn {
                    label: "Cat Tile Text"
                    currentColor: Style.currentStyle.categoryTileTextColor
                    onColorPicked: function(c) { Style.currentStyle.categoryTileTextColor = c }
                }
                ColorPickerColumn {
                    label: "Button Text"
                    currentColor: Style.currentStyle.buttonTextColor
                    onColorPicked: function(c) { Style.currentStyle.buttonTextColor = c }
                }
                ColorPickerColumn {
                    label: "Back Btn Text"
                    currentColor: Style.currentStyle.backButtonTextColor
                    onColorPicked: function(c) { Style.currentStyle.backButtonTextColor = c }
                }

                // ── Separator ──
                Rectangle { width: 1; Layout.fillHeight: true; color: "#444" }

                // ── Keyboard colors ──
                ColorPickerColumn {
                    label: "Key BG"
                    currentColor: Style.currentStyle.keyboardBackground
                    onColorPicked: function(c) { Style.currentStyle.keyboardBackground = c }
                }
                ColorPickerColumn {
                    label: "Key Default"
                    currentColor: Style.currentStyle.keyColor
                    onColorPicked: function(c) { Style.currentStyle.keyColor = c }
                }
                ColorPickerColumn {
                    label: "Key Hover"
                    currentColor: Style.currentStyle.keyHoverColor
                    onColorPicked: function(c) { Style.currentStyle.keyHoverColor = c }
                }
                ColorPickerColumn {
                    label: "Key Pressed"
                    currentColor: Style.currentStyle.keyPressedColor
                    onColorPicked: function(c) { Style.currentStyle.keyPressedColor = c }
                }
                ColorPickerColumn {
                    label: "Key Text"
                    currentColor: Style.currentStyle.keyTextColor
                    onColorPicked: function(c) { Style.currentStyle.keyTextColor = c }
                }
                ColorPickerColumn {
                    label: "Key Highlight"
                    currentColor: Style.currentStyle.keyHighlightColor
                    onColorPicked: function(c) { Style.currentStyle.keyHighlightColor = c }
                }
                ColorPickerColumn {
                    label: "Key Accent Text"
                    currentColor: Style.currentStyle.keyAccentTextColor
                    onColorPicked: function(c) { Style.currentStyle.keyAccentTextColor = c }
                }
                ColorPickerColumn {
                    label: "Key Highlight Text"
                    currentColor: Style.currentStyle.keyHighlightTextColor
                    onColorPicked: function(c) { Style.currentStyle.keyHighlightTextColor = c }
                }
                ColorPickerColumn {
                    label: "Popup Text"
                    currentColor: Style.currentStyle.keyPopupTextColor
                    onColorPicked: function(c) { Style.currentStyle.keyPopupTextColor = c }
                }
                ColorPickerColumn {
                    label: "Popup Active Text"
                    currentColor: Style.currentStyle.keyPopupActiveTextColor
                    onColorPicked: function(c) { Style.currentStyle.keyPopupActiveTextColor = c }
                }
            }
        }
    }
}
