import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import modules.hardware
import modules.style

Window {
    id: root
    width: 420
    height: 540
    title: "Cash Validator Emulator"
    visible: true
    color: "#1a1a2e"

    // ── Denomination buttons ──────────────────────────────────────────
    readonly property var denominations: [
        { value: 1000,  label: "10",   color: "#2d6a4f" },
        { value: 2000,  label: "20",   color: "#40916c" },
        { value: 5000,  label: "50",   color: "#52b788" },
        { value: 10000, label: "100",  color: "#74c69d" },
        { value: 20000, label: "200",  color: "#95d5b2" },
        { value: 50000, label: "500",  color: "#b7e4c7" },
        { value: 100000,label: "1000", color: "#d8f3dc" }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ── Header ───────────────────────────────────────────────────
        Text {
            text: "💵  Validator Emulator"
            color: "#7a80ff"
            font.pixelSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // ── Status card ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: statusCol.implicitHeight + 24
            radius: 10
            color: "#11112a"
            border.color: "#2a2a4e"
            border.width: 1

            ColumnLayout {
                id: statusCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "State:"; color: "#9090b8"; font.pixelSize: 13 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: ValidatorController.stateName
                        color: {
                            var s = ValidatorController.state
                            if (s === 2) return "#52b788"       // Idling
                            if (s === 4) return "#f9c74f"       // Escrowed
                            if (s >= 10) return "#e76f51"       // Error states
                            return "#c8c8ff"
                        }
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a4e" }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Inserted:"; color: "#9090b8"; font.pixelSize: 13 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: ValidatorController.formattedAmount
                        color: "#52b788"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a4e" }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Accepting:"; color: "#9090b8"; font.pixelSize: 13 }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 12; height: 12; radius: 6
                        color: ValidatorController.accepting ? "#52b788" : "#e76f51"
                    }
                    Text {
                        text: ValidatorController.accepting ? "YES" : "NO"
                        color: ValidatorController.accepting ? "#52b788" : "#e76f51"
                        font.pixelSize: 13; font.bold: true
                    }
                }
            }
        }

        // ── Denomination grid ────────────────────────────────────────
        Text {
            text: "Insert bill"
            color: "#9090b8"
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: root.denominations
                delegate: Rectangle {
                    id: denomBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 8
                    color: denomMouse.containsMouse
                           ? Qt.lighter(modelData.color, 1.2)
                           : modelData.color
                    opacity: ValidatorController.accepting
                             && ValidatorController.state === 2 ? 1.0 : 0.4 // Idling = 2

                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: modelData.label
                            color: "#1a1a2e"
                            font.pixelSize: 20
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: ValidatorController.currency
                            color: "#1a1a2e"
                            font.pixelSize: 10
                            opacity: 0.7
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: denomMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: ValidatorController.accepting && ValidatorController.state === 2
                        onClicked: {
                            var emu = ValidatorController.emulator()
                            if (emu) {
                                emu.insertBill(modelData.value)
                            }
                        }
                    }
                }
            }
        }

        // ── Action buttons (accept / reject escrowed bill) ───────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: ValidatorController.state === 4 // Escrowed

            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 8
                color: acceptMouse.containsMouse ? "#40916c" : "#2d6a4f"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "✓  Accept"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    id: acceptMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: ValidatorController.acceptBill()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 8
                color: rejectMouse.containsMouse ? "#c1121f" : "#9b2226"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "✗  Reject"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    id: rejectMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: ValidatorController.rejectBill()
                }
            }
        }

        // ── Trouble simulation ───────────────────────────────────────
        Text {
            text: "Simulate"
            color: "#9090b8"
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { label: "🔧  Jam",            action: "simulateJam" },
                    { label: "✓  Clear Jam",       action: "clearJam" },
                    { label: "📦  Box Full",        action: "simulateCashboxFull" },
                    { label: "📤  Box Removed",     action: "simulateCashboxRemoved" },
                    { label: "📥  Box Inserted",    action: "simulateCashboxInserted" },
                    { label: "⚡  Power Cycle",     action: "simulatePowerCycle" },
                    { label: "⚠  Cheat",           action: "simulateCheat" }
                ]

                delegate: Rectangle {
                    width: simText.implicitWidth + 20
                    height: 32
                    radius: 6
                    color: simMouse.containsMouse ? "#2a2a5e" : "#1e1e42"
                    border.color: "#3a3a6e"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }

                    Text {
                        id: simText
                        anchors.centerIn: parent
                        text: modelData.label
                        color: "#c8c8ff"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: simMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var emu = ValidatorController.emulator()
                            if (emu) emu[modelData.action]()
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
