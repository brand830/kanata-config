# Mi teclado con Kanata

Configuración personal de [Kanata](https://github.com/jtroo/kanata) para un **Redragon Fizz Pro 60%**, lista para clonar en **Windows** y **Ubuntu**.

Agrega una **capa 1** (navegación, multimedia y mouse con el teclado) que se activa con **Esc x2** o un toque de **Ctrl derecho**. Un **indicador** en la parte inferior central de la pantalla muestra en qué capa estás.

| Sistema | Estado |
|---|---|
| Windows 11 (distribución Español-España) | ✅ En uso y probado |
| Ubuntu | 🟡 Preparado, todavía **sin probar** en Ubuntu real |

Versión de Kanata usada: **v1.12.0**

---

## Índice

1. [Mapa de teclas](#1-mapa-de-teclas)
2. [Estructura del repositorio](#2-estructura-del-repositorio)
3. [Windows: instalación, uso y cómo desactivarlo](#3-windows)
4. [Ubuntu: instalación, uso y cómo desactivarlo](#4-ubuntu)
5. [Cambiar la configuración](#5-cambiar-la-configuración)
6. [El indicador de capa](#6-el-indicador-de-capa)
7. [Problemas conocidos y sus soluciones](#7-problemas-conocidos-y-sus-soluciones)
8. [Historial: qué se hizo y por qué](#8-historial-qué-se-hizo-y-por-qué)
9. [Subir a GitHub y clonar en otra PC](#9-subir-a-github-y-clonar-en-otra-pc)

---

## 1. Mapa de teclas

Kanata trabaja con la **posición física** de las teclas, no con la letra impresa. Por eso las capas funcionan igual con la distribución en inglés, español o latino; Windows o Linux solo deciden qué letra sale al escribir.

### Cambiar de capa

| Acción | Resultado |
|---|---|
| **Esc** x1 | Esc normal |
| **Esc** x2 (rápido, < 250 ms) | Entra a la capa 1, o vuelve a la capa 0 |
| **Ctrl derecho**: un toque | Entra a la capa 1, o vuelve a la capa 0 |
| **Ctrl derecho**: mantener o combinar (Ctrl+C...) | Ctrl normal |
| **Ctrl izq + Espacio + Esc** | **Salida de emergencia**: cierra Kanata |

### Capa 0 (C0): teclado normal

Todo funciona como siempre. Solo cambian **Esc** (doble toque) y **Ctrl derecho** (toque).

### Capa 1 (C1): navegación + mouse

```
 Esc   1     2     3     4     5     6     7    8    9    0      Bksp
 x2   Mute  Vol-  Vol+  Ant.  Play  Sig.   ·    ·    ·  Recargar Bksp

 Tab   Q      W     E     R     T      Y        U       I     O        P
  ·  Inicio   ↑    Fin  RePág ImpPnt Clic Med Clic Izq 🖱↑  Clic Der  Recorte

 Caps  A     S     D     F     G     H      J     K     L    Enter
  ·    ←     ↓     →   AvPág   ·   Lento   🖱←    🖱↓    🖱→     ·

 Shift Z      X      C      V      B      N       M      Shift
  ·  Deshac Cortar Copiar Pegar  Rehac  Rueda↑  Rueda↓    ·       Ctrl der = salir
```

| Teclas | Función |
|---|---|
| **1 2 3** | Silencio, bajar volumen, subir volumen |
| **4 5 6** | Canción anterior, Play/Pausa, siguiente |
| **0** | Recargar la configuración (después de editarla) |
| **W A S D** | Flechas |
| **Q / E** | Inicio / Fin |
| **R / F** | RePág / AvPág |
| **Z X C V B** | Deshacer, Cortar, Copiar, Pegar, Rehacer |
| **T** | Impr Pant |
| **P** | Recorte de pantalla (Windows: Win+Shift+S · Ubuntu: Impr Pant) |
| **I J K L** | Mover el mouse (acelera mientras mantienes la tecla; se pueden combinar para diagonales) |
| **U / O** | Clic izquierdo / derecho (mantener = arrastrar) |
| **Y** | Clic central |
| **N / M** | Scroll arriba / abajo |
| **H** (mantener) | Mouse lento y preciso |
| **Backspace** | Normal (borra a la izquierda) |

- **Shift + flechas** selecciona texto.
- **Ctrl + flechas** salta de palabra en palabra.

F1–F12 no están en la capa: el teclado ya los tiene con **Fn**.

---

## 2. Estructura del repositorio

```
.
├── README.md                    ← este documento
├── config/
│   ├── comun.kbd                ← CAPAS (compartidas por Windows y Ubuntu) ← aquí se edita casi todo
│   ├── windows.kbd              ← ajustes solo de Windows + (include comun.kbd)
│   ├── linux.kbd                ← ajustes solo de Ubuntu  + (include comun.kbd)
│   └── icons/c0.png, c1.png     ← íconos de la bandeja de Windows
├── windows/
│   ├── iniciar-kanata.cmd       ← inicia (o reinicia) Kanata + indicador
│   ├── detener-kanata.cmd       ← cierra Kanata + indicador
│   ├── inicio-automatico.ps1    ← activa/quita el arranque con Windows
│   └── indicador/
│       ├── indicador.cs         ← código del indicador (C#)
│       └── compilar.cmd         ← genera indicador-capa.exe
└── linux/
    ├── instalar.sh              ← instala todo en Ubuntu (Kanata, permisos, servicio, indicador)
    ├── desinstalar.sh           ← lo quita
    └── indicador-capa.py        ← indicador para Linux (Python + Tk)
```

**No se suben a GitHub** (ver `.gitignore`): los ejecutables de Kanata (`kanata.exe`, `kanata`, `bin/`) y el indicador compilado (`indicador-capa.exe`). Se descargan o generan en cada PC.

---

## 3. Windows

### 3.1 Instalación en una PC nueva

1. **Clonar** el repositorio, por ejemplo en `D:\PROYECTOS\kanata`.
2. **Descargar Kanata v1.12.0**: [`windows-binaries-x64.zip`](https://github.com/jtroo/kanata/releases/download/v1.12.0/windows-binaries-x64.zip).
   - Descomprime el contenido en la carpeta `bin\` del repositorio.
   - **Copia** `bin\kanata_windows_gui_winIOv2_x64.exe` a la raíz del repositorio con el nombre **`kanata.exe`**.

   | Parte del nombre | Por qué esa variante |
   |---|---|
   | `gui` | Tiene ícono en la bandeja y no abre ventana de consola |
   | `winIOv2` | Lee la posición física de la tecla, así las capas no dependen de la distribución |
   | sin `cmd_allowed` | No permite ejecutar comandos del sistema (más seguro; no lo usamos) |

3. **Compilar el indicador**: doble clic en `windows\indicador\compilar.cmd`. Usa el compilador de C# que ya trae Windows; no hay que instalar nada. Crea `indicador-capa.exe`.
4. **Iniciar**: doble clic en `windows\iniciar-kanata.cmd`.
5. **Arranque automático** (opcional), en PowerShell desde la raíz del repositorio:
   ```powershell
   powershell -ExecutionPolicy Bypass -File windows\inicio-automatico.ps1
   ```
   Crea el acceso directo **Kanata** en la carpeta Inicio (`shell:startup`). Si mueves la carpeta del repositorio, vuelve a ejecutarlo.

### 3.2 Uso diario

- Kanata y el indicador arrancan solos al iniciar sesión.
- En la bandeja (junto al reloj) hay un ícono **C0/C1**. Si no lo ves, está en la flechita **^**; puedes arrastrarlo afuera.
- Abajo al centro aparece el cuadrado **C1** (blanco) mientras estés en la capa 1.

### 3.3 Cómo desactivarlo

| Quiero... | Cómo |
|---|---|
| Apagarlo **ya**, en emergencia | **Ctrl izq + Espacio + Esc** (cierra Kanata; el indicador se oculta solo) |
| Apagarlo un rato | Doble clic en `windows\detener-kanata.cmd` |
| Volver a encenderlo | Doble clic en `windows\iniciar-kanata.cmd` |
| Que **no arranque** con Windows | `powershell -ExecutionPolicy Bypass -File windows\inicio-automatico.ps1 -Quitar` |
| (alternativa) | Administrador de tareas (Ctrl+Shift+Esc) → **Aplicaciones de arranque** → desactivar **Kanata** |
| (alternativa) | Win+R → `shell:startup` → borrar el acceso directo **Kanata** |

Desinstalar del todo: quitar el arranque automático, cerrar con `detener-kanata.cmd` y borrar la carpeta. Kanata no instala nada más en el sistema.

---

## 4. Ubuntu

> 🟡 **Sin probar todavía en Ubuntu.** Los archivos siguen la documentación oficial de Kanata y el indicador se probó en Windows (misma lógica). Si algo falla en Ubuntu, revisar la [sección 7](#7-problemas-conocidos-y-sus-soluciones).

### 4.1 Instalación

```bash
git clone https://github.com/<tu-usuario>/<tu-repo>.git ~/kanata
cd ~/kanata
bash linux/instalar.sh
```

Luego **cierra sesión o reinicia** (solo la primera vez).

Qué hace `instalar.sh`, paso a paso:

1. Descarga `kanata_linux_x64` (v1.12.0) y lo guarda como `./kanata` en la raíz del repositorio.
2. Instala `python3-tk`, que necesita el indicador.
3. Da permisos para usar Kanata **sin sudo**:
   - agrega tu usuario a los grupos `input` y `uinput`;
   - crea la regla `/etc/udev/rules.d/99-kanata-uinput.rules`;
   - carga el módulo `uinput` y lo deja configurado para cada arranque.

   Kanata necesita esto para leer el teclado y crear un teclado virtual.
4. Valida `config/linux.kbd`.
5. Crea y activa el servicio de usuario `~/.config/systemd/user/kanata.service`, que arranca Kanata al iniciar sesión.
6. Crea `~/.config/autostart/indicador-capa-kanata.desktop`, que abre el indicador al iniciar sesión gráfica.

### 4.2 Uso y cómo desactivarlo

| Quiero... | Comando |
|---|---|
| Ver si está corriendo | `systemctl --user status kanata` |
| Ver errores | `journalctl --user -u kanata -e` |
| Apagarlo **ya**, en emergencia | **Ctrl izq + Espacio + Esc** |
| Apagarlo un rato | `systemctl --user stop kanata` |
| Volver a encenderlo | `systemctl --user start kanata` |
| Reiniciarlo (tras editar la config) | `systemctl --user restart kanata`, o **capa 1 + 0** |
| Que no arranque al iniciar sesión | `systemctl --user disable kanata` |
| Quitar servicio + indicador | `bash linux/desinstalar.sh` |
| Quitar también permisos y grupos | `bash linux/desinstalar.sh --todo` |

### 4.3 Diferencias con Windows

- **Recorte (P)** envía **Impr Pant**, que en Ubuntu abre la herramienta de captura.
- En Linux **no** existe el problema de las teclas de símbolos de Windows (sección 7.1), así que `linux.kbd` procesa todas las teclas.
- No hay ícono en la bandeja: el indicador abajo al centro hace esa función.

---

## 5. Cambiar la configuración

1. Edita **`config/comun.kbd`** para cambiar las capas. Los ajustes propios de cada sistema están en `windows.kbd` y `linux.kbd`.
2. **Valida** antes de recargar:
   - Windows: `bin\kanata_windows_tty_winIOv2_x64.exe --cfg config\windows.kbd --check`
   - Ubuntu: `./kanata --cfg config/linux.kbd --check`
3. **Recarga**:
   - Capa 1 + **0**.
   - O reinicia: Windows `windows\iniciar-kanata.cmd`, Ubuntu `systemctl --user restart kanata`.

Si la configuración tiene un error, Kanata lo avisa y sigue usando la anterior.

Reglas de Kanata a tener en cuenta:

- Cada `deflayer` debe tener **exactamente la misma cantidad de teclas** que `defsrc`. Si no, sale un error como *"Layer c1 has 44 item(s), but requires 43"*.
- `_` significa "igual que en la capa de abajo" (transparente).
- **En Windows no agregues teclas de símbolos a `defsrc`** (`- = [ ] \ ; ' , . /` y la tecla `º`). Ver sección 7.1.
- Documentación oficial: <https://github.com/jtroo/kanata/blob/main/docs/config.adoc>

---

## 6. El indicador de capa

Es un cuadrado de 36×36 px en la **parte inferior central** de la pantalla.

| Capa | Color | Comportamiento |
|---|---|---|
| **C0** | Gris con letras blancas | Aparece ~1,2 s al volver a la capa 0 y se oculta |
| **C1** | Blanco con letras oscuras | Se queda visible mientras la capa 1 esté activa |

### Cómo funciona

- Kanata se inicia con `--port 127.0.0.1:5829`, que abre un pequeño servidor **solo local**: no acepta conexiones desde internet.
- Cada vez que cambias de capa, Kanata envía un mensaje JSON como `{"LayerChange":{"new":"c1"}}`.
- El indicador está conectado a ese servidor y cambia según el mensaje. Al conectarse pregunta la capa actual con `{"RequestCurrentLayerName":{}}`.
- Si Kanata se cierra, el indicador se oculta y se reconecta solo cada 2 s.

| | Windows | Ubuntu |
|---|---|---|
| Archivo | `windows/indicador/indicador.cs` (C# / WinForms) | `linux/indicador-capa.py` (Python / Tk) |
| Compilar | `compilar.cmd` | No hace falta |
| Detalles | No recibe clics, no roba el foco, no aparece en Alt+Tab | Ventana sin bordes, siempre encima |

### Personalizar

Los colores, el tamaño, el tiempo y la distancia al borde están al inicio de cada archivo:

- **C#:** `FONDO_BASE`, `TEXTO_BASE`, `FONDO_CAPA`, `TEXTO_CAPA`, `LADO`, `MS_MOSTRAR_BASE`, `MARGEN_INFERIOR`. Después de cambiarlos, vuelve a ejecutar `compilar.cmd` (cierra antes el indicador con `detener-kanata.cmd`).
- **Python:** `COLORES`, `LADO`, `MS_MOSTRAR_BASE`, `MARGEN_INFERIOR`.

Si cambias los colores, puedes regenerar también `config/icons/c0.png` y `c1.png` (64×64) para que coincidan con la bandeja de Windows.

---

## 7. Problemas conocidos y sus soluciones

### 7.1 Windows + distribución española: aviso *"Unexpected keycode... Clearing kanata states: Bslash / Minus"* y teclas que no se repiten

**Síntoma:**

- Al presionar `}` (AltGr + ç), `'` u otras teclas de símbolos aparece el aviso *"Unexpected keycode is pressed in kanata but not in Windows. Clearing kanata states: Bslash"* (o `Minus`).
- Al mantenerlas presionadas, se escriben **una sola vez** en lugar de repetirse.

**Causa:**

- Kanata compara periódicamente sus teclas presionadas con las de Windows, pero pregunta usando los códigos del **teclado inglés**.
- En español, las teclas de símbolos tienen otros códigos. Por ejemplo, la tecla `ç` está en la posición de la `\` inglesa, pero Windows la registra con otro código.
- Windows responde "no está presionada", Kanata borra la tecla de su lista y deja de repetirla.
- En **v1.12.0 esta comparación no se puede apagar**: `windows-sync-keystates no` solo apaga otra parte del chequeo.

**Solución aplicada** en `config/windows.kbd`:

```lisp
process-unmapped-keys (all-except min eql lbrc rbrc \ scln apos grv comm . / nubs)
```

- Las teclas de símbolos (ñ ' ¡ ` + ç - º ´ < , .) **no pasan por Kanata**: van directo a Windows.
- Tampoco están en `defsrc`.
- La contra es que en Windows esas teclas no se pueden usar en las capas. Por eso F11/F12 se quitaron de la capa 1.

**A futuro:** en el código de desarrollo de Kanata ya existe `windows-sync-keystates none`, que apaga la comparación del todo. Cuando salga una versión publicada que lo incluya, se podría actualizar y volver a usar esas teclas.

### 7.2 Windows: AltGr

AltGr envía por debajo un Ctrl izquierdo falso, lo que puede dejar Ctrl "pegado". Se corrige con:

```lisp
windows-altgr cancel-lctl-press
```

Si da problemas, la alternativa es `add-lctl-release`.

### 7.3 Windows: ventanas de administrador

Kanata no actúa dentro de ventanas abiertas como administrador (Administrador de tareas, algunos instaladores). Ahí el teclado escribe normal. Es una limitación de Windows.

### 7.4 Windows: `windows-sync-keystates none` da error

En v1.12.0 esa opción solo acepta `yes`/`no`. `none` es de versiones más nuevas.

### 7.5 Ubuntu: el indicador no aparece encima, o no queda centrado

- Ubuntu usa **Wayland** por defecto. El indicador (Tk) corre mediante XWayland, y algunas versiones de GNOME no respetan la posición o el "siempre encima".
- Si pasa: en la pantalla de inicio de sesión, el ícono ⚙️ → **"Ubuntu en Xorg"**.
- Con varios monitores, el centro se calcula sobre el área total.

### 7.6 Ubuntu: Kanata no arranca (permisos)

- Revisa con `journalctl --user -u kanata -e`.
- Casi siempre es porque falta **cerrar sesión** después de `instalar.sh`.
- `groups` debe mostrar `input` y `uinput`.

---

## 8. Historial: qué se hizo y por qué

1. **Capa base + capa de navegación** activada con **Esc x2** (`tap-dance` de 250 ms).
2. **Error `Bslash`/`Minus` y teclas sin repetición** (sección 7.1).
   - Se probó `windows-sync-keystates no`: no basta en v1.12.0.
   - Luego `notify-error no`: solo ocultaba el aviso.
   - Solución final: excluir las teclas de símbolos de Kanata.
3. **AltGr**: `windows-altgr cancel-lctl-press` (sección 7.2).
4. **Nueva distribución de la capa:**
   - Ctrl derecho (toque) también cambia de capa (`tap-hold-press`: mantenido sigue siendo Ctrl).
   - Volumen en 2/3, flechas en WASD.
   - Inicio/Fin y RePág/AvPág alrededor de WASD.
   - Deshacer/Cortar/Copiar/Pegar/Rehacer en ZXCVB.
   - Recorte en P.
5. **Mouse con el teclado:** IJKL con aceleración, U/O clics, Y clic central, N/M scroll, H modo lento.
6. **Corrección:** Backspace en la capa tenía *Supr* (borraba a la derecha). Volvió a ser Backspace normal.
7. **Capas renombradas** a `c0` y `c1`.
8. **Indicador de capa:**
   - El ícono flotante de Kanata solo aparece junto al mouse, así que se creó un indicador propio, abajo al centro, conectado por el servidor TCP de Kanata.
   - Primero fue una pastilla oscura; luego un cuadrado, **gris en C0 y blanco en C1**.
   - Íconos de la bandeja con los mismos colores.
9. **Arranque automático** con Windows (acceso directo en `shell:startup`).
10. **Proyecto para GitHub:**
    - Configuración separada en `comun.kbd` + `windows.kbd` / `linux.kbd`.
    - Scripts de instalación para Ubuntu.
    - Indicador para Linux en Python.

---

## 9. Subir a GitHub y clonar en otra PC

### Primera vez (desde esta PC con Windows)

1. Instala Git: `winget install --id Git.Git -e`. Luego cierra y vuelve a abrir la terminal.
2. Crea un repositorio **vacío** en <https://github.com/new> (sin README), por ejemplo `mi-teclado-kanata`.
3. En la carpeta del proyecto:
   ```powershell
   git init
   git add .
   git commit -m "Configuracion de Kanata: capas c0/c1, indicador, Windows y Ubuntu"
   git branch -M main
   git remote add origin https://github.com/<tu-usuario>/mi-teclado-kanata.git
   git push -u origin main
   ```
   Antes del commit, `git status` no debe mostrar `kanata.exe`, `bin/` ni `indicador-capa.exe`.

### En otra PC

- **Windows:** `git clone ...` y seguir la [sección 3.1](#31-instalación-en-una-pc-nueva).
- **Ubuntu:** `git clone ...` y `bash linux/instalar.sh` ([sección 4.1](#41-instalación)).

### Al hacer cambios

```bash
git add .
git commit -m "Describe el cambio"
git push          # y en la otra PC: git pull
```
