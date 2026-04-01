#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, simpledialog
import subprocess
import threading
import queue
import os
import re

# ==============================================================================
# setup_gui.py - Versión Granular Pro
# ==============================================================================

class SetupApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fedora 43 Setup - Huawei Matebook 14")
        self.root.geometry("900x750")
        self.root.resizable(True, True)

        self.log_queue = queue.Queue()
        self.root.after(100, self._check_log_queue)

        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.password = ""
        
        # Variables de selección granular
        self.vars = {
            # Terminal
            "term_pkg": tk.BooleanVar(value=True),
            "term_eza": tk.BooleanVar(value=True),
            "term_font": tk.BooleanVar(value=True),
            "term_zsh": tk.BooleanVar(value=True),
            "term_starship": tk.BooleanVar(value=True),
            
            # Themes
            "theme_dep": tk.BooleanVar(value=True),
            "theme_gtk": tk.BooleanVar(value=True),
            "theme_icons": tk.BooleanVar(value=True),
            "theme_gdm": tk.BooleanVar(value=True),
            "theme_firefox": tk.BooleanVar(value=True),
            "theme_sync": tk.BooleanVar(value=True),
            
            # Apps
            "app_vscode": tk.BooleanVar(value=True),
            "app_git": tk.BooleanVar(value=True),
            "app_intel": tk.BooleanVar(value=False),
            "app_ext": tk.BooleanVar(value=True),
        }

        self.setup_ui()
        self.setup_styles()

    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('clam')
        style.configure("Header.TLabel", font=("Inter", 16, "bold"))
        style.configure("SubHeader.TLabelframe.Label", font=("Inter", 11, "bold"), foreground="#3b82f6")

    def setup_ui(self):
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)

        header = ttk.Label(main_frame, text="🚀 Configuración Modular de Fedora", style="Header.TLabel")
        header.pack(pady=(0, 5))

        # Canvas con Scroll para las opciones por si hay muchas
        container = ttk.Frame(main_frame)
        container.pack(fill=tk.BOTH, expand=True)

        # Usaremos marcos divididos para organizar
        options_frame = ttk.Frame(container)
        options_frame.pack(fill=tk.X, pady=10)

        # --- SECCIÓN TERMINAL ---
        term_frame = ttk.LabelFrame(options_frame, text=" 🐚 Terminal Pro ", style="SubHeader.TLabelframe", padding=10)
        term_frame.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        ttk.Checkbutton(term_frame, text="Paquetes base (git, curl, wget...)", variable=self.vars["term_pkg"]).pack(anchor=tk.W)
        ttk.Checkbutton(term_frame, text="Herramientas modernas (eza, bat, fzf...)", variable=self.vars["term_eza"]).pack(anchor=tk.W)
        ttk.Checkbutton(term_frame, text="Fuente JetBrainsMono Nerd", variable=self.vars["term_font"]).pack(anchor=tk.W)
        ttk.Checkbutton(term_frame, text="Zsh + Oh My Zsh + Plugins", variable=self.vars["term_zsh"]).pack(anchor=tk.W)
        ttk.Checkbutton(term_frame, text="Prompt Moderno (Starship)", variable=self.vars["term_starship"]).pack(anchor=tk.W)

        # --- SECCIÓN TEMAS ---
        theme_frame = ttk.LabelFrame(options_frame, text=" 🍎 Entorno Visual macOS ", style="SubHeader.TLabelframe", padding=10)
        theme_frame.grid(row=0, column=1, sticky="nsew", padx=5, pady=5)
        
        ttk.Checkbutton(theme_frame, text="Dependencias del tema", variable=self.vars["theme_dep"]).pack(anchor=tk.W)
        ttk.Checkbutton(theme_frame, text="Tema GTK (WhiteSur Light/Dark)", variable=self.vars["theme_gtk"]).pack(anchor=tk.W)
        ttk.Checkbutton(theme_frame, text="Iconos (WhiteSur & MacTahoe)", variable=self.vars["theme_icons"]).pack(anchor=tk.W)
        ttk.Checkbutton(theme_frame, text="Pantalla de Inicio (GDM)", variable=self.vars["theme_gdm"]).pack(anchor=tk.W)
        ttk.Checkbutton(theme_frame, text="Tema de Firefox", variable=self.vars["theme_firefox"]).pack(anchor=tk.W)
        ttk.Checkbutton(theme_frame, text="Sincronización de Modo Oscuro", variable=self.vars["theme_sync"]).pack(anchor=tk.W)

        # --- SECCIÓN APPS ---
        app_frame = ttk.LabelFrame(options_frame, text=" 🛠️ Aplicaciones & Sistema ", style="SubHeader.TLabelframe", padding=10)
        app_frame.grid(row=1, column=0, columnspan=2, sticky="nsew", padx=5, pady=5)
        
        inner_app_frame = ttk.Frame(app_frame)
        inner_app_frame.pack(fill=tk.X)
        
        ttk.Checkbutton(inner_app_frame, text="Visual Studio Code + Configuración", variable=self.vars["app_vscode"]).pack(side=tk.LEFT, padx=10)
        ttk.Checkbutton(inner_app_frame, text="Git Global + Clave SSH", variable=self.vars["app_git"]).pack(side=tk.LEFT, padx=10)
        ttk.Checkbutton(inner_app_frame, text="Fix Intel Flicker", variable=self.vars["app_intel"]).pack(side=tk.LEFT, padx=10)
        ttk.Checkbutton(inner_app_frame, text="Extensiones GNOME", variable=self.vars["app_ext"]).pack(side=tk.LEFT, padx=10)

        # Consola de Salida
        terminal_label = ttk.Label(main_frame, text="📟 Consola de Salida:", font=("Inter", 10, "bold"))
        terminal_label.pack(anchor=tk.W, pady=(10, 2))

        self.console = scrolledtext.ScrolledText(main_frame, height=12, font=("JetBrainsMono Nerd Font", 9), bg="#1e1e1e", fg="#d4d4d4", padx=10, pady=10)
        self.console.pack(fill=tk.BOTH, expand=True)
        self.console.tag_config("blue", foreground="#3b82f6", font=("JetBrainsMono Nerd Font", 9, "bold"))
        self.console.tag_config("green", foreground="#22c55e", font=("JetBrainsMono Nerd Font", 9, "bold"))
        self.console.tag_config("yellow", foreground="#eab308")
        self.console.tag_config("red", foreground="#ef4444", font=("JetBrainsMono Nerd Font", 9, "bold"))
        self.console.tag_config("bold", font=("JetBrainsMono Nerd Font", 9, "bold"))

        # Pie de página
        btn_frame = ttk.Frame(main_frame, padding="10")
        btn_frame.pack(fill=tk.X)
        self.start_btn = ttk.Button(btn_frame, text="⚡ Iniciar Instalación Personalizada", command=self.run_install)
        self.start_btn.pack(side=tk.RIGHT)

    def log(self, text):
        """Encola un mensaje de log para ser procesado por el hilo principal."""
        self.log_queue.put(text)

    def _check_log_queue(self):
        """Procesa los mensajes pendientes en la cola desde el hilo principal."""
        try:
            while True:
                text = self.log_queue.get_nowait()
                self._log_internal(text)
                self.log_queue.task_done()
        except queue.Empty:
            pass
        finally:
            self.root.after(100, self._check_log_queue)

    def _log_internal(self, text):
        self.console.config(state=tk.NORMAL)
        parts = re.split(r'(\x1b\[[0-9;]*m)', text)
        for part in parts:
            if not part: continue
            if part.startswith(r'\x1b[') or part.startswith(r'\033['): continue
            tag = None
            if "══" in part: tag = "blue"
            elif "✔" in part: tag = "green"
            elif "!" in part: tag = "yellow"
            elif "✗" in part: tag = "red"
            elif "·" in part: tag = "bold"
            self.console.insert(tk.END, part, tag)
        self.console.see(tk.END)
        self.console.config(state=tk.DISABLED)

    def run_command(self, cmd_list, password=None):
        final_cmd = ["sudo", "-S"] + cmd_list
        process = subprocess.Popen(final_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1, cwd=self.script_dir)
        if password:
            process.stdin.write(f"{password}\n")
            process.stdin.flush()
        for line in process.stdout:
            if "[sudo] password for" in line: continue
            self.log(line)
        return process.wait()

    def run_worker(self):
        self.log("\n══ Iniciando instalación granular...\n")
        
        # --- 1. Terminal modular ---
        term_flags = []
        if not self.vars["term_pkg"].get(): term_flags.append("--skip-pkg")
        if not self.vars["term_eza"].get(): term_flags.append("--skip-eza")
        if not self.vars["term_font"].get(): term_flags.append("--skip-font")
        if not self.vars["term_zsh"].get(): term_flags.append("--skip-zsh")
        if not self.vars["term_starship"].get(): term_flags.append("--skip-starship")
        
        # Solo ejecutar si algo en terminal está activo o si queremos correr con flags
        # (Nota: En este diseño, si todo está desmarcado, no corremos el script)
        any_term = any([self.vars[f"term_{x}"].get() for x in ["pkg","eza","font","zsh","starship"]])
        if any_term:
            self.log("\n══ Configurando TERMINAL ═══════════════\n")
            self.run_command(["bash", "scripts/01-terminal.sh"] + term_flags, self.password)

        # --- 2. Temas modulares ---
        theme_flags = []
        if not self.vars["theme_dep"].get(): theme_flags.append("--skip-dep")
        if not self.vars["theme_gtk"].get(): theme_flags.append("--skip-gtk")
        if not self.vars["theme_icons"].get(): theme_flags.append("--skip-icons")
        if not self.vars["theme_gdm"].get(): theme_flags.append("--skip-gdm")
        if not self.vars["theme_firefox"].get(): theme_flags.append("--skip-firefox")
        if not self.vars["theme_sync"].get(): theme_flags.append("--skip-sync")
        
        any_theme = any([self.vars[f"theme_{x}"].get() for x in ["dep","gtk","icons","gdm","firefox","sync"]])
        if any_theme:
            self.log("\n══ Configurando TEMAS macOS ════════════\n")
            self.run_command(["bash", "scripts/04-gnome-theme.sh"] + theme_flags, self.password)

        # --- 3. Resto de sección (Legacy/Monofuncionales) ---
        if self.vars["app_vscode"].get():
            self.log("\n══ Instalando VS Studio Code ═══════════\n")
            self.run_command(["bash", "scripts/02-vscode.sh"], self.password)
        
        if self.vars["app_git"].get():
            self.log("\n══ Configurando Git & SSH ══════════════\n")
            self.run_command(["bash", "scripts/03-git.sh"], self.password)
            
        if self.vars["app_intel"].get():
            self.log("\n══ Aplicando Fix Intel Flicker ═════════\n")
            self.run_command(["bash", "scripts/05-intel-fix.sh"], self.password)
            
        if self.vars["app_ext"].get():
            self.log("\n══ Instalando Extensiones GNOME ════════\n")
            self.run_command(["bash", "scripts/06-extensions.sh"], self.password)
        
        self.log("\n══ PROCESO FINALIZADO ════════════════════\n")
        self.root.after(0, lambda: messagebox.showinfo("Completado", "La instalación granular ha finalizado."))
        self.root.after(0, lambda: self.start_btn.config(state=tk.NORMAL))

    def run_install(self):
        self.password = simpledialog.askstring("Autenticación", "Se requieren permisos de administrador.\nIntroduce tu contraseña:", show='*')
        if not self.password: return
        self.start_btn.config(state=tk.DISABLED)
        self.console.config(state=tk.NORMAL); self.console.delete(1.0, tk.END); self.console.config(state=tk.DISABLED)
        thread = threading.Thread(target=self.run_worker)
        thread.start()

if __name__ == "__main__":
    root = tk.Tk()
    app = SetupApp(root)
    root.mainloop()
