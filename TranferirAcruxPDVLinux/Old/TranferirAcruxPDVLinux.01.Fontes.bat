@echo off
setlocal enableextensions enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

if not exist "%SRC_FONTES%" (
  echo [ERRO] Pasta de origem nao encontrada: %SRC_FONTES%
  exit /b 1
)

echo [GRUPO] Copiando Fontes...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_FONTES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_FONTES%/
if errorlevel 1 (
  echo [ERRO] Falha ao copiar Fontes.
  exit /b 1
)

exit /b 0
