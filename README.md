# fib-addon

The shared build platform of the addon repositories (`fib-jieba` and friends):
it carries the addon runtime code, the N-API headers and the entry script that
drives the build.

An addon repository is a single CMake project: its root `CMakeLists.txt` takes
the build environment from `build_tools` (`cmake/config.cmake`), calls
`project()` - the call that detects the compiler - and then includes
`common.cmake` of this repository, which states the addon target and its
packaging steps.

```cmake
cmake_minimum_required(VERSION 3.10)

include(fib-addon/build_tools/cmake/config.cmake)

get_filename_component(name ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${name})

file(GLOB_RECURSE src_list "${PROJECT_SOURCE_DIR}/<sources>/*.c*")

include(fib-addon/common.cmake)
```

The repository builds through its own entry script, which sources
`scripts/build` of this repository:

```bash
bash build x64 release -j8
```

| path | contents |
| --- | --- |
| `common.cmake` | the addon target: sources, includes, link flags, artifact |
| `scripts/build`, `scripts/build.cmd` | the entry script of the repositories |
| `cmake/glibc_report.cmake` | the runtime requirements report of the artifact |
| `include/`, `src/` | the addon runtime code and headers, compiled into every addon |
| `lib/` | the import libraries of node (Windows) |
| `node-addon-api/` | the N-API headers |
| `build_tools/` | the shared build infrastructure (submodule) |
