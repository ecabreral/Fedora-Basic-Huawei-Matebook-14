# Fedora Setup Pro

![Fedora](https://img.shields.io/badge/Fedora-43-blue?style=flat-square&logo=fedora)
![Python](https://img.shields.io/badge/Python-3.14+-blue?style=flat-square&logo=python)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

Automatiza la configuración de Fedora Linux para Huawei Matebook 14 con una interfaz gráfica moderna estilo Fedora Installer.

## Características Principales

### 🎨 Interfaz Gráfica
- **Diseño estilo Fedora Installer (Anaconda)** con paleta de colores oficial
- **Tema claro/oscuro** con toggle en tiempo real
- **Layout responsivo** que se adapta a cualquier resolución
- **Cards colapsables** para organizar componentes
- **Consola integrada** con soporte para copiar/pegar
- **Barra de progreso** durante la instalación

### ⚙️ Modularidad
- **Selección granular**: Instala solo lo que necesites
- **Tres modos de selección**: Todo / Ninguno / Recomendado
- **Idempotente**: Verifica antes de instalar
- **Flags de granularidad**: `--skip-{componente}`

### 📝 Logging
- Logs detallados en `/logs/`
- Registro de comandos ejecutados
- Timestamps en cada acción
- Compatible con múltiples usuarios (sudo)

---

## Capturas de Pantalla

```
┌────────────────────────────────────────────────────────────┐
│  🟢 Fedora Setup Pro                                      │
│     Configura tu Huawei Matebook 14                       │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─ 🐚 Terminal Pro ─────────────────────────────────┐   │
│  │ ☑ Paquetes base         git, curl, wget          │   │
│  │ ☑ Herramientas modernas  eza, bat, fzf          │   │
│  │ ☑ Zsh + Oh My Zsh     Shell moderno            │   │
│  │ ☑ Starship Prompt      Prompt minimalista        │   │
│  └───────────────────────────────────────────────────┘   │
│                                                            │
│  ┌─ 🍎 Temas macOS ─────────────────────────────────┐   │
│  │ ☑ Tema GTK WhiteSur      Light + Dark           │   │
│  │ ☑ Iconos WhiteSur       WhiteSur + MacTahoe   │   │
│  │ ☐ GDM / Login          Pantalla de inicio      │   │
│  └───────────────────────────────────────────────────┘   │
│                                                            │
│  [Todo] [Ninguno] [Recomendado]                          │
│                                                            │
│  ┌─ 📟 Consola ─────────────────────────────────────┐   │
│  │  Iniciando instalación...                         │   │
│  │  ✔ Terminal Pro completado                       │   │
│  └───────────────────────────────────────────────────┘   │
│                                                            │
│            [ ⚡ Instalar Fedora ]                        │
└────────────────────────────────────────────────────────────┘
```

---

## Componentes Disponibles

### 🐚 Terminal Pro
| Componente | Descripción |
|------------|-------------|
| Paquetes base | git, curl, wget, unzip |
| Herramientas modernas | eza, bat, fzf, zoxide, fastfetch, micro |
| Fuente Nerd | JetBrainsMono Nerd Font |
| Zsh + Oh My Zsh | Shell moderno con plugins |
| Starship | Prompt minimalista estilo Pastel Powerline |

**Aliases configurados:**
```bash
ls   → eza --icons=auto
ll   → eza -lah --icons --git
cat  → bat --paging=never
cd   → z (zoxide)
```

### 🍎 Temas macOS
| Componente | Descripción |
|------------|-------------|
| Dependencias | sassc, glib, ImageMagick |
| Tema GTK | WhiteSur Light + Dark |
| Iconos | WhiteSur + MacTahoe |
| GDM | Pantalla de login estilo macOS |
| Firefox | WhiteSur Firefox Theme |
| Sync | Auto-switch claro/oscuro |

### 🛠️ Aplicaciones
| Componente | Descripción |
|------------|-------------|
| VS Code | Editor con config optimizada (GitHub theme, JetBrains Mono) |
| Git + SSH | Config global + clave ed25519 para GitHub |
| Intel Fix | Parámetros kernel para corregir parpadeo |
| Extensiones | Dash to Dock, Magic Lamp, Copyous, Night Theme Switcher |

---

## Instalación

### Rápido
```bash
git clone https://github.com/ecabreral/Fedora-Basic-Huawei-Matebook-14.git
cd Fedora-Basic-Huawei-Matebook-14
python3 setup_gui.py
```

### Interfaz Gráfica
```bash
./setup_gui.py
```

### Línea de Comandos
```bash
# Ejecutar script individual
sudo bash scripts/01-terminal.sh
sudo bash scripts/04-gnome-theme.sh

# Con flags de granularidad
sudo bash scripts/01-terminal.sh --skip-pkg --skip-font
sudo bash scripts/04-gnome-theme.sh --skip-firefox --skip-gdm

# Modo no interactivo
NONINTERACTIVE=true GIT_NAME="Tu Nombre" GIT_EMAIL="tu@email.com" \
  bash scripts/03-git.sh
```

---

## Estructura del Proyecto

```
Fedora-Basic-Huawei-Matebook-14/
├── setup.sh                     # Launcher (CLI → GUI)
├── setup_gui.py                # Interfaz gráfica
├── fedora-setup-launcher.sh     # Wrapper portable
├── FedoraSetup.desktop         # Entry para GNOME
│
├── scripts/
│   ├── lib.sh                  # Librería compartida
│   ├── 01-terminal.sh          # Terminal moderna
│   ├── 02-vscode.sh            # Visual Studio Code
│   ├── 03-git.sh               # Git + SSH
│   ├── 04-gnome-theme.sh       # Temas macOS
│   ├── 05-intel-fix.sh         # Fix Intel
│   └── 06-extensions.sh         # Extensiones GNOME
│
├── config/
│   └── starship.toml            # Preset Pastel Powerline
│
├── logs/                       # Logs de ejecución
│
└── docs/
    ├── dash-to-dock.md
    └── copyous-troubleshooting.md
```

---

## Sistema de Logging

Los logs se guardan automáticamente en:
```
proyecto/logs/setup-YYYYMMDD-HHMMSS.log
```

**Contenido del log:**
```bash
========================================
Inicio: 2026-04-01 12:00:00
Script: 04-gnome-theme
Host: matebook
User: ecabrera
Log File: /home/.../logs/setup-20260401-120000.log
========================================
[12:00:01] INFO: Instalando WhiteSur GTK Theme...
[12:00:05] OK: WhiteSur GTK Theme instalado.
...
Fin: 2026-04-01 12:00:30
========================================
```

---

## Variables de Entorno

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `NONINTERACTIVE` | Modo no interactivo | `false` |
| `GIT_NAME` | Nombre para Git | Prompt interactivo |
| `GIT_EMAIL` | Email para Git | Prompt interactivo |
| `LOG_DIR` | Directorio de logs | `proyecto/logs/` |
| `FORCE_INTEL_FIX` | Forzar fix Intel | `false` |

---

## Requisitos

- **Fedora 43+** (probado en Fedora 43)
- **Python 3.14+** (para GUI)
- **GNOME** (temas y extensiones)
- **sudo** privileges
- **Huawei Matebook 14** (optimizado para)

---

## Solución de Problemas

### La GUI no responde
```bash
# Verificar Python
python3 --version

# Verificar tkinter
python3 -c "import tkinter; print('tkinter OK')"
```

### Permisos de archivos
```bash
# Los logs se crean con el usuario real
ls -la logs/

# Eliminar logs antiguos
rm -f logs/*.log
```

### Extensiones no se abren
- Asegúrate de tener Firefox instalado
- Instala las extensiones manualmente desde los enlaces mostrados

---

## Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcion`)
3. Commit (`git commit -am 'Agrega nueva función'`)
4. Push (`git push origin feature/nueva-funcion`)
5. Crea un Pull Request

---

## Licencia

MIT License - Ver [LICENSE](LICENSE) para más detalles.

---

## Créditos

- **WhiteSur GTK Theme**: [vinceliuice/WhiteSur-gtk-theme](https://github.com/vinceliuice/WhiteSur-gtk-theme)
- **WhiteSur Icon Theme**: [vinceliuice/WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme)
- **MacTahoe Theme**: [vinceliuice/MacTahoe-gtk-theme](https://github.com/vinceliuice/MacTahoe-gtk-theme)
- **Starship**: [starship/starship](https://github.com/starship/starship)

---

> 🚀 Configura tu Huawei Matebook 14 con Fedora en minutos, no horas.
