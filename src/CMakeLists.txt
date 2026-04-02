cmake_minimum_required(VERSION 3.16)
project(app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Quick LinguistTools)
qt_standard_project_setup(REQUIRES 6.10)

add_subdirectory(modules/hardware)
add_subdirectory(modules/controls)
add_subdirectory(services/testservice)

qt_add_executable(app
    main.cpp
)

qt_add_qml_module(app
    URI app
    SOURCES
        TranslationManager.h
        TranslationManager.cpp
    QML_FILES
        Main.qml
)

qt_add_translations(app
    TS_FILES
        translations/sst_en.ts
        translations/sst_kk.ts
    SOURCE_TARGETS app hardware controls testservice
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
set_target_properties(app PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(app
    PRIVATE Qt6::Quick Qt6::Gui hardwareplugin controlsplugin testserviceplugin
)

include(GNUInstallDirs)
install(TARGETS app
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
