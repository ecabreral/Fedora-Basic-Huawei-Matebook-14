#!/usr/bin/env bash
# ==============================================================================
# lib.sh — Librería compartida para scripts del proyecto Fedora Setup
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

# ── dnf_install: Instala paquetes con mensaje, solo si no están instalados ───
dnf_install() {
  local pkgs=("$@")
  local to_install=()
  for pkg in "${pkgs[@]}"; do
    if ! rpm -q "$pkg" &>/dev/null; then
      to_install+=("$pkg")
    fi
  done
  if [ ${#to_install[@]} -gt 0 ]; then
    info "Instalando: ${to_install[*]}"
    sudo dnf install -y "${to_install[@]}"
  else
    success "Todos los paquetes ya están instalados."
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
