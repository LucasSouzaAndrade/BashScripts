@echo off
setlocal enableextensions enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

if not exist "%SRC_GLOBAL_CLASSES%" (
  echo [ERRO] Pasta de origem nao encontrada: %SRC_GLOBAL_CLASSES%
  exit /b 1
)

echo [GRUPO] Copiando Classes Global...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_GLOBAL_CLASSES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_GLOBAL_CLASSES%/
if errorlevel 1 (
  echo [ERRO] Falha ao copiar Classes Global.
  exit /b 1
)

exit /b 0
