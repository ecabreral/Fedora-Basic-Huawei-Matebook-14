#!/usr/bin/env bash

show_help() {
    echo "Uso: ./setup.sh [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --help              Muestra esta ayuda"
    echo "  --dry-run           Muestra qué haría sin ejecutar nada"
    echo "  --component <names> Instala uno o varios componentes separados por espacio"
    echo "  --theme <name>      Selecciona tema para terminal"
    echo "  --uninstall         Modo desinstalación interactiva"
    echo ""
    echo "Ejemplos:"
    echo "  ./setup.sh"
    echo "  ./setup.sh --component base terminal --theme tokyo-night"
    echo "  ./setup.sh --dry-run --component base terminal"
    echo "  ./setup.sh --uninstall"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h) show_help; exit 0 ;;
            --dry-run) DRY_RUN=true; shift ;;
            --component)
                if [ $# -lt 2 ] || [[ "$2" == -* ]]; then
                    error "--component requiere al menos un nombre."
                    return 1
                fi
                shift
                while [[ $# -gt 0 && "$1" != -* ]]; do
                    CLI_COMPONENTS+=" $1"
                    shift
                done
                ;;
            --theme)
                if [ $# -lt 2 ] || [[ -z "$2" || "$2" == -* ]]; then
                    error "--theme requiere un nombre."
                    return 1
                fi
                CLI_THEME="$2"
                shift 2
                ;;
            --uninstall) UNINSTALL_MODE=true; shift ;;
            *) error "Opción desconocida: $1"; show_help; return 1 ;;
        esac
    done
}

validate_selection() {
    local item
    for item in $1; do
        if ! component_exists "$item"; then
            error "Componente desconocido: $item"
            error "Usa --help para ver los componentes disponibles."
            return 1
        fi
    done
}

validate_theme() {
    local theme
    [ -z "$1" ] && return 0
    for theme in "${THEMES[@]}"; do
        [ "$1" = "$theme" ] && return 0
    done
    error "Tema desconocido: $1"
    error "Temas disponibles: ${THEMES[*]}"
    return 1
}
