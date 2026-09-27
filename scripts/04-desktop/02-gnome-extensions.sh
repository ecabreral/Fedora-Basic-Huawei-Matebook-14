#!/usr/bin/env bash
# ==============================================================================
# 02-gnome-extensions.sh
# Instala extensiones de GNOME automáticamente vía la API de extensions.gnome.org
# (sin depender del navegador) y abre sus páginas por si alguna requiere
# activación manual (p. ej. la primera vez que se usa GSConnect).
# ==============================================================================

# No usar set -e: una extensión que falle no debe abortar la instalación de
# las demás; el catálogo ya se instala con "|| true" de forma explícita.
source "$(dirname "$0")/../../lib/common.sh"

section "🧩 Extensiones GNOME ($OS_NAME)"

# Asegurar que gnome-extensions esté disponible (CLI para instalación automatizada)
if ! command -v gnome-extensions &>/dev/null; then
  info "Instalando gnome-extensions (CLI)..."
  if ! pkg_install gnome-extensions; then
    error "No se pudo instalar gnome-extensions. Las extensiones se gestionarán desde Extension Manager."
  fi
fi

# Instalar Extension Manager desde Flathub (interfaz gráfica para gestionar extensiones)
section "Extension Manager"
if command -v flatpak &>/dev/null; then
  if flatpak info com.mattjakeman.ExtensionManager &>/dev/null; then
    success "Extension Manager ya está instalado."
  else
    info "Instalando Extension Manager desde Flathub..."
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    success "Extension Manager instalado."
  fi
else
  warn "Flatpak no está disponible. No se pudo instalar Extension Manager."
  warn "Puedes instalarlo manualmente desde: https://flathub.org/apps/com.mattjakeman.ExtensionManager"
fi

# jq/curl no son necesarios: el parseo del JSON de la API se hace con grep/sed
pkg_install curl >/dev/null 2>&1 || true

# ── Catálogo de extensiones: "pk:Nombre legible" ──────────────────────────────
# pk = ID numérico en la URL https://extensions.gnome.org/extension/<pk>/...
EXTENSIONS_CATALOG=(
  "307:Dash to Dock"
  "8834:Copyous"
  "2236:Night Theme Switcher"
  "9334:Dynamic Music Pill"
  "97:Coverflow Alt-Tab"
  "4679:Burn My Windows"
  "7065:Tiling Shell"
  "4648:Desktop Cube"
  "4269:Alphabetical App Grid"
  "4167:Custom Hot Corners Extended"
  "5219:TopHat"
  "4470:Media Controls"
  "1319:GSConnect"
)

EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXTENSIONS_DIR"

# ── Magic Lamp Effect: se instala desde un fork propio en GitHub ──────────────
info "Instalando Compiz Alike Magic Lamp Effect..."
if [ -d "$EXTENSIONS_DIR/compiz-alike-magic-lamp-effect@hermes83.github.com" ]; then
    success "Magic Lamp Effect ya instalado."
    gnome-extensions enable "compiz-alike-magic-lamp-effect@hermes83.github.com" 2>/dev/null || true
    _record_installed_extension "compiz-alike-magic-lamp-effect@hermes83.github.com"
else
    MAGIC_LAMP_REPO="https://github.com/ecabreral/compiz-alike-magic-lamp-effect"
    TEMP_DIR=$(mktemp -d)

    if git clone --depth 1 "$MAGIC_LAMP_REPO" "$TEMP_DIR/magic-lamp" 2>/dev/null; then
        EXTENSION_UUID="compiz-alike-magic-lamp-effect@hermes83.github.com"
        if [ -d "$TEMP_DIR/magic-lamp/$EXTENSION_UUID" ]; then
            cp -r "$TEMP_DIR/magic-lamp/$EXTENSION_UUID" "$EXTENSIONS_DIR/"
            gnome-extensions enable "$EXTENSION_UUID" 2>/dev/null || true
            _record_installed_extension "$EXTENSION_UUID"
            success "Magic Lamp Effect instalado correctamente."
        else
            for dir in "$TEMP_DIR/magic-lamp"/*; do
                if [ -d "$dir" ]; then
                    cp -r "$dir" "$EXTENSIONS_DIR/"
                    gnome-extensions enable "$(basename "$dir")" 2>/dev/null || true
                    _record_installed_extension "$(basename "$dir")"
                    success "$(basename "$dir") instalado."
                fi
            done
        fi
    else
        warn "No se pudo clonar el fork de Magic Lamp Effect. Intentando desde extensions.gnome.org..."
        install_gnome_extension "3740" "Compiz Alike Magic Lamp Effect" || true
    fi
    rm -rf "$TEMP_DIR"
fi

# ── Resto del catálogo: instalación automática vía API ────────────────────────
for entry in "${EXTENSIONS_CATALOG[@]}"; do
    pk="${entry%%:*}"
    label="${entry#*:}"
    info "Instalando $label..."
    install_gnome_extension "$pk" "$label" || true
done

# ── Ajustes finos post-instalación ───────────────────────────────────────────
if gnome-extensions list 2>/dev/null | grep -q "dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread' 2>/dev/null || true
fi

# ── Resumen de extensiones instaladas ─────────────────────────────────────────
INSTALLED_COUNT=$(gnome-extensions list 2>/dev/null | wc -l)
echo ""
info "Extensiones activas en GNOME: $INSTALLED_COUNT"
echo ""
echo "  Extensiones gestionadas por este instalador:"
echo "  • Dash to Dock              • Burn My Windows"
echo "  • Custom Hot Corners Ext.   • Tiling Shell"
echo "  • Magic Lamp Effect         • Desktop Cube"
echo "  • Copyous                   • Alphabetical App Grid"
echo "  • Night Theme Switcher      • TopHat"
echo "  • Dynamic Music Pill        • Media Controls"
echo "  • Coverflow Alt-Tab         • GSConnect (requiere KDE Connect en el teléfono)"
echo ""

# Abrir Extension Manager (una sola ventana) en vez de 13 pestañas del navegador.
# Si no está disponible, se abre solo la página de Dash to Dock como referencia.
if [ -t 0 ]; then
  if flatpak info com.mattjakeman.ExtensionManager &>/dev/null; then
    info "Abriendo Extension Manager para gestionar/configurar las extensiones."
    flatpak run com.mattjakeman.ExtensionManager &>/dev/null &
    disown 2>/dev/null || true
  else
    info "Abriendo la página de extensiones GNOME en tu navegador."
    open_url "https://extensions.gnome.org/"
  fi
else
  info "Modo no interactivo: se omite la apertura del navegador."
  info "Para gestionar las extensiones usa: Extension Manager (Flathub)"
fi

echo ""
wait_for_enter

success "Extensiones configuradas."
wait_for_enter
