import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    property alias text:        inputField.text
    property string defaultPrefix: "KG"
    property int    maxLength:  28      // full IBAN length incl. spaces
    readonly property bool   isValid:   rawValue.length >= 10
    readonly property string rawValue:  inputField.text.replace(/\s/g, "")

    signal accepted()

    implicitWidth:  500
    implicitHeight: 70

    Component.onCompleted: {
        if (inputField.text.length === 0) {
            inputField.text = defaultPrefix
            inputField.cursorPosition = inputField.text.length
        }
    }

    // ── Key insertion helper (called from keyboard) ─────────────────
    function appendKey(ch) {
        var raw = inputField.text.replace(/\s/g, "")
        // Count only uppercase Latin / digits — max 24 raw chars (IBAN max)
        if (raw.length >= 24) return
        raw += ch.toUpperCase()
        _applyFormatted(raw)
    }

    // ── Backspace helper ────────────────────────────────────────────
    function deleteLastKey() {
        var raw = inputField.text.replace(/\s/g, "")
        if (raw.length === 0) return
        raw = raw.substring(0, raw.length - 1)
        _applyFormatted(raw)
    }

    // ── Format raw string into groups of 4 separated by double space ─
    function _applyFormatted(raw) {
        var out = ""
        for (var i = 0; i < raw.length; i++) {
            if (i > 0 && i % 4 === 0) out += "  "
            out += raw[i]
        }
        if (out !== inputField.text) {
            inputField.text = out
            inputField.cursorPosition = out.length
        }
    }

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius:       12
        color:        Style.currentStyle.surfaceSecondary
        border.color: inputField.activeFocus
                      ? Style.currentStyle.borderAccent
                      : Qt.rgba(0.608, 0.557, 0.769, 0.4)
        border.width: 1.5

        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    RowLayout {
        anchors.fill:    parent
        anchors.margins: 10
        spacing:         12

        // ── Icon ───────────────────────────────────────────────────
        Rectangle {
            Layout.preferredWidth:  50
            Layout.preferredHeight: 50
            Layout.alignment:       Qt.AlignVCenter
            radius:                 10
            color:                  Style.currentStyle.surfaceHover

            Image {
                anchors.centerIn: parent
                source:           "qrc:/qt/qml/app/assets/icons/icon_iban.svg"
                sourceSize:       Qt.size(28, 28)
            }
        }

        // ── Read-only display field ─────────────────────────────────
        // We use a plain TextInput with readOnly=true so the user sees the
        // formatted value but all editing goes through appendKey/deleteLastKey.
        // This prevents the virtual keyboard from interfering with formatting.
        TextInput {
            id:                inputField
            Layout.fillWidth:  true
            Layout.alignment:  Qt.AlignVCenter

            readOnly:          true           // keyboard is virtual; no OS IME
            color:             Style.currentStyle.textPrimary
            font.pixelSize:    20
            font.letterSpacing: 2.5
            font.weight:       Font.Medium
            verticalAlignment: TextInput.AlignVCenter
            clip:              true

            // ── Placeholder overlay ────────────────────────────────
            Text {
                anchors.fill:     parent
                verticalAlignment: Text.AlignVCenter
                visible:          inputField.text.length === 0
                text:             "KG_ _  _ _ _ _  _ _ _ _  _ _ _ _"
                color:            Style.currentStyle.textSecondary
                font:             inputField.font
            }
        }
    }
}
