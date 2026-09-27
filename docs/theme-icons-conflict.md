# Gestión de temas: componente `theme` vs componente `icons`

## El problema

Los dos componentes escriben sobre el mismo `gsettings`:

| Componente | Escritura | Momento |
|---|---|---|
| `theme` | `gtk-theme`, `user-theme`, `icon-theme` | Al instalar |
| `theme` (sincronizador) | `color-scheme`, `gtk-theme`, `user-theme`, `icon-theme` | **Cada vez** que cambia el modo claro/oscuro |
| `icons` | `icon-theme` | Al aplicar el pack elegido |

`whitesur-theme-sync.sh` es un demonio que corre con autostart y vigila
`gsettings monitor`. Dentro fijaba `local icon_theme="WhiteSur"` como literal, así
que si el usuario elegía otro pack en el componente `icons`, el sincronizador le
devolvía `WhiteSur` al siguiente cambio de modo. El componente `icons` ganaba una
vez y perdía para siempre.

## Solución implementada (opción 3)

El valor del icono se extrajo del literal a una constante configurable:

```bash
# ~/.local/bin/whitesur-theme-sync.sh
SYNC_ICON_THEME="WhiteSur"     # <-- el componente "icons" reescribe esta línea
```

`icons` llama a `sync_theme_sync_icons()` al aplicar un pack, que reescribe esa
constante. Resultado: el usuario elige, y el sincronizador respeta la elección
en los cambios de modo futuros.

Detalles de la implementación:

- Escritura atómica vía archivo temporal + `mv`, con verificación posterior de
  que el valor quedó aplicado. Si el `sed` falla, el archivo original no se toca.
- El nombre del pack se valida contra `^[A-Za-z0-9._-]+$` antes de interpolarse en
  el `sed`, para que un valor inesperado no rompa el archivo del sincronizador.
- Es idempotente: si el valor ya es el correcto, no escribe nada.
- `01-gnome-theme.sh` parchea los sincronizadores preexistentes que no tengan la
  constante, para que los usuarios que ya lo tenían instalado no se queden sin
  la funcionalidad.

## Alternativas consideradas

Se evaluaron cinco enfoques. Se documentan aquí por si el modelo de componentes
cambia en el futuro.

### Opción 1 — Sync condicional

`theme` no instala el sincronizador si el componente `icons` está seleccionado.

- Pros: la más simple, ~5 líneas, sin estado compartido.
- Contras: se pierde el auto-sync de iconos al cambiar de modo. El usuario
  tendría que cambiar los iconos a mano cada vez.
- Cuándo elegirla: si se decide que el auto-sync de iconos no vale la pena.

### Opción 2 — Sync respetuoso

El sincronizador lee `gsettings get icon-theme` al arrancar y usa ese valor en
lugar de una constante fija.

- Pros: respeta cualquier cambio que el usuario haga, incluso después de
  instalar `icons`, sin necesidad de cooperation entre componentes. Es la opción
  más robusta ante cambios futuros.
- Contras: si el usuario cambia de pack mientras el sincronizador corre, el valor
  queda congelado hasta reiniciar sesión. Además, el pack elegido podría no ser
  el deseado si se arranca con otro activo.
- Cuándo elegirla: si se prioriza que el sincronizador sea autocontenido.

### Opción 3 — Sobrescritura desde `icons` (implementada)

`icons` reescribe la constante del sincronizador.

- Pros: ambos componentes conservan su función completa. El usuario elige y el
  sistema lo respeta.
- Contras: requiere que `icons` conozca la existencia y el formato del archivo del
  sincronizador. Acoplamiento entre componentes.
- Cuándo elegirla: cuando se quiere mantener la modularidad con estado compartido
  explícito. **Es la opción actual.**

### Opción 4 — Preguntar en el menú

Añadir una pregunta en el menú de `theme`: "¿Sincronizar también los iconos?".

- Pros: control explícito del usuario, sin acoplamiento.
- Contras: más complejidad de UI, y en la práctica casi todos responderían lo mismo.
  Un paso más que recordar.
- Cuándo elegirla: si el comportamiento por defecto debería ser conservador.

### Opción 5 — Componente único de apariencia

Un solo componente `appearance` que gestione GTK + Shell + Iconos + sincronizador.

- Pros: una sola fuente de verdad, imposible que haya conflictos porque todo se
  decide en un solo sitio. Aplicable si se quiere permitir combinaciones libre
  de temas e iconos.
- Contras: refactor mayor. Rompe la granularidad actual (instalar solo iconos sin
  tocar el tema GTK deja de ser posible). Cambia el contrato de la CLI
  (`--component icons`).
- Cuándo elegirla: si el proyecto crece y la combinación de temas se vuelve un
  flujo de primer orden en lugar de un ajuste secundario.

## Nota sobre la detección de conflicto

`sync_theme_sync_icons()` no falla si el sincronizador no existe (caso normal
cuando solo se instala `icons`) ni si no reconoce la constante (avisa y sigue,
para no bloquear la instalación de iconos). Solo aborta en esos dos casos con un
aviso accionable.

## Verificación

Casos probados con el sincronizador simulado:

| Caso | Resultado |
|---|---|
| No existe el sincronizador | Sin error, no hay conflicto |
| Existe sin `SYNC_ICON_THEME` (pre-migración) | Avisa, no modifica el archivo |
| `.local/bin` inexistente | No falla |
| Reescritura con cada pack | Correcta para los 4 |
| Reintento con el mismo valor | Idempotente, no escribe |
| Nombre con comillas y `rm -rf` | Rechazado por la validación |
| Migración del formato viejo | Inserta la constante y sustituye el literal; `bash -n` OK |
