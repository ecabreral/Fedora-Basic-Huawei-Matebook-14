# Fedora Basic Setup - Huawei Matebook 14

Script de instalación automatizada para Fedora/Ubuntu con interfaz whiptail.

## Uso Rápido

```bash
# Instalación interactiva (menú whiptail)
./setup.sh

# Instalación con flags
./setup.sh --component base terminal vscode --theme tokyo-night

# Ver qué haría sin ejecutar
./setup.sh --dry-run

# Desinstalar componentes
./setup.sh --uninstall

# Ayuda
./setup.sh --help
```

## Componentes

| Componente | Descripción |
|-----------|-------------|
| `base` | Paquetes base del sistema (curl, git, htop, etc.) |
| `terminal` | Configuración de terminal + Starship + Nerd Fonts |
| `vscode` | Visual Studio Code |
| `git` | Git + SSH + GitHub CLI |
| `theme` | Temas GNOME (Colloid, Dracula, etc.) |
| `extensions` | Extensiones GNOME (Tiling, GSConnect, etc.) |
| `icons` | Iconos (Colloid, Papirus, etc.) |
| `intel` | Drivers Intel Arc |
| `brave` | Brave Browser |
| `spotify` | Spotify |
| `opencode` | OpenCode CLI |

## Temas Disponibles

- `tokyo-night`, `pastel-powerline`, `gruvbox-rainbow`, `catppuccin-powerline`
- `jetpack`, `pure-preset`, `nerd-font-symbols`, `no-nerd-font`
- `bracketed-segments`, `plain-text`, `no-runtimes`, `no-empty-icons`
- `cyberpunk-storm`, `cyberpunk-neon`, `cyberpunk-night`

## Estructura

```
├── setup.sh              # Entry point principal
├── lib/
│   ├── common.sh         # Funciones compartidas
│   ├── logger.sh         # Logging con timestamps
│   └── gnome-terminal-colors.sh  # Colores GNOME Terminal
├── scripts/
│   ├── runner.sh         # Orquestador de scripts
│   ├── 01-system/        # Configuración del sistema
│   ├── 02-terminal/      # Terminal y temas
│   ├── 03-development/   # Desarrollo (VS Code, Git)
│   ├── 04-desktop/       # GNOME themes/extensions
│   ├── 05-media/         # Codecs multimedia
│   └── 06-apps/          # Aplicaciones (Brave, Spotify, OpenCode)
└── config/
    └── starship/         # Temas Starship personalizados
```

## Requisitos

- Fedora 40+ o Ubuntu 22.04+
- Conexión a internet
- Permisos sudo

## Logs

Los logs se guardan en `scripts/logs/` con rotación automática (máx 5 archivos, 1MB cada uno).
