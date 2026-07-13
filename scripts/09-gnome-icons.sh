#!/bin/bash
# ==============================================================================
# 09-gnome-icons.sh
# Instala y aplica temas de iconos para GNOME en Fedora/Ubuntu.
#
# Iconos disponibles:
#   1. WhiteSur      → macOS Big Sur (squircle)
#   2. MacTahoe      → macOS style (squircle)
#   3. Pebble        → Premium squircle (10 variantes de color)
#   4. Flat Remix    → Material Design (flat con sombras)
#   5. Numix Circle  → Circulares clásicos
#   6. Papirus       → Flat moderno SVG
# ==============================================================================

set -e
source "$(dirname "$0")/lib.sh"

section "🎨 Instalador de Iconos GNOME"

# ── Menú interactivo de selección ─────────────────────────────────────────────
show_icon_menu() {
    local -A selected
    selected[whitesur]=false
    selected[mactahoe]=false
    selected[pebble]=false
    selected[flatremix]=false
    selected[numix]=false
    selected[papirus]=false

    while true; do
        echo "" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "  SELECCIONA LOS ICONOS A INSTALAR" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "" >&2

        echo "  [1] WhiteSur       → macOS Big Sur           $([ "${selected[whitesur]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [2] MacTahoe       → macOS style              $([ "${selected[mactahoe]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [3] Pebble         → Squircle premium (10色)  $([ "${selected[pebble]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [4] Flat Remix     → Material Design          $([ "${selected[flatremix]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [5] Numix Circle   → Circulares clásicos      $([ "${selected[numix]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [6] Papirus        → Flat moderno SVG         $([ "${selected[papirus]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "" >&2
        echo "  [T] Aplicar todos" >&2
        echo "  [N] Ninguno (salir)" >&2
        echo "  [A] Continuar con la instalación" >&2
        echo "" >&2
        read -p "  Opción (1-6 para togglear, T/N/A): " input

        case "$input" in
            1) selected[whitesur]=$([ "${selected[whitesur]}" = true ] && echo false || echo true) ;;
            2) selected[mactahoe]=$([ "${selected[mactahoe]}" = true ] && echo false || echo true) ;;
            3) selected[pebble]=$([ "${selected[pebble]}" = true ] && echo false || echo true) ;;
            4) selected[flatremix]=$([ "${selected[flatremix]}" = true ] && echo false || echo true) ;;
            5) selected[numix]=$([ "${selected[numix]}" = true ] && echo false || echo true) ;;
            6) selected[papirus]=$([ "${selected[papirus]}" = true ] && echo false || echo true) ;;
            t|T)
                selected[whitesur]=true
                selected[mactahoe]=true
                selected[pebble]=true
                selected[flatremix]=true
                selected[numix]=true
                selected[papirus]=true
                ;;
            n|N) exit 0 ;;
            a|A) break ;;
            *) echo "  ⚠ Opción inválida. Usa 1-6, T, N o A" >&2 ;;
        esac
    done

    local result=""
    for key in whitesur mactahoe pebble flatremix numix papirus; do
        if [ "${selected[$key]}" = true ]; then
            result="$result $key"
        fi
    done
    echo "$result"
}

# ── Instalar dependencias del sistema ─────────────────────────────────────────
install_dependencies() {
    info "Instalando dependencias del sistema..."
    if is_fedora; then
        pkg_install git sassc glib2-devel libxml2 ImageMagick optipng inkscape make
    elif is_ubuntu; then
        pkg_install git sassc libglib2.0-dev-bin libxml2-utils imagemagick optipng inkscape make
    fi
    success "Dependencias instaladas."
}

# ── Instalar WhiteSur Icon Theme ─────────────────────────────────────────────
install_whitesur() {
    if [ -d "$HOME/.local/share/icons/WhiteSur" ]; then
        success "WhiteSur Icon Theme ya está instalado."
    else
        info "Instalando WhiteSur Icon Theme..."
        cd ~
        rm -rf WhiteSur-icon-theme
        git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
        cd ~/WhiteSur-icon-theme
        ./install.sh
        success "WhiteSur Icon Theme instalado."
    fi
}

# ── Instalar MacTahoe Icon Theme ─────────────────────────────────────────────
install_mactahoe() {
    if [ -d "$HOME/.local/share/icons/MacTahoe" ]; then
        success "MacTahoe Icon Theme ya está instalado."
    else
        info "Instalando MacTahoe Icon Theme..."
        cd ~
        rm -rf MacTahoe-icon-theme
        git clone https://github.com/vinceliuice/MacTahoe-icon-theme.git --depth=1
        cd ~/MacTahoe-icon-theme
        ./install.sh
        success "MacTahoe Icon Theme instalado."
    fi
}

# ── Instalar Pebble Icon Theme ───────────────────────────────────────────────
install_pebble() {
    if [ -d "$HOME/.local/share/icons/Pebble" ]; then
        success "Pebble Icon Theme ya está instalado."
    else
        info "Instalando Pebble Icon Theme..."
        cd ~
        rm -rf Pebble-Icon-Theme
        git clone https://github.com/abhijeetshewale05/Pebble-Icon-Theme.git --depth=1
        cd ~/Pebble-Icon-Theme
        ./install.sh
        success "Pebble Icon Theme instalado."
    fi
}

