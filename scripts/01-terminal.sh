#!/usr/bin/env bash
# ==============================================================================
# 01-terminal.sh
# Configura un entorno de terminal moderno en Fedora 43.
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"
init_log
trap cleanup_log EXIT

REAL_USER="${SUDO_USER:-$USER}"
export HOME_DIR="/home/$REAL_USER"

section "🚀 Fedora Terminal Pro Setup"

log_to_file "Flags activos: pkg=$SKIP_PKG eza=$SKIP_EZA font=$SKIP_FONT zsh=$SKIP_ZSH starship=$SKIP_STARSHIP chsh=$SKIP_CHSH"

# ── 1. Actualizar sistema e instalar paquetes base ───────────────────────────
if [ "$SKIP_PKG" = false ]; then
  info "Actualizando sistema..."
  log_cmd "sudo dnf update -y"
  sudo dnf update -y
  success "Sistema actualizado."

  info "Instalando paquetes base..."
  dnf_install \
    git curl wget unzip \
    zsh \
    fastfetch fzf bat zoxide micro \
    libgda libgda-sqlite \
    rust cargo
else
  info "Saltando paquetes base (--skip-pkg)"
fi

# ── 3. eza (reemplazo moderno de ls) ─────────────────────────────────────────
if [ "$SKIP_EZA" = false ]; then
  if command -v eza &>/dev/null; then
    success "eza ya está instalado."
  else
    info "Instalando eza..."
    log_cmd "sudo dnf install -y eza"
    if sudo dnf install -y eza 2>/dev/null; then
      success "eza instalado desde dnf."
    else
      info "Instalando eza via cargo (puede tardar varios minutos)..."
      log_cmd "cargo install eza"
      cargo install eza
      success "eza instalado via cargo."
    fi
  fi
else
  info "Saltando eza (--skip-eza)"
fi

# ── 4. Fuente JetBrainsMono Nerd ──────────────────────────────────────────────
if [ "$SKIP_FONT" = false ]; then
  if fc-list | grep -qi "JetBrainsMono Nerd"; then
    success "JetBrainsMono Nerd Font ya instalada."
  else
    info "Instalando JetBrainsMono Nerd Font..."
    log_cmd "wget + unzip JetBrainsMono Nerd Font"
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip > /dev/null
    rm JetBrainsMono.zip
    fc-cache -fv > /dev/null
    cd ~
    success "JetBrainsMono Nerd Font instalada."
  fi
else
  info "Saltando fuente Nerd (--skip-font)"
fi

# ── 5. Oh My Zsh ──────────────────────────────────────────────────────────────
if [ "$SKIP_ZSH" = false ]; then
  if [ -d "$HOME/.oh-my-zsh" ]; then
    success "Oh My Zsh ya está instalado."
  else
    info "Instalando Oh My Zsh..."
    log_cmd "sh -c \"\$(curl...)\" --unattended"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh instalado."
  fi

  # ── 6. Plugins de Zsh ────────────────────────────────────────────────────────
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    info "Clonando zsh-autosuggestions..."
    log_cmd "git clone zsh-autosuggestions"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  fi

  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    info "Clonando zsh-syntax-highlighting..."
    log_cmd "git clone zsh-syntax-highlighting"
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
      ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi
  success "Plugins de Zsh listos."
else
  info "Saltando Oh My Zsh (--skip-zsh)"
fi

# ── 7. Starship ───────────────────────────────────────────────────────────────
if [ "$SKIP_STARSHIP" = false ]; then
  if command -v starship &>/dev/null; then
    success "Starship ya está instalado."
  else
    info "Instalando Starship..."
    log_cmd "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    success "Starship instalado."
  fi

  # ── 8. Configurar Starship (preset Pastel Powerline) ────────────────────────
  mkdir -p ~/.config
  PRESET_LOCAL="$PROJECT_ROOT/config/starship.toml"

  if [ -e ~/.config/starship.toml ] || [ -L ~/.config/starship.toml ]; then
    rm -f ~/.config/starship.toml
  fi

  if [ -f "$PRESET_LOCAL" ]; then
    info "Aplicando preset Pastel Powerline local..."
    log_cmd "cp $PRESET_LOCAL ~/.config/starship.toml"
    cp "$PRESET_LOCAL" ~/.config/starship.toml
  else
    info "Generando preset Pastel Powerline desde starship..."
    log_cmd "starship preset pastel-powerline > ~/.config/starship.toml"
    starship preset pastel-powerline > ~/.config/starship.toml
  fi
  success "Starship configurado."
else
  info "Saltando Starship (--skip-starship)"
fi

# ── 9. Generar .zshrc ─────────────────────────────────────────────────────────
if [ "$SKIP_ZSH" = false ]; then
  if [ -L ~/.zshrc ] || [ -f ~/.zshrc ]; then
    info "Respaldando .zshrc existente..."
    mv ~/.zshrc ~/.zshrc.backup.$(date +%s)
  fi

  cat << 'EOF' > ~/.zshrc
# paths personalizados
export PATH="$HOME/.cargo/bin:$HOME/.opencode/bin:$PATH"

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
fi

# ── 10. Cambiar shell por defecto a Zsh ───────────────────────────────────────
if [ "$SKIP_CHSH" = false ] && [ "$SKIP_ZSH" = false ]; then
  if [ "$SHELL" != "$(which zsh)" ]; then
    info "Cambiando shell por defecto a Zsh..."
    log_cmd "chsh -s \$(which zsh)"
    chsh -s "$(which zsh)"
    success "Zsh configurado como shell por defecto."
  fi
else
  if [ "$SKIP_ZSH" = true ]; then
    info "Saltando cambio de shell (--skip-zsh)"
  fi
fi

section "✅ Terminal Setup completo"
log_to_file "Terminal Setup completado exitosamente"
echo -e "  Ejecuta ${BOLD}exec zsh${RESET} o abre una nueva terminal para aplicar los cambios."
echo ""
