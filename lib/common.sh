#!/usr/bin/env bash
# ==============================================================================
# lib.sh — Librería compartida para scripts del proyecto Fedora/Ubuntu Setup
# Uso: source "$(dirname "$0")/../../lib/common.sh"
# ==============================================================================

# ── Colores (compatibilidad hacia atrás) ──────────────────────────────────────
BOLD="\e[1m"
DIM="\e[2m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# ── Directorio raíz del proyecto ──────────────────────────────────────────────
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Cargar logger si existe ──────────────────────────────────────────────────
_LOGGER_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logger.sh"
if [ -f "$_LOGGER_FILE" ]; then
  source "$_LOGGER_FILE"
fi
source "$(dirname "${BASH_SOURCE[0]}")/privilege.sh"
source "$(dirname "${BASH_SOURCE[0]}")/platform.sh"
source "$(dirname "${BASH_SOURCE[0]}")/catalog.sh"

# ── Funciones de log (compatibilidad hacia atrás) ────────────────────────────
info()    { log_info "$@" 2>/dev/null || echo -e "${CYAN}${BOLD}  ·${RESET}  $1"; }
success() { log_success "$@" 2>/dev/null || echo -e "${GREEN}${BOLD}  ✔${RESET}  $1"; }
warn()    { log_warn "$@" 2>/dev/null || echo -e "${YELLOW}${BOLD}  !${RESET}  $1"; }
error()   { log_error "$@" 2>/dev/null || echo -e "${RED}${BOLD}  ✗${RESET}  $1" >&2; }
section() {
  log_section "$@" 2>/dev/null || {
    echo ""
     echo -e "${BLUE}${BOLD}== $1${RESET}"
    echo ""
  }
}

# ── OS Detection ──────────────────────────────────────────────────────────────
OS_ID=""
OS_NAME=""
OS_VERSION=""

detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID,,}"
    OS_NAME="$NAME"
    OS_VERSION="$VERSION_ID"
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS_ID="${DISTRIB_ID,,}"
    OS_NAME="$DISTRIB_ID"
    OS_VERSION="$DISTRIB_RELEASE"
  else
    OS_ID="unknown"
    OS_NAME="unknown"
    OS_VERSION="unknown"
  fi
  echo "$OS_ID"
}

is_fedora() { [ "$OS_ID" = "fedora" ]; }
is_ubuntu() { [ "$OS_ID" = "ubuntu" ]; }

# ── require_root: Falla si no se ejecuta como root ───────────────────────────
require_root() {
  if [ "$EUID" -ne 0 ]; then
    error "Este script debe ejecutarse con sudo."
    exit 1
  fi
}

# ── require_cmd: Falla si un comando no está disponible ──────────────────────
require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    error "Se requiere '$1' pero no está instalado."
    exit 1
  fi
}

# ── pkg_check: Verifica si un paquete está instalado ─────────────────────────
pkg_check() {
  local pkg="$1"
  if is_fedora; then
    rpm -q "$pkg" &>/dev/null
  elif is_ubuntu; then
    dpkg -s "$pkg" 2>/dev/null | grep -q "Status: install ok installed"
  else
    return 1
  fi
}

