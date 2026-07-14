@echo off
setlocal enableextensions enabledelayedexpansion

if /i "%~1"==":EnsureTools" goto EnsureTools
if /i "%~1"==":EnsureHostKey" goto EnsureHostKey
if /i "%~1"==":TestHostKey" goto TestHostKey
if /i "%~1"==":RefreshHostKey" goto RefreshHostKey

exit /b 0

:EnsureTools
where pscp >nul 2>nul
if errorlevel 1 (
  echo [ERRO] pscp nao encontrado. Instale o PuTTY ou adicione ao PATH.
  exit /b 1
)

where plink >nul 2>nul
if errorlevel 1 (
  echo [ERRO] plink nao encontrado. Instale o PuTTY ou adicione ao PATH.
  exit /b 1
)
exit /b 0

:EnsureHostKey
echo [INFO] Validando HOSTKEY atual...
call "%~f0" :TestHostKey
if errorlevel 1 (
  echo [AVISO] HOSTKEY atual falhou. Tentando gerar automaticamente...
  call "%~f0" :RefreshHostKey
  if errorlevel 1 (
    echo [ERRO] Nao foi possivel gerar HOSTKEY automaticamente.
    exit /b 1
  )

  echo [INFO] HOSTKEY atualizado em memoria: %HOSTKEY%
  call "%~f0" :TestHostKey
  if errorlevel 1 (
    echo [ERRO] HOSTKEY gerado, mas a conexao ainda falhou.
    echo        Verifique usuario/senha e conectividade de rede.
    exit /b 1
  )
)
exit /b 0

:TestHostKey
plink -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" %LINUX_USER%@%LINUX_HOST% "echo ok" >nul 2>nul
exit /b %errorlevel%

:RefreshHostKey
set "TMP_HOSTKEY_FILE=%TEMP%\plink_hostkey_%RANDOM%_%RANDOM%.txt"
set "NEW_HOSTKEY="

plink -batch -pw "%LINUX_PASS%" %LINUX_USER%@%LINUX_HOST% "exit" 1>nul 2>"%TMP_HOSTKEY_FILE%"

for /f "usebackq tokens=*" %%L in ("%TMP_HOSTKEY_FILE%") do (
  for %%W in (%%L) do (
    set "CANDIDATE=%%W"
    if /i "!CANDIDATE:~0,7!"=="SHA256:" set "NEW_HOSTKEY=!CANDIDATE!"
  )
)

if exist "%TMP_HOSTKEY_FILE%" del /q "%TMP_HOSTKEY_FILE%" >nul 2>nul

if not defined NEW_HOSTKEY exit /b 1

endlocal & set "HOSTKEY=%NEW_HOSTKEY%"
exit /b 0
