# The build environment (BUILD_OS/BUILD_ARCH/BUILD_TYPE, DIST_DIRNAME and
# BT_BIN_DIR) has to be known before project() runs, so that a configure
# started by hand behaves exactly like one driven by fib-addon/build.cmake.
include(${CMAKE_CURRENT_LIST_DIR}/build_tools/cmake/config.cmake)

get_filename_component(name ${CMAKE_CURRENT_SOURCE_DIR} NAME)

project(${name})

include(${CMAKE_CURRENT_LIST_DIR}/build_tools/cmake/option.cmake)

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
