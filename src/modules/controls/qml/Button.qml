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
        color: {
            if (!control.enabled)
                return Style.currentStyle.surfaceSecondary
            if (control.down)
                return Style.currentStyle.accentSecondary
            if (control.hovered)
                return Style.currentStyle.accentPrimary
            return Style.currentStyle.surfaceSecondary
        }
        border.color: {
            if (!control.enabled)
                return Style.currentStyle.surfacePressed
            if (control.activeFocus)
                return Style.currentStyle.accentPrimary
            if (control.hovered)
                return Style.currentStyle.accentPrimary
            return Style.currentStyle.surfacePressed
        }
        border.width: 1
        opacity: control.enabled ? 1.0 : 0.4

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    contentItem: Text {
        text: control.text
        font.pixelSize: 15
        font.weight: control.hovered && control.enabled ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.5
        color: {
            if (!control.enabled)
                return Style.currentStyle.textSecondary
            if (control.down)
                return Style.currentStyle.textOnAccent
            if (control.hovered)
                return Style.currentStyle.textOnAccent
            return Style.currentStyle.textPrimary
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        opacity: control.enabled ? 1.0 : 0.4

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
