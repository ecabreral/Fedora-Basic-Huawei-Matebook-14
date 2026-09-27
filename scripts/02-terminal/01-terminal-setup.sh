#!/usr/bin/env bash
# ==============================================================================
# 01-terminal-setup.sh
# Configura un entorno de terminal moderno en Fedora o Ubuntu.
# ==============================================================================

# No usar set -e para permitir continuar aunque sudo falle
source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../../lib/ptyxis-colors.sh"

THEME="${1:-$TERMINAL_THEME}"
THEME="${THEME:-tokyo-night}"

section "Configuración de terminal ($OS_NAME $OS_VERSION)"

# ── 1. Actualizar sistema ─────────────────────────────────────────────────────
info "Actualizando lista de paquetes..."
pkg_update
info "Actualizando sistema..."
system_upgrade 2>/dev/null || success "Sistema ya actualizado."

# ── 2. Instalar paquetes en un solo bloque ────────────────────────────────────
section "Instalando paquetes"

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

# ── 3. Verificar Ptyxis ──────────────────────────────────────────────────────
section "Terminal Ptyxis"
if command -v ptyxis &>/dev/null; then
  success "Ptyxis ya está instalada."
else
  info "Instalando Ptyxis (terminal por defecto de Fedora moderno)..."
  pkg_install ptyxis

  if command -v ptyxis &>/dev/null; then
    success "Ptyxis instalada correctamente."
  else
    warn "No se pudo instalar Ptyxis en $OS_NAME."
    warn "Continuando sin configuración de terminal (zsh/Starship funcionarán igual)."
  fi
fi

# ── 4. eza (reemplazo moderno de ls) ─────────────────────────────────────────
section "Instalando eza"
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
section "Fuente Nerd"
install_nerd_font

# ── 5. Oh My Zsh ──────────────────────────────────────────────────────────────
section "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  success "Oh My Zsh ya está instalado."
else
  info "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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
section "Starship"
if command -v starship &>/dev/null; then
  success "Starship ya está instalado."
else
  info "Instalando Starship..."
  curl -sS --proto '=https' --tlsv1.2 https://starship.rs/install.sh -o /tmp/starship-install.sh
  # "-s --" solo aplica cuando el instalador se ejecuta vía "curl | sh -s --";
  # al ejecutar el archivo ya descargado esos tokens se pasarían como
  # argumentos literales al script y romperían el modo --yes (no interactivo).
  sh /tmp/starship-install.sh --yes
  rm -f /tmp/starship-install.sh
  success "Starship instalado."
fi

# ── 8. Configurar Starship (tema seleccionado) ──────────────────────────────
section "Configurando Starship"
mkdir -p ~/.config

info "Aplicando tema Starship: $THEME"

# Respaldo automático si ya existe configuración
if [ -f ~/.config/starship.toml ]; then
  if [ ! -t 0 ]; then
    info "starship.toml ya existe. Omitiendo generación (modo automatizado)."
    SKIP_STARSHIP=true
  else
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
fi

if [ "$SKIP_STARSHIP" != true ]; then
rm -f ~/.config/starship.toml
apply_starship_theme "$THEME"
fi

# ── 9. Configurar Ptyxis con tema seleccionado ────────────────────────────────
section "Configurando Ptyxis: $THEME"

if command -v ptyxis &>/dev/null; then
  apply_ptyxis_theme "$THEME"
else
  warn "Ptyxis no está disponible. Omitiendo configuración de tema."
fi

# ── 10. Generar configuración de zsh (snippets en conf.d) ───────────────────
section "Configurando zsh (snippets en ~/.config/zsh/conf.d/)"

ZSH_CONF_DIR="$HOME/.config/zsh/conf.d"
mkdir -p "$ZSH_CONF_DIR"

UPDATE_ALIAS=$(system_update_alias)

# Si .zshrc existe y no es un symlink a nuestro template, preguntar antes de respaldar
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

if [ "$SKIP_ZSHRC" != true ]; then
  # ── 00-path.sh ─────────────────────────────────────────────────────────────
  cat << 'EOF' > "$ZSH_CONF_DIR/00-path.sh"
