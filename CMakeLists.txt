cmake_minimum_required(VERSION 3.22)

project(sst VERSION 0.0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(VENDOR "Simbank")
set(BUNDLE "SST")
set(APP_VERSION ${PROJECT_VERSION})
set(CMAKE_INSTALL_BINDIR .)
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/output/${BUNDLE}-${PROJECT_VERSION})
set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME ${BUNDLE})

option(WITH_TESTS "Build unit tests" OFF)
option(USE_DEVICE_EMULATOR "Use device emulators instead of real hardware drivers" ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Test QuickTest)
qt_standard_project_setup(REQUIRES 6.10)

string(TIMESTAMP DAY "%d")
math (EXPR DAY ${DAY})
string(TIMESTAMP MONTH "%m")
string(TIMESTAMP YEAR "%Y")

add_compile_definitions(BUILD_DAY="${DAY}"
                        BUILD_MONTH="${MONTH}"
                        BUILD_YEAR="${YEAR}"
                        APP_VERSION_STRING="${APP_VERSION}"
                        COMPANY_NAME=${VENDOR}
                        APP_NAME=${PROJECT_NAME}
                        API_STACK="dev")  #dev,live,prd,stg


add_subdirectory(src)
if(WITH_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()


# Packaging (optional)
set(CPACK_PACKAGE_NAME ${BUNDLE})
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/output)
set(CPACK_PACKAGE_FILE_NAME "SST_${PROJECT_VERSION}")
set(CPACK_ARCHIVE_THREADS 0)
set(CPACK_GENERATOR TGZ)
message("Including CPack...")
include(CPack)
