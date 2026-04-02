import QtQuick 2.15
import QtTest 1.15
import "../../../../src/modules/controls/qml" as MyControls

TestCase {
    name: "tst_TextField"
    width: 200
    height: 200

    MyControls.TextField {
        id: testField
        text: "TestField"
        placeholderText: "Empty"
    }

    function test_properties() {
        verify(testField.text === "TestField", "TextField binds internal string formats accurately")
        verify(testField.leftPadding > 0, "LeftPadding explicitly styled according to custom design constraints")
        
        // Simulate Key presses implicitly
        testField.forceActiveFocus()
        testField.clear()
        keyClick(Qt.Key_H)
        keyClick(Qt.Key_E)
        verify(testField.text === "he", "TextField evaluates raw key input logic");
    }
}
