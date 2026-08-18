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
if is_fedora && ! dnf repolist 2>/dev/null | grep -q google-chrome; then
  info "Agregando repositorio de Google Chrome..."
  sudo dnf config-manager addrepo --from-repofile=https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome.repo
  success "Repositorio agregado."
else
  success "Repositorio de Google Chrome ya configurado."
fi

# 3. Instalar Google Chrome
info "Instalando Google Chrome..."
if platform_install_packages google-chrome-stable; then
  success "Google Chrome instalado satisfactoriamente."
else
  error "Error al instalar Google Chrome."
  exit 1
fi

# 4. Configurar alias chromefix en ~/.zshrc (idempotente)
ZSHRC="$HOME/.zshrc"
CHROMEFIX_LINE="alias chromefix='pkill -f chrome >/dev/null 2>&1; rm -f ~/.config/google-chrome/SingletonLock ~/.config/google-chrome/SingletonSocket ~/.config/google-chrome/SingletonCookie; google-chrome-stable'"

if [ -f "$ZSHRC" ] && grep -q "chromefix" "$ZSHRC"; then
  success "El alias chromefix ya está configurado en ~/.zshrc"
else
  info "Configurando alias chromefix en ~/.zshrc..."
  echo "" >> "$ZSHRC"
  echo "# Google Chrome - Fix para perfil bloqueado" >> "$ZSHRC"
  echo "$CHROMEFIX_LINE" >> "$ZSHRC"
  success "Alias chromefix agregado a ~/.zshrc correctamente"
fi

# 5. Verificación final
if command -v google-chrome-stable &>/dev/null; then
  success "Google Chrome listo para usar."
  echo ""
  info "Si Chrome queda bloqueado, ejecuta: chromefix"
  info "Para usar en esta terminal ejecuta: source ~/.zshrc"
else
  warn "Instalación completada, pero 'google-chrome-stable' no se detecta en la sesión actual."
  info "Ejecuta 'source ~/.zshrc' para activar el comando."
fi
