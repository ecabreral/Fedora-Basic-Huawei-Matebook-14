#!/usr/bin/env bash
# ==============================================================================
# 02-vscode.sh
# Instala VS Code en Fedora o Ubuntu (método oficial Microsoft)
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"
require_root

REAL_USER="${SUDO_USER:-$USER}"
if [ -z "$REAL_USER" ] || [ "$REAL_USER" = "root" ]; then
  REAL_USER="$USER"
fi

# VS Code no debe ejecutarse como root (sandbox); usar el usuario real
vscode_version() {
  sudo -u "$REAL_USER" code --version 2>/dev/null | head -1
}

section "Instalando Visual Studio Code en $OS_NAME"

# 1. Verificar si ya está instalado
if command -v code &>/dev/null; then
  success "VS Code ya está instalado: $(vscode_version)"
else
  if is_fedora; then
    # ── Fedora: repositorio RPM ───────────────────────────────────────────────
    info "Importando llave GPG de Microsoft..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    info "Agregando repositorio oficial de VS Code..."
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

    info "Instalando Visual Studio Code..."
    sudo dnf check-update || true
    sudo dnf install -y code
    success "Visual Studio Code instalado."

  elif is_ubuntu; then
    # ── Ubuntu: repositorio apt ───────────────────────────────────────────────
    info "Importando llave GPG de Microsoft..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    rm -f /tmp/packages.microsoft.gpg

    info "Agregando repositorio oficial de VS Code..."
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

    info "Instalando Visual Studio Code..."
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y code
    success "Visual Studio Code instalado."
  fi
fi

# Verificar si VS Code se instaló correctamente
if ! command -v code &>/dev/null; then
  warn "VS Code no se encontró después de la instalación. Omitiendo configuración."
  exit 0
fi

# ── 3. Configuración inicial de VS Code ───────────────────────────────────────
section "Configurando VS Code"

VSCODE_CONFIG_DIR="/home/$REAL_USER/.config/Code/User"
mkdir -p "$VSCODE_CONFIG_DIR"
chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.config" 2>/dev/null || true

if [ -f "$VSCODE_CONFIG_DIR/settings.json" ]; then
  info "settings.json ya existe. Omitiendo sobrescribir."
else
  cat > "$VSCODE_CONFIG_DIR/settings.json" << 'SETTINGS'
{
  "window.autoDetectColorScheme": true,
  "workbench.preferredLightColorTheme": "GitHub Light",
  "workbench.preferredDarkColorTheme": "GitHub Dark",
  "window.titleBarStyle": "custom",
  "editor.fontFamily": "JetBrains Mono, SF Mono, Menlo, monospace",
  "editor.fontLigatures": true,
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.minimap.enabled": false,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.formatOnSave": true,
  "files.autoSave": "afterDelay",
  "workbench.iconTheme": "vs-seti",
  "terminal.integrated.fontFamily": "JetBrains Mono"
}
SETTINGS
fi

chown -R "$REAL_USER":"$REAL_USER" "$VSCODE_CONFIG_DIR" 2>/dev/null || true
chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.config/Code" 2>/dev/null || true
chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.vscode" 2>/dev/null || true

success "Configuración de VS Code aplicada."

section "Visual Studio Code listo"
echo -e "  Versión instalada: ${BOLD}$(vscode_version)${RESET}"
echo -e "  Ejecuta ${BOLD}code${RESET} para abrir VS Code."
echo ""
