#!/usr/bin/env bash
# ==============================================================================
# 06-extensions.sh
# Guía interactiva para instalar y configurar extensiones de GNOME.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"
init_log
trap cleanup_log EXIT

REAL_USER="${SUDO_USER:-$USER}"

section "🧩 Extensiones GNOME"

echo ""
echo "  Instala y activa las siguientes extensiones:"
echo ""
echo "  1. Dash to Dock      → https://extensions.gnome.org/extension/307/dash-to-dock/"
echo "  2. Magic Lamp Effect → https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/"
echo "  3. Copyous           → https://extensions.gnome.org/extension/8834/copyous/"
echo "  4. Night Theme Switcher → https://extensions.gnome.org/extension/2236/night-theme-switcher/"
echo ""

info "Abriendo páginas de extensiones GNOME..."

EXTENSIONS=(
  "https://extensions.gnome.org/extension/307/dash-to-dock/"
  "https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/"
  "https://extensions.gnome.org/extension/8834/copyous/"
  "https://extensions.gnome.org/extension/2236/night-theme-switcher/"
)

sudo -u "$REAL_USER" firefox "${EXTENSIONS[@]}" 2>/dev/null &

sleep 2
success "Navegador abierto con las páginas de extensiones."

if [ "$NONINTERACTIVE" = "false" ]; then
    echo ""
    read -p "  Activa las extensiones y presiona ENTER para continuar... "
fi

# ── Configuración Dash to Dock ───────────────────────────────────────────────
info "Aplicando configuración avanzada de Dash to Dock..."
sudo -u "$REAL_USER" gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread' 2>/dev/null || true
success "Configuración del dock aplicada: clic para minimizar/enfocar."

success "Extensiones configuradas."
