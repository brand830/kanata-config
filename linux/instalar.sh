#!/usr/bin/env bash
# ============================================================
# Instala Kanata + indicador de capa en Ubuntu (usuario actual).
#
#   bash linux/instalar.sh
#
# Que hace:
#   1. Descarga Kanata (si no existe ./kanata en la raiz del repo).
#   2. Instala python3-tk (para el indicador).
#   3. Da permisos para que Kanata funcione SIN sudo
#      (grupos input/uinput + regla udev + modulo uinput).
#   4. Crea el servicio de usuario systemd "kanata" (arranca al iniciar sesion).
#   5. Crea el autoarranque del indicador (~/.config/autostart).
#
# Despues de la primera instalacion hay que CERRAR SESION O REINICIAR
# para que los permisos de los grupos tengan efecto.
# Se puede ejecutar de nuevo sin problema (por ejemplo, si mueves la carpeta).
# ============================================================
set -euo pipefail

KANATA_VERSION="v1.12.0"
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KANATA="$RAIZ/kanata"
CONFIG="$RAIZ/config/linux.kbd"
INDICADOR="$RAIZ/linux/indicador-capa.py"

echo "==> Repositorio: $RAIZ"

# 1. Kanata
if [[ ! -x "$KANATA" ]]; then
    echo "==> Descargando Kanata $KANATA_VERSION..."
    sudo apt-get install -y curl unzip
    TMP="$(mktemp -d)"
    curl -fL -o "$TMP/kanata.zip" \
        "https://github.com/jtroo/kanata/releases/download/$KANATA_VERSION/linux-binaries-x64.zip"
    unzip -o "$TMP/kanata.zip" kanata_linux_x64 -d "$TMP"
    install -m 755 "$TMP/kanata_linux_x64" "$KANATA"
    rm -rf "$TMP"
fi
"$KANATA" --version

# 2. Dependencias del indicador
echo "==> Instalando python3-tk..."
sudo apt-get install -y python3-tk

# 3. Permisos (Kanata necesita leer el teclado y crear un teclado virtual)
echo "==> Configurando permisos (input/uinput)..."
getent group uinput >/dev/null || sudo groupadd --system uinput
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' \
    | sudo tee /etc/udev/rules.d/99-kanata-uinput.rules >/dev/null
echo uinput | sudo tee /etc/modules-load.d/kanata-uinput.conf >/dev/null
sudo modprobe uinput
sudo udevadm control --reload-rules
sudo udevadm trigger

# Validar la configuracion antes de activar nada
"$KANATA" --cfg "$CONFIG" --check

# 4. Servicio systemd de usuario para Kanata
echo "==> Creando servicio systemd de usuario: kanata"
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/kanata.service" <<EOF
[Unit]
Description=Kanata - teclado personalizado (capas c0/c1)
Documentation=file://$RAIZ/README.md

[Service]
Type=simple
ExecStart="$KANATA" --cfg "$CONFIG" --port 127.0.0.1:5829 --no-wait --quiet
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable kanata.service

# 5. Autoarranque del indicador (se abre al iniciar sesion grafica)
echo "==> Creando autoarranque del indicador"
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/indicador-capa-kanata.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Indicador de capa (Kanata)
Comment=Muestra C0/C1 abajo al centro de la pantalla
Exec=python3 "$INDICADOR"
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

echo
if id -nG "$USER" | grep -qw uinput; then
    echo "==> Iniciando Kanata e indicador..."
    systemctl --user restart kanata.service
    nohup python3 "$INDICADOR" >/dev/null 2>&1 &
    echo "Listo. Estado: systemctl --user status kanata"
else
    echo "Listo. CIERRA SESION O REINICIA para que los permisos tengan efecto."
    echo "Despues Kanata y el indicador arrancan solos."
fi
