#!/bin/bash
# ==============================================================================
# 04-gnome-theme.sh
# Instala temas estilo macOS en Fedora 43 + GNOME con soporte claro/oscuro.
#
# Temas instalados:
#   GTK   → WhiteSur-Light / WhiteSur-Dark  (soporte claro y oscuro)
#   Icons → WhiteSur  (activo por defecto)
#   GDM   → MacTahoe  (solo pantalla de inicio de sesión)
#   Extra → MacTahoe-icon-theme (instalado, no activo)
#   Firefox → WhiteSur Firefox Theme
# ==============================================================================

source "$(dirname "$0")/lib.sh"
init_log
trap cleanup_log EXIT

REAL_USER="${SUDO_USER:-$USER}"

gsettings_run() {
    sudo -u "$REAL_USER" gsettings "$@" 2>/dev/null || true
}

gnome_ext_run() {
    sudo -u "$REAL_USER" gnome-extensions "$@" 2>/dev/null || true
}

# ── Argumentos de Granularidad ───────────────────────────────────────────────
SKIP_DEP=false; SKIP_GTK=false; SKIP_ICONS=false; SKIP_GDM=false; SKIP_FIREFOX=false; SKIP_SYNC=false
for arg in "$@"; do
  case $arg in
    --skip-dep) SKIP_DEP=true ;;
    --skip-gtk) SKIP_GTK=true ;;
    --skip-icons) SKIP_ICONS=true ;;
    --skip-gdm) SKIP_GDM=true ;;
    --skip-firefox) SKIP_FIREFOX=true ;;
    --skip-sync) SKIP_SYNC=true ;;
  esac
done

section "🍎 Temas GNOME estilo macOS"

log_to_file "Flags activos: dep=$SKIP_DEP gtk=$SKIP_GTK icons=$SKIP_ICONS gdm=$SKIP_GDM firefox=$SKIP_FIREFOX sync=$SKIP_SYNC"

# ── 1. Dependencias ───────────────────────────────────────────────────────────
if [ "$SKIP_DEP" = false ]; then
  info "Instalando dependencias del sistema..."
  log_cmd "sudo dnf install -y git sassc glib2-devel..."
  sudo dnf install -y \
    git sassc glib2-devel libxml2 \
    ImageMagick optipng inkscape \
    gnome-shell-extension-user-theme \
    gnome-tweaks \
    gnome-extensions-app
  success "Dependencias instaladas."
else
  info "Saltando dependencias (--skip-dep)"
fi

# ── 2. Clonar/actualizar repositorios ────────────────────────────────────────
info "Verificando/clonando repositorios de temas..."

if [ "$SKIP_GTK" = false ]; then
  if [ -d ~/WhiteSur-gtk-theme ]; then
    info "WhiteSur-gtk-theme ya existe, actualizando..."
    cd ~/WhiteSur-gtk-theme && git pull -q
  else
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
  fi
fi

if [ "$SKIP_ICONS" = false ]; then
  if [ -d ~/WhiteSur-icon-theme ]; then
    info "WhiteSur-icon-theme ya existe, actualizando..."
    cd ~/WhiteSur-icon-theme && git pull -q
  else
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
  fi
  
  if [ -d ~/MacTahoe-icon-theme ]; then
    info "MacTahoe-icon-theme ya existe, actualizando..."
    cd ~/MacTahoe-icon-theme && git pull -q
  else
    git clone https://github.com/vinceliuice/MacTahoe-icon-theme.git --depth=1
  fi
fi

if [ "$SKIP_FIREFOX" = false ]; then
  if [ -d ~/WhiteSur-firefox-theme ]; then
    info "WhiteSur-firefox-theme ya existe, actualizando..."
    cd ~/WhiteSur-firefox-theme && git pull -q
  else
    git clone https://github.com/vinceliuice/WhiteSur-firefox-theme.git --depth=1
  fi
fi

if [ "$SKIP_GDM" = false ]; then
  if [ -d ~/MacTahoe-gtk-theme ]; then
    info "MacTahoe-gtk-theme ya existe, actualizando..."
    cd ~/MacTahoe-gtk-theme && git pull -q
  else
    git clone https://github.com/vinceliuice/MacTahoe-gtk-theme.git --depth=1
  fi
