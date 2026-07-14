#!/usr/bin/env bash
# ==============================================================================
# 06-extensions.sh
# Guía interactiva para instalar y configurar extensiones de GNOME.
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "🧩 Extensiones GNOME ($OS_NAME)"

# Asegurar que gnome-extensions esté disponible
if ! command -v gnome-extensions &>/dev/null; then
  info "Instalando gnome-extensions..."
  if is_fedora; then
    pkg_install gnome-extensions-app
  elif is_ubuntu; then
    pkg_install gnome-shell-extension-prefs
  fi
fi

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

# Configurar Dash to Dock solo si está instalado
if gnome-extensions list | grep -q "dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread' 2>/dev/null || true
fi

# ── Magic Lamp Effect (desde tu repositorio) ───────────────────────────────────
info "Instalando Compiz Alike Magic Lamp Effect..."
if [ -d "$EXTENSIONS_DIR/compiz-alike-magic-lamp-effect@hermes83.github.com" ]; then
    success "Magic Lamp Effect ya instalado."
else
    MAGIC_LAMP_REPO="https://github.com/ecabreral/compiz-alike-magic-lamp-effect"
    TEMP_DIR=$(mktemp -d)

    if git clone --depth 1 "$MAGIC_LAMP_REPO" "$TEMP_DIR/magic-lamp" 2>/dev/null; then
        # El UUID correcto es compiz-alike-magic-lamp-effect@hermes83.github.com
        EXTENSION_UUID="compiz-alike-magic-lamp-effect@hermes83.github.com"
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

# ── Dynamic Music Pill ───────────────────────────────────────────────────────
info "Instalando Dynamic Music Pill..."
if [ -d "$EXTENSIONS_DIR/dynamic-music-pill@palasso.gitlab.com" ]; then
    success "Dynamic Music Pill ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/9334/dynamic-music-pill/" 2>/dev/null || \
      info "Dynamic Music Pill ya instalado o requiere instalación manual"
fi

# ── Coverflow Alt-Tab ────────────────────────────────────────────────────────
info "Instalando Coverflow Alt-Tab..."
if [ -d "$EXTENSIONS_DIR/coverflow-alt-tab@palasso.gitlab.com" ]; then
    success "Coverflow Alt-Tab ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/97/coverflow-alt-tab/" 2>/dev/null || \
      info "Coverflow Alt-Tab ya instalado o requiere instalación manual"
fi

# ── Burn My Windows ───────────────────────────────────────────────────────────
info "Instalando Burn My Windows..."
if [ -d "$EXTENSIONS_DIR/burn-my-windows@schmidi" ]; then
    success "Burn My Windows ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/4679/burn-my-windows/" 2>/dev/null || \
      info "Burn My Windows ya instalado o requiere instalación manual"
fi

# ── Tiling Shell ──────────────────────────────────────────────────────────────
info "Instalando Tiling Shell..."
if [ -d "$EXTENSIONS_DIR/tiling-shell@ferraro.matias" ]; then
    success "Tiling Shell ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/7065/tiling-shell/" 2>/dev/null || \
      info "Tiling Shell ya instalado o requiere instalación manual"
fi

# ── Desktop Cube ─────────────────────────────────────────────────────────────
info "Instalando Desktop Cube..."
if [ -d "$EXTENSIONS_DIR/desktop-cube@berend.de.schutter" ]; then
    success "Desktop Cube ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/4648/desktop-cube/" 2>/dev/null || \
      info "Desktop Cube ya instalado o requiere instalación manual"
fi

# ── Alphabetical App Grid ────────────────────────────────────────────────────
info "Instalando Alphabetical App Grid..."
if [ -d "$EXTENSIONS_DIR/alphabetical-app-grid@alphabetical-order" ]; then
    success "Alphabetical App Grid ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/4269/alphabetical-app-grid/" 2>/dev/null || \
      info "Alphabetical App Grid ya instalado o requiere instalación manual"
fi

# ── Custom Hot Corners Extended ───────────────────────────────────────────────
info "Instalando Custom Hot Corners Extended..."
if [ -d "$EXTENSIONS_DIR/custom-hot-corners-extended@G-dice" ]; then
    success "Custom Hot Corners Extended ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/4167/custom-hot-corners-extended/" 2>/dev/null || \
      info "Custom Hot Corners Extended ya instalado o requiere instalación manual"
fi

# ── TopHat ───────────────────────────────────────────────────────────────────
info "Instalando TopHat..."
if [ -d "$EXTENSIONS_DIR/tophat@fflewddur.github.io" ]; then
    success "TopHat ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/5219/tophat/" 2>/dev/null || \
      info "TopHat ya instalado o requiere instalación manual"
fi

# ── Media Controls ────────────────────────────────────────────────────────────
info "Instalando Media Controls..."
if [ -d "$EXTENSIONS_DIR/media-controls@cliffniff.github.com" ]; then
    success "Media Controls ya instalado."
else
    gnome-extensions install "https://extensions.gnome.org/extension/4470/media-controls/" 2>/dev/null || \
      info "Media Controls ya instalado o requiere instalación manual"
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
echo "  5. Dynamic Music Pill"
echo "  6. Coverflow Alt-Tab"
echo "  7. Burn My Windows"
echo "  8. Tiling Shell"
echo "  9. Desktop Cube"
echo " 10. Alphabetical App Grid"
echo " 11. Custom Hot Corners Extended"
echo " 12. TopHat"
echo " 13. Media Controls"
echo ""

open_url "https://extensions.gnome.org/extension/307/dash-to-dock/"
open_url "https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/"
open_url "https://extensions.gnome.org/extension/8834/copyous/"
open_url "https://extensions.gnome.org/extension/2236/night-theme-switcher/"
open_url "https://extensions.gnome.org/extension/9334/dynamic-music-pill/"
open_url "https://extensions.gnome.org/extension/97/coverflow-alt-tab/"
open_url "https://extensions.gnome.org/extension/4679/burn-my-windows/"
open_url "https://extensions.gnome.org/extension/7065/tiling-shell/"
open_url "https://extensions.gnome.org/extension/4648/desktop-cube/"
open_url "https://extensions.gnome.org/extension/4269/alphabetical-app-grid/"
open_url "https://extensions.gnome.org/extension/4167/custom-hot-corners-extended/"
open_url "https://extensions.gnome.org/extension/5219/tophat/"
open_url "https://extensions.gnome.org/extension/4470/media-controls/"

if ! command -v xdg-open &>/dev/null; then
    echo ""
    echo "  ⚠️ No se detectó navegador. Copia las URLs arriba y ábrelas manualmente."
fi

echo ""
read -p "  Presiona ENTER para continuar después de activar las extensiones... "

success "Extensiones configuradas."
