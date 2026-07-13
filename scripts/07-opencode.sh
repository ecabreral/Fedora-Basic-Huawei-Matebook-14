#!/usr/bin/env bash
# ==============================================================================
# 07-opencode.sh — Instala OpenCode CLI y configura el PATH en zsh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

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
    
    if curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path; then
      success "OpenCode instalado satisfactoriamente"
    else
      error "Error al ejecutar el instalador de OpenCode"
      exit 1
    fi
  fi
fi

# 4. Configurar PATH en zsh (idempotente)
ZSHRC="$HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.opencode/bin:$PATH"'

if [ -f "$ZSHRC" ] && grep -q "\.opencode/bin" "$ZSHRC"; then
  success "El PATH de OpenCode ya está configurado en ~/.zshrc"
else
  info "Configurando PATH en ~/.zshrc..."
  echo "" >> "$ZSHRC"
  echo "# OpenCode CLI" >> "$ZSHRC"
  echo "$PATH_LINE" >> "$ZSHRC"
  success "PATH agregado a ~/.zshrc correctamente"
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
