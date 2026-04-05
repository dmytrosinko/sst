import QtQuick
import QtQuick.Layouts
import app
import modules.controls
import modules.style

Item {
    id: root

    property string serviceName: ""

    signal quitRequested()
    signal nextRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        // ── Top panel: info + input ────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                Layout.fillWidth: true
                text: root.serviceName
                color: Style.currentStyle.textHeading
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.9
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Enter information")
                color: Style.currentStyle.textPrimary
                font.pixelSize: 28
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Information for service")
                color: Style.currentStyle.textSecondary
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            StringInput {
                id: stringInput
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Button {
                    text: qsTr("BACK")
                    onClicked: root.quitRequested()
                }

                Button {
                    text: qsTr("NEXT")
                    enabled: stringInput.isValid
                    onClicked: root.nextRequested()
                }
            }
        }

        // ── Bottom panel: full keyboard ────────────────────────────
        StringKeyboard {
            Layout.fillWidth: true

            language: TranslationManager.currentLanguage

            onKeyPressed: function(key) {
                stringInput.text += key
            }
            onBackspace: {
                var raw = stringInput.text
                if (raw.length > 0)
                    stringInput.text = raw.substring(0, raw.length - 1)
            }
            onSpacePressed: stringInput.text += " "
            onLanguageSwitch: TranslationManager.toggleLanguage()
        }
    }
}
