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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "Main Background"
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                model: SimbankPallete.allBackgroundGradients

                delegate: Item {
                    id: delegate
                    width: ListView.view.width
                    height: 50

                    // radius: 10
                    // border.color: modelData === SimbankPallete.currentBackgroundGradient ? "blue" : "transparent"
                    // border.width: 3

                    Shape {
                        anchors.fill: parent
                        anchors.margins: 2

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
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "bGradient" + (index + 1)
                        color: "black"
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
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "Tiles Background"
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                model: SimbankPallete.allSecondaryColors

                delegate: Item {
                    id: tileDelegate
                    width: ListView.view.width
                    height: 50

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: modelData
                        border.color: modelData === SimbankPallete.currentTileColor ? "white" : "transparent"
                        border.width: 2
                        radius: 4
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "TileColor " + modelData
                        color: "black"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            SimbankPallete.currentTileColor = modelData
                        }
                    }
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "Button Background"
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: SimbankPallete.allSecondaryColors
                delegate: Item {
                    width: ListView.view.width
                    height: 50
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: modelData
                        border.color: modelData === SimbankPallete.currentButtonColor ? "white" : "transparent"
                        border.width: 2
                        radius: 4
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Button " + modelData
                        color: "black"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            SimbankPallete.currentButtonColor = modelData
                        }
                    }
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "BackButton Background"
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: SimbankPallete.allSecondaryColors
                delegate: Item {
                    width: ListView.view.width
                    height: 50
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: modelData
                        border.color: modelData === SimbankPallete.currentBackButtonColor ? "white" : "transparent"
                        border.width: 2
                        radius: 4
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "BackBtn " + modelData
                        color: "black"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            SimbankPallete.currentBackButtonColor = modelData
                        }
                    }
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "LanguageToggle Selected"
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: SimbankPallete.allSecondaryColors
                delegate: Item {
                    width: ListView.view.width
                    height: 50
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: modelData
                        border.color: modelData === SimbankPallete.currentLanguageToggleSelectedColor ? "white" : "transparent"
                        border.width: 2
                        radius: 4
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "LangTgl " + modelData
                        color: "black"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            SimbankPallete.currentLanguageToggleSelectedColor = modelData
                        }
                    }
                }
            }
        }
    }
}
