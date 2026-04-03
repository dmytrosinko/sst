import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import service.testservice

Item {
    id: root

    signal quitService()

    QQC2.SwipeView {
        anchors.fill: parent
        currentIndex: ServiceModel.currentScreen
        interactive: false // Only navigate via buttons

        Screen1 {
            onQuitRequested: root.quitService()
        }
        Screen2 {}
        Screen3 {
            onQuitRequested: root.quitService()
        }
    }
}
