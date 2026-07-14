@echo off
setlocal enableextensions enabledelayedexpansion

rem ==========================
rem Configuracao padrao
rem ==========================
set "LINUX_USER=root"
set "LINUX_HOST=192.168.40.141"
set "HOSTKEY=SHA256:BnI2cklBut5FrbvH3UZVsYfX67rLQaTX3nubbgc4gMM"

rem Senha padrao (altere se necessario)
set "LINUX_PASS=consinco"

set "SRC_ROOT=C:\WorkCopy\TOTVS\PDV\Desktop\Projetos\AcruxPDV"
set "SRC_GLOBAL_CLASSES=C:\WorkCopy\TOTVS\PDV\Desktop\Projetos\Classes"
set "SRC_FONTES=%SRC_ROOT%\Fontes"
set "SRC_CLASSES=%SRC_ROOT%\Classes"
set "SRC_COMPONENT=%SRC_ROOT%\Component"
set "SRC_RESOURCES=%SRC_ROOT%\Resources"

set "REMOTE_ROOT=/mnt/Projetos/AcruxPDV"
set "REMOTE_FONTES=%REMOTE_ROOT%/Fontes"
set "REMOTE_CLASSES=%REMOTE_ROOT%/Classes"
set "REMOTE_COMPONENT=%REMOTE_ROOT%/Component"
set "REMOTE_RESOURCES=%REMOTE_ROOT%/Resources"
set "REMOTE_ARQUIVOS=%REMOTE_ROOT%"
set "REMOTE_GLOBAL_CLASSES=/mnt/Projetos/Classes"

echo ==========================================
echo Copia de pastas e arquivos para Linux
echo ==========================================
echo Origem base : %SRC_ROOT%
echo Destino base: %LINUX_USER%@%LINUX_HOST%:%REMOTE_ROOT%/
echo.

if not exist "%SRC_ROOT%" (
	echo [ERRO] Pasta base de origem nao encontrada: %SRC_ROOT%
	exit /b 1
)

if not exist "%SRC_FONTES%" (
	echo [ERRO] Pasta de origem nao encontrada: %SRC_FONTES%
	exit /b 1
)

if not exist "%SRC_CLASSES%" (
	echo [ERRO] Pasta de origem nao encontrada: %SRC_CLASSES%
	exit /b 1
)

if not exist "%SRC_COMPONENT%" (
	echo [ERRO] Pasta de origem nao encontrada: %SRC_COMPONENT%
	exit /b 1
)

if not exist "%SRC_RESOURCES%" (
	echo [ERRO] Pasta de origem nao encontrada: %SRC_RESOURCES%
	exit /b 1
)

if not exist "%SRC_GLOBAL_CLASSES%" (
	echo [ERRO] Pasta de origem nao encontrada: %SRC_GLOBAL_CLASSES%
	exit /b 1
)

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

echo [INFO] Validando HOSTKEY atual...
call :TestHostKey
if errorlevel 1 (
	echo [AVISO] HOSTKEY atual falhou. Tentando gerar automaticamente...
	call :RefreshHostKey
	if errorlevel 1 (
		echo [ERRO] Nao foi possivel gerar HOSTKEY automaticamente.
		exit /b 1
	)

	echo [INFO] HOSTKEY atualizado em memoria: %HOSTKEY%
	call :TestHostKey
	if errorlevel 1 (
		echo [ERRO] HOSTKEY gerado, mas a conexao ainda falhou.
		echo        Verifique usuario/senha e conectividade de rede.
		exit /b 1
	)
)

echo [1/7] Garantindo diretorios de destino no Linux...
plink -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" %LINUX_USER%@%LINUX_HOST% "mkdir -p %REMOTE_FONTES% %REMOTE_CLASSES% %REMOTE_COMPONENT% %REMOTE_RESOURCES% %REMOTE_ARQUIVOS% %REMOTE_GLOBAL_CLASSES%"
if errorlevel 1 (
	echo [ERRO] Falha ao criar diretorios remotos.
	exit /b 1
)

echo [2/7] Copiando pasta Fontes...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_FONTES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_FONTES%/
if errorlevel 1 (
	echo [ERRO] Falha ao copiar pasta Fontes.
	exit /b 1
)

echo [3/7] Copiando pasta Classes (AcruxPDV)...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_CLASSES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_CLASSES%/
if errorlevel 1 (
	echo [ERRO] Falha ao copiar pasta Classes AcruxPDV.
	exit /b 1
)

echo [4/7] Copiando pasta Component...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_COMPONENT%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_COMPONENT%/
if errorlevel 1 (
	echo [ERRO] Falha ao copiar pasta Component.
	exit /b 1
)

echo [5/7] Copiando pasta Resources...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_RESOURCES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_RESOURCES%/
if errorlevel 1 (
	echo [ERRO] Falha ao copiar pasta Resources.
	exit /b 1
)

echo [6/7] Copiando pasta global Classes...
pscp -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" -scp -r "%SRC_GLOBAL_CLASSES%\*" %LINUX_USER%@%LINUX_HOST%:%REMOTE_GLOBAL_CLASSES%/
if errorlevel 1 (
	echo [ERRO] Falha ao copiar pasta global Classes.
	exit /b 1
)

echo [7/7] Copiando arquivos da raiz (sem subpastas)...
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

echo [VALIDACAO] Conferindo diretorios no Linux...
plink -batch -hostkey "%HOSTKEY%" -pw "%LINUX_PASS%" %LINUX_USER%@%LINUX_HOST% "ls -ld %REMOTE_FONTES% %REMOTE_CLASSES% %REMOTE_COMPONENT% %REMOTE_RESOURCES% %REMOTE_ARQUIVOS% %REMOTE_GLOBAL_CLASSES%"
if errorlevel 1 (
	echo [ERRO] Validacao remota falhou.
	exit /b 2
)

echo.
echo [OK] Processo concluido com sucesso.
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

if not defined NEW_HOSTKEY (
	exit /b 1
)

set "HOSTKEY=%NEW_HOSTKEY%"
exit /b 0
