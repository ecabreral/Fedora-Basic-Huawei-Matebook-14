#!/usr/bin/env bash
# ==============================================================================
# 03-brave.sh — Instala Brave Browser y configura alias bravefix
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "Brave Browser"

# 1. Verificar si Brave ya está instalado
if command -v brave-browser &>/dev/null; then
  success "Brave Browser ya está instalado: $(which brave-browser)"
else
  # 2. Instalación usando el instalador oficial
  info "Descargando e instalando Brave Browser..."

  if curl -fsS https://dl.brave.com/install.sh | sh; then
    success "Brave Browser instalado satisfactoriamente"
  else
    error "Error al ejecutar el instalador de Brave Browser"
    exit 1
  fi
fi

# 3. Configurar alias bravefix en ~/.zshrc (idempotente)
ZSHRC="$HOME/.zshrc"
BRAVEFIX_LINE="alias bravefix='pkill -f brave >/dev/null 2>&1; rm -f ~/.config/BraveSoftware/Brave-Browser/Singleton*; brave-browser'"

if [ -f "$ZSHRC" ] && grep -q "bravefix" "$ZSHRC"; then
  success "El alias bravefix ya está configurado en ~/.zshrc"
else
  info "Configurando alias bravefix en ~/.zshrc..."
  echo "" >> "$ZSHRC"
  echo "# Brave Browser - Fix para perfil bloqueado" >> "$ZSHRC"
  echo "$BRAVEFIX_LINE" >> "$ZSHRC"
  success "Alias bravefix agregado a ~/.zshrc correctamente"
fi

# 4. Verificación final
if command -v brave-browser &>/dev/null; then
  success "Brave Browser instalado y listo"
  echo ""
  info "Si Brave queda bloqueado, ejecuta: bravefix"
  info "Para usar en esta terminal ejecuta: source ~/.zshrc"
else
  warn "Instalación completada, pero 'brave-browser' no se detecta en la sesión actual."
  info "Ejecuta 'source ~/.zshrc' para activar el comando."
fi
