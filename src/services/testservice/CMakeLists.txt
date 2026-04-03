project(testservice VERSION 1.0 LANGUAGES CXX)
set_source_files_properties(qml/Service.qml PROPERTIES QT_RESOURCE_ALIAS Service.qml)
set_source_files_properties(qml/ScreenPhone.qml PROPERTIES QT_RESOURCE_ALIAS ScreenPhone.qml)
set_source_files_properties(qml/ScreenCard.qml PROPERTIES QT_RESOURCE_ALIAS ScreenCard.qml)
set_source_files_properties(qml/ScreenIban.qml PROPERTIES QT_RESOURCE_ALIAS ScreenIban.qml)
set_source_files_properties(qml/ScreenNumber.qml PROPERTIES QT_RESOURCE_ALIAS ScreenNumber.qml)
set_source_files_properties(qml/ScreenString.qml PROPERTIES QT_RESOURCE_ALIAS ScreenString.qml)
set_source_files_properties(qml/Screen2.qml PROPERTIES QT_RESOURCE_ALIAS Screen2.qml)
set_source_files_properties(qml/Screen3.qml PROPERTIES QT_RESOURCE_ALIAS Screen3.qml)
set_source_files_properties(qml/NumericInputScreen.qml PROPERTIES QT_RESOURCE_ALIAS NumericInputScreen.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI service.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/Service.qml
        qml/ScreenPhone.qml
        qml/ScreenCard.qml
        qml/ScreenIban.qml
        qml/ScreenNumber.qml
        qml/ScreenString.qml
        qml/Screen2.qml
        qml/Screen3.qml
        qml/NumericInputScreen.qml
    SOURCES
        ServiceModel.h
        ServiceModel.cpp
)
