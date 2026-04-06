#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instalador en CONSOLA para Fedora 43 en Matebook 14
# ==============================================================================

set +e

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
    for key in terminal vscode git theme intel extensions opencode; do
        if [ "${selected[$key]}" = true ]; then
            result="$result $key"
        fi
    done
    echo "$result"
}

show_starship_menu_simple() {
    local theme=""
    while true; do
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
            1)  theme="tokyo-night"; break ;;
            2)  theme="pastel-powerline"; break ;;
            3)  theme="gruvbox-rainbow"; break ;;
            4)  theme="catppuccin-powerline"; break ;;
            5)  theme="jetpack"; break ;;
            6)  theme="pure-preset"; break ;;
        esac
    done
    echo "$theme"
}

main() {
    print_banner
    
    echo "  [1] Instalar TODOS los componentes"
    echo "  [2] Seleccionar componentes específicos"
    echo "  [3] Salir"
    echo ""
    echo "  Escribe el número y presiona ENTER"
    echo ""
    read -p "Selecciona una opción [1-3]: " choice
    echo ""
    
    case "$choice" in
        1)
            SELECTED="terminal vscode git theme intel extensions opencode"
            ;;
        2)
            SELECTED=$(show_component_menu_simple)
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
    
    if echo "$SELECTED" | grep -qw "terminal"; then
        THEME=$(show_starship_menu_simple)
        if [ -n "$THEME" ]; then
            export TERMINAL_THEME="$THEME"
            info "Tema seleccionado: $TERMINAL_THEME"
        fi
    fi
    
    echo ""
    info "Componentes a instalar:$SELECTED"
    echo ""
    read -p "¿Continuar con la instalación? [s/N]: " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        info "Instalación cancelada."
        exit 0
    fi
    
    chmod +x "$SCRIPT_DIR"/scripts/*.sh
    
    info "Iniciando instalación..."
    echo ""
    
    if [ -n "$TERMINAL_THEME" ]; then
        TERMINAL_THEME="$TERMINAL_THEME" bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
    else
        bash "$SCRIPT_DIR/scripts/gui-launcher.sh" $SELECTED
    fi
}

main "$@"