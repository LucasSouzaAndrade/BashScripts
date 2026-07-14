@echo off
setlocal

rem ==========================
rem Configuracoes gerais
rem ==========================
set "LINUX_USER=root"
set "LINUX_HOST=192.168.40.141"
set "HOSTKEY=SHA256:BnI2cklBut5FrbvH3UZVsYfX67rLQaTX3nubbgc4gMM"
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

rem Exporta variaveis para o caller
endlocal & (
  set "LINUX_USER=%LINUX_USER%"
  set "LINUX_HOST=%LINUX_HOST%"
  set "HOSTKEY=%HOSTKEY%"
  set "LINUX_PASS=%LINUX_PASS%"
  set "SRC_ROOT=%SRC_ROOT%"
  set "SRC_GLOBAL_CLASSES=%SRC_GLOBAL_CLASSES%"
  set "SRC_FONTES=%SRC_FONTES%"
  set "SRC_CLASSES=%SRC_CLASSES%"
  set "SRC_COMPONENT=%SRC_COMPONENT%"
  set "SRC_RESOURCES=%SRC_RESOURCES%"
  set "REMOTE_ROOT=%REMOTE_ROOT%"
  set "REMOTE_FONTES=%REMOTE_FONTES%"
  set "REMOTE_CLASSES=%REMOTE_CLASSES%"
  set "REMOTE_COMPONENT=%REMOTE_COMPONENT%"
  set "REMOTE_RESOURCES=%REMOTE_RESOURCES%"
  set "REMOTE_ARQUIVOS=%REMOTE_ARQUIVOS%"
  set "REMOTE_GLOBAL_CLASSES=%REMOTE_GLOBAL_CLASSES%"
)
exit /b 0
