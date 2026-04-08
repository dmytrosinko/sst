import QtQuick
import QtQuick.Layouts
import modules.style

Item {
    id: root

    // ── Public API ──
    // Array of { label: "EN", value: "en" } objects
    property var languages: []
    property int currentIndex: 0

    signal languageSelected(int index, var language)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // ── Internal ──
    readonly property int _count: languages.length
    readonly property real _radius: height / 2

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.languages

            delegate: Item {
                id: toggleBtn
                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property bool isFirst: index === 0
                readonly property bool isLast:  index === root._count - 1
                readonly property bool isActive: root.currentIndex === index

                Rectangle {
                    topLeftRadius: isFirst ? root._radius : 0
                    bottomLeftRadius: isFirst ? root._radius : 0
                    topRightRadius: isLast ? root._radius : 0
                    bottomRightRadius: isLast ? root._radius : 0
                    anchors.fill: parent
                    color: {
                        if (toggleBtn.isActive) {
                            return mouseArea.pressed
                                   ? Qt.darker(Style.currentStyle.languageToggleColor, 1.2)
                                   : Style.currentStyle.languageToggleColor
                        }
                        return mouseArea.containsMouse
                               ? Style.currentStyle.textHeading
                               : Style.currentStyle.surfaceSecondary
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                // Label
                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    color: toggleBtn.isActive
                           ? Style.currentStyle.background
                           : Style.currentStyle.textPrimary
                    font.pixelSize: root.height * 0.36
                    font.weight: toggleBtn.isActive ? Font.DemiBold : Font.Normal
                    font.letterSpacing: 0.5

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.currentIndex = index
                        root.languageSelected(index, root.languages[index])
                    }
                }
            }
        }
    }
}
