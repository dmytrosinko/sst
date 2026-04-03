import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    property alias text: inputField.text
    property int maxDigits: 16
    readonly property bool isValid: inputField.text.replace(/\s/g, "").length === maxDigits
    readonly property string rawValue: inputField.text.replace(/\s/g, "")

    signal accepted()

    implicitWidth: 500
    implicitHeight: 70

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 12
        color: Style.currentStyle.surfaceSecondary
        border.color: inputField.activeFocus
                      ? Style.currentStyle.borderAccent
                      : Qt.rgba(0.608, 0.557, 0.769, 0.4)   // borderAccent @ 40%
        border.width: 1.5

        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        // ── Icon container ─────────────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: Style.currentStyle.surfaceHover

            Image {
                anchors.centerIn: parent
                source: "qrc:/qt/qml/app/assets/icons/icon_card.svg"
                sourceSize: Qt.size(28, 28)
            }
        }

        // ── Formatted input ────────────────────────────────────────
        TextInput {
            id: inputField
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            color: Style.currentStyle.textPrimary
            font.pixelSize: 22
            font.letterSpacing: 3
            font.weight: Font.Medium
            verticalAlignment: TextInput.AlignVCenter
            inputMethodHints: Qt.ImhDigitsOnly
            maximumLength: maxDigits + Math.floor((maxDigits - 1) / 4) // digits + spaces
            activeFocusOnPress: true
            clip: true

            // Auto-format: insert space every 4 digits
            onTextChanged: {
                var raw = text.replace(/\s/g, "")
                if (raw.length > maxDigits) raw = raw.substring(0, maxDigits)
                var formatted = ""
                for (var i = 0; i < raw.length; i++) {
                    if (i > 0 && i % 4 === 0) formatted += "  "
                    formatted += raw[i]
                }
                if (formatted !== text) {
                    var pos = cursorPosition
                    text = formatted
                    cursorPosition = Math.min(pos, formatted.length)
                }
            }

            onAccepted: root.accepted()

            // ── Placeholder overlay ────────────────────────────────
            Text {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                visible: inputField.text.length === 0
                text: "_ _ _ _   _ _ _ _   _ _ _ _   _ _ _ _"
                color: Style.currentStyle.textSecondary
                font: inputField.font
            }
        }
    }
}
