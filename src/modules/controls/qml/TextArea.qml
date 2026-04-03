import QtQuick
import QtQuick.Templates as T
import modules.style

T.TextArea {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    activeFocusOnPress: true
    color: Style.currentStyle.textPrimary
    selectedTextColor: Style.currentStyle.textPrimary
    selectionColor: Style.currentStyle.accentPrimary

    font.pixelSize: Style.currentStyle.fontSizeNormal

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 120
        color: Style.currentStyle.surfaceSecondary
        border.color: control.activeFocus
                      ? Style.currentStyle.borderAccent
                      : Style.currentStyle.borderDefault
        border.width: 2
        radius: 6
    }
}
