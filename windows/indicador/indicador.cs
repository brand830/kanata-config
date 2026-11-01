// Indicador de capa para Kanata.
// Se conecta al servidor TCP de Kanata (127.0.0.1:5829) y muestra una pastilla
// cuadrado minimalista en la parte inferior central de la pantalla con el nombre de la capa
// (gris en c0, blanco en c1).
//   - c0 (teclado normal): se muestra 1,2 s al volver y se oculta.
//   - cualquier otra capa (c1...): se queda visible mientras la capa este activa.
// No recibe clics (se puede hacer clic "a traves" de ella) y no roba el foco.
// Compilar: compilar.cmd

using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows.Forms;

class Indicador : Form
{
    const int PUERTO = 5829;
    const string CAPA_BASE = "c0";
    const int MS_MOSTRAR_BASE = 1200;
    const int MARGEN_INFERIOR = 28;   // pixeles (a 100%) por encima de la barra de tareas

    // c0 = cuadrado gris con texto blanco; c1 (y otras capas) = cuadrado blanco con texto oscuro
    static readonly Color FONDO_BASE  = Color.FromArgb(96, 96, 96);
    static readonly Color TEXTO_BASE  = Color.FromArgb(255, 255, 255);
    static readonly Color FONDO_CAPA  = Color.FromArgb(245, 245, 245);
    static readonly Color TEXTO_CAPA  = Color.FromArgb(32, 32, 32);
    const int LADO = 36;   // lado del cuadrado en pixeles (a 100%)

    Color colorTexto = TEXTO_BASE;

    readonly float escala;
    readonly System.Windows.Forms.Timer temporizador = new System.Windows.Forms.Timer();
    string texto = "";

    [DllImport("user32.dll")] static extern bool SetProcessDPIAware();

    public Indicador()
    {
        using (Graphics g = Graphics.FromHwnd(IntPtr.Zero)) escala = g.DpiX / 96f;

        FormBorderStyle = FormBorderStyle.None;
        ShowInTaskbar = false;
        TopMost = true;
        StartPosition = FormStartPosition.Manual;
        BackColor = FONDO_BASE;
        Opacity = 0.95;
        DoubleBuffered = true;
        Font = new Font("Segoe UI Semibold", 11f);
        Size = new Size((int)(LADO * escala), (int)(LADO * escala));

        temporizador.Interval = MS_MOSTRAR_BASE;
        temporizador.Tick += (s, e) => { temporizador.Stop(); Hide(); };

        Posicionar();
        Microsoft.Win32.SystemEvents.DisplaySettingsChanged += (s, e) =>
        {
            try { BeginInvoke((Action)Posicionar); } catch { }
        };
    }

    // Sin foco, sin clics, sin aparecer en Alt+Tab, siempre encima
    protected override bool ShowWithoutActivation { get { return true; } }
    protected override CreateParams CreateParams
    {
        get
        {
            CreateParams cp = base.CreateParams;
            cp.ExStyle |= 0x00000080   // WS_EX_TOOLWINDOW
                        | 0x00000020   // WS_EX_TRANSPARENT
                        | 0x00080000   // WS_EX_LAYERED
                        | 0x08000000   // WS_EX_NOACTIVATE
                        | 0x00000008;  // WS_EX_TOPMOST
            return cp;
        }
    }

    void Posicionar()
    {
        Rectangle area = Screen.PrimaryScreen.WorkingArea;
        Location = new Point(area.Left + (area.Width - Width) / 2,
                             area.Bottom - Height - (int)(MARGEN_INFERIOR * escala));
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        e.Graphics.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;
        TextRenderer.DrawText(e.Graphics, texto, Font, ClientRectangle, colorTexto,
            TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding);
    }

    void MostrarCapa(string capa)
    {
        texto = capa.ToUpperInvariant();
        bool esBase = capa == CAPA_BASE;
        BackColor = esBase ? FONDO_BASE : FONDO_CAPA;
        colorTexto = esBase ? TEXTO_BASE : TEXTO_CAPA;
        Invalidate();
        temporizador.Stop();
        if (!Visible) Show();
        TopMost = true;
        if (capa == CAPA_BASE) temporizador.Start();
    }

    void Ocultar()
    {
        temporizador.Stop();
        Hide();
    }

    // Hilo en segundo plano: escucha a Kanata y se reconecta si Kanata se reinicia
    void Escuchar()
    {
        Regex mensaje = new Regex("\"(?:LayerChange|CurrentLayerName)\"\\s*:\\s*\\{\\s*\"(?:new|name)\"\\s*:\\s*\"([^\"]*)\"");
        byte[] pedirCapa = Encoding.UTF8.GetBytes("{\"RequestCurrentLayerName\":{}}\n");
        byte[] buf = new byte[4096];

        while (true)
        {
            try
            {
                using (TcpClient cliente = new TcpClient("127.0.0.1", PUERTO))
                using (NetworkStream red = cliente.GetStream())
                {
                    red.Write(pedirCapa, 0, pedirCapa.Length);
                    StringBuilder pendiente = new StringBuilder();
                    int n;
                    while ((n = red.Read(buf, 0, buf.Length)) > 0)
                    {
                        pendiente.Append(Encoding.UTF8.GetString(buf, 0, n));
                        string txt = pendiente.ToString();
                        int fin = 0;
                        foreach (Match m in mensaje.Matches(txt))
                        {
                            string capa = m.Groups[1].Value;
                            BeginInvoke((Action)(() => MostrarCapa(capa)));
                            fin = m.Index + m.Length;
                        }
                        pendiente.Remove(0, fin);
                        if (pendiente.Length > 65536) pendiente.Clear();
                    }
                }
            }
            catch { }
            try { BeginInvoke((Action)Ocultar); } catch { }
            Thread.Sleep(2000);
        }
    }

    [STAThread]
    static void Main()
    {
        bool nuevo;
        using (Mutex m = new Mutex(true, "KanataIndicadorCapa", out nuevo))
        {
            if (!nuevo) return;   // ya hay un indicador abierto
            SetProcessDPIAware();
            Application.EnableVisualStyles();
            Indicador f = new Indicador();
            IntPtr crear = f.Handle;   // crea la ventana sin mostrarla
            Thread hilo = new Thread(f.Escuchar);
            hilo.IsBackground = true;
            hilo.Start();
            Application.Run();
        }
    }
}
