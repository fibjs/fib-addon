@echo off

REM Entry script of the addon platform (Windows): the addon repositories call it
REM from their own build.cmd, which is started in the repository root.
REM
REM   build.cmd x64 release -j8

REM The addons link the import libraries of node on Windows (fib-addon/lib), and
REM those are the MSVC ones, so the Windows builds use MSVC rather than the
REM clang-cl default of the driver.
set BUILD_WITH_MSVC=1

REM The repository root: the outputs belong to it (out\<dist>, bin\<dist>).
set WORK_ROOT=%cd%

call "%~dp0..\build_tools\scripts\build.cmd" %*
