#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instalador con whiptail para Fedora/Ubuntu en Matebook 14
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/logger.sh"

DETECTED_OS="$OS_NAME $OS_VERSION"

# ── Flags de línea de comandos ───────────────────────────────────────────────
DRY_RUN=false
SHOW_HELP=false
UNINSTALL_MODE=false
CLI_COMPONENTS=""
CLI_THEME=""

show_help() {
    echo "Uso: ./setup.sh [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --help              Muestra esta ayuda"
    echo "  --dry-run           Muestra qué haría sin ejecutar nada"
    echo "  --component <name>  Instala un componente específico (base, terminal, vscode, git, theme, extensions, icons, intel, brave, spotify, opencode)"
    echo "  --theme <name>      Selecciona tema para terminal (tokyo-night, pastel-powerline, gruvbox-rainbow, catppuccin-powerline, jetpack, pure-preset, cyberpunk-storm, cyberpunk-neon, cyberpunk-night)"
    echo "  --uninstall         Modo desinstalación interactiva"
    echo ""
    echo "Ejemplos:"
    echo "  ./setup.sh                                    # Modo interactivo (whiptail)"
    echo "  ./setup.sh --component base --theme tokyo-night  # Instala solo base con tema"
    echo "  ./setup.sh --dry-run                          # Solo muestra qué haría"
    echo "  ./setup.sh --uninstall                        # Desinstalar componentes"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --component)
            CLI_COMPONENTS="$CLI_COMPONENTS $2"
            shift 2
            ;;
        --theme)
            CLI_THEME="$2"
            shift 2
            ;;
        --uninstall)
            UNINSTALL_MODE=true
            shift
            ;;
        *)
            error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

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

# ── Menú de componentes por categoría ────────────────────────────────────────
show_component_menu() {
    local SELECTED=""
    
    while true; do
        local cat_choice
        cat_choice=$(whiptail --title "Selecciona componentes" \
            --menu "Elige una categoría para agregar componentes:" 18 60 8 \
            "1" "🖥️  Sistema" \
            "2" "🐚 Terminal" \
            "3" "💻 Desarrollo" \
            "4" "🌐 Navegadores" \
            "5" "🎵 Multimedia" \
            "6" "🎨 Escritorio GNOME" \
            "7" "🔧 Hardware" \
            "8" "✅ Seleccionar TODO" \
            "9" "▶️  Continuar con la instalación" \
            3>&1 1>&2 2>&3)
        
        case "$cat_choice" in
            1) # Sistema
                local r
                r=$(whiptail --title "Sistema" --checklist \
                    "Selecciona componentes del sistema:" 10 60 2 \
                    "base" "Sistema Base (Repositorios, Códecs, VA-API, Flatpak)" ON \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            2) # Terminal
                local r
                r=$(whiptail --title "Terminal" --checklist \
                    "Selecciona componentes de terminal:" 10 60 2 \
                    "terminal" "Terminal (Ptyxis, zsh, Starship, eza...)" ON \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            3) # Desarrollo
                local r
                r=$(whiptail --title "Desarrollo" --checklist \
                    "Selecciona herramientas de desarrollo:" 14 60 4 \
                    "vscode" "Visual Studio Code + Extensiones" ON \
                    "git" "Git + Clave SSH para GitHub" ON \
                    "opencode" "OpenCode CLI (Asistente IA)" ON \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            4) # Navegadores
                local r
                r=$(whiptail --title "Navegadores" --checklist \
                    "Selecciona navegadores:" 10 60 3 \
                    "brave" "Brave Browser + alias bravefix" ON \
                    "chrome" "Google Chrome" OFF \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            5) # Multimedia
                local r
                r=$(whiptail --title "Multimedia" --checklist \
                    "Selecciona apps multimedia:" 10 60 2 \
                    "spotify" "Spotify (Cliente de música)" ON \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            6) # Escritorio GNOME
                local r
                r=$(whiptail --title "Escritorio GNOME" --checklist \
                    "Selecciona componentes de escritorio:" 14 60 4 \
                    "theme" "Temas GNOME estilo macOS" OFF \
                    "extensions" "Extensiones GNOME" OFF \
                    "icons" "Iconos GNOME (WhiteSur, Papirus...)" OFF \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            7) # Hardware
                local r
                r=$(whiptail --title "Hardware" --checklist \
                    "Selecciona fixes de hardware:" 10 60 2 \
                    "intel" "Fix Intel Screen Flicker" OFF \
                    3>&1 1>&2 2>&3)
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                ;;
            8) # Seleccionar TODO
                SELECTED="base terminal vscode git theme extensions icons intel brave spotify opencode chrome"
                whiptail --title "TODO seleccionado" --msgbox "Todos los componentes seleccionados." 8 50
                ;;
            9) # Continuar
                if [ -z "$SELECTED" ]; then
                    whiptail --title "Sin componentes" --msgbox "No seleccionaste ningún componente." 8 50
                else
                    echo "$SELECTED"
                    return 0
                fi
                ;;
            *)
                echo ""
                return 1
                ;;
        esac
    done
}

