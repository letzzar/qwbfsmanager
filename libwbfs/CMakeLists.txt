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
    # WIN32_LEAN_AND_MEAN: keep windows.h from pulling the legacy winsock.h (conflicts with winsock2.h)
    target_compile_definitions(wbfs PUBLIC WIN32 WIN32_LEAN_AND_MEAN)
    target_compile_definitions(wbfs PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_link_libraries(wbfs PUBLIC ws2_32)
endif()
