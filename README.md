# Fedora Setup - Huawei Matebook 14

Colección de scripts para automatizar la configuración de Fedora Linux orientada a desarrollo, con una experiencia de escritorio GNOME similar a macOS.

## Uso rápido

```bash
./fedora-setup
# o
./setup.sh
```

> 🚀 **Novedad**: Ahora cuenta con una **interfaz gráfica profesional en Python** y **Zenity**. Al ejecutar `./fedora-setup` se abrirá una GUI donde podrás navegar por los componentes, seleccionar opciones e instalar con progreso en tiempo real. También puedes elegir el **tema de Starship** que más te guste (12 presets disponibles).

---

## Estructura del Proyecto

```
Fedora-Basic-Huawei-Matebook-14/
├── fedora-setup                 # ▶ Punto de entrada ejecutable
├── setup.sh                    # Script principal
├── main.py                     # Entry point de la GUI Python
├── gui/                        # Módulo de GUI profesional
│   ├── app.py                  # Ventana principal
│   ├── theme.py                # Sistema de temas (tokens de diseño)
│   └── widgets/                # Componentes reutilizables
│       ├── button.py           # Botones estilizados
│       ├── card.py             # Tarjetas
│       ├── console.py          # Consola de salida
│       └── progress.py         # Progress bar
├── scripts/
│   ├── lib.sh                  # Librería compartida (colores, helpers)
│   ├── gui-launcher.sh         # Ejecutor de scripts seleccionados
│   ├── 01-terminal.sh          # Terminal moderna: zsh, Starship, eza…
│   ├── 02-vscode.sh            # Visual Studio Code + configuración
│   ├── 03-git.sh               # Git global + clave SSH para GitHub
│   ├── 04-gnome-theme.sh       # Temas GNOME estilo macOS
│   ├── 05-intel-fix.sh         # Fix parpadeo pantalla Intel (opcional)
│   ├── 06-extensions.sh        # Extensiones GNOME
│   ├── 07-opencode.sh          # OpenCode CLI: Asistente de IA para terminal
│   └── cleanup.sh              # Elimina Oh My Zsh (opcional)
├── config/
│   └── starship.toml           # Preset Pastel Powerline para Starship
└── docs/
    ├── dash-to-dock.md         # Guía de configuración de Dash to Dock
    └── copyous-troubleshooting.md  # Solución de problemas de Copyous
```

---

## Características Principales

### 🎨 Selector de Tema Starship (12 Presets)

Al instalar la Terminal, puedes elegir entre **12 temas diferentes** para Starship:

| # | Preset | Estilo | Descripción |
|---|--------|--------|-------------|
| 1 | Tokyo Night | Oscuro | Inspirado en tokyo-night-vscode-theme |
| 2 | Pastel Powerline | Claro | Inspirado en M365Princess |
| 3 | Gruvbox Rainbow | Oscuro | Colores warm estilo retro |
| 4 | Catppuccin Powerline | Oscuro | Paleta Catppuccin minimalista |
| 5 | Jetpack | Minimalista | Inspirado en geometry/spaceship |
| 6 | Pure Prompt | Clásico | Emula el look de Pure |
| 7 | Nerd Font Symbols | Símbolos | Usa símbolos Nerd Font |
| 8 | No Nerd Font | Sin símbolos | No usa Nerd Font |
| 9 | Bracketed Segments | Formato | Segmentos entre paréntesis |
| 10 | Plain Text | Texto | Solo texto plano |
| 11 | No Runtime Versions | Utilidad | Oculta versiones de runtime |
| 12 | No Empty Icons | Utilidad | No muestra iconos vacíos |

**El selector aparece automáticamente** al elegir "Terminal Moderna" en:
- **GUI Python**: RadioButtons para seleccionar tema
- **GUI Zenity**: Lista de selección con `--hide-column=2`

---

### 🔄 Ejecución Idempotente

Todos los scripts verifican si un componente ya está instalado antes de proceder:
- Si ya está instalado → Omite la instalación
- Si ya está configurado → Omite la configuración
- Permite ejecutar múltiples veces sin efectos secundarios

---

### 📋 OpenCode PATH Automático

Al final de cada instalación, automáticamente se agrega OpenCode al PATH:
```bash
export PATH="$HOME/.opencode/bin:$PATH"
```
Se ejecuta `source ~/.zshrc` para que esté disponible inmediatamente.

---

## Qué instala cada script

### 1. Terminal — `scripts/01-terminal.sh`

| Herramienta | Descripción |
|---|---|
| `zsh` + Oh My Zsh | Shell moderna con plugins |
| `starship` | Prompt configurable (12 temas) |
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

**INSTALAR VS CODE CORRECTAMENTE EN FEDORA**

Método recomendado (OFICIAL Microsoft):

1. Agregar repo de Microsoft:
   ```bash
   sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
   sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
   ```
2. Instalar:
   ```bash
   sudo dnf check-update
   sudo dnf install code
   ```
✔️ Este es el método oficial para Fedora.

