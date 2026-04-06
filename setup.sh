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

# Si terminal está seleccionado, pedir tema de Starship
if echo "$SELECTED" | grep -qw "terminal"; then
  THEME=$(zenity --list --radiolist --title="Tema de Starship" \
      --width=600 --height=450 \
      --column="Seleccionar" --column="ID" --column="Tema" \
      TRUE  "tokyo-night"            "🌙 Tokyo Night (oscuro, recomendado)" \
      FALSE "pastel-powerline"        "🎨 Pastel Powerline (claro)" \
      FALSE "gruvbox-rainbow"         "🟤 Gruvbox Rainbow (oscuro)" \
      FALSE "catppuccin-powerline"    "🟣 Catppuccin Powerline (oscuro)" \
      FALSE "jetpack"                 "🚀 Jetpack (minimalista)" \
      FALSE "pure-preset"             "⚡ Pure Prompt (clásico)" \
      FALSE "nerd-font-symbols"       "🔣 Nerd Font Symbols" \
      FALSE "no-nerd-font"            "🔤 Sin Nerd Font" \
      FALSE "bracketed-segments"      "🔲 Bracketed Segments" \
      FALSE "plain-text"               "📝 Plain Text" \
      FALSE "no-runtimes"             "🚫 Sin Runtime Versions" \
      FALSE "no-empty-icons"          "🚫 Sin Iconos Vacíos" \
      --hide-column=2)
  
  if [ -n "$THEME" ]; then
    export TERMINAL_THEME="$THEME"
    info "Tema seleccionado: $TERMINAL_THEME"
  fi
fi

chmod +x "$SCRIPT_DIR"/scripts/*.sh
info "Preparando la ejecución..."

# Agregar tema de terminal si está seleccionado
TERMINAL_ARG=""
if [ -n "$TERMINAL_THEME" ]; then
  SELECTED="$SELECTED"
  TERMINAL_ARG="$TERMINAL_THEME"
fi

TERM_CMD=""
if command -v ptyxis &>/dev/null; then
  TERM_CMD="ptyxis --title='Instalación de Fedora Setup' -e"
elif command -v gnome-terminal &>/dev/null; then
  TERM_CMD="gnome-terminal --title='Instalación de Fedora Setup' --"
elif command -v kgx &>/dev/null; then
  TERM_CMD="kgx --title='Instalación de Fedora Setup' -e"
elif command -v gnome-console &>/dev/null; then
  TERM_CMD="gnome-console --title='Instalación de Fedora Setup' -e"
fi

if [ -n "$TERM_CMD" ]; then
  info "Iniciando instalación en una nueva ventana de terminal..."
  if [ -n "$TERMINAL_ARG" ]; then
    $TERM_CMD bash -c "TERMINAL_THEME=$TERMINAL_ARG $SCRIPT_DIR/scripts/gui-launcher.sh $SELECTED"
  else
    $TERM_CMD bash -c "$SCRIPT_DIR/scripts/gui-launcher.sh $SELECTED"
  fi
  zenity --info --title="Proceso Iniciado" --width=400 \
    --text="✅ La instalación ha comenzado en una ventana de terminal independiente.\n\nPor favor, sigue las instrucciones en esa ventana."
else
  info "No se detectÃ³ un emulador de terminal grÃ¡fico. Ejecutando en la terminal actual..."
  echo ""
  if [ -n "$TERMINAL_ARG" ]; then
    TERMINAL_THEME="$TERMINAL_ARG" bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
  else
    bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
  fi
fi
