import QtQuick
import QtQuick.Layouts
import modules.controls
import modules.style

Item {
    id: root

    property string serviceName: ""

    signal doneRequested()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30
        width: parent.width * 0.4

        // ── Success icon ───────────────────────────────────────────
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            radius: 40
            color: Qt.rgba(0.639, 0.745, 0.549, 0.15) // statusSuccess @ 15%

            Text {
                anchors.centerIn: parent
                text: "✓"
                color: Style.currentStyle.statusSuccess
                font.pixelSize: 40
                font.weight: Font.Bold
            }
        }

        // ── Title ──────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: qsTr("Payment successful")
            color: Style.currentStyle.statusSuccess
            font.pixelSize: 28
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Subtitle ───────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: root.serviceName
            color: Style.currentStyle.textSecondary
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Receipt card ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: receiptColumn.implicitHeight + 32
            radius: 12
            color: Style.currentStyle.surfaceSecondary
            border.color: Qt.rgba(0.639, 0.745, 0.549, 0.3)
            border.width: 1

            ColumnLayout {
                id: receiptColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

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
                        color: Style.currentStyle.textPrimary
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Date")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Qt.formatDateTime(new Date(), "dd.MM.yyyy  HH:mm")
                        color: Style.currentStyle.textPrimary
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Status")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: qsTr("Completed")
                        color: Style.currentStyle.statusSuccess
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        // ── Button ─────────────────────────────────────────────────
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("DONE")
            onClicked: root.doneRequested()
        }
    }
}
