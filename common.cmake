# The addon target of an addon repository: the root CMakeLists.txt of the
# repository includes cmake/config.cmake, calls project() and then this file, so
# the repository is a single CMake project that the driver of the entry script
# (fib-addon/scripts/build) configures and builds in one pass.
#
# The include below keeps the contract explicit: the build environment
# (BUILD_OS/BUILD_ARCH/BUILD_TYPE, DIST_DIRNAME and BT_BIN_DIR) has to be known
# before project() runs, and config.cmake reports a top-level project that
# called project() first.
include(${CMAKE_CURRENT_LIST_DIR}/build_tools/cmake/config.cmake)

get_filename_component(name ${CMAKE_CURRENT_SOURCE_DIR} NAME)

include(${CMAKE_CURRENT_LIST_DIR}/build_tools/cmake/option.cmake)

# node-addon-api is a C++17 library: napi.h includes <string_view> and uses
# std::string_view unconditionally (MSVC compiles as C++14 by default, where
# <string_view> exists but std::string_view does not).  A repository that states
# an older standard is lifted here; an unset one keeps the default of
# build_tools (C++20).
if(NOT "${CMAKE_CXX_STANDARD}" STREQUAL "" AND CMAKE_CXX_STANDARD LESS 17)
    set(CMAKE_CXX_STANDARD 17)
endif()

file(GLOB_RECURSE addons_list "fib-addon/src/*.c*")
add_library(${name} SHARED ${src_list} ${addons_list})

include_directories(
    "${PROJECT_SOURCE_DIR}/include"
    "${PROJECT_SOURCE_DIR}/fib-addon/include"
    "${PROJECT_SOURCE_DIR}/fib-addon/node-addon-api"
    "${CMAKE_CURRENT_BINARY_DIR}")

if(MSVC)
    target_link_libraries(${name} "${PROJECT_SOURCE_DIR}/fib-addon/lib/node_${BUILD_ARCH}.lib")
    set(link_flags "${link_flags} /DELAYLOAD:node.exe")
else()
    set(link_flags "${link_flags} -Wl,-undefined,dynamic_lookup")
endif()

setup_result_library(${name})

set_target_properties(${name} PROPERTIES PREFIX "")
set_target_properties(${name} PROPERTIES SUFFIX ".node")

# The package entry point loads the addon from <repo>/addon/<name>.node and the
# release job packs that file, so the artifact is copied next to the sources
# after every build; the runtime requirements of the artifact are reported the
# way the historical build driver did.
add_custom_command(TARGET ${name} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_SOURCE_DIR}/addon"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:${name}>" "${PROJECT_SOURCE_DIR}/addon/")

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    add_custom_command(TARGET ${name} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -DNODE_FILE=$<TARGET_FILE:${name}>
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/glibc_report.cmake")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    add_custom_command(TARGET ${name} POST_BUILD
        COMMAND otool -L "$<TARGET_FILE:${name}>")
endif()
