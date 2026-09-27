# Fedora System Setup

Instalador post-instalación automatizado para Fedora Workstation con GNOME, optimizado para Huawei MateBook 14. También ofrece soporte parcial para Ubuntu.

## Características

- Interfaz interactiva con `whiptail` (menús, checklists y diálogos)
- Instalación selectiva por componentes o completa
- Diagnóstico inicial del entorno (OS, arquitectura, Internet, sudo)
- Reintento automático de componentes fallidos
- Registro detallado con rotación de logs
- Desinstalación selectiva de componentes
- Compatible con terminales Fedora, SSH y modo CLI

## Uso

```bash
chmod +x setup.sh

# Menú interactivo
./setup.sh

# Instalar componentes concretos
./setup.sh --component base terminal vscode git --theme tokyo-night

# Simular una instalación
./setup.sh --dry-run --component base terminal

# Desinstalar componentes
./setup.sh --uninstall

# Ayuda
./setup.sh --help
```

## Opciones

| Opción | Descripción |
|---|---|
| `--component <nombres>` | Instala uno o varios componentes separados por espacio. |
| `--theme <nombre>` | Selecciona el tema de Starship y Ptyxis. |
| `--dry-run` | Muestra qué se instalaría sin modificar el sistema. |
| `--uninstall` | Abre el menú de desinstalación. |
| `--help`, `-h` | Muestra la ayuda. |

## Componentes

| ID | Componente | Descripción |
|---|---|---|
| `base` | Sistema base | RPM Fusion Free/Non-Free, actualizaciones, FFmpeg, GStreamer Good/Bad/Ugly/Extras, OpenH264, Flatpak, Flathub, VA-API y controlador Intel. Desactiva el autostart de GNOME Software y ofrece desactivar `NetworkManager-wait-online` con confirmación. |
| `terminal` | Terminal | Ptyxis, Zsh, Oh My Zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, Starship, `eza`, `fastfetch`, `fzf`, `bat`, `zoxide`, `micro`, JetBrainsMono Nerd Font y aliases. Configura Zsh y Ptyxis como predeterminados. |
| `vscode` | Visual Studio Code | VS Code desde el repositorio oficial de Microsoft con configuración inicial respetando `settings.json` existente. |
| `git` | Git + SSH | Git, configuración global, rama `main`, clave SSH Ed25519, `ssh-agent`, copia de la clave y prueba con GitHub. |
| `gh` | GitHub CLI | GitHub CLI y configuración como credential helper de Git. |
| `opencode` | OpenCode CLI | OpenCode en `~/.opencode/bin` con PATH idempotente en la configuración de zsh. |
| `theme` | Temas GNOME | WhiteSur GTK, MacTahoe GTK, iconos WhiteSur/MacTahoe, tema de Firefox, tema GDM y sincronización claro/oscuro. |
| `extensions` | Extensiones GNOME | Instala Extension Manager (Flathub) más Dash to Dock, Tiling Shell, GSConnect, Burn My Windows, Coverflow Alt-Tab, Desktop Cube, Alphabetical App Grid, TopHat, Media Controls, Custom Hot Corners, Magic Lamp, Copyous, Night Theme Switcher y Dynamic Music Pill. Instalación automática vía API de extensions.gnome.org, con registro de lo instalado para una desinstalación limpia. |
| `icons` | Iconos GNOME | WhiteSur, McMojave Circle, Tela Circle, Papirus o BeautyLine. |
| `intel` | Corrección Intel | Añade `i915.enable_psr=0`, `i915.enable_dc=0` e `intel_idle.max_cstate=2` al kernel. Requiere reinicio. |
| `brave` | Brave Browser | Brave desde el instalador oficial con alias `bravefix` para desbloquear perfiles. |
| `chrome` | Google Chrome | Repositorio oficial de Google e instalación de `google-chrome-stable`. |
| `spotify` | Spotify | Cliente oficial mediante Flathub con permisos gráficos necesarios. |

En el menú **Instalar todos los componentes** se incluyen todos los componentes de esta tabla.

## Configuración de Zsh

La configuración de zsh se organiza en snippets modulares en `~/.config/zsh/conf.d/`, cargados desde un `~/.zshrc` mínimo:

```text
~/.zshrc                         → Carga snippets de conf.d/
~/.config/zsh/conf.d/
├── 00-path.sh                   → PATH de cargo
├── 10-oh-my-zsh.sh              → Oh My Zsh y plugins
├── 20-aliases.sh                → Aliases modernos
├── 30-tools.sh                  → zoxide, fzf, starship
└── 40-motd.sh                   → fastfetch al inicio
```

Estructura modular que permite agregar, quitar o modificar snippets sin afectar la configuración global.

## Temas de terminal

Los temas disponibles son presets oficiales de Starship, con paleta de colores sincronizada para Ptyxis:

| Tema | Estilo | Glifos |
|---|---|---|
| `tokyo-night` | Oscuro azulado (recomendado por defecto). | Powerline |
| `gruvbox-rainbow` | Oscuro cálido. | Powerline |
| `pastel-powerline` | Claro pastel. | Powerline |
| `catppuccin-powerline` | Oscuro pastel. | Powerline |

Los cuatro usan separadores Powerline (U+E0A0–U+E0D4), por lo que **todos requieren JetBrainsMono Nerd Font**. La fuente también es necesaria para los iconos de archivo de `eza --icons`, que los aliases `ls`/`ll`/`lt` usan.

Al aplicar un tema, el proyecto añade la línea `# fedora-setup: theme=<nombre>` al inicio de `~/.config/starship.toml` para poder identificar el tema activo: los presets de Starship no incluyen su propio nombre y sus paletas se solapan entre sí.

