#!/usr/bin/env bash
# ==============================================================================
# 03-github-cli.sh — Instala GitHub CLI (gh) en Fedora o Ubuntu
# ==============================================================================

# No usar set -e: los pasos de red y escritura en /etc se reportan por separado.
source "$(dirname "$0")/../../lib/common.sh"

section "🐙 GitHub CLI (gh)"

# 1. Verificar si ya está instalado
if command -v gh &>/dev/null; then
    success "GitHub CLI ya está instalado: $(gh --version | head -1)"
else
    if is_fedora; then
        # ── Fedora: repositorios oficiales ──────────────────────────────────────
        info "Instalando GitHub CLI desde repositorios de Fedora..."
        if ! sudo dnf install -y gh; then
            error "No se pudo instalar GitHub CLI."
            exit 1
        fi
    elif is_ubuntu; then
        # ── Ubuntu: repositorio oficial de GitHub CLI ───────────────────────────
        GH_KEYRING=/usr/share/keyrings/githubcli-archive-keyring.gpg
        GH_LIST=/etc/apt/sources.list.d/github-cli.list

        # Idempotente: solo configurar si falta el keyring o la lista de sources.
        if [ ! -f "$GH_KEYRING" ]; then
            info "Descargando llave de GitHub CLI..."
            GH_TMP=/tmp/githubcli-keyring.gpg
            if secure_fetch "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
                "$GH_TMP" "llave de GitHub CLI"; then
                # Descargar a archivo y luego copiar: escribir directamente con
                # "curl | sudo dd" deja un keyring corrupto si curl se corta.
                sudo install -o root -g root -m 644 "$GH_TMP" "$GH_KEYRING"
                rm -f "$GH_TMP"
                success "Llave instalada."
            else
                error "No se pudo obtener la llave de GitHub CLI. Abortando."
                exit 1
            fi
        else
            success "Llave de GitHub CLI ya instalada."
        fi

        if [ ! -f "$GH_LIST" ] || ! grep -q "cli.github.com/packages" "$GH_LIST"; then
            info "Agregando repositorio oficial de GitHub CLI..."
            echo "deb [arch=$(dpkg --print-architecture) signed-by=$GH_KEYRING] https://cli.github.com/packages stable main" \
                | sudo tee "$GH_LIST" > /dev/null
        else
            success "Repositorio de GitHub CLI ya configurado."
        fi

        sudo apt update
        if ! sudo DEBIAN_FRONTEND=noninteractive apt install -y gh; then
            error "No se pudo instalar GitHub CLI."
            exit 1
        fi
    fi

    if command -v gh &>/dev/null; then
        success "GitHub CLI instalado: $(gh --version | head -1)"
    else
        error "No se pudo instalar GitHub CLI."
        exit 1
    fi
fi

# 2. Autenticación y configuración de git
echo ""
if gh auth status &>/dev/null; then
    info "Configurando gh como credential helper de git..."
    if gh auth setup-git &>/dev/null; then
        success "git usará gh para autenticarse (repos privados por HTTPS funcionan sin pedir usuario)."
    else
        warn "No se pudo configurar el credential helper. Ejecuta: gh auth setup-git"
    fi
else
    info "Para autenticarte con GitHub ejecuta: gh auth login"
    info "Después, habilita el credential helper con: gh auth setup-git"
fi
