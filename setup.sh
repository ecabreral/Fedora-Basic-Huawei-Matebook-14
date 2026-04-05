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

# ── Ejecución de la Instalación ───────────────────────────────────────────────
chmod +x "$SCRIPT_DIR"/scripts/*.sh

info "Preparando la ejecución..."

# Intentar detectar un emulador de terminal para abrir en ventana nueva
TERM_CMD=""
if command -v gnome-terminal &>/dev/null; then
  TERM_CMD="gnome-terminal --title='Instalación de Fedora Setup' --"
elif command -v kgx &>/dev/null; then
  TERM_CMD="kgx --title='Instalación de Fedora Setup' -e"
elif command -v gnome-console &>/dev/null; then
  TERM_CMD="gnome-console --title='Instalación de Fedora Setup' -e"
fi

if [ -n "$TERM_CMD" ]; then
  info "Iniciando instalación en una nueva ventana de terminal..."
  $TERM_CMD bash -c "$SCRIPT_DIR/scripts/gui-launcher.sh $SELECTED"
  
  zenity --info --title="Proceso Iniciado" --width=400 \
    --text="✅ La instalación ha comenzado en una ventana de terminal independiente.\n\nPor favor, sigue las instrucciones en esa ventana."
else
  # Fallback: Ejecutar en la terminal actual si no se detecta emulador gráfico
  info "No se detectó un emulador de terminal gráfico. Ejecutando en la terminal actual..."
  echo ""
  bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
fi
