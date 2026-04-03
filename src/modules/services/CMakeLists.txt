project(services VERSION 1.0 LANGUAGES CXX)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    SOURCES
        ServiceTreeItem.h
        ServiceTreeItem.cpp
        ServiceTreeModel.h
        ServiceTreeModel.cpp
)
