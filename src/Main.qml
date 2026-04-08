import QtQuick
import modules.ui
Window {
    id: window
    property size targetSize : Qt.size(1280,920)
    property real globalScale: Math.min(Screen.width / targetSize.width, Screen.height / targetSize.height)
    visibility: Window.FullScreen
    visible: true
    width: Screen.width
    height: Screen.height
    title: qsTr("SST")
    color: "#D8DEE9"

    Shortcut {
        sequence: "Ctrl+X"
        onActivated: Qt.quit()
    }

    Component.onCompleted: {
        homeLoader.active = true;
    }

    Rectangle {
            anchors.fill: parent
            color:"#F0F3F7"
    }


    Item {
        id: splash
        anchors.fill: parent
        visible: homeLoader.status !== Loader.Ready

        Image {
            id: logo
            source: "assets/logo.svg"
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.3
            height: width
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(width, height)
        }
    }

    Loader {
        id: homeLoader
        active: false
        width: window.targetSize.width
        height: window.targetSize.height
        anchors.centerIn: parent
        scale: window.globalScale
        asynchronous: true
        source: "qrc:/qt/qml/modules/ui/Home.qml"
        opacity: status === Loader.Ready ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }
}