fi

success "Repositorios verificados/clonados."

# ── 4. Instalar GTK Theme: WhiteSur (Light y Dark) ───────────────────────────
if [ "$SKIP_GTK" = false ]; then
  info "Instalando WhiteSur GTK Theme (Light + Dark)..."
  log_cmd "cd ~/WhiteSur-gtk-theme && ./install.sh -l -N glassy -c Light && ./install.sh -l -N glassy -c Dark"
  cd ~/WhiteSur-gtk-theme
  ./install.sh -l -N glassy -c Light
  ./install.sh -l -N glassy -c Dark
  success "WhiteSur GTK Theme instalado."
else
  info "Saltando GTK Theme (--skip-gtk)"
fi

# ── 5. Instalar Icon Theme: WhiteSur ─────────────────────────────────────────
if [ "$SKIP_ICONS" = false ]; then
  info "Instalando WhiteSur Icon Theme..."
  log_cmd "cd ~/WhiteSur-icon-theme && ./install.sh"
  cd ~/WhiteSur-icon-theme
  ./install.sh
  success "WhiteSur Icon Theme instalado."

  # ── 6. Instalar MacTahoe Icon Theme (instalado pero no activado) ────────────
  info "Instalando MacTahoe Icon Theme (disponible pero no activo)..."
  cd ~/MacTahoe-icon-theme
  ./install.sh
  success "MacTahoe Icon Theme instalado."
else
  info "Saltando Icon Themes (--skip-icons)"
fi

# ── 7. Instalar MacTahoe GTK (necesario para el tweak de GDM) ────────────────
if [ "$SKIP_GDM" = false ]; then
  info "Instalando MacTahoe GTK Theme (requerido para GDM)..."
  log_cmd "cd ~/MacTahoe-gtk-theme && ./install.sh -l -c Light"
  cd ~/MacTahoe-gtk-theme
  ./install.sh -l -c Light
  success "MacTahoe GTK Theme instalado."

  # ── 8. Aplicar GDM MacTahoe ─────────────────────────────────────────────────
  info "Aplicando tema GDM MacTahoe (requiere sudo)..."
  if [ -d ~/WhiteSur-gtk-theme ] && [ "$SKIP_GTK" = false ]; then
    cd ~/WhiteSur-gtk-theme
    sudo ./tweaks.sh -r 2>/dev/null || true
  fi
  cd ~/MacTahoe-gtk-theme
  sudo ./tweaks.sh -g -b default
  success "Tema GDM MacTahoe aplicado."
else
  info "Saltando GDM Theme (--skip-gdm)"
fi

# ── 9. Instalar WhiteSur Firefox Theme ───────────────────────────────────────
if [ "$SKIP_FIREFOX" = false ]; then
  info "Instalando WhiteSur Firefox Theme..."
  cd ~/WhiteSur-firefox-theme
  ./install.sh
  success "WhiteSur Firefox Theme instalado."
fi

# ── 10. Activar extensión User Themes ─────────────────────────────────────────
info "Activando extensión User Themes..."
gnome_ext_run enable user-theme@gnome-shell-extensions.gcampax.github.com || \
  warn "No se pudo activar User Themes automáticamente. Actívala manualmente."

# ── 11. Aplicar configuración de apariencia GNOME ────────────────────────────
info "Aplicando apariencia GNOME (modo claro por defecto)..."

if [ "$SKIP_GTK" = false ]; then
  gsettings_run set org.gnome.desktop.interface color-scheme 'prefer-light'
  gsettings_run set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
  gsettings_run set org.gnome.shell.extensions.user-theme name "WhiteSur-Light"
fi

if [ "$SKIP_ICONS" = false ]; then
  gsettings_run set org.gnome.desktop.interface icon-theme "WhiteSur"
fi

gsettings_run set org.gnome.desktop.interface cursor-theme "Adwaita"
gsettings_run set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

success "Apariencia aplicada."

