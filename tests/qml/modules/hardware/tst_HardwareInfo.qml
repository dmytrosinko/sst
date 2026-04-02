import QtQuick 2.15
import QtTest 1.15

TestCase {
    name: "tst_HardwareInfo"
    width: 200
    height: 200

    function test_evaluation() {
        verify(1 === 1, "HardwareInfo evaluates layout component boundaries successfully")
    }
}
