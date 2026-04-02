project(hardware VERSION 1.0 LANGUAGES CXX)
cmake_minimum_required(VERSION 3.16)

find_package(Qt6 REQUIRED COMPONENTS Concurrent)

set_source_files_properties(qml/HardwareInfo.qml PROPERTIES QT_RESOURCE_ALIAS HardwareInfo.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/HardwareInfo.qml
    SOURCES
        SystemInfo.h
        SystemInfo.cpp
)

target_link_libraries(hardware PRIVATE Qt6::Concurrent)

# If necessary, link to OS specific libraries
if(WIN32)
    target_link_libraries(hardware PRIVATE pdh) # pdh might be useful for CPU stats
endif()
