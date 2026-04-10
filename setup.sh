#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instalador en CONSOLA para Fedora 44 en Matebook 14
# ==============================================================================

set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

print_banner() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     Fedora 44 Setup - Huawei Matebook 14                     ║"
    echo "║     Configuración automatizada en terminal                   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

show_component_menu_simple() {
    local -A selected
    selected[base]=false
    selected[terminal]=false
    selected[vscode]=false
    selected[git]=false
    selected[theme]=false
    selected[intel]=false
    selected[extensions]=false
    selected[opencode]=false
    
    while true; do
        echo "" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "  SELECCIONA LOS COMPONENTES A INSTALAR" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "" >&2
        
        echo "  [0] Sistema Base (Repositorios, Códecs, VA-API, Flatpak) $([ "${selected[base]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [1] Terminal Moderna (zsh, Starship, eza, bat, fzf...)   $([ "${selected[terminal]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [2] Visual Studio Code + Extensiones                      $([ "${selected[vscode]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [3] Git + Clave SSH para GitHub                           $([ "${selected[git]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [4] Temas macOS (GTK, Iconos, GDM, Firefox)              $([ "${selected[theme]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [5] Fix Intel Screen Flicker                             $([ "${selected[intel]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [6] Extensiones GNOME                                    $([ "${selected[extensions]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [7] OpenCode CLI (Asistente IA)                         $([ "${selected[opencode]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "" >&2
        echo "  [A] Continuar con la instalación" >&2
        echo "  [Q] Cancelar y salir" >&2
        echo "" >&2
        read -p "  Opción (número para togglear, A para continuar): " input
        
        case "$input" in
            0)   selected[base]=$([ "${selected[base]}" = true ] && echo false || echo true) ;;
            1)   selected[terminal]=$([ "${selected[terminal]}" = true ] && echo false || echo true) ;;
            2)   selected[vscode]=$([ "${selected[vscode]}" = true ] && echo false || echo true) ;;
            3)   selected[git]=$([ "${selected[git]}" = true ] && echo false || echo true) ;;
            4)   selected[theme]=$([ "${selected[theme]}" = true ] && echo false || echo true) ;;
            5)   selected[intel]=$([ "${selected[intel]}" = true ] && echo false || echo true) ;;
            6)   selected[extensions]=$([ "${selected[extensions]}" = true ] && echo false || echo true) ;;
            7)   selected[opencode]=$([ "${selected[opencode]}" = true ] && echo false || echo true) ;;
            a|A) break ;;
            q|Q) exit 0 ;;
            *)   echo "  ⚠ Opción inválida. Usa 0-7, A o Q" >&2 ;;
        esac
    done
    
    local result=""
    for key in base terminal vscode git theme intel extensions opencode; do
        if [ "${selected[$key]}" = true ]; then
            result="$result $key"
        fi
    done
    echo "$result"
}

show_starship_menu_simple() {
    local theme=""
    while true; do
        echo "" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "  SELECCIONA EL TEMA DE STARSHIP" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "" >&2
        echo "  [1] 🌙 Tokyo Night (oscuro, recomendado)" >&2
        echo "  [2] 🎨 Pastel Powerline (claro)" >&2
        echo "  [3] 🟤 Gruvbox Rainbow (oscuro)" >&2
        echo "  [4] 🟣 Catppuccin Powerline (oscuro)" >&2
        echo "  [5] 🚀 Jetpack (minimalista)" >&2
        echo "  [6] ⚡ Pure Prompt (clásico)" >&2
        echo "" >&2
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
            SELECTED="base terminal vscode git theme intel extensions opencode"
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