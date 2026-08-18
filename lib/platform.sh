#!/usr/bin/env bash
# Adaptadores de plataforma. Los componentes deben usar estas funciones en vez
# de invocar directamente dnf o apt.

platform_is_supported() {
  is_fedora || is_ubuntu
}

platform_package_manager() {
  if is_fedora; then
    printf '%s\n' dnf
  elif is_ubuntu; then
    printf '%s\n' apt
  else
    return 1
  fi
}

platform_install_packages() {
  pkg_install "$@"
}

platform_remove_packages() {
  local packages=() package
  for package in "$@"; do
    pkg_check "$package" && packages+=("$package")
  done
  [ "${#packages[@]}" -eq 0 ] && return 0

  if is_fedora; then
    sudo dnf remove -y "${packages[@]}"
  elif is_ubuntu; then
    sudo DEBIAN_FRONTEND=noninteractive apt remove -y "${packages[@]}"
  fi
}

platform_update() {
  pkg_update
}

platform_install_flatpak() {
  if ! command -v flatpak >/dev/null 2>&1; then
    platform_install_packages flatpak
  fi
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

platform_install_flatpak_app() {
  local app_id="$1"
  platform_install_flatpak
  flatpak install -y flathub "$app_id"
}
