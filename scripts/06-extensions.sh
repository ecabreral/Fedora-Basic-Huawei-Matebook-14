#!/usr/bin/env bash
# ==============================================================================
# 06-extensions.sh
# Guía interactiva para instalar y configurar extensiones de GNOME.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"

section "🧩 Extensiones GNOME"

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

echo ""
read -p "  Activa las extensiones y presiona ENTER para continuar... "

# ── Configuración Dash to Dock ───────────────────────────────────────────────
info "Aplicando configuración avanzada de Dash to Dock..."
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread'
success "Configuración del dock aplicada: clic para minimizar/enfocar."

success "Extensiones configuradas."
