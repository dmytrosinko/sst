import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import modules.style

Window {
    id: root
    width: 600
    height: 400
    title: "Gradient Selector"
    visible: true

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        model: SimbankPallete.allBackgroundGradients

        delegate: Item {
            id: delegate
            width: 100
            height: 50
            
            // radius: 10
            // border.color: modelData === SimbankPallete.currentBackgroundGradient ? "blue" : "transparent"
            // border.width: 3

            Shape {
                anchors.fill: parent

                ShapePath {
                    PathLine { x: delegate.width; y: 0 }
                    PathLine { x: delegate.width; y: delegate.height }
                    PathLine { x: 0; y: delegate.height }
                    PathLine { x: 0; y: 0 }
                    fillGradient: LinearGradient {
                        x1: 0; y1: delegate.height
                        x2: delegate.width; y2: 0

                        GradientStop {
                            position: 0.0; color: modelData[0]
                        }
                        GradientStop {
                            position: modelData.length === 3 ? 0.5 : 1.0; color: modelData[1]
                        }
                        GradientStop {
                            position: 1.0; color: modelData.length === 3 ? modelData[2] : modelData[1]
                        }
                    }
                    // fillGradient: Gradient {
                    //     GradientStop { position: 0.0; color: modelData[0] }
                    //     GradientStop { position: modelData.length === 3 ? 0.5 : 1.0; color: modelData[1] }
                    //     GradientStop { position: 1.0; color: modelData.length === 3 ? modelData[2] : modelData[1] }
                    // }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "bGradient" + (index + 1)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    SimbankPallete.currentBackgroundGradient = modelData
                }
            }
        }
    }
}
