#!/usr/bin/env bash
# ==============================================================================
# 01-vscode.sh
# Instala VS Code en Fedora o Ubuntu (método oficial Microsoft)
# ==============================================================================

# No usar set -e: se maneja cada paso explícitamente para poder reportar
# qué falló sin abortar en silencio a mitad de la instalación.
source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../../lib/privilege.sh"
require_root

# VS Code no debe ejecutarse como root (sandbox); usar el usuario real
vscode_version() {
  run_as_user code --version 2>/dev/null | head -1
}

section "Instalando Visual Studio Code en $OS_NAME"

# 1. Verificar si ya está instalado
if command -v code &>/dev/null; then
  success "VS Code ya está instalado: $(vscode_version)"
else
  if is_fedora; then
    # ── Fedora: repositorio RPM ───────────────────────────────────────────────
    # Importar la llave desde un archivo, no por process substitution:
    # "sudo rpm --import <(curl ...)" falla con "import read failed(2)" porque
    # sudo no hereda el file descriptor creado por <(). Además, descargar a
    # archivo permite verificar el tamaño del contenido antes de importar.
    if rpm -q gpg-pubkey --qf '%{SUMMARY}\n' 2>/dev/null | grep -qi 'Microsoft'; then
      success "Llave GPG de Microsoft ya importada."
    else
      MS_KEY=/tmp/microsoft.asc
      if ! secure_fetch "https://packages.microsoft.com/keys/microsoft.asc" \
          "$MS_KEY" "llave GPG de Microsoft"; then
        error "No se pudo descargar la llave GPG de Microsoft. Abortando."
        exit 1
      fi

      info "Importando llave GPG de Microsoft..."
      if sudo rpm --import "$MS_KEY"; then
        success "Llave GPG importada."
      else
        rm -f "$MS_KEY"
        error "No se pudo importar la llave GPG de Microsoft. Abortando."
        exit 1
      fi
      rm -f "$MS_KEY"
    fi

    # Idempotente: no sobrescribir si el repo ya está bien configurado.
    VSCODE_REPO=/etc/yum.repos.d/vscode.repo
    if [ -f "$VSCODE_REPO" ] && grep -q "packages.microsoft.com/yumrepos/vscode" "$VSCODE_REPO"; then
      success "Repositorio de VS Code ya configurado."
    else
      info "Agregando repositorio oficial de VS Code..."
      printf '%s\n' \
        '[code]' \
        'name=Visual Studio Code' \
        'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
        'enabled=1' \
        'gpgcheck=1' \
        'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
        | sudo tee "$VSCODE_REPO" > /dev/null
      success "Repositorio agregado."
    fi

    info "Instalando Visual Studio Code..."
    sudo dnf check-update || true
    if sudo dnf install -y code; then
      success "Visual Studio Code instalado."
    else
      error "No se pudo instalar VS Code."
      exit 1
    fi

  elif is_ubuntu; then
    # ── Ubuntu: repositorio apt ───────────────────────────────────────────────
    info "Importando llave GPG de Microsoft..."
    MS_KEY=/tmp/packages.microsoft.asc
    if secure_fetch "https://packages.microsoft.com/keys/microsoft.asc" \
        "$MS_KEY" "llave GPG de Microsoft"; then
      gpg --dearmor < "$MS_KEY" > /tmp/packages.microsoft.gpg \
        && sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg \
             /etc/apt/trusted.gpg.d/packages.microsoft.gpg
      rm -f "$MS_KEY" /tmp/packages.microsoft.gpg
      success "Llave GPG importada."
    else
      error "No se pudo importar la llave GPG de Microsoft. Abortando."
      exit 1
    fi

    VSCODE_LIST=/etc/apt/sources.list.d/vscode.list
    if [ -f "$VSCODE_LIST" ] && grep -q "packages.microsoft.com/repos/code" "$VSCODE_LIST"; then
      success "Repositorio de VS Code ya configurado."
    else
      info "Agregando repositorio oficial de VS Code..."
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee "$VSCODE_LIST" > /dev/null
      success "Repositorio agregado."
    fi

    info "Instalando Visual Studio Code..."
    sudo apt update
    if sudo DEBIAN_FRONTEND=noninteractive apt install -y code; then
      success "Visual Studio Code instalado."
    else
      error "No se pudo instalar VS Code."
      exit 1
    fi
  fi
fi

# Verificar si VS Code se instaló correctamente
if ! command -v code &>/dev/null; then
  warn "VS Code no se encontró después de la instalación. Omitiendo configuración."
  exit 0
fi

# ── 3. Configuración inicial de VS Code ───────────────────────────────────────
section "Configurando VS Code"

# user_path evita asumir /home/<user>: en Fedora Silverblue el home es /var/home.
VSCODE_CONFIG_DIR="$(user_path '.config/Code/User')"
VSCODE_CONFIG_ROOT="$(user_path '.config/Code')"
VSCODE_EXTENSIONS_DIR="$(user_path '.vscode')"
mkdir -p "$VSCODE_CONFIG_DIR"
# Solo se ajusta el propietario del árbol de VS Code, nunca de ~/.config entero:
# un "chown -R ~/.config" tocaría la configuración de todas las demás apps.
chown -R "$INSTALL_USER":"$INSTALL_USER" "$VSCODE_CONFIG_ROOT" 2>/dev/null || true

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

chown -R "$INSTALL_USER":"$INSTALL_USER" "$VSCODE_CONFIG_DIR" 2>/dev/null || true
[ -d "$VSCODE_EXTENSIONS_DIR" ] && \
  chown -R "$INSTALL_USER":"$INSTALL_USER" "$VSCODE_EXTENSIONS_DIR" 2>/dev/null || true

success "Configuración de VS Code aplicada."

section "Visual Studio Code listo"
echo -e "  Versión instalada: ${BOLD}$(vscode_version)${RESET}"
echo -e "  Ejecuta ${BOLD}code${RESET} para abrir VS Code."
echo ""
wait_for_enter
