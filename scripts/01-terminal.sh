#!/usr/bin/env bash
# ==============================================================================
# 01-terminal.sh
# Configura un entorno de terminal moderno en Fedora 43.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"

section "🚀 Fedora Terminal Pro Setup"

# ── 1. Actualizar sistema ─────────────────────────────────────────────────────
info "Actualizando sistema..."
sudo dnf update -y
success "Sistema actualizado."

# ── 2. Instalar paquetes en un solo bloque ────────────────────────────────────
section "📦 Instalando paquetes"
dnf_install \
  git curl wget unzip \
  zsh \
  fastfetch fzf bat zoxide micro \
  libgda libgda-sqlite \
  rust cargo

# ── 3. eza (reemplazo moderno de ls) ─────────────────────────────────────────
section "📦 Instalando eza"
if command -v eza &>/dev/null; then
  success "eza ya está instalado."
else
  if sudo dnf install -y eza 2>/dev/null; then
    success "eza instalado desde dnf."
  else
    info "Instalando eza via cargo (puede tardar varios minutos)..."
    cargo install eza
    success "eza instalado via cargo."
  fi
fi

# ── 4. Fuente JetBrainsMono Nerd ──────────────────────────────────────────────
section "🔤 Fuente Nerd"
if fc-list | grep -qi "JetBrainsMono Nerd"; then
  success "JetBrainsMono Nerd Font ya instalada."
else
  info "Instalando JetBrainsMono Nerd Font..."
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o JetBrainsMono.zip > /dev/null
  rm JetBrainsMono.zip
  fc-cache -fv > /dev/null
  cd ~
  success "JetBrainsMono Nerd Font instalada."
fi

# ── 5. Oh My Zsh ──────────────────────────────────────────────────────────────
section "🐚 Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  success "Oh My Zsh ya está instalado."
else
  info "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "Oh My Zsh instalado."
fi

# ── 6. Plugins de Zsh ─────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  info "Clonando zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  info "Clonando zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi
success "Plugins de Zsh listos."

# ── 7. Starship ───────────────────────────────────────────────────────────────
section "🚀 Starship"
if command -v starship &>/dev/null; then
  success "Starship ya está instalado."
else
  info "Instalando Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  success "Starship instalado."
fi

# ── 8. Configurar Starship (preset Pastel Powerline) ─────────────────────────
mkdir -p ~/.config
PRESET_LOCAL="$PROJECT_ROOT/config/starship.toml"
if [ -f "$PRESET_LOCAL" ]; then
  info "Aplicando preset Pastel Powerline local..."
  rm -f ~/.config/starship.toml
  cp "$PRESET_LOCAL" ~/.config/starship.toml
else
  info "Generando preset Pastel Powerline desde starship..."
  rm -f ~/.config/starship.toml
  starship preset pastel-powerline > ~/.config/starship.toml
fi
success "Starship configurado con Pastel Powerline."

# ── 9. Generar .zshrc ─────────────────────────────────────────────────────────
section "⚙️  Configurando .zshrc"

# Si .zshrc existe (como archivo o link), respaldarlo y eliminarlo para evitar conflictos
if [ -L ~/.zshrc ] || [ -f ~/.zshrc ]; then
  info "Respaldando .zshrc existente..."
  mv ~/.zshrc ~/.zshrc.backup.$(date +%s)
fi

cat << 'EOF' > ~/.zshrc
# cargo path
export PATH="$HOME/.cargo/bin:$PATH"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

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

success ".zshrc configurado."

# ── 10. Cambiar shell por defecto a Zsh ───────────────────────────────────────
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Cambiando shell por defecto a Zsh..."
  chsh -s "$(which zsh)"
  success "Zsh configurado como shell por defecto."
fi

section "✅ Terminal Setup completo"
echo -e "  Ejecuta ${BOLD}exec zsh${RESET} o abre una nueva terminal para aplicar los cambios."
echo ""
