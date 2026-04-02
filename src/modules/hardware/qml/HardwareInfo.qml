import QtQuick
import modules.hardware

Item {
    id: root
    width: 300
    height: 200

    SystemInfo {
        id: sysInfo
    }

    Rectangle {
        anchors.fill: parent
        color: "#2E3440"
        border.color: "#88C0D0"
        border.width: 2
        radius: 8

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: qsTr("Hardware Status")
                color: "#8FBCBB"
                font.bold: true
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                columns: 2
                spacing: 10

                Text { text: qsTr("CPU Usage:"); color: "#D8DEE9"; font.pixelSize: 14 }
                Text { text: sysInfo.cpuUsage; color: "#A3BE8C"; font.pixelSize: 14; font.bold: true }

                Text { text: qsTr("Total RAM:"); color: "#D8DEE9"; font.pixelSize: 14 }
                Text { text: sysInfo.totalRam; color: "#A3BE8C"; font.pixelSize: 14; font.bold: true }

                Text { text: qsTr("Avail RAM:"); color: "#D8DEE9"; font.pixelSize: 14 }
                Text { text: sysInfo.availableRam; color: "#88C0D0"; font.pixelSize: 14; font.bold: true }

                Text { text: qsTr("FPS:"); color: "#D8DEE9"; font.pixelSize: 14 }
                Text { text: sysInfo.fps; color: "#EBCB8B"; font.pixelSize: 14; font.bold: true }
            }
        }
    }

    FrameAnimation {
        running: true
        onTriggered: sysInfo.registerFrame()
    }
}
