#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instalador con whiptail para Fedora/Ubuntu en Matebook 14
# ==============================================================================

set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/logger.sh"

DETECTED_OS="$OS_NAME $OS_VERSION"

# ── Verificar whiptail ────────────────────────────────────────────────────────
if ! command -v whiptail &>/dev/null; then
    echo "whiptail no está instalado. Instalando..."
    sudo dnf install -y newt || sudo apt install -y whiptail
fi

# ── Menú principal con whiptail ────────────────────────────────────────────────
show_main_menu() {
    local choice
    choice=$(whiptail --title "Fedora 44 Setup — Huawei Matebook 14" \
        --menu "Selecciona una opción:" 15 60 4 \
        "1" "Instalar TODOS los componentes" \
        "2" "Seleccionar componentes específicos" \
        "3" "Cambiar tema de terminal" \
        "4" "Desinstalar terminal alternativa (Kitty/Alacritty)" \
        "5" "Salir" \
        3>&1 1>&2 2>&3)
    echo "$choice"
}

# ── Menú de componentes con whiptail (checklist) ──────────────────────────────
show_component_menu() {
    local result
    result=$(whiptail --title "Selecciona los componentes" \
        --checklist "Usa ESPACIO para seleccionar y ENTER para continuar:" 22 70 13 \
        "1" "Sistema Base (Repositorios, Códecs, VA-API, Flatpak)" ON \
        "2" "Terminal (GNOME Terminal, zsh, Starship, eza...)" ON \
        "3" "Visual Studio Code + Extensiones" ON \
        "4" "Git + Clave SSH para GitHub" ON \
        "5" "Temas GNOME estilo macOS" OFF \
        "6" "Extensiones GNOME" OFF \
        "7" "Iconos GNOME (WhiteSur, Papirus...)" OFF \
        "8" "Fix Intel Screen Flicker" OFF \
        "9" "Brave Browser + alias bravefix" ON \
        "10" "Spotify (Cliente de música)" ON \
        "11" "OpenCode CLI (Asistente IA)" ON \
        3>&1 1>&2 2>&3)
    
    if [ -z "$result" ]; then
        echo ""
        return
    fi
    
    # Convertir resultado de whiptail a IDs internos
    local selected=""
    local items
    IFS='"' read -ra items <<< "$result"
    for item in "${items[@]}"; do
        case "$item" in
            1)  selected="$selected base" ;;
            2)  selected="$selected terminal" ;;
            3)  selected="$selected vscode" ;;
            4)  selected="$selected git" ;;
            5)  selected="$selected theme" ;;
            6)  selected="$selected extensions" ;;
            7)  selected="$selected icons" ;;
            8)  selected="$selected intel" ;;
            9)  selected="$selected brave" ;;
            10) selected="$selected spotify" ;;
            11) selected="$selected opencode" ;;
        esac
    done
    echo "$selected"
}

# ── Menú de temas con whiptail (radiolist) ────────────────────────────────────
show_theme_menu() {
    local theme
    theme=$(whiptail --title "Selecciona el tema de Starship" \
        --radiolist "Elige un tema para tu terminal:" 20 60 10 \
        "1" "Tokyo Night (oscuro, recomendado)" ON \
        "2" "Pastel Powerline (claro)" OFF \
        "3" "Gruvbox Rainbow (oscuro cálido)" OFF \
        "4" "Catppuccin Powerline (oscuro pastel)" OFF \
        "5" "Jetpack (minimalista)" OFF \
        "6" "Pure Prompt (clásico)" OFF \
        "7" "Cyberpunk Storm (neón intenso)" OFF \
        "8" "Cyberpunk Neon (máxima saturación)" OFF \
        "9" "Cyberpunk Night (sutel elegante)" OFF \
        3>&1 1>&2 2>&3)
    
    case "$theme" in
        1)  echo "tokyo-night" ;;
        2)  echo "pastel-powerline" ;;
        3)  echo "gruvbox-rainbow" ;;
        4)  echo "catppuccin-powerline" ;;
        5)  echo "jetpack" ;;
        6)  echo "pure-preset" ;;
        7)  echo "cyberpunk-storm" ;;
        8)  echo "cyberpunk-neon" ;;
        9)  echo "cyberpunk-night" ;;
        *)  echo "" ;;
    esac
}

# ── Menú de desinstalación ────────────────────────────────────────────────────
show_uninstall_menu() {
    local result
    result=$(whiptail --title "Desinstalar terminales alternativas" \
        --checklist "Selecciona las terminales a desinstalar:" 15 60 4 \
        "kitty" "Kitty Terminal" OFF \
        "alacritty" "Alacritty Terminal" OFF \
        3>&1 1>&2 2>&3)
    echo "$result"
}

