#!/usr/bin/env bash
# ==============================================================================
# 02-vscode.sh
# INSTALAR VS CODE CORRECTAMENTE EN FEDORA 43
# Método recomendado (OFICIAL Microsoft)
# Ejecuta TODO esto:
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"
require_root

enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc

section "💻 INSTALAR VS CODE CORRECTAMENTE EN FEDORA 43"

# 1. Verificar si ya está instalado
if command -v code &>/dev/null; then
  success "VS Code ya está instalado: $(code --version | head -1)"
else
  # 2. Agregar repo de Microsoft
  info "Importando llave GPG de Microsoft..."
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

  info "Agregando repositorio oficial de VS Code..."
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

  # 3. Instalar
  info "Actualizando repositorios..."
  sudo dnf check-update || true
  info "Instalando Visual Studio Code..."
  if sudo dnf install -y code; then
    success "Visual Studio Code instalado."
  else
    error "Error al instalar VS Code. Intentando método alternativo..."
    # Intentar instalar sin -y (para Fedora nuevo)
    sudo dnf install code || warn "No se pudo instalar VS Code."
  fi
fi

echo "✔️ Este es el método oficial para Fedora"

# Verificar si VS Code se instaló correctamente
if ! command -v code &>/dev/null; then
  warn "VS Code no se encontró después de la instalación. Omitiendo configuración."
  exit 0
fi

# ── 3. Configuración inicial de VS Code ───────────────────────────────────────
section "⚙️  Configurando VS Code"

REAL_USER="${SUDO_USER:-$USER}"
if [ -z "$REAL_USER" ] || [ "$REAL_USER" = "root" ]; then
  REAL_USER="$USER"
fi

# Crear directorio de configuración
VSCODE_CONFIG_DIR="/home/$REAL_USER/.config/Code/User"
mkdir -p "$VSCODE_CONFIG_DIR"
chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.config" 2>/dev/null || true

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

chown -R "$REAL_USER":"$REAL_USER" "$VSCODE_CONFIG_DIR" 2>/dev/null || true

# También asegurar permisos del directorio de usuario
chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.config/Code" 2>/dev/null || true
chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.vscode" 2>/dev/null || true

success "Configuración de VS Code aplicada."

section "✅ VS Code listo"
echo -e "  Versión instalada: ${BOLD}$(code --version | head -1)${RESET}"
echo -e "  Ejecuta ${BOLD}code${RESET} para abrir VS Code."
echo ""
