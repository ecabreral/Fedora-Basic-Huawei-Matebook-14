#!/usr/bin/env python3
"""
Fedora Setup Pro — GUI Installer for Huawei Matebook 14
Professional PyQt6 Application
"""

import sys
import os

try:
    from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
                                  QGridLayout, QLabel, QPushButton, QScrollArea, QFrame,
                                  QTextEdit, QCheckBox, QGroupBox, QProgressBar, QMessageBox,
                                  QInputDialog, QSizePolicy, QGraphicsOpacityEffect)
    from PyQt6.QtCore import Qt, QThread, pyqtSignal, QSize, QTimer
    from PyQt6.QtGui import QFont, QIcon, QPalette, QColor, QAction
    PYQT6_AVAILABLE = True
except ImportError:
    PYQT6_AVAILABLE = False

import subprocess
import re
import platform
import json

ANSI_PATTERN = re.compile(r'\x1b\[[0-9;]*m')
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPTS_DIR = os.path.join(SCRIPT_DIR, "scripts")

# ═══════════════════════════════════════════════════════════════════════════════
# DESIGN TOKENS
# ═══════════════════════════════════════════════════════════════════════════════
DARK = {
    "bg": "#0d0d14",
    "surface": "#13131f",
    "card": "#1a1a2c",
    "raised": "#222238",
    "hover": "#30305a",
    "border": "#38385e",
    "accent": "#3c6eb4",
    "accent_hover": "#4a7fc7",
    "text": "#e8e8f0",
    "text_sec": "#9898b8",
    "text_muted": "#55557a",
    "success": "#4ade80",
    "warning": "#fbbf24",
    "error": "#f87171",
}