# ── Instalar Flat Remix Icon Theme ───────────────────────────────────────────
install_flatremix() {
    if [ -d "$HOME/.local/share/icons/Flat-Remix" ]; then
        success "Flat Remix Icon Theme ya está instalado."
    else
        info "Instalando Flat Remix Icon Theme..."
        cd ~
        rm -rf flat-remix
        git clone https://github.com/daniruiz/flat-remix.git --depth=1
        cd ~/flat-remix
        make install
        success "Flat Remix Icon Theme instalado."
    fi
}

# ── Instalar Numix Circle Icon Theme ─────────────────────────────────────────
install_numix() {
    if [ -d "$HOME/.local/share/icons/Numix-Circle" ] || [ -d "/usr/share/icons/Numix-Circle" ]; then
        success "Numix Circle Icon Theme ya está instalado."
    else
        info "Instalando Numix Circle Icon Theme..."
        if is_fedora; then
            sudo dnf install -y numix-icon-theme-circle
        elif is_ubuntu; then
            sudo apt install -y numix-icon-theme-circle
        fi
        success "Numix Circle Icon Theme instalado."
    fi
}

# ── Instalar Papirus Icon Theme ──────────────────────────────────────────────
install_papirus() {
    if [ -d "$HOME/.local/share/icons/Papirus" ] || [ -d "/usr/share/icons/Papirus" ]; then
        success "Papirus Icon Theme ya está instalado."
    else
        info "Instalando Papirus Icon Theme..."
        if is_fedora; then
            sudo dnf install -y papirus-icon-theme
        elif is_ubuntu; then
            sudo apt install -y papirus-icon-theme
        fi
        success "Papirus Icon Theme instalado."
    fi
}

# ── Aplicar tema de iconos ───────────────────────────────────────────────────
apply_icon_theme() {
    local theme="$1"
    info "Aplicando tema de iconos: $theme"
    gsettings set org.gnome.desktop.interface icon-theme "$theme"
    success "Tema de iconos aplicado: $theme"
}

# ── Menú para seleccionar tema activo ────────────────────────────────────────
choose_active_theme() {
    local installed_themes=()

    [ -d "$HOME/.local/share/icons/WhiteSur" ] || [ -d "/usr/share/icons/WhiteSur" ] && installed_themes+=("WhiteSur")
    [ -d "$HOME/.local/share/icons/MacTahoe" ] || [ -d "/usr/share/icons/MacTahoe" ] && installed_themes+=("MacTahoe")
    [ -d "$HOME/.local/share/icons/Pebble" ] || [ -d "/usr/share/icons/Pebble" ] && installed_themes+=("Pebble")
    [ -d "$HOME/.local/share/icons/Flat-Remix" ] || [ -d "/usr/share/icons/Flat-Remix" ] && installed_themes+=("Flat-Remix")
    [ -d "$HOME/.local/share/icons/Numix-Circle" ] || [ -d "/usr/share/icons/Numix-Circle" ] && installed_themes+=("Numix-Circle")
    [ -d "$HOME/.local/share/icons/Papirus" ] || [ -d "/usr/share/icons/Papirus" ] && installed_themes+=("Papirus")

    if [ ${#installed_themes[@]} -eq 0 ]; then
        warn "No se instaló ningún tema de iconos."
        return
    fi

    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "  TEMA DE ICONOS ACTIVO" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2

    local i=1
    for theme in "${installed_themes[@]}"; do
        echo "  [$i] $theme" >&2
        i=$((i + 1))
    done
    echo "" >&2

    local current=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
    echo "  Tema actual: $current" >&2
    echo "" >&2

    read -p "  Selecciona tema activo [1-${#installed_themes[@]}] (Enter para mantener actual): " choice

    if [ -n "$choice" ] && [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "${#installed_themes[@]}" ] 2>/dev/null; then
        local selected_theme="${installed_themes[$((choice - 1))]}"
        apply_icon_theme "$selected_theme"
    else
        info "Manteniendo tema actual: $current"
    fi
}

# ── Flujo principal ──────────────────────────────────────────────────────────
SELECTED=$(show_icon_menu)

if [ -z "$SELECTED" ]; then
    info "No se seleccionaron iconos."
    exit 0
fi

echo ""
info "Iconos a instalar:$SELECTED"
echo ""

install_dependencies

for icon in $SELECTED; do
    case "$icon" in
        whitesur)   install_whitesur ;;
        mactahoe)   install_mactahoe ;;
        pebble)     install_pebble ;;
        flatremix)  install_flatremix ;;
        numix)      install_numix ;;
        papirus)    install_papirus ;;
    esac
done

echo ""
choose_active_theme

# ── Resumen final ─────────────────────────────────────────────────────────────
echo ""
success "¡Instalación de iconos completa!"
echo ""
echo -e "  ${BOLD}Iconos instalados:${RESET}"
echo "$SELECTED" | tr ' ' '\n' | while read -r icon; do
    case "$icon" in
        whitesur)   echo "  • WhiteSur     → macOS Big Sur" ;;
        mactahoe)   echo "  • MacTahoe     → macOS style" ;;
        pebble)     echo "  • Pebble       → Squircle premium" ;;
        flatremix)  echo "  • Flat Remix   → Material Design" ;;
        numix)      echo "  • Numix Circle → Circulares clásicos" ;;
        papirus)    echo "  • Papirus      → Flat moderno SVG" ;;
    esac
done
echo ""
echo "  Los iconos se pueden cambiar en cualquier momento con:"
echo "  gnome-tweaks → Apariencia → Iconos"
echo ""
