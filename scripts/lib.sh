#!/usr/bin/env bash
# ==============================================================================
# lib.sh — Librería compartida para scripts del proyecto Fedora/Ubuntu Setup
# Uso: source "$(dirname "$0")/lib.sh"
# ==============================================================================

# ── Colores ───────────────────────────────────────────────────────────────────
BOLD="\e[1m"
DIM="\e[2m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# ── Directorio raíz del proyecto ──────────────────────────────────────────────
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Funciones de log ──────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}${BOLD}  ·${RESET}  $1"; }
success() { echo -e "${GREEN}${BOLD}  ✔${RESET}  $1"; }
warn()    { echo -e "${YELLOW}${BOLD}  !${RESET}  $1"; }
error()   { echo -e "${RED}${BOLD}  ✗${RESET}  $1" >&2; }
section() {
  echo ""
  echo -e "${BLUE}${BOLD}══ $1${RESET}"
  echo ""
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

# ── Inicializar detección de SO al cargar ────────────────────────────────────
detect_os > /dev/null
