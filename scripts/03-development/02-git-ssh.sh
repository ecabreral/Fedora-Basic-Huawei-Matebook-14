#!/usr/bin/env bash
# ==============================================================================
# 02-git-ssh.sh
# Configura Git con nombre/email de usuario, genera claves SSH
# y guía para añadirla a GitHub.
# ==============================================================================

# No usar set -e: los prompts interactivos y la generación de claves necesitan
# poder salir limpiamente sin abortar todo el flujo.
source "$(dirname "$0")/../../lib/common.sh"

section "Configuración de Git y GitHub"

# SSH agent iniciado por este script, para poder cerrarlo al finalizar.
SSH_AGENT_STARTED_BY_US=0
cleanup_ssh_agent() {
  if [ "$SSH_AGENT_STARTED_BY_US" = "1" ] && [ -n "${SSH_AGENT_PID:-}" ]; then
    kill "$SSH_AGENT_PID" 2>/dev/null && info "ssh-agent cerrado."
    SSH_AGENT_STARTED_BY_US=0
  fi
}
trap cleanup_ssh_agent EXIT

# ── 1. Verificar si ya está configurado completamente ─────────────────────────
if git config --global user.name &>/dev/null && \
   git config --global user.email &>/dev/null && \
   [ -f ~/.ssh/id_ed25519 ]; then
  success "Git ya está configurado con GitHub."
  echo ""
  echo -e "  Nombre:  ${BOLD}$(git config --global user.name)${RESET}"
  echo -e "  Email:   ${BOLD}$(git config --global user.email)${RESET}"
  echo -e "  Clave:   ${BOLD}~/.ssh/id_ed25519${RESET}"
  echo ""
  if [ ! -t 0 ]; then
    info "Modo no interactivo: se mantiene la configuración existente."
    exit 0
  fi
  read -p "  ¿Deseas reconfigurar de todas formas? [s/N]: " RECONFIG
  if [[ "$RECONFIG" != "s" && "$RECONFIG" != "S" ]]; then
    exit 0
  fi
fi

# ── 2. Instalar git si no está ────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
  info "Git no está instalado. Instalando..."
  pkg_install git
fi

# ── 3. Solicitar datos ─────────────────────────────────────────────────────────
if [ ! -t 0 ]; then
  error "La configuración de Git requiere interacción (nombre y email)."
  error "Ejecuta './setup.sh --component git' desde una terminal interactiva."
  exit 1
fi

echo ""
read -p "  Ingresa tu nombre para Git: " GIT_NAME
read -p "  Ingresa tu email de GitHub:  " GIT_EMAIL
echo ""

# Validar que no estén vacíos: una config con nombre vacío rompe los commits.
if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
  error "Nombre y email son obligatorios. Configuración cancelada."
  exit 1
fi

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input

success "Git configurado."

# ── 4. Generar clave SSH ──────────────────────────────────────────────────────
section "🔑 Clave SSH"
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ -f ~/.ssh/id_ed25519 ]; then
  warn "Ya existe una clave SSH (~/.ssh/id_ed25519)."
  # Respaldar la clave existente: regenerar la destruye y deja al usuario sin
  # acceso a sus repositorios hasta que suba la nueva a GitHub.
  read -p "  ¿Generar una nueva? La actual se respaldará. [s/N]: " REGEN
  if [[ "$REGEN" == "s" || "$REGEN" == "S" ]]; then
    BACKUP=~/.ssh/id_ed25519.backup.$(date +%s)
    cp ~/.ssh/id_ed25519 "$BACKUP" && chmod 600 "$BACKUP"
    info "Clave anterior respaldada en $BACKUP"
    if ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N "" -q; then
      success "Nueva clave SSH generada."
    else
      error "ssh-keygen falló. Restaurando la clave anterior..."
      cp "$BACKUP" ~/.ssh/id_ed25519
      exit 1
    fi
  fi
else
  info "Generando clave SSH..."
  if ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N "" -q; then
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    success "Clave SSH generada."
  else
    error "No se pudo generar la clave SSH."
    exit 1
  fi
fi

eval "$(ssh-agent -s)" > /dev/null
SSH_AGENT_PID="$SSH_AGENT_PID"
SSH_AGENT_STARTED_BY_US=1
ssh-add ~/.ssh/id_ed25519 2>/dev/null

# ── 5. Mostrar y copiar clave pública ─────────────────────────────────────────
SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)
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
section "Añadir clave a GitHub"
info "Abriendo GitHub → Settings → SSH Keys..."

open_url "https://github.com/settings/keys"

if ! command -v xdg-open &>/dev/null; then
    echo "  Aviso: no se detectó navegador. Copia la URL y ábrela manualmente."
fi

echo ""
echo "  1. En la página que se abrió, haz clic en 'New SSH key'"
echo "  2. Dale un título (ej: 'Fedora Matebook 14')"
echo "  3. Pega la clave pública que se copió al portapapeles"
echo "  4. Haz clic en 'Add SSH key'"
echo ""
read -p "  Presiona ENTER cuando hayas añadido la clave a GitHub... "

# ── 7. Probar conexión ────────────────────────────────────────────────────────
section "Probando conexión con GitHub"
# BatchMode evita que ssh pida contraseña/passphrase y bloquee el script;
# ConnectTimeout evita colgarse en redes sin salida a github.com:22.
if ssh -T -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new \
     git@github.com 2>&1 | grep -q "successfully authenticated"; then
  success "¡Conexión con GitHub exitosa! 🎉"
else
  warn "El test de conexión no regresó el mensaje esperado."
  warn "Puede que aún no hayas agregado la clave, o que tarde unos segundos."
  warn "Verifica manualmente con: ssh -T git@github.com"
fi

echo ""
success "Configuración de Git completada"
echo ""
