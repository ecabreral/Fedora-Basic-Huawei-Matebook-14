#!/usr/bin/env bash
# ==============================================================================
# 00-base-system.sh
# Configura el sistema base para Fedora o Ubuntu en Huawei MateBook 14.
# Incluye: Repositorios, códecs, VA-API Intel, Flatpak, optimizaciones.
# ==============================================================================

source "$(dirname "$0")/../../lib/common.sh"

OS="$(detect_os)"
section "💻 Sistema operativo detectado: $OS_NAME $OS_VERSION"

# ── 1. Repositorios adicionales ──────────────────────────────────────────────
if is_fedora; then

  section "🗃️ Habilitando RPM Fusion"

  if pkg_check rpmfusion-free-release; then
    success "RPM Fusion Free ya está instalado."
  else
    info "Instalando RPM Fusion Free..."
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    success "RPM Fusion Free instalado."
  fi

  if pkg_check rpmfusion-nonfree-release; then
    success "RPM Fusion Non-Free ya está instalado."
  else
    info "Instalando RPM Fusion Non-Free..."
    sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    success "RPM Fusion Non-Free instalado."
  fi

  info "Configurando repositorios RPM Fusion..."
  sudo dnf config-manager --set-disabled rpmfusion-free-rawhide 2>/dev/null || true
  sudo dnf config-manager --set-disabled rpmfusion-nonfree-rawhide 2>/dev/null || true
  sudo dnf config-manager --set-enabled rpmfusion-free 2>/dev/null || true
  sudo dnf config-manager --set-enabled rpmfusion-nonfree 2>/dev/null || true
  success "Repositorios RPM Fusion configurados."

elif is_ubuntu; then

  section "🗃️ Habilitando repositorios Ubuntu"

  info "Asegurando que universe, multiverse y restricted estén habilitados..."
  sudo add-apt-repository -y universe 2>/dev/null || true
  sudo add-apt-repository -y multiverse 2>/dev/null || true
  sudo add-apt-repository -y restricted 2>/dev/null || true

  # Verificar en sources.list (Ubuntu <24.04) o ubuntu.sources (24.04+)
  if grep -q "restricted" /etc/apt/sources.list 2>/dev/null || \
     grep -q "restricted" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null; then
    success "Repositorios restricted/universe/multiverse ya habilitados."
  else
    info "Verificando con apt-cache policy..."
    if apt policy 2>/dev/null | grep -q "restricted"; then
      success "Repositorios restricted disponibles."
    else
      warn "No se pudo confirmar restricted. Los códecs pueden fallar."
    fi
  fi

fi

# ── 2. Actualizar sistema ────────────────────────────────────────────────────
section "📊 Actualizando sistema"
info "Actualizando paquetes del sistema..."
if is_fedora; then
  sudo dnf group upgrade -y core 2>/dev/null || sudo dnf upgrade -y
elif is_ubuntu; then
  sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
fi
success "Sistema actualizado."

# ── 3. Códecs multimedia ─────────────────────────────────────────────────────
section "📦 Instalando códecs multimedia"

if is_fedora; then
  pkg_install \
    ffmpeg \
    ffmpeg-libs \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-ugly \
    gstreamer1-plugins-good-extras \
    gstreamer1-plugins-bad-free-extras

  if pkg_check ffmpeg-free; then
    info "Convirtiendo ffmpeg-free a ffmpeg completo..."
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
  fi

elif is_ubuntu; then
  info "Instalando ubuntu-restricted-extras..."
  sudo DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-restricted-extras 2>/dev/null || \
    sudo DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-restricted-addons

  pkg_install \
    ffmpeg \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav
fi

success "Códecs multimedia instalados."

# ── 4. VA-API: Aceleración de video por hardware (Intel) ──────────────────────
section "🎬 VA-API: Aceleración de video por hardware (Intel)"

