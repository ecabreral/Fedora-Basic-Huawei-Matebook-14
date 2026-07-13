#!/usr/bin/env bash
# ==============================================================================
# 01-terminal.sh
# Configura un entorno de terminal moderno en Fedora o Ubuntu.
# ==============================================================================

# No usar set -e para permitir continuar aunque sudo falle
source "$(dirname "$0")/lib.sh"

THEME="${1:-$TERMINAL_THEME}"
THEME="${THEME:-tokyo-night}"

echo ""
echo ">>> 01-terminal.sh: THEME = '$THEME'"
echo ">>> 01-terminal.sh: TERMINAL_THEME env = '$TERMINAL_THEME'"

section "🚀 Terminal Pro Setup ($OS_NAME $OS_VERSION)"

# ── 1. Actualizar sistema ─────────────────────────────────────────────────────
info "Actualizando lista de paquetes..."
pkg_update
info "Actualizando sistema..."
system_upgrade 2>/dev/null || success "Sistema ya actualizado."

# ── 2. Instalar paquetes en un solo bloque ────────────────────────────────────
section "📦 Instalando paquetes"

if is_fedora; then
  pkg_install \
    git curl wget unzip \
    zsh \
    fastfetch fzf bat zoxide micro \
    libgda libgda-sqlite \
    rust cargo

elif is_ubuntu; then
  pkg_install \
    git curl wget unzip \
    zsh \
    fastfetch fzf bat zoxide micro \
    cargo

  if ! command -v rustc &>/dev/null; then
    pkg_install rustc
  fi
fi

# ── 3. eza (reemplazo moderno de ls) ─────────────────────────────────────────
section "📦 Instalando eza"
if command -v eza &>/dev/null; then
  success "eza ya está instalado."
else
  if pkg_install eza 2>/dev/null; then
    success "eza instalado desde paquetes."
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

# ── 8. Configurar Starship (tema seleccionado) ──────────────────────────────
section "🎨 Configurando Starship"
mkdir -p ~/.config

info "Aplicando tema Starship: $THEME"
rm -f ~/.config/starship.toml

case "$THEME" in
    tokyo-night)
        starship preset tokyo-night > ~/.config/starship.toml
        success "Tema Tokyo Night aplicado."
        ;;
    pastel-powerline)
        starship preset pastel-powerline > ~/.config/starship.toml
        success "Tema Pastel Powerline aplicado."
        ;;
    gruvbox-rainbow)
        starship preset gruvbox-rainbow > ~/.config/starship.toml
        success "Tema Gruvbox Rainbow aplicado."
        ;;
    catppuccin-powerline)
        starship preset catppuccin-powerline > ~/.config/starship.toml
        success "Tema Catppuccin Powerline aplicado."
        ;;
    jetpack)
        starship preset jetpack > ~/.config/starship.toml
        success "Tema Jetpack aplicado."
        ;;
    pure-preset)
        starship preset pure-preset > ~/.config/starship.toml
        success "Tema Pure Prompt aplicado."
        ;;
    nerd-font-symbols)
        starship preset nerd-font-symbols > ~/.config/starship.toml
        success "Tema Nerd Font Symbols aplicado."
        ;;
    no-nerd-font)
        starship preset no-nerd-font > ~/.config/starship.toml
        success "Tema Sin Nerd Font aplicado."
        ;;
    bracketed-segments)
        starship preset bracketed-segments > ~/.config/starship.toml
        success "Tema Bracketed Segments aplicado."
        ;;
    plain-text)
        starship preset plain-text > ~/.config/starship.toml
        success "Tema Plain Text aplicado."
        ;;
    no-runtimes)
        starship preset no-runtimes > ~/.config/starship.toml
        success "Tema Sin Runtime Versions aplicado."
        ;;
    no-empty-icons)
        starship preset no-empty-icons > ~/.config/starship.toml
        success "Tema Sin Iconos Vacíos aplicado."
        ;;
    *)
        warn "Tema desconocido: $THEME. Usando Tokyo Night..."
        starship preset tokyo-night > ~/.config/starship.toml
        ;;
esac

# ── 9. Generar .zshrc ─────────────────────────────────────────────────────────
section "⚙️  Configurando .zshrc"

# Si .zshrc existe, preguntar antes de sobrescribir
if [ -L ~/.zshrc ] || [ -f ~/.zshrc ]; then
  read -p "  .zshrc ya existe. ¿Deseas respaldar y generar uno nuevo? [s/N]: " RESP
  if [[ "$RESP" =~ ^[sS]$ ]]; then
    info "Respaldando .zshrc existente..."
    mv ~/.zshrc ~/.zshrc.backup.$(date +%s)
  else
    info "Omitiendo generación de .zshrc."
    SKIP_ZSHRC=true
  fi
fi

UPDATE_ALIAS=$(system_update_alias)

if [ "$SKIP_ZSHRC" != true ]; then
cat << EOF > ~/.zshrc
# cargo path
export PATH="\$HOME/.cargo/bin:\$PATH"

# Verificar si estamos en zsh antes de cargar oh-my-zsh
if [ -n "\$ZSH_VERSION" ]; then
  export ZSH="\$HOME/.oh-my-zsh"
  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
  source \$ZSH/oh-my-zsh.sh
else
  # Si se ejecuta desde bash, cargar plugins manualmente
  [ -f "\$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "\$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "\$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "\$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# aliases modernos
alias ls="eza --icons=auto"
alias ll="eza -lah --icons --git"
alias lt="eza --tree --icons"
alias cat="bat --paging=never"
alias cd="z"
alias cls="clear"

# atajo de actualización del sistema
$UPDATE_ALIAS

# zoxide (cd inteligente)
eval "\$(zoxide init zsh)"

# fzf (búsqueda difusa)
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

# starship prompt
eval "\$(starship init zsh)"

# fastfetch al iniciar terminal interactiva
clear
if [[ \$- == *i* ]]; then
  fastfetch
fi
EOF

  success ".zshrc configurado."
fi

# ── 10. Cambiar shell por defecto a Zsh ───────────────────────────────────────
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Cambiando shell por defecto a Zsh..."
  chsh -s "$(which zsh)"
  success "Zsh configurado como shell por defecto."
fi

section "✅ Terminal Setup completo"
echo -e "  Ejecuta ${BOLD}exec zsh${RESET} o abre una nueva terminal para aplicar los cambios."
echo ""
