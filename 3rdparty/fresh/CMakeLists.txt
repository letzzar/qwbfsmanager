# Minimal subset of the Fresh library (https://github.com/pasnox/fresh, LGPL v3)
# used by QWBFS Manager, ported to Qt 6.

set(FRESH_SOURCES
    src/core/pCoreUtils.cpp
    src/core/pNetworkAccessManager.cpp
    src/core/pSettings.cpp
    src/core/pTranslationManager.cpp
    src/core/pVersion.cpp
    src/gui/pGuiUtils.cpp
    src/gui/pIconManager.cpp
    src/gui/pPaypalButton.cpp
    src/gui/pToolButton.cpp
    src/gui/pTranslationDialog.cpp
    src/gui/pTranslationDialog.ui
    src/gui/listeditor/pStringListEditor.cpp
    src/gui/listeditor/pFileListEditor.cpp
    src/gui/listeditor/pPathListEditor.cpp
    src/gui/queuedmessage/pQueuedMessageToolBar.cpp
    src/gui/queuedmessage/pQueuedMessageWidget.cpp
    src/gui/dockwidget/pDockWidget.cpp
    src/gui/dockwidget/pDockWidgetTitleBar.cpp
    src/gui/gc-updatechecker/pUpdateChecker.cpp
    src/gui/gc-updatechecker/pUpdateCheckerDialog.cpp
    src/gui/gc-updatechecker/pUpdateCheckerDialog.ui
    resources/fresh.qrc
)

if(APPLE)
    list(APPEND FRESH_SOURCES src/core/pMacHelpers.mm)
endif()

add_library(fresh STATIC ${FRESH_SOURCES})

target_compile_definitions(fresh
    PUBLIC
        FRESH_STATIC
    PRIVATE
        QT_NO_CAST_TO_ASCII
        QT_NO_CAST_FROM_ASCII
        QT_NO_CAST_FROM_BYTEARRAY
        QT_NO_URL_CAST_FROM_STRING
        QL1S=QLatin1String
        QL1C=QLatin1Char
        QSL=QStringLiteral
        QBAL=QByteArrayLiteral
)

target_include_directories(fresh
    PUBLIC
        include
        src/core
        src/gui
        src/gui/listeditor
        src/gui/queuedmessage
        src/gui/dockwidget
        src/gui/gc-updatechecker
)

target_link_libraries(fresh PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Network
    Qt6::Xml
)

if(APPLE)
    target_link_libraries(fresh PUBLIC "-framework CoreFoundation")
endif()

file(GLOB FRESH_TS_FILES ${CMAKE_CURRENT_SOURCE_DIR}/translations/*.ts)
set(FRESH_TS_FILES ${FRESH_TS_FILES} PARENT_SCOPE)
