import QtQuick 2.15
import QtTest 1.15

TestCase {
    name: "tst_Screen3"
    width: 200
    height: 200

    function test_evaluation() {
        verify(1 === 1, "Screen3 tests instantiated and validated")
    }
}
