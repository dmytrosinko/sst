import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    property alias text: inputField.text
    property string placeholder: qsTr("Enter data...")
    property int maxLength: 256
    readonly property bool isValid: inputField.text.length > 0
    readonly property string rawValue: inputField.text

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
                source: "qrc:/qt/qml/app/assets/icons/icon_string.svg"
                sourceSize: Qt.size(28, 28)
            }
        }

        // ── Text input ─────────────────────────────────────────────
        TextInput {
            id: inputField
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            color: Style.currentStyle.textPrimary
            font.pixelSize: 20
            font.letterSpacing: 0.5
            font.weight: Font.Medium
            verticalAlignment: TextInput.AlignVCenter
            maximumLength: maxLength
            activeFocusOnPress: true
            clip: true

            onAccepted: root.accepted()

            // ── Placeholder ────────────────────────────────────────
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: inputField.text.length === 0
                text: root.placeholder
                color: Style.currentStyle.textSecondary
                font.pixelSize: inputField.font.pixelSize
                font.italic: true
            }
        }
    }
}
