# ============================================================
# Activa o quita el inicio automatico de Kanata + indicador al iniciar sesion en Windows.
#
#   Activar:  powershell -ExecutionPolicy Bypass -File windows\inicio-automatico.ps1
#   Quitar:   powershell -ExecutionPolicy Bypass -File windows\inicio-automatico.ps1 -Quitar
#
# Crea (o borra) el acceso directo "Kanata" en la carpeta Inicio del usuario (shell:startup).
# Usa la ubicacion actual del repositorio, asi que si mueves la carpeta, vuelve a ejecutarlo.
# ============================================================
param([switch]$Quitar)

$acceso = Join-Path ([Environment]::GetFolderPath('Startup')) 'Kanata.lnk'

if ($Quitar) {
    if (Test-Path $acceso) { Remove-Item $acceso; 'Inicio automatico desactivado.' }
    else { 'No estaba activado.' }
    return
}

$lanzador = Join-Path $PSScriptRoot 'iniciar-kanata.cmd'
$raiz = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $raiz 'kanata.exe'))) { Write-Warning "Falta kanata.exe en $raiz (ver README)." }
if (-not (Test-Path (Join-Path $PSScriptRoot 'indicador\indicador-capa.exe'))) { Write-Warning 'Falta compilar el indicador: windows\indicador\compilar.cmd' }

$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut($acceso)
$sc.TargetPath = "$env:WINDIR\System32\cmd.exe"
$sc.Arguments = "/c `"$lanzador`""
$sc.WorkingDirectory = $raiz
$sc.WindowStyle = 7   # minimizado
$sc.IconLocation = (Join-Path $raiz 'kanata.exe') + ',0'
$sc.Description = 'Inicia Kanata y el indicador de capa'
$sc.Save()
"Inicio automatico activado: $acceso"
