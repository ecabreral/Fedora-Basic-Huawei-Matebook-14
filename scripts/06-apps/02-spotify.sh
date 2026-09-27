#!/usr/bin/env bash
# ==============================================================================
# 02-spotify.sh
# Instala Spotify desde Flathub.
# ==============================================================================

# No usar set -e: cada paso reporta su propio error para no abortar en silencio.
source "$(dirname "$0")/../../lib/common.sh"

section "Spotify"

if ! command -v flatpak &>/dev/null; then
    info "Flatpak no está instalado. Instalando..."
    if ! pkg_install flatpak; then
        error "No se pudo instalar Flatpak. Spotify requiere Flatpak."
        exit 1
    fi
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if ! flatpak remote-list 2>/dev/null | grep -q "flathub"; then
    info "Añadiendo Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if flatpak list 2>/dev/null | grep -q "spotify.com"; then
    success "Spotify ya está instalado."
else
    info "Instalando Spotify desde Flathub..."
    if flatpak install -y flathub com.spotify.Client; then
        flatpak override --user com.spotify.Client --no-desktop
        success "Override aplicado: botones de minimizar/maximizar habilitados."
        success "Spotify instalado correctamente."
    else
        error "No se pudo instalar Spotify desde Flathub."
        exit 1
    fi
fi

info "Spotify está disponible en el menú de aplicaciones."
info "Si no aparece, reinicia GNOME Shell (Alt+F2 → r → Enter)."
