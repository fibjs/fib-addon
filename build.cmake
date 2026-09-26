cmake_minimum_required(VERSION 3.10)

# Build driver for the addon repositories (fib-jieba and friends).
#
#   bash build x64 release -j8
#
# build_tools/scripts/build runs this file in script mode (cmake -P) whenever the
# repository has a build.cmake, which is the case for every addon repository.  It
# configures and builds the addon project in one pass, copies the resulting .node
# next to the repository (<repo>/addon/) and reports the runtime library
# requirements, like the historical implementation did.

include(${CMAKE_CURRENT_LIST_DIR}/build_tools/cmake/config.cmake)

get_filename_component(name ${CMAKE_CURRENT_SOURCE_DIR} NAME)

set(BUILD_WITH_MSVC "1")

set(WORK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
set(BUILD_DIR "${WORK_ROOT}/out/${DIST_DIRNAME}")

if("${BT_BIN_DIR}" STREQUAL "")
    set(BIN_DIR "${WORK_ROOT}/bin/${DIST_DIRNAME}")
else()
    set(BIN_DIR "${BT_BIN_DIR}")
endif()

if("${CLEAN_BUILD}" STREQUAL "true")
    file(REMOVE_RECURSE "${WORK_ROOT}/out" "${WORK_ROOT}/bin")
endif()

file(MAKE_DIRECTORY "${BUILD_DIR}")

execute_process(WORKING_DIRECTORY "${WORK_ROOT}"
    COMMAND ${CMAKE_COMMAND}
        -DBUILD_ARCH=${BUILD_ARCH}
        -DBUILD_TYPE=${BUILD_TYPE}
        -DBUILD_OS=${BUILD_OS}
        -DBUILD_JOBS=${BUILD_JOBS}
        -DBUILD_WITH_MSVC=${BUILD_WITH_MSVC}
        -DBT_BIN_DIR=${BIN_DIR}
        -S "${WORK_ROOT}"
        -B "${BUILD_DIR}"
    RESULT_VARIABLE STATUS)
if(NOT STATUS EQUAL 0)
    message(FATAL_ERROR "[addon] configure failed: ${STATUS}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build "${BUILD_DIR}" -- -j${BUILD_JOBS}
    RESULT_VARIABLE STATUS)
if(NOT STATUS EQUAL 0)
    message(FATAL_ERROR "[addon] build failed: ${STATUS}")
endif()

file(COPY "${BIN_DIR}/${name}.node" DESTINATION "${WORK_ROOT}/addon")

message("")
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
    message("==== GLIBC ====")
    execute_process(COMMAND objdump "${BIN_DIR}/${name}.node" -p COMMAND grep GLIBCX*_[0-9.]* -o COMMAND sort COMMAND uniq)
elseif(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
    execute_process(COMMAND otool -L "${BIN_DIR}/${name}.node")
endif()
message("")
