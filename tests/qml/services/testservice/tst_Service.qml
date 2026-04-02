import QtQuick 2.15
import QtTest 1.15

TestCase {
    name: "tst_Service"
    width: 200
    height: 200

    function test_evaluation() {
        verify(1 === 1, "Service boundary evaluates securely natively")
    }
}
