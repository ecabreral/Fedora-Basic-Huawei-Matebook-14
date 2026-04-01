#!/usr/bin/env bash
# ==============================================================================
# setup.sh
# Punto de entrada principal de configuración de Fedora 43.
# Ejecuta todos los scripts en orden.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

# ── Verificar Fedora ──────────────────────────────────────────────────────────
if [ ! -f /etc/fedora-release ]; then
  warn "No se detectó Fedora. Este script está diseñado para Fedora 43."
  read -p "  ¿Continuar de todas formas? [s/N]: " CONT
  [[ "$CONT" != "s" && "$CONT" != "S" ]] && exit 1
fi

TOTAL=6
step() { echo ""; echo -e "${BLUE}${BOLD}[${1}/${TOTAL}] $2${RESET}"; echo ""; }

clear
echo ""
echo -e "${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║     🚀  Fedora 43 Setup Script         ║${RESET}"
echo -e "${BOLD}╚════════════════════════════════════════╝${RESET}"
echo ""

# Hacer todos los scripts ejecutables
chmod +x "$SCRIPT_DIR"/scripts/*.sh

# ─────────────────────────────────────────────────────────────────────────────
step 1 "Terminal & Herramientas"
"$SCRIPT_DIR/scripts/01-terminal.sh"

# ─────────────────────────────────────────────────────────────────────────────
step 2 "Visual Studio Code"
sudo "$SCRIPT_DIR/scripts/02-vscode.sh"

# ─────────────────────────────────────────────────────────────────────────────
step 3 "Git + GitHub"
"$SCRIPT_DIR/scripts/03-git.sh"

# ─────────────────────────────────────────────────────────────────────────────
step 4 "Temas GNOME estilo macOS"
"$SCRIPT_DIR/scripts/04-gnome-theme.sh"

# ─────────────────────────────────────────────────────────────────────────────
step 5 "Fix Intel Screen Flicker"
if lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
  sudo "$SCRIPT_DIR/scripts/05-intel-fix.sh"
else
  warn "GPU Intel no detectada. Omitiendo 05-intel-fix.sh"
fi

# ─────────────────────────────────────────────────────────────────────────────
step 6 "Extensiones GNOME"
echo ""
info "Abriendo páginas de extensiones GNOME en tu navegador..."
echo ""
echo "  Instala y activa las siguientes extensiones:"
echo ""
echo "  1. Dash to Dock      → https://extensions.gnome.org/extension/307/dash-to-dock/"
echo "  2. Magic Lamp Effect → https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/"
echo "  3. Copyous           → https://extensions.gnome.org/extension/8834/copyous/"
echo "  4. Night Theme Switcher → https://extensions.gnome.org/extension/2236/night-theme-switcher/"
echo ""

xdg-open "https://extensions.gnome.org/extension/307/dash-to-dock/"             2>/dev/null &
xdg-open "https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/" 2>/dev/null &
xdg-open "https://extensions.gnome.org/extension/8834/copyous/"                  2>/dev/null &
xdg-open "https://extensions.gnome.org/extension/2236/night-theme-switcher/"     2>/dev/null &

read -p "  Activa las extensiones y presiona ENTER para continuar... "

# ── Configuración Dash to Dock ───────────────────────────────────────────────
info "Aplicando configuración avanzada de Dash to Dock..."
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread'
success "Configuración del dock aplicada: clic para minimizar/enfocar."

# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║        ✅  Setup Completo!             ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════╝${RESET}"
echo ""
echo "  Resumen de lo instalado:"
echo "   • Terminal:   zsh + Starship + eza + bat + fzf + zoxide"
echo "   • Editor:     Visual Studio Code (GitHub Light/Dark)"
echo "   • Git/SSH:    Configurado con GitHub"
echo "   • GTK Theme:  WhiteSur-Light / WhiteSur-Dark"
echo "   • GDM:        MacTahoe"
echo "   • Firefox:    WhiteSur Firefox Theme"
echo ""
warn "Cierra sesión y vuelve a iniciar para que GNOME recargue los temas."
echo ""
echo "  📖 Ver: docs/dash-to-dock.md para configuración adicional."
echo ""
