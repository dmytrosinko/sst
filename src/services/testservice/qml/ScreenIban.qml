import QtQuick
import modules.controls

NumericInputScreen {
    title: qsTr("Enter IBAN\nnumber")
    subtitle: qsTr("For bank transfer")
    inputComponent: Component { IbanInput {} }
}