# ── pkg_install: Instala paquetes con el gestor adecuado ─────────────────────
pkg_install() {
  local pkgs=("$@")
  local to_install=()
  for pkg in "${pkgs[@]}"; do
    if ! pkg_check "$pkg"; then
      to_install+=("$pkg")
    fi
  done
  if [ ${#to_install[@]} -gt 0 ]; then
    info "Instalando: ${to_install[*]}"
    if is_fedora; then
      sudo dnf install -y "${to_install[@]}"
    elif is_ubuntu; then
      sudo DEBIAN_FRONTEND=noninteractive apt install -y "${to_install[@]}"
    fi
  else
    success "Todos los paquetes ya están instalados."
  fi
}

# ── pkg_update: Actualiza la lista de paquetes ───────────────────────────────
pkg_update() {
  if is_fedora; then
    sudo dnf check-update &>/dev/null || true
  elif is_ubuntu; then
    sudo apt update &>/dev/null || true
  fi
}

# ── system_upgrade: Actualiza todos los paquetes del sistema ─────────────────
system_upgrade() {
  if is_fedora; then
    sudo dnf upgrade -y
  elif is_ubuntu; then
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
  fi
}

# ── system_update_alias: Retorna el alias de actualización para .zshrc ──────
system_update_alias() {
  if is_fedora; then
    echo 'alias update="sudo dnf upgrade -y && flatpak update -y"'
  elif is_ubuntu; then
    echo 'alias update="sudo apt update && sudo apt upgrade -y && flatpak update -y"'
  fi
}

# ── clipboard_copy: Copia texto al portapapeles (Wayland o X11) ──────────────
clipboard_copy() {
  if command -v wl-copy &>/dev/null; then
    echo "$1" | wl-copy
    return 0
  elif command -v xclip &>/dev/null; then
    echo "$1" | xclip -selection clipboard
    return 0
  fi
  return 1
}

# ── install_nerd_font: Instala JetBrainsMono Nerd Font si no existe ───────────
install_nerd_font() {
  if fc-list | grep -qi "JetBrainsMono Nerd"; then
    success "JetBrainsMono Nerd Font ya instalada."
    return 0
  fi
  info "Instalando JetBrainsMono Nerd Font..."
  mkdir -p ~/.local/share/fonts
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts > /dev/null
  rm -f /tmp/JetBrainsMono.zip
  fc-cache -fv > /dev/null
  success "JetBrainsMono Nerd Font instalada."
}

# ── open_url: Abre una URL en el navegador predeterminado ─────────────────────
open_url() {
  local url="$1"
  if command -v xdg-open &>/dev/null; then
    xdg-open "$url" 2>/dev/null
  elif command -v gnome-open &>/dev/null; then
    gnome-open "$url" 2>/dev/null
  else
    info "Abre esta URL manualmente: $url"
    return 1
  fi
}

# ── apply_starship_theme: Aplica un tema de Starship ──────────────────────────
apply_starship_theme() {
  local theme="$1"
  local config_dir="${2:-$HOME/.config}"

  mkdir -p "$config_dir"

  case "$theme" in
    tokyo-night|pastel-powerline|gruvbox-rainbow|catppuccin-powerline|jetpack|pure-preset| \
    nerd-font-symbols|no-nerd-font|bracketed-segments|plain-text|no-runtimes|no-empty-icons)
      starship preset "$theme" > "$config_dir/starship.toml"
      ;;
    cyberpunk-storm|cyberpunk-neon|cyberpunk-night)
      local toml_file="$PROJECT_ROOT/config/starship/starship-${theme}.toml"
      if [ -f "$toml_file" ]; then
        cp "$toml_file" "$config_dir/starship.toml"
      else
        error "No se encontró starship-${theme}.toml"
        return 1
      fi
      ;;
    *)
      error "Tema desconocido: $theme"
      return 1
      ;;
  esac
  success "Tema Starship '$theme' aplicado."
}

# ── show_theme_selector: Muestra menú whiptail de selección de temas ──────────
show_theme_selector() {
  local theme lines cols height width
  lines=$(tput lines 2>/dev/null || echo 24)
  cols=$(tput cols 2>/dev/null || echo 80)
  height=$((lines > 28 ? 24 : lines - 3))
  width=$((cols > 100 ? 92 : cols - 4))
  [ "$height" -lt 16 ] && height=16
  [ "$width" -lt 60 ] && width=60
  if theme=$(whiptail --title "Selecciona el tema de Starship" \
      --radiolist "Elige un tema para tu terminal (Espacio marca, Enter confirma):" "$height" "$width" 12 \
      "1" "Tokyo Night (oscuro, recomendado)" ON \
      "2" "Pastel Powerline (claro)" OFF \
      "3" "Gruvbox Rainbow (oscuro cálido)" OFF \
      "4" "Catppuccin Powerline (oscuro pastel)" OFF \
      "5" "Jetpack (minimalista)" OFF \
      "6" "Pure Prompt (clásico)" OFF \
      "7" "Cyberpunk Storm (neón intenso)" OFF \
      "8" "Cyberpunk Neon (máxima saturación)" OFF \
      "9" "Cyberpunk Night (sutil y elegante)" OFF \
      3>&1 1>&2 2>&3); then
    :
  else
    echo ""
    return 1
  fi
  [ -z "$theme" ] && { echo ""; return 1; }

  case "$theme" in
    1) echo "tokyo-night" ;;
    2) echo "pastel-powerline" ;;
    3) echo "gruvbox-rainbow" ;;
    4) echo "catppuccin-powerline" ;;
    5) echo "jetpack" ;;
    6) echo "pure-preset" ;;
    7) echo "cyberpunk-storm" ;;
    8) echo "cyberpunk-neon" ;;
    9) echo "cyberpunk-night" ;;
    *) echo "" ;;
  esac
}

# ── Inicializar detección de SO al cargar ────────────────────────────────────
detect_os > /dev/null
