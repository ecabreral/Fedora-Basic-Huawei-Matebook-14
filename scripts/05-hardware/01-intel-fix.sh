#!/usr/bin/env bash
# ==============================================================================
# 01-intel-fix.sh
# Corrige el parpadeo de pantalla en GPUs Intel aplicando parámetros de kernel.
# Compatible con Fedora (grubby) y Ubuntu (update-grub).
# Requiere: sudo, reinicio
# ==============================================================================

# No usar set -e: grubby/update-grub deben reportar su fallo sin dejar el
# script a medias tras haber modificado la configuración del bootloader.
source "$(dirname "$0")/../../lib/common.sh"
require_root

KERNEL_PARAMS="i915.enable_psr=0 i915.enable_dc=0 intel_idle.max_cstate=2"

section "Corrección de parpadeo Intel ($OS_NAME)"

# ── 1. Detectar GPU Intel ─────────────────────────────────────────────────────
if ! has_intel_gpu; then
  warn "No se detectó una GPU Intel en este sistema."
  warn "Este script está diseñado solo para GPUs Intel (driver i915/xe)."
  if [ ! -t 0 ]; then
    warn "Modo no interactivo: saliendo sin aplicar cambios."
    exit 0
  fi
  echo ""
  read -p "  ¿Aplicar parámetros de todas formas? [s/N]: " FORCE
  if [[ "$FORCE" != "s" && "$FORCE" != "S" ]]; then
    exit 0
  fi
fi

# ── 2. Aplicar parámetros del kernel ──────────────────────────────────────────
if is_fedora; then
  # ── Fedora: grubby ──────────────────────────────────────────────────────────
  if ! command -v grubby &>/dev/null; then
    info "Instalando grubby..."
    if ! dnf install -y grubby; then
      error "No se pudo instalar grubby. Abortando."
      exit 1
    fi
  fi

  # Idempotente: grubby añade los args en cada ejecución, duplicándolos.
  if grubby --info=DEFAULT 2>/dev/null | grep -q "i915.enable_psr=0"; then
    success "Los parámetros Intel ya están aplicados en el kernel por defecto."
  else
    info "Aplicando parámetros del kernel con grubby..."
    if grubby --update-kernel=ALL --args="$KERNEL_PARAMS"; then
      success "Parámetros aplicados correctamente."
    else
      error "grubby falló. El bootloader puede haber quedado inconsistente."
      exit 1
    fi
  fi

  info "Parámetros activos en el kernel:"
  grubby --info=DEFAULT | grep args

elif is_ubuntu; then
  # ── Ubuntu: /etc/default/grub + update-grub ─────────────────────────────────
  info "Aplicando parámetros del kernel en /etc/default/grub..."

  # Este script ya se ejecuta como root (require_root), así que no se usa
  # "sudo" aquí para no depender de que sudo también esté instalado/configurado.
  # Se hace backup antes de modificar, para poder revertir.
  if [ ! -f /etc/default/grub.bak ]; then
    cp /etc/default/grub /etc/default/grub.bak
    info "Backup creado en /etc/default/grub.bak"
  fi

  if grep -q "^GRUB_CMDLINE_LINUX=" /etc/default/grub; then
    if grep -q "$KERNEL_PARAMS" /etc/default/grub; then
      success "Parámetros ya están presentes en GRUB_CMDLINE_LINUX."
    else
      # Añadir parámetros a la línea existente
      sed -i 's/^GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 '"$KERNEL_PARAMS"'"/' /etc/default/grub
      success "Parámetros agregados a GRUB_CMDLINE_LINUX."
    fi
  else
    echo "GRUB_CMDLINE_LINUX=\"$KERNEL_PARAMS\"" >> /etc/default/grub
    success "GRUB_CMDLINE_LINUX creado con parámetros."
  fi

  info "Actualizando GRUB..."
  if update-grub; then
    success "GRUB actualizado."
  else
    error "update-grub falló. Revierte con: cp /etc/default/grub.bak /etc/default/grub && update-grub"
    exit 1
  fi
fi

section "Corrección de Intel completada"
warn "Debes reiniciar el sistema para aplicar los cambios:"
echo ""
echo -e "    ${BOLD}sudo reboot${RESET}"
echo ""
wait_for_enter
