project(testservice VERSION 1.0 LANGUAGES CXX)
set_source_files_properties(qml/Service.qml PROPERTIES QT_RESOURCE_ALIAS Service.qml)
set_source_files_properties(qml/ScreenInputPhone.qml PROPERTIES QT_RESOURCE_ALIAS ScreenInputPhone.qml)
set_source_files_properties(qml/ScreenInputCardNumber.qml PROPERTIES QT_RESOURCE_ALIAS ScreenInputCardNumber.qml)
set_source_files_properties(qml/ScreenInputIban.qml PROPERTIES QT_RESOURCE_ALIAS ScreenInputIban.qml)
set_source_files_properties(qml/ScreenInputNumber.qml PROPERTIES QT_RESOURCE_ALIAS ScreenInputNumber.qml)
set_source_files_properties(qml/ScreenInputString.qml PROPERTIES QT_RESOURCE_ALIAS ScreenInputString.qml)
set_source_files_properties(qml/ScreenInsertCash.qml PROPERTIES QT_RESOURCE_ALIAS ScreenInsertCash.qml)
set_source_files_properties(qml/Screen3.qml PROPERTIES QT_RESOURCE_ALIAS Screen3.qml)
set_source_files_properties(qml/NumericInputScreen.qml PROPERTIES QT_RESOURCE_ALIAS NumericInputScreen.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI service.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../service/${PROJECT_NAME}
    QML_FILES
        qml/Service.qml
        qml/ScreenInputPhone.qml
        qml/ScreenInputCardNumber.qml
        qml/ScreenInputIban.qml
        qml/ScreenInputNumber.qml
        qml/ScreenInputString.qml
        qml/ScreenInsertCash.qml
        qml/Screen3.qml
        qml/NumericInputScreen.qml
    SOURCES
        ServiceModel.h
        ServiceModel.cpp
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/src/modules/services
)
