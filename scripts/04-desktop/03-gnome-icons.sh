#!/bin/bash
# ==============================================================================
# 09-gnome-icons.sh
# Instala y aplica temas de iconos para GNOME en Fedora/Ubuntu.
#
# Iconos disponibles:
#   1. WhiteSur Icons  → macOS Big Sur/Monterey/Ventura/Sonoma ⭐
#   2. McMojave Circle → macOS Mojave (circulares)
#   3. Tela Circle     → Minimalista redondeado
#   4. Papirus         → Flat moderno SVG (muy completo)
#   5. BeautyLine      → Coloridos premium (estilo Apple)
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "Instalador de iconos GNOME"

# ── Menú interactivo de selección ─────────────────────────────────────────────
show_icon_menu() {
    local -A selected
    selected[whitesur]=false
    selected[mcmojave]=false
    selected[telacircle]=false
    selected[papirus]=false
    selected[beautyline]=false

    while true; do
        echo "" >&2
        echo "================================================================" >&2
        echo "  SELECCIONA LOS ICONOS A INSTALAR" >&2
        echo "================================================================" >&2
        echo "" >&2

        echo "  [1] WhiteSur Icons  → macOS Big Sur/Monterey    $([ "${selected[whitesur]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [2] McMojave Circle → macOS Mojave (circulares) $([ "${selected[mcmojave]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [3] Tela Circle     → Minimalista redondeado    $([ "${selected[telacircle]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [4] Papirus         → Flat moderno SVG          $([ "${selected[papirus]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "  [5] BeautyLine      → Coloridos premium         $([ "${selected[beautyline]}" = true ] && echo "[✓]" || echo "[ ]")" >&2
        echo "" >&2
        echo "  [T] Instalar todos" >&2
        echo "  [N] Ninguno (salir)" >&2
        echo "  [A] Continuar con la instalación" >&2
        echo "" >&2
        read -p "  Opción (1-5 para togglear, T/N/A): " input

        case "$input" in
            1) selected[whitesur]=$([ "${selected[whitesur]}" = true ] && echo false || echo true) ;;
            2) selected[mcmojave]=$([ "${selected[mcmojave]}" = true ] && echo false || echo true) ;;
            3) selected[telacircle]=$([ "${selected[telacircle]}" = true ] && echo false || echo true) ;;
            4) selected[papirus]=$([ "${selected[papirus]}" = true ] && echo false || echo true) ;;
            5) selected[beautyline]=$([ "${selected[beautyline]}" = true ] && echo false || echo true) ;;
            t|T)
                selected[whitesur]=true
                selected[mcmojave]=true
                selected[telacircle]=true
                selected[papirus]=true
                selected[beautyline]=true
                ;;
            n|N) exit 0 ;;
            a|A) break ;;
            *) echo "  Opción inválida. Usa 1-5, T, N o A" >&2 ;;
        esac
    done

    local result=""
    for key in whitesur mcmojave telacircle papirus beautyline; do
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

# ── Instalar WhiteSur Icon Theme ⭐ ──────────────────────────────────────────
install_whitesur() {
    if [ -d "$HOME/.local/share/icons/WhiteSur" ]; then
        success "WhiteSur Icon Theme ya está instalado."
    else
        info "Instalando WhiteSur Icon Theme (macOS Big Sur/Monterey)..."
        cd ~
        rm -rf WhiteSur-icon-theme
        git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
        cd ~/WhiteSur-icon-theme
        ./install.sh
        success "WhiteSur Icon Theme instalado."
    fi
}

# ── Instalar McMojave Circle Icon Theme ──────────────────────────────────────
install_mcmojave() {
    if [ -d "$HOME/.local/share/icons/McMojave-circle" ]; then
        success "McMojave Circle Icon Theme ya está instalado."
    else
        info "Instalando McMojave Circle Icon Theme (macOS Mojave)..."
        cd ~
        rm -rf McMojave-circle
        git clone https://github.com/vinceliuice/McMojave-circle.git --depth=1
        cd ~/McMojave-circle
        ./install.sh
        success "McMojave Circle Icon Theme instalado."
    fi
}

# ── Instalar Tela Circle Icon Theme ──────────────────────────────────────────
install_telacircle() {
    if [ -d "$HOME/.local/share/icons/Tela-circle" ]; then
        success "Tela Circle Icon Theme ya está instalado."
    else
        info "Instalando Tela Circle Icon Theme (minimalista redondeado)..."
        cd ~
        rm -rf Tela-circle-icon-theme
        git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git --depth=1
        cd ~/Tela-circle-icon-theme
        ./install.sh -a
        success "Tela Circle Icon Theme instalado."
    fi
}

# ── Instalar Papirus Icon Theme ──────────────────────────────────────────────
install_papirus() {
    if [ -d "$HOME/.local/share/icons/Papirus" ] || [ -d "/usr/share/icons/Papirus" ]; then
        success "Papirus Icon Theme ya está instalado."
    else
        info "Instalando Papirus Icon Theme (flat moderno SVG)..."
        if is_fedora; then
            platform_install_packages papirus-icon-theme
        elif is_ubuntu; then
            platform_install_packages papirus-icon-theme
        fi
        success "Papirus Icon Theme instalado."
    fi
}

# ── Instalar BeautyLine Icon Theme ───────────────────────────────────────────
install_beautyline() {
    if [ -d "$HOME/.local/share/icons/BeautyLine" ]; then
        success "BeautyLine Icon Theme ya está instalado."
    else
        info "Instalando BeautyLine Icon Theme (coloridos premium)..."
        cd ~
        rm -rf BeautyLine
        git clone https://github.com/gvolpe/BeautyLine.git --depth=1
        mkdir -p ~/.local/share/icons
        cp -r ~/BeautyLine/BeautyLine ~/.local/share/icons/
        success "BeautyLine Icon Theme instalado."
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
    [ -d "$HOME/.local/share/icons/McMojave-circle" ] || [ -d "/usr/share/icons/McMojave-circle" ] && installed_themes+=("McMojave-circle")
    [ -d "$HOME/.local/share/icons/Tela-circle" ] || [ -d "/usr/share/icons/Tela-circle" ] && installed_themes+=("Tela-circle")
    [ -d "$HOME/.local/share/icons/Papirus" ] || [ -d "/usr/share/icons/Papirus" ] && installed_themes+=("Papirus")
    [ -d "$HOME/.local/share/icons/BeautyLine" ] || [ -d "/usr/share/icons/BeautyLine" ] && installed_themes+=("BeautyLine")

    if [ ${#installed_themes[@]} -eq 0 ]; then
        warn "No se instaló ningún tema de iconos."
        return
    fi

    echo "" >&2
    echo "================================================================" >&2
    echo "  TEMA DE ICONOS ACTIVO" >&2
    echo "================================================================" >&2
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
        whitesur)    install_whitesur ;;
        mcmojave)    install_mcmojave ;;
        telacircle)  install_telacircle ;;
        papirus)     install_papirus ;;
        beautyline)  install_beautyline ;;
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
        whitesur)    echo "  • WhiteSur Icons  → macOS Big Sur/Monterey ⭐" ;;
        mcmojave)    echo "  • McMojave Circle → macOS Mojave (circulares)" ;;
        telacircle)  echo "  • Tela Circle     → Minimalista redondeado" ;;
        papirus)     echo "  • Papirus         → Flat moderno SVG" ;;
        beautyline)  echo "  • BeautyLine      → Coloridos premium" ;;
    esac
done
echo ""
echo "  Los iconos se pueden cambiar en cualquier momento con:"
echo "  gnome-tweaks → Apariencia → Iconos"
echo ""