if is_fedora; then
  pkg_install libva libva-utils

  if pkg_check intel-media-driver; then
    success "intel-media-driver ya está instalado."
  else
    info "Instalando intel-media-driver..."
    sudo dnf install -y intel-media-driver
    success "intel-media-driver instalado."
  fi

  if pkg_check libva-intel-media-driver; then
    info "Removiendo libva-intel-media-driver conflictivo..."
    sudo dnf remove -y libva-intel-media-driver || true
  fi

  pkg_install libva-intel-driver

elif is_ubuntu; then
  pkg_install \
    libva-drm2 \
    libva-wayland2 \
    libva-x11-2 \
    libva2 \
    vainfo

  if pkg_check intel-media-va-driver; then
    success "intel-media-va-driver ya instalado."
  else
    info "Instalando intel-media-va-driver..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y intel-media-va-driver
    success "intel-media-va-driver instalado."
  fi
fi

# ── 5. OpenH264 para Firefox ─────────────────────────────────────────────────
section "🦊 OpenH264 para Firefox"

if is_fedora; then
  pkg_install openh264
elif is_ubuntu; then
  if pkg_check openh264; then
    success "OpenH264 ya instalado."
  else
    info "Instalando OpenH264..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y openh264
    success "OpenH264 instalado."
  fi
fi

# ── 6. Flatpak y Flathub ──────────────────────────────────────────────────────
section "📦 Configurando Flatpak y Flathub"

if command -v flatpak &>/dev/null; then
  if flatpak remote-list 2>/dev/null | grep -q "flathub"; then
    success "Flathub ya está configurado."
  else
    info "Añadiendo Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub configurado."
  fi
else
  info "Instalando Flatpak..."
  if is_fedora; then
    sudo dnf install -y flatpak
  elif is_ubuntu; then
    sudo DEBIAN_FRONTEND=noninteractive apt install -y flatpak
  fi
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  success "Flatpak instalado y Flathub configurado."
fi

# ── 7. Optimizaciones de arranque ─────────────────────────────────────────────
section "⚡ Optimizaciones de arranque"

info "Deshabilitando NetworkManager-wait-online.service..."
if systemctl is-enabled NetworkManager-wait-online.service &>/dev/null; then
  sudo systemctl disable NetworkManager-wait-online.service
  success "NetworkManager-wait-online deshabilitado."
else
  success "NetworkManager-wait-online ya deshabilitado."
fi

info "Removiendo Gnome Software del autostart..."
if [ -f /etc/xdg/autostart/org.gnome.Software.desktop ]; then
  sudo rm -f /etc/xdg/autostart/org.gnome.Software.desktop
  success "Gnome Software removido del autostart."
elif [ -f /etc/xdg/autostart/gnome-software-service.desktop ]; then
  sudo rm -f /etc/xdg/autostart/gnome-software-service.desktop
  success "Gnome Software removido del autostart."
else
  success "Gnome Software ya no está en autostart."
fi

# ── 8. Verificar driver Intel ─────────────────────────────────────────────────
section "🔧 Verificando driver Intel"

info "Verificando driver gráfico..."
if lsmod | grep -qE "xe|i915"; then
  success "Driver Intel (xe/i915) cargado."
else
  warn "Driver Intel no detectado. Verifica con: lsmod | grep -E 'xe|i915'"
fi

info "Verificando VA-API..."
if vainfo &>/dev/null; then
  success "VA-API disponible."
  vainfo | grep -i "vainfo" | head -2
else
  warn "VA-API no disponible. Verifica con: vainfo"
fi

# ── 9. Resumen ────────────────────────────────────────────────────────────────
section "✅ Base System Setup completo"
echo ""
echo "  Resumen del sistema ($OS_NAME $OS_VERSION):"
echo "    • Repositorios del sistema"
echo "    • Códecs multimedia"
echo "    • VA-API Intel (Hardware video acceleration)"
echo "    • OpenH264"
echo "    • Flatpak + Flathub"
echo "    • Optimizaciones de arranque"
echo ""
echo "  Para reiniciar y aplicar cambios: sudo reboot"
echo ""