LIGHT = {
    "bg": "#f4f4f8",
    "surface": "#ffffff",
    "card": "#ffffff",
    "raised": "#f0f0f6",
    "hover": "#e8e8f4",
    "border": "#d0d0e0",
    "accent": "#3c82f6",
    "accent_hover": "#2563eb",
    "text": "#111827",
    "text_sec": "#4b5563",
    "text_muted": "#9ca3af",
    "success": "#16a34a",
    "warning": "#d97706",
    "error": "#dc2626",
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODULES
# ═══════════════════════════════════════════════════════════════════════════════
MODULES = [
    {"id": "terminal", "icon": "🐚", "title": "Terminal Pro",
     "desc": "Shell moderno con zsh, Starship y herramientas CLI",
     "script": "01-terminal.sh", "sudo": False, "recommended": True,
     "items": [("Paquetes base", "git, curl, wget, zsh", True),
               ("Herramientas", "eza, bat, fzf, zoxide", True),
               ("JetBrainsMono Nerd", "Fuente con iconos", True),
               ("Zsh + Oh My Zsh", "Shell moderno", True),
               ("Starship", "Prompt minimalista", True)]},
    {"id": "vscode", "icon": "💻", "title": "Visual Studio Code",
     "desc": "Editor con GitHub Theme y JetBrains Mono",
     "script": "02-vscode.sh", "sudo": True, "recommended": True,
     "items": [("VS Code", "Repositorio Microsoft", True)]},
    {"id": "git", "icon": "🔐", "title": "Git + GitHub",
     "desc": "Config global, clave SSH ed25519",
     "script": "03-git.sh", "sudo": False, "recommended": True,
     "items": [("Config global", "user.name, email", True),
               ("Clave SSH", "ed25519 para GitHub", True)]},
    {"id": "theme", "icon": "🎨", "title": "Temas GNOME",
     "desc": "Estilo macOS con WhiteSur y MacTahoe",
     "script": "04-gnome-theme.sh", "sudo": False, "recommended": True,
     "items": [("Dependencias", "sassc, glib", True),
               ("Tema GTK", "WhiteSur Light + Dark", True),
               ("Iconos", "WhiteSur + MacTahoe", True),
               ("GDM", "Pantalla de inicio", False),
               ("Firefox", "WhiteSur Firefox", True)]},
    {"id": "intel", "icon": "⚡", "title": "Intel Fix",
     "desc": "Elimina el parpadeo de pantalla Intel Arc",
     "script": "05-intel-fix.sh", "sudo": True, "recommended": False,
     "items": [("Parámetros kernel", "i915.enable_psr=0", True)]},
    {"id": "extensions", "icon": "🔌", "title": "Extensiones GNOME",
     "desc": "Dash to Dock, Magic Lamp, Night Theme Switcher",
     "script": "06-extensions.sh", "sudo": False, "recommended": True,
     "items": [("Dash to Dock", "Dock estilo macOS", True),
               ("Magic Lamp", "Animación minimizar", True),
               ("Copyous", "Historial portapapeles", True),
               ("Night Theme", "Auto claro/oscuro", True)]},
]


class InstallThread(QThread):
    output = pyqtSignal(str, str)
    finished = pyqtSignal(bool)
    progress = pyqtSignal(str, int)

    def __init__(self, modules, password):
        super().__init__()
        self.modules = modules
        self.password = password

    def run(self):
        self.output.emit("╔══════════════════════════════════════════╗", "info")
        self.output.emit("║   🚀  Iniciando Fedora Setup Pro       ║", "info")
        self.output.emit("╚══════════════════════════════════════════╝\n", "info")

        for i, mod in enumerate(self.modules):
            script = os.path.join(SCRIPTS_DIR, mod["script"])
            self.progress.emit(mod["title"], int((i/len(self.modules))*100))

            if not os.path.isfile(script):
                self.output.emit(f"  ✗ No encontrado: {script}", "error")
                continue

            self.output.emit(f"\n══ {mod['icon']} {mod['title']} ═══════════════════", "info")

            try:
                proc = subprocess.Popen(
                    ["sudo", "-S", "bash", script],
                    stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT, text=True, bufsize=1
                )
                proc.stdin.write(self.password + "\n")
                proc.stdin.flush()

                for line in proc.stdout:
                    clean = ANSI_PATTERN.sub('', line.rstrip())
                    if "[sudo] password" not in clean:
                        tag = self._detect_tag(clean)
                        self.output.emit(clean, tag)

                proc.stdin.close()
                proc.wait()

                if proc.returncode == 0:
                    self.output.emit(f"\n  ✅ {mod['title']} completado\n", "success")
                else:
                    self.output.emit(f"\n  ⚠️  {mod['title']} finalizado\n", "warning")

            except Exception as e:
                self.output.emit(f"  ✗ Error: {e}", "error")

        self.progress.emit("Completado", 100)
        self.finished.emit(True)

    def _detect_tag(self, line):
        l = line.lower()
        if any(x in l for x in ["✔", "ok", "success", "completado", "done"]):
            return "success"
        if any(x in l for x in ["✗", "error", "failed", "fallo"]):
            return "error"
        if any(x in l for x in ["warn", "advertencia", "⚠"]):
            return "warning"
        return "dim"


class ModuleCard(QFrame):
    def __init__(self, mod, check_var, colors):
        super().__init__()
        self.colors = colors
        self.mod = mod
        self.check_var = check_var
        self._setup_ui()

    def _setup_ui(self):
        self.setFrameStyle(QFrame.Shape.NoFrame)
        self.setStyleSheet(f"""
            QFrame {{
                background: {self.colors['card']};
                border: 1px solid {self.colors['border']};
                border-radius: 8px;
                padding: 12px;
            }}
            QFrame:hover {{
                border: 1px solid {self.colors['accent']};
            }}
            QLabel {{
                color: {self.colors['text']};
                background: transparent;
            }}
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 12)
        layout.setSpacing(8)

        header = QHBoxLayout()
        icon = QLabel(f"<span style='font-size: 20px'>{self.mod['icon']}</span>")
        title = QLabel(f"<b style='font-size: 14px'>{self.mod['title']}</b>")
        title.setStyleSheet(f"color: {self.colors['accent']}")
        checkbox = QCheckBox()
        checkbox.setChecked(self.mod["recommended"])
        checkbox.stateChanged.connect(lambda: None)

        header.addWidget(icon)
        header.addWidget(title)
        header.addStretch()
        header.addWidget(checkbox)

        desc = QLabel(self.mod["desc"])
        desc.setStyleSheet(f"color: {self.colors['text_sec']}; font-size: 11px;")
        desc.setWordWrap(True)

        items_frame = QFrame()
        items_frame.setStyleSheet(f"border-top: 1px solid {self.colors['border']}; padding-top: 8px;")
        items_layout = QVBoxLayout(items_frame)
        items_layout.setContentsMargins(0, 8, 0, 0)
        items_layout.setSpacing(4)

        for name, desc_text, default in self.mod["items"]:
            item = QLabel(f"▸ <b>{name}</b> <span style='color: {self.colors['text_muted']}'>— {desc_text}</span>")
            item.setStyleSheet(f"font-size: 11px; color: {self.colors['text']}")
            items_layout.addWidget(item)

        if self.mod["sudo"]:
            sudo_badge = QLabel("🔒 requiere sudo")
            sudo_badge.setStyleSheet(f"color: {self.colors['warning']}; font-size: 10px; font-weight: bold;")
            layout.addWidget(sudo_badge)

        layout.addLayout(header)
        layout.addWidget(desc)
        layout.addWidget(items_frame)


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.dark_mode = True
        self.colors = DARK
        self.module_vars = {mod["id"]: mod["recommended"] for mod in MODULES}
        self.is_running = False
        self.password = ""
        self.thread = None

        self._load_theme()
        self._setup_ui()
        self._apply_styles()

    def _load_theme(self):
        config_path = os.path.expanduser("~/.config/fedora-setup/settings.json")
        try:
            with open(config_path) as f:
                self.dark_mode = json.load(f).get("dark_mode", True)
                self.colors = DARK if self.dark_mode else LIGHT
        except:
            pass

    def _save_theme(self):
        config_path = os.path.expanduser("~/.config/fedora-setup/settings.json")
        os.makedirs(os.path.dirname(config_path), exist_ok=True)
        with open(config_path, "w") as f:
            json.dump({"dark_mode": self.dark_mode}, f)

    def _setup_ui(self):
        self.setWindowTitle("Fedora Setup Pro — Huawei Matebook 14")
        self.setMinimumSize(1000, 700)
        self.resize(1200, 850)

        central = QWidget()
        self.setCentralWidget(central)
        main_layout = QVBoxLayout(central)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        main_layout.addWidget(self._create_header())
        main_layout.addWidget(self._create_content())
        main_layout.addWidget(self._create_footer())

        self._check_system()

    def _create_header(self):
        header = QFrame()
        header.setObjectName("header")
        layout = QVBoxLayout(header)
        layout.setContentsMargins(24, 16, 24, 12)

        top = QHBoxLayout()
        title_layout = QVBoxLayout()
        title = QLabel("◉ Fedora Setup Pro")
        title.setObjectName("title")
        subtitle = QLabel("Huawei Matebook 14")
        subtitle.setObjectName("subtitle")
        title_layout.addWidget(title)
        title_layout.addWidget(subtitle)

        btn_layout = QHBoxLayout()
        btn_layout.addWidget(self._create_btn("Todo", self._select_all))
        btn_layout.addWidget(self._create_btn("Ninguno", self._select_none))
        btn_layout.addWidget(self._create_btn("Recomendado", self._select_recommended))
        btn_layout.addSpacing(12)

        self.theme_btn = self._create_btn("☀ Claro" if self.dark_mode else "🌙 Oscuro", self._toggle_theme)
        btn_layout.addWidget(self.theme_btn)

        top.addLayout(title_layout)
        top.addStretch()
        top.addLayout(btn_layout)

        specs = QLabel("Intel Core Ultra 5 125H  ·  16 GB LPDDR5  ·  14.2\" 2K OLED  ·  Intel Arc  ·  Fedora 43")
        specs.setObjectName("specs")

        layout.addLayout(top)
        layout.addWidget(specs)

        return header

    def _create_content(self):
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)

        container = QFrame()
        container.setObjectName("content")
        grid = QGridLayout(container)
        grid.setContentsMargins(24, 16, 24, 16)
        grid.setSpacing(16)

        self.module_cards = []
        for i, mod in enumerate(MODULES):
            row, col = divmod(i, 3)
            var = mod["recommended"]
            card = ModuleCard(mod, var, self.colors)
            self.module_cards.append((mod["id"], card))
            grid.addWidget(card, row, col)

        self.console = QTextEdit()
        self.console.setObjectName("console")
        self.console.setReadOnly(True)
        self.console.setMinimumHeight(200)

        grid.addWidget(self.console, 2, 0, 1, 3)

        scroll.setWidget(container)
        return scroll

    def _create_footer(self):
        footer = QFrame()
        footer.setObjectName("footer")
        layout = QHBoxLayout(footer)
        layout.setContentsMargins(24, 16, 24, 16)

        self.status_label = QLabel("● Listo")
        self.status_label.setObjectName("status")
        layout.addWidget(self.status_label)

        self.progress_bar = QProgressBar()
        self.progress_bar.setObjectName("progress")
        self.progress_bar.setMaximumWidth(300)
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)
        layout.addWidget(self.progress_bar)

        self.install_btn = self._create_btn("⚡  Instalar Fedora", self._on_install, primary=True)
        layout.addWidget(self.install_btn)

        return footer

    def _create_btn(self, text, callback, primary=False):
        btn = QPushButton(text)
        btn.setCursor(Qt.CursorShape.PointingHandCursor)
        btn.clicked.connect(callback)
        if primary:
            btn.setObjectName("primaryBtn")
        return btn

    def _apply_styles(self):
        accent = self.colors["accent"]
        accent_hover = self.colors["accent_hover"]
        bg = self.colors["bg"]
        surface = self.colors["surface"]
        card = self.colors["card"]
        text = self.colors["text"]
        text_sec = self.colors["text_sec"]
        text_muted = self.colors["text_muted"]
        border = self.colors["border"]
        success = self.colors["success"]
        warning = self.colors["warning"]
        error = self.colors["error"]

        stylesheet = f"""
            QMainWindow {{ background: {bg}; }}
            QWidget {{ background: {bg}; color: {text}; font-family: 'Segoe UI', sans-serif; }}

            #header {{ background: {accent}; padding: 0; }}
            #title {{ color: white; font-size: 22px; font-weight: bold; }}
            #subtitle {{ color: rgba(255,255,255,0.8); font-size: 12px; }}

            #content {{ background: {bg}; }}

            QScrollArea {{ background: {bg}; border: none; }}
            QScrollBar:vertical {{ background: {surface}; width: 10px; border-radius: 5px; }}
            QScrollBar::handle:vertical {{ background: {border}; min-height: 30px; border-radius: 5px; }}
            QScrollBar::handle:hover {{ background: {text_muted}; }}
            QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{ height: 0px; }}

            QPushButton {{
                background: {card};
                color: {text};
                border: 1px solid {border};
                border-radius: 6px;
                padding: 8px 16px;
                font-size: 12px;
            }}
            QPushButton:hover {{ background: {self.colors['hover']}; border-color: {accent}; }}
            QPushButton:pressed {{ background: {surface}; }}

            #primaryBtn {{
                background: {accent};
                color: white;
                border: none;
                font-weight: bold;
                font-size: 13px;
                padding: 10px 24px;
            }}
            #primaryBtn:hover {{ background: {accent_hover}; }}

            QCheckBox {{ color: {text}; spacing: 8px; }}
            QCheckBox::indicator {{ width: 18px; height: 18px; border: 2px solid {border}; border-radius: 4px; background: {card}; }}
            QCheckBox::indicator:checked {{ background: {accent}; border-color: {accent}; }}

            #console {{
                background: #0d0d14;
                color: #e0e0e0;
                border: 1px solid {border};
                border-radius: 8px;
                padding: 12px;
                font-family: 'JetBrains Mono', 'Consolas', monospace;
                font-size: 11px;
            }}

            #footer {{ background: {surface}; border-top: 1px solid {border}; }}
            #status {{ color: {text_sec}; font-size: 11px; }}

            #progress {{ border: none; border-radius: 4px; background: {surface}; height: 6px; }}
            #progress::chunk {{ background: {accent}; border-radius: 4px; }}

            #specs {{ color: rgba(255,255,255,0.6); font-size: 10px; font-family: monospace; padding: 8px 0 0 0; }}
        """
        self.setStyleSheet(stylesheet)

    def _toggle_theme(self):
        self.dark_mode = not self.dark_mode
        self.colors = DARK if self.dark_mode else LIGHT
        self.theme_btn.setText("☀ Claro" if self.dark_mode else "🌙 Oscuro")
        self._save_theme()
        self._apply_styles()

    def _check_system(self):
        info = f"{platform.system()} {platform.release()}"
        try:
            r = subprocess.run(['lsb_release', '-d'], capture_output=True, text=True)
            if r.returncode == 0:
                info = r.stdout.strip().split(':', 1)[1].strip()
        except:
            pass
        self._console_write(f"Sistema: {info}\n", "dim")
        self._console_write("Selecciona los componentes y presiona ⚡ Instalar...\n\n", "dim")

    def _console_write(self, text, level="dim"):
        colors = {
            "info": "#60b0f4",
            "success": self.colors["success"],
            "warning": self.colors["warning"],
            "error": self.colors["error"],
            "dim": "#55557a",
        }
        color = colors.get(level, "#e0e0e0")
        cursor = self.console.textCursor()
        cursor.movePosition(cursor.End)
        self.console.setTextCursor(cursor)
        self.console.insertHtml(f'<span style="color: {color}">{text.replace(" ", "&nbsp;").replace(chr(10), "<br>")}</span>')
        self.console.verticalScrollBar().setValue(self.console.verticalScrollBar().maximum())

    def _select_all(self):
        for mod_id, card in self.module_cards:
            self.module_vars[mod_id] = True
        self._update_status()

    def _select_none(self):
        for mod_id, card in self.module_cards:
            self.module_vars[mod_id] = False
        self._update_status()

    def _select_recommended(self):
        for mod in MODULES:
            self.module_vars[mod["id"]] = mod["recommended"]
        self._update_status()

    def _update_status(self):
        count = sum(1 for v in self.module_vars.values() if v)
        self.status_label.setText(f"● {count} módulos seleccionados")

    def _on_install(self):
        selected = [m for m in MODULES if self.module_vars.get(m["id"], False)]
        if not selected:
            QMessageBox.warning(self, "Sin selección", "Selecciona al menos un módulo.")
            return

        msg = "Se instalarán los siguientes módulos:\n\n"
        msg += "\n".join(f"  {m['icon']} {m['title']}" for m in selected)
        msg += "\n\n¿Continuar?"

        reply = QMessageBox.question(self, "Confirmar instalación", msg, QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply != QMessageBox.StandardButton.Yes:
            return

        password, ok = QInputDialog.getText(self, "Autenticación", "Introduce tu contraseña de sudo:", QLineEdit.EchoMode.Password)
        if not ok or not password:
            return

        self._start_installation(selected, password)

    def _start_installation(self, selected, password):
        self.is_running = True
        self.install_btn.setEnabled(False)
        self.install_btn.setText("🔄 Instalando...")
        self.console.clear()

        self.thread = InstallThread(selected, password)
        self.thread.output.connect(lambda text, level: self._console_write(text + "\n", level))
        self.thread.progress.connect(lambda title, pct: (self.status_label.setText(f"Ejecutando: {title}"), self.progress_bar.setValue(pct)))
        self.thread.finished.connect(self._on_complete)
        self.thread.start()

    def _on_complete(self, success):
        self.is_running = False
        self.install_btn.setEnabled(True)
        self.install_btn.setText("⚡  Instalar Fedora")
        self.progress_bar.setValue(100)
        self.status_label.setText("✓ Instalación completada")
        self._console_write("\n╔══════════════════════════════════════════╗\n", "success")
        self._console_write("║      ✅  Proceso Completado              ║\n", "success")
        self._console_write("╚══════════════════════════════════════════╝\n", "success")
        self._console_write("\nSi instalaste temas, cierra sesión para aplicar cambios.\n", "warning")
        QMessageBox.information(self, "Completado", "Instalación finalizada.\nCierra sesión para aplicar cambios.")


if __name__ == "__main__":
    if not PYQT6_AVAILABLE:
        print("PyQt6 no está instalado. Ejecuta:")
        print("  pip install PyQt6")
        print("  sudo dnf install python3-pyQt6")
        print("\nAlternativamente, usa la versión tkinter:")
        print("  python3 setup_gui.py --tk")
        sys.exit(1)

    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
