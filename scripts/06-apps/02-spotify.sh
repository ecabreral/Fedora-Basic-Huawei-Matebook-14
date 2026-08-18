#!/usr/bin/env bash
# ==============================================================================
# 08-spotify.sh
# Instala Spotify desde Flathub.
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "Spotify"

if ! command -v flatpak &>/dev/null; then
    info "Flatpak no está instalado. Instalando..."
    pkg_install flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if ! flatpak remote-list 2>/dev/null | grep -q "flathub"; then
    info "Añadiendo Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if flatpak list | grep -q "spotify.com"; then
    success "Spotify ya está instalado."
else
    info "Instalando Spotify desde Flathub..."
    flatpak install -y flathub com.spotify.Client
    flatpak override --user com.spotify.Client --no-desktop
    success "Override aplicado: botones de minimizar/maximizar habilitados."
    success "Spotify instalado correctamente."
fi

info "Spotify está disponible en el menú de aplicaciones."
info "Si no aparece, reinicia GNOME Shell (Alt+F2 → r → Enter)."
