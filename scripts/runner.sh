#!/usr/bin/env bash
# ==============================================================================
# runner.sh — Ejecuta los scripts seleccionados con logging y progreso
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/logger.sh"

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

# ── Array de resultados ───────────────────────────────────────────────────────
declare -a RESULTS=()

# ── Ejecutar scripts ─────────────────────────────────────────────────────────
for ID in "${SELECTED_IDS[@]}"; do
    case "$ID" in
        "base")
            step "Sistema Base (Repositorios, Códecs, VA-API, Flatpak)"
            set +e
            sudo "$SCRIPT_DIR/scripts/01-system/01-base-system.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en sistema base. Continuando..."
                RESULTS+=("Sistema Base [FAIL]")
            else
                RESULTS+=("Sistema Base [OK]")
            fi
            ;;
        "terminal")
            step "Terminal & Herramientas (tema: $THEME_NAME)"
            set +e
            "$SCRIPT_DIR/scripts/02-terminal/01-terminal-setup.sh" "$THEME_NAME" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en terminal. Continuando..."
                RESULTS+=("Terminal ($THEME_NAME) [FAIL]")
            else
                RESULTS+=("Terminal ($THEME_NAME) [OK]")
            fi
            ;;
        "vscode")
            step "Visual Studio Code"
            set +e
            sudo "$SCRIPT_DIR/scripts/03-development/01-vscode.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en VS Code. Continuando..."
                RESULTS+=("Visual Studio Code [FAIL]")
            else
                RESULTS+=("Visual Studio Code [OK]")
            fi
            ;;
        "git")
            step "Git + GitHub"
            set +e
            "$SCRIPT_DIR/scripts/03-development/02-git-ssh.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en Git. Continuando..."
                RESULTS+=("Git + SSH [FAIL]")
            else
                RESULTS+=("Git + SSH [OK]")
            fi
            ;;
        "theme")
            step "Temas GNOME estilo macOS"
            set +e
            "$SCRIPT_DIR/scripts/04-desktop/01-gnome-theme.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en tema. Continuando..."
                RESULTS+=("Temas GNOME [FAIL]")
            else
                RESULTS+=("Temas GNOME [OK]")
            fi
            ;;
        "intel")
            step "Fix Intel Screen Flicker"
            if lspci | grep -qi "intel.*graphics\|intel.*vga\|intel.*display"; then
                set +e
                sudo "$SCRIPT_DIR/scripts/05-hardware/01-intel-fix.sh" 2>&1 | tee -a "$LOG_FILE"
                RESULT=$?
                set -e
                if [ $RESULT -ne 0 ]; then
                    warn "Error en Intel Fix. Continuando..."
                    RESULTS+=("Intel Flicker Fix [FAIL]")
                else
                    RESULTS+=("Intel Flicker Fix [OK]")
                fi
            else
                warn "GPU Intel no detectada. Omitiendo intel-fix"
                RESULTS+=("Intel Flicker Fix [SKIP]")
            fi
            ;;
        "extensions")
            step "Extensiones GNOME"
            set +e
            "$SCRIPT_DIR/scripts/04-desktop/02-gnome-extensions.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en extensiones. Continuando..."
                RESULTS+=("Extensiones GNOME [FAIL]")
            else
                RESULTS+=("Extensiones GNOME [OK]")
            fi
            ;;
        "opencode")
            step "OpenCode CLI"
            set +e
            "$SCRIPT_DIR/scripts/06-apps/01-opencode.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en OpenCode. Continuando..."
                RESULTS+=("OpenCode CLI [FAIL]")
            else
                RESULTS+=("OpenCode CLI [OK]")
            fi
            ;;
        "spotify")
            step "Spotify"
            set +e
            "$SCRIPT_DIR/scripts/06-apps/02-spotify.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en Spotify. Continuando..."
                RESULTS+=("Spotify [FAIL]")
            else
                RESULTS+=("Spotify [OK]")
            fi
            ;;
        "brave")
            step "Brave Browser"
            set +e
            "$SCRIPT_DIR/scripts/06-apps/03-brave.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en Brave Browser. Continuando..."
                RESULTS+=("Brave Browser [FAIL]")
            else
                RESULTS+=("Brave Browser [OK]")
            fi
            ;;
        "icons")
            step "Iconos GNOME"
            set +e
            "$SCRIPT_DIR/scripts/04-desktop/03-gnome-icons.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en Iconos. Continuando..."
                RESULTS+=("Iconos GNOME [FAIL]")
            else
                RESULTS+=("Iconos GNOME [OK]")
            fi
            ;;
        "change-theme")
            step "Cambio de Tema"
            set +e
            "$SCRIPT_DIR/scripts/02-terminal/02-change-theme.sh" 2>&1 | tee -a "$LOG_FILE"
            RESULT=$?
            set -e
            if [ $RESULT -ne 0 ]; then
                warn "Error en cambio de tema. Continuando..."
                RESULTS+=("Cambio de Tema [FAIL]")
            else
                RESULTS+=("Cambio de Tema [OK]")
            fi
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
