#!/usr/bin/env python3
"""
Fedora Setup Pro — GUI Installer for Huawei Matebook 14
Professional Python GUI following design best practices
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, simpledialog
import subprocess
import threading
import queue
import os
import re
import platform
import json

ANSI_PATTERN = re.compile(r'\x1b\[[0-9;]*m')
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPTS_DIR = os.path.join(SCRIPT_DIR, "scripts")

# ═══════════════════════════════════════════════════════════════════════════════
# DESIGN TOKENS — 4px Grid System
# ═══════════════════════════════════════════════════════════════════════════════
TOKENS = {
    "bg_base":      "#0d0d14",
    "bg_surface":   "#13131f",
    "bg_card":      "#1a1a2c",
    "bg_raised":    "#222238",
    "bg_overlay":   "#2c2c48",
    "bg_hover":     "#30305a",
    "border_subtle": "#252540",
    "border_default":"#38385e",
    "border_focus":  "#60b0f4",
    "accent":        "#3c6eb4",
    "accent_hover":  "#4a7fc7",
    "accent_dim":    "#1e2d4d",
    "text_primary":   "#e8e8f0",
    "text_secondary":"#9898b8",
    "text_muted":    "#55557a",
    "text_inverse":  "#ffffff",
    "success":       "#4ade80",
    "warning":       "#fbbf24",
    "error":         "#f87171",
    "info":          "#60b0f4",
    "space_1": 4, "space_2": 8, "space_3": 12,
    "space_4": 16, "space_5": 20, "space_6": 24,
    "space_8": 32, "space_10": 40,
}

TOKENS_LIGHT = {
    "bg_base":      "#f4f4f8",
    "bg_surface":    "#ffffff",
    "bg_card":       "#ffffff",
    "bg_raised":     "#f0f0f6",
    "bg_overlay":    "#ffffff",
    "bg_hover":      "#e8e8f4",
    "border_subtle": "#e4e4ee",
    "border_default": "#d0d0e0",
    "border_focus":  "#3c82f6",
    "accent":        "#3c82f6",
    "accent_hover":  "#2563eb",
    "accent_dim":    "#dbeafe",
    "text_primary":  "#111827",
    "text_secondary":"#4b5563",
    "text_muted":    "#9ca3af",
    "text_inverse":  "#ffffff",
    "success":       "#16a34a",
    "warning":       "#d97706",
    "error":         "#dc2626",
    "info":          "#2563eb",
    "space_1": 4, "space_2": 8, "space_3": 12,
    "space_4": 16, "space_5": 20, "space_6": 24,
    "space_8": 32, "space_10": 40,
}

T = TOKENS

# ═══════════════════════════════════════════════════════════════════════════════
# TYPOGRAPHY
# ═══════════════════════════════════════════════════════════════════════════════
def get_system_fonts():
    system = platform.system()
    return {
        "sans": {
            "Linux":   ["Inter", "Noto Sans", "DejaVu Sans", "sans-serif"],
            "Darwin":  ["SF Pro Text", "Helvetica Neue", "sans-serif"],
            "Windows": ["Segoe UI", "Calibri", "sans-serif"],
        }[system],
        "mono": {
            "Linux":   ["JetBrains Mono", "Fira Code", "monospace"],
            "Darwin":  ["SF Mono", "Menlo", "monospace"],
            "Windows": ["Cascadia Code", "Consolas", "monospace"],
        }[system],
    }

def first_font(candidates):
    available = set(tk.font.families())
    for f in candidates:
        if f in available:
            return f
    return candidates[-1]

FONTS = get_system_fonts()
FONT_PRIMARY = first_font(FONTS["sans"])
FONT_MONO = first_font(FONTS["mono"])

F = {
    "display": (FONT_PRIMARY, 24, "bold"),
    "h1":      (FONT_PRIMARY, 18, "bold"),
    "h2":      (FONT_PRIMARY, 14, "bold"),
    "h3":      (FONT_PRIMARY, 12, "bold"),
    "body":    (FONT_PRIMARY, 10),
    "body_sm": (FONT_PRIMARY, 9),
    "label":   (FONT_PRIMARY, 9, "bold"),
    "caption": (FONT_PRIMARY, 8),
    "mono":    (FONT_MONO, 9),
    "btn":     (FONT_PRIMARY, 10, "bold"),
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODULES
# ═══════════════════════════════════════════════════════════════════════════════
MODULES = [
    {"id": "terminal", "icon": "🐚", "title": "Terminal Pro",
     "desc": "Shell moderno con zsh, Starship y herramientas CLI",
     "script": "01-terminal.sh", "sudo": False, "recommended": True,
     "items": [("Paquetes base", "git, curl, wget, zsh", "pkg"),
               ("Herramientas", "eza, bat, fzf, zoxide", "eza"),
               ("JetBrainsMono Nerd", "Fuente con iconos", "font"),
               ("Zsh + Oh My Zsh", "Shell moderno", "zsh"),
               ("Starship", "Prompt minimalista", "starship")]},
    {"id": "vscode", "icon": "💻", "title": "Visual Studio Code",
     "desc": "Editor con GitHub Theme y JetBrains Mono",
     "script": "02-vscode.sh", "sudo": True, "recommended": True,
     "items": [("VS Code", "Repositorio Microsoft", "main")]},
    {"id": "git", "icon": "🔐", "title": "Git + GitHub",
     "desc": "Config global, clave SSH ed25519",
     "script": "03-git.sh", "sudo": False, "recommended": True,
     "items": [("Config global", "user.name, email", "main"),
               ("Clave SSH", "ed25519 para GitHub", "ssh")]},
    {"id": "theme", "icon": "🎨", "title": "Temas GNOME",
     "desc": "Estilo macOS con WhiteSur y MacTahoe",
     "script": "04-gnome-theme.sh", "sudo": False, "recommended": True,
     "items": [("Dependencias", "sassc, glib", "dep"),
               ("Tema GTK", "WhiteSur Light + Dark", "gtk"),
               ("Iconos", "WhiteSur + MacTahoe", "icons"),
               ("GDM", "Pantalla de inicio", "gdm"),
               ("Firefox", "WhiteSur Firefox", "firefox")]},
    {"id": "intel", "icon": "⚡", "title": "Intel Fix",
     "desc": "Elimina el parpadeo de pantalla Intel Arc",
     "script": "05-intel-fix.sh", "sudo": True, "recommended": False,
     "items": [("Parámetros kernel", "i915.enable_psr=0", "main")]},
    {"id": "extensions", "icon": "🔌", "title": "Extensiones GNOME",
     "desc": "Dash to Dock, Magic Lamp, Night Theme Switcher",
     "script": "06-extensions.sh", "sudo": False, "recommended": True,
     "items": [("Dash to Dock", "Dock estilo macOS", "dash"),
               ("Magic Lamp", "Animación minimizar", "lamp"),
               ("Copyous", "Historial portapapeles", "copy"),
               ("Night Theme", "Auto claro/oscuro", "night")]},
]

# ═══════════════════════════════════════════════════════════════════════════════
# WIDGETS
# ═══════════════════════════════════════════════════════════════════════════════

class ScrollableFrame(tk.Frame):
    def __init__(self, parent, **kw):
        super().__init__(parent, bg=kw.get("bg", T["bg_surface"]))
        self.canvas = tk.Canvas(self, highlightthickness=0, bg=kw.get("bg", T["bg_surface"]))
        self.scrollbar = ttk.Scrollbar(self, orient="vertical", command=self.canvas.yview)
        self.inner = tk.Frame(self.canvas, bg=kw.get("bg", T["bg_surface"]))

        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.scrollbar.pack(side="right", fill="y")
        self.canvas.pack(side="left", fill="both", expand=True)
        self._window = self.canvas.create_window((0, 0), window=self.inner, anchor="nw")

        self.inner.bind("<Configure>", lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all")))
        self.canvas.bind("<Configure>", lambda e: self.canvas.itemconfig(self._window, width=e.width))
        self.canvas.bind_all("<MouseWheel>", self._scroll)
        self.canvas.bind_all("<Button-4>", self._scroll)
        self.canvas.bind_all("<Button-5>", self._scroll)

    def _scroll(self, event):
        if event.num == 4:
            self.canvas.yview_scroll(-1, "units")
        elif event.num == 5:
            self.canvas.yview_scroll(1, "units")
        else:
            self.canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")


class Card(tk.Frame):
    def __init__(self, parent, **kw):
        super().__init__(parent, bg=T["bg_card"],
                        highlightbackground=T["border_subtle"], highlightthickness=1)
        self.bind("<Enter>", lambda e: self.configure(highlightbackground=T["border_focus"]))
        self.bind("<Leave>", lambda e: self.configure(highlightbackground=T["border_subtle"]))


class Button(tk.Button):
    STYLES = {
        "primary":   {"fg": T["text_inverse"], "bg": T["accent"],       "hover": T["accent_hover"]},
        "secondary": {"fg": T["text_primary"],  "bg": T["bg_raised"],    "hover": T["bg_overlay"]},
        "ghost":     {"fg": T["text_secondary"],"bg": "transparent",     "hover": T["bg_hover"]},
        "danger":    {"fg": "#ffffff",           "bg": T["error"],        "hover": "#dc2020"},
    }

    def __init__(self, parent, text, command=None, variant="primary", size="md", **kw):
        s = self.STYLES[variant]
        super().__init__(parent, text=text, command=command,
                        font=F["btn"], fg=s["fg"], bg=s["bg"],
                        activeforeground=s["fg"], activebackground=s["hover"],
                        relief="flat", bd=0, cursor="hand2", padx=16, pady=7, **kw)
        self._bg_normal = s["bg"]
        self._bg_hover = s["hover"]
        self.bind("<Enter>", lambda e: self.configure(bg=self._bg_hover))
        self.bind("<Leave>", lambda e: self.configure(bg=self._bg_normal))


class ConsoleWidget(tk.Frame):
    TAGS = {
        "info":    "#60b0f4",
        "success": "#4ade80",
        "warning": "#fbbf24",
        "error":   "#f87171",
        "cmd":     "#c084fc",
        "dim":     "#55557a",
    }

    def __init__(self, parent, **kw):
        super().__init__(parent, bg=T["bg_base"], **kw)
        self._build()

    def _build(self):
        hdr = tk.Frame(self, bg=T["bg_raised"])
        hdr.pack(fill="x")
        tk.Label(hdr, text="  Consola", font=F["label"],
                fg=T["text_muted"], bg=T["bg_raised"], pady=5).pack(side="left")
        Button(hdr, "Limpiar", command=self.clear, variant="ghost", size="sm").pack(side="right", padx=4)

        self.text = scrolledtext.ScrolledText(self, bg=T["bg_base"], fg="#cdd6f4",
            font=F["mono"], insertbackground=T["accent"], relief="flat", bd=0,
            state="disabled", wrap="word", padx=16, pady=8)
        self.text.pack(fill="both", expand=True)
        for tag, color in self.TAGS.items():
            self.text.tag_config(tag, foreground=color)

    def write(self, text, level="info"):
        clean = ANSI_PATTERN.sub('', text)
        self.text.configure(state="normal")
        self.text.insert("end", clean, level)
        self.text.configure(state="disabled")
        self.text.see("end")

    def _auto_tag(self, line):
        l = line.lower()
        if any(x in l for x in ["✔", "ok", "success", "completado", "done", "installed"]):
            return "success"
        if any(x in l for x in ["✗", "error", "failed", "fallo"]):
            return "error"
        if any(x in l for x in ["warn", "advertencia", "⚠"]):
            return "warning"
        if any(x in l for x in ["instalando", "configurando", "descargando"]):
            return "info"
        return "dim"

    def clear(self):
        self.text.configure(state="normal")
        self.text.delete("1.0", "end")
        self.text.configure(state="disabled")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN APP
# ═══════════════════════════════════════════════════════════════════════════════

def center_window(window, width, height):
    window.update_idletasks()
    sw, sh = window.winfo_screenwidth(), window.winfo_screenheight()
    window.geometry(f"{width}x{height}+{(sw-width)//2}+{(sh-height)//2-40}")


class SetupApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Fedora Setup Pro — Huawei Matebook 14")
        self.minsize(900, 750)
        center_window(self, 1100, 900)
        self.configure(bg=T["bg_surface"])

        self.password = ""
        self.is_running = False
        self.theme = ThemeManager()
        self.module_vars = {}

        self._create_vars()
        self._build_ui()
        self._check_system()
        self.theme.subscribe(self._on_theme_change)
        self.after(100, self._check_log_queue)

    def _create_vars(self):
        for mod in MODULES:
            self.module_vars[mod["id"]] = tk.BooleanVar(value=mod["recommended"])

    def _build_ui(self):
        self._build_header()
        self._build_body()
        self._build_footer()

    def _build_header(self):
        header = tk.Frame(self, bg=T["accent"], height=90)
        header.pack(fill="x", side="top")
        header.pack_propagate(False)

        inner = tk.Frame(header, bg=T["accent"])
        inner.pack(fill="x", padx=24, pady=12)

        left = tk.Frame(inner, bg=T["accent"])
        left.pack(side="left")
        tk.Label(left, text="◉ Fedora Setup Pro", font=F["display"],
                fg=T["text_inverse"], bg=T["accent"]).pack(anchor="w")
        tk.Label(left, text="Huawei Matebook 14", font=F["body"],
                fg=T["text_inverse"], bg=T["accent"]).pack(anchor="w")

        right = tk.Frame(inner, bg=T["accent"])
        right.pack(side="right")
        for label, cmd in [("Todo", self._select_all), ("Ninguno", self._select_none),
                          ("Recomendado", self._select_recommended)]:
            Button(right, label, cmd, variant="secondary", size="sm").pack(side="left", padx=4)
        tk.Frame(right, bg="#ffffff44", width=1, height=28).pack(side="left", padx=12)
        Button(right, "☀", self.theme.toggle, variant="secondary", size="sm").pack(side="left", padx=4)

        specs = tk.Frame(self, bg=T["bg_surface"], pady=6)
        specs.pack(fill="x")
        tk.Label(specs, text="Intel Core Ultra 5 125H  ·  16 GB LPDDR5  ·  14.2\" 2K OLED  ·  Intel Arc  ·  Fedora 43",
                font=F["caption"], fg=T["text_muted"], bg=T["bg_surface"]).pack(side="left", padx=24)

    def _build_body(self):
        body = tk.Frame(self, bg=T["bg_surface"])
        body.pack(fill="both", expand=True, padx=24, pady=12)
        body.grid_rowconfigure(0, weight=1)
        body.grid_columnconfigure(0, weight=3)
        body.grid_columnconfigure(1, weight=2)

        self.scroll_frame = ScrollableFrame(body, bg=T["bg_surface"])
        self.scroll_frame.grid(row=0, column=0, sticky="nsew", padx=(0, 12))
        self._build_cards()

        self.console = ConsoleWidget(body)
        self.console.grid(row=0, column=1, sticky="nsew")

    def _build_cards(self):
        scroll = self.scroll_frame.inner
        for i, mod in enumerate(MODULES):
            row, col = divmod(i, 3)
            card = self._build_card(scroll, mod)
            card.grid(row=row, column=col, padx=8, pady=8, sticky="nsew")
            scroll.columnconfigure(col, weight=1)

    def _build_card(self, parent, mod):
        var = self.module_vars[mod["id"]]
        card = Card(parent)

        hdr = tk.Frame(card, bg=T["bg_card"])
        hdr.pack(fill="x", padx=16, pady=(12, 6))

        title_row = tk.Frame(hdr, bg=T["bg_card"])
        title_row.pack(fill="x")
        tk.Label(title_row, text=f"{mod['icon']} {mod['title']}",
                font=F["h2"], fg=T["text_primary"], bg=T["bg_card"]).pack(side="left")

        cb = tk.Checkbutton(title_row, variable=var, bg=T["bg_card"],
                          activebackground=T["bg_card"], fg=T["accent"],
                          selectcolor=T["accent_dim"], highlightthickness=0,
                          command=self._update_summary)
        cb.pack(side="right")

        tk.Label(hdr, text=mod["desc"], font=F["body_sm"],
                fg=T["text_secondary"], bg=T["bg_card"]).pack(anchor="w")

        tk.Frame(card, bg=T["border_subtle"], height=1).pack(fill="x")

        items = tk.Frame(card, bg=T["bg_card"])
        items.pack(fill="x", padx=16, pady=8)

        for name, desc, key in mod["items"]:
            row = tk.Frame(items, bg=T["bg_card"])
            row.pack(fill="x", pady=2)
            tk.Label(row, text=f"▸ {name}", font=F["body_sm"],
                    fg=T["text_primary"], bg=T["bg_card"]).pack(side="left")
            tk.Label(row, text=f"— {desc}", font=F["caption"],
                    fg=T["text_muted"], bg=T["bg_card"]).pack(side="right")

        if mod["sudo"]:
            tk.Label(card, text="🔒 requiere sudo", font=F["caption"],
                    fg=T["warning"], bg=T["bg_card"], pady=6).pack(side="left", padx=16)

        return card

    def _build_footer(self):
        footer = tk.Frame(self, bg=T["bg_surface"], height=60)
        footer.pack(fill="x", side="bottom")
        footer.pack_propagate(False)

        inner = tk.Frame(footer, bg=T["bg_surface"])
        inner.pack(fill="x", padx=24, pady=12)

        self.summary_label = tk.Label(inner, text="● Listo", font=F["body_sm"],
                fg=T["text_secondary"], bg=T["bg_surface"])
        self.summary_label.pack(side="left")

        self.progress_label = tk.Label(inner, text="", font=F["caption"],
                fg=T["text_muted"], bg=T["bg_surface"])
        self.progress_label.pack(side="left", padx=16)

        self.install_btn = Button(inner, "⚡  Instalar Fedora",
                command=self._on_install_click, variant="primary")
        self.install_btn.pack(side="right")

    def _on_theme_change(self):
        for widget in self.winfo_children():
            widget.destroy()
        self._create_vars()
        self._build_ui()

    def _check_system(self):
        info = f"{platform.system()} {platform.release()}"
        try:
            r = subprocess.run(['lsb_release', '-d'], capture_output=True, text=True)
            if r.returncode == 0:
                info = r.stdout.strip().split(':', 1)[1].strip()
        except:
            pass
        self.console.write(f"Sistema: {info}\n", "dim")
        self.console.write("Selecciona los componentes y presiona ⚡ Instalar...\n\n", "dim")

    def _select_all(self):
        for var in self.module_vars.values():
            var.set(True)
        self._update_summary()

    def _select_none(self):
        for var in self.module_vars.values():
            var.set(False)
        self._update_summary()

    def _select_recommended(self):
        for mod in MODULES:
            self.module_vars[mod["id"]].set(mod["recommended"])
        self._update_summary()

    def _update_summary(self):
        count = sum(1 for v in self.module_vars.values() if v.get())
        self.summary_label.config(text=f"● {count} módulos seleccionados")

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
        self.install_btn.configure(state="disabled", text="🔄 Instalando...")
        self.console.clear()
        threading.Thread(target=self._run_installation, args=(selected,), daemon=True).start()

    def _run_installation(self, selected):
        self.console.write("╔══════════════════════════════════════════╗\n", "info")
        self.console.write("║   🚀  Iniciando Fedora Setup Pro       ║\n", "info")
        self.console.write("╚══════════════════════════════════════════╝\n\n", "info")

        for mod in selected:
            script_path = os.path.join(SCRIPTS_DIR, mod["script"])
            if not os.path.isfile(script_path):
                self.console.write(f"  ✗ No encontrado: {script_path}\n", "error")
                continue

            self.after(0, lambda m=mod["title"]: self.progress_label.config(text=f"Ejecutando: {m}"))
            self.console.write(f"\n══ {mod['icon']} {mod['title']} ═══════════════════\n", "info")

            cmd = ["sudo", "-S", "bash", script_path]
            try:
                proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                      stderr=subprocess.STDOUT, text=True, bufsize=1, cwd=SCRIPT_DIR)
                proc.stdin.write(self.password + "\n")
                proc.stdin.flush()

                for line in proc.stdout:
                    line = line.rstrip()
                    if line and "[sudo] password for" not in line:
                        clean = ANSI_PATTERN.sub('', line)
                        self.after(0, lambda l=clean: self.console.write(l + "\n", self.console._auto_tag(l)))

                proc.stdin.close()
                proc.wait()

                if proc.returncode == 0:
                    self.after(0, lambda m=mod["title"]: self.console.write(f"\n  ✅ {m} completado\n\n", "success"))
                else:
                    self.after(0, lambda m=mod["title"]: self.console.write(f"\n  ⚠️  {m} finalizado\n\n", "warning"))
            except Exception as e:
                self.console.write(f"  ✗ Error: {e}\n", "error")

        self.after(0, self._on_complete)

    def _on_complete(self):
        self.is_running = False
        self.install_btn.configure(state="normal", text="⚡  Instalar Fedora")
        self.progress_label.config(text="")
        self.console.write("\n╔══════════════════════════════════════════╗\n", "success")
        self.console.write("║      ✅  Proceso Completado              ║\n", "success")
        self.console.write("╚══════════════════════════════════════════╝\n", "success")
        self.console.write("\nSi instalaste temas, cierra sesión para aplicar cambios.\n", "warning")
        messagebox.showinfo("Completado", "Instalación finalizada.\nCierra sesión para aplicar cambios.")

    def _check_log_queue(self):
        self.after(100, self._check_log_queue)


class ThemeManager:
    CONFIG_PATH = os.path.expanduser("~/.config/fedora-setup/settings.json")

    def __init__(self):
        self._dark = self._load_preference()
        self._subscribers = []

    def subscribe(self, callback):
        self._subscribers.append(callback)

    def toggle(self):
        global T
        self._dark = not self._dark
        T = TOKENS if self._dark else TOKENS_LIGHT
        self._save_preference()
        for cb in self._subscribers:
            cb()

    def _load_preference(self):
        try:
            with open(self.CONFIG_PATH) as f:
                return json.load(f).get("dark_mode", True)
        except:
            return True

    def _save_preference(self):
        os.makedirs(os.path.dirname(self.CONFIG_PATH), exist_ok=True)
        with open(self.CONFIG_PATH, "w") as f:
            json.dump({"dark_mode": self._dark}, f)


if __name__ == "__main__":
    app = SetupApp()
    app.mainloop()
