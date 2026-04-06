# Fedora Setup - Huawei Matebook 14

Colección de scripts para automatizar la configuración de Fedora Linux orientada a desarrollo, con una experiencia de escritorio GNOME similar a macOS.

## Uso rápido

```bash
./setup.sh
```

---

## Estructura del Proyecto

```
Fedora-Basic-Huawei-Matebook-14/
├── setup.sh                    # Instalador interactivo en consola
├── scripts/
│   ├── lib.sh                  # Librería compartida (colores, helpers)
│   ├── gui-launcher.sh         # Ejecutor de scripts seleccionados
│   ├── 00-base-system.sh       # Sistema base: repositorios, códecs, VA-API, Flatpak
│   ├── 01-terminal.sh          # Terminal moderna: zsh, Starship, eza…
│   ├── 02-vscode.sh            # Visual Studio Code + configuración
│   ├── 03-git.sh               # Git global + clave SSH para GitHub
│   ├── 04-gnome-theme.sh       # Temas GNOME estilo macOS
│   ├── 05-intel-fix.sh         # Fix parpadeo pantalla Intel (opcional)
│   ├── 06-extensions.sh        # Extensiones GNOME
│   ├── 07-opencode.sh          # OpenCode CLI: Asistente de IA para terminal
│   └── cleanup.sh              # Elimina Oh My Zsh (opcional)
├── config/
│   └── starship.toml           # Preset para Starship (sin uso)
└── docs/
    ├── dash-to-dock.md         # Guía de configuración de Dash to Dock
    └── copyous-troubleshooting.md  # Solución de problemas de Copyous
```

---

## Interfaz de Consola (TUI)

El instalador funciona completamente en terminal:

```
╔═══════════════════════════════════════════════════════════════╗
║     Fedora Setup - Huawei Matebook 14                        ║
║     Configuración automatizada en terminal                   ║
╚═══════════════════════════════════════════════════════════════╝

  [1] Instalar TODOS los componentes
  [2] Seleccionar componentes específicos
  [3] Salir

  Escribe el número y presiona ENTER
```

- **Menú interactivo** - Escribe el número y presiona ENTER
- **Selección de componentes** - Toggles con números 1-7, [A] continuar, [Q] salir
- **Selector de tema Starship** - 6 presets disponibles

---

## Componentes

| # | Componente | Descripción |
|---|------------|-------------|
| 0 | Sistema Base | Repositorios (RPM Fusion), códecs, VA-API Intel, Flatpak |
| 1 | Terminal | zsh, Starship (6 temas), eza, bat, fzf, zoxide, fastfetch |
| 2 | VS Code | Editor con configuración optimizada |
| 3 | Git | Configuración global + clave SSH para GitHub |
| 4 | Temas | GTK, Iconos, Shell estilo macOS |
| 5 | Intel Fix | Solución parpadeo pantalla (opcional) |
| 6 | Extensiones | Dash to Dock, Magic Lamp, Night Theme Switcher, Copyous |
| 7 | OpenCode CLI | Asistente de IA para terminal |

---

## Selector de Tema Starship (6 Presets)

| # | Preset | Estilo |
|---|--------|--------|
| 1 | Tokyo Night | Oscuro (recomendado) |
| 2 | Pastel Powerline | Claro |
| 3 | Gruvbox Rainbow | Oscuro |
| 4 | Catppuccin Powerline | Oscuro |
| 5 | Jetpack | Minimalista |
| 6 | Pure Prompt | Clásico |

---

## Características

### 🔄 Ejecución Idempotente

Todos los scripts verifican si un componente ya está instalado antes de proceder:
- Si ya está instalado → Omite la instalación
- Si ya está configurado → Omite la configuración

### 📋 OpenCode PATH Automático

Al final de la instalación, si OpenCode está instalado y funciona, se agrega automáticamente al PATH:
```bash
export PATH="$HOME/.opencode/bin:$PATH"
```

Solo se agrega si el comando `opencode` está disponible en el sistema.

---

## Qué instala cada script

### 0. Sistema Base — `scripts/00-base-system.sh`

