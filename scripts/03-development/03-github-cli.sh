#!/usr/bin/env bash
# ==============================================================================
# 03-github-cli.sh — Instala GitHub CLI (gh) en Fedora o Ubuntu
# ==============================================================================

set -e
source "$(dirname "$0")/../../lib/common.sh"

section "🐙 GitHub CLI (gh)"

# 1. Verificar si ya está instalado
if command -v gh &>/dev/null; then
    success "GitHub CLI ya está instalado: $(gh --version | head -1)"
else
    if is_fedora; then
        # ── Fedora: repositorios oficiales ──────────────────────────────────────
        info "Instalando GitHub CLI desde repositorios de Fedora..."
        sudo dnf install -y gh
    elif is_ubuntu; then
        # ── Ubuntu: repositorio oficial de GitHub CLI ───────────────────────────
        info "Agregando repositorio oficial de GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
            sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo DEBIAN_FRONTEND=noninteractive apt install -y gh
    fi

    if command -v gh &>/dev/null; then
        success "GitHub CLI instalado: $(gh --version | head -1)"
    else
        error "No se pudo instalar GitHub CLI."
        exit 1
    fi
fi

# 2. Sugerencia de autenticación
echo ""
info "Para autenticarte con GitHub ejecuta: gh auth login"
