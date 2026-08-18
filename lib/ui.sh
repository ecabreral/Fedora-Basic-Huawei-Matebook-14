#!/usr/bin/env bash

component_badge() {
    if component_status "$1"; then echo "[INSTALADO]"; else echo "[NO INSTALADO]"; fi
}

show_preflight() {
    whiptail --title "Diagnóstico inicial" --msgbox "$(preflight_text)" "$UI_HEIGHT" "$UI_WIDTH" \
        3>&1 1>&2 2>&3
}

show_main_menu() {
    whiptail --title "$UI_TITLE | Huawei MateBook 14" \
        --menu "Selecciona una opción (Esc cancela):" "$UI_HEIGHT" "$UI_WIDTH" 6 \
        "1" "Instalar todos los componentes" \
        "2" "Seleccionar componentes específicos" \
        "3" "Cambiar tema de terminal" \
        "4" "Desinstalar terminal alternativa (Kitty/Alacritty)" \
        "d" "Ver diagnóstico del entorno" \
        "5" "Salir" \
        3>&1 1>&2 2>&3
}

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
    local result
    result=$(whiptail --title "$title" --checklist "$prompt" "$height" "$UI_WIDTH" "$n" "${args[@]}" \
        3>&1 1>&2 2>&3)
    local output="" selected
    for selected in $result; do
        selected="${selected//\"/}"
        if [[ "$selected" =~ ^[0-9]+$ ]] && [ -n "${tags[selected-1]:-}" ]; then
            output+=" ${tags[selected-1]}"
        fi
    done
    printf '%s\n' "$output" | xargs
}

_component_tags() {
    case "$1" in
        sistema) echo "base" ;;
        terminal) echo "terminal" ;;
        dev) echo "vscode git gh opencode" ;;
        browsers) echo "brave chrome" ;;
        multimedia) echo "spotify" ;;
        desktop) echo "theme extensions icons" ;;
        hardware) echo "intel" ;;
    esac
}

_component_items() {
    case "$1" in
        sistema) echo "base|Sistema Base (Repositorios, Códecs, VA-API, Flatpak)" ;;
        terminal) echo "terminal|Terminal (Ptyxis, zsh, Starship, eza...)" ;;
        dev) echo "vscode|Visual Studio Code + Extensiones"; echo "git|Git + Clave SSH para GitHub"; echo "gh|GitHub CLI (gh)"; echo "opencode|OpenCode CLI (Asistente IA)" ;;
        browsers) echo "brave|Brave Browser + alias bravefix"; echo "chrome|Google Chrome" ;;
        multimedia) echo "spotify|Spotify (Cliente de música)" ;;
        desktop) echo "theme|Temas GNOME estilo macOS"; echo "extensions|Extensiones GNOME"; echo "icons|Iconos GNOME (WhiteSur, Papirus...)" ;;
        hardware) echo "intel|Corrección de parpadeo Intel" ;;
    esac
}

_component_title() {
    case "$1" in
        sistema) echo "Sistema" ;; terminal) echo "Terminal" ;; dev) echo "Desarrollo" ;;
        browsers) echo "Navegadores" ;; multimedia) echo "Multimedia" ;;
        desktop) echo "Escritorio GNOME" ;; hardware) echo "Hardware" ;;
    esac
}

_selected_has() { printf '%s\n' " $SELECTED " | grep -q " $1 "; }

_strip_category() {
    local category="$1" item category_item keep output=""
    for item in $SELECTED; do
        keep=1
        for category_item in $(_component_tags "$category"); do
            [ "$item" = "$category_item" ] && keep=0 && break
        done
        [ "$keep" -eq 1 ] && output+=" $item"
    done
    SELECTED="$output"
}

_show_selected_msg() {
    local msg="Componentes seleccionados actualmente:\n\n" any=0 component
    for component in $SELECTED; do
        any=1
        msg+="  - $(component_label "$component") $(component_badge "$component")\n"
    done
    [ "$any" -eq 0 ] && msg+="  (ninguno)"
    whiptail --title "Selección actual" --msgbox "$msg" "$UI_HEIGHT" "$UI_WIDTH" \
        3>&1 1>&2 2>&3
}

