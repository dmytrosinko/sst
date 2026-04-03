import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    signal keyPressed(string key)
    signal backspace()
    signal spacePressed()

    property bool uppercaseMode: true

    implicitWidth: 700
    implicitHeight: 260

    readonly property var _rows: [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["Z","X","C","V","B","N","M"]
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        Repeater {
            model: root._rows

            delegate: RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 5

                // Center shorter rows
                Item {
                    Layout.fillWidth: modelData.length < 10
                    visible: modelData.length < 10
                }

                Repeater {
                    model: modelData

                    delegate: Rectangle {
                        id: keyRect
                        Layout.preferredWidth: 56
                        Layout.fillHeight: true
                        radius: 8
                        color: keyMouse.pressed
                               ? Style.currentStyle.surfacePressed
                               : (keyMouse.containsMouse
                                  ? Style.currentStyle.surfaceHover
                                  : Style.currentStyle.surfaceSecondary)
                        border.color: keyMouse.containsMouse
                                      ? Qt.rgba(0.608, 0.557, 0.769, 0.4)
                                      : Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }
                        scale: keyMouse.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.uppercaseMode ? modelData : modelData.toLowerCase()
                            color: Style.currentStyle.textPrimary
                            font.pixelSize: Math.min(keyRect.width, keyRect.height) * 0.38
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: keyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var ch = root.uppercaseMode ? modelData : modelData.toLowerCase()
                                root.keyPressed(ch)
                            }
                        }
                    }
                }

                // Center shorter rows
                Item {
                    Layout.fillWidth: modelData.length < 10
                    visible: modelData.length < 10
                }
            }
        }

        // ── Bottom row: Shift / Space / Backspace ──────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            spacing: 6

            // Shift key
            Rectangle {
                Layout.preferredWidth: 80
                Layout.fillHeight: true
                radius: 8
                color: root.uppercaseMode
                       ? Style.currentStyle.accentPrimary
                       : (shiftMa.containsMouse
                          ? Style.currentStyle.surfaceHover
                          : Style.currentStyle.surfaceSecondary)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "⇧"
                    color: root.uppercaseMode
                           ? Style.currentStyle.textOnAccent
                           : Style.currentStyle.textPrimary
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: shiftMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.uppercaseMode = !root.uppercaseMode
                }
            }

            // Space bar
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: spaceMa.pressed
                       ? Style.currentStyle.surfacePressed
                       : (spaceMa.containsMouse
                          ? Style.currentStyle.surfaceHover
                          : Style.currentStyle.surfaceSecondary)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("SPACE")
                    color: Style.currentStyle.textSecondary
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    font.letterSpacing: 2
                }

                MouseArea {
                    id: spaceMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.spacePressed()
                }
            }

            // Backspace
            Rectangle {
                Layout.preferredWidth: 80
                Layout.fillHeight: true
                radius: 8
                color: bsMa.pressed
                       ? Style.currentStyle.surfacePressed
                       : (bsMa.containsMouse
                          ? Style.currentStyle.surfaceHover
                          : Style.currentStyle.surfaceSecondary)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "⌫"
                    color: Style.currentStyle.accentPrimary
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: bsMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backspace()
                }
            }
        }
    }
}
