import QtQuick
import QtQuick.Layouts
import app
import modules.controls
import modules.style

Item {
    id: root

    property string serviceName: ""
    property string title:    qsTr("Enter IBAN\nnumber")
    property string subtitle: qsTr("For bank transfer")

    signal quitRequested()
    signal nextRequested()

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: 30
        spacing:         20

        // ── Top panel: info + input ────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                Layout.fillWidth: true
                text:                  root.serviceName
                color:                 Style.currentStyle.textHeading
                font.pixelSize:        20
                font.weight:           Font.DemiBold
                horizontalAlignment:   Text.AlignHCenter
                opacity:               0.9
            }

            Text {
                Layout.fillWidth: true
                text:                  root.title
                color:                 Style.currentStyle.textPrimary
                font.pixelSize:        28
                font.weight:           Font.Bold
                horizontalAlignment:   Text.AlignHCenter
                lineHeight:            1.2
            }

            Text {
                Layout.fillWidth: true
                text:                  root.subtitle
                color:                 Style.currentStyle.textSecondary
                font.pixelSize:        16
                horizontalAlignment:   Text.AlignHCenter
                visible:               text.length > 0
            }

            IbanInput {
                id: ibanInput
                Layout.fillWidth:   true
                Layout.preferredHeight: 70
                Layout.maximumWidth: 600
                Layout.alignment:   Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 600
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text:      qsTr("BACK")
                    onClicked: root.quitRequested()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text:      qsTr("NEXT")
                    enabled:   ibanInput.isValid
                    onClicked: root.nextRequested()
                }
            }
        }

        // ── Bottom panel: full string keyboard ─────────────────────
        StringKeyboard {
            id: keyboard
            Layout.fillWidth:   true


            // IBAN is always uppercase Latin — lock uppercase, hide lang/shift
            uppercaseMode:       true
            language:            "en"
            hideLanguageButton:  true
            hideShiftButton:     true

            onKeyPressed: function(key) {
                // Accept only alphanumeric characters (IBAN charset)
                if (/^[A-Z0-9]$/.test(key.toUpperCase()))
                    ibanInput.appendKey(key.toUpperCase())
            }
            onBackspace: ibanInput.deleteLastKey()
            onSpacePressed: { /* no spaces in IBAN */ }
        }
    }
}
