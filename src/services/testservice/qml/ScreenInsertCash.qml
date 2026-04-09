import QtQuick
import QtQuick.Layouts
import app
import modules.controls
import modules.style
import modules.hardware
import modules.finance

Item {
    id: root

    property string serviceName: ""

    signal quitRequested()
    signal nextRequested()

    // ── Activate validator when screen opens, deactivate on leave ──
    Component.onCompleted: {
        ValidatorController.activate()
    }
    Component.onDestruction: {
        ValidatorController.deactivate()
    }

    // ── Pipe cash insertions to TransactionController ─────────────
    Connections {
        target: ValidatorController
        function onTotalAmountChanged() {
            TransactionController.setAmount(ValidatorController.totalAmount)
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 80
        anchors.rightMargin: 80
        anchors.topMargin: 40
        anchors.bottomMargin: 80
        spacing: 60

        // ── Left Side: Info Panel & Buttons ───────────────────────
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: parent.width * 0.35
            Layout.maximumWidth: parent.width * 0.50
            spacing: 20

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 24

                // ── Service name
                Text {
                    Layout.fillWidth: true
                    text: root.serviceName
                    color: Style.currentStyle.textHeading
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    opacity: 0.9
                    wrapMode: Text.WordWrap
                }

                // ── Title
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Insert cash")
                    color: Style.currentStyle.textPrimary
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }

                // ── Summary card
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
                        anchors.margins: 24
                        spacing: 20

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

                        // Row: Inserted Amount — live from TransactionController
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

                        // Row: Commission — live from TransactionController
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Commission")
                                color: Style.currentStyle.textSecondary
                                font.pixelSize: 14
                            }
                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 6

                                // Loading indicator while commission is being fetched
                                Text {
                                    visible: TransactionController.isCommissionLoading
                                    text: "⏳"
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: TransactionController.formattedCommission
                                    color: Style.currentStyle.textPrimary
                                    font.pixelSize: 14
                                    opacity: TransactionController.isCommissionLoading ? 0.5 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }
                            }
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }

                        // Row: Validator status
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Status")
                                color: Style.currentStyle.textSecondary
                                font.pixelSize: 14
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: ValidatorController.stateName
                                color: {
                                    var s = ValidatorController.stateName
                                    if (s === "Idling")
                                        return Style.currentStyle.statusSuccess
                                    if (s === "Jammed" || s === "Stacker Full"
                                        || s === "Cashbox Removed" || s === "Failure")
                                        return Style.currentStyle.statusWarning
                                    return Style.currentStyle.textSecondary
                                }
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            // ── Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text: qsTr("BACK")
                    onClicked: root.quitRequested()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text: qsTr("NEXT")
                    enabled: TransactionController.amount > 0
                             && !TransactionController.isCommissionLoading
                    onClicked: root.nextRequested()
                }
            }
        }

        // ── Right Side: Cash Validator ────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 350

            CashValidator {
                id: cashValidator
                anchors.top: parent.top
                anchors.topMargin: 120
                anchors.right: parent.right
                transformOrigin: Item.TopRight
                width: 600
                height: 900
                scale: 0.5

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
    }
}
