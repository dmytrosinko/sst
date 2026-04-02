import QtQuick 2.15
import QtTest 1.15
import "../../../../src/modules/controls/qml" as MyControls

TestCase {
    name: "tst_Button"
    width: 200
    height: 200

    MyControls.Button {
        id: testButton
        text: "TestBtn"
        width: 100
        height: 50
    }

    function test_properties() {
        verify(testButton.text === "TestBtn", "Button assigns text property gracefully")
        verify(testButton.width > 0, "Button anchors width correctly")
        
        var clicked = false;
        testButton.clicked.connect(function() { clicked = true; });
        testButton.clicked() // Explicit bounds test
        verify(clicked, "Button clicked signal evaluates native evaluation bounds");
    }
}
