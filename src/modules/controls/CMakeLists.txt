project(controls VERSION 1.0 LANGUAGES CXX)
set_source_files_properties(qml/Button.qml PROPERTIES QT_RESOURCE_ALIAS Button.qml)
set_source_files_properties(qml/TextField.qml PROPERTIES QT_RESOURCE_ALIAS TextField.qml)
set_source_files_properties(qml/TextArea.qml PROPERTIES QT_RESOURCE_ALIAS TextArea.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/Button.qml
        qml/TextField.qml
        qml/TextArea.qml
)
