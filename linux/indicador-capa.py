#!/usr/bin/env python3
"""
Indicador de capa para Kanata (version Linux / Ubuntu).

Se conecta al servidor TCP de Kanata (127.0.0.1:5829) y muestra un cuadrado
minimalista en la parte inferior central de la pantalla con el nombre de la capa:
  - c0 (teclado normal): cuadrado gris; se muestra 1,2 s al volver y se oculta.
  - c1 (y cualquier otra capa): cuadrado blanco; visible mientras la capa este activa.

Es el equivalente de windows/indicador/indicador.cs. Requiere: python3-tk
Ejecutar a mano:  python3 linux/indicador-capa.py
"""
import json
import queue
import socket
import threading
import time
import tkinter as tk

PUERTO = 5829
CAPA_BASE = "c0"
MS_MOSTRAR_BASE = 1200
LADO = 36               # lado del cuadrado en pixeles
MARGEN_INFERIOR = 70    # distancia al borde inferior (deja espacio para el dock / barra)
# es_base -> (fondo, texto)
COLORES = {True: ("#606060", "#ffffff"), False: ("#f5f5f5", "#202020")}


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
        x = (self.root.winfo_screenwidth() - LADO) // 2
        y = self.root.winfo_screenheight() - LADO - MARGEN_INFERIOR
        self.root.geometry(f"{LADO}x{LADO}+{x}+{y}")
        self.root.deiconify()
        self.root.lift()
        self.root.attributes("-topmost", True)
        self.cancelar_temporizador()
        if es_base:
            self.temporizador = self.root.after(MS_MOSTRAR_BASE, self.ocultar)

    def ocultar(self):
        self.cancelar_temporizador()
        self.root.withdraw()

    def cancelar_temporizador(self):
        if self.temporizador is not None:
            self.root.after_cancel(self.temporizador)
            self.temporizador = None


if __name__ == "__main__":
    Indicador().root.mainloop()
