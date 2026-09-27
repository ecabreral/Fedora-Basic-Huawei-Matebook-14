#!/bin/bash
# ==============================================================================
# ptyxis-colors.sh — Temas de colores para Ptyxis via paletas de usuario.
# Los colores son idénticos a los históricos de GNOME Terminal.
# Compartido por 01-terminal-setup.sh y 02-change-theme.sh
#
# Ptyxis carga paletas custom desde:
#   ~/.local/share/ptyxis/palettes/<id>.palette   (keyfile INI)
# El ID de la paleta es el nombre del archivo sin ".palette" y se asigna al
# perfil con: gsettings set org.gnome.Ptyxis.Profile:/.../<uuid>/ palette '<id>'
# ==============================================================================

PTYXIS_PALETTES_DIR="$HOME/.local/share/ptyxis/palettes"
PTYXIS_FONT="JetBrainsMono Nerd Font 11"
PTYXIS_COLUMNS=120
PTYXIS_ROWS=35

# ── Datos de colores por tema ─────────────────────────────────────────────────
# Define: _PTYXIS_FG, _PTYXIS_BG y el arreglo _PTYXIS_COLORS (16 colores).
_ptyxis_theme_data() {
    local theme="$1"

    _PTYXIS_FG="" _PTYXIS_BG=""
    _PTYXIS_COLORS=()

    case "$theme" in
        tokyo-night)
            _PTYXIS_FG='#a9b1d6' _PTYXIS_BG='#1a1b26'
            _PTYXIS_COLORS=( '#32344a' '#f7768e' '#9ece6a' '#e0af68' '#7aa2f7' '#ad8ee6' '#449dab' '#787c99' '#444b6a' '#ff7a93' '#b9f27c' '#ff9e64' '#7da6ff' '#bb9af7' '#0db9d7' '#acb0d0' )
            ;;
        pastel-powerline)
            _PTYXIS_FG='#575279' _PTYXIS_BG='#faf4ed'
            _PTYXIS_COLORS=( '#575279' '#b4637a' '#286983' '#ea9d34' '#56949f' '#907aa9' '#ea9d34' '#faf4ed' '#9893a5' '#b4637a' '#286983' '#ea9d34' '#56949f' '#907aa9' '#ea9d34' '#575279' )
            ;;
        gruvbox-rainbow)
            _PTYXIS_FG='#ebdbb2' _PTYXIS_BG='#282828'
            _PTYXIS_COLORS=( '#3c3836' '#cc241d' '#98971a' '#d79921' '#458588' '#b16286' '#689d6a' '#a89984' '#928374' '#fb4934' '#b8bb26' '#fabd2f' '#83a598' '#d3869b' '#8ec07c' '#ebdbb2' )
            ;;
        catppuccin-powerline)
            _PTYXIS_FG='#cdd6f4' _PTYXIS_BG='#1e1e2e'
            _PTYXIS_COLORS=( '#45475a' '#f38ba8' '#a6e3a1' '#f9e2af' '#89b4fa' '#f5c2e7' '#94e2d5' '#bac2de' '#585b70' '#f38ba8' '#a6e3a1' '#f9e2af' '#89b4fa' '#f5c2e7' '#94e2d5' '#a6adc8' )
            ;;
        *)
            _PTYXIS_FG='' _PTYXIS_BG=''
            _PTYXIS_COLORS=()
            return 1
            ;;
    esac

    [ ${#_PTYXIS_COLORS[@]} -eq 16 ] && [ -n "$_PTYXIS_FG" ]
}

# ── Nombre legible del tema ───────────────────────────────────────────────────
ptyxis_theme_display_name() {
    case "$1" in
        tokyo-night)          echo "Tokyo Night" ;;
        pastel-powerline)     echo "Pastel Powerline" ;;
        gruvbox-rainbow)      echo "Gruvbox Rainbow" ;;
        catppuccin-powerline) echo "Catppuccin Powerline" ;;
        *)                    echo "$1" ;;
    esac
}

# ── Instalar paleta de usuario <theme>.palette ────────────────────────────────
install_ptyxis_palette() {
    local theme="$1"
    _ptyxis_theme_data "$theme" || { error "Tema desconocido: $theme"; return 1; }

    mkdir -p "$PTYXIS_PALETTES_DIR"
    local file="$PTYXIS_PALETTES_DIR/$theme.palette"

    cat > "$file" <<EOF
[Palette]
Name=$(ptyxis_theme_display_name "$theme")
Foreground=$_PTYXIS_FG
Background=$_PTYXIS_BG
CursorBackground=$_PTYXIS_FG
Color0=${_PTYXIS_COLORS[0]}
Color1=${_PTYXIS_COLORS[1]}
Color2=${_PTYXIS_COLORS[2]}
Color3=${_PTYXIS_COLORS[3]}
Color4=${_PTYXIS_COLORS[4]}
Color5=${_PTYXIS_COLORS[5]}
Color6=${_PTYXIS_COLORS[6]}
Color7=${_PTYXIS_COLORS[7]}
Color8=${_PTYXIS_COLORS[8]}
Color9=${_PTYXIS_COLORS[9]}
Color10=${_PTYXIS_COLORS[10]}
Color11=${_PTYXIS_COLORS[11]}
Color12=${_PTYXIS_COLORS[12]}
Color13=${_PTYXIS_COLORS[13]}
Color14=${_PTYXIS_COLORS[14]}
Color15=${_PTYXIS_COLORS[15]}
EOF

    success "Paleta Ptyxis instalada: $file"
}

# ── UUID del perfil por defecto de Ptyxis ─────────────────────────────────────
get_ptyxis_default_profile_uuid() {
    gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'"
}

# ── Aplicar tema completo a Ptyxis ────────────────────────────────────────────
# Instala la paleta, la asigna al perfil default y configura fuente/tamaño.
apply_ptyxis_theme() {
    local theme="$1"

    command -v ptyxis &>/dev/null || { warn "Ptyxis no está instalado."; return 1; }
    command -v gsettings &>/dev/null || { warn "gsettings no disponible."; return 1; }

    local uuid
    uuid=$(get_ptyxis_default_profile_uuid)
    if [ -z "$uuid" ]; then
        warn "No hay perfil de Ptyxis. Abre Ptyxis una vez y reintenta."
        return 1
    fi

    install_ptyxis_palette "$theme"

    local profile_path="org.gnome.Ptyxis.Profile:/org/gnome/ptyxis/profiles/$uuid/"
    gsettings set "$profile_path" palette "$theme"

    # Fuente Nerd Font + tamaño de ventana
    install_nerd_font
    gsettings set org.gnome.Ptyxis use-system-font false
    gsettings set org.gnome.Ptyxis font-name "$PTYXIS_FONT"
    gsettings set org.gnome.Ptyxis default-columns "$PTYXIS_COLUMNS"
    gsettings set org.gnome.Ptyxis default-rows "$PTYXIS_ROWS"

    success "Ptyxis configurado con tema: $theme"
}

# ── Establecer Ptyxis como terminal por defecto del sistema ──────────────────
set_ptyxis_as_default_terminal() {
    command -v ptyxis &>/dev/null || { warn "Ptyxis no está instalado."; return 1; }

    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'ptyxis'
        success "Ptyxis configurado como terminal por defecto en GNOME."
    fi

    if [ -x "$(command -v ptyxis)" ]; then
        sudo ln -sf "$(command -v ptyxis)" /usr/local/bin/x-terminal-emulator 2>/dev/null || true
        success "Symlink x-terminal-emulator → ptyxis creado."
    fi
}
