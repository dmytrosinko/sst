project(testservice VERSION 1.0 LANGUAGES CXX)
set_source_files_properties(qml/Service.qml PROPERTIES QT_RESOURCE_ALIAS Service.qml)
set_source_files_properties(qml/Screen1.qml PROPERTIES QT_RESOURCE_ALIAS Screen1.qml)
set_source_files_properties(qml/Screen2.qml PROPERTIES QT_RESOURCE_ALIAS Screen2.qml)
set_source_files_properties(qml/Screen3.qml PROPERTIES QT_RESOURCE_ALIAS Screen3.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI service.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/Service.qml
        qml/Screen1.qml
        qml/Screen2.qml
        qml/Screen3.qml
    SOURCES
        ServiceModel.h
        ServiceModel.cpp
)
