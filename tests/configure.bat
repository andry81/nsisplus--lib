@echo off

(
  echo.@echo off
  echo.
  echo.set PROJECT_ROOT=%~dp0..
  echo.set TEST_LIB_ROOT=%~dp0_testlib
  echo.set BUILD_DIR_NAME=Debug
  echo.set MAKENSIS_EXE=%%PROJECT_ROOT%%\nsis\v3\Bin\makensis.exe
  echo.set _NSIS_SETUP_LIB_ROOT=%~dp0..
  echo.set "PATH=%%PATH%%;%%_NSIS_SETUP_LIB_ROOT%%\tools"
) > "%~dp0configure.user.bat"
