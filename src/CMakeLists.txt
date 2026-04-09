project(sst-app VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Gui Quick QuickDialogs2 LinguistTools)

add_subdirectory(modules/hardware)
add_subdirectory(modules/controls)
add_subdirectory(modules/style)
add_subdirectory(modules/ui)
add_subdirectory(modules/services)
add_subdirectory(services/testservice)

qt_add_executable(${PROJECT_NAME}
    main.cpp
)

qt_add_qml_module(${PROJECT_NAME}
    URI app
    SOURCES
        TranslationManager.h
        TranslationManager.cpp
        FileWriter.h
        FileWriter.cpp
    QML_FILES
        Main.qml
    RESOURCES
        assets/logo.svg
        assets/icon_category.svg
        assets/icon_service.svg
        assets/icons/0.svg
        assets/icons/1.svg
        assets/icons/2.svg
        assets/icons/3.svg
        assets/icons/4.svg
        assets/icons/5.svg
        assets/icons/6.svg
        assets/icons/7.svg
        assets/icons/8.svg
        assets/icons/9.svg
        assets/icons/default.svg
        assets/icons/back_arrow.svg
        assets/icons/icon_card.svg
        assets/icons/icon_phone.svg
        assets/icons/icon_iban.svg
        assets/icons/icon_number.svg
        assets/icons/icon_string.svg
        assets/fonts/EuclidCircularB-Regular.ttf
        assets/fonts/EuclidCircularB-Medium.ttf
        assets/fonts/EuclidCircularB-SemiBold.ttf
        assets/fonts/EuclidCircularB-Bold.ttf
        assets/services.json
)

qt_add_translations(${PROJECT_NAME}
    TS_FILES
        translations/sst_en.ts
        translations/sst_ky.ts
        translations/sst_ru.ts
    SOURCE_TARGETS ${PROJECT_NAME} hardware controls style ui services testservice
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt6::Quick Qt6::Gui Qt6::QuickDialogs2 hardwareplugin controlsplugin styleplugin uiplugin servicesplugin testserviceplugin
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Deployment on cmake install for Windows and Linux
qt_generate_deploy_qml_app_script(
    TARGET ${PROJECT_NAME}
    OUTPUT_SCRIPT deploy_script
        MACOS_BUNDLE_POST_BUILD
        NO_UNSUPPORTED_PLATFORM_ERROR
        DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    NO_TRANSLATIONS
)
install(SCRIPT ${deploy_script})
