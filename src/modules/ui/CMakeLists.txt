project(ui VERSION 1.0 LANGUAGES CXX)

set_source_files_properties(qml/Home.qml PROPERTIES QT_RESOURCE_ALIAS Home.qml)
set_source_files_properties(qml/Header.qml PROPERTIES QT_RESOURCE_ALIAS Header.qml)
set_source_files_properties(qml/Footer.qml PROPERTIES QT_RESOURCE_ALIAS Footer.qml)

set_source_files_properties(qml/MainBackground.qml PROPERTIES QT_RESOURCE_ALIAS MainBackground.qml)
set_source_files_properties(qml/PanelBackground.qml PROPERTIES QT_RESOURCE_ALIAS PanelBackground.qml)
set_source_files_properties(qml/ServiceTileView.qml PROPERTIES QT_RESOURCE_ALIAS ServiceTileView.qml)
set_source_files_properties(qml/GradientSelectionWindow.qml PROPERTIES QT_RESOURCE_ALIAS GradientSelectionWindow.qml)
qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/Home.qml
        qml/Header.qml
        qml/Footer.qml

        qml/MainBackground.qml
        qml/PanelBackground.qml
        qml/ServiceTileView.qml
        qml/GradientSelectionWindow.qml
)
