# Prints the runtime library requirements of an artifact, the way the historical
# build driver of the addons reported them:
#
#   cmake -DNODE_FILE=<artifact> -P cmake/glibc_report.cmake
#
# It is a POST_BUILD step of the addon targets (fib-addon/common.cmake): the
# artifact only exists once the target has been built.

if("${NODE_FILE}" STREQUAL "")
    message(FATAL_ERROR "NODE_FILE is not set")
endif()

message("")
message("==== GLIBC ====")
execute_process(
    COMMAND objdump "${NODE_FILE}" -p
    COMMAND grep -o "GLIBCX*_[0-9.]*"
    COMMAND sort -V
    COMMAND uniq)
message("")
