import QtQuick
import QtQuick.Layouts
import modules.controls
import service.testservice

Item {
    id: root

    signal quitRequested()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Thank you")
            color: "#000000"
            font.pixelSize: 24
            font.bold: true
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Go to Main")
            onClicked: root.quitRequested()
        }
    }
}
