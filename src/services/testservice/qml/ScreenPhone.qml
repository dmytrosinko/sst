import QtQuick
import modules.controls

NumericInputScreen {
    title: qsTr("Enter your\nphone number")
    subtitle: qsTr("To receive OTP code")
    inputComponent: Component { PhoneInput {} }

    // ── Extra disclaimer below the buttons ──
    // (handled via the base layout — disclaimer is screen-specific)
}