# cargo path
export PATH="$HOME/.cargo/bin:$PATH"
EOF

  # ── 10-oh-my-zsh.sh ────────────────────────────────────────────────────────
  cat << 'EOF' > "$ZSH_CONF_DIR/10-oh-my-zsh.sh"
# Verificar si estamos en zsh antes de cargar oh-my-zsh
if [ -n "$ZSH_VERSION" ]; then
  export ZSH="$HOME/.oh-my-zsh"
  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
  source $ZSH/oh-my-zsh.sh
else
  # Si se ejecuta desde bash, cargar plugins manualmente
  [ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF

  # ── 20-aliases.sh ──────────────────────────────────────────────────────────
  cat << EOF > "$ZSH_CONF_DIR/20-aliases.sh"
# aliases modernos
alias ls="eza --icons=auto"
alias ll="eza -lah --icons --git"
alias lt="eza --tree --icons"
alias cat="bat --paging=never"
alias cd="z"
alias cls="clear"

# atajo de actualización del sistema
$UPDATE_ALIAS
EOF

  # ── 30-tools.sh ─────────────────────────────────────────────────────────────
  cat << 'EOF' > "$ZSH_CONF_DIR/30-tools.sh"
# zoxide (cd inteligente)
eval "$(zoxide init zsh)"

# fzf (búsqueda difusa)
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

# starship prompt
eval "$(starship init zsh)"
EOF

  # ── 40-motd.sh ──────────────────────────────────────────────────────────────
  cat << 'EOF' > "$ZSH_CONF_DIR/40-motd.sh"
# fastfetch al iniciar terminal interactiva
clear
if [[ $- == *i* ]]; then
  fastfetch
fi
EOF

  # ── .zshrc mínimo que carga los snippets ───────────────────────────────────
  cat << 'EOF' > ~/.zshrc
# ~/.zshrc — generado por Fedora System Setup
# Carga snippets desde ~/.config/zsh/conf.d/ (orden alfabético)
for snippet in ~/.config/zsh/conf.d/*.zsh(N); do
  source "$snippet"
done
EOF

  success "Configuración de zsh generada en ~/.config/zsh/conf.d/ y ~/.zshrc."
fi

# ── 10. Cambiar shell por defecto a Zsh ───────────────────────────────────────
if ! command -v zsh &>/dev/null; then
  warn "Zsh no está instalado. No se puede cambiar la shell por defecto."
elif [ "$SHELL" != "$(which zsh)" ]; then
  # Registrar zsh en /etc/shells si no está (evita fallo silencioso con zsh de cargo/binario)
  if ! grep -qxF "$(which zsh)" /etc/shells 2>/dev/null; then
    info "Registrando zsh en /etc/shells..."
    echo "$(which zsh)" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ ! -t 0 ]; then
    info "Modo no interactivo: no se puede ejecutar chsh automáticamente."
    info "Ejecuta manualmente: chsh -s $(which zsh)"
  else
    info "Cambiando shell por defecto a Zsh..."
    chsh -s "$(which zsh)"
    success "Zsh configurado como shell por defecto."
  fi
fi

# ── 12. Establecer Ptyxis como terminal por defecto ──────────────────────────
if command -v ptyxis &>/dev/null; then
  section "Estableciendo Ptyxis como terminal por defecto"
  set_ptyxis_as_default_terminal
fi

section "Configuración de terminal completada"
echo ""
echo "  Terminal: Ptyxis (default Fedora 41+)"
echo "  Fuente: JetBrainsMono Nerd Font"
echo "  Tema: $THEME"
echo ""
echo "  Atajos de teclado (Ptyxis):"
echo "    Ctrl+Shift+T       Nueva pestaña"
echo "    Ctrl+Shift+N       Nueva ventana"
echo "    Ctrl+Shift+C/V     Copiar/Pegar"
echo "    Ctrl+Shift+F       Buscar"
echo "    Ctrl+PageUp/Down   Navegar pestañas"
echo ""
echo "  Ejecuta exec zsh o abre una nueva terminal para aplicar los cambios."
echo ""
