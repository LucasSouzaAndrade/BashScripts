@echo off
setlocal enableextensions enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

if not exist "%SRC_ROOT%" (
  echo [ERRO] Pasta base de origem nao encontrada: %SRC_ROOT%
  exit /b 1
)

echo [GRUPO] Copiando arquivos da raiz (sem subpastas)...
set "HAS_FILE=0"
for /f "delims=" %%F in ('dir /b /a-d "%SRC_ROOT%"') do (
  set "HAS_FILE=1"
  echo    - "%%F"
  pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp "%SRC_ROOT%\%%F" %LINUX_USER%@%LINUX_HOST%:%REMOTE_ARQUIVOS%/
  if errorlevel 1 (
    echo [ERRO] Falha ao copiar arquivo: "%%F"
    exit /b 1
  )
)

if "!HAS_FILE!"=="0" (
  echo [AVISO] Nenhum arquivo de raiz encontrado para copiar em %SRC_ROOT%.
)

exit /b 0
