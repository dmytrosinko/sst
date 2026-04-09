project(hardware VERSION 1.0 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Concurrent)

option(USE_DEVICE_EMULATOR "Use device emulators instead of real hardware drivers" ON)

# SerialPort is only needed when building with real hardware drivers
if(NOT USE_DEVICE_EMULATOR)
    find_package(Qt6 REQUIRED COMPONENTS SerialPort)
endif()

set_source_files_properties(qml/HardwareInfo.qml PROPERTIES QT_RESOURCE_ALIAS HardwareInfo.qml)

# Common sources (always compiled)
set(HARDWARE_SOURCES
    SystemInfo.h
    SystemInfo.cpp
    ValidatorTypes.h
    ValidatorInterface.h
    ValidatorInterface.cpp
    ValidatorController.h
    ValidatorController.cpp
)

# Backend-specific sources
if(USE_DEVICE_EMULATOR)
    list(APPEND HARDWARE_SOURCES
        ValidatorEmulator.h
        ValidatorEmulator.cpp
    )
else()
    list(APPEND HARDWARE_SOURCES
        ValidatorDriver.h
        ValidatorDriver.cpp
        PortScanner.h
        PortScanner.cpp
    )
endif()

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/HardwareInfo.qml
    SOURCES
        ${HARDWARE_SOURCES}
)

target_link_libraries(hardware PRIVATE Qt6::Concurrent)

if(USE_DEVICE_EMULATOR)
    target_compile_definitions(hardware PUBLIC USE_DEVICE_EMULATOR)
else()
    target_link_libraries(hardware PRIVATE Qt6::SerialPort)
endif()

# If necessary, link to OS specific libraries
if(WIN32)
    target_link_libraries(hardware PRIVATE pdh) # pdh might be useful for CPU stats
endif()
