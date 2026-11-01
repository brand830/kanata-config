@echo off
rem ============================================================
rem Inicia Kanata (con servidor local para el indicador) y el indicador de capa.
rem Si ya estaban abiertos, los reinicia (sirve tambien para "reiniciar todo").
rem Requiere: kanata.exe en la raiz del repositorio (ver README).
rem ============================================================
set "RAIZ=%~dp0.."
taskkill /im kanata.exe /f >nul 2>&1
taskkill /im indicador-capa.exe /f >nul 2>&1
start "" "%RAIZ%\kanata.exe" --cfg "%RAIZ%\config\windows.kbd" --port 127.0.0.1:5829
start "" "%~dp0indicador\indicador-capa.exe"
