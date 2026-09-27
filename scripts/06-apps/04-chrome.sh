#!/usr/bin/env bash
# ==============================================================================
# 04-chrome.sh — Instala Google Chrome en Fedora
# ==============================================================================

# No usar set -e: cada paso reporta su propio error.
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
  if ! sudo dnf config-manager addrepo --from-repofile=https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome.repo; then
    error "No se pudo agregar el repositorio de Google Chrome."
    exit 1
  fi
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

# 4. Configurar alias chromefix en ~/.config/zsh/conf.d/ (idempotente)
ZSH_CONF_DIR="$HOME/.config/zsh/conf.d"
CHROMEFIX_FILE="$ZSH_CONF_DIR/51-chrome.sh"
CHROMEFIX_LINE="alias chromefix='pkill -f chrome >/dev/null 2>&1; rm -f ~/.config/google-chrome/SingletonLock ~/.config/google-chrome/SingletonSocket ~/.config/google-chrome/SingletonCookie; google-chrome-stable'"

if [ -f "$CHROMEFIX_FILE" ] && grep -q "chromefix" "$CHROMEFIX_FILE"; then
  success "El alias chromefix ya está configurado"
else
  info "Configurando alias chromefix..."
  mkdir -p "$ZSH_CONF_DIR"
  cat << EOF > "$CHROMEFIX_FILE"
# Google Chrome - Fix para perfil bloqueado
$CHROMEFIX_LINE
EOF
  success "Alias chromefix agregado correctamente"
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
wait_for_enter
