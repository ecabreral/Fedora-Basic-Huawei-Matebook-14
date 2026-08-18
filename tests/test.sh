#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

passed=0
failed=0

assert() {
    local name="$1"
    shift
    if "$@"; then
        printf 'ok - %s\n' "$name"
        passed=$((passed + 1))
    else
        printf 'not ok - %s\n' "$name" >&2
        failed=$((failed + 1))
    fi
}

assert_component_catalog() {
    [ "${#COMPONENTS[@]}" -eq 13 ] &&
        component_exists spotify &&
        [ "$(component_category vscode)" = development ] &&
        [ "$(component_dependencies spotify)" = base ]
}

assert_platform_detection() {
    is_fedora || is_ubuntu
}

assert_user_context() {
    [ -n "$INSTALL_USER" ] && [ -n "$INSTALL_USER_HOME" ] &&
        [ "$(user_path .config)" = "$INSTALL_USER_HOME/.config" ]
}

assert "catálogo y dependencias" assert_component_catalog
assert "detección de plataforma" assert_platform_detection
assert "contexto de usuario" assert_user_context

if [ "$failed" -gt 0 ]; then
    printf '%s\n' "$failed pruebas fallaron." >&2
    exit 1
fi
printf '%s\n' "$passed pruebas pasaron."
