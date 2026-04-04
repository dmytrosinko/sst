import QtQuick
import QtQuick.Controls as QQC2
import service.testservice

Item {
    id: root

    signal quitService()

    // ── Screen components ──────────────────────────────────────────
    Component { id: screenPhoneComponent;  ScreenPhone  {} }
    Component { id: screenCardComponent;   ScreenCard   {} }
    Component { id: screenIbanComponent;   ScreenIban   {} }
    Component { id: screenNumberComponent; ScreenNumber {} }
    Component { id: screenStringComponent; ScreenString {} }
    Component { id: screen2Component;      Screen2      {} }
    Component { id: screen3Component;      Screen3      {} }

    // ── Map input type enum → screen component ─────────────────────
    function _componentForType(inputType) {
        switch (inputType) {
        case 0: return screenPhoneComponent     // Phone
        case 1: return screenIbanComponent      // IBAN
        case 2: return screenNumberComponent    // Account
        default: return screenStringComponent   // Default
        }
    }

    // ── StackView with push/pop animations ─────────────────────────
    QQC2.StackView {
        id: stackView
        anchors.fill: parent

        // ── Push transition: slide in from right ───────────────────
        pushEnter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "x"
                    from: stackView.width
                    to: 0
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: 120
                }
            }
        }
        pushExit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "x"
                    from: 0
                    to: -stackView.width * 0.3
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    from: 1; to: 0
                    duration: 120
                }
            }
        }

        // ── Pop transition: slide back from left ───────────────────
        popEnter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "x"
                    from: -stackView.width * 0.3
                    to: 0
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: 120
                }
            }
        }
        popExit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "x"
                    from: 0
                    to: stackView.width
                    duration: 150
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    from: 1; to: 0
                    duration: 120
                }
            }
        }
    }

    // ── Public: push the correct input screen ──────────────────────
    function showInputScreen() {
        stackView.clear()
        var component = _componentForType(ServiceModel.inputType)
        stackView.push(component, {
            "serviceName": ServiceModel.serviceName
        })
    }

    // ── Connect each pushed screen's signals ───────────────────────
    Connections {
        target: stackView.currentItem
        ignoreUnknownSignals: true

        function onQuitRequested() {
            if (stackView.depth > 1) {
                stackView.pop()
            } else {
                stackView.clear()
                root.quitService()
            }
        }

        function onNextRequested() {
            // Input screen (depth 1) → push Screen2 (confirmation)
            // Screen2 (depth 2)      → push Screen3 (result)
            if (stackView.depth === 1) {
                stackView.push(screen2Component, {
                    "serviceName": ServiceModel.serviceName
                })
            } else if (stackView.depth === 2) {
                stackView.push(screen3Component, {
                    "serviceName": ServiceModel.serviceName
                })
            }
        }

        // Screen3 DONE → clear everything and exit
        function onDoneRequested() {
            stackView.clear()
            root.quitService()
        }
    }
}
