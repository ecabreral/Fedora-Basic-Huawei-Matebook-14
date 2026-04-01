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

# 1. Agregar repo de Microsoft
info "Importando llave GPG de Microsoft..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

info "Agregando repositorio oficial de VS Code..."
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# 2. Instalar
info "Actualizando repositorios..."
sudo dnf check-update
info "Instalando Visual Studio Code..."
sudo dnf install -y code
success "Visual Studio Code instalado."

echo "✔️ Este es el método oficial para Fedora"

# ── 3. Configuración inicial de VS Code ───────────────────────────────────────

section "⚙️  Configurando VS Code"

success "Configuración de VS Code aplicada."

REAL_USER="${SUDO_USER:-$USER}"
VSCODE_CONFIG="/home/$REAL_USER/.config/Code/User"
mkdir -p "$VSCODE_CONFIG"

cat > "$VSCODE_CONFIG/settings.json" << 'SETTINGS'
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
chown -R "$REAL_USER":"$REAL_USER" "$VSCODE_CONFIG"
success "Configuración de VS Code aplicada."

section "✅ VS Code listo"
echo -e "  Versión instalada: ${BOLD}$(code --version | head -1)${RESET}"
echo -e "  Ejecuta ${BOLD}code${RESET} para abrir VS Code."
echo ""

read -p "¿VS Code mostró error de permisos al abrir? (s/N): " RESP
if [[ "$RESP" =~ ^[sS]$ ]]; then
  echo "Corrigiendo permisos de VS Code..."
  sudo chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.config/Code"
  sudo chown -R "$REAL_USER":"$REAL_USER" "/home/$REAL_USER/.vscode"
  echo "Permisos corregidos. Intenta abrir VS Code de nuevo."
else
  echo "No se detectaron problemas de permisos. Instalación finalizada."
fi
