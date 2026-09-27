#!/usr/bin/env bash
# ==============================================================================
# 01-opencode.sh — Instala OpenCode CLI y configura el PATH en zsh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$0")/../../lib/common.sh"

OPENCODE_DIR="$HOME/.opencode/bin"
OPENCODE_BIN="$OPENCODE_DIR/opencode"

section "OpenCode CLI"

# 1. Verificar si ya está en el PATH y funciona
if command -v opencode &>/dev/null; then
  success "OpenCode ya está instalado y configurado: $(which opencode)"
  info "Verificando configuración del PATH..."
else
  # 2. Verificar si el binario ya existe en la carpeta esperada (aunque no esté en PATH)
  if [ -f "$OPENCODE_BIN" ]; then
    info "OpenCode ya existe en $OPENCODE_DIR pero no está en el PATH de esta sesión."
  else
    # 3. Instalación usando el instalador oficial
    info "Descargando e instalando OpenCode CLI..."
    
    curl -fsSL --proto '=https' --tlsv1.2 https://opencode.ai/v2/install -o /tmp/opencode-install.sh
    if bash /tmp/opencode-install.sh --no-modify-path; then
      success "OpenCode instalado satisfactoriamente"
    else
      error "Error al ejecutar el instalador de OpenCode"
      rm -f /tmp/opencode-install.sh
      exit 1
    fi
    rm -f /tmp/opencode-install.sh
  fi
fi

# 4. Configurar PATH en zsh (idempotente)
ZSH_CONF_DIR="$HOME/.config/zsh/conf.d"
PATH_FILE="$ZSH_CONF_DIR/52-opencode.sh"
PATH_LINE='export PATH="$HOME/.opencode/bin:$PATH"'

if [ -f "$PATH_FILE" ] && grep -q "\.opencode/bin" "$PATH_FILE"; then
  success "El PATH de OpenCode ya está configurado"
else
  info "Configurando PATH de OpenCode..."
  mkdir -p "$ZSH_CONF_DIR"
  cat << EOF > "$PATH_FILE"
# OpenCode CLI
$PATH_LINE
EOF
  success "PATH de OpenCode agregado correctamente"
fi

# 5. Habilitar para la sesión actual del script
export PATH="$HOME/.opencode/bin:$PATH"

# Verificación final
if command -v opencode &>/dev/null; then
  success "OpenCode instalado y listo: $(opencode --version 2>/dev/null || echo 'OK')"
  echo ""
  info "Para usar en esta terminal ejecuta: source ~/.zshrc"
else
  warn "Instalación completada, pero 'opencode' no se detecta en la sesión actual."
  info "Ejecuta 'source ~/.zshrc' para activar el comando."
fi
