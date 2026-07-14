#!/usr/bin/env bash
# ==============================================================================
# 01-terminal-setup.sh
# Configura un entorno de terminal moderno en Fedora o Ubuntu.
# ==============================================================================

# No usar set -e para permitir continuar aunque sudo falle
source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../../lib/gnome-terminal-colors.sh"

THEME="${1:-$TERMINAL_THEME}"
THEME="${THEME:-tokyo-night}"

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

# ── 3. Verificar GNOME Terminal ──────────────────────────────────────────────
section "🖥️  GNOME Terminal"
if command -v gnome-terminal &>/dev/null; then
  success "GNOME Terminal ya está instalado."
else
  info "Instalando GNOME Terminal..."
  if is_fedora; then
    pkg_install gnome-terminal
  elif is_ubuntu; then
    pkg_install gnome-terminal
  fi

  if command -v gnome-terminal &>/dev/null; then
    success "GNOME Terminal instalado correctamente."
  else
    error "Error al instalar GNOME Terminal."
  fi
fi

# ── 4. eza (reemplazo moderno de ls) ─────────────────────────────────────────
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
install_nerd_font

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
  curl -sS https://starship.rs/install.sh -o /tmp/starship-install.sh
  sh /tmp/starship-install.sh -s -- --yes
  rm -f /tmp/starship-install.sh
  success "Starship instalado."
fi

# ── 8. Configurar Starship (tema seleccionado) ──────────────────────────────
section "🎨 Configurando Starship"
mkdir -p ~/.config

info "Aplicando tema Starship: $THEME"

# Respaldo automático si ya existe configuración
if [ -f ~/.config/starship.toml ]; then
  read -p "  starship.toml ya existe. ¿Deseas respaldar y generar uno nuevo? [s/N]: " RESP
  if [[ "$RESP" =~ ^[sS]$ ]]; then
    mkdir -p ~/.config/theme-backups
    cp ~/.config/starship.toml ~/.config/theme-backups/starship.toml.backup.$(date +%s)
    success "Starship respaldado."
  else
    info "Omitiendo generación de starship.toml."
    SKIP_STARSHIP=true
  fi
fi

if [ "$SKIP_STARSHIP" != true ]; then
rm -f ~/.config/starship.toml
apply_starship_theme "$THEME"
fi

# ── 9. Configurar GNOME Terminal con tema seleccionado ───────────────────────
section "🎨 Configurando GNOME Terminal: $THEME"

if command -v gnome-terminal &>/dev/null && command -v dconf &>/dev/null; then
  # Obtener el perfil por defecto
  PROFILE=$(get_default_profile)

  if [ -n "$PROFILE" ]; then
    PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$PROFILE"

    info "Aplicando tema '$THEME' al perfil: $PROFILE"
    apply_gnome_terminal_theme "$PROFILE_PATH"
    success "GNOME Terminal configurado con tema: $THEME"
  else
    # Crear un nuevo perfil si no existe ninguno
    info "No se encontró perfil de GNOME Terminal. Creando uno nuevo..."

    # Generar UUID para el nuevo perfil
    NEW_UUID=$(uuidgen)
    NEW_UUID_LOWER=$(echo "$NEW_UUID" | tr '[:upper:]' '[:lower:]')

    # Crear el perfil
    dconf write /org/gnome/terminal/legacy/profiles: "['$NEW_UUID_LOWER']"
    dconf write "/org/gnome/terminal/legacy/profiles:/:$NEW_UUID_LOWER/visible-name" "'$THEME'"
    dconf write "/org/gnome/terminal/legacy/profiles:/:$NEW_UUID_LOWER/default-size-columns" "120"
    dconf write "/org/gnome/terminal/legacy/profiles:/:$NEW_UUID_LOWER/default-size-rows" "35"
    dconf write "/org/gnome/terminal/legacy/profiles:/:$NEW_UUID_LOWER/use-system-font" "false"
    dconf write "/org/gnome/terminal/legacy/profiles:/:$NEW_UUID_LOWER/font" "'JetBrainsMono Nerd Font 11'"

    # Aplicar el tema
    PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$NEW_UUID_LOWER"
    apply_gnome_terminal_theme "$PROFILE_PATH"

    success "Nuevo perfil de GNOME Terminal creado con tema: $THEME"
  fi
else
  warn "GNOME Terminal o dconf no están disponibles. Omitiendo configuración de tema."
fi

# ── 10. Generar .zshrc ────────────────────────────────────────────────────────
section "⚙️  Configurando .zshrc"

# Si .zshrc existe, preguntar antes de sobrescribir
if [ -L ~/.zshrc ] || [ -f ~/.zshrc ]; then
  if [ ! -t 0 ]; then
    info ".zshrc ya existe. Omitiendo generación (modo automatizado)."
    SKIP_ZSHRC=true
  else
    read -p "  .zshrc ya existe. ¿Deseas respaldar y generar uno nuevo? [s/N]: " RESP
    if [[ "$RESP" =~ ^[sS]$ ]]; then
      info "Respaldando .zshrc existente..."
      mv ~/.zshrc ~/.zshrc.backup.$(date +%s)
    else
      info "Omitiendo generación de .zshrc."
      SKIP_ZSHRC=true
    fi
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

# ── 12. Establecer GNOME Terminal como terminal por defecto ──────────────────
if command -v gnome-terminal &>/dev/null; then
  section "Estableciendo GNOME Terminal como terminal por defecto"

  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.default-applications.terminal exec 'gnome-terminal'
    success "GNOME Terminal configurado como terminal por defecto en GNOME."
  fi

  if [ -f "$(which gnome-terminal)" ]; then
    sudo ln -sf "$(which gnome-terminal)" /usr/local/bin/x-terminal-emulator 2>/dev/null || true
    success "Symlink x-terminal-emulator creado."
  fi
fi

section "Terminal Setup completo"
echo ""
echo "  Terminal: GNOME Terminal (default Fedora)"
echo "  Fuente: JetBrainsMono Nerd Font"
echo "  Tema: $THEME"
echo ""
echo "  Atajos de teclado (GNOME Terminal):"
echo "    Ctrl+Shift+T       Nueva pestaña"
echo "    Ctrl+Shift+W       Cerrar pestaña"
echo "    Ctrl+Shift+E       Nueva ventana"
echo "    Ctrl+Shift+O       Nuevo split horizontal"
echo "    Ctrl+Shift+J       Nuevo split vertical"
echo "    Alt+←/→            Navegar paneles"
echo ""
echo "  Ejecuta exec zsh o abre una nueva terminal para aplicar los cambios."
echo ""
