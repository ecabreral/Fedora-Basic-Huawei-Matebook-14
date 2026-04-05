#!/usr/bin/env bash
# ==============================================================================
# setup.sh
# Instalador gráfico para la configuración de Fedora 43 en Matebook 14.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Verificar Dependencias de Python ─────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "Python 3 no está instalado. Por favor, instálalo primero."
  exit 1
fi

# ── Intentar iniciar la GUI Python ───────────────────────────────────────────
if python3 "$SCRIPT_DIR/main.py"; then
  exit 0
fi

# Fallback: Si la GUI Python falla, intentar Zenity
echo "Intentando interfaz Zenity..."

source "$SCRIPT_DIR/scripts/lib.sh"

if ! command -v zenity &>/dev/null; then
  warn "Zenity no está instalado. Instalándolo..."
  sudo dnf install -y zenity
fi

zenity --info --title="Fedora 43 Setup" --width=400 \
  --text="🚀 Bienvenido al configurador de Fedora para Huawei Matebook 14.\n\nA continuación podrás elegir qué componentes deseas configurar."

SELECTED=$(zenity --list --checklist --title="Selección de Componentes" \
  --width=600 --height=450 \
  --column="Instalar" --column="ID" --column="Componente" \
  TRUE  "terminal"   "Terminal Moderna (zsh, Starship, eza, bat, fzf...)" \
  TRUE  "vscode"     "Visual Studio Code + Extensiones & Configuración" \
  TRUE  "git"        "Git Global + Generación de Clave SSH para GitHub" \
  TRUE  "theme"      "Temas macOS (GTK, Iconos, GDM, Firefox)" \
  FALSE "intel"      "Fix Intel Screen Flicker (Fix parpadeo pantalla)" \
  TRUE  "extensions" "Extensiones GNOME (Dash to Dock, Magic Lamp, etc.)" \
  TRUE  "opencode"   "OpenCode CLI (Asistente de IA para Terminal)" \
  --hide-column=2 --separator=" ")

if [ -z "$SELECTED" ]; then
  info "Instalación cancelada por el usuario."
  exit 0
fi

chmod +x "$SCRIPT_DIR"/scripts/*.sh
info "Preparando la ejecución..."

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
  info "No se detectó un emulador de terminal gráfico. Ejecutando en la terminal actual..."
  echo ""
  bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
fi
