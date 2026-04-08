import QtQuick
import modules.style

Rectangle {
    id: control

    // ── Public API ──────────────────────────────────────────────────
    signal clicked()

    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed

    // ── Sizing ──────────────────────────────────────────────────────
    implicitWidth: 44
    implicitHeight: 44
    radius: height / 2

    // ── Styling ─────────────────────────────────────────────────────
    color: control.pressed
           ? Qt.darker(Style.currentStyle.backButtonColor, 1.2)
           : (control.hovered
              ? Qt.lighter(Style.currentStyle.backButtonColor, 1.2)
              : Style.currentStyle.backButtonColor)
    border.color: control.hovered
                  ? Style.currentStyle.borderAccent
                  : Style.currentStyle.borderDefault
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // ── Icon ────────────────────────────────────────────────────────
    Image {
        anchors.centerIn: parent
        source: "qrc:/qt/qml/app/assets/icons/back_arrow.svg"
        sourceSize.width: control.height * 0.50
        sourceSize.height: control.height * 0.50
    }

    // ── Interaction ─────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
    }
}
