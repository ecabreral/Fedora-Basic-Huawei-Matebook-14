#!/usr/bin/env bash
# ==============================================================================
# 03-git.sh
# Configura Git con nombre/email de usuario, genera claves SSH
# y guía para añadirla a GitHub.
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "Configuración de Git y GitHub"

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
  read -p "  ¿Deseas reconfigurar de todas formas? [s/N]: " RECONFIG
  [[ "$RECONFIG" != "s" && "$RECONFIG" != "S" ]] && exit 0
fi

# ── 2. Instalar git si no está ────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
  info "Git no está instalado. Instalando..."
  pkg_install git
fi

# ── 3. Solicitar datos ─────────────────────────────────────────────────────────
echo ""
read -p "  Ingresa tu nombre para Git: " GIT_NAME
read -p "  Ingresa tu email de GitHub:  " GIT_EMAIL
echo ""

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input

success "Git configurado."

# ── 4. Generar clave SSH ──────────────────────────────────────────────────────
section "🔑 Clave SSH"
if [ -f ~/.ssh/id_ed25519 ]; then
  warn "Ya existe una clave SSH (~/.ssh/id_ed25519)."
  read -p "  ¿Generar una nueva y reemplazarla? [s/N]: " REGEN
  if [[ "$REGEN" == "s" || "$REGEN" == "S" ]]; then
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N "" -q
    success "Nueva clave SSH generada."
  fi
else
  info "Generando clave SSH..."
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N "" -q
  success "Clave SSH generada."
fi

eval "$(ssh-agent -s)" > /dev/null
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

# Función helper para abrir URLs
open_url() {
    local url="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" &
    else
        echo "  URL: $url"
    fi
}

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
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  success "¡Conexión con GitHub exitosa! 🎉"
else
  warn "El test de conexión no regresó el mensaje esperado."
  warn "Puede que aún no hayas agregado la clave, o que tome unos segundos."
  ssh -T git@github.com || true
fi

echo ""
success "Configuración de Git completada"
echo ""
