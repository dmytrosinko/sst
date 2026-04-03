import QtQuick
import QtQuick.Templates as T
import modules.style

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    leftPadding: 24
    rightPadding: 24

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        radius: height / 2
        color: control.down
               ? Style.currentStyle.accentSecondary
               : (control.hovered ? Style.currentStyle.accentPrimary : Style.currentStyle.surfaceSecondary)
        border.color: control.activeFocus
                      ? Style.currentStyle.accentPrimary
                      : (control.hovered ? Style.currentStyle.accentPrimary : Style.currentStyle.surfacePressed)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
        text: control.text
        font.pixelSize: 15
        font.weight: control.hovered ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.5
        color: control.down
               ? Style.currentStyle.textOnAccent
               : (control.hovered ? Style.currentStyle.textOnAccent : Style.currentStyle.textPrimary)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