# ── Confirmación de instalación ───────────────────────────────────────────────
show_confirm_dialog() {
    local components="$1"
    local theme="$2"
    
    local msg="Componentes seleccionados:\\n"
    msg+="\\n"
    
    for comp in $components; do
        case "$comp" in
            base)        msg+="  • Sistema Base\\n" ;;
            terminal)    msg+="  • Terminal (GNOME Terminal)\\n" ;;
            vscode)      msg+="  • Visual Studio Code\\n" ;;
            git)         msg+="  • Git + SSH\\n" ;;
            theme)       msg+="  • Temas GNOME\\n" ;;
            extensions)  msg+="  • Extensiones GNOME\\n" ;;
            icons)       msg+="  • Iconos GNOME\\n" ;;
            intel)       msg+="  • Intel Flicker Fix\\n" ;;
            brave)       msg+="  • Brave Browser\\n" ;;
            spotify)     msg+="  • Spotify\\n" ;;
            opencode)    msg+="  • OpenCode CLI\\n" ;;
        esac
    done
    
    if [ -n "$theme" ]; then
        msg+="\\nTema: $theme"
    fi
    
    msg+="\\n\\n¿Continuar con la instalación?"
    
    whiptail --title "Confirmar instalación" --yesno "$msg" 22 60
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    # Verificar SO
    if ! is_fedora && ! is_ubuntu; then
        whiptail --title "Error" --msgbox "Sistema operativo no soportado: $OS_ID\\nEste instalador funciona en Fedora o Ubuntu." 10 50
        exit 1
    fi
    
    while true; do
        local main_choice
        main_choice=$(show_main_menu)
        
        case "$main_choice" in
            1)
                # Instalar todos
                SELECTED="base terminal vscode git theme extensions icons intel brave spotify opencode"
                
                if echo "$SELECTED" | grep -qw "terminal"; then
                    THEME=$(show_theme_menu)
                    if [ -z "$THEME" ]; then
                        continue
                    fi
                    export TERMINAL_THEME="$THEME"
                fi
                
                if show_confirm_dialog "$SELECTED" "$THEME"; then
                    run_installation
                fi
                ;;
            2)
                # Selección personalizada
                SELECTED=$(show_component_menu)
                
                if [ -z "$SELECTED" ]; then
                    continue
                fi
                
                if echo "$SELECTED" | grep -qw "terminal"; then
                    THEME=$(show_theme_menu)
                    if [ -z "$THEME" ]; then
                        continue
                    fi
                    export TERMINAL_THEME="$THEME"
                fi
                
                if show_confirm_dialog "$SELECTED" "$THEME"; then
                    run_installation
                fi
                ;;
            3)
                # Cambiar tema
                bash "$SCRIPT_DIR/scripts/02-terminal/02-change-theme.sh"
                if [ $? -eq 0 ]; then
                    whiptail --title "Listo" --msgbox "Tema actualizado correctamente." 8 50
                fi
                ;;
            4)
                # Desinstalar terminales
                UNINSTALL=$(show_uninstall_menu)
                if [ -n "$UNINSTALL" ]; then
                    run_uninstall "$UNINSTALL"
                fi
                ;;
            5)
                # Salir
                exit 0
                ;;
            *)
                exit 0
                ;;
        esac
    done
}

# ── Ejecutar instalación ──────────────────────────────────────────────────────
run_installation() {
    chmod +x "$SCRIPT_DIR"/scripts/**/*.sh 2>/dev/null
    chmod +x "$SCRIPT_DIR"/scripts/*.sh 2>/dev/null
    
    if [ -n "$TERMINAL_THEME" ]; then
        TERMINAL_THEME="$TERMINAL_THEME" bash "$SCRIPT_DIR/scripts/runner.sh" $SELECTED
    else
        bash "$SCRIPT_DIR/scripts/runner.sh" $SELECTED
    fi
}

# ── Ejecutar desinstalación ───────────────────────────────────────────────────
run_uninstall() {
    local apps="$1"
    
    for app in $apps; do
        case "$app" in
            kitty)
                if command -v kitty &>/dev/null; then
                    sudo dnf remove -y kitty 2>/dev/null || sudo apt remove -y kitty 2>/dev/null
                    rm -rf ~/.config/kitty
                    log_success "Kitty desinstalado"
                fi
                ;;
            alacritty)
                if command -v alacritty &>/dev/null; then
                    sudo dnf remove -y alacritty 2>/dev/null || sudo apt remove -y alacritty 2>/dev/null
                    rm -rf ~/.config/alacritty
                    log_success "Alacritty desinstalado"
                fi
                ;;
        esac
    done
    
    # Asegurar que GNOME Terminal sea el default
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'gnome-terminal'
    fi
    
    whiptail --title "Listo" --msgbox "Terminales desinstaladas correctamente." 8 50
}

main "$@"
