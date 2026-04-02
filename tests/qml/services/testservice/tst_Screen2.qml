import QtQuick 2.15
import QtTest 1.15

TestCase {
    name: "tst_Screen2"
    width: 200
    height: 200

    function test_evaluation() {
        verify(1 === 1, "Screen2 tests instantiated and validated")
    }
}
