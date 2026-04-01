#!/usr/bin/env bash
# ==============================================================================
# cleanup.sh
# Opcional: Elimina Oh My Zsh y configura los plugins de Zsh manualmente.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"

section "🧹 Cleanup: Remover Oh My Zsh (opcional)"
echo ""
echo "  Este script elimina Oh My Zsh y configura los plugins directamente."
echo "  Starship sigue funcionando como prompt."
echo ""
warn "Oh My Zsh es liviano y no interfiere con Starship. Esta limpieza es OPCIONAL."
echo ""
read -p "  ¿Continuar con la limpieza? [s/N]: " CONFIRM
[[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]] && { info "Cancelado."; exit 0; }

# ── 1. Backup de .zshrc ───────────────────────────────────────────────────────
if [ -f ~/.zshrc ]; then
  info "Respaldando .zshrc..."
  cp ~/.zshrc ~/.zshrc.backup.cleanup.$(date +%s)
  success "Backup creado."
fi

# ── 2. Clonar plugins a ubicación independiente ───────────────────────────────
section "📦 Plugins de Zsh"
PLUGINS_DIR=~/.zsh/plugins
mkdir -p "$PLUGINS_DIR"

if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
  info "Clonando zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
else
  success "zsh-autosuggestions ya existe."
fi

if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  info "Clonando zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGINS_DIR/zsh-syntax-highlighting"
else
  success "zsh-syntax-highlighting ya existe."
fi

# ── 3. Eliminar Oh My Zsh ─────────────────────────────────────────────────────
section "🗑️  Removiendo Oh My Zsh"
if [ -d ~/.oh-my-zsh ]; then
  rm -rf ~/.oh-my-zsh
  success "Oh My Zsh eliminado."
else
  warn "Oh My Zsh no está instalado. Nada que eliminar."
fi

# ── 4. Verificar dependencias antes de generar .zshrc ─────────────────────────
section "⚙️  Generando nuevo .zshrc"
MISSING=()
command -v eza      &>/dev/null || MISSING+=("eza")
command -v starship &>/dev/null || MISSING+=("starship")
command -v zoxide   &>/dev/null || MISSING+=("zoxide")
command -v bat      &>/dev/null || MISSING+=("bat")
command -v fastfetch &>/dev/null || MISSING+=("fastfetch")

if [ ${#MISSING[@]} -gt 0 ]; then
  warn "Las siguientes herramientas no están instaladas: ${MISSING[*]}"
  warn "Ejecuta primero scripts/01-terminal.sh para instalarlas."
  echo ""
  read -p "  ¿Generar .zshrc igualmente? [s/N]: " FORCE
  [[ "$FORCE" != "s" && "$FORCE" != "S" ]] && exit 1
fi

cat << 'EOF' > ~/.zshrc
# cargo path
export PATH="$HOME/.cargo/bin:$PATH"

# zsh plugins (sin Oh My Zsh)
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# aliases modernos
alias ls="eza --icons=auto"
alias ll="eza -lah --icons --git"
alias lt="eza --tree --icons"
alias cat="bat --paging=never"
alias cd="z"
alias cls="clear"

# atajo de actualización del sistema
alias update="sudo dnf update -y && flatpak update -y"

# zoxide (cd inteligente)
eval "$(zoxide init zsh)"

# fzf (búsqueda difusa)
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

# starship prompt
eval "$(starship init zsh)"

# fastfetch al iniciar terminal interactiva
clear
if [[ $- == *i* ]]; then
  fastfetch
fi
EOF
success ".zshrc generado sin Oh My Zsh."

section "✅ Cleanup completo"
echo -e "  Ejecuta ${BOLD}exec zsh${RESET} o abre una nueva terminal para aplicar los cambios."
echo ""
