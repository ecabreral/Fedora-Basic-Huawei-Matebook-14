#!/usr/bin/env python3
"""
Fedora Setup Pro — GUI Installer for Huawei Matebook 14
Professional PyQt6 Application
"""

import sys
import os

PYQT6_AVAILABLE = False
try:
    from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
                                  QGridLayout, QLabel, QPushButton, QScrollArea, QFrame,
                                  QTextEdit, QCheckBox, QProgressBar, QMessageBox,
                                  QInputDialog, QLineEdit)
    from PyQt6.QtCore import Qt, QThread, pyqtSignal
    PYQT6_AVAILABLE = True
except ImportError:
    pass

import subprocess
import re
import platform
import json

ANSI_PATTERN = re.compile(r'\x1b\[[0-9;]*m')
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPTS_DIR = os.path.join(SCRIPT_DIR, "scripts")

DARK = {
    "bg": "#0d0d14", "surface": "#13131f", "card": "#1a1a2c",
    "accent": "#3c6eb4", "text": "#e8e8f0", "text_sec": "#9898b8",
    "success": "#4ade80", "warning": "#fbbf24", "error": "#f87171",
}

LIGHT = {
    "bg": "#f4f4f8", "surface": "#ffffff", "card": "#ffffff",
    "accent": "#3c82f6", "text": "#111827", "text_sec": "#4b5563",
    "success": "#16a34a", "warning": "#d97706", "error": "#dc2626",
}

MODULES = [
    {"id": "terminal", "icon": "🐚", "title": "Terminal Pro",
     "desc": "Shell moderno con zsh, Starship y herramientas CLI",
     "script": "01-terminal.sh", "sudo": False, "recommended": True,
     "items": [("Paquetes base", "git, curl, wget, zsh"),
               ("Herramientas", "eza, bat, fzf, zoxide"),
               ("JetBrainsMono Nerd", "Fuente con iconos"),
               ("Zsh + Oh My Zsh", "Shell moderno"),
               ("Starship", "Prompt minimalista")]},
    {"id": "vscode", "icon": "💻", "title": "Visual Studio Code",
     "desc": "Editor con GitHub Theme y JetBrains Mono",
     "script": "02-vscode.sh", "sudo": True, "recommended": True,
     "items": [("VS Code", "Repositorio Microsoft")]},
    {"id": "git", "icon": "🔐", "title": "Git + GitHub",
     "desc": "Config global, clave SSH ed25519",
     "script": "03-git.sh", "sudo": False, "recommended": True,
     "items": [("Config global", "user.name, email"), ("Clave SSH", "ed25519 para GitHub")]},
    {"id": "theme", "icon": "🎨", "title": "Temas GNOME",
     "desc": "Estilo macOS con WhiteSur y MacTahoe",
     "script": "04-gnome-theme.sh", "sudo": False, "recommended": True,
     "items": [("Dependencias", "sassc, glib"), ("Tema GTK", "WhiteSur Light + Dark"),
               ("Iconos", "WhiteSur + MacTahoe"), ("GDM", "Pantalla de inicio"),
               ("Firefox", "WhiteSur Firefox")]},
    {"id": "intel", "icon": "⚡", "title": "Intel Fix",
     "desc": "Elimina el parpadeo de pantalla Intel Arc",
     "script": "05-intel-fix.sh", "sudo": True, "recommended": False,
     "items": [("Parámetros kernel", "i915.enable_psr=0")]},
    {"id": "extensions", "icon": "🔌", "title": "Extensiones GNOME",
     "desc": "Dash to Dock, Magic Lamp, Night Theme Switcher",
     "script": "06-extensions.sh", "sudo": False, "recommended": True,
     "items": [("Dash to Dock", "Dock estilo macOS"), ("Magic Lamp", "Animación minimizar"),
               ("Copyous", "Historial portapapeles"), ("Night Theme", "Auto claro/oscuro")]},
]

