#!/usr/bin/env bash
# ==============================================================================
# 05-intel-fix.sh
# Corrige el parpadeo de pantalla en GPUs Intel aplicando parámetros de kernel.
# Requiere: sudo, reinicio
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"
init_log
trap cleanup_log EXIT
require_root

REAL_USER="${SUDO_USER:-$USER}"

section "🔧 Fix Intel Screen Flicker"

# ── 1. Detectar GPU Intel ─────────────────────────────────────────────────────
if ! lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
  warn "No se detectó una GPU Intel en este sistema."
  warn "Este script está diseñado solo para GPUs Intel (driver i915)."
  if [ "${FORCE_INTEL_FIX:-false}" != "true" ]; then
    echo ""
    read -p "  ¿Aplicar parámetros de todas formas? [s/N]: " FORCE
    [[ "$FORCE" != "s" && "$FORCE" != "S" ]] && exit 0
  fi
fi

# ── 2. Verificar grubby ────────────────────────────────────────────────────────
if ! command -v grubby &>/dev/null; then
  info "Instalando grubby..."
  dnf install -y grubby
fi

# ── 3. Aplicar parámetros del kernel ──────────────────────────────────────────
info "Aplicando parámetros del kernel con grubby..."
grubby --update-kernel=ALL --args="i915.enable_psr=0 i915.enable_dc=0 intel_idle.max_cstate=2"
success "Parámetros aplicados correctamente."

# ── 4. Verificar que se aplicaron ─────────────────────────────────────────────
info "Parámetros activos en el kernel:"
grubby --info=DEFAULT | grep args

section "✅ Configuración completa"
warn "Debes reiniciar el sistema para aplicar los cambios:"
echo ""
echo -e "    ${BOLD}sudo reboot${RESET}"
echo ""
