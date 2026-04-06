#!/usr/bin/env bash
# ==============================================================================
# 06-extensions.sh
# Guía interactiva para instalar y configurar extensiones de GNOME.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"

section "🧩 Extensiones GNOME"

EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"

mkdir -p "$EXTENSIONS_DIR"

# ── Dash to Dock ──────────────────────────────────────────────────────────────
info "Instalando Dash to Dock..."
if [ -d "$EXTENSIONS_DIR/dash-to-dock@micxgx.gmail.com" ]; then
    success "Dash to Dock ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/307/dash-to-dock/" 2>/dev/null || \
      info "Dash to Dock ya instalado o requiere instalación manual"
fi
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread'

# ── Magic Lamp Effect (desde tu repositorio) ───────────────────────────────────
info "Instalando Compiz Alike Magic Lamp Effect..."
if [ -d "$EXTENSIONS_DIR/compiz-alike-magic-lamp-effect@he fury" ] || [ -d "$EXTENSIONS_DIR/compiz-alike-magic-lamp-effect@hermes84" ]; then
    success "Magic Lamp Effect ya instalado."
else
    MAGIC_LAMP_REPO="https://github.com/ecabreral/compiz-alike-magic-lamp-effect"
    TEMP_DIR=$(mktemp -d)

    if git clone "$MAGIC_LAMP_REPO" "$TEMP_DIR/magic-lamp" 2>/dev/null; then
        EXTENSION_UUID="compiz-alike-magic-lamp-effect@he fury"
        if [ -d "$TEMP_DIR/magic-lamp/$EXTENSION_UUID" ]; then
            cp -r "$TEMP_DIR/magic-lamp/$EXTENSION_UUID" "$EXTENSIONS_DIR/"
            success "Magic Lamp Effect instalado correctamente."
        elif [ -d "$TEMP_DIR/magic-lamp" ]; then
            for dir in "$TEMP_DIR/magic-lamp"/*; do
                if [ -d "$dir" ]; then
                    cp -r "$dir" "$EXTENSIONS_DIR/"
                    success "$(basename "$dir") instalado."
                fi
            done
        fi
    else
        warn "No se pudo clonar Magic Lamp Effect. Instalando desde GNOME Extensions..."
        gnome-extensions install "https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/" 2>/dev/null || true
    fi
    rm -rf "$TEMP_DIR"
fi

# ── Copyous ────────────────────────────────────────────────────────────────────
info "Instalando Copyous..."
if [ -d "$EXTENSIONS_DIR/copyous@ambrice.dev" ]; then
    success "Copyous ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/8834/copyous/" 2>/dev/null || \
      info "Copyous ya instalado o requiere instalación manual"
fi

# ── Night Theme Switcher ─────────────────────────────────────────────────────
info "Instalando Night Theme Switcher..."
if [ -d "$EXTENSIONS_DIR/nightthemeswitcher@romainvigier.fr" ]; then
    success "Night Theme Switcher ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/2236/night-theme-switcher/" 2>/dev/null || \
      info "Night Theme Switcher ya instalado o requiere instalación manual"
fi

# ── Función helper para abrir URLs ─────────────────────────────────────────────
open_url() {
    local url="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" &
    else
        echo "  🔗 $url"
    fi
}

# ── Abrir páginas de extensiones ─────────────────────────────────────────────
info "Abriendo páginas de extensiones GNOME en tu navegador para activar..."
echo ""
echo "  Activa las siguientes extensiones:"
echo "  1. Dash to Dock"
echo "  2. Magic Lamp Effect"
echo "  3. Copyous"
echo "  4. Night Theme Switcher"
echo ""

open_url "https://extensions.gnome.org/extension/307/dash-to-dock/"
open_url "https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/"
open_url "https://extensions.gnome.org/extension/8834/copyous/"
open_url "https://extensions.gnome.org/extension/2236/night-theme-switcher/"

if ! command -v xdg-open &>/dev/null; then
    echo ""
    echo "  ⚠️ No se detectó navegador. Copia las URLs arriba y ábrelas manualmente."
fi

echo ""
read -p "  Presiona ENTER para continuar después de activar las extensiones... "

success "Extensiones configuradas."
