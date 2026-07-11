@echo off
setlocal enableextensions enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

if not exist "%SRC_COMPONENT%" (
  echo [ERRO] Pasta de origem nao encontrada: %SRC_COMPONENT%
  exit /b 1
)

echo [GRUPO] Copiando Component...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_COMPONENT%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_COMPONENT%/
if errorlevel 1 (
  echo [ERRO] Falha ao copiar Component.
  exit /b 1
)

exit /b 0
