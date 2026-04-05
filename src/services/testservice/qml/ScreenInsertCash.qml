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
        anchors.centerIn: parent
        spacing: 24
        width: parent.width * 0.5

        // ── Service name ───────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: root.serviceName
            color: Style.currentStyle.textHeading
            font.pixelSize: 20
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.9
        }

        // ── Title ──────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: qsTr("Confirm details")
            color: Style.currentStyle.textPrimary
            font.pixelSize: 28
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Summary card ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: summaryColumn.implicitHeight + 40
            radius: 12
            color: Style.currentStyle.surfaceSecondary
            border.color: Qt.rgba(0.608, 0.557, 0.769, 0.3)
            border.width: 1

            ColumnLayout {
                id: summaryColumn
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // Row: Service
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Service")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.serviceName
                        color: Style.currentStyle.textPrimary
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // Row: Amount
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Amount")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "100.00 KGS"
                        color: Style.currentStyle.statusSuccess
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // Row: Commission
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Commission")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "0.00 KGS"
                        color: Style.currentStyle.textPrimary
                        font.pixelSize: 14
                    }
                }
            }
        }

        // ── Cash Validator ─────────────────────────────────────────
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 300
            Layout.preferredHeight: 450
            Layout.topMargin: 20
            
            CashValidator {
                id: cashValidator
                width: 600
                height: 900
                scale: 0.5
                transformOrigin: Item.TopLeft
                
                Component.onCompleted: {
                    // Automatically start the insertion animation after a short delay
                    insertionTimer.start()
                }

                Timer {
                    id: insertionTimer
                    interval: 500
                    onTriggered: cashValidator.insertCash()
                }
            }
        }

        // ── Buttons ────────────────────────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Button {
                text: qsTr("BACK")
                onClicked: root.quitRequested()
            }

            Button {
                text: qsTr("CONFIRM")
                onClicked: root.nextRequested()
            }
        }
    }
}
