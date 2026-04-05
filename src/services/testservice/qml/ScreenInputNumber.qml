import QtQuick
import modules.controls

NumericInputScreen {
    title: qsTr("Enter\nnumber")
    subtitle: qsTr("Account number or identifier")
    inputComponent: Component { NumberInput {} }
}
