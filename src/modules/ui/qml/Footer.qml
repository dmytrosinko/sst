import QtQuick
import QtQuick.Layouts

Item {
    id: footer
    implicitHeight: 40

    // ── Black background (same as Header) ──
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#000000"
    }

    // ── Content row: date + time ──
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 10

        Item { Layout.fillWidth: true }

        Text {
            id: dateTimeText
            color: "#a9a3bc"
            font.pixelSize: 16
            font.weight: Font.Medium
            font.letterSpacing: 0.5
            Layout.alignment: Qt.AlignVCenter

            function updateDateTime() {
                var now = new Date()
                var dateStr = Qt.formatDate(now, "dd.MM.yyyy")
                var timeStr = Qt.formatTime(now, "HH:mm:ss")
                text = dateStr + "  |  " + timeStr
            }

            Component.onCompleted: updateDateTime()
        }

        Item { Layout.fillWidth: true }
    }

    // ── Timer to update every second ──
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateTimeText.updateDateTime()
    }
}
