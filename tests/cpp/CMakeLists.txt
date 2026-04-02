# C++ Unit Tests Aggregator

# App Root Tests
qt_add_executable(cpp_tst_translationmanager 
    tst_TranslationManager.cpp
    ../../src/TranslationManager.cpp
)
target_link_libraries(cpp_tst_translationmanager PRIVATE Qt6::Test Qt6::Gui Qt6::Qml)
add_test(NAME cpp_tst_translationmanager COMMAND cpp_tst_translationmanager)

# Hardware Module Tests
qt_add_executable(cpp_tst_hardware
    modules/hardware/tst_systeminfo.cpp
)
target_link_libraries(cpp_tst_hardware PRIVATE Qt6::Test hardware)
add_test(NAME cpp_tst_hardware COMMAND cpp_tst_hardware)

# TestService Module Tests
qt_add_executable(cpp_tst_testservice
    services/testservice/tst_ServiceModel.cpp
)
target_link_libraries(cpp_tst_testservice PRIVATE Qt6::Test testservice)
add_test(NAME cpp_tst_testservice COMMAND cpp_tst_testservice)