if PYQT6_AVAILABLE:
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
                    proc = subprocess.Popen(["sudo", "-S", "bash", script],
                        stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT, text=True, bufsize=1)
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


    class MainWindow(QMainWindow):
        def __init__(self):
            super().__init__()
            self.dark_mode = self._load_preference()
            self.colors = DARK if self.dark_mode else LIGHT
            self.module_vars = {m["id"]: m["recommended"] for m in MODULES}
            self.is_running = False
            self.password = ""
            self.thread = None
            self._setup_ui()

        def _load_preference(self):
            try:
                with open(os.path.expanduser("~/.config/fedora-setup/settings.json")) as f:
                    return json.load(f).get("dark_mode", True)
            except:
                return True

        def _save_preference(self):
            os.makedirs(os.path.expanduser("~/.config/fedora-setup"), exist_ok=True)
            with open(os.path.expanduser("~/.config/fedora-setup/settings.json"), "w") as f:
                json.dump({"dark_mode": self.dark_mode}, f)

        def _setup_ui(self):
            self.setWindowTitle("Fedora Setup Pro — Huawei Matebook 14")
            self.setMinimumSize(1000, 700)
            self.resize(1200, 850)

            central = QWidget()
            self.setCentralWidget(central)
            layout = QVBoxLayout(central)
            layout.setContentsMargins(0, 0, 0, 0)
            layout.addWidget(self._create_header())
            layout.addWidget(self._create_content())
            layout.addWidget(self._create_footer())
            self._check_system()

        def _create_header(self):
            header = QFrame()
            header.setStyleSheet(f"background: {self.colors['accent']}; padding: 16px 24px;")
            layout = QVBoxLayout(header)

            top = QHBoxLayout()
            title = QLabel("◉ Fedora Setup Pro")
            title.setStyleSheet("color: white; font-size: 22px; font-weight: bold;")
            subtitle = QLabel("Huawei Matebook 14")
            subtitle.setStyleSheet("color: rgba(255,255,255,0.8); font-size: 12px;")
            top.addWidget(title)
            top.addWidget(subtitle)
            top.addStretch()

            btns = QHBoxLayout()
            for t, c in [("Todo", self._select_all), ("Ninguno", self._select_none),
                         ("Recomendado", self._select_recommended)]:
                b = QPushButton(t)
                b.setCursor(Qt.CursorShape.PointingHandCursor)
                b.setStyleSheet("background: rgba(255,255,255,0.2); color: white; border: none; padding: 8px 16px; border-radius: 6px;")
                b.clicked.connect(c)
                btns.addWidget(b)

            sep = QFrame()
            sep.setStyleSheet("background: rgba(255,255,255,0.3); width: 1px; margin: 0 12px;")
            sep.setFixedWidth(1)
            btns.addWidget(sep)

            self.theme_btn = QPushButton("☀ Claro" if self.dark_mode else "🌙 Oscuro")
            self.theme_btn.setCursor(Qt.CursorShape.PointingHandCursor)
            self.theme_btn.setStyleSheet("background: rgba(255,255,255,0.2); color: white; border: none; padding: 8px 16px; border-radius: 6px;")
            self.theme_btn.clicked.connect(self._toggle_theme)
            btns.addWidget(self.theme_btn)
            top.addLayout(btns)

            specs = QLabel("Intel Core Ultra 5 125H  ·  16 GB LPDDR5  ·  14.2\" 2K OLED  ·  Intel Arc  ·  Fedora 43")
            specs.setStyleSheet("color: rgba(255,255,255,0.6); font-size: 10px; font-family: monospace;")
            layout.addLayout(top)
            layout.addWidget(specs)
            return header

        def _create_content(self):
            scroll = QScrollArea()
            scroll.setWidgetResizable(True)
            scroll.setStyleSheet("background: #0d0d14; border: none;")

            container = QFrame()
            container.setStyleSheet(f"background: {self.colors['bg']}; padding: 16px 24px;")
            grid = QGridLayout(container)
            grid.setSpacing(16)

            self.module_cards = []
            for i, mod in enumerate(MODULES):
                row, col = divmod(i, 3)
                card = self._create_card(mod)
                self.module_cards.append((mod["id"], card))
                grid.addWidget(card, row, col)

            self.console = QTextEdit()
            self.console.setReadOnly(True)
            self.console.setStyleSheet("background: #0d0d14; color: #e0e0e0; border: 1px solid #38385e; border-radius: 8px; padding: 12px; font-family: monospace; font-size: 11px;")
            self.console.setMinimumHeight(200)
            grid.addWidget(self.console, 2, 0, 1, 3)

            scroll.setWidget(container)
            return scroll

        def _create_card(self, mod):
            card = QFrame()
            card.setStyleSheet(f"background: {self.colors['card']}; border: 1px solid #38385e; border-radius: 8px; padding: 12px;")
            layout = QVBoxLayout(card)
            layout.setContentsMargins(16, 12, 16, 12)

            header = QHBoxLayout()
            icon = QLabel(f"<span style='font-size: 20px'>{mod['icon']}</span>")
            title = QLabel(f"<b style='font-size: 14px; color: {self.colors['accent']}'>{mod['title']}</b>")
            cb = QCheckBox()
            cb.setChecked(mod["recommended"])
            header.addWidget(icon)
            header.addWidget(title)
            header.addStretch()
            header.addWidget(cb)

            desc = QLabel(mod["desc"])
            desc.setStyleSheet(f"color: {self.colors['text_sec']}; font-size: 11px;")
            desc.setWordWrap(True)

            items = QFrame()
            items.setStyleSheet(f"border-top: 1px solid #38385e; padding-top: 8px;")
            items_layout = QVBoxLayout(items)
            items_layout.setContentsMargins(0, 8, 0, 0)
            for name, desc_text in mod["items"]:
                item = QLabel(f"▸ <b>{name}</b> <span style='color: #55557a'>— {desc_text}</span>")
                item.setStyleSheet(f"font-size: 11px; color: {self.colors['text']};")
                items_layout.addWidget(item)

            if mod["sudo"]:
                sudo = QLabel("🔒 requiere sudo")
                sudo.setStyleSheet("color: #fbbf24; font-size: 10px; font-weight: bold;")
                layout.addWidget(sudo)

            layout.addLayout(header)
            layout.addWidget(desc)
            layout.addWidget(items)
            return card

        def _create_footer(self):
            footer = QFrame()
            footer.setStyleSheet(f"background: {self.colors['surface']}; border-top: 1px solid #38385e; padding: 16px 24px;")
            layout = QHBoxLayout(footer)

            self.status_label = QLabel("● Listo")
            self.status_label.setStyleSheet(f"color: {self.colors['text_sec']}; font-size: 11px;")

            self.progress_bar = QProgressBar()
            self.progress_bar.setRange(0, 100)
            self.progress_bar.setValue(0)
            self.progress_bar.setMaximumWidth(300)
            self.progress_bar.setStyleSheet("border: none; border-radius: 4px; background: #38385e; height: 6px;")

            self.install_btn = QPushButton("⚡  Instalar Fedora")
            self.install_btn.setCursor(Qt.CursorShape.PointingHandCursor)
            self.install_btn.setStyleSheet("background: #3c6eb4; color: white; border: none; padding: 10px 24px; border-radius: 6px; font-weight: bold; font-size: 13px;")
            self.install_btn.clicked.connect(self._on_install)

            layout.addWidget(self.status_label)
            layout.addWidget(self.progress_bar)
            layout.addWidget(self.install_btn)
            return footer

        def _toggle_theme(self):
            self.dark_mode = not self.dark_mode
            self.colors = DARK if self.dark_mode else LIGHT
            self.theme_btn.setText("☀ Claro" if self.dark_mode else "🌙 Oscuro")
            self._save_preference()
            self._setup_ui()

        def _check_system(self):
            info = f"{platform.system()} {platform.release()}"
            try:
                r = subprocess.run(['lsb_release', '-d'], capture_output=True, text=True)
                if r.returncode == 0:
                    info = r.stdout.strip().split(':', 1)[1].strip()
            except:
                pass
            self._console_write(f"Sistema: {info}\n", "#55557a")
            self._console_write("Selecciona los componentes y presiona ⚡ Instalar...\n\n", "#55557a")

        def _console_write(self, text, color="#e0e0e0"):
            cursor = self.console.textCursor()
            cursor.movePosition(cursor.End)
            self.console.setTextCursor(cursor)
            self.console.insertHtml(f'<span style="color: {color}">{text.replace(" ", "&nbsp;").replace(chr(10), "<br>")}</span>')
            self.console.verticalScrollBar().setValue(self.console.verticalScrollBar().maximum())

        def _select_all(self):
            for mod_id, _ in self.module_cards:
                self.module_vars[mod_id] = True
            self._update_status()

        def _select_none(self):
            for mod_id, _ in self.module_cards:
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
            msg = "Se instalarán los siguientes módulos:\n\n" + "\n".join(f"  {m['icon']} {m['title']}" for m in selected) + "\n\n¿Continuar?"
            if QMessageBox.question(self, "Confirmar", msg) != QMessageBox.StandardButton.Yes:
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
            self.thread.output.connect(lambda t, l: self._console_write(t + "\n", {"info": "#60b0f4", "success": "#4ade80", "warning": "#fbbf24", "error": "#f87171", "dim": "#55557a"}.get(l, "#e0e0e0")))
            self.thread.progress.connect(lambda t, p: (self.status_label.setText(f"Ejecutando: {t}"), self.progress_bar.setValue(p)))
            self.thread.finished.connect(lambda s: self._on_complete())
            self.thread.start()

        def _on_complete(self):
            self.is_running = False
            self.install_btn.setEnabled(True)
            self.install_btn.setText("⚡  Instalar Fedora")
            self.progress_bar.setValue(100)
            self.status_label.setText("✓ Instalación completada")
            self._console_write("\n╔══════════════════════════════════════════╗\n", "#4ade80")
            self._console_write("║      ✅  Proceso Completado              ║\n", "#4ade80")
            self._console_write("╚══════════════════════════════════════════╝\n", "#4ade80")
            self._console_write("\nSi instalaste temas, cierra sesión para aplicar cambios.\n", "#fbbf24")
            QMessageBox.information(self, "Completado", "Instalación finalizada.\nCierra sesión para aplicar cambios.")


if __name__ == "__main__":
    if PYQT6_AVAILABLE:
        app = QApplication(sys.argv)
        window = MainWindow()
        window.show()
        sys.exit(app.exec())
    else:
        print("╔══════════════════════════════════════════╗")
        print("║  Fedora Setup Pro                       ║")
        print("╚══════════════════════════════════════════╝")
        print()
        print("PyQt6 no está instalado.")
        print()
        print("Instala PyQt6 con:")
        print("  pip install PyQt6")
        print()
        print("O ejecuta la versión tkinter:")
        print("  python3 -c \"import tkinter; exec(open('setup_gui.py').read())\"")
        sys.exit(1)
