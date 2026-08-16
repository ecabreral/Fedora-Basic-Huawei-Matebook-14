#!/usr/bin/env bash
# ==============================================================================
# 04-chrome.sh — Instala Google Chrome en Fedora
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "Google Chrome"

# 1. Verificar si Chrome ya está instalado
if command -v google-chrome-stable &>/dev/null; then
  success "Google Chrome ya está instalado: $(which google-chrome-stable)"
  exit 0
fi

# 2. Agregar repo RPM de Google Chrome
if ! dnf repolist 2>/dev/null | grep -q google-chrome; then
  info "Agregando repositorio de Google Chrome..."
  sudo dnf config-manager addrepo --from-repofile=https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome.repo
  success "Repositorio agregado."
else
  success "Repositorio de Google Chrome ya configurado."
fi

# 3. Instalar Google Chrome
info "Instalando Google Chrome..."
if sudo dnf install -y google-chrome-stable; then
  success "Google Chrome instalado satisfactoriamente."
else
  error "Error al instalar Google Chrome."
  exit 1
fi

# 4. Verificación final
if command -v google-chrome-stable &>/dev/null; then
  success "Google Chrome listo para usar."
fi
