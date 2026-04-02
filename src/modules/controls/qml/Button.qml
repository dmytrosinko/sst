import QtQuick
import QtQuick.Templates as T

T.Button {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: control.down ? "#4C566A" : (control.hovered ? "#434C5E" : "#3B4252")
        border.color: control.activeFocus ? "#88C0D0" : "#2E3440"
        border.width: 2
        radius: 6
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.down ? "#2E3440" : (control.hovered ? "#2E3440" : "#ECEFF4")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
