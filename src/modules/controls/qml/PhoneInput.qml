import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    property string prefix: "+996"
    property alias text: inputField.text
    property int maxDigits: 9
    readonly property bool isValid: inputField.text.replace(/\s/g, "").length === maxDigits
    readonly property string rawValue: prefix + inputField.text.replace(/\s/g, "")

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
                source: "qrc:/qt/qml/app/assets/icons/icon_phone.svg"
                sourceSize: Qt.size(28, 28)
            }
        }

        // ── Fixed prefix ───────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.prefix
            color: Style.currentStyle.textPrimary
            font.pixelSize: 22
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        // ── Separator line ─────────────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter
            color: Qt.rgba(0.608, 0.557, 0.769, 0.3)
        }

        // ── Formatted input ────────────────────────────────────────
        TextInput {
            id: inputField
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            color: Style.currentStyle.textPrimary
            font.pixelSize: 22
            font.letterSpacing: 2
            font.weight: Font.Medium
            verticalAlignment: TextInput.AlignVCenter
            inputMethodHints: Qt.ImhDigitsOnly
            maximumLength: maxDigits + 3  // 9 digits + 3 spaces (3-2-2-2)
            activeFocusOnPress: true
            clip: true

            // Auto-format: 3-2-2-2 grouping
            onTextChanged: {
                var raw = text.replace(/\s/g, "")
                if (raw.length > maxDigits) raw = raw.substring(0, maxDigits)
                var groups = [3, 2, 2, 2]
                var formatted = ""
                var pos = 0
                for (var g = 0; g < groups.length && pos < raw.length; g++) {
                    if (g > 0) formatted += " "
                    formatted += raw.substring(pos, pos + groups[g])
                    pos += groups[g]
                }
                if (formatted !== text) {
                    var cp = cursorPosition
                    text = formatted
                    cursorPosition = Math.min(cp, formatted.length)
                }
            }

            onAccepted: root.accepted()

            // ── Placeholder ────────────────────────────────────────
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: inputField.text.length === 0
                text: "_ _ _  _ _  _ _  _ _"
                color: Style.currentStyle.textSecondary
                font: inputField.font
            }
        }
    }
}
