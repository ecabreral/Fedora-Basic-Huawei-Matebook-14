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
    ("🚀", "Inicio", "home"),
    ("💻", "Terminal", "terminal"),
    ("📝", "VS Code", "vscode"),
    ("🔧", "Git", "git"),
    ("🎨", "Tema", "theme"),
    ("🔲", "Intel Fix", "intel"),
    ("🧩", "Extensiones", "extensions"),
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
        self._navigate("home")

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

        if page_id == "home":
            self._build_home_page()
        elif page_id == "terminal":
            self._build_install_page("terminal", "Terminal Moderna",
                                     "zsh, Starship, eza, bat, fzf, zoxide...")
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
            ("🔲", "Intel Fix", "驱动 de pantalla"),
            ("🧩", "Extensiones", "GNOME extensions"),
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
        
        self._install_btn.set_loading(True)
        self._progress_bar.set(0, animate=False)
        
        thread = threading.Thread(target=self._install_thread, args=(script_path, component_id), daemon=True)
        thread.start()

    def _install_thread(self, script_path, component_id):
        def update_ui(text, level="auto"):
            self.after(0, lambda: self._console.write(text, level))

        try:
            cmd = ["bash", script_path, component_id]
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
