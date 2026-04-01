#!/usr/bin/env bash
# ==============================================================================
# 03-git.sh
# Configura Git con nombre/email de usuario, genera claves SSH
# y guía para añadirla a GitHub.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"
init_log
trap cleanup_log EXIT

NONINTERACTIVE=${NONINTERACTIVE:-false}

section "⚙️  Configuración de Git + GitHub"

log_to_file "Modo interactivo: $NONINTERACTIVE"

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
SSH_DIR="$REAL_HOME/.ssh"
GIT_SSH_KEY="$SSH_DIR/id_ed25519"

git_config() {
    if [ -n "$SUDO_USER" ]; then
        sudo -u "$REAL_USER" git config "$@"
    else
        git config "$@"
    fi
}

git_config_or_empty() {
    if [ -n "$SUDO_USER" ]; then
        sudo -u "$REAL_USER" git config "$@" 2>/dev/null || echo ""
    else
        git config "$@" 2>/dev/null || echo ""
    fi
}

# ── 1. Verificar configuración actual de Git ───────────────────────────────────
info "Verificando configuración actual de Git (usuario: $REAL_USER)..."
echo ""

GIT_CONFIGURED=true
GIT_NAME=""
GIT_EMAIL=""

GIT_NAME=$(git_config_or_empty --global user.name)
if [ -n "$GIT_NAME" ]; then
  success "Nombre: $GIT_NAME"
  log_to_file "Git nombre: $GIT_NAME"
else
  GIT_CONFIGURED=false
  warn "Nombre: No configurado"
fi

GIT_EMAIL=$(git_config_or_empty --global user.email)
if [ -n "$GIT_EMAIL" ]; then
  success "Email: $GIT_EMAIL"
  log_to_file "Git email: $GIT_EMAIL"
else
  GIT_CONFIGURED=false
  warn "Email: No configurado"
fi

if [ -f "$GIT_SSH_KEY" ]; then
  success "Clave SSH: $GIT_SSH_KEY existe"
  log_to_file "Clave SSH: existe"
else
  GIT_CONFIGURED=false
  warn "Clave SSH: No existe"
fi

echo ""

if [ "$GIT_CONFIGURED" = true ]; then
  success "Git está completamente configurado."
  if [ "$NONINTERACTIVE" = "false" ]; then
    read -p "  ¿Deseas reconfigurar? [s/N]: " RECONFIG
    [[ "$RECONFIG" != "s" && "$RECONFIG" != "S" ]] && exit 0
  else
    log_to_file "Git ya configurado (NONINTERACTIVE=true) - saliendo"
    exit 0
  fi
fi

# ── 2. Instalar git si no está ────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
  info "Git no está instalado. Instalando..."
  log_cmd "sudo dnf install -y git"
  sudo dnf install -y git
fi

# ── 3. Solicitar datos ─────────────────────────────────────────────────────────
echo ""
if [ "$NONINTERACTIVE" = "false" ]; then
  read -p "  Ingresa tu nombre para Git: " GIT_NAME
  read -p "  Ingresa tu email de GitHub:  " GIT_EMAIL
else
  GIT_NAME="${GIT_NAME:-$(whoami)}"
  GIT_EMAIL="${GIT_EMAIL:-}"
fi
echo ""

git_config --global user.name  "$GIT_NAME"
git_config --global user.email "$GIT_EMAIL"

git_config --global init.defaultBranch main
git_config --global pull.rebase false
git_config --global core.autocrlf input

success "Git configurado."

# ── 4. Generar clave SSH ──────────────────────────────────────────────────────
section "🔑 Clave SSH"
if [ -f "$GIT_SSH_KEY" ]; then
  warn "Ya existe una clave SSH ($GIT_SSH_KEY)."
  if [ "$NONINTERACTIVE" = "false" ]; then
    read -p "  ¿Generar una nueva y reemplazarla? [s/N]: " REGEN
    if [[ "$REGEN" == "s" || "$REGEN" == "S" ]]; then
      sudo -u "$REAL_USER" ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$GIT_SSH_KEY" -N "" -q
      success "Nueva clave SSH generada."
    fi
  fi
else
  info "Generando clave SSH..."
  mkdir -p "$SSH_DIR" 2>/dev/null
  sudo -u "$REAL_USER" ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$GIT_SSH_KEY" -N "" -q
  chmod 700 "$SSH_DIR" 2>/dev/null
  chmod 600 "$GIT_SSH_KEY" 2>/dev/null
  success "Clave SSH generada."
fi

if [ -f "$GIT_SSH_KEY" ]; then
  export SSH_AUTH_SOCK=$(ssh-agent -s | grep -o '/[^;]*agent[^;]*')
  sudo -u "$REAL_USER" ssh-add "$GIT_SSH_KEY" 2>/dev/null || true
fi

# ── 5. Mostrar y copiar clave pública ─────────────────────────────────────────
SSH_KEY=$(sudo -u "$REAL_USER" cat "$SSH_DIR/id_ed25519.pub" 2>/dev/null)
echo ""
echo -e "  ${BOLD}Tu clave pública SSH:${RESET}"
echo ""
echo "  $SSH_KEY"
echo ""

if clipboard_copy "$SSH_KEY"; then
  success "Clave copiada al portapapeles automáticamente. 📋"
else
  warn "No se pudo copiar al portapapeles. Cópiala manualmente desde arriba."
fi

# ── 6. Guiar para añadir en GitHub ────────────────────────────────────────────
section "🌐 Añadir clave a GitHub"

if [ "$NONINTERACTIVE" = "false" ]; then
  info "Abriendo GitHub → Settings → SSH Keys..."
  xdg-open "https://github.com/settings/keys" 2>/dev/null &

  echo ""
  echo "  1. En la página que se abrió, haz clic en 'New SSH key'"
  echo "  2. Dale un título (ej: 'Fedora Matebook 14')"
  echo "  3. Pega la clave pública que se copió al portapapeles"
  echo "  4. Haz clic en 'Add SSH key'"
  echo ""
  read -p "  Presiona ENTER cuando hayas añadido la clave a GitHub... "
fi

# ── 7. Probar conexión ────────────────────────────────────────────────────────
section "🔗 Probando conexión con GitHub"
SSH_OUTPUT=$(ssh -T git@github.com 2>&1 || true)
if echo "$SSH_OUTPUT" | grep -qE "(successfully authenticated|Hi |You've successfully authenticated)"; then
  success "¡Conexión con GitHub exitosa! 🎉"
elif echo "$SSH_OUTPUT" | grep -q "Permission denied"; then
  warn "La clave no fue aceptada. Verifica que la añadiste en GitHub."
else
  info "Respuesta de GitHub: $SSH_OUTPUT"
  info "Si no puedes conectar, verifica que añadiste la clave en GitHub."
fi

echo ""
success "Configuración de Git completa 🚀"
echo ""
