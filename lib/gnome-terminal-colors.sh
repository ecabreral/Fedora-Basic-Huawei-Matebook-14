#!/bin/bash
# ==============================================================================
# gnome-terminal-colors.sh
# Definiciones de colores para GNOME Terminal via dconf.
# Compartido por 01-terminal-setup.sh y 02-change-theme.sh
# ==============================================================================

# Función para obtener los colores de GNOME Terminal según el tema
get_gnome_terminal_colors() {
    case "$THEME" in
        tokyo-night)
            echo "palette=['#32344a','#f7768e','#9ece6a','#e0af68','#7aa2f7','#ad8ee6','#449dab','#787c99','#444b6a','#ff7a93','#b9f27c','#ff9e64','#7da6ff','#bb9af7','#0db9d7','#acb0d0']"
            echo "foreground_color='#a9b1d6'"
            echo "background_color='#1a1b26'"
            echo "bold_color='#a9b1d6'"
            echo "bold_color_same_as_fg=true"
            ;;
        pastel-powerline)
            echo "palette=['#575279','#b4637a','#286983','#ea9d34','#56949f','#907aa9','#ea9d34','#faf4ed','#9893a5','#b4637a','#286983','#ea9d34','#56949f','#907aa9','#ea9d34','#575279']"
            echo "foreground_color='#575279'"
            echo "background_color='#faf4ed'"
            echo "bold_color='#575279'"
            echo "bold_color_same_as_fg=true"
            ;;
        gruvbox-rainbow)
            echo "palette=['#3c3836','#cc241d','#98971a','#d79921','#458588','#b16286','#689d6a','#a89984','#928374','#fb4934','#b8bb26','#fabd2f','#83a598','#d3869b','#8ec07c','#ebdbb2']"
            echo "foreground_color='#ebdbb2'"
            echo "background_color='#282828'"
            echo "bold_color='#ebdbb2'"
            echo "bold_color_same_as_fg=true"
            ;;
        catppuccin-powerline)
            echo "palette=['#45475a','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#bac2de','#585b70','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#a6adc8']"
            echo "foreground_color='#cdd6f4'"
            echo "background_color='#1e1e2e'"
            echo "bold_color='#f5e0dc'"
            echo "bold_color_same_as_fg=false"
            ;;
        *)
            # Gruvbox Rainbow (default)
            echo "palette=['#3c3836','#cc241d','#98971a','#d79921','#458588','#b16286','#689d6a','#a89984','#928374','#fb4934','#b8bb26','#fabd2f','#83a598','#d3869b','#8ec07c','#ebdbb2']"
            echo "foreground_color='#ebdbb2'"
            echo "background_color='#282828'"
            echo "bold_color='#ebdbb2'"
            echo "bold_color_same_as_fg=true"
            ;;
    esac
}

# Función para aplicar colores al perfil de GNOME Terminal
apply_gnome_terminal_theme() {
    local profile_path="$1"

    # Leer colores del tema sin eval (seguro)
    local palette="" foreground_color="" background_color="" bold_color="" bold_color_same_as_fg=""
    while IFS='=' read -r key value; do
        case "$key" in
            palette) palette="$value" ;;
            foreground_color) foreground_color="$value" ;;
            background_color) background_color="$value" ;;
            bold_color) bold_color="$value" ;;
            bold_color_same_as_fg) bold_color_same_as_fg="$value" ;;
        esac
    done < <(get_gnome_terminal_colors)

    # Aplicar via dconf
    dconf write "${profile_path}/palette" "$palette"
    dconf write "${profile_path}/foreground-color" "$foreground_color"
    dconf write "${profile_path}/background-color" "$background_color"
    dconf write "${profile_path}/bold-color" "$bold_color"
    dconf write "${profile_path}/bold-color-same-as-fg" "$bold_color_same_as_fg"
    dconf write "${profile_path}/use-theme-colors" "false"
    dconf write "${profile_path}/visible-name" "'$THEME'"

    # Configurar fuente Nerd Font
    install_nerd_font
    dconf write "${profile_path}/use-system-font" "false"
    dconf write "${profile_path}/font" "'JetBrainsMono Nerd Font 11'"
}

# Función para obtener el perfil por defecto de GNOME Terminal
get_default_profile() {
    # Usar gsettings para obtener el UUID del perfil por defecto (más confiable)
    local default_uuid
    default_uuid=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")

    if [ -n "$default_uuid" ] && [ "$default_uuid" != "" ]; then
        echo "$default_uuid"
        return
    fi

    # Fallback: obtener el primer perfil de la lista
    local first_profile
    first_profile=$(gsettings get org.gnome.Terminal.ProfilesList list 2>/dev/null | grep -oP "^[^']*" | head -1 | tr -d "[]' ")

    if [ -n "$first_profile" ]; then
        echo "$first_profile"
        return
    fi

    echo ""
}
