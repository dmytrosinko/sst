import QtQuick
import QtQuick.Layouts
import modules.controls
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    property string serviceName: ""
    property string title: ""
    property string subtitle: ""
    property Component inputComponent: null

    // Reference to the loaded input control (set after Loader completes)
    readonly property Item inputControl: inputLoader.item

    signal quitRequested()
    signal nextRequested()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 30

        // ── Left panel: info + input ───────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: parent.width * 0.45
            spacing: 20

            Item { Layout.fillHeight: true }

            Text {
                Layout.fillWidth: true
                text: root.serviceName
                color: Style.currentStyle.textHeading
                font.pixelSize: 20
                font.weight: Font.DemiBold
                opacity: 0.9
            }

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Style.currentStyle.textPrimary
                font.pixelSize: 32
                font.weight: Font.Bold
                lineHeight: 1.2
                wrapMode: Text.WordWrap
            }

            Text {
                text: root.subtitle
                color: Style.currentStyle.textSecondary
                font.pixelSize: 16
                visible: text.length > 0
            }

            Loader {
                id: inputLoader
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                sourceComponent: root.inputComponent
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Button {
                    text: qsTr("BACK")
                    onClicked: root.quitRequested()
                }

                Button {
                    text: qsTr("NEXT")
                    enabled: inputLoader.item && inputLoader.item.isValid
                    onClicked: root.nextRequested()
                }
            }

            Item { Layout.fillHeight: true }
        }

        // ── Right panel: numpad ────────────────────────────────────
        NumPad {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.45

            onKeyPressed: function(key) {
                if (inputLoader.item) inputLoader.item.text += key
            }
            onBackspace: {
                if (inputLoader.item) {
                    var raw = inputLoader.item.text
                    if (raw.length > 0)
                        inputLoader.item.text = raw.substring(0, raw.length - 1)
                }
            }
            onClear: {
                if (inputLoader.item) inputLoader.item.text = ""
            }
        }
    }
}
