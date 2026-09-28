add_library(wbfs STATIC
    tools.c
    ec.c
    bn.c
    rijndael.c
    wiidisc.c
    libwbfs.c
    libwbfs_unix.c
    libwbfs_win32.c
)

target_include_directories(wbfs PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(wbfs PUBLIC LARGE_FILES _FILE_OFFSET_BITS=64)

if(WIN32)
    # libwbfs uses the ANSI Win32 API and tests the WIN32 macro (not defined by MinGW)
    target_compile_definitions(wbfs PUBLIC WIN32)
    target_compile_definitions(wbfs PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_link_libraries(wbfs PUBLIC ws2_32)
endif()