run_checklist_dyn() {
    local title="$1" prompt="$2" height="$3" category="$4"
    local -a tags=() args=()
    local item n=0
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        n=$((n + 1))
        local tag="${item%%|*}" desc="${item#*|}" def=OFF
        _selected_has "$tag" && def=ON
        args+=("$n" "$desc $(component_badge "$tag")" "$def")
        tags+=("$tag")
    done < <(_component_items "$category")
    local result
    result=$(whiptail --title "$title" --checklist "$prompt" "$height" 60 "$n" "${args[@]}" \
        3>&1 1>&2 2>&3)
    local output="" selected
    for selected in $result; do
        selected="${selected//\"/}"
        if [[ "$selected" =~ ^[0-9]+$ ]] && [ -n "${tags[selected-1]:-}" ]; then
            output+=" ${tags[selected-1]}"
        fi
    done
    printf '%s\n' "$output" | xargs
}

show_component_menu() {
    local SELECTED=""
    while true; do
        local count category_choice
        count=$(printf '%s\n' "$SELECTED" | wc -w | tr -d ' ')
        category_choice=$(whiptail --title "Selecciona componentes (${count} seleccionados)" \
            --menu "Elige una categoría para agregar o quitar componentes:" "$UI_HEIGHT" "$UI_WIDTH" 10 \
            "1" "Sistema" "2" "Terminal" "3" "Desarrollo" "4" "Navegadores" \
            "5" "Multimedia" "6" "Escritorio GNOME" "7" "Hardware" \
            "8" "Seleccionar todos" "9" "Continuar con la instalación" "0" "Ver selección actual" "c" "Limpiar selección" \
            3>&1 1>&2 2>&3)
        case "$category_choice" in
            1|2|3|4|5|6|7)
                local category result
                case "$category_choice" in 1) category=sistema ;; 2) category=terminal ;; 3) category=dev ;; 4) category=browsers ;; 5) category=multimedia ;; 6) category=desktop ;; 7) category=hardware ;; esac
                result=$(run_checklist_dyn "$(_component_title "$category")" "Marca los componentes de $(_component_title "$category") a instalar:" 14 "$category")
                _strip_category "$category"
                [ -n "$result" ] && SELECTED="$SELECTED $result"
                SELECTED=$(printf '%s\n' "$SELECTED" | xargs)
                ;;
            8) SELECTED="$(all_components)"; whiptail --title "Selección completa" --msgbox "Todos los componentes han sido seleccionados." 8 50 3>&1 1>&2 2>&3 ;;
            c) SELECTED=""; whiptail --title "Selección limpiada" --msgbox "Se quitaron todos los componentes seleccionados." 8 50 3>&1 1>&2 2>&3 ;;
            0) _show_selected_msg ;;
            9)
                if [ -n "$(printf '%s\n' "$SELECTED" | xargs)" ]; then printf '%s\n' "$SELECTED" | xargs; return 0; fi
                whiptail --title "Sin componentes" --msgbox "No seleccionaste ningún componente." 8 50 3>&1 1>&2 2>&3
                ;;
            *) return 1 ;;
        esac
    done
}

show_theme_menu() { show_theme_selector; }
show_uninstall_menu() {
    run_checklist "Desinstalar terminales alternativas" "Selecciona las terminales a desinstalar:" 15 \
        "kitty|Kitty Terminal|OFF" "alacritty|Alacritty Terminal|OFF"
}

show_confirm_dialog() {
    local components="$1" theme="$2" msg="Componentes seleccionados:\n\n" component
    for component in $components; do msg+="  - $(component_label "$component") $(component_badge "$component")\n"; done
    [ -n "$theme" ] && msg+="\nTema: $theme"
    if printf '%s\n' "$components" | grep -Eq '(^| )(base|intel|theme|extensions|icons)( |$)'; then
        msg+="\n\nCambios especiales:\n"
        printf '%s\n' "$components" | grep -qw base && msg+="  - Repositorios y paquetes del sistema\n"
        printf '%s\n' "$components" | grep -qw intel && msg+="  - Parámetros de kernel; requiere reinicio\n"
        printf '%s\n' "$components" | grep -Eq '(^| )(theme|extensions|icons)( |$)' && msg+="  - Configuración de GNOME; puede requerir cerrar sesión\n"
    fi
    msg+="\n\n¿Continuar con la instalación?"
    whiptail --title "Confirmar instalación" --yesno "$msg" "$UI_HEIGHT" "$UI_WIDTH"
}
