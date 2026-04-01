#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import subprocess
import threading
import queue
import os
import re
import platform

ANSI_PATTERN = re.compile(r'\x1b\[[0-9;]*m')

class SetupApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fedora Setup Pro - Huawei Matebook 14")
        self.root.geometry("1000x800")
        self.root.minsize(900, 700)
        self.root.configure(bg="#1a1a2e")

        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.password = ""
        self.is_running = False

        self.log_queue = queue.Queue()
        self.root.after(100, self._check_log_queue)

        self.vars = {}
        self._create_vars()
        self._setup_ui()
        self._check_system()

    def _create_vars(self):
        vars_data = [
            ("term_pkg", True), ("term_eza", True), ("term_font", True),
            ("term_zsh", True), ("term_starship", True),
            ("theme_dep", True), ("theme_gtk", True), ("theme_icons", True),
            ("theme_gdm", True), ("theme_firefox", True), ("theme_sync", True),
            ("app_vscode", True), ("app_git", True),
            ("app_intel", False), ("app_ext", True),
        ]
        for name, default in vars_data:
            self.vars[name] = tk.BooleanVar(value=default)

    def _setup_ui(self):
        main = tk.Frame(self.root, bg="#1a1a2e")
        main.pack(fill=tk.BOTH, expand=True)

        header = tk.Frame(main, bg="#1a1a2e", pady=10, padx=20)
        header.pack(fill=tk.X)
        tk.Label(header, text="Fedora Setup Pro", bg="#1a1a2e", fg="#eaeaea", 
                 font=("Segoe UI", 20, "bold")).pack(side=tk.LEFT)
        tk.Label(header, text="Huawei Matebook 14", bg="#1a1a2e", fg="#e94560", 
                 font=("Segoe UI", 11)).pack(side=tk.LEFT, padx=10, pady=5)
        
        self.status_label = tk.Label(header, text="● Listo", bg="#1a1a2e", fg="#4ecca3", 
                                      font=("Segoe UI", 10, "bold"))
        self.status_label.pack(side=tk.RIGHT, padx=10)

        content = tk.Frame(main, bg="#1a1a2e")
        content.pack(fill=tk.BOTH, expand=True, padx=20, pady=(0, 10))

        left = tk.Frame(content, bg="#1a1a2e")
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        right = tk.Frame(content, bg="#0d1117", width=350)
        right.pack(side=tk.RIGHT, fill=tk.BOTH, padx=(10, 0))

        self._build_toolbar(left)
        self._build_options(left)
        self._build_console(right)
        self._build_footer(main)

    def _build_toolbar(self, parent):
        toolbar = tk.Frame(parent, bg="#16213e", pady=8, padx=15)
        toolbar.pack(fill=tk.X, pady=(0, 10))

        tk.Label(toolbar, text="Componentes", bg="#16213e", fg="#e94560", 
                 font=("Segoe UI", 12, "bold")).pack(side=tk.LEFT)

        btn_frame = tk.Frame(toolbar, bg="#16213e")
        btn_frame.pack(side=tk.RIGHT)

        for txt, cmd, color in [
            ("Todo", self._select_all, "#0f3460"),
            ("Ninguno", self._select_none, "#2d2d2d"),
            ("Recomendado", self._select_recommended, "#4ecca3")
        ]:
            b = tk.Button(btn_frame, text=txt, command=cmd, bg=color, fg="white",
                         font=("Segoe UI", 9, "bold" if color == "#4ecca3" else "normal"),
                         relief="flat", padx=12, pady=5, cursor="hand2")
            b.pack(side=tk.LEFT, padx=3)

    def _build_options(self, parent):
        sections = [
            ("🐚 Terminal Pro", [
                ("term_pkg", "Paquetes base", "git, curl, wget, unzip"),
                ("term_eza", "Herramientas modernas", "eza, bat, fzf, zoxide"),
                ("term_font", "Fuente JetBrainsMono Nerd", "Tipografía para código"),
                ("term_zsh", "Zsh + Oh My Zsh", "Shell moderno con plugins"),
                ("term_starship", "Starship Prompt", "Prompt minimalista"),
            ]),
            ("🍎 Temas macOS", [
                ("theme_dep", "Dependencias", "sassc, glib, ImageMagick..."),
                ("theme_gtk", "Tema GTK WhiteSur", "Light + Dark"),
                ("theme_icons", "Iconos", "WhiteSur + MacTahoe"),
                ("theme_gdm", "Pantalla de Login", "GDM con MacTahoe"),
                ("theme_firefox", "Tema Firefox", "WhiteSur Firefox"),
                ("theme_sync", "Sincronización Dark/Light", "Auto-switch de temas"),
            ]),
            ("🛠️ Aplicaciones", [
                ("app_vscode", "Visual Studio Code", "Editor con config optimizada"),
                ("app_git", "Git + SSH", "Configuración y clave GitHub"),
                ("app_intel", "Fix Intel Flicker", "Corregir parpadeo pantalla"),
                ("app_ext", "Extensiones GNOME", "Guía de extensiones"),
            ]),
        ]

        canvas = tk.Canvas(parent, bg="#1a1a2e", highlightthickness=0)
        scrollbar = ttk.Scrollbar(parent, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=scrollbar.set)

        scroll_frame = tk.Frame(canvas, bg="#1a1a2e")
        scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scroll_frame, anchor="nw")

        for section_title, options in sections:
            card = tk.Frame(scroll_frame, bg="#16213e", padx=15, pady=12,
                           highlightbackground="#0f3460", highlightthickness=1)
            card.pack(fill=tk.X, padx=5, pady=5)

            tk.Label(card, text=section_title, bg="#16213e", fg="#e94560",
                    font=("Segoe UI", 12, "bold")).pack(anchor=tk.W, pady=(0, 10))

            for var_key, title, desc in options:
                row = tk.Frame(card, bg="#16213e")
                row.pack(fill=tk.X, pady=3)

                cb = ttk.Checkbutton(row, variable=self.vars[var_key])
                cb.pack(side=tk.LEFT, padx=(0, 10))

                tk.Label(row, text=title, bg="#16213e", fg="#eaeaea",
                        font=("Segoe UI", 10)).pack(side=tk.LEFT)
                tk.Label(row, text=desc, bg="#16213e", fg="#6c757d",
                        font=("Segoe UI", 8)).pack(side=tk.RIGHT)

        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.summary_label = tk.Label(parent, text="", bg="#1a1a2e", fg="#a0a0a0",
                                     font=("Segoe UI", 10), pady=10)
        self.summary_label.pack()
        self._update_summary()

    def _build_console(self, parent):
        header = tk.Frame(parent, bg="#161b22", pady=8, padx=10)
        header.pack(fill=tk.X)
        tk.Label(header, text="📟 Consola", bg="#161b22", fg="#eaeaea",
                 font=("Segoe UI", 11, "bold")).pack(side=tk.LEFT)
        self.progress_label = tk.Label(header, text="", bg="#161b22", fg="#4ecca3",
                                       font=("Segoe UI", 9))
        self.progress_label.pack(side=tk.RIGHT)

        self.console = tk.Text(parent, bg="#0d1117", fg="#c9d1d9",
                               font=("Cascadia Code", 10), wrap=tk.WORD,
                               state=tk.NORMAL, relief="flat", padx=10, pady=10,
                               selectbackground="#264f78", selectforeground="#ffffff",
                               inactiveselectbackground="#264f78")
        self.console.pack(fill=tk.BOTH, expand=True)
        
        self._copy_menu = tk.Menu(parent, tearoff=0, bg="#1a1a2e", fg="#eaeaea")
        self._copy_menu.add_command(label="Copiar", command=self._copy_selection)
        self._copy_menu.add_command(label="Seleccionar todo", command=self._select_all_text)
        
        self.console.bind("<Control-c>", lambda e: self._copy_selection())
        self.console.bind("<Control-a>", lambda e: self._select_all_text() or "break")
        self.console.bind("<Button-3>", lambda e: self._copy_menu.post(e.x_root, e.y_root))

        for tag, color in [("blue", "#58a6ff"), ("green", "#3fb950"),
                          ("yellow", "#d29922"), ("red", "#f85149"), ("dim", "#6c757d")]:
            self.console.tag_config(tag, foreground=color)

    def _build_footer(self, parent):
        footer = tk.Frame(parent, bg="#16213e", pady=12, padx=20)
        footer.pack(fill=tk.X, side=tk.BOTTOM)

        self.install_btn = tk.Button(footer, text="⚡ Iniciar Instalación",
                                    command=self._on_install_click,
                                    bg="#e94560", fg="white",
                                    font=("Segoe UI", 12, "bold"),
                                    relief="flat", padx=30, pady=12, cursor="hand2")
        self.install_btn.pack(side=tk.RIGHT)

    def _check_system(self):
        info = f"{platform.system()} {platform.release()}"
        try:
            r = subprocess.run(['lsb_release', '-d'], capture_output=True, text=True)
            if r.returncode == 0:
                info = r.stdout.strip().split(':', 1)[1].strip()
        except:
            pass
        self._append_log(f"  Sistema: {info}\n", "dim")
        self._append_log("  Esperando selección...\n\n", "dim")

    def _select_all(self):
        for v in self.vars.values():
            v.set(True)
        self._update_summary()

    def _select_none(self):
        for v in self.vars.values():
            v.set(False)
        self._update_summary()

    def _select_recommended(self):
        self._select_all()
        self.vars["app_intel"].set(False)
        self._update_summary()

    def _update_summary(self):
        count = sum(1 for v in self.vars.values() if v.get())
        self.summary_label.config(text=f"✓ {count} componentes seleccionados")

    def _on_install_click(self):
        if self.is_running:
            return

        count = sum(1 for v in self.vars.values() if v.get())
        if count == 0:
            messagebox.showwarning("Sin selección", "Selecciona al menos un componente.")
            return

        self.password = simpledialog.askstring("Autenticación",
                                              "Introduce tu contraseña de sudo:",
                                              show='*')
        if not self.password:
            return

        self._start_installation()

    def _start_installation(self):
        self.is_running = True
        self.install_btn.config(state=tk.DISABLED, text="🔄 Ejecutando...")
        self.status_label.config(text="● Instalando...", fg="#ffc107")

        self.console.config(state=tk.NORMAL)
        self.console.delete(1.0, tk.END)
        self.console.config(state=tk.DISABLED)

        thread = threading.Thread(target=self._run_installation, daemon=True)
        thread.start()

    def _run_installation(self):
        self._append_log("══ Iniciando instalación ═══════════\n\n", "blue")

        term_flags = self._get_flags("term_", ["pkg", "eza", "font", "zsh", "starship"])
        if any(self.vars[f"term_{x}"].get() for x in ["pkg", "eza", "font", "zsh", "starship"]):
            self._run_script("scripts/01-terminal.sh", term_flags, "TERMINAL")

        theme_flags = self._get_flags("theme_", ["dep", "gtk", "icons", "gdm", "firefox", "sync"])
        if any(self.vars[f"theme_{x}"].get() for x in ["dep", "gtk", "icons", "gdm", "firefox", "sync"]):
            self._run_script("scripts/04-gnome-theme.sh", theme_flags, "TEMAS macOS")

        if self.vars["app_vscode"].get():
            self._run_script("scripts/02-vscode.sh", [], "VS CODE")

        if self.vars["app_git"].get():
            self._run_script("scripts/03-git.sh", [], "GIT + SSH")

        if self.vars["app_intel"].get():
            self._run_script("scripts/05-intel-fix.sh", [], "INTEL FIX")

        if self.vars["app_ext"].get():
            self._run_script("scripts/06-extensions.sh", [], "EXTENSIONES GNOME")

        self._append_log("\n══ INSTALACIÓN COMPLETADA ═══════\n", "green")
        self._append_log("  Cierra sesión para aplicar cambios.\n\n", "yellow")
        self.root.after(0, self._on_complete)

    def _get_flags(self, prefix, keys):
        return [f"--skip-{k}" for k in keys if not self.vars[f"{prefix}{k}"].get()]

    def _run_script(self, script, flags, name):
        self._append_log(f"\n══ {name} ═══════════════════\n", "blue")
        self.root.after(0, lambda: self.progress_label.config(text=f"Ejecutando: {name}"))

        script_path = os.path.join(self.script_dir, script)
        cmd = ["sudo", "-S", "bash", script_path] + flags
        
        try:
            proc = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                   text=True, bufsize=1, cwd=self.script_dir)
            
            # Enviar contraseña al stdin
            if self.password:
                proc.stdin.write(self.password + "\n")
                proc.stdin.flush()
            
            # Leer output línea por línea
            for line in proc.stdout:
                line = line.rstrip()
                if line and "[sudo] password for" not in line:
                    self._append_log(line + "\n")
            
            proc.stdin.close()
            proc.stdout.close()
            return_code = proc.wait()
            
            if return_code != 0:
                self._append_log(f"\n  ⚠️  {name} finalizó con código {return_code}\n", "yellow")
                
        except Exception as e:
            self._append_log(f"  Error ejecutando {name}: {e}\n", "red")

    def _append_log(self, text, tag=None):
        def append():
            self.console.config(state=tk.NORMAL)
            parts = ANSI_PATTERN.split(text)
            for part in parts:
                if part:
                    self.console.insert(tk.END, part, tag if tag else "dim")
            self.console.see(tk.END)
            self.console.config(state=tk.DISABLED)
        self.root.after(0, append)

    def _copy_selection(self):
        try:
            selection = self.console.selection_get()
            self.root.clipboard_clear()
            self.root.clipboard_append(selection)
        except:
            pass

    def _select_all_text(self):
        self.console.tag_add("sel", "1.0", "end")

    def _check_log_queue(self):
        try:
            while True:
                msg = self.log_queue.get_nowait()
                self._append_log(msg)
        except queue.Empty:
            pass
        finally:
            self.root.after(100, self._check_log_queue)

    def _on_complete(self):
        self.is_running = False
        self.install_btn.config(state=tk.NORMAL, text="⚡ Iniciar Instalación")
        self.status_label.config(text="● Completado", fg="#4ecca3")
        self.progress_label.config(text="")
        messagebox.showinfo("Completado",
                          "Instalación finalizada.\nCierra sesión para aplicar cambios.")

if __name__ == "__main__":
    root = tk.Tk()
    app = SetupApp(root)
    root.mainloop()
