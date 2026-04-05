# Scripts de Configuración de Fedora 43

Colección de scripts para automatizar la configuración de Fedora Linux orientada a desarrollo, con una experiencia de escritorio GNOME similar a macOS.

## Uso rápido

```bash
./setup.sh
```

> 🚀 **Novedad**: Ahora cuenta con una **interfaz gráfica interactiva**. Podrás seleccionar exactamente qué componentes deseas instalar mediante casillas de verificación. Una vez seleccionado, se abrirá una terminal para que sigas el progreso en tiempo real.

---

## Estructura del Proyecto

```
Fedora/
├── setup.sh                    # ▶ Punto de entrada — ejecutar este
├── scripts/
│   ├── lib.sh                  # Librería compartida (colores, helpers)
│   ├── 01-terminal.sh          # Terminal moderna: zsh, Starship, eza…
│   ├── 02-vscode.sh            # Visual Studio Code + configuración
│   ├── 03-git.sh               # Git global + clave SSH para GitHub
│   ├── 04-gnome-theme.sh       # Temas GNOME estilo macOS
│   ├── 05-intel-fix.sh         # Fix parpadeo pantalla Intel (opcional)
│   └── cleanup.sh              # Elimina Oh My Zsh (opcional)
├── config/
│   └── starship.toml           # Preset Pastel Powerline para Starship
└── docs/
    ├── dash-to-dock.md         # Guía de configuración de Dash to Dock
    └── copyous-troubleshooting.md  # Solución de problemas de Copyous
```

---

## Qué instala cada script

### 1. Terminal — `scripts/01-terminal.sh`

| Herramienta | Descripción |
|---|---|
| `zsh` + Oh My Zsh | Shell moderna con plugins |
| `starship` | Prompt Pastel Powerline |
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

**INSTALAR VS CODE CORRECTAMENTE EN FEDORA 43**

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

El cambio automático claro↔oscuro se gestiona con **Night Theme Switcher**. Configurarlo así:

```
GTK Light  → WhiteSur-Light    GTK Dark  → WhiteSur-Dark
Shell Light → WhiteSur-Light   Shell Dark → WhiteSur-Dark
```

> Activa *Ubicación automática del dispositivo* en Configuración → Privacidad → Ubicación para que el cambio sea por hora solar.

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
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/) | Dock estilo macOS (Autoconfigurado con clic para minimizar) |
| [Night Theme Switcher](https://extensions.gnome.org/extension/2236/night-theme-switcher/) | Cambio automático claro/oscuro |
| [Compiz Alike Magic Lamp](https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/) | Efecto de lámpara al minimizar |
| [Copyous](https://extensions.gnome.org/extension/8834/copyous/) | Historial de portapapeles |

> 💡 **Automatización**: `setup.sh` configura automáticamente el dock para minimizar al hacer clic una vez activada. Ver [`docs/dash-to-dock.md`](docs/dash-to-dock.md) para más detalles.

---

## Limpieza opcional — `scripts/cleanup.sh`

Elimina Oh My Zsh y carga los plugins de Zsh directamente (más ligero). Starship sigue funcionando como prompt.

```bash
./scripts/cleanup.sh
```

> Oh My Zsh es liviano y no interfiere con Starship. Este paso es completamente opcional.

---

## Notas

- Probado en **Fedora 43** con **GNOME**
- `setup.sh` detecta automáticamente si hay GPU Intel y omite el fix si no aplica
- Todos los scripts son **idempotentes**: verifican si cada componente ya está instalado antes de instalar
- `scripts/lib.sh` es la librería compartida usada por todos los scripts