- El script también corrige permisos de `~/.config/Code` y `~/.vscode` para evitar problemas de propiedad.
- Configura automáticamente `~/.config/Code/User/settings.json`:
  - Tema claro → **GitHub Light** | oscuro → **GitHub Dark** (auto según el sistema)
  - Fuente: **JetBrains Mono** con ligaduras, tamaño 14
  - `formatOnSave`, `autoSave afterDelay`, minimap desactivado
  - Icon theme: `vs-seti`

---

### 3. Git + GitHub — `scripts/03-git.sh`

- Configura nombre, email y rama por defecto (`main`)
- Configura `pull.rebase false` y `core.autocrlf input`
- Genera clave SSH **ed25519**
- Copia la clave al portapapeles automáticamente (`wl-copy` o `xclip`)
- Abre `github.com/settings/keys` en el navegador
- Verifica la conexión SSH al final

---

### 4. Temas GNOME — `scripts/04-gnome-theme.sh`

Instala **GNOME Tweaks** y **GNOME Extensions** para gestionar temas y extensiones fácilmente.

| Componente | Tema |
|---|---|
| GTK Theme | **WhiteSur-Light** + **WhiteSur-Dark** |
| GNOME Shell | **WhiteSur-Light** |
| Icon Theme | **WhiteSur** |
| GDM (pantalla de login) | **MacTahoe** |
| Firefox | **WhiteSur Firefox Theme** |
| Cursores | Adwaita |
| MacTahoe Icons | Instalado (no activo por defecto) |

El cambio automático claro↔oscuro se gestiona con **Night Theme Switcher**.

---

### 5. Fix Intel Flicker — `scripts/05-intel-fix.sh`

- Detecta GPU Intel automáticamente (se omite si no se detecta)
- Aplica parámetros de kernel via `grubby`:
  ```
  i915.enable_psr=0   i915.enable_dc=0   intel_idle.max_cstate=2
  ```
- **Requiere reinicio** para tener efecto

---

## Extensiones GNOME

| Extensión | Descripción |
|---|---|
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/) | Dock estilo macOS |
| [Compiz Alike Magic Lamp Effect](https://github.com/ecabreral/compiz-alike-magic-lamp-effect) | Efecto de lámpara al minimizar |
| [Night Theme Switcher](https://extensions.gnome.org/extension/2236/night-theme-switcher/) | Cambio automático claro/oscuro |
| [Copyous](https://extensions.gnome.org/extension/8834/copyous/) | Historial de portapapeles |

---

### 7. OpenCode CLI — `scripts/07-opencode.sh`

Instala el intérprete de IA **OpenCode** para usar directamente desde la terminal.

- Utiliza el instalador oficial de `opencode.ai`.
- Configura automáticamente el PATH en `~/.zshrc`.
- Permite ejecutar comandos de lenguaje natural mediante el comando `opencode`.

---

## Limpieza opcional — `scripts/cleanup.sh`

Elimina Oh My Zsh y carga los plugins de Zsh directamente (más ligero). Starship sigue funcionando como prompt.

```bash
./scripts/cleanup.sh
```

> Oh My Zsh es liviano y no interfiere con Starship. Este paso es completamente opcional.

---

## Requisitos

- **Python 3.10+** (para la GUI)
- **Zenity** (fallback si la GUI Python no está disponible)

La GUI se inicia automáticamente. Si Python no está instalado, el script intentará usar Zenity como alternativa.

---

## Interfaz Gráfica

La aplicación incluye dos interfaces gráfica:

### 1. GUI Python (Principal)

- **Tema oscuro** con tokens de diseño Fedora (#60b0f4 accent)
- **Navegación por sidebar** para explorar componentes
- **Selector de tema Starship** con 12 opciones
- **Consola en tiempo real** que muestra el output de la instalación
- **Progress bar animada** con progreso en vivo
- **Ejecución en background thread** para no bloquear la UI

### 2. GUI Zenity (Fallback)

- Selector de componentes con checkboxes
- **Selector de tema Starship** con 12 opciones
- Ejecución en terminal separada

### Capturas de pantalla

La GUI incluye las siguientes páginas:
- **Inicio**: Información general del proyecto
- **Terminal**: Instalación de zsh, Starship (12 temas), eza, bat, fzf, zoxide
- **VS Code**: Editor configurado con extensiones
- **Git**: SSH keys para GitHub
- **Tema**: Apariencia estilo macOS
- **Intel Fix**: Solución al parpadeo de pantalla
- **Extensiones**: GNOME extensions
- **OpenCode CLI**: Instalación del asistente de IA

---

## Notas

- Probado en **Fedora 43** con **GNOME**
- `setup.sh` detecta automáticamente si hay GPU Intel y omite el fix si no aplica
- Todos los scripts son **idempotentes**: verifican si cada componente ya está instalado antes de instalar
- El PATH de OpenCode se agrega automáticamente al final de la instalación
- `scripts/lib.sh` es la librería compartida usada por todos los scripts
- El log de instalación se guarda en `install.log` para revisión

---

## Tecnologías

| Componente | Tecnología |
|------------|-------------|
| GUI | Python 3 + tkinter |
| Instalador | Bash scripts |
| Temas | GTK, GNOME Shell |
| Terminal | zsh + Starship |

---

## Licencia

MIT
