#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instalador con whiptail para Fedora/Ubuntu en Matebook 14
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_LIGHT_MODE=false
if command -v gsettings >/dev/null 2>&1 && \
   gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | grep -q "prefer-light"; then
    INSTALL_LIGHT_MODE=true
elif [[ "${COLORFGBG:-}" == *";15" || "${COLORFGBG:-}" == *";7" ]]; then
    INSTALL_LIGHT_MODE=true
fi
export INSTALL_LIGHT_MODE
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/cli.sh"

# Paleta sobria inspirada en las herramientas de instalación de Fedora.
if [ "$INSTALL_LIGHT_MODE" = true ]; then
    export NEWT_COLORS='root=black,white border=black,white window=black,white shadow=black,black title=black,white button=white,blue actbutton=white,blue checkbox=black,white actcheckbox=white,blue entry=black,white label=black,white listbox=black,white actlistbox=white,blue textbox=black,white'
else
    export NEWT_COLORS='root=white,blue border=white,blue window=white,blue shadow=black,black title=white,blue button=black,cyan actbutton=white,cyan checkbox=white,blue actcheckbox=black,cyan entry=white,blue label=white,blue listbox=white,blue actlistbox=black,cyan textbox=white,blue'
fi

# ── Flags de línea de comandos ───────────────────────────────────────────────
DRY_RUN=false
UNINSTALL_MODE=false
CLI_COMPONENTS=""
CLI_THEME=""

# Tamaños conservadores para que la interfaz funcione también por SSH.
UI_LINES=$(tput lines 2>/dev/null || echo 24)
UI_COLS=$(tput cols 2>/dev/null || echo 80)
UI_HEIGHT=$((UI_LINES > 28 ? 24 : UI_LINES - 3))
UI_WIDTH=$((UI_COLS > 100 ? 92 : UI_COLS - 4))
[ "$UI_HEIGHT" -lt 16 ] && UI_HEIGHT=16
[ "$UI_WIDTH" -lt 60 ] && UI_WIDTH=60
UI_TITLE="Fedora System Setup"
is_ubuntu && UI_TITLE="Linux System Setup"

parse_args "$@" || exit 1

preflight_text() {
    local sudo_state="NO" internet_state="NO" session_state="NO" text=""
    command -v sudo >/dev/null 2>&1 && sudo_state="SI"
    command -v curl >/dev/null 2>&1 && curl -fsS --max-time 3 https://mirrors.fedoraproject.org >/dev/null 2>&1 && internet_state="SI"
    [ -n "${XDG_CURRENT_DESKTOP:-}" ] && session_state="SI"
    text="Diagnóstico del entorno\\n\\n"
    text+="Sistema: $OS_NAME $OS_VERSION ($OS_ID)\\n"
    text+="Arquitectura: $(uname -m)\\n"
    text+="Terminal: ${TERM:-desconocida}\\n"
    text+="Sesión gráfica: $session_state\\n"
    text+="Internet: $internet_state\\n"
    text+="Permisos sudo: $sudo_state\\n"
    text+="Interfaz: ${UI_WIDTH}x${UI_HEIGHT}\\n"
    text+="Contraste: $([ "$INSTALL_LIGHT_MODE" = true ] && echo "claro" || echo "oscuro")\\n\\n"
    if [ "$sudo_state" = "NO" ] || [ "$internet_state" = "NO" ]; then
        text+="Advertencias\\n"
        [ "$sudo_state" = "NO" ] && text+="- No se encontró sudo; la instalación fallará en componentes del sistema.\\n"
        [ "$internet_state" = "NO" ] && text+="- No se pudo verificar Internet; los repositorios podrían no responder.\\n"
    else
        text+="Entorno listo para continuar.\\n"
    fi
    printf '%s' "$text"
}

CLI_COMPONENTS=$(printf '%s' "$CLI_COMPONENTS" | xargs)
validate_selection "$CLI_COMPONENTS" || exit 1
validate_theme "$CLI_THEME" || exit 1

