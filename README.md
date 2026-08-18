# Fedora Basic Setup — Huawei MateBook 14

Script de post-instalación automatizada para **Fedora** (con soporte parcial de **Ubuntu**), diseñado para el Huawei MateBook 14 pero utilizable en cualquier equipo con GPU Intel.

Menú interactivo (whiptail), instalación por componentes, modo CLI no interactivo, logging completo y modos de desinstalación.

---

## Requisitos

- Fedora 40+ (recomendado) o Ubuntu 22.04+
- Conexión a internet
- Permisos sudo (se piden solo cuando un componente lo necesita)
- `whiptail` (se instala automáticamente si falta)

---

## Uso

```bash
chmod +x setup.sh

# Instalación interactiva (menú whiptail)
./setup.sh

# Instalación no interactiva por componentes
./setup.sh --component base terminal vscode git --theme tokyo-night

# Ver qué se ejecutaría sin instalar nada
./setup.sh --dry-run --component base terminal

# Desinstalación interactiva de componentes
./setup.sh --uninstall

# Ayuda
./setup.sh --help
```

### Flags

| Flag | Descripción |
|------|-------------|
| `--component <nombres>` | Instala componentes específicos separados por espacio |
| `--theme <nombre>` | Tema de terminal (solo aplica si se instala `terminal`) |
| `--dry-run` | Muestra qué haría sin ejecutar nada |
| `--uninstall` | Menú de desinstalación de componentes |
| `--help`, `-h` | Ayuda |

### Menú interactivo

```
1) Instalar TODOS los componentes
2) Seleccionar componentes específicos   (sub-menús por categoría, checklist con toggle para agregar/quitar, contador de seleccionados, "Ver selección actual" y "Limpiar selección")
3) Cambiar tema de terminal              (Starship + Ptyxis sin reinstalar)
4) Desinstalar terminal alternativa      (Kitty / Alacritty)
5) Salir
```

La opción 2 organiza los componentes en 7 categorías (Sistema, Terminal, Desarrollo, Navegadores, Multimedia, Escritorio GNOME, Hardware) más atajos para seleccionar TODO o continuar.

---

## Componentes