# ── Menú de temas con whiptail (radiolist) ────────────────────────────────────
show_theme_menu() {
    show_theme_selector
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
            terminal)    msg+="  • Terminal (Ptyxis)\\n" ;;
            vscode)      msg+="  • Visual Studio Code\\n" ;;
            git)         msg+="  • Git + SSH\\n" ;;
            theme)       msg+="  • Temas GNOME\\n" ;;
            extensions)  msg+="  • Extensiones GNOME\\n" ;;
            icons)       msg+="  • Iconos GNOME\\n" ;;
            intel)       msg+="  • Intel Flicker Fix\\n" ;;
            brave)       msg+="  • Brave Browser\\n" ;;
            chrome)      msg+="  • Google Chrome\\n" ;;
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
    
    # Modo CLI (sin whiptail)
    if [ -n "$CLI_COMPONENTS" ]; then
        local SELECTED=$(echo "$CLI_COMPONENTS" | xargs)
        local THEME="$CLI_THEME"
        
        if [ "$DRY_RUN" = true ]; then
            info "[DRY RUN] Se instalarían: $SELECTED"
            [ -n "$THEME" ] && info "[DRY RUN] Tema: $THEME"
            return 0
        fi
        
        if [ -n "$THEME" ]; then
            export TERMINAL_THEME="$THEME"
        fi
        
        run_installation
        return $?
    fi
    
    # Modo desinstalación
    if [ "$UNINSTALL_MODE" = true ]; then
        run_full_uninstall
        return $?
    fi
    
    # Modo dry-run sin componentes
    if [ "$DRY_RUN" = true ]; then
        info "[DRY RUN] Modo interactivo — ejecuta sin --dry-run para instalar"
        return 0
    fi
    
    while true; do
        local main_choice
        main_choice=$(show_main_menu)
        
        case "$main_choice" in
            1)
                # Instalar todos
                local SELECTED="base terminal vscode git theme extensions icons intel brave spotify opencode"
                local THEME=""
                
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
                local SELECTED=$(show_component_menu)
                local THEME=""
                
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
    
    # Asegurar que Ptyxis sea el default
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'ptyxis'
    fi
    
    whiptail --title "Listo" --msgbox "Terminales desinstaladas correctamente." 8 50
}

# ── Desinstalación completa de componentes ─────────────────────────────────────
run_full_uninstall() {
    local COMPONENTS=$(whiptail --title "Desinstalar Componentes" --checklist \
        "Selecciona los componentes a desinstalar:" 18 60 12 \
        "vscode" "Visual Studio Code" OFF \
        "brave" "Brave Browser" OFF \
        "chrome" "Google Chrome" OFF \
        "spotify" "Spotify" OFF \
        "starship" "Starship Prompt" OFF \
        "ohmyzsh" "Oh My Zsh" OFF \
        "extensions" "Extensiones GNOME" OFF \
        "themes" "Temas GNOME" OFF \
        "icons" "Iconos" OFF \
        "opencode" "OpenCode CLI" OFF \
        3>&1 1>&2 2>&3)
    
    if [ -z "$COMPONENTS" ]; then
        return 0
    fi
    
    for item in $COMPONENTS; do
        local comp=$(echo "$item" | tr -d '"')
        case "$comp" in
            vscode)
                sudo dnf remove -y code 2>/dev/null || sudo snap remove code 2>/dev/null
                rm -rf ~/.config/Code ~/.vscode
                log_success "VS Code desinstalado"
                ;;
            brave)
                sudo dnf remove -y brave-browser 2>/dev/null
                rm -rf ~/.config/BraveSoftware
                log_success "Brave desinstalado"
                ;;
            chrome)
                sudo dnf remove -y google-chrome-stable 2>/dev/null
                sudo dnf config-manager disable google-chrome 2>/dev/null
                rm -rf ~/.config/google-chrome
                log_success "Google Chrome desinstalado"
                ;;
            spotify)
                sudo dnf remove -y spotify 2>/dev/null || sudo snap remove spotify 2>/dev/null
                log_success "Spotify desinstalado"
                ;;
            starship)
                rm -f ~/.local/bin/starship
                rm -f ~/.config/starship.toml
                log_success "Starship desinstalado"
                ;;
            ohmyzsh)
                rm -rf ~/.oh-my-zsh
                if [ -f ~/.zshrc.pre-oh-my-zsh ]; then
                    mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
                fi
                log_success "Oh My Zsh desinstalado"
                ;;
            extensions)
                if command -v gnome-extensions &>/dev/null; then
                    gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null
                    gnome-extensions disable gsconnect@andyholmes.github.io 2>/dev/null
                    gnome-extensions disable dash-to-dock@micxios.gmail.com 2>/dev/null
                fi
                log_success "Extensiones deshabilitadas"
                ;;
            themes)
                gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null
                gsettings reset org.gnome.shell.extensions.user-theme name 2>/dev/null
                rm -rf ~/.themes/* ~/.local/share/themes/*
                log_success "Temas GNOME restaurados"
                ;;
            icons)
                gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null
                rm -rf ~/.icons/* ~/.local/share/icons/*
                log_success "Iconos restaurados"
                ;;
            opencode)
                sudo dnf remove -y opencode 2>/dev/null || sudo snap remove opencode 2>/dev/null
                rm -rf ~/.config/opencode
                log_success "OpenCode desinstalado"
                ;;
        esac
    done
    
    whiptail --title "Desinstalación Completa" --msgbox "Componentes desinstalados correctamente." 8 50
}

main "$@"