# ── Verificar whiptail ────────────────────────────────────────────────────────
if [ -z "$CLI_COMPONENTS" ] && [ "$DRY_RUN" = false ] && ! command -v whiptail &>/dev/null; then
    if ! command -v sudo &>/dev/null; then
        error "No se encontró sudo para instalar whiptail."
        exit 1
    fi
    echo "whiptail no está instalado. Instalando..."
    if is_fedora; then
        sudo dnf install -y newt
    elif is_ubuntu; then
        sudo apt install -y whiptail
    fi
fi

if [ -z "$CLI_COMPONENTS" ] && [ "$DRY_RUN" = false ] && ! command -v whiptail &>/dev/null; then
    error "No se pudo instalar whiptail. Ejecuta el modo CLI o instala whiptail manualmente."
    exit 1
fi

# ── Menú principal con whiptail ────────────────────────────────────────────────
show_main_menu() {
    local choice
    choice=$(whiptail --title "$UI_TITLE | Huawei MateBook 14" \
        --menu "Selecciona una opción (Esc cancela):" "$UI_HEIGHT" "$UI_WIDTH" 6 \
        "1" "Instalar todos los componentes" \
        "2" "Seleccionar componentes específicos" \
        "3" "Cambiar tema de terminal" \
        "4" "Desinstalar terminal alternativa (Kitty/Alacritty)" \
        "d" "Ver diagnóstico del entorno" \
        "5" "Salir" \
        3>&1 1>&2 2>&3)
    echo "$choice"
}

# ── Helper: checklist whiptail con opciones numeradas ─────────────────────────
# Uso: run_checklist <titulo> <prompt> <alto> "tag|descripcion|ON/OFF" ...
# Devuelve los tags seleccionados (descodificados de sus números)
run_checklist() {
    local title="$1" prompt="$2" height="$3"
    shift 3

    local -a tags=() args=()
    local item n=0
    for item in "$@"; do
        n=$((n + 1))
        local tag="${item%%|*}" rest="${item#*|}"
        local desc="${rest%%|*}" def="${rest#*|}"
        args+=("$n" "$desc" "$def")
        tags+=("$tag")
    done

    local r
    r=$(whiptail --title "$title" --checklist "$prompt" "$height" "$UI_WIDTH" "$n" "${args[@]}" \
        3>&1 1>&2 2>&3)

    local out="" sel
    for sel in $r; do
        sel="${sel//\"/}"
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ -n "${tags[sel-1]:-}" ]; then
            out+=" ${tags[sel-1]}"
        fi
    done
    echo "$out" | xargs
}

# ── Helpers de selección de componentes ───────────────────────────────────────
_component_tags() {
    case "$1" in
        sistema)     echo "base" ;;
        terminal)    echo "terminal" ;;
        dev)         echo "vscode git gh opencode" ;;
        browsers)    echo "brave chrome" ;;
        multimedia)  echo "spotify" ;;
        desktop)     echo "theme extensions icons" ;;
        hardware)    echo "intel" ;;
    esac
}

_component_items() {
    case "$1" in
        sistema)     echo "base|Sistema Base (Repositorios, Códecs, VA-API, Flatpak)" ;;
        terminal)    echo "terminal|Terminal (Ptyxis, zsh, Starship, eza...)" ;;
        dev)         echo "vscode|Visual Studio Code + Extensiones"
                     echo "git|Git + Clave SSH para GitHub"
                     echo "gh|GitHub CLI (gh)"
                     echo "opencode|OpenCode CLI (Asistente IA)" ;;
        browsers)    echo "brave|Brave Browser + alias bravefix"
                     echo "chrome|Google Chrome" ;;
        multimedia)  echo "spotify|Spotify (Cliente de música)" ;;
        desktop)     echo "theme|Temas GNOME estilo macOS"
                     echo "extensions|Extensiones GNOME"
                     echo "icons|Iconos GNOME (WhiteSur, Papirus...)" ;;
        hardware)    echo "intel|Corrección de parpadeo Intel" ;;
    esac
}

_component_title() {
    case "$1" in
        sistema)     echo "Sistema" ;;
        terminal)    echo "Terminal" ;;
        dev)         echo "Desarrollo" ;;
        browsers)    echo "Navegadores" ;;
        multimedia)  echo "Multimedia" ;;
        desktop)     echo "Escritorio GNOME" ;;
        hardware)    echo "Hardware" ;;
    esac
}

