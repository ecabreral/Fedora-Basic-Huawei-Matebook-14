# Configurar opencode en zsh (posterior a instalación)

Perfecto, ya con eso sabemos el problema exacto:

👉 **Sí tienes `opencode` instalado**, pero **zsh no lo está viendo en el PATH**.

Vamos a arreglarlo en 30 segundos 👇

---

## ✅ 1. Agrega correctamente al PATH (zsh)

Ejecuta:

```bash
echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 🔍 2. Verifica que ya lo detecta

```bash
which opencode
```

Debe salir algo como:

```
/home/ecabrera/.opencode/bin/opencode
```

---

## 🚀 3. Ejecuta

```bash
opencode
```

---

## 🧠 Si todavía falla (caso raro)

Forzamos recarga limpia:

```bash
exec zsh
```

o incluso:

```bash
rehash
```

---

## 💡 Nota importante

Antes lo agregaste así:

```bash
~/.bashrc ❌
```

Pero tú usas **zsh**, así que siempre:

```
~/.zshrc ✅
```

---

Si aún así no corre, dime qué te devuelve:

```bash
echo $PATH
which opencode
```

y lo dejamos fino (puede ser permisos o shebang, pero ya estás a 1 paso de que funcione).
