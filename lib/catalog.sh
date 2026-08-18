#!/usr/bin/env bash
# Catálogo central de componentes y sus metadatos.

COMPONENTS=(base terminal vscode git gh theme extensions icons intel brave chrome spotify opencode)
THEMES=(tokyo-night pastel-powerline gruvbox-rainbow catppuccin-powerline jetpack pure-preset cyberpunk-storm cyberpunk-neon cyberpunk-night)

all_components() { printf '%s\n' "${COMPONENTS[*]}"; }

component_label() {
  case "$1" in
    base) echo "Sistema Base" ;;
    terminal) echo "Terminal y herramientas" ;;
    vscode) echo "Visual Studio Code" ;;
    git) echo "Git + SSH" ;;
    gh) echo "GitHub CLI" ;;
    theme) echo "Temas GNOME" ;;
    extensions) echo "Extensiones GNOME" ;;
    icons) echo "Iconos GNOME" ;;
    intel) echo "Corrección de parpadeo Intel" ;;
    brave) echo "Brave Browser" ;;
    chrome) echo "Google Chrome" ;;
    spotify) echo "Spotify" ;;
    opencode) echo "OpenCode CLI" ;;
    *) return 1 ;;
  esac
}

component_category() {
  case "$1" in
    base) echo system ;;
    terminal) echo terminal ;;
    vscode|git|gh|opencode) echo development ;;
    theme|extensions|icons) echo desktop ;;
    intel) echo hardware ;;
    brave|chrome) echo browsers ;;
    spotify) echo multimedia ;;
    *) return 1 ;;
  esac
}

component_dependencies() {
  case "$1" in
    terminal|vscode|git|gh|theme|extensions|icons|intel|brave|chrome|spotify|opencode) echo base ;;
    *) : ;;
  esac
}

component_requires_root() {
  case "$1" in
    base|vscode|intel|brave|chrome) return 0 ;;
    *) return 1 ;;
  esac
}

component_exists() {
  local component
  for component in "${COMPONENTS[@]}"; do
    [ "$component" = "$1" ] && return 0
  done
  return 1
}

component_status() {
  case "$1" in
    base)
      if is_fedora; then
        [ -f /etc/yum.repos.d/rpmfusion-free.repo ] && command -v flatpak >/dev/null 2>&1
      else
        pkg_check ubuntu-restricted-extras 2>/dev/null || pkg_check flatpak 2>/dev/null
      fi ;;
    terminal) command -v zsh >/dev/null 2>&1 && command -v starship >/dev/null 2>&1 ;;
    vscode) command -v code >/dev/null 2>&1 ;;
    git) command -v git >/dev/null 2>&1 ;;
    gh) command -v gh >/dev/null 2>&1 ;;
    theme) [ -d "$(user_path .themes)" ] || gsettings get org.gnome.desktop.interface gtk-theme >/dev/null 2>&1 ;;
    extensions) command -v gnome-extensions >/dev/null 2>&1 ;;
    icons) [ -d "$(user_path .local/share/icons)" ] && [ "$(printf '%s' "$(user_path .local/share/icons)"/* 2>/dev/null)" != "$(user_path .local/share/icons)/*" ] ;;
    intel) grep -Eq 'i915|intel_idle' /etc/default/grub 2>/dev/null ;;
    brave) command -v brave-browser >/dev/null 2>&1 || command -v brave >/dev/null 2>&1 ;;
    chrome) command -v google-chrome >/dev/null 2>&1 || command -v google-chrome-stable >/dev/null 2>&1 ;;
    spotify) command -v flatpak >/dev/null 2>&1 && flatpak info com.spotify.Client >/dev/null 2>&1 ;;
    opencode) command -v opencode >/dev/null 2>&1 || [ -x "$(user_path .opencode/bin/opencode)" ] ;;
    *) return 1 ;;
  esac
}
