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
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Variables de logging (se inicializan en init_log) ──────────────────────────
LOG_PREFIX="${LOG_PREFIX:-$(basename "$0" .sh)}"
LOG_FILE=""
LOG_DIR=""
REAL_USER="${SUDO_USER:-$USER}"

init_log() {
    # Detectar usuario real si estamos usando sudo
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        REAL_USER="$SUDO_USER"
        REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
        LOG_DIR="${REAL_HOME}/Downloads/Fedora-Basic-Huawei-Matebook-14/logs"
    else
        LOG_DIR="${LOG_DIR:-$PROJECT_ROOT/logs}"
    fi
    
    # Crear directorio y archivo con permisos correctos
    mkdir -p "$LOG_DIR" 2>/dev/null || sudo mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"
    
    # Crear archivo y ajustar permisos
    touch "$LOG_FILE" 2>/dev/null
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        chown "$SUDO_USER:$SUDO_USER" "$LOG_FILE" 2>/dev/null
        chmod 644 "$LOG_FILE" 2>/dev/null
    fi
    
    # Escribir header
    {
        echo "========================================"
        echo "Inicio: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Script: $LOG_PREFIX"
        echo "Host: $(hostname)"
        echo "User: $REAL_USER"
        echo "Log File: $LOG_FILE"
        echo "========================================"
    } > "$LOG_FILE"
}

log_to_file() {
    if [ -n "$LOG_FILE" ] && [ -w "$LOG_FILE" ]; then
        echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

log_cmd() {
    log_to_file "CMD: $1"
}

# ── Funciones de log ──────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}${BOLD}  ·${RESET}  $1"; log_to_file "INFO: $1"; }
success() { echo -e "${GREEN}${BOLD}  ✔${RESET}  $1"; log_to_file "OK: $1"; }
warn()    { echo -e "${YELLOW}${BOLD}  !${RESET}  $1"; log_to_file "WARN: $1"; }
error()   { echo -e "${RED}${BOLD}  ✗${RESET}  $1" >&2; log_to_file "ERROR: $1"; }
section() {
  echo ""
  echo -e "${BLUE}${BOLD}══ $1${RESET}"
  echo ""
  log_to_file "=== $1 ==="
}

finalize_log() {
    {
        echo "Fin: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "========================================"
        echo ""
    } >> "$LOG_FILE" 2>/dev/null || true
    echo "Log: $LOG_FILE" >> /dev/stderr 2>/dev/null
}

cleanup_log() {
    finalize_log
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
    log_cmd "sudo dnf install -y ${to_install[*]}"
    sudo dnf install -y "${to_install[@]}"
    log_to_file "DNF install completado"
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