_selected_has() {
    echo " $SELECTED " | grep -q " $1 "
}

_strip_category() {
    local cat="$1" t ct keep out=""
    for t in $SELECTED; do
        keep=1
        for ct in $(_component_tags "$cat"); do
            [ "$t" = "$ct" ] && keep=0 && break
        done
        [ "$keep" -eq 1 ] && out+=" $t"
    done
    SELECTED="$out"
}

_show_selected_msg() {
    local msg="Componentes seleccionados actualmente:\\n\\n" any=0
    for comp in $SELECTED; do
        any=1
        msg+="  • $(component_label "$comp") $(component_badge "$comp")\\n"
    done
    [ "$any" -eq 0 ] && msg+="  (ninguno)"
    # Este menú se ejecuta dentro de $(show_component_menu). Mantener la UI en
    # stderr evita que whiptail contamine el valor capturado por stdout.
    whiptail --title "Selección actual" --msgbox "$msg" "$UI_HEIGHT" "$UI_WIDTH" \
        3>&1 1>&2 2>&3
}

# Checklist con defaults dinámicos según SELECTED (permite toggle real)
run_checklist_dyn() {
    local title="$1" prompt="$2" height="$3" cat="$4"
    local -a tags=() args=()
    local item n=0
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        n=$((n + 1))
        local tag="${item%%|*}" desc="${item#*|}"
        local def="OFF"
        _selected_has "$tag" && def="ON"
        desc="$desc $(component_badge "$tag")"
        args+=("$n" "$desc" "$def")
        tags+=("$tag")
    done < <(_component_items "$cat")

    local r
    r=$(whiptail --title "$title" --checklist "$prompt" "$height" 60 "$n" "${args[@]}" \
        3>&1 1>&2 2>&3)

    local out="" sel
    for sel in $r; do
        sel="${sel//\"/}"
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ -n "${tags[sel-1]:-}" ]; then
            out+=" ${tags[sel-1]}"
        fi
    done
    echo "$out" | xargs
}

# ── Menú de componentes por categoría ────────────────────────────────────────
show_component_menu() {
    local SELECTED=""

    while true; do
        local count
        count=$(echo "$SELECTED" | wc -w | tr -d ' ')
        local cat_choice
        cat_choice=$(whiptail --title "Selecciona componentes (${count} seleccionados)" \
            --menu "Elige una categoría para agregar o quitar componentes:" "$UI_HEIGHT" "$UI_WIDTH" 10 \
            "1" "Sistema" \
            "2" "Terminal" \
            "3" "Desarrollo" \
            "4" "Navegadores" \
            "5" "Multimedia" \
            "6" "Escritorio GNOME" \
            "7" "Hardware" \
            "8" "Seleccionar todos" \
            "9" "Continuar con la instalación" \
            "0" "Ver selección actual" \
            "c" "Limpiar selección" \
            3>&1 1>&2 2>&3)

        case "$cat_choice" in
            1|2|3|4|5|6|7)
                local cat r
                case "$cat_choice" in
                    1) cat=sistema ;;
                    2) cat=terminal ;;
                    3) cat=dev ;;
                    4) cat=browsers ;;
                    5) cat=multimedia ;;
                    6) cat=desktop ;;
                    7) cat=hardware ;;
                esac
                r=$(run_checklist_dyn "$(_component_title "$cat")" \
                    "Marca los componentes de $(_component_title "$cat") a instalar:" 14 "$cat")
                _strip_category "$cat"
                if [ -n "$r" ]; then
                    SELECTED="$SELECTED $r"
                fi
                SELECTED=$(echo "$SELECTED" | xargs)
                ;;
            8) # Seleccionar todos
                SELECTED="base terminal vscode git gh theme extensions icons intel brave spotify opencode chrome"
                whiptail --title "Selección completa" --msgbox "Todos los componentes han sido seleccionados." 8 50 \
                    3>&1 1>&2 2>&3
                ;;
            c) # Limpiar selección
                SELECTED=""
                whiptail --title "Selección limpiada" --msgbox "Se quitaron todos los componentes seleccionados." 8 50 \
                    3>&1 1>&2 2>&3
                ;;
            0) # Ver selección actual
                _show_selected_msg
                ;;
            9) # Continuar
                if [ -z "$(echo "$SELECTED" | xargs)" ]; then
                    whiptail --title "Sin componentes" --msgbox "No seleccionaste ningún componente." 8 50 \
                        3>&1 1>&2 2>&3
                else
                    echo "$SELECTED" | xargs
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
    run_checklist "Desinstalar terminales alternativas" \
        "Selecciona las terminales a desinstalar:" 15 \
        "kitty|Kitty Terminal|OFF" \
        "alacritty|Alacritty Terminal|OFF"
}

