@echo off
setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%logs"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if errorlevel 1 (
    echo [ERRO] Nao foi possivel criar a pasta de log: %LOG_DIR%
    exit /b 1
)

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.config.bat"
if errorlevel 1 exit /b 1

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.Common.bat" :EnsureTools
if errorlevel 1 exit /b 1

call "%SCRIPT_DIR%TranferirAcruxPDVLinux.Common.bat" :EnsureHostKey
if errorlevel 1 exit /b 1

echo ==========================================
echo Copia de pastas e arquivos para Linux
echo ==========================================
echo Origem base : %SRC_ROOT%
echo Destino base: %LINUX_USER%@%LINUX_HOST%:%REMOTE_ROOT%/
echo.

echo [0/8] Garantindo diretorios de destino no Linux...
plink -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" %LINUX_USER%@%LINUX_HOST% "mkdir -p %REMOTE_FONTES% %REMOTE_CLASSES% %REMOTE_COMPONENT% %REMOTE_RESOURCES% %REMOTE_ARQUIVOS% %REMOTE_GLOBAL_CLASSES%"
if errorlevel 1 (
    echo [ERRO] Falha ao criar diretorios remotos.
    exit /b 1
)

set "RUN_ID="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"`) do set "RUN_ID=%%I"
if not defined RUN_ID set "RUN_ID=%RANDOM%_%RANDOM%"
set "JOB_DIR=%LOG_DIR%\run_%RUN_ID%_%RANDOM%"
mkdir "%JOB_DIR%" >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Nao foi possivel criar pasta temporaria de jobs.
    exit /b 1
)

echo [1/8] Iniciando grupos assincronos em lotes (2 por vez)...
set "ANY_FAIL=0"

rem Lote 1
call :StartGroupAsync "01.Fontes" "TranferirAcruxPDVLinux.01.Fontes.bat"
if errorlevel 1 exit /b 1
call :StartGroupAsync "02.ClassesAcruxPDV" "TranferirAcruxPDVLinux.02.ClassesAcruxPDV.bat"
if errorlevel 1 exit /b 1

echo [2/8] Aguardando lote 1...
call :WaitGroup "01.Fontes" || set "ANY_FAIL=1"
call :WaitGroup "02.ClassesAcruxPDV" || set "ANY_FAIL=1"

if "%ANY_FAIL%"=="1" goto :EndWithFailure

rem Lote 2
call :StartGroupAsync "03.Component" "TranferirAcruxPDVLinux.03.Component.bat"
if errorlevel 1 exit /b 1
call :StartGroupAsync "04.Resources" "TranferirAcruxPDVLinux.04.Resources.bat"
if errorlevel 1 exit /b 1

echo [3/8] Aguardando lote 2...
call :WaitGroup "03.Component" || set "ANY_FAIL=1"
call :WaitGroup "04.Resources" || set "ANY_FAIL=1"

if "%ANY_FAIL%"=="1" goto :EndWithFailure

rem Lote 3
call :StartGroupAsync "05.ClassesGlobal" "TranferirAcruxPDVLinux.05.ClassesGlobal.bat"
if errorlevel 1 exit /b 1
call :StartGroupAsync "06.ArquivosRaiz" "TranferirAcruxPDVLinux.06.ArquivosRaiz.bat"
if errorlevel 1 exit /b 1

echo [4/8] Aguardando lote 3...
call :WaitGroup "05.ClassesGlobal" || set "ANY_FAIL=1"
call :WaitGroup "06.ArquivosRaiz" || set "ANY_FAIL=1"

if "%ANY_FAIL%"=="1" goto :EndWithFailure

if exist "%JOB_DIR%" rd /s /q "%JOB_DIR%" >nul 2>nul

echo [5/8] Validando diretorios no Linux...
plink -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" %LINUX_USER%@%LINUX_HOST% "ls -ld %REMOTE_FONTES% %REMOTE_CLASSES% %REMOTE_COMPONENT% %REMOTE_RESOURCES% %REMOTE_ARQUIVOS% %REMOTE_GLOBAL_CLASSES%"
if errorlevel 1 (
    echo [ERRO] Validacao remota falhou.
    exit /b 2
)

echo.
echo [OK] Processo concluido com sucesso.
exit /b 0

:EndWithFailure
echo [ERRO] Um ou mais grupos falharam. Logs em: %JOB_DIR%
exit /b 1

:StartGroupAsync
set "GRP_NAME=%~1"
set "GRP_FILE=%~2"
set "GRP_LOG=%JOB_DIR%\%GRP_NAME%.log"
set "GRP_RC=%JOB_DIR%\%GRP_NAME%.rc"
set "GRP_RUN=%JOB_DIR%\%GRP_NAME%.cmd"

if exist "%GRP_RC%" del /q "%GRP_RC%" >nul 2>nul
if exist "%GRP_RUN%" del /q "%GRP_RUN%" >nul 2>nul

> "%GRP_RUN%" (
    echo @echo off
    echo call "%SCRIPT_DIR%%GRP_FILE%" ^> "%GRP_LOG%" 2^>^&1
    echo set "RC=%%errorlevel%%"
    echo ^> "%GRP_RC%" echo %%RC%%
)

start "" /b cmd /c ""%GRP_RUN%""
if errorlevel 1 (
    echo [ERRO] Falha ao iniciar grupo %GRP_NAME%.
    exit /b 1
)

echo   - %GRP_NAME% iniciado.
exit /b 0

:WaitGroup
set "GRP_NAME=%~1"
set "GRP_LOG=%JOB_DIR%\%GRP_NAME%.log"
set "GRP_RC=%JOB_DIR%\%GRP_NAME%.rc"
set /a "WAIT_COUNT=0"
set /a "WAIT_MAX=7200"

:WaitGroupLoop
if not exist "%GRP_RC%" (
    set /a "WAIT_COUNT+=1"
    if !WAIT_COUNT! GEQ !WAIT_MAX! (
        echo [ERRO] Timeout aguardando grupo %GRP_NAME%.
        exit /b 1
    )
    timeout /t 1 /nobreak >nul
    goto :WaitGroupLoop
)

set "GRP_RESULT="
set /p GRP_RESULT=<"%GRP_RC%" 2>nul
if not defined GRP_RESULT (
    set /a "WAIT_COUNT+=1"
    if !WAIT_COUNT! GEQ !WAIT_MAX! (
        echo [ERRO] Timeout lendo retorno do grupo %GRP_NAME%.
        exit /b 1
    )
    timeout /t 1 /nobreak >nul
    goto :WaitGroupLoop
)

for /f "delims=0123456789" %%X in ("%GRP_RESULT%") do (
    echo [ERRO] Retorno invalido do grupo %GRP_NAME%: %GRP_RESULT%
    if exist "%GRP_LOG%" (
        echo ------- LOG %GRP_NAME% -------
        type "%GRP_LOG%"
        echo ------- FIM LOG %GRP_NAME% -------
    )
    exit /b 1
)

if not "%GRP_RESULT%"=="0" (
    echo [ERRO] Grupo %GRP_NAME% falhou. Codigo: %GRP_RESULT%
    if exist "%GRP_LOG%" (
        echo ------- LOG %GRP_NAME% -------
        type "%GRP_LOG%"
        echo ------- FIM LOG %GRP_NAME% -------
    )
    exit /b 1
)

echo   - %GRP_NAME% finalizado com sucesso.
exit /b 0
