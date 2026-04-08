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
                return Style.currentStyle.buttonDisabledColor
            if (control.down)
                return Qt.darker(Style.currentStyle.buttonColor, 1.2)
            if (control.hovered)
                return Qt.lighter(Style.currentStyle.buttonColor, 1.2)
            return Style.currentStyle.buttonColor
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
        font.weight: control.hovered && control.enabled ? Font.Bold : Font.Bold
        font.letterSpacing: 0.5
        color: {
            if (!control.enabled)
                return Style.currentStyle.buttonTextDisabledColor
            if (control.down)
                return Qt.darker(Style.currentStyle.buttonTextColor, 0.8)
            if (control.hovered)
                return Qt.lighter(Style.currentStyle.buttonTextColor, 1.1)
            return Style.currentStyle.buttonTextColor
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        opacity: control.enabled ? 1.0 : 0.4

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
