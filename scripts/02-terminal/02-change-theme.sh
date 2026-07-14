#!/usr/bin/env bash
# ==============================================================================
# 02-change-theme.sh
# Cambio rápido de tema para Starship y GNOME Terminal.
# Respalda automáticamente las configuraciones anteriores.
# ==============================================================================

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../../lib/gnome-terminal-colors.sh"

section "🎨 Cambio de Tema"

# ── Verificar si Starship está instalado ───────────────────────────────────
if ! command -v starship &>/dev/null; then
  error "Starship no está instalado."
  error "Ejecuta primero: ./setup.sh → [1] o [2] → [1] Terminal Moderna"
  exit 1
fi

# ── Detectar tema actual ───────────────────────────────────────────────────
CURRENT_THEME="ninguno"
if [ -f ~/.config/starship.toml ]; then
  if grep -q 'palette = "cyberpunk_storm"' ~/.config/starship.toml; then
    CURRENT_THEME="cyberpunk-storm"
  elif grep -q 'palette = "cyberpunk_neon"' ~/.config/starship.toml; then
    CURRENT_THEME="cyberpunk-neon"
  elif grep -q 'palette = "cyberpunk_night"' ~/.config/starship.toml; then
    CURRENT_THEME="cyberpunk-night"
  else
    # Detectar temas de Starship presets
    if grep -q 'tokyo-night' ~/.config/starship.toml 2>/dev/null; then
      CURRENT_THEME="tokyo-night"
    elif grep -q 'pastel-powerline' ~/.config/starship.toml 2>/dev/null; then
      CURRENT_THEME="pastel-powerline"
    elif grep -q 'gruvbox-rainbow' ~/.config/starship.toml 2>/dev/null; then
      CURRENT_THEME="gruvbox-rainbow"
    elif grep -q 'catppuccin-powerline' ~/.config/starship.toml 2>/dev/null; then
      CURRENT_THEME="catppuccin-powerline"
    elif grep -q 'jetpack' ~/.config/starship.toml 2>/dev/null; then
      CURRENT_THEME="jetpack"
    elif grep -q 'pure-preset' ~/.config/starship.toml 2>/dev/null; then
      CURRENT_THEME="pure-preset"
    else
      CURRENT_THEME="personalizado"
    fi
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
      "1" "Tokyo Night (oscuro azulado)" ON \
      "2" "Pastel Powerline (claro)" OFF \
      "3" "Gruvbox Rainbow (oscuro calido)" OFF \
      "4" "Catppuccin Powerline (oscuro pastel)" OFF \
      "5" "Jetpack (minimalista)" OFF \
      "6" "Pure Prompt (clasico)" OFF \
      "7" "Cyberpunk Storm (neon intenso)" OFF \
      "8" "Cyberpunk Neon (maxima saturacion)" OFF \
      "9" "Cyberpunk Night (sutel elegante)" OFF \
      3>&1 1>&2 2>&3)

  if [ $? -ne 0 ] || [ -z "$theme" ]; then
    info "Cancelado."
    exit 1
  fi

  case "$theme" in
    1)  echo "tokyo-night" ;;
    2)  echo "pastel-powerline" ;;
    3)  echo "gruvbox-rainbow" ;;
    4)  echo "catppuccin-powerline" ;;
    5)  echo "jetpack" ;;
    6)  echo "pure-preset" ;;
    7)  echo "cyberpunk-storm" ;;
    8)  echo "cyberpunk-neon" ;;
    9)  echo "cyberpunk-night" ;;
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
section "📦 Respaldando configuraciones anteriores"

BACKUP_DIR="$HOME/.config/theme-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Respaldo Starship
if [ -f ~/.config/starship.toml ]; then
  cp ~/.config/starship.toml "$BACKUP_DIR/starship.toml.backup"
  success "Starship respaldado en: $BACKUP_DIR"
fi

# ── Aplicar tema Starship ──────────────────────────────────────────────────
section "🎨 Aplicando tema Starship: $THEME"

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

case "$THEME" in
  tokyo-night)
    starship preset tokyo-night > ~/.config/starship.toml
    ;;
  pastel-powerline)
    starship preset pastel-powerline > ~/.config/starship.toml
    ;;
  gruvbox-rainbow)
    starship preset gruvbox-rainbow > ~/.config/starship.toml
    ;;
  catppuccin-powerline)
    starship preset catppuccin-powerline > ~/.config/starship.toml
    ;;
  jetpack)
    starship preset jetpack > ~/.config/starship.toml
    ;;
  pure-preset)
    starship preset pure-preset > ~/.config/starship.toml
    ;;
  cyberpunk-storm)
    if [ -f "$SCRIPT_DIR/config/starship-cyberpunk-storm.toml" ]; then
      cp "$SCRIPT_DIR/config/starship-cyberpunk-storm.toml" ~/.config/starship.toml
    else
      error "No se encontró starship-cyberpunk-storm.toml"
      exit 1
    fi
    ;;
  cyberpunk-neon)
    if [ -f "$SCRIPT_DIR/config/starship-cyberpunk-neon.toml" ]; then
      cp "$SCRIPT_DIR/config/starship-cyberpunk-neon.toml" ~/.config/starship.toml
    else
      error "No se encontró starship-cyberpunk-neon.toml"
      exit 1
    fi
    ;;
  cyberpunk-night)
    if [ -f "$SCRIPT_DIR/config/starship-cyberpunk-night.toml" ]; then
      cp "$SCRIPT_DIR/config/starship-cyberpunk-night.toml" ~/.config/starship.toml
    else
      error "No se encontró starship-cyberpunk-night.toml"
      exit 1
    fi
    ;;
esac

success "Starship actualizado: $THEME"

# ── Verificar e instalar fuente Nerd Font ───────────────────────────────────
if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
  section "🔤 Instalando JetBrainsMono Nerd Font"
  mkdir -p ~/.local/share/fonts
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts > /dev/null
  rm -f /tmp/JetBrainsMono.zip
  fc-cache -fv > /dev/null
  success "JetBrainsMono Nerd Font instalada."
fi

# ── Aplicar tema GNOME Terminal ────────────────────────────────────────────
if command -v gnome-terminal &>/dev/null && command -v dconf &>/dev/null; then
  section "Aplicando tema GNOME Terminal: $THEME"

  # Obtener el perfil por defecto
  PROFILE=$(get_default_profile)

  if [ -n "$PROFILE" ]; then
    PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$PROFILE"

    info "Aplicando tema '$THEME' al perfil: $PROFILE"
    apply_gnome_terminal_theme "$PROFILE_PATH"
    success "GNOME Terminal actualizado: $THEME"
  else
    warn "No se encontró perfil de GNOME Terminal."
    info "Ejecuta primero: ./setup.sh → [1] o [2] → [1] Terminal Moderna"
  fi
else
  warn "GNOME Terminal o dconf no están disponibles. Solo se actualizó Starship."
fi

# Resumen
section "Tema actualizado"
echo ""
echo "  Tema: $THEME"
echo "  Starship: ~/.config/starship.toml"
if command -v gnome-terminal &>/dev/null; then
  echo "  GNOME Terminal: tema aplicado via dconf"
fi
echo "  Respaldos: $BACKUP_DIR"
echo ""
echo "  Ejecuta exec zsh o abre una nueva terminal para ver los cambios."
echo ""
