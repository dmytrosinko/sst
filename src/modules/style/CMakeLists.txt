project(style VERSION 1.0 LANGUAGES CXX)

set_source_files_properties(qml/Style.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS Style.qml
)
set_source_files_properties(qml/DarkStyle.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS DarkStyle.qml
)
set_source_files_properties(qml/SimbankPallete.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS SimbankPallete.qml
)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/Style.qml
        qml/DarkStyle.qml
        qml/SimbankPallete.qml
        QML_FILES qml/DarkStyle_copy.qml
)
