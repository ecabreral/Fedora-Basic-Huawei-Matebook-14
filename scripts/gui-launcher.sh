#!/usr/bin/env bash
# ==============================================================================
# gui-launcher.sh
# Ejecuta los scripts seleccionados en el instalador gráfico.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

# Función para reportar errores
error_handler() {
  echo ""
  error "¡Error crítico detectado en la instalación!"
  warn "El script falló en el comando: ${BOLD}${BASH_COMMAND}${RESET}"
  echo ""
  read -p "Presiona ENTER para salir..."
  exit 1
}
trap 'error_handler' ERR

# Recibir los scripts seleccionados como argumentos (separados por espacios)
# Ejemplo: ./gui-launcher.sh terminal vscode theme ...
SELECTED_IDS=("$@")
TOTAL=${#SELECTED_IDS[@]}
CURRENT=0

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
    "terminal")
      step "Terminal & Herramientas"
      "$SCRIPT_DIR/scripts/01-terminal.sh"
      ;;
    "vscode")
      step "Visual Studio Code"
      sudo "$SCRIPT_DIR/scripts/02-vscode.sh"
      ;;
    "git")
      step "Git + GitHub"
      "$SCRIPT_DIR/scripts/03-git.sh"
      ;;
    "theme")
      step "Temas GNOME estilo macOS"
      "$SCRIPT_DIR/scripts/04-gnome-theme.sh"
      ;;
    "intel")
      step "Fix Intel Screen Flicker"
      if lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
        sudo "$SCRIPT_DIR/scripts/05-intel-fix.sh"
      else
        warn "GPU Intel no detectada. Omitiendo 05-intel-fix.sh"
      fi
      ;;
    "extensions")
      step "Extensiones GNOME"
      "$SCRIPT_DIR/scripts/06-extensions.sh"
      ;;
    "opencode")
      step "OpenCode CLI"
      "$SCRIPT_DIR/scripts/07-opencode.sh"
      ;;
  esac
  echo ""
done

# ── Resumen Final ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║        ✅  Proceso Completado!         ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════╝${RESET}"
echo ""
echo "  Resumen de lo configurado:"
for ID in "${SELECTED_IDS[@]}"; do
  case "$ID" in
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
