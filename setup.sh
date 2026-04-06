#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instalador en CONSOLA para Fedora 43 en Matebook 14
# ==============================================================================

set +e  # No salir en errores

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

print_banner() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     Fedora 43 Setup - Huawei Matebook 14                     ║"
    echo "║     Configuración automatizada en terminal                   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

main() {
    print_banner
    
    # Detectar si hay dialog disponible
    if command -v dialog &>/dev/null && [ -t 1 ]; then
        USE_DIALOG=1
    else
        USE_DIALOG=0
    fi
    
    echo "  [1] Instalar TODOS los componentes"
    echo "  [2] Seleccionar componentes específicos"
    echo "  [3] Salir"
    echo ""
    echo "  Escribe el número y presiona ENTER"
    echo ""
    read -p "Selecciona una opción [1-3]: " choice
    echo ""
    
    case "$choice" in
        1)  # Todos los componentes
            SELECTED="terminal vscode git theme intel extensions opencode"
            ;;
        2)  # Seleccionar componentes específicos
            SELECTED=$(show_component_menu_simple)
            ;;
        3|*)
            info "Instalación cancelada."
            exit 0
            ;;
    esac
    
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo "$choice"
}

# ── Selección de Componentes ──────────────────────────────────────────────
show_component_menu() {
    local cmd=(dialog --backtitle "Fedora Setup" --title "Seleccionar Componentes" \
        --checklist "Marca los componentes a instalar:" 18 70 12)
    
    local options=(
        "terminal"  "Terminal Moderna (zsh, Starship, eza, bat, fzf...)" on
        "vscode"    "Visual Studio Code + Extensiones" on
        "git"       "Git + Clave SSH para GitHub" on
        "theme"     "Temas macOS (GTK, Iconos, GDM, Firefox)" on
        "intel"     "Fix Intel Screen Flicker" off
        "extensions" "Extensiones GNOME" on
        "opencode"  "OpenCode CLI (Asistente IA)" on
    )
    
    local selected=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo "$selected"
}

# ── Selector de Tema Starship ─────────────────────────────────────────────
show_starship_menu() {
    local cmd=(dialog --backtitle "Fedora Setup" --title "Tema de Starship" \
        --radiolist "Selecciona el tema para tu terminal:" 20 60 12)
    
    local options=(
        "tokyo-night"           "🌙 Tokyo Night (oscuro, recomendado)" on
        "pastel-powerline"      "🎨 Pastel Powerline (claro)" off
        "gruvbox-rainbow"       "🟤 Gruvbox Rainbow (oscuro)" off
        "catppuccin-powerline"  "🟣 Catppuccin Powerline (oscuro)" off
        "jetpack"               "🚀 Jetpack (minimalista)" off
        "pure-preset"           "⚡ Pure Prompt (clásico)" off
    )
    
    local theme=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo "$theme"
}

# ── Menú Alternativo (sin dialog) ─────────────────────────────────────────
show_menu_simple() {
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     Fedora 43 Setup - Huawei Matebook 14                     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  [1] Instalar TODOS los componentes"
    echo "  [2] Seleccionar componentes específicos"
    echo "  [3] Salir"
    echo ""
    echo "  Escribe el número y presiona ENTER"
    echo ""
    read -p "Selecciona una opción [1-3]: " choice
    echo ""
    echo "$choice"
}

