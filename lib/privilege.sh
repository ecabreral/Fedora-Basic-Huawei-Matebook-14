#!/usr/bin/env bash
# ==============================================================================
# privilege.sh — Contexto de privilegios y del usuario real
#
# Los scripts que el runner lanza con sudo ven $HOME=/root, lo que hace que
# cualquier ajuste de sesión (autostart, configuración de apps) acabe en el
# home equivocado. Este módulo centraliza la resolución del usuario real.
#
# Uso: source "$(dirname "$0")/../../lib/privilege.sh"
# ==============================================================================

# Evita recarga en el mismo proceso.
[ -n "${_PRIVILEGE_LOADED:-}" ] && return 0
_PRIVILEGE_LOADED=1

# ── Usuario real: quien lanzó el proceso, no quien lo ejecuta con sudo ───────
INSTALL_USER="${SUDO_USER:-${USER:-$(id -un)}}"

# Sin sudo, $HOME ya es el del usuario. Con sudo hay que consultarlo: puede no
# ser /home/<user> (Fedora Silverblue usa /var/home), y asumirlo rompe rutas.
INSTALL_USER_HOME="$HOME"
if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    _resolved_home=$(getent passwd "$INSTALL_USER" 2>/dev/null | cut -d: -f6)
    [ -n "$_resolved_home" ] && INSTALL_USER_HOME="$_resolved_home"
    unset _resolved_home
fi

# ── run_as_user: Ejecuta un comando como el usuario real ─────────────────────
# Ajusta HOME y USER para que las apps no escriban en /root.
run_as_user() {
    if [ "$(id -un)" = "$INSTALL_USER" ]; then
        HOME="$INSTALL_USER_HOME" USER="$INSTALL_USER" "$@"
    else
        sudo -H -u "$INSTALL_USER" env HOME="$INSTALL_USER_HOME" USER="$INSTALL_USER" "$@"
    fi
}

# ── run_as_root: Ejecuta un comando como root, con o sin sudo ─────────────────
# Evita tener que comprobar [ "$(id -u)" -eq 0 ] en cada llamada.
run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# ── user_path: Construye una ruta bajo el home del usuario real ───────────────
user_path() {
    printf '%s/%s\n' "$INSTALL_USER_HOME" "$1"
}