| Categoría | Paquetes/Acciones |
|-----------|-------------------|
| **Repositorios** | RPM Fusion Free + Non-Free |
| **Códecs multimedia** | ffmpeg, gstreamer plugins (base, good, bad, ugly) |
| **VA-API Intel** | libva, libva-utils, intel-media-driver, libva-intel-driver |
| **OpenH264** | Para Firefox |
| **Flatpak** | Instalación + Flathub |
| **Optimizaciones** | NetworkManager-wait-online deshabilitado, Gnome Software removido del autostart |

> **Importante**: Este script debe ejecutarse primero (opción 0 o al instalar todos). Esencial para MateBook 14 con Intel Core Ultra.

### 1. Terminal — `scripts/01-terminal.sh`

| Herramienta | Descripción |
|---|---|
| `zsh` + Oh My Zsh | Shell moderna con plugins |
| `starship` | Prompt configurable (6 temas) |
| `eza` | `ls` moderno con iconos y colores |
| `bat` | `cat` con syntax highlighting |
| `fzf` | Búsqueda difusa en terminal |
| `zoxide` | `cd` inteligente con historial |
| `fastfetch` | Info del sistema al abrir terminal |
| `micro` | Editor de texto en terminal |
| `rust` + `cargo` | Toolchain de Rust |
| JetBrainsMono Nerd Font | Fuente con soporte de iconos |

**Aliases configurados en `.zshrc`:**

| Alias | Comando |
|---|---|
| `ls` | `eza --icons=auto` |
| `ll` | `eza -lah --icons --git` |
| `lt` | `eza --tree --icons` |
| `cat` | `bat --paging=never` |
| `cd` | `z` (zoxide) |
| `cls` | `clear` |
| `update` | `sudo dnf update -y && flatpak update -y` |

---

### 2. Visual Studio Code — `scripts/02-vscode.sh`

Instala VS Code desde el repositorio oficial de Microsoft:
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install code
```

- Configura tema, fuente JetBrains Mono con ligaduras
- Configura `formatOnSave`, `autoSave`, minimap desactivado

---

### 3. Git + GitHub — `scripts/03-git.sh`

- Configura nombre, email y rama por defecto (`main`)
- Genera clave SSH **ed25519**
- Copia la clave al portapapeles automáticamente
- Abre `github.com/settings/keys` en el navegador
- Verifica la conexión SSH

---

### 4. Temas GNOME — `scripts/04-gnome-theme.sh`

| Componente | Tema |
|---|---|
| GTK Theme | **WhiteSur-Light** + **WhiteSur-Dark** |
| GNOME Shell | **WhiteSur-Light** |
| Icon Theme | **WhiteSur** |
| GDM | **MacTahoe** |
| Firefox | **WhiteSur Firefox Theme** |

---

### 5. Fix Intel Flicker — `scripts/05-intel-fix.sh`

- Detecta GPU Intel automáticamente
- Aplica parámetros de kernel:
  ```
  i915.enable_psr=0 i915.enable_dc=0 intel_idle.max_cstate=2
  ```
- **Requiere reinicio**

---

## Extensiones GNOME

| Extensión | Descripción |
|---|---|
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/) | Dock estilo macOS |
| [Compiz Alike Magic Lamp Effect](https://github.com/ecabreral/compiz-alike-magic-lamp-effect) | Efecto de lámpara al minimizar |
| [Night Theme Switcher](https://extensions.gnome.org/extension/2236/night-theme-switcher/) | Cambio automático claro/oscuro |
| [Copyous](https://extensions.gnome.org/extension/8834/copyous/) | Historial de portapapeles |

---

## OpenCode CLI — `scripts/07-opencode.sh`

Instala el intérprete de IA **OpenCode** para usar directamente desde la terminal.

---

## Requisitos

- **Fedora 43/44** con **GNOME**
- Ninguna dependencia adicional requerida (todo funciona en consola)

---

## Notas

- Probado en **Fedora 43 y 44** con **GNOME**
- `setup.sh` detecta automáticamente si hay GPU Intel y omite el fix si no aplica
- Todos los scripts son **idempotentes**
- El PATH de OpenCode se agrega automáticamente solo si está instalado

---

## Licencia

MIT