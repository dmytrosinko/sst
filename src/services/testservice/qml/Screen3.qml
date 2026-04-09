import QtQuick
import QtQuick.Layouts
import app
import modules.controls
import modules.style
import modules.finance

Item {
    id: root

    property string serviceName: ""

    signal doneRequested()

    // ── Send transaction when this screen loads ────────────────────
    Component.onCompleted: {
        TransactionController.send()
    }

    // ── React to transaction status changes ────────────────────────
    Connections {
        target: TransactionController

        function onStatusChanged() {
            // Force re-evaluation of bound properties
        }
    }

    // ── Loading state (Sent — waiting for backend) ─────────────────
    ColumnLayout {
        id: loadingView
        anchors.centerIn: parent
        spacing: 20
        visible: TransactionController.status === 2  // Sent

        // Spinner placeholder
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            radius: 30
            color: Qt.rgba(0.608, 0.557, 0.769, 0.15)

            Text {
                anchors.centerIn: parent
                text: "⏳"
                font.pixelSize: 28
            }

            RotationAnimation on rotation {
                from: 0; to: 360
                duration: 2000
                loops: Animation.Infinite
                running: loadingView.visible
            }
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("Processing payment...")
            color: Style.currentStyle.textPrimary
            font.pixelSize: 20
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── Success state ──────────────────────────────────────────────
    ColumnLayout {
        id: successView
        anchors.centerIn: parent
        spacing: 30
        width: parent.width * 0.4
        visible: TransactionController.status === 3  // Success

        property var receipt: TransactionController.receiptData()

        // Refresh receipt when status changes to success
        Connections {
            target: TransactionController
            function onStatusChanged() {
                if (TransactionController.status === 3)
                    successView.receipt = TransactionController.receiptData()
            }
        }

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

                // Transaction ID
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Transaction ID")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: successView.receipt.transactionId || "—"
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

                // Amount
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Amount")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: TransactionController.formattedAmount
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

                // Commission
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Commission")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: TransactionController.formattedCommission
                        color: Style.currentStyle.textPrimary
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // Date
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Date")
                        color: Style.currentStyle.textSecondary
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: successView.receipt.date || Qt.formatDateTime(new Date(), "dd.MM.yyyy  HH:mm")
                        color: Style.currentStyle.textPrimary
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // Status
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

    // ── Error state ────────────────────────────────────────────────
    ColumnLayout {
        id: errorView
        anchors.centerIn: parent
        spacing: 30
        width: parent.width * 0.4
        visible: TransactionController.status === 4  // Error

        // ── Error icon ─────────────────────────────────────────────
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            radius: 40
            color: Qt.rgba(0.9, 0.3, 0.3, 0.15)

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: Style.currentStyle.statusWarning
                font.pixelSize: 40
                font.weight: Font.Bold
            }
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("Payment failed")
            color: Style.currentStyle.statusWarning
            font.pixelSize: 28
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true
            text: TransactionController.errorMessage
            color: Style.currentStyle.textSecondary
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: text.length > 0
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Button {
                text: qsTr("RETRY")
                onClicked: TransactionController.send()
            }

            Button {
                text: qsTr("DONE")
                onClicked: root.doneRequested()
            }
        }
    }
}
