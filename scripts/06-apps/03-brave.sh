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

  curl -fsS --proto '=https' --tlsv1.2 https://dl.brave.com/install.sh -o /tmp/brave-install.sh
  if sh /tmp/brave-install.sh; then
    success "Brave Browser instalado satisfactoriamente"
  else
    error "Error al ejecutar el instalador de Brave Browser"
    rm -f /tmp/brave-install.sh
    exit 1
  fi
  rm -f /tmp/brave-install.sh
fi

# 3. Configurar alias bravefix en ~/.config/zsh/conf.d/ (idempotente)
ZSH_CONF_DIR="$HOME/.config/zsh/conf.d"
BRAVEFIX_FILE="$ZSH_CONF_DIR/50-brave.sh"
BRAVEFIX_LINE="alias bravefix='pkill -f brave >/dev/null 2>&1; rm -f ~/.config/BraveSoftware/Brave-Browser/Singleton*; brave-browser'"

if [ -f "$BRAVEFIX_FILE" ] && grep -q "bravefix" "$BRAVEFIX_FILE"; then
  success "El alias bravefix ya está configurado"
else
  info "Configurando alias bravefix..."
  mkdir -p "$ZSH_CONF_DIR"
  cat << EOF > "$BRAVEFIX_FILE"
# Brave Browser - Fix para perfil bloqueado
$BRAVEFIX_LINE
EOF
  success "Alias bravefix agregado correctamente"
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
