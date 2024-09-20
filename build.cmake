cmake_minimum_required(VERSION 3.5)

get_filename_component(name ${CMAKE_CURRENT_SOURCE_DIR} NAME)

include(fib-addon/build_tools/cmake-scripts/get_env.cmake)

set(BUILD_WITH_MSVC "1")

set(WORK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
build("${CMAKE_CURRENT_SOURCE_DIR}" "${WORK_ROOT}" "${name}")

set(BIN_PATH "${WORK_ROOT}/bin/${DIST_DIRNAME}")

file(COPY ${BIN_PATH}/${name}.node DESTINATION ${WORK_ROOT}/addon)

message("")
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
    message("==== GLIBC ====")
    execute_process(COMMAND objdump ${BIN_PATH}/${name}.node -p COMMAND grep GLIBCX*_[0-9.]* -o COMMAND sort COMMAND uniq)
elseif(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
    execute_process(COMMAND otool -L ${BIN_PATH}/${name}.node)
endif()
message("")
