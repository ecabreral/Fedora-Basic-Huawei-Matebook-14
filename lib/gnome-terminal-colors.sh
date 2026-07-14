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
        jetpack)
            echo "palette=['#01060e','#ea6c73','#91b362','#f9af4f','#53bdfa','#fae994','#90e1c6','#c7c7c7','#686868','#f07178','#c2d94c','#ffb378','#69d0ff','#e6b450','#95e6cb','#ffffff']"
            echo "foreground_color='#b3b1ad'"
            echo "background_color='#0b0e14'"
            echo "bold_color='#b3b1ad'"
            echo "bold_color_same_as_fg=true"
            ;;
        pure-preset)
            echo "palette=['#323232','#ff6b6b','#98c379','#e5c07b','#61afef','#c678dd','#56b6c2','#dcdcdc','#505050','#ff8787','#aed9a0','#ffd98e','#8cc8ff','#d898ff','#7fdeff','#f1f1f1']"
            echo "foreground_color='#f1f1f1'"
            echo "background_color='#1d1d1d'"
            echo "bold_color='#f1f1f1'"
            echo "bold_color_same_as_fg=true"
            ;;
        cyberpunk-storm)
            echo "palette=['#0a0e14','#ff007f','#00ff41','#ffff00','#0080ff','#bf00ff','#00ffff','#ffffff','#1a1e24','#ff3399','#33ff77','#ffff33','#3399ff','#cc33ff','#33ffff','#ffffff']"
            echo "foreground_color='#e0e6f0'"
            echo "background_color='#0a0e14'"
            echo "bold_color='#e0e6f0'"
            echo "bold_color_same_as_fg=true"
            ;;
        cyberpunk-neon)
            echo "palette=['#123e7c','#ff0000','#d300c4','#f57800','#123e7c','#711c91','#0abdc6','#d7d7d5','#1c61c2','#ff0000','#d300c4','#f57800','#00ff00','#711c91','#0abdc6','#d7d7d5']"
            echo "foreground_color='#0abdc6'"
            echo "background_color='#000b1e'"
            echo "bold_color='#0abdc6'"
            echo "bold_color_same_as_fg=true"
            ;;
        cyberpunk-night)
            echo "palette=['#161b22','#f85149','#39d353','#d29922','#1f6feb','#8b5cf6','#39d353','#c9d1d9','#21262d','#ff7b72','#56d364','#e3b341','#58a6ff','#bc8cff','#56d364','#f0f6fc']"
            echo "foreground_color='#c9d1d9'"
            echo "background_color='#0d1117'"
            echo "bold_color='#c9d1d9'"
            echo "bold_color_same_as_fg=true"
            ;;
        *)
            # Tokyo Night (Default)
            echo "palette=['#32344a','#f7768e','#9ece6a','#e0af68','#7aa2f7','#ad8ee6','#449dab','#787c99','#444b6a','#ff7a93','#b9f27c','#ff9e64','#7da6ff','#bb9af7','#0db9d7','#acb0d0']"
            echo "foreground_color='#a9b1d6'"
            echo "background_color='#1a1b26'"
            echo "bold_color='#a9b1d6'"
            echo "bold_color_same_as_fg=true"
            ;;
    esac
}

# Función para aplicar colores al perfil de GNOME Terminal
apply_gnome_terminal_theme() {
    local profile_path="$1"

    # Leer colores del tema
    eval "$(get_gnome_terminal_colors)"

    # Aplicar via dconf
    dconf write "${profile_path}/palette" "$palette"
    dconf write "${profile_path}/foreground_color" "$foreground_color"
    dconf write "${profile_path}/background_color" "$background_color"
    dconf write "${profile_path}/bold_color" "$bold_color"
    dconf write "${profile_path}/bold_color_same_as_fg" "$bold_color_same_as_fg"
    dconf write "${profile_path}/use-theme-colors" "false"
    dconf write "${profile_path}/visible-name" "'$THEME'"

    # Configurar fuente Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
        mkdir -p ~/.local/share/fonts
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip
        unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts > /dev/null
        rm -f /tmp/JetBrainsMono.zip
        fc-cache -fv > /dev/null
    fi
    dconf write "${profile_path}/use-system-font" "false"
    dconf write "${profile_path}/font" "'JetBrainsMono Nerd Font 11'"
}

# Función para obtener el perfil por defecto de GNOME Terminal
get_default_profile() {
    # Intentar obtener el perfil marcado como predeterminado
    local default
    default=$(dconf read /org/gnome/terminal/legacy/profiles:/ 2>/dev/null | tr -d "'" | tr -d '/')

    if [ -n "$default" ] && [ "$default" != "" ]; then
        echo "$default"
        return
    fi

    # Si no hay perfil por defecto, tomar el primero disponible
    local first_profile
    first_profile=$(dconf list /org/gnome/terminal/legacy/profiles:/ 2>/dev/null | head -1 | tr -d '/')

    if [ -n "$first_profile" ]; then
        echo "$first_profile"
        return
    fi

    # Si no hay perfiles, crear uno nuevo
    echo ""
}
