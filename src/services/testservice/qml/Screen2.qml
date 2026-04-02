import QtQuick
import QtQuick.Layouts
import modules.controls
import service.testservice

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        TextField {
            Layout.alignment: Qt.AlignHCenter
            placeholderText: qsTr("Enter string...")
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: qsTr("Back")
                onClicked: ServiceModel.goToPreviouseScreen()
            }

            Button {
                text: qsTr("Next")
                onClicked: ServiceModel.goToNextScreen()
            }
        }
    }
}
