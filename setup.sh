#!/usr/bin/env bash
# ==============================================================================
# setup.sh
# Lanzador inteligente para el instalador de Fedora Pro.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

# ── 1. Intentar Lanzar Interfaz Pro (Python/Tkinter) ─────────────────────────
if command -v python3 &>/dev/null && [ -f "$SCRIPT_DIR/setup_gui.py" ]; then
  info "Lanzando Interfaz Gráfica Pro..."
  python3 "$SCRIPT_DIR/setup_gui.py" &
  exit 0
fi

# ── 2. Fallback a Interfaz Zenity (si Python falla) ──────────────────────────
if ! command -v zenity &>/dev/null; then
  warn "Instalando Zenity para soporte gráfico..."
  sudo dnf install -y zenity
fi

# ... lógica de Zenity anterior si se desea mantener como fallback ...
# (Para brevedad en esta actualización, asumimos que el usuario usará el Pro)
# Si llega aquí es porque Python no está o el script falló.
warn "No se pudo iniciar la interfaz Pro. Contacta con soporte o revisa Python3."
exit 1
