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
    color: Style.currentStyle.inputTextColor
    selectedTextColor: Style.currentStyle.inputTextColor
    selectionColor: Style.currentStyle.accentPrimary

    font.pixelSize: Style.currentStyle.fontSizeNormal

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 120
        color: Style.currentStyle.inputBackgroundColor
        border.color: control.activeFocus
                      ? Style.currentStyle.inputBorderColor
                      : Style.currentStyle.borderDefault
        border.width: 2
        radius: 6
    }
}
