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

        TextField {
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Enter number...")
            inputMethodHints: Qt.ImhDigitsOnly
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: qsTr("Quit")
                onClicked: root.quitRequested()
            }

            Button {
                text: qsTr("Next")
                onClicked: ServiceModel.goToNextScreen()
            }
        }
    }
}
