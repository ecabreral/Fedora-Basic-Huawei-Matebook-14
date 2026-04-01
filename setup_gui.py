import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, simpledialog
import subprocess
import threading
import os
import re
import sys

# ==============================================================================
# setup_gui.py
# Instalador gráfico avanzado con terminal embebida y soporte de colores.
# ==============================================================================

class SetupApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fedora 43 Setup - Huawei Matebook 14")
        self.root.geometry("800x650")
        self.root.resizable(True, True)

        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.password = ""
        
        self.setup_ui()
        self.setup_styles()

    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('clam')
        # Colores modernos (Inspirados en WhiteSur)
        style.configure("TButton", padding=6, font=("Inter", 10))
        style.configure("Header.TLabel", font=("Inter", 16, "bold"))
        style.configure("TCheckbutton", font=("Inter", 11))

    def setup_ui(self):
        # Contenedor Principal
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Encabezado
        header = ttk.Label(main_frame, text="🚀 Configuración Pro de Fedora", style="Header.TLabel")
        header.pack(pady=(0, 10))

        desc = ttk.Label(main_frame, text="Selecciona los componentes que deseas instalar y configurar:", wraplength=700)
        desc.pack(pady=(0, 15))

        # Checklist de Componentes
        self.vars = {
            "terminal": tk.BooleanVar(value=True),
            "vscode": tk.BooleanVar(value=True),
            "git": tk.BooleanVar(value=True),
            "theme": tk.BooleanVar(value=True),
            "intel": tk.BooleanVar(value=False),
            "extensions": tk.BooleanVar(value=True),
        }

        check_frame = ttk.LabelFrame(main_frame, text=" Personalización ", padding="10")
        check_frame.pack(fill=tk.X, pady=10)

        ttk.Checkbutton(check_frame, text="Terminal moderna (zsh, Starship, eza, bat...)", variable=self.vars["terminal"]).pack(anchor=tk.W, pady=2)
        ttk.Checkbutton(check_frame, text="Visual Studio Code + Configuración Premium", variable=self.vars["vscode"]).pack(anchor=tk.W, pady=2)
        ttk.Checkbutton(check_frame, text="Git Global + Clave SSH para GitHub", variable=self.vars["git"]).pack(anchor=tk.W, pady=2)
        ttk.Checkbutton(check_frame, text="Temas macOS (WhiteSur GTK, Iconos, GDM)", variable=self.vars["theme"]).pack(anchor=tk.W, pady=2)
        ttk.Checkbutton(check_frame, text="Fix Intel Screen Flicker (Parpadeo pantalla)", variable=self.vars["intel"]).pack(anchor=tk.W, pady=2)
        ttk.Checkbutton(check_frame, text="Extensiones GNOME (Dash to Dock, etc.)", variable=self.vars["extensions"]).pack(anchor=tk.W, pady=2)

        # Terminal Embebida (ScrolledText)
        terminal_label = ttk.Label(main_frame, text="📟 Consola de Salida (Logs):", font=("Inter", 10, "bold"))
        terminal_label.pack(anchor=tk.W, pady=(15, 5))

        self.console = scrolledtext.ScrolledText(main_frame, height=15, font=("JetBrainsMono Nerd Font", 9), bg="#1e1e1e", fg="#d4d4d4", padx=10, pady=10)
        self.console.pack(fill=tk.BOTH, expand=True)
        
        # Configurar etiquetas de color (ansi to tags)
        self.console.tag_config("blue", foreground="#3b82f6", font=("JetBrainsMono Nerd Font", 9, "bold"))
        self.console.tag_config("green", foreground="#22c55e", font=("JetBrainsMono Nerd Font", 9, "bold"))
        self.console.tag_config("yellow", foreground="#eab308")
        self.console.tag_config("red", foreground="#ef4444", font=("JetBrainsMono Nerd Font", 9, "bold"))
        self.console.tag_config("bold", font=("JetBrainsMono Nerd Font", 9, "bold"))

        # Botones
        btn_frame = ttk.Frame(main_frame, padding="10")
        btn_frame.pack(fill=tk.X)

        self.start_btn = ttk.Button(btn_frame, text="⚡ Iniciar Instalación", command=self.run_install)
        self.start_btn.pack(side=tk.RIGHT, padx=5)

    def log(self, text):
        """Escribe texto en la consola procesando colores ANSI básicos."""
        # Limpiar secuencias de escape ANSI y mapear a etiquetas
        # Esta es una implementación simplificada para los scripts del proyecto
        
        self.console.config(state=tk.NORMAL)
        
        parts = re.split(r'(\x1b\[[0-9;]*m)', text)
        for part in parts:
            if not part: continue
            
            if part.startswith(r'\x1b[') or part.startswith(r'\033['):
                # Ignorar reseteo por ahora o mapear colores específicos
                continue
            
            # Mapeo manual basado en las funciones de lib.sh
            tag = None
            clean_part = part
            
            if "══" in part: tag = "blue"
            elif "✔" in part: tag = "green"
            elif "!" in part: tag = "yellow"
            elif "✗" in part: tag = "red"
            elif "·" in part: tag = "bold"
            
            self.console.insert(tk.END, clean_part, tag)
            
        self.console.see(tk.END)
        self.console.config(state=tk.DISABLED)
        self.root.update_idletasks()

    def run_command(self, cmd_list, password=None):
        """Ejecuta un comando y captura la salida línea por línea."""
        # Si hay contraseña, la inyectamos en el proceso usando sudo -S
        # Modificamos el comando para que use sudo -S si es un script del proyecto
        
        final_cmd = ["sudo", "-S"] + cmd_list
        
        process = subprocess.Popen(
            final_cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            cwd=self.script_dir
        )
        
        # Enviar contraseña si existe
        if password:
            process.stdin.write(f"{password}\n")
            process.stdin.flush()
        
        for line in process.stdout:
            # Filtrar el prompt de sudo [sudo] password... para que no ensucie el log
            if "[sudo] password for" in line:
                continue
            self.log(line)
        
        return process.wait()

    def run_worker(self):
        items = []
        for key, var in self.vars.items():
            if var.get(): items.append(key)

        if not items:
            messagebox.showwarning("Atención", "No has seleccionado ningún componente.")
            self.root.after(0, lambda: self.start_btn.config(state=tk.NORMAL))
            return

        # Pedir contraseña de forma gráfica
        self.password = simpledialog.askstring("Autenticación", 
                                              "Se requieren permisos de administrador.\nIntroduce tu contraseña:", 
                                              show='*')
        
        if not self.password:
            self.log("\n✗ Instalación cancelada: se requiere contraseña.\n")
            self.root.after(0, lambda: self.start_btn.config(state=tk.NORMAL))
            return

        self.log("\n══ Iniciando instalación con privilegios...\n")
        
        for item in items:
            script_id = item
            self.log(f"\n══ Instalando: {script_id.upper()} ═══════════════\n")
            
            script_map = {
                "terminal": "scripts/01-terminal.sh",
                "vscode": "scripts/02-vscode.sh",
                "git": "scripts/03-git.sh",
                "theme": "scripts/04-gnome-theme.sh",
                "intel": "scripts/05-intel-fix.sh",
                "extensions": "scripts/06-extensions.sh"
            }
            
            exit_code = self.run_command(["bash", script_map[script_id]], self.password)
            if exit_code != 0:
                self.log(f"\n✗ Error en {script_id}. Abortando.\n")
                break
        
        self.log("\n══ PROCESO FINALIZADO ════════════════════\n")
        messagebox.showinfo("Completado", "La instalación ha finalizado. Revisa el log para ver detalles.")
        self.root.after(0, lambda: self.start_btn.config(state=tk.NORMAL))

    def run_install(self):
        self.start_btn.config(state=tk.DISABLED)
        self.console.delete(1.0, tk.END)
        # Ejecutar en un hilo separado para no bloquear la UI
        thread = threading.Thread(target=self.run_worker)
        thread.start()

if __name__ == "__main__":
    root = tk.Tk()
    app = SetupApp(root)
    root.mainloop()
