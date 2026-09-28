cmake_minimum_required(VERSION 3.21)

project(QWBFSManager
    VERSION 1.3.0
    DESCRIPTION "The Free, Fast and Powerful cross platform Wii Backup File System manager"
    HOMEPAGE_URL "https://github.com/letzzar/qwbfsmanager"
    LANGUAGES C CXX
)

if(APPLE)
    enable_language(OBJCXX)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Widgets Network Xml LinguistTools)
qt_standard_project_setup()
set(CMAKE_AUTORCC ON)

add_subdirectory(libwbfs)
add_subdirectory(3rdparty/fresh)
add_subdirectory(qwbfs)
