import QtQuick
import modules.controls

NumericInputScreen {
    title: qsTr("Enter card\nnumber")
    subtitle: qsTr("16-digit card number")
    inputComponent: Component { CardInput {} }
}
