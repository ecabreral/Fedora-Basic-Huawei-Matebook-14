#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, simpledialog
import subprocess
import threading
import queue
import os
import re
import platform

ANSI_PATTERN = re.compile(r'\x1b\[[0-9;]*m')

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPTS_DIR = os.path.join(SCRIPT_DIR, "scripts")

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

# ═══════════════════════════════════════════════════════════════════════════════
# MÓDULOS DE INSTALACIÓN
# ═══════════════════════════════════════════════════════════════════════════════
MODULES = [
    {
        "id": "terminal",
        "icon": "🐚",
        "title": "Terminal Pro",
        "desc": "Shell moderno con zsh, Starship y herramientas CLI",
        "script": "01-terminal.sh",
        "sudo": False,
        "recommended": True,
        "prefix": "term_",
        "items": [
            ("Paquetes base", "git, curl, wget, unzip, zsh", "pkg"),
            ("Herramientas modernas", "eza, bat, fzf, zoxide", "eza"),
            ("Fuente JetBrainsMono", "Nerd Font con iconos", "font"),
            ("Zsh + Oh My Zsh", "Shell moderno con plugins", "zsh"),
            ("Starship Prompt", "Prompt minimalista Pastel Powerline", "starship"),
        ],
    },
    {
        "id": "vscode",
        "icon": "💻",
        "title": "Visual Studio Code",
        "desc": "Editor con GitHub Theme y JetBrains Mono",
        "script": "02-vscode.sh",
        "sudo": True,
        "recommended": True,
        "prefix": "vscode_",
        "items": [
            ("VS Code", "Repositorio oficial Microsoft", "main"),
        ],
    },
    {
        "id": "git",
        "icon": "🔐",
        "title": "Git + GitHub",
        "desc": "Config global, clave SSH ed25519",
        "script": "03-git.sh",
        "sudo": False,
        "recommended": True,
        "prefix": "git_",
        "items": [
            ("Config global", "user.name, user.email", "main"),
            ("Clave SSH", "ed25519 para GitHub", "ssh"),
        ],
    },
    {
        "id": "theme",
        "icon": "🎨",
        "title": "Temas GNOME",
        "desc": "Estilo macOS con WhiteSur y MacTahoe",
        "script": "04-gnome-theme.sh",
        "sudo": False,
        "recommended": True,
        "prefix": "theme_",
        "items": [
            ("Dependencias", "sassc, glib, ImageMagick", "dep"),
            ("Tema GTK", "WhiteSur Light + Dark", "gtk"),
            ("Iconos", "WhiteSur + MacTahoe", "icons"),
            ("GDM / Login", "Pantalla de inicio macOS", "gdm"),
            ("Firefox", "WhiteSur Firefox Theme", "firefox"),
        ],
    },
    {
        "id": "intel",
        "icon": "⚡",
        "title": "Intel Fix",
        "desc": "Elimina el parpadeo de pantalla Intel Arc",
        "script": "05-intel-fix.sh",
        "sudo": True,
        "recommended": False,
        "prefix": "intel_",
        "items": [
            ("Parámetros kernel", "i915.enable_psr=0", "main"),
        ],
    },
    {
        "id": "extensions",
        "icon": "🔌",
        "title": "Extensiones GNOME",
        "desc": "Dash to Dock, Magic Lamp, Night Theme Switcher",
        "script": "06-extensions.sh",
        "sudo": False,
        "recommended": True,
        "prefix": "ext_",
        "items": [
            ("Dash to Dock", "Dock estilo macOS", "dash"),
            ("Magic Lamp", "Animación minimizar", "lamp"),
            ("Copyous", "Historial portapapeles", "copy"),
            ("Night Theme Switcher", "Auto claro/oscuro", "night"),
        ],
    },
]


class SetupApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fedora Setup Pro — Huawei Matebook 14")
        self.root.geometry("1100x900")
        self.root.minsize(900, 750)

        self.password = ""
        self.is_running = False
        self.dark_mode = False
        self.colors = LIGHT_THEME.copy()
        self.log_queue = queue.Queue()

        self.vars = {}
        self.module_vars = {}
        self._create_vars()
        self._setup_ui()
        self._check_system()

        self.root.bind("<Configure>", self._on_resize)
        self.root.after(100, self._check_log_queue)

    def _create_vars(self):
        for mod in MODULES:
            var = tk.BooleanVar(value=mod["recommended"])
            self.module_vars[mod["id"]] = var
            for _, _, key in mod["items"]:
                if key != "main":
                    self.vars[f"{mod['prefix']}{key}"] = tk.BooleanVar(value=True)

    def _setup_ui(self):
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(0, weight=1)

        self._create_header()

        self.content = tk.Frame(self.root, bg=self.colors["bg"])
        self.content.grid(row=1, column=0, sticky="nsew", padx=20, pady=15)
        self.content.grid_rowconfigure(0, weight=1)
        self.content.grid_columnconfigure(0, weight=3)
        self.content.grid_columnconfigure(1, weight=2)

        self._build_options()
        self._build_console()
        self._build_footer()

    def _create_header(self):
        header = tk.Frame(self.root, bg=self.colors["header_bg"], height=90)
        header.grid(row=0, column=0, sticky="ew")
        header.grid_propagate(False)

        inner = tk.Frame(header, bg=self.colors["header_bg"])
        inner.pack(fill="x", padx=24, pady=12)

        left = tk.Frame(inner, bg=self.colors["header_bg"])
        left.pack(side="left")

        tk.Label(left, text="◉ Fedora Setup Pro",
                font=("Segoe UI", 20, "bold"), bg=self.colors["header_bg"], fg="white").pack(anchor="w")
        tk.Label(left, text="Huawei Matebook 14",
                font=("Segoe UI", 12), bg=self.colors["header_bg"], fg="#b0c4de").pack(anchor="w")

        right = tk.Frame(inner, bg=self.colors["header_bg"])
        right.pack(side="right")

        for label, cmd in [("Todo", self._select_all), ("Ninguno", self._select_none), ("Recomendado", self._select_recommended)]:
            self._make_toolbar_btn(right, label, cmd).pack(side="left", padx=3)

        tk.Frame(right, bg="#ffffff", width=1, height=22).pack(side="left", padx=10)

        self.theme_btn = tk.Button(right, text="🌙", font=("Segoe UI", 14),
                bg=self.colors["header_bg"], fg="white", relief="flat", cursor="hand2",
                command=self._toggle_theme, activebackground=self.colors["primary_hover"],
                width=3, height=1)
        self.theme_btn.pack(side="left", padx=3)

        tk.Label(header, text="Intel Core Ultra 5 125H  ·  16 GB LPDDR5  ·  14.2\" 2K OLED  ·  Intel Arc  ·  Fedora 43",
                font=("Cascadia Code", 8), bg=self.colors["header_bg"], fg="#aaaaaa", pady=4).pack(side="bottom", fill="x")

    def _build_options(self):
        canvas = tk.Canvas(self.content, bg=self.colors["bg"], highlightthickness=0, bd=0)
        scrollbar = ttk.Scrollbar(self.content, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=scrollbar.set)

        scroll_frame = tk.Frame(canvas, bg=self.colors["bg"])
        scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scroll_frame, anchor="nw")

        for i, mod in enumerate(MODULES):
            row, col = divmod(i, 3)
            card = self._build_card(scroll_frame, mod)
            card.grid(row=row, column=col, padx=8, pady=8, sticky="nsew")
            scroll_frame.columnconfigure(col, weight=1)

        canvas.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        scrollbar.grid(row=0, column=1, sticky="ns")

    def _build_card(self, parent, mod):
        var = self.module_vars[mod["id"]]
        card = tk.Frame(parent, bg=self.colors["card_bg"],
                       highlightbackground=self.colors["border"],
                       highlightthickness=1, bd=0)

        hdr = tk.Frame(card, bg=self.colors["card_bg"])
        hdr.pack(fill="x", padx=14, pady=(12, 6))

        title_row = tk.Frame(hdr, bg=self.colors["card_bg"])
        title_row.pack(fill="x")

        tk.Label(title_row, text=f"{mod['icon']} {mod['title']}",
                font=("Segoe UI", 11, "bold"), bg=self.colors["card_bg"],
                fg=self.colors["primary"]).pack(side="left")

        cb = tk.Checkbutton(title_row, variable=var, bg=self.colors["card_bg"],
                           activebackground=self.colors["card_bg"],
                           fg=self.colors["primary"], selectcolor=self.colors["bg"],
                           command=self._update_summary)
        cb.pack(side="right")

        tk.Label(hdr, text=mod["desc"], font=("Segoe UI", 8),
                fg=self.colors["text_secondary"], bg=self.colors["card_bg"],
                anchor="w", wraplength=200).pack(fill="x", pady=(2, 0))

        tk.Frame(card, bg=self.colors["border"], height=1).pack(fill="x", padx=14)

        items_frame = tk.Frame(card, bg=self.colors["card_bg"])
        items_frame.pack(fill="x", padx=14, pady=(8, 8))

        for item_name, item_desc, key in mod["items"]:
            row = tk.Frame(items_frame, bg=self.colors["card_bg"])
            row.pack(fill="x", pady=1)

            var_key = f"{mod['prefix']}{key}" if key != "main" else None
            sub_var = self.vars.get(var_key) if var_key else None

            if sub_var:
                cb2 = tk.Checkbutton(row, variable=sub_var, bg=self.colors["card_bg"],
                                    activebackground=self.colors["card_bg"],
                                    fg=self.colors["primary"], selectcolor=self.colors["bg"],
                                    highlightthickness=0)
                cb2.pack(side="left", padx=(0, 4))

            tk.Label(row, text=f"▸ {item_name}",
                    font=("Segoe UI", 9, "bold" if key == "main" else "normal"),
                    fg=self.colors["text"], bg=self.colors["card_bg"]).pack(side="left")
            tk.Label(row, text=f"— {item_desc}",
                    font=("Segoe UI", 8), fg=self.colors["text_secondary"],
                    bg=self.colors["card_bg"]).pack(side="right")

        if mod["sudo"]:
            tk.Label(card, text="🔒 requiere sudo", font=("Cascadia Code", 8),
                    fg=self.colors["warning"], bg=self.colors["card_bg"],
                    pady=6).pack(side="left", padx=14, padbottom=6)

        def on_enter(e, c=card):
            c.configure(highlightbackground=self.colors["primary"])
        def on_leave(e, c=card):
            c.configure(highlightbackground=self.colors["border"])
        card.bind("<Enter>", on_enter)
        card.bind("<Leave>", on_leave)

        return card

    def _build_console(self):
        console_frame = tk.Frame(self.content, bg=self.colors["console_bg"])
        console_frame.grid(row=0, column=1, sticky="nsew")

        header = tk.Frame(console_frame, bg="#252525", pady=8, padx=12)
        header.pack(fill="x")
        tk.Label(header, text="📟 Consola de Instalación",
                font=("Segoe UI", 11, "bold"), bg="#252525", fg="#c0c0c0").pack(side="left")
        self.progress_label = tk.Label(header, text="", font=("Segoe UI", 9),
                                      bg="#252525", fg=self.colors["success"])
        self.progress_label.pack(side="right")

        self.console = scrolledtext.ScrolledText(console_frame,
                bg=self.colors["console_bg"], fg=self.colors["console_fg"],
                font=("Cascadia Code", 10), wrap="word", state="normal",
                relief="flat", padx=10, pady=10, insertbackground="white", bd=0)
        self.console.pack(fill="both", expand=True)

        for tag, color in [("info", "#58a6ff"), ("success", "#3fb950"),
                          ("warning", "#d29922"), ("error", "#f85149"), ("dim", "#6c757d")]:
            self.console.tag_config(tag, foreground=color)

        self.console.bind("<Control-c>", lambda e: self._copy_selection())
        self.console.bind("<Control-a>", lambda e: self.console.tag_add("sel", "1.0", "end") or "break")

        self.context_menu = tk.Menu(console_frame, tearoff=0, bg="#2d2d2d", fg="white")
        self.context_menu.add_command(label="Copiar", command=self._copy_selection)
        self.console.bind("<Button-3>", lambda e: self.context_menu.post(e.x_root, e.y_root))

    def _build_footer(self):
        footer = tk.Frame(self.root, bg=self.colors["surface"], height=60)
        footer.grid(row=2, column=0, sticky="ew")
        footer.grid_propagate(False)

        inner = tk.Frame(footer, bg=self.colors["surface"])
        inner.place(relx=0.5, rely=0.5, anchor="center")

        self.summary_label = tk.Label(inner, text="● Listo",
                font=("Segoe UI", 10), bg=self.colors["surface"],
                fg=self.colors["text_secondary"])
        self.summary_label.pack(side="left", padx=(0, 30))

        self.status_label = tk.Label(inner, text="✓ 0 componentes",
                font=("Segoe UI", 9), bg=self.colors["surface"],
                fg=self.colors["text_secondary"])
        self.status_label.pack(side="left")

        self.install_btn = tk.Button(inner, text="⚡ Instalar Fedora",
                command=self._on_install_click,
                bg=self.colors["primary"], fg="white",
                font=("Segoe UI", 12, "bold"),
                relief="flat", padx=30, pady=10, cursor="hand2",
                activebackground=self.colors["primary_hover"])
        self.install_btn.pack(side="right")

    def _make_toolbar_btn(self, parent, text, cmd):
        btn = tk.Button(parent, text=text, command=cmd, bg=self.colors["surface"],
                       fg=self.colors["text_secondary"], font=("Segoe UI", 9),
                       relief="flat", cursor="hand2", padx=10, pady=5)
        btn.bind("<Enter>", lambda e: btn.configure(bg=self.colors["surface_hover"]))
        btn.bind("<Leave>", lambda e: btn.configure(bg=self.colors["surface"]))
        return btn

    def _toggle_theme(self):
        self.dark_mode = not self.dark_mode
        self.colors = DARK_THEME.copy() if self.dark_mode else LIGHT_THEME.copy()
        self.theme_btn.config(text="☀️" if self.dark_mode else "🌙")
        self._refresh_ui()

    def _refresh_ui(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        self.vars.clear()
        self.module_vars.clear()
        self._create_vars()
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
        self._append_log(f"Sistema: {info}\n", "dim")
        self._append_log("Selecciona los componentes y presiona ⚡ Instalar...\n\n", "dim")

    def _select_all(self):
        for var in self.module_vars.values():
            var.set(True)
        for var in self.vars.values():
            var.set(True)
        self._update_summary()

    def _select_none(self):
        for var in self.module_vars.values():
            var.set(False)
        for var in self.vars.values():
            var.set(False)
        self._update_summary()

    def _select_recommended(self):
        for mod in MODULES:
            self.module_vars[mod["id"]].set(mod["recommended"])
        for var in self.vars.values():
            var.set(True)
        self._update_summary()

    def _update_summary(self):
        count = sum(1 for v in self.module_vars.values() if v.get())
        total = sum(len(m["items"]) for m in MODULES if self.module_vars[m["id"]].get())
        self.summary_label.config(text=f"● {count} módulos seleccionados")
        self.status_label.config(text=f"{total} componentes")

    def _on_install_click(self):
        if self.is_running:
            return

        selected = [m for m in MODULES if self.module_vars[m["id"]].get()]
        if not selected:
            messagebox.showwarning("Sin selección", "Selecciona al menos un módulo.")
            return

        confirm = "Se instalarán los siguientes módulos:\n\n" + \
            "\n".join(f"  {m['icon']} {m['title']}" for m in selected) + \
            "\n\n¿Continuar?"
        if not messagebox.askyesno("Confirmar instalación", confirm):
            return

        self.password = simpledialog.askstring("Autenticación",
                                               "Introduce tu contraseña de sudo:", show='*')
        if not self.password:
            return

        self._start_installation(selected)

    def _start_installation(self, selected):
        self.is_running = True
        self.install_btn.config(state="disabled", text="🔄 Instalando...")
        self.summary_label.config(text="● Instalando...", fg=self.colors["warning"])

        self.console.config(state="normal")
        self.console.delete(1.0, "end")
        self.console.config(state="disabled")

        thread = threading.Thread(target=self._run_installation, args=(selected,), daemon=True)
        thread.start()

    def _run_installation(self, selected):
        self._append_log("╔══════════════════════════════════════════╗\n", "info")
        self._append_log("║   🚀  Iniciando Fedora Setup Pro       ║\n", "info")
        self._append_log("╚══════════════════════════════════════════╝\n\n", "info")

        total = len(selected)
        for i, mod in enumerate(selected):
            script_path = os.path.join(SCRIPTS_DIR, mod["script"])
            if not os.path.isfile(script_path):
                self._append_log(f"  ✗ No encontrado: {script_path}\n", "error")
                continue

            self._append_log(f"\n══ {mod['icon']} {mod['title']} ═══════════════════\n", "info")
            self.root.after(0, lambda n=mod["title"]: self.progress_label.config(text=f"Ejecutando: {n}"))

            flags = []
            for _, _, key in mod["items"]:
                if key != "main":
                    var_key = f"{mod['prefix']}{key}"
                    if not self.vars.get(var_key, tk.BooleanVar(value=True)).get():
                        flags.append(f"--skip-{key}")

            cmd = ["sudo", "-S", "bash", script_path] + flags
            try:
                proc = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                       text=True, bufsize=1, cwd=SCRIPT_DIR)

                proc.stdin.write(self.password + "\n")
                proc.stdin.flush()

                for line in proc.stdout:
                    line = line.rstrip()
                    if line and "[sudo] password for" not in line:
                        clean = ANSI_PATTERN.sub('', line)
                        tag = self._detect_tag(clean)
                        self._append_log(clean + "\n", tag)

                proc.stdin.close()
                proc.wait()

                if proc.returncode == 0:
                    self._append_log(f"\n  ✅ {mod['title']} completado\n", "success")
                else:
                    self._append_log(f"\n  ⚠️  {mod['title']} finalizó con código {proc.returncode}\n", "warning")

            except Exception as e:
                self._append_log(f"  ✗ Error: {e}\n", "error")

        self._append_log("\n╔══════════════════════════════════════════╗\n", "success")
        self._append_log("║      ✅  Proceso Completado              ║\n", "success")
        self._append_log("╚══════════════════════════════════════════╝\n", "success")
        self._append_log("\nSi instalaste temas, cierra sesión para aplicar cambios.\n", "warning")
        self.root.after(0, self._on_complete)

    def _append_log(self, text, tag=None):
        def append():
            self.console.config(state="normal")
            self.console.insert("end", text, tag if tag else "dim")
            self.console.see("end")
            self.console.config(state="disabled")
        self.root.after(0, append)

    def _detect_tag(self, line):
        l = line.lower()
        if any(x in l for x in ["✔", "ok", "success", "completado", "listo", "done", "installed"]):
            return "success"
        if any(x in l for x in ["✗", "error", "failed", "fallo", "failed"]):
            return "error"
        if any(x in l for x in ["warn", "advertencia", "⚠"]):
            return "warning"
        if any(x in l for x in ["instalando", "configurando", "descargando", "installing"]):
            return "info"
        return None

    def _check_log_queue(self):
        try:
            while True:
                msg = self.log_queue.get_nowait()
                self._append_log(msg)
        except queue.Empty:
            pass
        finally:
            self.root.after(100, self._check_log_queue)

    def _copy_selection(self):
        try:
            selection = self.console.selection_get()
            self.root.clipboard_clear()
            self.root.clipboard_append(selection)
        except:
            pass

    def _on_complete(self):
        self.is_running = False
        self.install_btn.config(state="normal", text="⚡ Instalar Fedora")
        self.summary_label.config(text="✓ Instalación completada", fg=self.colors["success"])
        self.progress_label.config(text="")
        messagebox.showinfo("Completado", "Instalación finalizada.\nCierra sesión para aplicar cambios.")

    def _on_resize(self, event=None):
        pass


if __name__ == "__main__":
    root = tk.Tk()
    app = SetupApp(root)
    root.mainloop()
