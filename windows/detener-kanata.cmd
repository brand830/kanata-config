@echo off
rem Cierra Kanata y el indicador (el teclado vuelve a ser 100% normal).
rem Para volver a activarlos: iniciar-kanata.cmd
taskkill /im kanata.exe /f >nul 2>&1
taskkill /im indicador-capa.exe /f >nul 2>&1
echo Kanata y el indicador estan cerrados.
