import tkinter as tk
from tkinter import ttk
import threading
import subprocess
import os
import sys
from gui.theme import T, F, ThemeManager, center_window
from gui.widgets import Button, Card, ConsoleWidget, ProgressBar, SpinnerWidget

SCRIPT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS_DIR = os.path.join(SCRIPT_DIR, "scripts")

NAV_ITEMS = [
    ("✅", "Seleccionar", "select"),
    ("🚀", "Inicio", "home"),
    ("💻", "Terminal", "terminal"),
    ("📝", "VS Code", "vscode"),
    ("🔧", "Git", "git"),
    ("🎨", "Tema", "theme"),
    ("🔲", "Intel Fix", "intel"),
    ("🧩", "Extensiones", "extensions"),
    ("🚀", "OpenCode CLI", "opencode"),
]

COMPONENTS = [
    ("terminal", "💻", "Terminal Moderna", "zsh, Starship (12 temas), eza, bat, fzf, zoxide..."),
    ("vscode", "📝", "Visual Studio Code", "Editor con extensiones y configuración optimizada"),
    ("git", "🔧", "Git Global", "Configuración global y clave SSH para GitHub"),
    ("theme", "🎨", "Temas macOS", "GTK, iconos, GDM, Firefox theme"),
    ("intel", "🔲", "Fix Intel Screen Flicker", "Solución al parpadeo de pantalla"),
    ("extensions", "🧩", "Extensiones GNOME", "Dash to Dock, Magic Lamp, etc."),
    ("opencode", "🤖", "OpenCode CLI", "Asistente de IA para terminal"),
]


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.theme = ThemeManager(self)
        self.title("Fedora Setup - Huawei Matebook 14")
        self.configure(bg=T["bg_surface"])
        self.minsize(900, 600)
        center_window(self, 1000, 700)
        self._setup_window()
        self._build_ui()
        self.theme.subscribe(self._on_theme_change)

    def _setup_window(self):
        self.protocol("WM_DELETE_WINDOW", self._on_close)
        self.bind("<Control-q>", lambda e: self.destroy())

    def _build_ui(self):
        root = tk.Frame(self, bg=T["bg_base"])
        root.pack(fill="both", expand=True)

        sidebar = tk.Frame(root, bg=T["bg_card"], width=220)
        sidebar.pack(side="left", fill="y")
        sidebar.pack_propagate(False)

        tk.Frame(sidebar, bg=T["border_subtle"], height=1).pack(fill="x", padx=16, pady=(0, 16))
        
        tk.Label(sidebar, text="  Fedora Setup", font=F["h2"],
                 fg=T["accent"], bg=T["bg_card"]).pack(anchor="w", padx=16, pady=(0, 8))
        
        tk.Label(sidebar, text="  Huawei Matebook 14", font=F["caption"],
                 fg=T["text_muted"], bg=T["bg_card"]).pack(anchor="w", padx=16, pady=(0, 20))

        self._nav_buttons = []
        for icon, label, page_id in NAV_ITEMS:
            btn = tk.Button(sidebar, text=f"  {icon}  {label}",
                            font=F["body"], fg=T["text_secondary"], bg=T["bg_card"],
                            relief="flat", bd=0, cursor="hand2",
                            command=lambda p=page_id: self._navigate(p))
            btn.pack(fill="x", padx=8, pady=2)
            btn.bind("<Enter>", lambda e, b=btn: b.configure(bg=T["bg_hover"]))
            btn.bind("<Leave>", lambda e, b=btn: b.configure(bg=T["bg_card"]))
            self._nav_buttons.append((btn, page_id))

        tk.Frame(sidebar, bg=T["border_subtle"]).pack(fill="x", padx=16, pady=16)
        
        self._settings_btn = Button(sidebar, "⚙️  Ajustes", command=self._show_settings,
                                     variant="ghost", size="sm")
        self._settings_btn.pack(fill="x", padx=8, pady=8)

        self.content = tk.Frame(root, bg=T["bg_surface"])
        self.content.pack(side="right", fill="both", expand=True)

        self._current_page = None
        self._navigate("select")

    def _navigate(self, page_id):
        if self._current_page == page_id:
            return
        self._current_page = page_id

        for btn, pid in self._nav_buttons:
            if pid == page_id:
                btn.configure(bg=T["accent_dim"], fg=T["accent"])
            else:
                btn.configure(bg=T["bg_card"], fg=T["text_secondary"])

        for w in self.content.winfo_children():
            w.destroy()

        if page_id == "select":
            self._build_select_page()
        elif page_id == "home":
            self._build_home_page()
        elif page_id == "terminal":
            self._build_terminal_page()
        elif page_id == "vscode":
            self._build_install_page("vscode", "Visual Studio Code",
                                     "Editor con extensiones y configuración optimizada")
        elif page_id == "git":
            self._build_install_page("git", "Git Global",
                                     "Configuración global y clave SSH para GitHub")
        elif page_id == "theme":
            self._build_install_page("theme", "Temas macOS",
                                     "GTK, iconos, GDM, Firefox theme")
        elif page_id == "intel":
            self._build_install_page("intel", "Fix Intel Screen Flicker",
                                     "Solución al parpadeo de pantalla")
        elif page_id == "extensions":
            self._build_install_page("extensions", "Extensiones GNOME",
                                     "Dash to Dock, Magic Lamp, etc.")
        elif page_id == "opencode":
            self._build_install_page("opencode", "OpenCode CLI",
                                     "Asistente de IA para terminal y generación de código")

    def _build_select_page(self):
        container = tk.Frame(self.content, bg=T["bg_surface"])
        container.pack(fill="both", expand=True, padx=40, pady=40)

        tk.Label(container, text="Seleccionar Componentes", font=F["display"],
                 fg=T["text_primary"], bg=T["bg_surface"]).pack(anchor="w")

        tk.Label(container, text="Marca los componentes que deseas instalar",
                 font=F["body_lg"], fg=T["text_secondary"], bg=T["bg_surface"]
                 ).pack(anchor="w", pady=(8, 24))

        self._component_vars = {}
        self._starship_theme = tk.StringVar(value="tokyo-night")

        check_frame = tk.Frame(container, bg=T["bg_surface"])
        check_frame.pack(fill="both", expand=True, pady=(0, 20))

        for i, (comp_id, icon, title, desc) in enumerate(COMPONENTS):
            var = tk.BooleanVar(value=True)
            self._component_vars[comp_id] = var

            row = i // 2
            col = i % 2

            card = tk.Frame(check_frame, bg=T["bg_card"], bd=1, relief="flat")
            card.grid(row=row, column=col, padx=8, pady=8, sticky="nsew")

            cb = tk.Checkbutton(card, variable=var, font=F["body"],
                                fg=T["text_primary"], bg=T["bg_card"],
                                selectcolor=T["bg_card"])
            cb.pack(anchor="w", padx=12, pady=(12, 0))

            tk.Label(card, text=f"{icon}  {title}", font=F["h3"],
                    fg=T["text_primary"], bg=T["bg_card"]).pack(anchor="w", padx=12)

            tk.Label(card, text=desc, font=F["body_sm"],
                    fg=T["text_muted"], bg=T["bg_card"]).pack(anchor="w", padx=12, pady=(0, 12))

        check_frame.columnconfigure(0, weight=1)
        check_frame.columnconfigure(1, weight=1)

        if self._component_vars.get("terminal"):
            theme_frame = tk.LabelFrame(container, text="🎨 Tema de Starship",
                                        font=F["body"], fg=T["text_primary"],
                                        bg=T["bg_surface"], bd=1, padx=16, pady=12)
            theme_frame.pack(fill="x", pady=(0, 20))

            themes = [
                ("tokyo-night", "🌙 Tokyo Night (oscuro, recomendado)"),
                ("pastel-powerline", "🎨 Pastel Powerline (claro)"),
                ("gruvbox-rainbow", "🟤 Gruvbox Rainbow (oscuro)"),
                ("catppuccin-powerline", "🟣 Catppuccin Powerline (oscuro)"),
                ("jetpack", "🚀 Jetpack (minimalista)"),
                ("pure-preset", "⚡ Pure Prompt (clásico)"),
                ("nerd-font-symbols", "🔣 Nerd Font Symbols"),
                ("no-nerd-font", "🔤 Sin Nerd Font"),
                ("bracketed-segments", "🔲 Bracketed Segments"),
                ("plain-text", "📝 Plain Text"),
                ("no-runtimes", "🚫 Sin Runtime Versions"),
                ("no-empty-icons", "🚫 Sin Iconos Vacíos"),
            ]

            for value, text in themes:
                tk.Radiobutton(theme_frame, text=text, variable=self._starship_theme,
                               value=value, font=F["body"], fg=T["text_primary"],
                               bg=T["bg_surface"], selectcolor=T["bg_surface"]).pack(anchor="w")

        btn_frame = tk.Frame(container, bg=T["bg_surface"])
        btn_frame.pack(fill="x")

        Button(btn_frame, "Seleccionar Todo", command=self._select_all,
               variant="secondary", size="md").pack(side="left")

        Button(btn_frame, "Deseleccionar Todo", command=self._deselect_all,
               variant="secondary", size="md").pack(side="left", padx=(12, 0))

        self._install_btn = Button(btn_frame, "⚡ Instalar Seleccionados",
                                   command=self._install_selected,
                                   variant="primary", size="lg")
        self._install_btn.pack(side="right")

        console_frame = tk.Frame(container, bg=T["bg_card"], bd=1)
        console_frame.pack(fill="both", expand=True, pady=(20, 0))

        self._console = ConsoleWidget(console_frame)
        self._console.pack(fill="both", expand=True)

    def _select_all(self):
        for var in self._component_vars.values():
            var.set(True)

    def _deselect_all(self):
        for var in self._component_vars.values():
            var.set(False)

    def _install_selected(self):
        import shutil
        selected = [comp_id for comp_id, var in self._component_vars.items() if var.get()]

        if not selected:
            return

        theme = self._starship_theme.get()

        cmd_str = "bash " + " ".join([
            os.path.join(SCRIPTS_DIR, "gui-launcher.sh")
        ] + selected)
        if "terminal" in selected:
            cmd_str += " " + theme

        term_cmd = None
        for prog in ["ptyxis", "kgx", "gnome-terminal", "xterm", "konsole", "mate-terminal", "tilix", "terminator"]:
            if shutil.which(prog):
                term_cmd = prog
                break

        if term_cmd == "ptyxis":
            subprocess.Popen(["ptyxis", "--title", "Fedora Setup", "-e", cmd_str])
        elif term_cmd == "kgx":
            subprocess.Popen(["kgx", "--title", "Fedora Setup", "-e", cmd_str])
        elif term_cmd == "gnome-terminal":
            subprocess.Popen(["gnome-terminal", "--title", "Fedora Setup", "--", cmd_str])
        elif term_cmd == "xterm":
            subprocess.Popen(["xterm", "-title", "Fedora Setup", "-e", cmd_str])
        elif term_cmd == "konsole":
            subprocess.Popen(["konsole", "--title", "Fedora Setup", "-e", cmd_str])
        elif term_cmd == "mate-terminal":
            subprocess.Popen(["mate-terminal", "--title", "Fedora Setup", "-x", cmd_str])
        elif term_cmd == "tilix":
            subprocess.Popen(["tilix", "-t", "Fedora Setup", "-e", cmd_str])
        elif term_cmd == "terminator":
            subprocess.Popen(["terminator", "-t", "Fedora Setup", "-e", cmd_str])
        else:
            self._console.write(f"\n❌ No se encontró terminal interactiva. Buscando en: ptyxis, kgx, gnome-terminal, konsole, tilix, terminator...\n", "error")
            return

        self._console.write(f"\n✅ Instalación iniciada en terminal ({term_cmd}).\n", "success")
        self._console.write("Por favor, responde las preguntas en la ventana de terminal.\n", "info")

    def _build_home_page(self):
        container = tk.Frame(self.content, bg=T["bg_surface"])
        container.pack(fill="both", expand=True, padx=40, pady=40)

        tk.Label(container, text="Bienvenido a Fedora Setup", font=F["display"],
                 fg=T["text_primary"], bg=T["bg_surface"]).pack(anchor="w")

        tk.Label(container, text="Configura tu Huawei Matebook 14 con un solo clic",
                 font=F["body_lg"], fg=T["text_secondary"], bg=T["bg_surface"]
                 ).pack(anchor="w", pady=(8, 32))

        info_card = Card(container, title="ℹ️  Información",
                         subtitle="Este asistente te ayudará a configurar Fedora 43 en tu Matebook 14")
        info_card.pack(fill="x", pady=(0, 16))

        components = [
            ("💻", "Terminal", "zsh + Starship + herramientas CLI"),
            ("📝", "VS Code", "Editor configurado con extensiones"),
            ("🔧", "Git", "SSH keys para GitHub"),
            ("🎨", "Tema", "Apariencia macOS-like"),
            ("🔲", "Intel Fix", "Fix parpadeo pantalla"),
            ("🧩", "Extensiones", "GNOME extensions"),
            ("🚀", "OpenCode", "IA CLI Interpeter"),
        ]
        
        grid_frame = tk.Frame(container, bg=T["bg_surface"])
        grid_frame.pack(fill="both", expand=True)
        
        cols = 3
        for i, (icon, title, desc) in enumerate(components):
            row, col = divmod(i, cols)
            card = Card(grid_frame, title=f"{icon} {title}", subtitle=desc)
            card.grid(row=row, column=col, padx=8, pady=8, sticky="nsew")

        for c in range(cols):
            grid_frame.columnconfigure(c, weight=1)

    def _build_terminal_page(self):
        container = tk.Frame(self.content, bg=T["bg_surface"])
        container.pack(fill="both", expand=True, padx=40, pady=40)

        tk.Label(container, text="Terminal Moderna", font=F["h1"],
                 fg=T["text_primary"], bg=T["bg_surface"]).pack(anchor="w")

        tk.Label(container, text="zsh, Starship, eza, bat, fzf, zoxide...",
                 font=F["body_lg"], fg=T["text_secondary"], bg=T["bg_surface"]
                 ).pack(anchor="w", pady=(8, 16))

        theme_frame = tk.LabelFrame(container, text="🎨 Tema de Starship",
                                     font=F["body"], fg=T["text_primary"],
                                     bg=T["bg_surface"], bd=1, padx=16, pady=12)
        theme_frame.pack(fill="x", pady=(0, 16))

        self._starship_theme = tk.StringVar(value="tokyo-night")

        themes = [
            ("tokyo-night", "🌙 Tokyo Night (oscuro, recomendado)"),
            ("pastel-powerline", "🎨 Pastel Powerline (claro)"),
            ("gruvbox-rainbow", "🟤 Gruvbox Rainbow (oscuro)"),
            ("catppuccin-powerline", "🟣 Catppuccin Powerline (oscuro)"),
            ("jetpack", "🚀 Jetpack (minimalista)"),
            ("pure-preset", "⚡ Pure Prompt (clásico)"),
            ("nerd-font-symbols", "🔣 Nerd Font Symbols"),
            ("no-nerd-font", "🔤 Sin Nerd Font"),
            ("bracketed-segments", "🔲 Bracketed Segments"),
            ("plain-text", "📝 Plain Text"),
            ("no-runtimes", "🚫 Sin Runtime Versions"),
            ("no-empty-icons", "🚫 Sin Iconos Vacíos"),
        ]

        for value, text in themes:
            tk.Radiobutton(theme_frame, text=text, variable=self._starship_theme,
                           value=value, font=F["body"], fg=T["text_primary"],
                           bg=T["bg_surface"], selectcolor=T["bg_surface"]).pack(anchor="w")

        self._progress_bar = ProgressBar(container, height=8)
        self._progress_bar.pack(fill="x", pady=(0, 16))

        self._console = ConsoleWidget(container)
        self._console.pack(fill="both", expand=True)

        btn_frame = tk.Frame(container, bg=T["bg_surface"])
        btn_frame.pack(fill="x", pady=(16, 0))

        self._install_btn = Button(btn_frame, "⚡ Instalar Terminal",
                                    command=lambda: self._run_install("terminal"),
                                    variant="primary", size="lg")
        self._install_btn.pack(side="left")

    def _build_install_page(self, component_id, title, description):
        container = tk.Frame(self.content, bg=T["bg_surface"])
        container.pack(fill="both", expand=True, padx=40, pady=40)

        tk.Label(container, text=title, font=F["h1"],
                 fg=T["text_primary"], bg=T["bg_surface"]).pack(anchor="w")

        tk.Label(container, text=description, font=F["body_lg"],
                 fg=T["text_secondary"], bg=T["bg_surface"]
                 ).pack(anchor="w", pady=(8, 24))

        self._progress_bar = ProgressBar(container, height=8)
        self._progress_bar.pack(fill="x", pady=(0, 16))

        self._console = ConsoleWidget(container)
        self._console.pack(fill="both", expand=True)

        btn_frame = tk.Frame(container, bg=T["bg_surface"])
        btn_frame.pack(fill="x", pady=(16, 0))

        self._install_btn = Button(btn_frame, f"⚡ Instalar {title}",
                                    command=lambda: self._run_install(component_id),
                                    variant="primary", size="lg")
        self._install_btn.pack(side="left")

    def _run_install(self, component_id):
        script_path = os.path.join(SCRIPTS_DIR, f"0{list(NAV_ITEMS).index(next((i for i in NAV_ITEMS if i[2] == component_id), None)) + 1}-{component_id}.sh")
        
        if not os.path.exists(script_path):
            script_path = os.path.join(SCRIPTS_DIR, f"gui-launcher.sh")
        
        extra_args = []
        if component_id == "terminal" and hasattr(self, "_starship_theme"):
            extra_args.append(self._starship_theme.get())
        
        self._install_btn.set_loading(True)
        self._progress_bar.set(0, animate=False)
        
        thread = threading.Thread(target=self._install_thread, args=(script_path, component_id, extra_args), daemon=True)
        thread.start()

    def _install_thread(self, script_path, component_id, extra_args=None):
        if extra_args is None:
            extra_args = []
        
        def update_ui(text, level="auto"):
            self.after(0, lambda: self._console.write(text, level))

        try:
            cmd = ["bash", script_path, component_id] + extra_args
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, text=True,
                                    cwd=SCRIPTS_DIR)
            
            for line in proc.stdout:
                update_ui(line)
            
            proc.wait()
            
            self.after(0, lambda: self._progress_bar.set(100))
            self.after(0, lambda: self._install_btn.set_loading(False))
            self.after(0, lambda: self._console.write("\n✅ Instalación completada\n", "success"))
            
        except Exception as e:
            self.after(0, lambda: self._console.write(f"\n❌ Error: {e}\n", "error"))
            self.after(0, lambda: self._install_btn.set_loading(False))

    def _show_settings(self):
        pass

    def _on_theme_change(self, tokens):
        self._build_ui()

    def _on_close(self):
        self.destroy()


def main():
    app = App()
    app.mainloop()


if __name__ == "__main__":
    main()
