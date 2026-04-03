import QtQuick
import modules.hardware
import modules.style

Item {
    id: root
    width: 300
    height: 200

    SystemInfo {
        id: sysInfo
    }

    Rectangle {
        anchors.fill: parent
        color: Style.currentStyle.surfaceSecondary
        border.color: Style.currentStyle.borderAccent
        border.width: 2
        radius: 8

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: qsTr("Hardware Status")
                color: Style.currentStyle.textHeading
                font.bold: true
                font.pixelSize: Style.currentStyle.fontSizeLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                columns: 2
                spacing: 10

                Text { text: qsTr("CPU Usage:"); color: Style.currentStyle.textPrimary; font.pixelSize: Style.currentStyle.fontSizeSmall }
                Text { text: sysInfo.cpuUsage; color: Style.currentStyle.statusSuccess; font.pixelSize: Style.currentStyle.fontSizeSmall; font.bold: true }

                Text { text: qsTr("Total RAM:"); color: Style.currentStyle.textPrimary; font.pixelSize: Style.currentStyle.fontSizeSmall }
                Text { text: sysInfo.totalRam; color: Style.currentStyle.statusSuccess; font.pixelSize: Style.currentStyle.fontSizeSmall; font.bold: true }

                Text { text: qsTr("Avail RAM:"); color: Style.currentStyle.textPrimary; font.pixelSize: Style.currentStyle.fontSizeSmall }
                Text { text: sysInfo.availableRam; color: Style.currentStyle.accentPrimary; font.pixelSize: Style.currentStyle.fontSizeSmall; font.bold: true }

                Text { text: qsTr("FPS:"); color: Style.currentStyle.textPrimary; font.pixelSize: Style.currentStyle.fontSizeSmall }
                Text { text: sysInfo.fps; color: Style.currentStyle.statusWarning; font.pixelSize: Style.currentStyle.fontSizeSmall; font.bold: true }
            }
        }
    }

    FrameAnimation {
        running: true
        onTriggered: sysInfo.registerFrame()
    }
}
