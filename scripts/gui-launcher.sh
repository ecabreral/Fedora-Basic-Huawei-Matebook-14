#!/usr/bin/env bash
# ==============================================================================
# gui-launcher.sh
# Ejecuta los scripts seleccionados en el instalador gráfico.
# ==============================================================================

# Verificar si se tiene sudo
if ! sudo -n true 2>/dev/null; then
  echo ""
  echo "⚠️ Algunos scripts requieren permisos de administrador (sudo)."
  echo "   Se te pedirá tu contraseña cuando sea necesario."
  echo ""
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

# Configurar logging
LOG_FILE="$SCRIPT_DIR/install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== $(date) - Inicio de instalación ==="
echo "Log guardado en: $LOG_FILE"
echo ""
echo "Argumentos recibidos: $@"
echo "TERMINAL_THEME (entorno): $TERMINAL_THEME"

# Recibir los scripts seleccionados como argumentos
# Ejemplo: ./gui-launcher.sh terminal vscode theme
SELECTED_IDS=("$@")
TOTAL=${#SELECTED_IDS[@]}
CURRENT=0

# El tema de terminal viene de la variable de entorno TERMINAL_THEME
if [ -n "$TERMINAL_THEME" ]; then
  TERMINAL_THEME="$TERMINAL_THEME"
else
  TERMINAL_THEME="tokyo-night"
fi

clear
echo ""
echo -e "${BLUE}${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}${BOLD}║     🚀  Ejecutando Instalación...      ║${RESET}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════╝${RESET}"
echo ""

step() { 
  CURRENT=$((CURRENT + 1))
  echo -e "${BLUE}${BOLD}[${CURRENT}/${TOTAL}] $1${RESET}"
}

for ID in "${SELECTED_IDS[@]}"; do
  case "$ID" in
    "base")
      step "Sistema Base (Repositorios, Códecs, VA-API, Flatpak)"
      set +e
      sudo "$SCRIPT_DIR/scripts/00-base-system.sh"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en sistema base. Continuando..."
      fi
      ;;
    "terminal")
      step "Terminal & Herramientas"
      THEME="${TERMINAL_THEME:-tokyo-night}"
      set +e
      "$SCRIPT_DIR/scripts/01-terminal.sh" "$THEME"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en terminal. Continuando..."
      fi
      ;;
    "vscode")
      step "Visual Studio Code"
      set +e
      sudo "$SCRIPT_DIR/scripts/02-vscode.sh"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en VS Code. Continuando..."
      fi
      ;;
    "git")
      step "Git + GitHub"
      set +e
      "$SCRIPT_DIR/scripts/03-git.sh"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en Git. Continuando..."
      fi
      ;;
    "theme")
      step "Temas GNOME estilo macOS"
      set +e
      "$SCRIPT_DIR/scripts/04-gnome-theme.sh"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en tema. Continuando..."
      fi
      ;;
    "intel")
      step "Fix Intel Screen Flicker"
      if lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
        set +e
        sudo "$SCRIPT_DIR/scripts/05-intel-fix.sh"
        RESULT=$?
        set -e
        if [ $RESULT -ne 0 ]; then
          warn "Error en Intel Fix. Continuando..."
        fi
      else
        warn "GPU Intel no detectada. Omitiendo 05-intel-fix.sh"
      fi
      ;;
    "extensions")
      step "Extensiones GNOME"
      set +e
      "$SCRIPT_DIR/scripts/06-extensions.sh"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en extensiones. Continuando..."
      fi
      ;;
    "opencode")
      step "OpenCode CLI"
      set +e
      "$SCRIPT_DIR/scripts/07-opencode.sh"
      RESULT=$?
      set -e
      if [ $RESULT -ne 0 ]; then
        warn "Error en OpenCode. Continuando..."
      fi
      ;;
  esac
  echo ""
done

# ── Agregar OpenCode al PATH ─────────────────────────────────────────────
if command -v opencode &>/dev/null; then
  if ! grep -q '\.opencode/bin' ~/.zshrc 2>/dev/null; then
    info "Agregando OpenCode al PATH..."
    echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.zshrc
  fi
  source ~/.zshrc
fi

# ── Resumen Final ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║        ✅  Proceso Completado!         ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════╝${RESET}"
echo ""
echo "  Resumen de lo configurado:"
for ID in "${SELECTED_IDS[@]}"; do
  case "$ID" in
    "base")        echo "   • Sistema Base (RPM Fusion, códecs, VA-API, Flatpak)" ;;
    "terminal")   echo "   • Terminal moderna (zsh, Starship, eza...)" ;;
    "vscode")     echo "   • Visual Studio Code + Configuración" ;;
    "git")        echo "   • Git & Clave SSH para GitHub" ;;
    "theme")      echo "   • Temas GTK/Icons/GDM WhiteSur" ;;
    "intel")      echo "   • Parámetros del kernel Intel (Flicker Fix)" ;;
    "extensions") echo "   • Extensiones GNOME (Dash to Dock...)" ;;
    "opencode")   echo "   • OpenCode CLI (IA Assistant)" ;;
  esac
done
echo ""
warn "Si instalaste temas, cierra sesión y vuelve a iniciar."
echo ""
read -p "Presiona ENTER para cerrar esta ventana... "
