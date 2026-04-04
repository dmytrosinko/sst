import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────
    signal keyPressed(string key)
    signal backspace()
    signal clear()

    implicitWidth: 482
    implicitHeight: 640

    // ── Numpad grid ────────────────────────────────────────────────
    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 3
        rowSpacing: 8
        columnSpacing: 8

        Repeater {
            model: ["1","2","3","4","5","6","7","8","9","C","0","⌫"]

            delegate: Rectangle {
                id: keyBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Math.min(width, height) * 0.12
                color: keyMa.pressed
                       ? Style.currentStyle.surfacePressed
                       : (keyMa.containsMouse
                          ? Style.currentStyle.surfaceHover
                          : Style.currentStyle.surfaceSecondary)
                border.color: keyMa.containsMouse
                              ? Qt.rgba(0.608, 0.557, 0.769, 0.5)
                              : Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }

                scale: keyMa.pressed ? 0.93 : 1.0

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: {
                        if (modelData === "⌫") return Style.currentStyle.accentPrimary
                        if (modelData === "C") return Style.currentStyle.statusWarning
                        return Style.currentStyle.textPrimary
                    }
                    font.pixelSize: Math.min(keyBtn.width, keyBtn.height) * 0.35
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: keyMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData === "⌫")
                            root.backspace()
                        else if (modelData === "C")
                            root.clear()
                        else
                            root.keyPressed(modelData)
                    }
                }
            }
        }
    }
}