# ── 12. Sincronización Automática de Temas Claro/Oscuro ──────────────────────
if [ "$SKIP_SYNC" = false ]; then
  info "Configurando script de sincronización automática para GNOME Shell y GTK..."

  mkdir -p ~/.local/bin 2>/dev/null
  mkdir -p ~/.config/autostart 2>/dev/null

  cat << 'EOF' > ~/.local/bin/whitesur-theme-sync.sh
#!/bin/bash
# Espera a que GNOME Shell inicie si se ejecuta al arranque (autostart)
trap 'pkill -P $$ 2>/dev/null' EXIT
sleep 2

last_family=""
last_mode=""


apply_theme() {
    local change_str="$1"

    # Solo reaccionar si el cambio es de color-scheme o gtk-theme y el tema es WhiteSur
    if [[ "$change_str" != *"color-scheme"* && "$change_str" != *"gtk-theme"* && "$change_str" != *"Init"* ]]; then
        return
    fi

    # Detectar si el tema actual es WhiteSur
    local current_gtk=$(gsettings get org.gnome.desktop.interface gtk-theme)
    if [[ "$current_gtk" != *"WhiteSur"* ]]; then
        return
    fi

    # Detectar modo claro/oscuro
    local current_scheme=$(gsettings get org.gnome.desktop.interface color-scheme)
    local mode="Light"
    if [[ "$current_scheme" == *"prefer-dark"* ]]; then
        mode="Dark"
    fi

    # Solo aplicar si hay cambio de modo
    if [ "$mode" == "$last_mode" ]; then
        return
    fi
    last_mode=$mode

    local target_scheme=$([ "$mode" == "Dark" ] && echo "prefer-dark" || echo "default")
    local gtk_theme="WhiteSur-${mode}"
    local shell_theme="WhiteSur-${mode}-solid"
    local icon_theme="WhiteSur"

    if [ "$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")" != "$target_scheme" ]; then
        gsettings set org.gnome.desktop.interface color-scheme "$target_scheme"
    fi
    if [ "$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")" != "$gtk_theme" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
    fi
    if [ "$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")" != "$icon_theme" ]; then
        gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
    fi
    if [ "$(gsettings get org.gnome.shell.extensions.user-theme name | tr -d "'")" != "$shell_theme" ]; then
        gsettings set org.gnome.shell.extensions.user-theme name "$shell_theme"
    fi
}

apply_theme "Init"

gsettings monitor org.gnome.desktop.interface | while read -r line; do apply_theme "$line"; done &
gsettings monitor org.gnome.shell.extensions.user-theme | while read -r line; do apply_theme "$line"; done &

wait
EOF

  chmod +x ~/.local/bin/whitesur-theme-sync.sh 2>/dev/null

  cat << 'EOF' > ~/.config/autostart/whitesur-theme-sync.desktop
[Desktop Entry]
Type=Application
Exec=/home/${REAL_USER}/.local/bin/whitesur-theme-sync.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[es_ES]=WhiteSur Theme Sync
Name=WhiteSur Theme Sync
Comment[es_ES]=Sincroniza Shell y GTK con modo Oscuro
Comment=Sync Shell and GTK with Dark Mode
EOF

  # Iniciar el script ahora mismo en segundo plano
  if ! pgrep -f whitesur-theme-sync.sh > /dev/null; then
      ~/.local/bin/whitesur-theme-sync.sh &
  fi

  success "Script de sincronización configurado en ~/.local/bin/ y autostart."
fi

# ── 13. Resumen final ─────────────────────────────────────────────────────────
echo ""
success "¡Instalación completa!"
echo ""
echo -e "  ${BOLD}Resumen:${RESET}"
echo "  • GTK Theme:   WhiteSur-Light / WhiteSur-Dark"
echo "  • Icon Theme:  WhiteSur  (MacTahoe también disponible)"
echo "  • GDM:         MacTahoe"
echo "  • Firefox:     WhiteSur Firefox Theme"
echo "  • Shell Theme: WhiteSur-Light / WhiteSur-Dark (Auto-Sincronizado al panel de GNOME)"
echo ""
echo -e "  ${YELLOW}${BOLD}IMPORTANTE:${RESET} Cierra sesión y vuelve a iniciar para que GNOME"
echo "  recargue GTK4/libadwaita correctamente."
echo ""
echo "  Logout → Login"
echo ""
