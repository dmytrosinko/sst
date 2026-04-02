cmake_minimum_required(VERSION 3.22)

project(sst VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Test QuickTest)
qt_standard_project_setup(REQUIRES 6.10)



enable_testing()
add_subdirectory(src)
#add_subdirectory(testservice)


# Packaging (optional)
set(CPACK_PACKAGE_NAME "SST")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/output)
set(CPACK_PACKAGE_FILE_NAME "SST_${PROJECT_VERSION}")
set(CPACK_ARCHIVE_THREADS 0)
set(CPACK_GENERATOR TGZ)
include(CPack)
