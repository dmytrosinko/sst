# QML Unit Tests Aggregator

# Controls QML Tests
qt_add_executable(qml_tst_controls 
    qml_test_runner_controls.cpp
    modules/controls/tst_Button.qml
    modules/controls/tst_TextArea.qml
    modules/controls/tst_TextField.qml
)
target_link_libraries(qml_tst_controls PRIVATE Qt6::QuickTest Qt6::Qml controls)
target_compile_definitions(qml_tst_controls PRIVATE 
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/modules/controls"
    QML_MODULE_DIR="${CMAKE_BINARY_DIR}/src")
add_test(NAME qml_tst_controls COMMAND qml_tst_controls)

# Hardware QML Tests
qt_add_executable(qml_tst_hardware 
    qml_test_runner_hardware.cpp
    modules/hardware/tst_HardwareInfo.qml
)
target_link_libraries(qml_tst_hardware PRIVATE Qt6::QuickTest Qt6::Qml hardware)
target_compile_definitions(qml_tst_hardware PRIVATE 
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/modules/hardware"
    QML_MODULE_DIR="${CMAKE_BINARY_DIR}/src")
add_test(NAME qml_tst_hardware COMMAND qml_tst_hardware)

# TestService QML Tests
qt_add_executable(qml_tst_testservice 
    qml_test_runner_testservice.cpp
    services/testservice/tst_Screen1.qml
    services/testservice/tst_Screen2.qml
    services/testservice/tst_Screen3.qml
    services/testservice/tst_Service.qml
)
target_link_libraries(qml_tst_testservice PRIVATE Qt6::QuickTest Qt6::Qml testservice)
target_compile_definitions(qml_tst_testservice PRIVATE 
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/services/testservice"
    QML_MODULE_DIR="${CMAKE_BINARY_DIR}/src")
add_test(NAME qml_tst_testservice COMMAND qml_tst_testservice)

# App Root QML Tests
qt_add_executable(qml_tst_app 
    qml_test_runner_app.cpp
    tst_Main.qml
)
target_link_libraries(qml_tst_app PRIVATE Qt6::QuickTest Qt6::Qml hardware testservice controls)
target_compile_definitions(qml_tst_app PRIVATE 
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    QML_MODULE_DIR="${CMAKE_BINARY_DIR}/src")
add_test(NAME qml_tst_app COMMAND qml_tst_app)
