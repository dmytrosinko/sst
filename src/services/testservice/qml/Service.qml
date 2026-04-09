import QtQuick
import QtQuick.Controls as QQC2
import service.testservice
import modules.finance

Item {
    id: root

    signal quitService

    // ── Screen components ──────────────────────────────────────────
    Component {
        id: screenPhoneComponent
        ScreenInputPhone {}
    }
    Component {
        id: screenCardComponent
        ScreenInputCardNumber {}
    }
    Component {
        id: screenIbanComponent
        ScreenInputIban {}
    }
    Component {
        id: screenNumberComponent
        ScreenInputNumber {}
    }
    Component {
        id: screenStringComponent
        ScreenInputString {}
    }
    Component {
        id: cashScreenComponent
        ScreenInsertCash {}
    }
    Component {
        id: screen3Component
        Screen3 {}
    }

    // ── Map input type string → screen component ───────────────────
    function _componentForInputType(inputType) {
        switch (inputType) {
        case "phone":
            return screenPhoneComponent;
        case "iban":
            return screenIbanComponent;
        case "account":
        case "number":
            return screenNumberComponent;
        case "card":
            return screenCardComponent;
        default:
            return screenStringComponent;
        }
    }

    // Legacy: map numeric enum → screen component (fallback)
    function _componentForType(inputType) {
        switch (inputType) {
        case 0:
            return screenPhoneComponent;     // Phone
        case 1:
            return screenIbanComponent;      // IBAN
        case 2:
            return screenNumberComponent;    // Account
        default:
            return screenStringComponent;   // Default
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
                    from: 0
                    to: 1
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
                    from: 1
                    to: 0
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
                    from: 0
                    to: 1
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
                    from: 1
                    to: 0
                    duration: 120
                }
            }
        }
    }

    // ── Track which field we're currently on (for multi-field services) ──
    property int _currentFieldIndex: 0
    property var _fields: []

    // ── Public: push the correct input screen ──────────────────────
    function showInputScreen() {
        stackView.clear();

        // Start a new transaction session
        TransactionController.startSession(ServiceModel.serviceId, ServiceModel.serviceName);

        _fields = ServiceModel.fields || [];
        _currentFieldIndex = 0;

        if (_fields.length > 0) {
            // Push the first field's input screen
            _pushFieldScreen(0);
        } else {
            // No fields defined — fallback to legacy input type
            var component = _componentForType(ServiceModel.inputType);
            stackView.push(component, {
                "serviceName": ServiceModel.serviceName
            });
        }
    }

    // Push an input screen for a specific field index
    function _pushFieldScreen(fieldIndex) {
        if (fieldIndex >= _fields.length) return;
        var field = _fields[fieldIndex];
        var component = _componentForInputType(field.inputType || "string");
        stackView.push(component, {
            "serviceName": ServiceModel.serviceName
        });
        _currentFieldIndex = fieldIndex;
    }

    // ── Connect each pushed screen's signals ───────────────────────
    Connections {
        target: stackView.currentItem
        ignoreUnknownSignals: true

        function onQuitRequested() {
            if (stackView.depth > 1) {
                stackView.pop();
                if (_currentFieldIndex > 0) {
                    _currentFieldIndex--;
                }
            } else {
                stackView.clear();
                TransactionController.cancelSession();
                root.quitService();
            }
        }

        function onNextRequested() {
            // Save current field's input value to the transaction
            _saveCurrentFieldParam();

            if (_currentFieldIndex < _fields.length - 1) {
                // More fields to fill — push next field screen
                _pushFieldScreen(_currentFieldIndex + 1);
            } else if (stackView.depth <= _fields.length || _fields.length === 0) {
                // All fields done (or no fields) — push CashScreen
                if (stackView.depth === 1 && _fields.length === 0) {
                    // Legacy: no fields, first screen done → cash
                    stackView.push(cashScreenComponent, {
                        "serviceName": ServiceModel.serviceName
                    });
                } else {
                    // Fields done → cash screen
                    stackView.push(cashScreenComponent, {
                        "serviceName": ServiceModel.serviceName
                    });
                }
            } else {
                // Cash screen done → result screen
                stackView.push(screen3Component, {
                    "serviceName": ServiceModel.serviceName
                });
            }
        }

        // Screen3 DONE → clear everything and exit
        function onDoneRequested() {
            TransactionController.cancelSession();
            stackView.clear();
            root.quitService();
        }
    }

    // ── Save the current input screen's value to the transaction ────
    function _saveCurrentFieldParam() {
        if (_fields.length === 0 || _currentFieldIndex >= _fields.length)
            return;

        var field = _fields[_currentFieldIndex];
        var item = stackView.currentItem;
        if (!item) return;

        // Try to get the input value from the current screen
        // Input controls expose their value through different properties
        var value = "";
        if (item.inputControl && item.inputControl.text !== undefined) {
            // NumericInputScreen pattern: has inputControl property
            value = item.inputControl.text.replace(/\s/g, "");
        } else if (item.children) {
            // Try to find an input field in the screen
            for (var i = 0; i < item.children.length; i++) {
                var child = item.children[i];
                if (child.text !== undefined && child.objectName === "inputField") {
                    value = child.text.replace(/\s/g, "");
                    break;
                }
            }
        }

        if (value.length > 0) {
            TransactionController.setParam(field.key, value);
            console.log("Saved param:", field.key, "=", value);
        }
    }
}
