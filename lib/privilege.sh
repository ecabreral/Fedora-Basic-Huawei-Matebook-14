#!/usr/bin/env bash
# Mantiene separadas las operaciones del sistema y las del usuario real.

INSTALL_USER="${SUDO_USER:-${USER:-$(id -un)}}"
INSTALL_USER_HOME="${HOME}"

if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
  INSTALL_USER_HOME="$(getent passwd "$INSTALL_USER" | cut -d: -f6)"
fi

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

run_as_user() {
  if [ "$(id -un)" = "$INSTALL_USER" ]; then
    HOME="$INSTALL_USER_HOME" USER="$INSTALL_USER" "$@"
  else
    sudo -H -u "$INSTALL_USER" env HOME="$INSTALL_USER_HOME" USER="$INSTALL_USER" "$@"
  fi
}

user_path() {
  printf '%s/%s\n' "$INSTALL_USER_HOME" "$1"
}