| ID | Componente | Qué hace |
|----|-----------|----------|
| `base` | Sistema Base | Habilita **RPM Fusion** (Free/Non-Free), actualiza el sistema, instala **códecs multimedia** (ffmpeg completo con swap de `ffmpeg-free`, GStreamer good/bad/ugly/extras), **VA-API Intel** (`intel-media-driver`, `libva`), **OpenH264** para Firefox, configura **Flatpak + Flathub** y aplica **optimizaciones de arranque** (deshabilita `NetworkManager-wait-online`, quita GNOME Software del autostart). Verifica driver Intel (xe/i915) y VA-API al final. |
| `terminal` | Terminal Pro | Instala Ptyxis, zsh, Oh My Zsh + plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`), **Starship**, `eza`, `fastfetch`, `fzf`, `bat`, `zoxide`, `micro`, JetBrainsMono **Nerd Font**. Genera `.zshrc` con aliases modernos (`ls`→eza, `cat`→bat, `cd`→zoxide, `update`), aplica el tema elegido a Starship y Ptyxis, cambia la shell por defecto a zsh y establece Ptyxis como terminal por defecto de GNOME. |
| `vscode` | VS Code | Instala **Visual Studio Code** desde el repositorio oficial de Microsoft (RPM en Fedora / apt en Ubuntu). Crea `settings.json` si no existe (temas GitHub Light/Dark auto, JetBrains Mono, ligaduras, formatOnSave, autoSave, minimap off). Respeta configuración existente. |
| `git` | Git + GitHub | Configura `user.name`/`user.email`, rama por defecto `main`, genera clave **SSH ed25519**, la carga en ssh-agent, la copia al portapapeles y guía paso a paso para añadirla a GitHub. Prueba la conexión con `ssh -T git@github.com`. |
| `gh` | GitHub CLI | Instala **`gh`** (dnf en Fedora / repositorio oficial de GitHub CLI en Ubuntu). Desinstalable desde `--uninstall`. Autenticación posterior con `gh auth login`. |
| `theme` | Temas GNOME | Instala apariencia estilo macOS: **WhiteSur GTK** (Light + Dark), iconos **WhiteSur**, tema **MacTahoe** para GTK y GDM (pantalla de login), **WhiteSur Firefox Theme**. Activa la extensión User Themes, aplica modo claro por defecto con botones a la izquierda (`close,minimize,maximize:`) e instala un **script de sincronización automática claro/oscuro** en `~/.local/bin/whitesur-theme-sync.sh` + autostart, que mantiene sincronizados GTK y GNOME Shell al cambiar el modo de color. |
| `extensions` | Extensiones GNOME | Instala 13 extensiones: Dash to Dock, Magic Lamp Effect, Copyous, Night Theme Switcher, Dynamic Music Pill, Coverflow Alt-Tab, Burn My Windows, Tiling Shell, Desktop Cube, Alphabetical App Grid, Custom Hot Corners Extended, TopHat y Media Controls. Abre las páginas de extensions.gnome.org para activarlas en el navegador. |
| `icons` | Iconos GNOME | Menú interactivo para instalar uno o varios de: **WhiteSur** (macOS), **McMojave-circle**, **Tela-circle**, **Papirus**, **BeautyLine**. Permite elegir el tema activo al final. Cambiable después con `gnome-tweaks`. |
| `intel` | Fix Screen Flicker | Corrige el **parpadeo de pantalla** en GPUs Intel aplicando parámetros de kernel: `i915.enable_psr=0 i915.enable_dc=0 intel_idle.max_cstate=2` (con `grubby` en Fedora o editando GRUB en Ubuntu). Detecta GPU Intel y pide confirmación si no la encuentra. **Requiere reinicio.** |
| `brave` | Brave Browser | Instala desde el instalador oficial de Brave y añade el alias **`bravefix`** a `~/.zshrc` para desbloquear el navegador cuando queda con perfil bloqueado (Singleton). |
| `chrome` | Google Chrome | Agrega el repositorio RPM oficial de Google e instala `google-chrome-stable`. |
| `spotify` | Spotify | Instala el cliente desde **Flathub** y aplica `flatpak override` para habilitar los botones de minimizar/maximizar. |
| `opencode` | OpenCode CLI | Instala el asistente de IA **OpenCode** en `~/.opencode/bin` (instalador oficial, sin modificar PATH global) y configura el PATH en `~/.zshrc` de forma idempotente. |

> En modo "instalar TODO" se incluyen todos los anteriores (incluido `chrome`).

---

## Temas de terminal

Disponibles para Starship + Ptyxis (paleta de colores sincronizada):

| Tema | Estilo |
|------|--------|
| `tokyo-night` | Oscuro azulado (recomendado) |
| `pastel-powerline` | Claro pastel |
| `gruvbox-rainbow` | Oscuro cálido |
| `catppuccin-powerline` | Oscuro pastel |
| `jetpack` | Minimalista |
| `pure-preset` | Clásico |
| `cyberpunk-storm` | Neón intenso (TOML propio) |
| `cyberpunk-neon` | Máxima saturación (TOML propio) |
| `cyberpunk-night` | Sutil elegante (TOML propio) |

Los temas cyberpunk viven en `config/starship/`; el resto son presets oficiales de Starship.

Para cambiar el tema después de instalar: `./setup.sh` → opción **3**, o directamente:

```bash
./scripts/02-terminal/02-change-theme.sh
```

Los cambios respaldan automáticamente `starship.toml` y la paleta anteriores.

---

## Desinstalación

```bash
./setup.sh --uninstall
```

Permite desinstalar (checklist): VS Code, Brave, Chrome, Spotify, Starship, Oh My Zsh (restaura `.zshrc.pre-oh-my-zsh`), Extensiones GNOME (deshabilita), Temas e Iconos (resetea gsettings sin borrar archivos personales) y OpenCode.

Además, el menú principal (opción 4) permite desinstalar terminales alternativas (Kitty/Alacritty) y restaurar Ptyxis como terminal por defecto.

---

## Logging

- Cada ejecución crea `logs/install-<YYYYMMDD>-<HHMMSS>.log` y un symlink `logs/install.log` al más reciente.
- El log es **texto plano** (sin códigos ANSI), con timestamps para los eventos del orquestador.
- Al final se escribe un **RESUMEN FINAL** con éxitos/errores por componente y duración total.
- Rotación automática: se conservan máximo **5 logs** y se eliminan los que excedan **1MB**.
- `logs/` está en `.gitignore`.

---

## Estructura

```
├── setup.sh                          # Entry point: menús, flags CLI, desinstalación
├── lib/
│   ├── common.sh                     # Funciones compartidas (pkg_install, OS detect, open_url...)
│   ├── logger.sh                     # Logging con timestamps, rotación y herencia runner→hijos
│   ├── ptyxis-colors.sh              # Paletas de Ptyxis por tema
│   └── gnome-terminal-colors.sh      # Colores GNOME Terminal (legado)
├── scripts/
│   ├── runner.sh                     # Orquestador: ejecuta componentes con logging y resumen
│   ├── 01-system/
│   │   └── 01-base-system.sh         # Repos, códecs, VA-API, Flatpak, optimizaciones
│   ├── 02-terminal/
│   │   ├── 01-terminal-setup.sh      # Ptyxis, zsh, Oh My Zsh, Starship, .zshrc
│   │   └── 02-change-theme.sh        # Cambio de tema en caliente
│   ├── 03-development/
│   │   ├── 01-vscode.sh              # VS Code + settings.json
│   │   ├── 02-git-ssh.sh             # Git config + clave SSH + GitHub
│   │   └── 03-github-cli.sh          # GitHub CLI (gh)
│   ├── 04-desktop/
│   │   ├── 01-gnome-theme.sh         # WhiteSur/MacTahoe + sync claro/oscuro
│   │   ├── 02-gnome-extensions.sh    # 13 extensiones GNOME
│   │   └── 03-gnome-icons.sh         # 5 packs de iconos
│   ├── 05-hardware/
│   │   └── 01-intel-fix.sh           # Fix parpadeo pantalla (kernel params)
│   └── 06-apps/
│       ├── 01-opencode.sh            # OpenCode CLI
│       ├── 02-spotify.sh             # Spotify (Flathub)
│       ├── 03-brave.sh               # Brave + alias bravefix
│       └── 04-chrome.sh              # Google Chrome
└── config/
    └── starship/                     # Temas Starship personalizados (cyberpunk)
```

---

## Después de instalar

1. `source ~/.zshrc` (o abre una nueva terminal) para activar zsh, aliases y Starship.
2. **Cierra sesión y vuelve a entrar** si instalaste temas GNOME (recarga GTK4/libadwaita).
3. **Reinicia** (`sudo reboot`) si instalaste `base` o `intel` (VA-API y parámetros de kernel).

## Atajos y aliases generados

| Alias | Acción |
|-------|--------|
| `ls` / `ll` / `lt` | `eza` con iconos, detalles y árbol |
| `cat` | `bat` (sin paginar) |
| `cd` | `zoxide` (cd inteligente) |
| `cls` | `clear` |
| `update` | `sudo dnf upgrade -y && flatpak update -y` (Fedora) |
| `bravefix` | Mata Brave y limpia locks de perfil bloqueado |
| `chromefix` | Mata Chrome y limpia locks de perfil bloqueado |

## Soporte Fedora vs Ubuntu

Todos los componentes detectan el SO con `lib/common.sh`. Fedora usa `dnf` y `grubby`; Ubuntu usa `apt` y edición de GRUB. Los componentes orientados a GNOME (temas, extensiones, iconos) asumen GNOME Shell estándar.
