import QtQuick
import QtQuick.Templates as T

T.TextField {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    // When the user taps the field, snag focus so VirtualKeyboard can activate.
    activeFocusOnPress: true
    color: "#ECEFF4"
    selectedTextColor: "#ECEFF4"
    selectionColor: "#81A1C1"
    
    font.pixelSize: 16
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 10

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: "#2E3440"
        border.color: control.activeFocus ? "#88C0D0" : "#4C566A"
        border.width: 2
        radius: 6
    }
}
