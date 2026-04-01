#!/usr/bin/env bash
# ==============================================================================
# setup.sh
# Instalador gráfico para la configuración de Fedora 43 en Matebook 14.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

# ── Verificar Dependencias ───────────────────────────────────────────────────
if ! command -v zenity &>/dev/null; then
  warn "Zenity no está instalado. Instalándolo..."
  sudo dnf install -y zenity
fi

# ── Bienvenida ─────────────────────────────────────────────────────────────
zenity --info --title="Fedora 43 Setup" --width=400 \
  --text="🚀 Bienvenido al configurador de Fedora para Huawei Matebook 14.\n\nA continuación podrás elegir qué componentes deseas configurar."

# ── Menú de Selección (Checklist) ───────────────────────────────────────────
SELECTED=$(zenity --list --checklist --title="Selección de Componentes" \
  --width=600 --height=450 \
  --column="Instalar" --column="ID" --column="Componente" \
  TRUE  "terminal"   "Terminal Moderna (zsh, Starship, eza, bat, fzf...)" \
  TRUE  "vscode"     "Visual Studio Code + Extensiones & Configuración" \
  TRUE  "git"        "Git Global + Generación de Clave SSH para GitHub" \
  TRUE  "theme"      "Temas macOS (GTK, Iconos, GDM, Firefox)" \
  FALSE "intel"      "Fix Intel Screen Flicker (Fix parpadeo pantalla)" \
  TRUE  "extensions" "Extensiones GNOME (Dash to Dock, Magic Lamp, etc.)" \
  --hide-column=2 --separator=" ")

# Si el usuario canceló, salir
if [ -z "$SELECTED" ]; then
  info "Instalación cancelada por el usuario."
  exit 0
fi

# ── Ejecución en Terminal ────────────────────────────────────────────────────
# Hacer ejecutables los scripts por si acaso
chmod +x "$SCRIPT_DIR"/scripts/*.sh

# Lanzar gnome-terminal con el gui-launcher.sh
# Pasamos la lista de selecciones como argumentos
info "Iniciando instalación en una nueva ventana de terminal..."

gnome-terminal --title="Instalación de Fedora Setup" -- bash -c "$SCRIPT_DIR/scripts/gui-launcher.sh $SELECTED"

zenity --info --title="Proceso Iniciado" --width=400 \
  --text="✅ La instalación ha comenzado en una ventana de terminal independiente.\n\nPor favor, sigue las instrucciones en la terminal (es posible que se te pida tu contraseña de usuario)."