show_component_menu_simple() {
    local -A selected
    selected[terminal]=false
    selected[vscode]=false
    selected[git]=false
    selected[theme]=false
    selected[intel]=false
    selected[extensions]=false
    selected[opencode]=false
    
    while true; do
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  SELECCIONA LOS COMPONENTES A INSTALAR"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        
        echo "  [1] Terminal Moderna (zsh, Starship, eza, bat, fzf...)   $([ "${selected[terminal]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo "  [2] Visual Studio Code + Extensiones                      $([ "${selected[vscode]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo "  [3] Git + Clave SSH para GitHub                           $([ "${selected[git]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo "  [4] Temas macOS (GTK, Iconos, GDM, Firefox)              $([ "${selected[theme]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo "  [5] Fix Intel Screen Flicker                             $([ "${selected[intel]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo "  [6] Extensiones GNOME                                    $([ "${selected[extensions]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo "  [7] OpenCode CLI (Asistente IA)                         $([ "${selected[opencode]}" = true ] && echo "[✓]" || echo "[ ]")"
        echo ""
        echo "  [A] Continuar con la instalación"
        echo "  [Q] Cancelar y salir"
        echo ""
        read -p "  Opción (número para togglear, A para continuar): " input
        
        case "$input" in
            1)   if [ "${selected[terminal]}" = true ]; then selected[terminal]=false; else selected[terminal]=true; fi ;;
            2)   if [ "${selected[vscode]}" = true ]; then selected[vscode]=false; else selected[vscode]=true; fi ;;
            3)   if [ "${selected[git]}" = true ]; then selected[git]=false; else selected[git]=true; fi ;;
            4)   if [ "${selected[theme]}" = true ]; then selected[theme]=false; else selected[theme]=true; fi ;;
            5)   if [ "${selected[intel]}" = true ]; then selected[intel]=false; else selected[intel]=true; fi ;;
            6)   if [ "${selected[extensions]}" = true ]; then selected[extensions]=false; else selected[extensions]=true; fi ;;
            7)   if [ "${selected[opencode]}" = true ]; then selected[opencode]=false; else selected[opencode]=true; fi ;;
            a|A) break ;;
            q|Q) exit 0 ;;
        esac
    done
    
    local result=""
    for key in "${!selected[@]}"; do
        if [ "${selected[$key]}" = true ]; then
            result="$result $key"
        fi
    done
    echo "$result"
}

show_starship_menu_simple() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  SELECCIONA EL TEMA DE STARSHIP"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "  [1] 🌙 Tokyo Night (oscuro, recomendado)"
    echo "  [2] 🎨 Pastel Powerline (claro)"
    echo "  [3] 🟤 Gruvbox Rainbow (oscuro)"
    echo "  [4] 🟣 Catppuccin Powerline (oscuro)"
    echo "  [5] 🚀 Jetpack (minimalista)"
    echo "  [6] ⚡ Pure Prompt (clásico)"
    echo ""
    read -p "Selecciona tema [1-6]: " choice
    
    case "$choice" in
        1) echo "tokyo-night" ;;
        2) echo "pastel-powerline" ;;
        3) echo "gruvbox-rainbow" ;;
        4) echo "catppuccin-powerline" ;;
        5) echo "jetpack" ;;
        6) echo "pure-preset" ;;
        *) echo "tokyo-night" ;;
    esac
}

# ── Main ───────────────────────────────────────────────────────────────────
main() {
    print_banner
    
    # Detectar si hay dialog disponible
    if command -v dialog &>/dev/null && [ -t 1 ]; then
        USE_DIALOG=1
    else
        USE_DIALOG=0
    fi
    
    # Menú principal
    if [ "$USE_DIALOG" -eq 1 ]; then
        choice=$(show_menu)
    else
        choice=$(show_menu_simple)
    fi
    
    case "$choice" in
        1)  # Todos los componentes
            SELECTED="terminal vscode git theme intel extensions opencode"
            ;;
        2)  # Seleccionar componentes
            if [ "$USE_DIALOG" -eq 1 ]; then
                SELECTED=$(show_component_menu)
            else
                SELECTED=$(show_component_menu_simple)
            fi
            ;;
        3|*)
            info "Instalación cancelada."
            exit 0
            ;;
    esac
    
    if [ -z "$SELECTED" ]; then
        info "No se seleccionaron componentes."
        exit 0
    fi
    
    # Si terminal está seleccionado, pedir tema
    if echo "$SELECTED" | grep -qw "terminal"; then
        if [ "$USE_DIALOG" -eq 1 ]; then
            THEME=$(show_starship_menu)
        else
            THEME=$(show_starship_menu_simple)
        fi
        
        if [ -n "$THEME" ]; then
            export TERMINAL_THEME="$THEME"
            info "Tema seleccionado: $TERMINAL_THEME"
        fi
    fi
    
    echo ""
    info "Componentes a instalar: $SELECTED"
    echo ""
    read -p "¿Continuar con la instalación? [s/N]: " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        info "Instalación cancelada."
        exit 0
    fi
    
    chmod +x "$SCRIPT_DIR"/scripts/*.sh
    
    # Ejecutar scripts
    info "Iniciando instalación..."
    echo ""
    
    if [ -n "$TERMINAL_THEME" ]; then
        TERMINAL_THEME="$TERMINAL_THEME" bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
    else
        bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
    fi
}

main "$@"