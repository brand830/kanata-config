#!/usr/bin/env python3
"""
Indicador de capa para Kanata (version Linux / Ubuntu).

Se conecta al servidor TCP de Kanata (127.0.0.1:5829) y muestra un cuadrado
minimalista en la parte inferior central de la pantalla con el nombre de la capa:
  - c0 (teclado normal): cuadrado gris; se muestra 1,2 s al volver y se oculta.
  - c1 (y cualquier otra capa): cuadrado blanco; se muestra 2,5 s al entrar y se oculta.

Es el equivalente de windows/indicador/indicador.cs. Requiere: python3-tk
Ejecutar a mano:  python3 linux/indicador-capa.py
"""
import json
import queue
import re
import socket
import subprocess
import threading
import time
import tkinter as tk

PUERTO = 5829
CAPA_BASE = "c0"
MS_MOSTRAR_BASE = 1200   # c0: ms visible al volver a la capa normal
MS_MOSTRAR_CAPA = 2500   # c1 y otras capas: ms visible al entrar
LADO = 36               # lado del cuadrado en pixeles
MARGEN_INFERIOR = 70    # distancia al borde inferior (deja espacio para el dock / barra)
# es_base -> (fondo, texto)
COLORES = {True: ("#606060", "#ffffff"), False: ("#f5f5f5", "#202020")}


def area_monitor_principal():
    """(x, y, ancho, alto) del monitor principal segun xrandr, o None si no se puede saber.

    Tk solo conoce el escritorio completo; con varios monitores su "centro" cae entre
    pantallas. xrandr marca el principal con '*', por ejemplo:
      0: +*HDMI-1-0 1920/597x1080/336+0+407  HDMI-1-0
    """
    try:
        salida = subprocess.run(["xrandr", "--listactivemonitors"], capture_output=True,
                                text=True, timeout=2).stdout
    except (OSError, subprocess.SubprocessError):
        return None
    monitores = []
    for linea in salida.splitlines():
        m = re.search(r"(\*?)\S*\s+(\d+)/\d+x(\d+)/\d+\+(\d+)\+(\d+)", linea)
        if m:
            area = tuple(int(v) for v in m.groups()[1:])  # ancho, alto, x, y
            monitores.append((m.group(1) == "*", area))
    if not monitores:
        return None
    principal = next((a for es_p, a in monitores if es_p), monitores[0][1])
    ancho, alto, x, y = principal
    return x, y, ancho, alto


def escuchar(cola):
    """Hilo en segundo plano: lee los mensajes de Kanata y se reconecta si Kanata se reinicia."""
    while True:
        try:
            with socket.create_connection(("127.0.0.1", PUERTO), timeout=5) as s:
                s.settimeout(None)
                s.sendall(b'{"RequestCurrentLayerName":{}}\n')
                with s.makefile("r", encoding="utf-8") as f:
                    for linea in f:
                        try:
                            msg = json.loads(linea)
                        except ValueError:
                            continue
                        if "LayerChange" in msg:
                            cola.put(msg["LayerChange"].get("new"))
                        elif "CurrentLayerName" in msg:
                            cola.put(msg["CurrentLayerName"].get("name"))
        except OSError:
            pass
        cola.put(None)  # desconectado: ocultar
        time.sleep(2)


class Indicador:
    def __init__(self):
        self.root = tk.Tk()
        self.root.withdraw()
        self.root.title("Indicador de capa")
        self.root.overrideredirect(True)        # sin bordes ni barra de titulo
        self.root.attributes("-topmost", True)  # siempre encima
        self.etiqueta = tk.Label(self.root, font=("Ubuntu", 11, "bold"), bd=0)
        self.etiqueta.pack(fill="both", expand=True)
        self.cola = queue.Queue()
        self.temporizador = None
        threading.Thread(target=escuchar, args=(self.cola,), daemon=True).start()
        self.root.after(50, self.revisar_cola)

    def revisar_cola(self):
        try:
            while True:
                capa = self.cola.get_nowait()
                if capa:
                    self.mostrar(capa)
                else:
                    self.ocultar()
        except queue.Empty:
            pass
        self.root.after(50, self.revisar_cola)

    def mostrar(self, capa):
        es_base = capa == CAPA_BASE
        fondo, texto = COLORES[es_base]
        self.root.configure(bg=fondo)
        self.etiqueta.configure(text=capa.upper(), bg=fondo, fg=texto)
        area = area_monitor_principal() or (
            0, 0, self.root.winfo_screenwidth(), self.root.winfo_screenheight())
        mx, my, ancho, alto = area
        x = mx + (ancho - LADO) // 2
        y = my + alto - LADO - MARGEN_INFERIOR
        self.root.geometry(f"{LADO}x{LADO}+{x}+{y}")
        self.root.deiconify()
        self.root.lift()
        self.root.attributes("-topmost", True)
        self.cancelar_temporizador()
        ms = MS_MOSTRAR_BASE if es_base else MS_MOSTRAR_CAPA
        self.temporizador = self.root.after(ms, self.ocultar)

    def ocultar(self):
        self.cancelar_temporizador()
        self.root.withdraw()

    def cancelar_temporizador(self):
        if self.temporizador is not None:
            self.root.after_cancel(self.temporizador)
            self.temporizador = None


if __name__ == "__main__":
    Indicador().root.mainloop()
