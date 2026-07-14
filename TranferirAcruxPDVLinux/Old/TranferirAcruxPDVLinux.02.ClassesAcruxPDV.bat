@echo off
setlocal enableextensions enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

if not exist "%SRC_CLASSES%" (
  echo [ERRO] Pasta de origem nao encontrada: %SRC_CLASSES%
  exit /b 1
)

echo [GRUPO] Copiando Classes AcruxPDV...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_CLASSES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_CLASSES%/
if errorlevel 1 (
  echo [ERRO] Falha ao copiar Classes AcruxPDV.
  exit /b 1
)

exit /b 0
