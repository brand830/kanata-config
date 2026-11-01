@echo off
rem Compila indicador.cs -> indicador-capa.exe con el compilador de C# que trae Windows
cd /d "%~dp0"
"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe /optimize+ /out:indicador-capa.exe /r:System.Windows.Forms.dll /r:System.Drawing.dll indicador.cs
