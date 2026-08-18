#!/usr/bin/env bash
# ==============================================================================
# 05-intel-fix.sh
# Corrige el parpadeo de pantalla en GPUs Intel aplicando parámetros de kernel.
# Compatible con Fedora (grubby) y Ubuntu (update-grub).
# Requiere: sudo, reinicio
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

KERNEL_PARAMS="i915.enable_psr=0 i915.enable_dc=0 intel_idle.max_cstate=2"

section "Corrección de parpadeo Intel ($OS_NAME)"

# ── 1. Detectar GPU Intel ─────────────────────────────────────────────────────
if ! lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
  warn "No se detectó una GPU Intel en este sistema."
  warn "Este script está diseñado solo para GPUs Intel (driver i915)."
  echo ""
  read -p "  ¿Aplicar parámetros de todas formas? [s/N]: " FORCE
  [[ "$FORCE" != "s" && "$FORCE" != "S" ]] && exit 0
fi

# ── 2. Aplicar parámetros del kernel ──────────────────────────────────────────
if is_fedora; then
  # ── Fedora: grubby ──────────────────────────────────────────────────────────
  if ! command -v grubby &>/dev/null; then
    info "Instalando grubby..."
    sudo dnf install -y grubby
  fi

  info "Aplicando parámetros del kernel con grubby..."
  sudo grubby --update-kernel=ALL --args="$KERNEL_PARAMS"
  success "Parámetros aplicados correctamente."

  info "Parámetros activos en el kernel:"
  sudo grubby --info=DEFAULT | grep args

elif is_ubuntu; then
  # ── Ubuntu: /etc/default/grub + update-grub ─────────────────────────────────
  info "Aplicando parámetros del kernel en /etc/default/grub..."

  if grep -q "^GRUB_CMDLINE_LINUX=" /etc/default/grub; then
    if grep -q "$KERNEL_PARAMS" /etc/default/grub; then
      success "Parámetros ya están presentes en GRUB_CMDLINE_LINUX."
    else
      # Añadir parámetros a la línea existente
      sudo sed -i 's/^GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 '"$KERNEL_PARAMS"'"/' /etc/default/grub
      success "Parámetros agregados a GRUB_CMDLINE_LINUX."
    fi
  else
    echo "GRUB_CMDLINE_LINUX=\"$KERNEL_PARAMS\"" | sudo tee -a /etc/default/grub > /dev/null
    success "GRUB_CMDLINE_LINUX creado con parámetros."
  fi

  info "Actualizando GRUB..."
  sudo update-grub
  success "GRUB actualizado."
fi

section "Corrección de Intel completada"
warn "Debes reiniciar el sistema para aplicar los cambios:"
echo ""
echo -e "    ${BOLD}sudo reboot${RESET}"
echo ""