# ── Confirmación de instalación ───────────────────────────────────────────────
show_confirm_dialog() {
    local components="$1"
    local theme="$2"
    
    local msg="Componentes seleccionados:\\n"
    msg+="\\n"
    
    for comp in $components; do
        msg+="  • $(component_label "$comp") $(component_badge "$comp")\\n"
    done
    
    if [ -n "$theme" ]; then
        msg+="\\nTema: $theme"
    fi

    if echo "$components" | grep -Eq '(^| )(base|intel|theme|extensions|icons)( |$)'; then
        msg+="\\n\\nCambios especiales:\\n"
        echo "$components" | grep -qw base && msg+="  • Repositorios y paquetes del sistema\\n"
        echo "$components" | grep -qw intel && msg+="  • Parámetros de kernel; requiere reinicio\\n"
        echo "$components" | grep -Eq '(^| )(theme|extensions|icons)( |$)' && msg+="  • Configuración de GNOME; puede requerir cerrar sesión\\n"
    fi
    
    msg+="\\n\\n¿Continuar con la instalación?"
    
    whiptail --title "Confirmar instalación" --yesno "$msg" "$UI_HEIGHT" "$UI_WIDTH"
}

# La interfaz vive en lib/ui.sh. Se recarga aquí para que el coordinador no
# dependa de implementaciones locales heredadas durante la migración.
source "$SCRIPT_DIR/lib/ui.sh"

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    # Verificar SO
    if ! is_fedora && ! is_ubuntu; then
        if command -v whiptail &>/dev/null; then
            whiptail --title "Error" --msgbox "Sistema operativo no soportado: $OS_ID\\nEste instalador funciona en Fedora o Ubuntu." 10 50
        else
            error "Sistema operativo no soportado: $OS_ID. Este instalador funciona en Fedora o Ubuntu."
        fi
        exit 1
    fi
    
    # Modo CLI (sin whiptail)
    if [ -n "$CLI_COMPONENTS" ]; then
        local SELECTED
        SELECTED=$(echo "$CLI_COMPONENTS" | xargs)
        local THEME="$CLI_THEME"
        
        if [ "$DRY_RUN" = true ]; then
            info "[DRY RUN] Plan de instalación:"
            bash "$SCRIPT_DIR/scripts/runner.sh" --dry-run $SELECTED
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

    show_preflight
    
    while true; do
        local main_choice
        main_choice=$(show_main_menu)
        
        case "$main_choice" in
            1)
                # Instalar todos
                local SELECTED="base terminal vscode git gh theme extensions icons intel brave spotify opencode chrome"
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
                local SELECTED
                SELECTED=$(show_component_menu)
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
                if bash "$SCRIPT_DIR/scripts/02-terminal/02-change-theme.sh"; then
                    whiptail --title "Listo" --msgbox "Tema actualizado correctamente." 8 50
                fi
                ;;
            d)
                show_preflight
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
    local script
    shopt -s nullglob globstar
    for script in "$SCRIPT_DIR"/scripts/**/*.sh; do
        chmod +x "$script" 2>/dev/null || true
    done
    local -a selected_args=()
    read -r -a selected_args <<< "$SELECTED"
    if [ "${#selected_args[@]}" -eq 0 ]; then
        error "No hay componentes seleccionados."
        return 1
    fi

    if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
        if [ -n "$TERMINAL_THEME" ]; then
            run_as_user env TERMINAL_THEME="$TERMINAL_THEME" bash "$SCRIPT_DIR/scripts/runner.sh" "${selected_args[@]}"
        else
            run_as_user bash "$SCRIPT_DIR/scripts/runner.sh" "${selected_args[@]}"
        fi
    elif [ -n "$TERMINAL_THEME" ]; then
        TERMINAL_THEME="$TERMINAL_THEME" bash "$SCRIPT_DIR/scripts/runner.sh" "${selected_args[@]}"
    else
        bash "$SCRIPT_DIR/scripts/runner.sh" "${selected_args[@]}"
    fi
}

