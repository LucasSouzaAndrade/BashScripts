@echo off
setlocal enableextensions enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

if not exist "%SRC_RESOURCES%" (
  echo [ERRO] Pasta de origem nao encontrada: %SRC_RESOURCES%
  exit /b 1
)

echo [GRUPO] Copiando Resources...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_RESOURCES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_RESOURCES%/
if errorlevel 1 (
  echo [ERRO] Falha ao copiar Resources.
  exit /b 1
)

exit /b 0
