#!/usr/bin/env bash
# ==============================================================================
# runner.sh — Ejecuta los scripts seleccionados con logging y progreso
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/logger.sh"

# Los scripts hijos heredan este log (logger.sh lo detecta y evita duplicar)
export _INSTALL_LOG_FILE="$LOG_FILE"
export _INSTALL_RUNNER=1

# Filtra códigos ANSI para que el log quede en texto plano
strip_ansi() { sed -ru 's/\x1B\[[0-9;]*[mK]//g'; }

# ── Verificar sudo ────────────────────────────────────────────────────────────
if ! sudo -n true 2>/dev/null; then
    log_warn "Algunos scripts requieren permisos de administrador (sudo)."
    log_warn "Se te pedirá tu contraseña cuando sea necesario."
fi

# ── Configurar logging ────────────────────────────────────────────────────────
SELECTED_IDS=("$@")
TOTAL=${#SELECTED_IDS[@]}
CURRENT=0

# El tema de terminal viene de la variable de entorno TERMINAL_THEME
if [ -n "$TERMINAL_THEME" ]; then
    THEME_NAME="$TERMINAL_THEME"
else
    THEME_NAME="tokyo-night"
fi

# ── Encabezado ────────────────────────────────────────────────────────────────
COMPONENTS_STR="${SELECTED_IDS[*]}"
log_header "$OS_NAME $OS_VERSION" "$COMPONENTS_STR"

# ── Función de paso ───────────────────────────────────────────────────────────
step() {
    CURRENT=$((CURRENT + 1))
    log_step "$CURRENT" "$TOTAL" "$1"
}

# ── Función reutilizable para ejecutar scripts ────────────────────────────────
run_script() {
    local name="$1"
    local script_path="$2"
    local use_sudo="${3:-false}"

    set +e
    if [ "$use_sudo" = "true" ]; then
        sudo "$SCRIPT_DIR/$script_path" 2>&1 | tee >(strip_ansi >> "$LOG_FILE")
    else
        "$SCRIPT_DIR/$script_path" 2>&1 | tee >(strip_ansi >> "$LOG_FILE")
    fi
    local result=${PIPESTATUS[0]}
    set -e

    if [ $result -ne 0 ]; then
        warn "Error en $name. Continuando..."
        RESULTS+=("$name [FAIL]")
    else
        RESULTS+=("$name [OK]")
    fi
}

# ── Array de resultados ───────────────────────────────────────────────────────
declare -a RESULTS=()

# ── Ejecutar scripts ─────────────────────────────────────────────────────────
for ID in "${SELECTED_IDS[@]}"; do
    case "$ID" in
        "base")
            step "Sistema Base (Repositorios, Códecs, VA-API, Flatpak)"
            run_script "Sistema Base" "scripts/01-system/01-base-system.sh" "true"
            ;;
        "terminal")
            step "Terminal & Herramientas (tema: $THEME_NAME)"
            run_script "Terminal ($THEME_NAME)" "scripts/02-terminal/01-terminal-setup.sh" "false"
            ;;
        "vscode")
            step "Visual Studio Code"
            run_script "Visual Studio Code" "scripts/03-development/01-vscode.sh" "true"
            ;;
        "git")
            step "Git + GitHub"
            run_script "Git + SSH" "scripts/03-development/02-git-ssh.sh" "false"
            ;;
        "gh")
            step "GitHub CLI"
            run_script "GitHub CLI" "scripts/03-development/03-github-cli.sh" "false"
            ;;
        "theme")
            step "Temas GNOME estilo macOS"
            run_script "Temas GNOME" "scripts/04-desktop/01-gnome-theme.sh" "false"
            ;;
        "intel")
            step "Fix Intel Screen Flicker"
            if lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
                run_script "Intel Flicker Fix" "scripts/05-hardware/01-intel-fix.sh" "true"
            else
                warn "GPU Intel no detectada. Omitiendo intel-fix"
                RESULTS+=("Intel Flicker Fix [SKIP]")
            fi
            ;;
        "extensions")
            step "Extensiones GNOME"
            run_script "Extensiones GNOME" "scripts/04-desktop/02-gnome-extensions.sh" "false"
            ;;
        "opencode")
            step "OpenCode CLI"
            run_script "OpenCode CLI" "scripts/06-apps/01-opencode.sh" "false"
            ;;
        "spotify")
            step "Spotify"
            run_script "Spotify" "scripts/06-apps/02-spotify.sh" "false"
            ;;
        "brave")
            step "Brave Browser"
            run_script "Brave Browser" "scripts/06-apps/03-brave.sh" "false"
            ;;
        "chrome")
            step "Google Chrome"
            run_script "Google Chrome" "scripts/06-apps/04-chrome.sh" "false"
            ;;
        "icons")
            step "Iconos GNOME"
            run_script "Iconos GNOME" "scripts/04-desktop/03-gnome-icons.sh" "false"
            ;;
    esac
done

# ── Agregar OpenCode al PATH ─────────────────────────────────────────────────
if command -v opencode &>/dev/null; then
    if ! grep -q '\.opencode/bin' ~/.zshrc 2>/dev/null; then
        log_info "Agregando OpenCode al PATH..."
        echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.zshrc
    fi
    source ~/.zshrc 2>/dev/null || true
fi

# ── Resumen Final ─────────────────────────────────────────────────────────────
log_summary "${RESULTS[@]}"

# ── Guardar referencia al log ─────────────────────────────────────────────────
LOG_PATH="$(get_log_file 2>/dev/null || echo 'N/A')"

SUMMARY_MSG="Instalacion completada.\\n\\nComponentes:\\n"
for result in "${RESULTS[@]}"; do
    SUMMARY_MSG+="  $result\\n"
done
SUMMARY_MSG+="\\nLog guardado en: $LOG_PATH\\n\\nReinicia la sesion para aplicar todos los cambios."

whiptail --title "Instalacion Completada" --msgbox "$SUMMARY_MSG" 20 70
