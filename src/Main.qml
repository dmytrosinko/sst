import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.Layouts
import modules.hardware
import modules.controls
import service.testservice

Window {
    id: window
    width: 640
    height: 480
    visible: true
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
        text: TranslationManager.isEnglish ? "EN" : "KK"
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

        y: {
            if (inputPanel.active && window.activeFocusItem && typeof window.activeFocusItem.mapToItem === 'function') {
                let mapped = window.activeFocusItem.mapToItem(viewport, 0, 0)
                let itemCenterY = mapped.y + window.activeFocusItem.height / 2
                let remainingHeight = window.height - inputPanel.height
                return (remainingHeight / 2) - itemCenterY
            }
            return 0
        }

        Behavior on y {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            HardwareInfo {
                Layout.alignment: Qt.AlignHCenter
                visible: !serviceView.visible
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                visible: !serviceView.visible
                text: qsTr("Start Service")
                onClicked: {
                    ServiceModel.goToScreen(0)
                    serviceView.visible = true
                }
            }

            // Test controls replaced by actual service instance for testing
            Service {
                id: serviceView
                visible: false
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 600
                Layout.preferredHeight: 300
                
                onQuitService: {
                    // Return to main layout by hiding the service and resetting model
                    visible = false
                }
            }
        }
    }

    InputPanel {
        id: inputPanel
        z: 99
        y: window.height
        width: window.width
        active: Qt.inputMethod.visible


        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                inputPanel.y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            NumberAnimation {
                properties: "y"
                easing.type: Easing.InOutQuad
            }
        }
    }
}
