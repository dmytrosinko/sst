import QtQuick 2.15
import QtTest 1.15
import "../../../../src/modules/controls/qml" as MyControls

TestCase {
    name: "tst_TextArea"
    width: 200
    height: 200

    MyControls.TextArea {
        id: testArea
        text: "Initial"
    }

    function test_properties() {
        verify(testArea.text === "Initial", "TextArea defaults internally evaluated properly")
    }
}
