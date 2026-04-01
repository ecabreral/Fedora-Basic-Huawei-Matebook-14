Dash to dock
------------

Esta extensión mejora el dash sacándolo de la vista general y transformándolo en un dock para facilitar el lanzamiento de aplicaciones y un cambio más rápido entre ventanas y escritorios sin tener que dejar la vista del escritorio.  
[https://extensions.gnome.org/extension/307/dash-to-dock/](hhttps://extensions.gnome.org/extension/307/dash-to-dock/)

[![](https://extensions.gnome.org/extension-data/screenshots/screenshot_307_90H8hVD.jpg)

### Instalación

La instalación requiere previamente una dependencia en fedora 34

sudo dnf install -y sassc gnome-extensions-app

Descargar la extension de:

[https://extensions.gnome.org/extension/307/dash-to-dock/](hhttps://extensions.gnome.org/extension/307/dash-to-dock/)


Abrir la app de extensiones para habilitarla

[![](https://linuxitos.com/main/wp-content/uploads/2021/06/Screenshot-from-2021-06-17-08-16-24-1-1024x576.png)](https://linuxitos.com/main/wp-content/uploads/2021/06/Screenshot-from-2021-06-17-08-16-24-1.png)

---

## Diagnóstico y Solución de Dash to Dock

¡Perfecto! 👌 Ahora podemos identificar claramente el origen del problema.

### 🔥 Configuración incorrecta detectada

En tu captura de pantalla:

- ✔ **Autohide → ON** ✅ (correcto)
- ❌ **Dodge windows → ON** ❌ (esto causa el problema)

### 💣 ¿Qué ocurre?

La opción **Dodge windows** (también llamada "Intelligent hide"):

- Puede fallar ocasionalmente
- Hace que el dock se quede encima de las ventanas
- Es especialmente problemático en Wayland y con efectos de blur

### ✅ Solución exacta para tu caso

Solo debes hacer lo siguiente:

#### ❌ Desactiva:
- **Dodge windows → OFF**

#### ✔ Mantén activo:
- **Autohide → ON**

### 🎯 Configuración recomendada

- Autohide → ✅
- Dodge windows → ❌
- All windows → (ya no importa)

### 🚀 Resultado

- El dock ya no se quedará encima de las ventanas
- El comportamiento será más fluido
- Desaparecen los bugs visuales

### 🚀 Ajuste PRO automático

El script de instalación ya configura el dock para que al hacer clic en un icono:
- **Minimice** la ventana si ya está abierta.
- **Cambie** entre ventanas si hay varias (app spread).
- **Enfoque** la ventana si está en segundo plano.

Si necesitas aplicarlo manualmente:
```bash
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-appspread'
```

### 🧠 Resumen

- El bug NO era Fedora
- NO era GNOME
- Era **Dodge windows activado**

---

Si lo deseas, en el siguiente paso te ayudo a dejar el dock:
- Con animación tipo macOS
- Tamaño perfecto
- Blur calibrado

¡Y te quedará 🔥!
