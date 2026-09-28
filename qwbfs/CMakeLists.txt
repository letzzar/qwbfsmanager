set(APP_NAME "QWBFS Manager")
set(APP_ORGANIZATION "QWBFS Team")
set(APP_DOMAIN "github.com/letzzar/qwbfsmanager")
set(APP_COPYRIGHTS "© 2010 - 2016 Filipe Azevedo")
set(APP_DOWNLOADS_FEED "https://github.com/letzzar/qwbfsmanager/releases.atom")
set(APP_REPORT_BUG_URL "https://github.com/letzzar/qwbfsmanager/issues")
set(APP_DISCUSS_URL "http://groups.google.com/group/qwbfs-discuss")

find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --always --dirty
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE APP_GIT_REVISION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
endif()
string(TOLOWER "${CMAKE_BUILD_TYPE}" _build_type)
if(APP_GIT_REVISION)
    set(APP_VERSION_STR "${PROJECT_VERSION} (${APP_GIT_REVISION} ${_build_type})")
else()
    set(APP_VERSION_STR "${PROJECT_VERSION} (${_build_type})")
endif()

set(QWBFS_SOURCES
    src/main.cpp
    src/Utils.cpp
    src/UIMain.cpp
    src/Gauge.cpp
    src/PartitionWidget.cpp
    src/ProgressDialog.cpp
    src/WorkerThread.cpp
    src/qwbfsdriver/PartitionDiscHandle.cpp
    src/qwbfsdriver/PartitionHandle.cpp
    src/qwbfsdriver/PartitionProperties.cpp
    src/qwbfsdriver/PartitionStatus.cpp
    src/qwbfsdriver/Driver.cpp
    src/models/Disc.cpp
    src/models/DiscDelegate.cpp
    src/models/DiscModel.cpp
    src/models/pPartitionModel.cpp
    src/models/PartitionDelegate.cpp
    src/models/pPartition.cpp
    src/UIAbout.cpp
    src/wiitdb/Covers.cpp
    src/PropertiesDialog.cpp
    src/Properties.cpp
    src/ListView.cpp
    src/ofi-labs-pictureflow/pictureflow-qt/pictureflow.cpp
    src/CoverFlowView.cpp
    src/PartitionComboBox.cpp
    src/UIMain.ui
    src/PartitionWidget.ui
    src/ProgressDialog.ui
    src/UIAbout.ui
    src/PropertiesDialog.ui
    resources/resources.qrc
)

if(APPLE)
    list(APPEND QWBFS_SOURCES src/models/pPartitionModel_mac.mm resources/qwbfsmanager.icns)
    set_source_files_properties(resources/qwbfsmanager.icns PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
elseif(WIN32)
    list(APPEND QWBFS_SOURCES src/models/pPartitionModel_win.cpp resources/qwbfsmanager.rc)
else()
    list(APPEND QWBFS_SOURCES src/models/pPartitionModel_linux.cpp)
endif()

# Theme aware monochrome SVG icons (*.tsvg), see src/themedsvgicon
qt_add_plugin(themedsvgicon STATIC
    CLASS_NAME ThemedSvgIconPlugin
    PLUGIN_TYPE iconengines
    src/themedsvgicon/ThemedSvgIconEngine.cpp
    src/themedsvgicon/ThemedSvgIconPlugin.cpp
)
target_link_libraries(themedsvgicon PRIVATE Qt6::Gui Qt6::Svg)
set_target_properties(themedsvgicon PROPERTIES AUTOMOC_MOC_OPTIONS "-I${CMAKE_CURRENT_SOURCE_DIR}/src/themedsvgicon")

qt_add_executable(qwbfsmanager WIN32 MACOSX_BUNDLE ${QWBFS_SOURCES})

if(APPLE)
    set_target_properties(qwbfsmanager PROPERTIES OUTPUT_NAME "QWBFSManager")
endif()

set_target_properties(qwbfsmanager PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.github.letzzar.qwbfsmanager"
    MACOSX_BUNDLE_BUNDLE_NAME "QWBFS Manager"
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    MACOSX_BUNDLE_ICON_FILE "qwbfsmanager.icns"
    MACOSX_BUNDLE_COPYRIGHT "${APP_COPYRIGHTS}"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/resources/Info.plist.in"
)

target_include_directories(qwbfsmanager PRIVATE
    src
    src/models
    src/qwbfsdriver
    src/wiitdb
)

target_compile_definitions(qwbfsmanager PRIVATE
    "_APPLICATION_NAME=\"${APP_NAME}\""
    "_APPLICATION_VERSION=\"${PROJECT_VERSION}\""
    "_APPLICATION_VERSION_STR=\"${APP_VERSION_STR}\""
    "_APPLICATION_DOMAIN=\"${APP_DOMAIN}\""
    "_APPLICATION_COPYRIGHTS=\"${APP_COPYRIGHTS}\""
    "_APPLICATION_DESCRIPTION=\"${PROJECT_DESCRIPTION}\""
    "_APPLICATION_ORGANIZATION=\"${APP_ORGANIZATION}\""
    "_APPLICATION_DOWNLOADS_FEED=\"${APP_DOWNLOADS_FEED}\""
    "_APPLICATION_REPORT_BUG_URL=\"${APP_REPORT_BUG_URL}\""
    "_APPLICATION_DISCUSS_URL=\"${APP_DISCUSS_URL}\""
)

target_link_libraries(qwbfsmanager PRIVATE
    wbfs
    fresh
    themedsvgicon
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Network
    Qt6::Xml
)

if(APPLE)
    target_link_libraries(qwbfsmanager PRIVATE
        "-framework DiskArbitration"
        "-framework CoreFoundation"
    )
elseif(UNIX)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(UDEV REQUIRED IMPORTED_TARGET libudev)
    target_link_libraries(qwbfsmanager PRIVATE PkgConfig::UDEV)
endif()

# Translations (compiled from .ts with lrelease)
file(GLOB QWBFS_TS_FILES ${PROJECT_SOURCE_DIR}/translations/*.ts)
set_source_files_properties(${QWBFS_TS_FILES} ${FRESH_TS_FILES}
    PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/translations")
qt_add_lrelease(qwbfsmanager
    TS_FILES ${QWBFS_TS_FILES} ${FRESH_TS_FILES}
    QM_FILES_OUTPUT_VARIABLE QWBFS_QM_FILES
)

include(GNUInstallDirs)

if(APPLE)
    # Put the translations inside the bundle.
    add_custom_command(TARGET qwbfsmanager POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_BUNDLE_CONTENT_DIR:qwbfsmanager>/Resources/translations"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${QWBFS_QM_FILES} "$<TARGET_BUNDLE_CONTENT_DIR:qwbfsmanager>/Resources/translations/"
        COMMAND_EXPAND_LISTS
        VERBATIM
    )
    install(TARGETS qwbfsmanager BUNDLE DESTINATION .)
elseif(WIN32)
    install(TARGETS qwbfsmanager RUNTIME DESTINATION .)
    install(FILES ${QWBFS_QM_FILES} DESTINATION translations)
else()
    install(TARGETS qwbfsmanager RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(FILES ${QWBFS_QM_FILES} DESTINATION ${CMAKE_INSTALL_DATADIR}/qwbfsmanager/translations)
    install(FILES ${PROJECT_SOURCE_DIR}/packages/QWBFSManager.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
    install(FILES resources/qwbfsmanager.png DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps)
endif()
