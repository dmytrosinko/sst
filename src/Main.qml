import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.Layouts
import modules.hardware
import modules.controls
import service.testservice

Window {
    id: window
    visibility: Window.FullScreen
    visible: true
    width: Screen.width
    height: Screen.height
    title: qsTr("SST")
    color: "#D8DEE9"

    // Language Toggle
    Button {
        id: langToggle
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: 60
        height: 40
        text: TranslationManager.isEnglish ? "EN" : "KY"
        z: 100 // keep above viewport
        
        // background: Rectangle {
        //    // color: "#ECEFF4"
        //     radius: 4
        //     border.color: "#D8DEE9"
        // }
        
        onClicked: TranslationManager.toggleLanguage()
    }

    Item {
        id: viewport
        width: parent.width
        height: parent.height


        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            Item {
                Layout.fillHeight: true
            }

            HardwareInfo {
                Layout.alignment: Qt.AlignHCenter
                // Layout.preferredWidth: parent.width * 0.4
                // Layout.preferredHeight: parent.width * 0.4 * 1.2
                visible: !serviceView.visible
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                visible: !serviceView.visible
                text: qsTr("Start Service")
                // Layout.preferredWidth: parent.width * 0.3
                // Layout.preferredHeight: parent.width * 0.3 * 0.3
                onClicked: {
                    ServiceModel.goToScreen(0)
                    serviceView.visible = true
                }
            }

            Item {
                Layout.fillHeight: true
            }

            // Test controls replaced by actual service instance for testing

        }

        Service {
            id: serviceView
            visible: false
            anchors.fill: parent

            onQuitService: {
                // Return to main layout by hiding the service and resetting model
                visible = false
            }
        }
    }

}
