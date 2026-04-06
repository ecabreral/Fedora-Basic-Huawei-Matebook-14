#!/usr/bin/env bash
# ==============================================================================
# 00-base-system.sh
# Configura el sistema base para Fedora en Huawei MateBook 14 (Intel Core Ultra).
# Incluye: Repositorios, códecs, VA-API Intel, Flatpak, optimizaciones.
# ==============================================================================

source "$(dirname "$0")/lib.sh"

section "🗃️ Habilitando RPM Fusion"

if rpm -q rpmfusion-free-release &>/dev/null; then
  success "RPM Fusion Free ya está instalado."
else
  info "Instalando RPM Fusion Free..."
  sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  success "RPM Fusion Free instalado."
fi

if rpm -q rpmfusion-nonfree-release &>/dev/null; then
  success "RPM Fusion Non-Free ya está instalado."
else
  info "Instalando RPM Fusion Non-Free..."
  sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  success "RPM Fusion Non-Free instalado."
fi

info "Configurando repositorios RPM Fusion (deshabilitar rawhide)..."
sudo dnf config-manager --set-disabled rpmfusion-free-rawhide 2>/dev/null || true
sudo dnf config-manager --set-disabled rpmfusion-nonfree-rawhide 2>/dev/null || true
sudo dnf config-manager --set-enabled rpmfusion-free 2>/dev/null || true
sudo dnf config-manager --set-enabled rpmfusion-nonfree 2>/dev/null || true
success "Repositorios RPM Fusion configurados correctamente."

section "📊 Actualizando sistema"

info "Actualizando paquetes del sistema..."
sudo dnf group upgrade -y core
success "Sistema actualizado."

section "📦 Instalando códecs multimedia"

dnf_install \
  ffmpeg \
  ffmpeg-libs \
  gstreamer1-plugins-base \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-ugly \
  gstreamer1-plugins-good-extras \
  gstreamer1-plugins-bad-free-extras

info "Convirtiendo ffmpeg-free a ffmpeg completo..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
success "Códecs multimedia instalados."

section "🎬 VA-API: Aceleración de video por hardware (Intel)"

dnf_install \
  libva \
  libva-utils

if rpm -q intel-media-driver &>/dev/null; then
  success "intel-media-driver ya está instalado."
else
  info "Instalando intel-media-driver..."
  sudo dnf install -y intel-media-driver
  success "intel-media-driver instalado."
fi

if rpm -q libva-intel-media-driver &>/dev/null; then
  info "Removiendo libva-intel-media-driver conflictos..."
  sudo dnf remove -y libva-intel-media-driver
fi

dnf_install libva-intel-driver

section "🦊 OpenH264 para Firefox"

if rpm -q openh264 &>/dev/null; then
  success "OpenH264 ya está instalado."
else
  info "Instalando OpenH264..."
  sudo dnf install -y openh264
  success "OpenH264 instalado."
fi

section "📦 Configurando Flatpak y Flathub"

if command -v flatpak &>/dev/null; then
  if flatpak remote-list | grep -q "flathub"; then
    success "Flathub ya está configurado."
  else
    info "Añadiendo Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub configurado."
  fi
else
  info "Instalando Flatpak..."
  sudo dnf install -y flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  success "Flatpak instalado y Flathub configurado."
fi

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
else
  success "Gnome Software ya no está en autostart."
fi

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

section "✅ Base System Setup completo"
echo ""
echo "  Resume del sistema:"
echo "    • RPM Fusion: Free + Non-Free"
echo "    • Códecs multimedia"
echo "    • VA-API Intel (Hardware video acceleration)"
echo "    • OpenH264"
echo "    • Flatpak + Flathub"
echo "    • Optimizaciones de arranque"
echo ""
echo "  Opcional (solo si necesitas debugging):"
echo "    • sudo dnf install intel-gpu-tools  # Para intel_gpu_top"
echo ""
echo "  Para reiniciar y aplicar cambios: sudo reboot"
echo ""
