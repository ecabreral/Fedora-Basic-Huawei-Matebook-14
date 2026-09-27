#!/usr/bin/env bash
# ==============================================================================
# 02-change-theme.sh
# Cambio rápido de tema para Starship y Ptyxis.
# Respalda automáticamente las configuraciones anteriores.
# ==============================================================================

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../../lib/ptyxis-colors.sh"

section "Cambio de tema"

# ── Verificar si Starship está instalado ───────────────────────────────────
if ! command -v starship &>/dev/null; then
  error "Starship no está instalado."
  error "Ejecuta primero: ./setup.sh → [1] o [2] → [1] Terminal Moderna"
  exit 1
fi

# ── Detectar tema actual ───────────────────────────────────────────────────
CURRENT_THEME="ninguno"
if [ -f ~/.config/starship.toml ]; then
  # Detectar cuál de los tres presets está aplicado. Los presets de Starship no
  # incluyen su nombre en el TOML, así que se distinguen por su paleta de colores.
  if grep -qE "'#faf4ed'|#faf4ed" ~/.config/starship.toml 2>/dev/null; then
    CURRENT_THEME="pastel-powerline"
  elif grep -qE "'#1e1e2e'|#1e1e2e" ~/.config/starship.toml 2>/dev/null; then
    CURRENT_THEME="catppuccin-powerline"
  elif grep -qE "'#282828'|#282828" ~/.config/starship.toml 2>/dev/null; then
    CURRENT_THEME="gruvbox-rainbow"
  else
    CURRENT_THEME="personalizado"
  fi
  info "Tema actual: $CURRENT_THEME"
else
  warn "No se encontró configuración de Starship."
fi

# ── Selector de tema ───────────────────────────────────────────────────────
show_theme_menu() {
  local theme
  theme=$(whiptail --title "Cambio de Tema" \
      --radiolist "Selecciona el nuevo tema para tu terminal:" 22 60 12 \
      "1" "Gruvbox Rainbow (oscuro cálido)" ON \
      "2" "Pastel Powerline (claro)" OFF \
      "3" "Catppuccin Powerline (oscuro pastel)" OFF \
      3>&1 1>&2 2>&3)

  if [ $? -ne 0 ] || [ -z "$theme" ]; then
    info "Cancelado."
    exit 1
  fi

  case "$theme" in
    1)  echo "gruvbox-rainbow" ;;
    2)  echo "pastel-powerline" ;;
    3)  echo "catppuccin-powerline" ;;
    *)  echo "" ;;
  esac
}

THEME=$(show_theme_menu)

if [ -z "$THEME" ]; then
  error "No se seleccionó ningún tema."
  exit 1
fi

info "Tema seleccionado: $THEME"

# ── Respaldo de configuraciones anteriores ──────────────────────────────────
section "Respaldando configuraciones anteriores"

BACKUP_DIR="$HOME/.config/theme-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Respaldo Starship
if [ -f ~/.config/starship.toml ]; then
  cp ~/.config/starship.toml "$BACKUP_DIR/starship.toml.backup"
  success "Starship respaldado en: $BACKUP_DIR"
fi

# ── Aplicar tema Starship ──────────────────────────────────────────────────
section "Aplicando tema Starship: $THEME"
apply_starship_theme "$THEME"

success "Starship actualizado: $THEME"

# ── Verificar e instalar fuente Nerd Font ───────────────────────────────────
section "Verificando fuente Nerd Font"
install_nerd_font

# ── Aplicar tema Ptyxis ─────────────────────────────────────────────────────
if command -v ptyxis &>/dev/null && command -v gsettings &>/dev/null; then
  section "Aplicando tema Ptyxis: $THEME"

  if apply_ptyxis_theme "$THEME"; then
    success "Ptyxis actualizado: $THEME"
  else
    warn "No se pudo aplicar el tema en Ptyxis."
    info "Abre Ptyxis una vez (crea el perfil) y reintenta."
  fi
else
  warn "Ptyxis o gsettings no están disponibles. Solo se actualizó Starship."
fi

# Resumen
section "Tema actualizado"
echo ""
echo "  Tema: $THEME"
echo "  Starship: ~/.config/starship.toml"
if command -v ptyxis &>/dev/null; then
  echo "  Ptyxis: paleta aplicada via gsettings"
fi
echo "  Respaldos: $BACKUP_DIR"
echo ""
echo "  Ejecuta exec zsh o abre una nueva terminal para ver los cambios."
echo ""