# ── Ejecutar desinstalación ───────────────────────────────────────────────────
run_uninstall() {
    local apps="$1"
    
    for app in $apps; do
        case "$app" in
            kitty)
                if command -v kitty &>/dev/null; then
                    platform_remove_packages kitty
                    rm -rf "$(user_path .config/kitty)"
                    log_success "Kitty desinstalado"
                fi
                ;;
            alacritty)
                if command -v alacritty &>/dev/null; then
                    platform_remove_packages alacritty
                    rm -rf "$(user_path .config/alacritty)"
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
    local COMPONENTS
    COMPONENTS=$(run_checklist "Desinstalar Componentes" \
        "Selecciona los componentes a desinstalar:" 18 \
        "vscode|Visual Studio Code|OFF" \
        "gh|GitHub CLI|OFF" \
        "brave|Brave Browser|OFF" \
        "chrome|Google Chrome|OFF" \
        "spotify|Spotify|OFF" \
        "starship|Starship Prompt|OFF" \
        "ohmyzsh|Oh My Zsh|OFF" \
        "extensions|Extensiones GNOME|OFF" \
        "themes|Temas GNOME|OFF" \
        "icons|Iconos|OFF" \
        "opencode|OpenCode CLI|OFF")

    if [ -z "$COMPONENTS" ]; then
        return 0
    fi

    for comp in $COMPONENTS; do
        case "$comp" in
            vscode)
                platform_remove_packages code 2>/dev/null || true
                rm -rf "$(user_path .config/Code)" "$(user_path .vscode)"
                log_success "VS Code desinstalado"
                ;;
            gh)
                platform_remove_packages gh
                log_success "GitHub CLI desinstalado"
                ;;
            brave)
                platform_remove_packages brave-browser 2>/dev/null || true
                rm -rf "$(user_path .config/BraveSoftware)"
                log_success "Brave desinstalado"
                ;;
            chrome)
                platform_remove_packages google-chrome-stable 2>/dev/null || true
                is_fedora && sudo dnf config-manager disable google-chrome 2>/dev/null || true
                rm -rf "$(user_path .config/google-chrome)"
                log_success "Google Chrome desinstalado"
                ;;
            spotify)
                flatpak uninstall -y --user com.spotify.Client 2>/dev/null || flatpak uninstall -y com.spotify.Client 2>/dev/null || true
                log_success "Spotify desinstalado"
                ;;
            starship)
                rm -f "$(user_path .local/bin/starship)"
                rm -f "$(user_path .config/starship.toml)"
                log_success "Starship desinstalado"
                ;;
            ohmyzsh)
                rm -rf "$(user_path .oh-my-zsh)"
                if [ -f "$(user_path .zshrc.pre-oh-my-zsh)" ]; then
                    mv "$(user_path .zshrc.pre-oh-my-zsh)" "$(user_path .zshrc)"
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
                log_success "Temas GNOME restaurados; no se borraron archivos personales"
                ;;
            icons)
                gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null
                log_success "Iconos restaurados; no se borraron archivos personales"
                ;;
            opencode)
                rm -f "$(user_path .opencode/bin/opencode)"
                rm -rf "$(user_path .config/opencode)"
                log_success "OpenCode desinstalado"
                ;;
        esac
    done
    
    whiptail --title "Desinstalación Completa" --msgbox "Componentes desinstalados correctamente." 8 50
}

main "$@"
