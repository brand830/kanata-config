#!/usr/bin/env bash
# ============================================================
# Quita Kanata + indicador del inicio en Ubuntu.
#
#   bash linux/desinstalar.sh            -> quita servicio y autoarranque
#   bash linux/desinstalar.sh --todo     -> ademas quita permisos (grupos, regla udev)
#
# No borra el repositorio ni el ejecutable ./kanata.
# ============================================================
set -uo pipefail

echo "==> Deteniendo y quitando el servicio kanata"
systemctl --user disable --now kanata.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/kanata.service"
systemctl --user daemon-reload

echo "==> Quitando el autoarranque del indicador"
pkill -f indicador-capa.py 2>/dev/null || true
rm -f "$HOME/.config/autostart/indicador-capa-kanata.desktop"

if [[ "${1:-}" == "--todo" ]]; then
    echo "==> Quitando permisos (regla udev, modulo, grupos)"
    sudo rm -f /etc/udev/rules.d/99-kanata-uinput.rules /etc/modules-load.d/kanata-uinput.conf
    sudo udevadm control --reload-rules
    sudo gpasswd -d "$USER" uinput 2>/dev/null || true
    sudo gpasswd -d "$USER" input 2>/dev/null || true
    echo "Cierra sesion para que el cambio de grupos tenga efecto."
fi
echo "Listo. El teclado vuelve a ser 100% normal."
