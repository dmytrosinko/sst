import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    property alias text: inputField.text
    property string defaultPrefix: "KG"
    property int maxLength: 24           // full IBAN length (prefix + 22)
    readonly property bool isValid: inputField.text.replace(/\s/g, "").length >= 10
    readonly property string rawValue: inputField.text.replace(/\s/g, "")

    signal accepted()

    implicitWidth: 500
    implicitHeight: 70

    Component.onCompleted: {
        // Pre-fill the editable prefix
        if (inputField.text.length === 0) {
            inputField.text = defaultPrefix
            inputField.cursorPosition = inputField.text.length
        }
    }

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 12
        color: Style.currentStyle.surfaceSecondary
        border.color: inputField.activeFocus
                      ? Style.currentStyle.borderAccent
                      : Qt.rgba(0.608, 0.557, 0.769, 0.4)
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
                source: "qrc:/qt/qml/app/assets/icons/icon_iban.svg"
                sourceSize: Qt.size(28, 28)
            }
        }

        // ── Editable IBAN field (prefix is prefilled but editable) ─
        TextInput {
            id: inputField
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            color: Style.currentStyle.textPrimary
            font.pixelSize: 20
            font.letterSpacing: 2.5
            font.weight: Font.Medium
            verticalAlignment: TextInput.AlignVCenter
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhLatinOnly
            activeFocusOnPress: true
            clip: true

            // Auto-uppercase + format in groups of 4
            onTextChanged: {
                var raw = text.replace(/\s/g, "").toUpperCase()
                if (raw.length > maxLength) raw = raw.substring(0, maxLength)
                var formatted = ""
                for (var i = 0; i < raw.length; i++) {
                    if (i > 0 && i % 4 === 0) formatted += "  "
                    formatted += raw[i]
                }
                if (formatted !== text) {
                    var oldLen = text.length
                    var pos = cursorPosition
                    text = formatted
                    cursorPosition = Math.min(pos + (formatted.length - oldLen), formatted.length)
                }
            }

            onAccepted: root.accepted()

            // ── Placeholder ────────────────────────────────────────
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: inputField.text.length === 0
                text: "KG_ _  _ _ _ _  _ _ _ _  _ _ _ _"
                color: Style.currentStyle.textSecondary
                font: inputField.font
            }
        }
    }
}