Cambiar el tema sin reinstalar:

```bash
./setup.sh
# Opción 3

# Alternativa directa
./scripts/02-terminal/02-change-theme.sh
```

## Desinstalación

```bash
./setup.sh --uninstall
```

Permite desinstalar VS Code, GitHub CLI, Brave, Chrome, Spotify, Starship, Oh My Zsh, OpenCode y componentes visuales de GNOME. Los temas e iconos restauran la configuración de GNOME sin borrar archivos personales.

La opción 4 del menú principal desinstala Kitty o Alacritty y restaura Ptyxis como terminal predeterminada.

## Interfaz

- Diagnóstico inicial de sistema, arquitectura, sesión gráfica, Internet y `sudo`.
- Estados `[INSTALADO]` y `[NO INSTALADO]` por componente.
- Item **"Ver descripción de componentes"** en cada checklist, que muestra qué hace cada componente, sus pros y contras, y su estado actual, sin salir del menú.
- Paleta azul sobria y alto contraste para modo claro.
- Ventanas adaptadas al tamaño de la terminal, con validación mínima (60x20).
- Reintento de componentes fallidos.
- Resumen final con componentes instalados, omitidos y fallidos.
- Apertura del log desde el resumen.
- Compatible con terminales Fedora, SSH y modo CLI.

## Comportamiento en modo no interactivo

Los scripts distinguen entre ejecución interactiva y automatizada (`[ -t 0 ]`):

- Los `read -p` se saltan o se sustituyen por un valor por defecto, evitando que el instalador quede esperando input indefinidamente.
- `chsh` no se ejecuta en modo automatizado; se imprime el comando a ejecutar manualmente.
- Las selecciones interactivas (tema de iconos, reconfigurar Git) usan un valor por defecto en lugar de bloquearse.
- Los componentes que requieren interacción (Git) fallan con un mensaje explicativo en lugar de colgarse.

## Logs

Cada ejecución crea un log en `logs/install-YYYYMMDD-HHMMSS.log` y actualiza el enlace `logs/install.log`.

- Texto plano sin códigos ANSI.
- Timestamps para las operaciones del instalador.
- Resumen final por componente y duración.
- Se conservan los últimos cinco logs.
- Los logs de más de 1 MB se eliminan durante la rotación.

El directorio `logs/` está en `.gitignore`: son artefactos de ejecución, no código.

## Después de instalar

```bash
source ~/.zshrc
```

El `.zshrc` se genera mínimo y carga los snippets de `~/.config/zsh/conf.d/`, así que recargar ese archivo basta para que los componentes que hayan añadido PATH o aliases (OpenCode, Brave, Chrome) queden activos.

Cierra sesión si instalaste temas o extensiones GNOME. **Reinicia solo si instalaste `intel`**: es el único componente que modifica parámetros del kernel.

## Estructura del proyecto

```text
setup.sh                 Menús, validación, CLI y desinstalación
lib/common.sh            Funciones compartidas, detección de SO y seguridad
lib/logger.sh            Logging, resumen y rotación
lib/ptyxis-colors.sh     Paletas de color para Ptyxis (tema activo)
lib/gnome-terminal-colors.sh  Paletas para GNOME Terminal (sin uso actual)
scripts/runner.sh        Ejecución ordenada de componentes
scripts/01-system        Sistema base
scripts/02-terminal      Terminal y cambio de tema
scripts/03-development   VS Code, Git y GitHub CLI
scripts/04-desktop       Temas, extensiones e iconos GNOME
scripts/05-hardware      Corrección Intel
scripts/06-apps          Brave, Chrome, Spotify y OpenCode
```

> `lib/gnome-terminal-colors.sh` no lo sourcea ningún script: el proyecto configura
> los colores de la terminal vía paletas de Ptyxis, no vía perfiles de GNOME
> Terminal. Se conserva por si se usa GNOME Terminal en vez de Ptyxis.

## Seguridad

Todas las descargas pasan por `secure_fetch()` (`lib/common.sh`), que aplica:

- **HTTPS exclusivamente** (`--proto '=https'` bloquea redirecciones a `http://`).
- **TLS >= 1.2** en todas las peticiones.
- **Tiempos de espera** (`--connect-timeout 15 --max-time 300 --retry 3`) para evitar que el instalador se cuelgue.
- **Validación de contenido**: se rechaza el archivo si llega vacío o si parece HTML en vez del script esperado (`looks_like_shell_script`), lo que evita ejecutar páginas de error de mirrors caídos o captive portals.
- **Instalación de llaves GPG** con verificación de éxito antes de continuar; nunca se escribe un keyring con `curl | sudo dd`, que lo deja corrupto si la descarga se corta.

Además:

- Zsh registrado en `/etc/shells` antes de cambiar la shell por defecto.
- Repositorios temporales de temas clonados en `~/.cache/fedora-setup/` y eliminados tras la instalación.
- Configuración de zsh modular en `~/.config/zsh/conf.d/` para evitar sobrescritura de snippets personalizados.
- Autostart de GNOME Software desactivado con una entrada `Hidden=true` en `~/.config/autostart/` en lugar de borrar archivos propiedad de paquetes en `/etc/xdg/autostart/`.
- Scripts de bootloader idempotentes: se detectan parámetros ya aplicados antes de modificarlos, y se guarda backup de `/etc/default/grub` en Ubuntu.
- Comprobación de `lspci` unificada en `has_intel_gpu()` antes de aplicar parámetros del kernel.
- Deshabilitar `NetworkManager-wait-online` requiere confirmación interactiva e informa del tradeoff.
