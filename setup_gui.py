#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk
import subprocess
import threading
import queue
import os
import re
import platform

ANSI_PATTERN = re.compile(r'\x1b\[[0-9;]*m')

# ═══════════════════════════════════════════════════════════════════════════════
# COLORES ESTILO FEDORA
# ═══════════════════════════════════════════════════════════════════════════════
LIGHT_THEME = {
    "bg": "#ffffff",
    "surface": "#f6f6f6",
    "surface_hover": "#eeeeee",
    "primary": "#3c6eb4",
    "primary_hover": "#2d5a8f",
    "text": "#1a1a1a",
    "text_secondary": "#6c757d",
    "border": "#e0e0e0",
    "success": "#2e7d32",
    "error": "#c62828",
    "warning": "#f9a825",
    "console_bg": "#1a1a1a",
    "console_fg": "#e0e0e0",
    "card_bg": "#ffffff",
    "header_bg": "#3c6eb4",
}

DARK_THEME = {
    "bg": "#1a1a1a",
    "surface": "#2d2d2d",
    "surface_hover": "#3d3d3d",
    "primary": "#4a90d9",
    "primary_hover": "#5ba0e9",
    "text": "#e0e0e0",
    "text_secondary": "#9a9a9a",
    "border": "#404040",
    "success": "#4caf50",
    "error": "#ef5350",
    "warning": "#ffb74d",
    "console_bg": "#0d0d0d",
    "console_fg": "#c0c0c0",
    "card_bg": "#2d2d2d",
    "header_bg": "#4a90d9",
}


class SetupApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fedora Setup Pro")
        self.root.geometry("1000x900")
        self.root.minsize(800, 700)
        
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.password = ""
        self.is_running = False
        self.dark_mode = False
        self.colors = LIGHT_THEME.copy()
        
        self.log_queue = queue.Queue()
        self.root.after(100, self._check_log_queue)
        
        self.vars = {}
        self._create_vars()
        self._setup_ui()
        self._check_system()
        
        self.root.bind("<Configure>", self._on_resize)
    
    def _on_resize(self, event=None):
        pass
    
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
        # Main container with grid
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(0, weight=1)
        
        # Header
        self._create_header()
        
        # Content area (two columns)
        self.content = tk.Frame(self.root, bg=self.colors["bg"])
        self.content.grid(row=1, column=0, sticky="nsew", padx=20, pady=15)
        self.content.grid_rowconfigure(0, weight=1)
        self.content.grid_columnconfigure(0, weight=1)
        
        # Left panel - Options
        self.left_panel = tk.Frame(self.content, bg=self.colors["bg"])
        self.left_panel.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        
        # Right panel - Console
        self.right_panel = tk.Frame(self.content, bg=self.colors["console_bg"])
        self.right_panel.grid(row=0, column=1, sticky="nsew", padx=(10, 0))
        self.right_panel.grid_rowconfigure(1, weight=1)
        
        self._build_options()
        self._build_console()
        
        # Footer
        self._build_footer()
    
    def _create_header(self):
        header = tk.Frame(self.root, bg=self.colors["header_bg"], height=80)
        header.grid(row=0, column=0, sticky="ew")
        header.grid_propagate(False)
        
        inner = tk.Frame(header, bg=self.colors["header_bg"])
        inner.place(relx=0.5, rely=0.5, anchor="center")
        
        # Logo
        logo = tk.Label(inner, text="◉", font=("Segoe UI", 28), 
                       bg=self.colors["header_bg"], fg="white")
        logo.pack(side="left", padx=(0, 15))
        
        # Title block
        title_frame = tk.Frame(inner, bg=self.colors["header_bg"])
        title_frame.pack(side="left")
        
        tk.Label(title_frame, text="Fedora Setup Pro",
                font=("Segoe UI", 22, "bold"), bg=self.colors["header_bg"], 
                fg="white").pack(anchor="w")
        tk.Label(title_frame, text="Configura tu Huawei Matebook 14",
                font=("Segoe UI", 11), bg=self.colors["header_bg"], 
                fg="#b0c4de").pack(anchor="w")
        
        # Theme toggle
        self.theme_btn = tk.Button(inner, text="🌙", font=("Segoe UI", 16),
                                 bg=self.colors["header_bg"], fg="white", relief="flat",
                                 cursor="hand2", command=self._toggle_theme,
                                 activebackground=self.colors["primary_hover"],
                                 width=3, height=1)
        self.theme_btn.pack(side="right", padx=(15, 0))
    
    def _build_options(self):
        # Scrollable frame setup
        canvas = tk.Canvas(self.left_panel, bg=self.colors["bg"], 
                          highlightthickness=0, bd=0)
        scrollbar = ttk.Scrollbar(self.left_panel, orient="vertical", command=canvas.yview)
        scroll_frame = tk.Frame(canvas, bg=self.colors["bg"])
        
        scroll_frame.bind("<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        # Toolbar inside scroll frame
        toolbar = tk.Frame(scroll_frame, bg=self.colors["surface"], pady=10, padx=15)
        toolbar.pack(fill="x", pady=(0, 15))
        
        tk.Label(toolbar, text="Componentes", font=("Segoe UI", 12, "bold"),
                bg=self.colors["surface"], fg=self.colors["primary"]).pack(side="left")
        
        btn_frame = tk.Frame(toolbar, bg=self.colors["surface"])
        btn_frame.pack(side="right")
        
        self._make_btn(btn_frame, "Todo", self._select_all, self.colors["surface"]).pack(side="left", padx=2)
        self._make_btn(btn_frame, "Ninguno", self._select_none, self.colors["surface"]).pack(side="left", padx=2)
        self._make_btn(btn_frame, "Recomendado", self._select_recommended, self.colors["primary"], "white").pack(side="left", padx=2)
        
        # Sections
        sections = [
            ("🐚 Terminal Pro", "term", [
                ("term_pkg", "Paquetes base", "git, curl, wget, unzip"),
                ("term_eza", "Herramientas modernas", "eza, bat, fzf, zoxide"),
                ("term_font", "Fuente JetBrainsMono Nerd", "Tipografía para código"),
                ("term_zsh", "Zsh + Oh My Zsh", "Shell moderno con plugins"),
                ("term_starship", "Starship Prompt", "Prompt minimalista"),
            ]),
            ("🍎 Temas macOS", "theme", [
                ("theme_dep", "Dependencias", "sassc, glib, ImageMagick..."),
                ("theme_gtk", "Tema GTK WhiteSur", "Light + Dark"),
                ("theme_icons", "Iconos", "WhiteSur + MacTahoe"),
                ("theme_gdm", "Pantalla de Login", "GDM con MacTahoe"),
                ("theme_firefox", "Tema Firefox", "WhiteSur Firefox"),
                ("theme_sync", "Sincronización Dark/Light", "Auto-switch de temas"),
            ]),
            ("🛠️ Aplicaciones", "app", [
                ("app_vscode", "Visual Studio Code", "Editor con config optimizada"),
                ("app_git", "Git + SSH", "Configuración y clave GitHub"),
                ("app_intel", "Fix Intel Flicker", "Corregir parpadeo pantalla"),
                ("app_ext", "Extensiones GNOME", "Guía de extensiones"),
            ]),
        ]
        
        for section_title, prefix, options in sections:
            self._create_section(scroll_frame, section_title, options)
        
        # Summary
        self.summary_label = tk.Label(scroll_frame, text="✓ 0 componentes seleccionados",
                                     font=("Segoe UI", 10), bg=self.colors["bg"],
                                     fg=self.colors["text_secondary"], pady=12)
        self.summary_label.pack()
        self._update_summary()
        
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
    
    def _make_btn(self, parent, text, cmd, bg, fg=None):
        btn = tk.Button(parent, text=text, command=cmd, bg=bg,
                      fg=fg or self.colors["text"], font=("Segoe UI", 9),
                      relief="solid", borderwidth=1, cursor="hand2", padx=12, pady=5)
        return btn
    
    def _create_section(self, parent, title, options):
        card = tk.Frame(parent, bg=self.colors["card_bg"],
                       highlightbackground=self.colors["border"],
                       highlightthickness=1, bd=0)
        card.pack(fill="x", pady=5, ipady=5)
        
        # Section header
        header = tk.Frame(card, bg=self.colors["card_bg"])
        header.pack(fill="x", padx=15, pady=(12, 5))
        
        tk.Label(header, text=title, font=("Segoe UI", 12, "bold"),
                bg=self.colors["card_bg"], fg=self.colors["primary"]).pack(side="left")
        
        # Options
        options_frame = tk.Frame(card, bg=self.colors["card_bg"])
        options_frame.pack(fill="x", padx=15, pady=(0, 10))
        
        for var_key, opt_title, opt_desc in options:
            row = tk.Frame(options_frame, bg=self.colors["card_bg"])
            row.pack(fill="x", pady=2)
            
            cb = tk.Checkbutton(row, variable=self.vars[var_key],
                              bg=self.colors["card_bg"], activebackground=self.colors["card_bg"],
                              fg=self.colors["primary"], selectcolor=self.colors["bg"],
                              command=self._update_summary)
            cb.pack(side="left", padx=(0, 8))
            
            tk.Label(row, text=opt_title, font=("Segoe UI", 10),
                    bg=self.colors["card_bg"], fg=self.colors["text"]).pack(side="left")
            
            tk.Label(row, text=opt_desc, font=("Segoe UI", 8),
                    bg=self.colors["card_bg"], fg=self.colors["text_secondary"]).pack(side="right")
    
    def _build_console(self):
        # Console header
        header = tk.Frame(self.right_panel, bg="#252525", pady=8, padx=12)
        header.grid(row=0, column=0, sticky="ew")
        
        tk.Label(header, text="📟 Consola", font=("Segoe UI", 11, "bold"),
                bg="#252525", fg="#c0c0c0").pack(side="left")
        
        self.progress_label = tk.Label(header, text="", font=("Segoe UI", 9),
                                      bg="#252525", fg=self.colors["success"])
        self.progress_label.pack(side="right")
        
        # Console text
        self.console = tk.Text(self.right_panel, bg=self.colors["console_bg"],
                              fg=self.colors["console_fg"],
                              font=("Cascadia Code", 10), wrap="word",
                              state="normal", relief="flat", padx=10, pady=10,
                              insertbackground="white", bd=0)
        self.console.grid(row=1, column=0, sticky="nsew")
        
        # Tags
        for tag, color in [("blue", "#58a6ff"), ("green", "#3fb950"),
                          ("yellow", "#d29922"), ("red", "#f85149"), ("dim", "#6c757d")]:
            self.console.tag_config(tag, foreground=color)
        
        # Bindings
        self.console.bind("<Control-c>", lambda e: self._copy_selection())
        self.console.bind("<Control-a>", lambda e: self._select_all_text() or "break")
        
        self.context_menu = tk.Menu(self.right_panel, tearoff=0, bg="#2d2d2d", fg="white")
        self.context_menu.add_command(label="Copiar", command=self._copy_selection)
        self.context_menu.add_command(label="Seleccionar todo", command=self._select_all_text)
        self.console.bind("<Button-3>", lambda e: self.context_menu.post(e.x_root, e.y_root))
    
    def _build_footer(self):
        footer = tk.Frame(self.root, bg=self.colors["surface"], height=60)
        footer.grid(row=2, column=0, sticky="ew")
        footer.grid_propagate(False)
        
        inner = tk.Frame(footer, bg=self.colors["surface"])
        inner.place(relx=0.5, rely=0.5, anchor="center")
        
        self.status_label = tk.Label(inner, text="● Listo",
                                     font=("Segoe UI", 10, "bold"),
                                     bg=self.colors["surface"], fg=self.colors["success"])
        self.status_label.pack(side="left", padx=(0, 30))
        
        self.install_btn = tk.Button(inner, text="⚡ Instalar Fedora",
                                    command=self._on_install_click,
                                    bg=self.colors["primary"], fg="white",
                                    font=("Segoe UI", 12, "bold"),
                                    relief="flat", padx=30, pady=10, cursor="hand2",
                                    activebackground=self.colors["primary_hover"])
        self.install_btn.pack(side="right")
    
    def _toggle_theme(self):
        self.dark_mode = not self.dark_mode
        self.colors = DARK_THEME.copy() if self.dark_mode else LIGHT_THEME.copy()
        self.theme_btn.config(text="☀️" if self.dark_mode else "🌙")
        self._refresh_ui()
    
    def _refresh_ui(self):
        # Rebuild entire UI for clean theme switching
        for widget in self.root.winfo_children():
            widget.destroy()
        self._setup_ui()
        self._check_system()
    
    def _check_system(self):
        info = f"{platform.system()} {platform.release()}"
        try:
            r = subprocess.run(['lsb_release', '-d'], capture_output=True, text=True)
            if r.returncode == 0:
                info = r.stdout.strip().split(':', 1)[1].strip()
        except:
            pass
        self._append_log(f"  Sistema: {info}\n", "dim")
        self._append_log("  Selecciona los componentes a instalar...\n\n", "dim")
    
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
            from tkinter import messagebox
            messagebox.showwarning("Sin selección", "Selecciona al menos un componente.")
            return
        
        from tkinter import simpledialog
        self.password = simpledialog.askstring("Autenticación",
                                              "Introduce tu contraseña de sudo:", show='*')
        if not self.password:
            return
        
        self._start_installation()
    
    def _start_installation(self):
        self.is_running = True
        self.install_btn.config(state="disabled", text="🔄 Ejecutando...")
        self.status_label.config(text="● Instalando...", fg=self.colors["warning"])
        
        self.console.config(state="normal")
        self.console.delete(1.0, "end")
        self.console.config(state="disabled")
        
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
            
            if self.password:
                proc.stdin.write(self.password + "\n")
                proc.stdin.flush()
            
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
            self._append_log(f"  Error: {e}\n", "red")
    
    def _append_log(self, text, tag=None):
        def append():
            self.console.config(state="normal")
            parts = ANSI_PATTERN.split(text)
            for part in parts:
                if part:
                    self.console.insert("end", part, tag if tag else "dim")
            self.console.see("end")
            self.console.config(state="disabled")
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
        self.install_btn.config(state="normal", text="⚡ Instalar Fedora")
        self.status_label.config(text="● Completado", fg=self.colors["success"])
        self.progress_label.config(text="")
        from tkinter import messagebox
        messagebox.showinfo("Completado",
                          "Instalación finalizada.\nCierra sesión para aplicar cambios.")


if __name__ == "__main__":
    root = tk.Tk()
    app = SetupApp(root)
    root.mainloop()
