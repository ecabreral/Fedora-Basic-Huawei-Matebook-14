# Fedora System Setup

Instalador post-instalación para Fedora Workstation con GNOME y Huawei MateBook 14. También ofrece soporte parcial para Ubuntu.

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

| ID | Componente | Instala o configura |
|---|---|---|
| `base` | Sistema base | RPM Fusion Free/Non-Free, actualizaciones, FFmpeg, GStreamer Good/Bad/Ugly/Extras, OpenH264, Flatpak, Flathub, VA-API y controlador Intel. También desactiva `NetworkManager-wait-online` y algunos autostarts de GNOME. |
| `terminal` | Terminal | Ptyxis, Zsh, Oh My Zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, Starship, `eza`, `fastfetch`, `fzf`, `bat`, `zoxide`, `micro`, JetBrainsMono Nerd Font, aliases y `.zshrc`. Configura Zsh y Ptyxis como predeterminados. |
| `vscode` | Visual Studio Code | VS Code desde el repositorio oficial de Microsoft y configuración inicial respetando `settings.json` existente. |
| `git` | Git + SSH | Git, configuración global, rama `main`, clave SSH Ed25519, `ssh-agent`, copia de la clave y prueba con GitHub. |
| `gh` | GitHub CLI | GitHub CLI y configuración como credential helper de Git. |
| `opencode` | OpenCode CLI | OpenCode en `~/.opencode/bin` y PATH idempotente en `.zshrc`. |
| `theme` | Temas GNOME | WhiteSur GTK, MacTahoe GTK, iconos WhiteSur/MacTahoe, tema de Firefox, tema GDM y sincronización claro/oscuro. |
| `extensions` | Extensiones GNOME | Dash to Dock, Tiling Shell, GSConnect, Burn My Windows, Coverflow Alt-Tab, Desktop Cube, Alphabetical App Grid, TopHat, Media Controls, Custom Hot Corners, Magic Lamp, Night Theme Switcher y Dynamic Music Pill. |
| `icons` | Iconos GNOME | Menú para instalar WhiteSur, McMojave Circle, Tela Circle, Papirus o BeautyLine. |
| `intel` | Corrección Intel | Añade `i915.enable_psr=0`, `i915.enable_dc=0` e `intel_idle.max_cstate=2` al kernel. Requiere reinicio. |
| `brave` | Brave Browser | Brave desde el instalador oficial y alias `bravefix` para desbloquear perfiles. |
| `chrome` | Google Chrome | Repositorio oficial de Google e instalación de `google-chrome-stable`. |
| `spotify` | Spotify | Cliente oficial mediante Flathub y permisos gráficos necesarios. |

En el menú **Instalar todos los componentes** se incluyen todos los componentes de esta tabla.

## Temas de terminal

Disponibles para Starship y Ptyxis:

| Tema | Estilo |
|---|---|
| `tokyo-night` | Oscuro azulado. |
| `pastel-powerline` | Claro pastel. |
| `gruvbox-rainbow` | Oscuro cálido. |
| `catppuccin-powerline` | Oscuro pastel. |
| `jetpack` | Minimalista. |
| `pure-preset` | Clásico. |
| `cyberpunk-storm` | Neón intenso. |
| `cyberpunk-neon` | Alta saturación. |
| `cyberpunk-night` | Oscuro y discreto. |

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
- Paleta azul sobria y alto contraste para modo claro.
- Ventanas adaptadas al tamaño de la terminal.
- Reintento de componentes fallidos.
- Resumen final con componentes instalados, omitidos y fallidos.
- Apertura del log desde el resumen.
- Compatible con terminales Fedora, SSH y modo CLI.

## Logs

Cada ejecución crea un log en `logs/install-YYYYMMDD-HHMMSS.log` y actualiza `logs/install.log`.

- Texto plano sin códigos ANSI.
- Timestamps para las operaciones del instalador.
- Resumen final por componente y duración.
- Se conservan los últimos cinco logs.
- Los logs de más de 1 MB se eliminan durante la rotación.

## Después de instalar

```bash
source ~/.zshrc
```

Cierra sesión si instalaste temas o extensiones GNOME. Reinicia si instalaste `base` o `intel`.

## Estructura

```text
setup.sh                 Menús, validación, CLI y desinstalación
lib/common.sh            Funciones compartidas y detección de sistema
lib/logger.sh            Logging, resumen y rotación
lib/catalog.sh           Catálogo, estados y dependencias de componentes
lib/cli.sh               Argumentos y validación del modo CLI
lib/ui.sh                Menús whiptail y selección de componentes
lib/platform.sh          Adaptadores de paquetes Fedora/Ubuntu
lib/privilege.sh         Contexto de usuario y operaciones root
scripts/runner.sh        Ejecución ordenada de componentes
scripts/01-system        Sistema base
scripts/02-terminal      Terminal y cambio de tema
scripts/03-development   VS Code, Git y GitHub CLI
scripts/04-desktop       Temas, extensiones e iconos GNOME
scripts/05-hardware      Corrección Intel
scripts/06-apps          Brave, Chrome, Spotify y OpenCode
config/starship          Temas Starship personalizados
tests/                   Pruebas sintácticas y de integración del runner
```

## Arquitectura

El punto de entrada coordina la interfaz y el modo CLI, mientras que las
decisiones compartidas viven en librerías:

```text
setup.sh
  -> lib/cli.sh       Argumentos y validación
  -> lib/ui.sh        Menús whiptail y selección
  -> lib/catalog.sh   Componentes, categorías y dependencias
  -> lib/platform.sh  Operaciones Fedora/Ubuntu
  -> lib/privilege.sh Contexto usuario/root
  -> scripts/runner.sh
  -> scripts/<area>/<componente>.sh
```

El runner resuelve dependencias antes de ejecutar. Por ejemplo, seleccionar
`spotify` incluye automáticamente `base`. El modo `--dry-run` muestra el plan
resuelto sin ejecutar comandos ni pedir permisos.

## Validación

Las comprobaciones sintácticas y pruebas básicas se ejecutan con:

```bash
./tests/run.sh
```
