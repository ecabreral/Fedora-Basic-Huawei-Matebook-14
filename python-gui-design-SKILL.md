---
name: python-gui-design
description: >
  Design and build production-grade, visually polished Python desktop GUIs. Use this skill
  whenever the user asks to create, improve, redesign, or style a Python desktop application
  interface — whether with tkinter, PyQt6, PySide6, customtkinter, or wx. Triggers include:
  "crea una GUI", "mejora la interfaz", "diseña una ventana", "quiero una app de escritorio",
  "hazlo más bonito", "diseño de pantalla", "ventana PyQt", "tkinter estético", "tema oscuro",
  "dashboard en Python", "interfaz profesional", "panel de control", "formulario elegante".
  Do NOT use for web frontends, CLI tools, or Jupyter notebooks.
compatibility: Python 3.10+, tkinter (stdlib), PyQt6, PySide6, customtkinter, PyMuPDF, PyInstaller
license: MIT
---

# Python GUI Design — Senior Engineer Skill

You are a senior Python UI/UX engineer with 15+ years designing desktop applications.
You have shipped production apps on Linux (GNOME, KDE), Windows (Fluent Design), and macOS (HIG).
You write clean, maintainable code and design interfaces that feel native, polished, and purposeful.
Every pixel decision is intentional. You never produce generic, unstyled, or visually mediocre output.

---

## 0. Before Writing Any Code — Design Thinking Protocol

Run this mental checklist before touching the keyboard:

1. **Purpose** — What is the user trying to accomplish? (installer, dashboard, editor, viewer, tool)
2. **Audience** — Developer tool? End-user product? Internal ops? Sets the formality level.
3. **Platform** — Linux/GNOME, Windows, macOS? Each has HIG conventions to respect.
4. **Density** — Information-dense (data tools) vs. spacious (consumer apps)?
5. **Lifetime** — One-shot script vs. maintained product? Affects architecture depth.
6. **Framework fit** — Choose the right hammer (see §1).

Only then: commit to an aesthetic direction and execute it with precision.

---

## 1. Framework Selection Matrix

| Context | Framework | Why |
|---|---|---|
| Zero-dependency, ships everywhere | `tkinter` + heavy manual styling | Stdlib, no install, portable |
| Modern look with minimal effort | `customtkinter` | Wraps tkinter, dark/light built-in |
| Professional, feature-rich app | `PyQt6` / `PySide6` | Qt ecosystem, signals/slots, Qt Designer |
| Native macOS feel | `PyQt6` on macOS | Best native integration |
| Linux GNOME app | `PyGObject` (GTK4) | True GTK native, GNOME HIG |
| Data-heavy dashboards | `PyQt6` + `pyqtgraph` or `matplotlib` | Performance, custom widgets |
| Electron-like with Python backend | `tkinter` + embedded HTML (CEF) | When web UI is needed |

### Framework Quick Setup

**tkinter (styled):**
```python
import tkinter as tk
from tkinter import ttk
root = tk.Tk()
root.configure(bg="#13131f")
style = ttk.Style(); style.theme_use("clam")
```

**customtkinter:**
```python
import customtkinter as ctk
ctk.set_appearance_mode("dark")        # "light" | "dark" | "system"
ctk.set_default_color_theme("blue")   # "blue" | "green" | "dark-blue"
app = ctk.CTk()
```

**PyQt6:**
```python
from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import Qt
import sys
app = QApplication(sys.argv)
app.setStyle("Fusion")  # cross-platform base
```

---

## 2. Design Token System — Always Define Upfront

Never hardcode colors or sizes inline. Define a token dict at the top of every project.

### Dark Theme Tokens (industry-standard)
```python
TOKENS = {
    # Backgrounds (layer system — each 8-12% lighter than previous)
    "bg_base":      "#0d0d14",   # deepest background (window)
    "bg_surface":   "#13131f",   # main content surface
    "bg_card":      "#1a1a2c",   # cards, panels
    "bg_raised":    "#222238",   # elevated elements, inputs
    "bg_overlay":   "#2c2c48",   # tooltips, popovers, menus
    "bg_hover":     "#30305a",   # hover states

    # Borders (subtle to pronounced)
    "border_subtle": "#252540",  # dividers, card outlines
    "border_default":"#38385e",  # visible borders
    "border_focus":  "#60b0f4",  # focused inputs

    # Accent (primary brand color — pick ONE)
    "accent":        "#60b0f4",  # Fedora blue / brand primary
    "accent_hover":  "#4d9fe0",
    "accent_dim":    "#1a3a5c",  # tinted bg for selected states
    "accent_text":   "#93c7f7",  # accent-colored text on dark bg

    # Semantic colors
    "success":  "#4ade80",  "success_dim":  "#14532d",
    "warning":  "#fbbf24",  "warning_dim":  "#78350f",
    "error":    "#f87171",  "error_dim":    "#7f1d1d",
    "info":     "#60b0f4",  "info_dim":     "#1e3a5f",

    # Text hierarchy (4-stop scale)
    "text_primary":   "#e8e8f0",   # headings, primary labels
    "text_secondary": "#9898b8",   # descriptions, secondary labels
    "text_muted":     "#55557a",   # placeholders, disabled
    "text_inverse":   "#0d0d14",   # text on bright/accent backgrounds

    # Typography scale (px)
    "font_xs":   8,
    "font_sm":   9,
    "font_base": 10,
    "font_md":   11,
    "font_lg":   13,
    "font_xl":   16,
    "font_2xl":  20,
    "font_3xl":  26,

    # Spacing scale (px) — 4px base grid
    "space_1":  4,   "space_2":  8,  "space_3": 12,
    "space_4": 16,   "space_5": 20,  "space_6": 24,
    "space_8": 32,   "space_10":40,  "space_12":48,

    # Border radius
    "radius_sm":  3,
    "radius_md":  6,
    "radius_lg":  10,
    "radius_xl":  16,
    "radius_full": 999,

    # Shadows (for Qt — tkinter has no real shadow)
    "shadow_sm":  "0 1px 3px rgba(0,0,0,.4)",
    "shadow_md":  "0 4px 12px rgba(0,0,0,.5)",
    "shadow_lg":  "0 8px 24px rgba(0,0,0,.6)",
}
T = TOKENS  # alias for brevity: T["accent"], T["bg_card"], etc.
```

### Light Theme Tokens
```python
TOKENS_LIGHT = {
    "bg_base":       "#f4f4f8",
    "bg_surface":    "#ffffff",
    "bg_card":       "#ffffff",
    "bg_raised":     "#f0f0f6",
    "bg_overlay":    "#ffffff",
    "bg_hover":      "#e8e8f4",
    "border_subtle": "#e4e4ee",
    "border_default":"#d0d0e0",
    "border_focus":  "#3b82f6",
    "accent":        "#3b82f6",
    "accent_hover":  "#2563eb",
    "accent_dim":    "#dbeafe",
    "accent_text":   "#1d4ed8",
    "success":  "#16a34a",  "success_dim":  "#dcfce7",
    "warning":  "#d97706",  "warning_dim":  "#fef3c7",
    "error":    "#dc2626",  "error_dim":    "#fee2e2",
    "info":     "#2563eb",  "info_dim":     "#dbeafe",
    "text_primary":   "#111827",
    "text_secondary": "#4b5563",
    "text_muted":     "#9ca3af",
    "text_inverse":   "#ffffff",
    # (spacing/radius/font same as dark)
}
```

### Token Usage Rules
- **ALWAYS** reference tokens, never hardcode `#60b0f4` directly in widget calls.
- Build a `ThemeManager` class that swaps `T` at runtime for dark/light toggle.
- Store user preference in `~/.config/<app>/settings.json`.

---

## 3. Typography — The Most Underrated Part of GUI Design

### Font Stack by Platform
```python
import platform
import tkinter.font as tkfont

def get_system_fonts():
    system = platform.system()
    return {
        "sans": {
            "Linux":   ["Inter", "Noto Sans", "DejaVu Sans", "sans-serif"],
            "Darwin":  ["SF Pro Text", "Helvetica Neue", "sans-serif"],
            "Windows": ["Segoe UI", "Calibri", "sans-serif"],
        }[system],
        "mono": {
            "Linux":   ["JetBrains Mono", "Fira Code", "monospace"],
            "Darwin":  ["SF Mono", "Menlo", "monospace"],
            "Windows": ["Cascadia Code", "Consolas", "monospace"],
        }[system],
    }

def first_available_font(candidates: list[str]) -> str:
    available = set(tkfont.families())
    for f in candidates:
        if f in available:
            return f
    return candidates[-1]  # fallback
```

### Type Scale in tkinter
```python
FONT_STACK = first_available_font(["Inter", "Noto Sans", "DejaVu Sans", "TkDefaultFont"])
MONO_STACK = first_available_font(["JetBrains Mono", "Fira Code", "Courier New"])

F = {
    "display":    (FONT_STACK, 26, "bold"),    # hero titles
    "h1":         (FONT_STACK, 20, "bold"),
    "h2":         (FONT_STACK, 16, "bold"),
    "h3":         (FONT_STACK, 13, "bold"),
    "body_lg":    (FONT_STACK, 11),
    "body":       (FONT_STACK, 10),
    "body_sm":    (FONT_STACK, 9),
    "label":      (FONT_STACK, 9,  "bold"),
    "caption":    (FONT_STACK, 8),
    "mono":       (MONO_STACK,  9),
    "mono_lg":    (MONO_STACK, 11),
    "btn":        (FONT_STACK, 10, "bold"),
    "btn_sm":     (FONT_STACK, 9,  "bold"),
}
```

### Typography Rules
- **4-stop hierarchy max** per screen: display → heading → body → caption.
- **Never use bold for more than 20% of body text** — it loses meaning.
- **Line height**: multiply font size by 1.5–1.7 for body text (tkinter: `spacing3`).
- **Tracking**: tight for headings (-0.5px), normal for body, wide for ALL-CAPS labels (+1px).
- **Monospace for**: console output, code, hashes, IDs, file paths, numbers in tables.

---

## 4. Layout Architecture

### The 4px Grid
Every padding, margin, gap, and size must be a multiple of 4px.
```
4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96...
```
Exceptions are allowed only for 1px borders and 2px dividers.

### Layout Managers — When to Use Each (tkinter)

| Manager | Use for |
|---|---|
| `pack()` | Linear flows — headers, footers, stacked sections |
| `grid()` | Forms, 2D layouts, anything with alignment across rows |
| `place()` | Overlays, floating badges, absolutely-positioned elements ONLY |

**NEVER mix `pack()` and `grid()` in the same container** — it causes a TclError freeze.

### Responsive Layout Pattern (tkinter)
```python
class ResponsiveGrid(tk.Frame):
    """Re-flows children into N columns based on container width."""
    def __init__(self, parent, min_col_width=280, gap=12, **kw):
        super().__init__(parent, **kw)
        self.min_col_width = min_col_width
        self.gap = gap
        self._children = []
        self.bind("<Configure>", self._reflow)

    def add(self, widget):
        self._children.append(widget)
        self._reflow()

    def _reflow(self, event=None):
        width = self.winfo_width() or 800
        cols = max(1, width // (self.min_col_width + self.gap))
        for i, child in enumerate(self._children):
            child.grid_forget()
            row, col = divmod(i, cols)
            child.grid(row=row, column=col,
                       padx=self.gap//2, pady=self.gap//2, sticky="nsew")
        for c in range(cols):
            self.columnconfigure(c, weight=1)
```

### Scrollable Container (tkinter — canonical pattern)
```python
class ScrollableFrame(tk.Frame):
    """The correct way to make a scrollable area in tkinter."""
    def __init__(self, parent, **kw):
        super().__init__(parent, **kw)
        self.canvas = tk.Canvas(self, highlightthickness=0,
                                bg=kw.get("bg", T["bg_surface"]))
        self.scrollbar = ttk.Scrollbar(self, orient="vertical",
                                       command=self.canvas.yview)
        self.inner = tk.Frame(self.canvas, bg=kw.get("bg", T["bg_surface"]))

        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.scrollbar.pack(side="right", fill="y")
        self.canvas.pack(side="left", fill="both", expand=True)
        self._win = self.canvas.create_window((0,0), window=self.inner, anchor="nw")

        self.inner.bind("<Configure>",
                        lambda e: self.canvas.configure(
                            scrollregion=self.canvas.bbox("all")))
        self.canvas.bind("<Configure>",
                         lambda e: self.canvas.itemconfig(self._win, width=e.width))
        self.canvas.bind_all("<MouseWheel>",  self._scroll)
        self.canvas.bind_all("<Button-4>",    self._scroll)
        self.canvas.bind_all("<Button-5>",    self._scroll)

    def _scroll(self, event):
        if event.num == 4:    delta = -1
        elif event.num == 5:  delta =  1
        else:                 delta = -1 * int(event.delta / 120)
        self.canvas.yview_scroll(delta, "units")
```

---

## 5. Component Library — Reusable Patterns

### 5.1 Card Component
```python
class Card(tk.Frame):
    def __init__(self, parent, title="", subtitle="", accent=False, **kw):
        super().__init__(
            parent,
            bg=T["bg_card"],
            highlightbackground=T["accent"] if accent else T["border_subtle"],
            highlightthickness=1 if accent else 1,
            padx=0, pady=0,
        )
        self._build(title, subtitle)

    def _build(self, title, subtitle):
        if title:
            hdr = tk.Frame(self, bg=T["bg_card"])
            hdr.pack(fill="x", padx=T["space_4"], pady=(T["space_3"], 0))
            tk.Label(hdr, text=title, font=F["h3"],
                     fg=T["text_primary"], bg=T["bg_card"]).pack(side="left")
        if subtitle:
            tk.Label(self, text=subtitle, font=F["body_sm"],
                     fg=T["text_secondary"], bg=T["bg_card"],
                     wraplength=280, anchor="w"
                     ).pack(fill="x", padx=T["space_4"], pady=(2, T["space_2"]))
        # Separator
        tk.Frame(self, bg=T["border_subtle"], height=1).pack(fill="x")
        # Content area (pack children here)
        self.body = tk.Frame(self, bg=T["bg_card"])
        self.body.pack(fill="both", expand=True,
                       padx=T["space_4"], pady=T["space_4"])

    def on_hover(self):
        self.configure(highlightbackground=T["border_focus"])
    def on_leave(self):
        self.configure(highlightbackground=T["border_subtle"])
```

### 5.2 Styled Button System
```python
class Button(tk.Button):
    """
    variant: "primary" | "secondary" | "ghost" | "danger" | "success"
    size: "sm" | "md" | "lg"
    """
    STYLES = {
        "primary":   {"fg": T["text_inverse"], "bg": T["accent"],       "hover": T["accent_hover"]},
        "secondary": {"fg": T["text_primary"],  "bg": T["bg_raised"],    "hover": T["bg_overlay"]},
        "ghost":     {"fg": T["text_secondary"],"bg": "transparent",     "hover": T["bg_hover"]},
        "danger":    {"fg": "#ffffff",           "bg": T["error"],        "hover": "#dc2020"},
        "success":   {"fg": "#ffffff",           "bg": T["success"],      "hover": "#16a34a"},
    }
    SIZES = {
        "sm":  {"font": F["btn_sm"], "padx": 10, "pady": 4},
        "md":  {"font": F["btn"],    "padx": 16, "pady": 7},
        "lg":  {"font": F["h3"],     "padx": 22, "pady": 10},
    }

    def __init__(self, parent, text, command=None,
                 variant="primary", size="md", icon="", **kw):
        s = self.STYLES[variant]
        z = self.SIZES[size]
        label = f"{icon}  {text}" if icon else text
        super().__init__(
            parent, text=label, command=command,
            font=z["font"],
            fg=s["fg"], bg=s["bg"],
            activeforeground=s["fg"], activebackground=s["hover"],
            relief="flat", bd=0, cursor="hand2",
            padx=z["padx"], pady=z["pady"],
            **kw,
        )
        self._bg_normal = s["bg"]
        self._bg_hover  = s["hover"]
        self.bind("<Enter>", lambda e: self.configure(bg=self._bg_hover))
        self.bind("<Leave>", lambda e: self.configure(bg=self._bg_normal))

    def set_loading(self, state: bool):
        if state:
            self.configure(state="disabled", text="⏳  " + self["text"])
        else:
            self.configure(state="normal",   text=self["text"].replace("⏳  ",""))
```

### 5.3 Labeled Input Field
```python
class LabeledInput(tk.Frame):
    """Label + Entry + optional error/hint message."""
    def __init__(self, parent, label, placeholder="",
                 error="", hint="", password=False, **kw):
        super().__init__(parent, bg=T["bg_surface"], **kw)
        self.var = tk.StringVar()
        self._build(label, placeholder, error, hint, password)

    def _build(self, label, placeholder, error, hint, password):
        # Label
        tk.Label(self, text=label, font=F["label"],
                 fg=T["text_secondary"], bg=T["bg_surface"]
                 ).pack(anchor="w", pady=(0, T["space_1"]))

        # Entry wrapper (fake border with Frame)
        wrapper = tk.Frame(self,
                           bg=T["border_default"],
                           highlightthickness=0, padx=1, pady=1)
        wrapper.pack(fill="x")
        inner = tk.Frame(wrapper, bg=T["bg_raised"])
        inner.pack(fill="x")

        self.entry = tk.Entry(
            inner, textvariable=self.var,
            font=F["body"], show="●" if password else "",
            fg=T["text_primary"], bg=T["bg_raised"],
            insertbackground=T["accent"],
            selectbackground=T["accent_dim"],
            relief="flat", bd=0,
        )
        self.entry.pack(fill="x", padx=T["space_2"], pady=T["space_2"])

        # Placeholder logic
        if placeholder:
            self._placeholder = placeholder
            self.entry.insert(0, placeholder)
            self.entry.configure(fg=T["text_muted"])
            self.entry.bind("<FocusIn>",  self._clear_placeholder)
            self.entry.bind("<FocusOut>", self._restore_placeholder)

        # Focus border highlight
        self.entry.bind("<FocusIn>",  lambda e: wrapper.configure(bg=T["border_focus"]))
        self.entry.bind("<FocusOut>", lambda e: wrapper.configure(bg=T["border_default"]))

        # Hint or error
        if error:
            tk.Label(self, text=f"✗  {error}", font=F["caption"],
                     fg=T["error"], bg=T["bg_surface"]).pack(anchor="w")
        elif hint:
            tk.Label(self, text=hint, font=F["caption"],
                     fg=T["text_muted"], bg=T["bg_surface"]).pack(anchor="w")

    def _clear_placeholder(self, e=None):
        if self.entry.get() == self._placeholder:
            self.entry.delete(0, "end")
            self.entry.configure(fg=T["text_primary"])

    def _restore_placeholder(self, e=None):
        if not self.entry.get():
            self.entry.insert(0, self._placeholder)
            self.entry.configure(fg=T["text_muted"])

    def get(self):
        val = self.var.get()
        return "" if val == getattr(self, "_placeholder", None) else val
```

### 5.4 Toggle Switch (tkinter)
```python
class Toggle(tk.Canvas):
    """Animated toggle switch using Canvas."""
    def __init__(self, parent, variable: tk.BooleanVar = None,
                 command=None, **kw):
        super().__init__(parent, width=44, height=24,
                         bg=T["bg_surface"], highlightthickness=0, **kw)
        self.var = variable or tk.BooleanVar(value=False)
        self._command = command
        self._is_on = self.var.get()
        self._draw()
        self.bind("<Button-1>", self._toggle)
        self.configure(cursor="hand2")

    def _draw(self):
        self.delete("all")
        on = self._is_on
        track_color = T["accent"] if on else T["bg_overlay"]
        self.create_rounded_rect(2, 4, 42, 20, radius=8, fill=track_color, outline="")
        knob_x = 28 if on else 14
        self.create_oval(knob_x-8, 4, knob_x+8, 20,
                         fill=T["text_primary"], outline="")

    def create_rounded_rect(self, x1, y1, x2, y2, radius, **kw):
        pts = [x1+radius,y1, x2-radius,y1, x2,y1,
               x2,y1+radius, x2,y2-radius, x2,y2,
               x2-radius,y2, x1+radius,y2, x1,y2,
               x1,y2-radius, x1,y1+radius, x1,y1]
        return self.create_polygon(pts, smooth=True, **kw)

    def _toggle(self, e=None):
        self._is_on = not self._is_on
        self.var.set(self._is_on)
        self._animate(steps=6)
        if self._command:
            self._command(self._is_on)

    def _animate(self, steps=6, current=0):
        if current <= steps:
            self._draw()
            self.after(16, lambda: self._animate(steps, current+1))
```

### 5.5 Status Badge / Chip
```python
class Badge(tk.Label):
    """
    status: "success" | "warning" | "error" | "info" | "neutral"
    """
    COLORS = {
        "success": (T["success_dim"], T["success"]),
        "warning": (T["warning_dim"], T["warning"]),
        "error":   (T["error_dim"],   T["error"]),
        "info":    (T["info_dim"],     T["info"]),
        "neutral": (T["bg_raised"],   T["text_secondary"]),
    }
    def __init__(self, parent, text, status="neutral", dot=True, **kw):
        bg, fg = self.COLORS[status]
        prefix = "● " if dot else ""
        super().__init__(parent, text=f"{prefix}{text}",
                         font=F["caption"],
                         fg=fg, bg=bg,
                         padx=T["space_2"], pady=2,
                         **kw)
```

### 5.6 Console / Log Widget
```python
class ConsoleWidget(tk.Frame):
    TAGS = {
        "info":    "#60b0f4",
        "success": "#4ade80",
        "warning": "#fbbf24",
        "error":   "#f87171",
        "cmd":     "#c084fc",
        "dim":     "#55557a",
        "bold":    None,  # weight handled separately
    }

    def __init__(self, parent, **kw):
        super().__init__(parent, bg=T["bg_base"], **kw)
        self._build()

    def _build(self):
        hdr = tk.Frame(self, bg=T["bg_raised"])
        hdr.pack(fill="x")
        tk.Label(hdr, text="  Console", font=F["label"],
                 fg=T["text_muted"], bg=T["bg_raised"], pady=5
                 ).pack(side="left")
        Button(hdr, "Clear", command=self.clear,
               variant="ghost", size="sm").pack(side="right", padx=4)

        from tkinter.scrolledtext import ScrolledText
        self.text = ScrolledText(
            self, bg=T["bg_base"], fg="#cdd6f4",
            font=F["mono"], insertbackground=T["accent"],
            relief="flat", bd=0, state="disabled",
            wrap="word", padx=T["space_4"], pady=T["space_2"],
        )
        self.text.pack(fill="both", expand=True)
        for tag, color in self.TAGS.items():
            if color:
                self.text.tag_config(tag, foreground=color)
        self.text.tag_config("bold", font=F["mono_lg"])

    def write(self, text: str, level="info"):
        import re
        clean = re.sub(r'\x1b\[[0-9;]*[mGKHF]', '', text)
        tag = self._auto_tag(clean) if level == "auto" else level
        self.text.configure(state="normal")
        self.text.insert("end", clean, tag)
        self.text.configure(state="disabled")
        self.text.see("end")

    def _auto_tag(self, line: str) -> str:
        l = line.lower()
        if any(x in l for x in ["✔","ok:","success","✓","done","complete"]): return "success"
        if any(x in l for x in ["✗","error","fail","critical"]):              return "error"
        if any(x in l for x in ["!","warn","⚠","caution"]):                   return "warning"
        if any(x in l for x in ["cmd:","$","sudo","dnf","pip","cargo"]):      return "cmd"
        if any(x in l for x in ["·","info:","loading","installing"]):         return "info"
        return "dim"

    def clear(self):
        self.text.configure(state="normal")
        self.text.delete("1.0", "end")
        self.text.configure(state="disabled")
```

---

## 6. Sidebar + Content Layout (PyQt6 canonical pattern)

```python
from PyQt6.QtWidgets import (QMainWindow, QWidget, QHBoxLayout,
                              QVBoxLayout, QPushButton, QStackedWidget)
from PyQt6.QtCore import Qt

class SidebarApp(QMainWindow):
    NAV_ITEMS = [
        ("🏠", "Inicio",      0),
        ("📊", "Dashboard",   1),
        ("⚙️",  "Ajustes",    2),
    ]

    def __init__(self):
        super().__init__()
        self.setWindowTitle("App")
        self.resize(1100, 700)
        self._build()

    def _build(self):
        root = QWidget(); self.setCentralWidget(root)
        layout = QHBoxLayout(root); layout.setContentsMargins(0,0,0,0); layout.setSpacing(0)

        # ── Sidebar ──
        sidebar = QWidget(); sidebar.setFixedWidth(220)
        sidebar.setStyleSheet(f"background: {T['bg_card']}; border-right: 1px solid {T['border_subtle']};")
        sb_layout = QVBoxLayout(sidebar); sb_layout.setContentsMargins(0, 16, 0, 16)

        self.pages = QStackedWidget()
        self._nav_btns = []

        for icon, label, page_idx in self.NAV_ITEMS:
            btn = QPushButton(f"  {icon}  {label}")
            btn.setCursor(Qt.CursorShape.PointingHandCursor)
            btn.setCheckable(True)
            btn.clicked.connect(lambda _, idx=page_idx: self._navigate(idx))
            btn.setStyleSheet(self._nav_btn_style())
            sb_layout.addWidget(btn)
            self._nav_btns.append(btn)
            self.pages.addWidget(self._make_page(label))

        sb_layout.addStretch()
        layout.addWidget(sidebar)
        layout.addWidget(self.pages)
        self._navigate(0)

    def _navigate(self, index):
        self.pages.setCurrentIndex(index)
        for i, btn in enumerate(self._nav_btns):
            btn.setChecked(i == index)

    def _nav_btn_style(self):
        return f"""
            QPushButton {{
                text-align: left; padding: 10px 20px;
                font-size: 13px; font-weight: 500;
                color: {T['text_secondary']};
                background: transparent; border: none;
            }}
            QPushButton:hover {{
                background: {T['bg_hover']};
                color: {T['text_primary']};
            }}
            QPushButton:checked {{
                background: {T['accent_dim']};
                color: {T['accent']};
                border-left: 3px solid {T['accent']};
            }}
        """

    def _make_page(self, name):
        w = QWidget()
        w.setStyleSheet(f"background: {T['bg_surface']};")
        return w
```

---

## 7. Threading — Never Block the UI

**The cardinal sin of desktop development**: running slow operations on the main thread.

### tkinter — threading.Thread pattern
```python
import threading

class InstallTask:
    def __init__(self, on_progress, on_output, on_done):
        self._on_progress = on_progress
        self._on_output   = on_output
        self._on_done     = on_done
        self._thread = None
        self._cancelled = False

    def start(self, cmd: list[str]):
        self._cancelled = False
        self._thread = threading.Thread(target=self._run, args=(cmd,), daemon=True)
        self._thread.start()

    def cancel(self):
        self._cancelled = True

    def _run(self, cmd):
        import subprocess
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, text=True)
            for line in proc.stdout:
                if self._cancelled:
                    proc.terminate()
                    break
                self._on_output(line)  # will call root.after() internally
            proc.wait()
            self._on_done(proc.returncode == 0)
        except Exception as e:
            self._on_output(f"ERROR: {e}\n")
            self._on_done(False)

# In the GUI:
def _on_output(self, line):
    # MUST use root.after to safely update from thread
    self.root.after(0, lambda: self.console.write(line, "auto"))
```

### PyQt6 — QThread + Signals pattern (preferred)
```python
from PyQt6.QtCore import QThread, pyqtSignal

class WorkerThread(QThread):
    progress  = pyqtSignal(int)      # 0-100
    output    = pyqtSignal(str, str) # (text, level)
    finished  = pyqtSignal(bool)     # success

    def __init__(self, cmd: list[str]):
        super().__init__()
        self._cmd = cmd
        self._cancelled = False

    def cancel(self): self._cancelled = True

    def run(self):
        import subprocess
        proc = subprocess.Popen(self._cmd, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, text=True)
        for line in proc.stdout:
            if self._cancelled:
                proc.terminate(); break
            self.output.emit(line, "auto")
        proc.wait()
        self.finished.emit(proc.returncode == 0)

# Usage:
self.worker = WorkerThread(["bash", "setup.sh"])
self.worker.output.connect(self.console.append_line)
self.worker.finished.connect(self.on_done)
self.worker.start()
```

---

## 8. Dark / Light Mode System

```python
import json, os

class ThemeManager:
    CONFIG_PATH = os.path.expanduser("~/.config/myapp/settings.json")

    def __init__(self, root: tk.Tk):
        self.root = root
        self._dark = self._load_preference()
        self._subscribers = []  # callbacks(tokens_dict)

    def subscribe(self, callback):
        self._subscribers.append(callback)

    def toggle(self):
        self._dark = not self._dark
        self._save_preference()
        self._apply()

    def _apply(self):
        global T
        T = TOKENS if self._dark else TOKENS_LIGHT
        for cb in self._subscribers:
            cb(T)

    def _load_preference(self) -> bool:
        try:
            with open(self.CONFIG_PATH) as f:
                return json.load(f).get("dark_mode", True)
        except (FileNotFoundError, json.JSONDecodeError):
            return True

    def _save_preference(self):
        os.makedirs(os.path.dirname(self.CONFIG_PATH), exist_ok=True)
        with open(self.CONFIG_PATH, "w") as f:
            json.dump({"dark_mode": self._dark}, f)
```

---

## 9. Window Management — Professional Patterns

### Center Window on Screen
```python
def center_window(window: tk.Tk, width: int, height: int):
    window.update_idletasks()
    sw = window.winfo_screenwidth()
    sh = window.winfo_screenheight()
    x = (sw - width) // 2
    y = max(0, (sh - height) // 2 - 40)  # -40: account for taskbar
    window.geometry(f"{width}x{height}+{x}+{y}")
```

### HiDPI / Retina Scaling
```python
import ctypes, sys

def enable_hidpi():
    if sys.platform == "win32":
        ctypes.windll.shcore.SetProcessDpiAwareness(2)  # PROCESS_PER_MONITOR_DPI_AWARE
    # macOS: handled automatically by tkinter
    # Linux: set Tk scaling
    root.tk.call("tk", "scaling", 1.5)  # 150% — detect from screen

def get_screen_dpi(root: tk.Tk) -> float:
    dpi = root.winfo_fpixels("1i")  # pixels per inch
    return dpi / 96.0  # 1.0 = normal, 2.0 = retina
```

### Splash Screen Pattern
```python
class SplashScreen(tk.Toplevel):
    def __init__(self, root, duration_ms=2500):
        super().__init__(root)
        self.overrideredirect(True)   # no title bar
        self.configure(bg=T["bg_base"])
        self._build()
        center_window(self, 480, 280)
        self.after(duration_ms, self.destroy)

    def _build(self):
        tk.Label(self, text="AppName", font=F["display"],
                 fg=T["accent"], bg=T["bg_base"]).pack(expand=True)
        self.progress_var = tk.DoubleVar(value=0)
        # ... animate progress bar
```

### Modal Dialog (proper implementation)
```python
class ConfirmDialog(tk.Toplevel):
    def __init__(self, parent, title, message, ok_text="Confirmar", cancel_text="Cancelar"):
        super().__init__(parent)
        self.result = False
        self.title(title)
        self.configure(bg=T["bg_card"])
        self.resizable(False, False)
        self.transient(parent)
        self.grab_set()             # modal — blocks parent
        self._build(message, ok_text, cancel_text)
        center_window(self, 420, 200)
        self.wait_window()          # blocks until self.destroy()

    def _build(self, message, ok_text, cancel_text):
        tk.Label(self, text=message, font=F["body_lg"],
                 fg=T["text_primary"], bg=T["bg_card"],
                 wraplength=360, justify="left",
                 padx=24, pady=20).pack()
        btn_row = tk.Frame(self, bg=T["bg_card"])
        btn_row.pack(fill="x", padx=24, pady=(0,16))
        Button(btn_row, cancel_text, command=self.destroy,
               variant="secondary").pack(side="right", padx=(8,0))
        Button(btn_row, ok_text, command=self._ok,
               variant="primary").pack(side="right")

    def _ok(self):
        self.result = True
        self.destroy()
```

---

## 10. Progress & Feedback Patterns

### Indeterminate Progress (animated)
```python
class SpinnerWidget(tk.Canvas):
    def __init__(self, parent, size=32, **kw):
        super().__init__(parent, width=size, height=size,
                         bg=T["bg_surface"], highlightthickness=0, **kw)
        self._size = size
        self._angle = 0
        self._active = False

    def start(self):
        self._active = True
        self._spin()

    def stop(self):
        self._active = False
        self.delete("all")

    def _spin(self):
        if not self._active: return
        self.delete("all")
        s = self._size
        m = s // 2
        r = m - 4
        import math
        start = self._angle
        extent = 270
        x0, y0 = m-r, m-r
        x1, y1 = m+r, m+r
        self.create_arc(x0, y0, x1, y1,
                        start=start, extent=extent,
                        style="arc", outline=T["accent"], width=3)
        self._angle = (self._angle + 12) % 360
        self.after(30, self._spin)
```

### Animated Progress Bar (tkinter)
```python
class ProgressBar(tk.Frame):
    def __init__(self, parent, height=6, **kw):
        super().__init__(parent, bg=T["bg_raised"],
                         height=height, **kw)
        self.propagate(False)
        self._bar = tk.Frame(self, bg=T["accent"], height=height)
        self._bar.place(x=0, y=0, relheight=1, width=0)
        self._value = 0

    def set(self, percent: float, animate=True):
        target_w = int(self.winfo_width() * min(percent/100, 1.0))
        if animate:
            self._animate_to(target_w)
        else:
            self._bar.place(width=target_w)

    def _animate_to(self, target_w, current_w=None, steps=8):
        if current_w is None:
            current_w = self._bar.winfo_width()
        if abs(current_w - target_w) < 2:
            self._bar.place(width=target_w)
            return
        new_w = current_w + (target_w - current_w) // 3
        self._bar.place(width=new_w)
        self.after(16, lambda: self._animate_to(target_w, new_w, steps-1))
```

---

## 11. Notification / Toast System

```python
class Toast(tk.Toplevel):
    """Non-blocking notification that fades out."""
    LEVELS = {
        "success": T["success"],
        "warning": T["warning"],
        "error":   T["error"],
        "info":    T["accent"],
    }

    def __init__(self, root, message, level="info", duration_ms=3000):
        super().__init__(root)
        self.overrideredirect(True)
        self.attributes("-topmost", True)
        try: self.attributes("-alpha", 0.0)  # start transparent
        except: pass
        color = self.LEVELS.get(level, T["accent"])
        self._build(message, color)
        self._position(root)
        self._fade_in()
        self.after(duration_ms, self._fade_out)

    def _build(self, message, color):
        self.configure(bg=T["bg_overlay"])
        tk.Frame(self, bg=color, width=4).pack(side="left", fill="y")
        tk.Label(self, text=f"  {message}  ",
                 font=F["body"], fg=T["text_primary"],
                 bg=T["bg_overlay"], pady=12).pack(side="left")

    def _position(self, root):
        self.update_idletasks()
        rx = root.winfo_x() + root.winfo_width() - self.winfo_width() - 24
        ry = root.winfo_y() + root.winfo_height() - self.winfo_height() - 24
        self.geometry(f"+{rx}+{ry}")

    def _fade_in(self, alpha=0.0):
        if alpha < 0.95:
            try: self.attributes("-alpha", alpha)
            except: pass
            self.after(20, lambda: self._fade_in(min(alpha + 0.1, 0.95)))

    def _fade_out(self, alpha=0.95):
        if alpha > 0.0:
            try: self.attributes("-alpha", alpha)
            except: pass
            self.after(25, lambda: self._fade_out(max(alpha - 0.1, 0)))
        else:
            self.destroy()

def show_toast(root, message, level="info"):
    Toast(root, message, level)
```

---

## 12. Accessibility Standards

### Keyboard Navigation (tkinter)
```python
def setup_keyboard_nav(root: tk.Tk):
    # Tab order is set by widget creation order by default
    # Override with: widget.tk_focusNext()

    # Global hotkeys
    root.bind("<Control-q>",     lambda e: root.destroy())
    root.bind("<F11>",           lambda e: toggle_fullscreen(root))
    root.bind("<Escape>",        lambda e: root.focus_set())

    # Enter activates focused button
    root.bind_class("Button", "<Return>", lambda e: e.widget.invoke())
    root.bind_class("Button", "<space>",  lambda e: e.widget.invoke())
```

### Focus Ring (custom)
```python
def add_focus_ring(widget: tk.Widget, parent: tk.Frame):
    """Wraps widget in a Frame that highlights on focus."""
    widget.bind("<FocusIn>",  lambda e: parent.configure(
        highlightbackground=T["border_focus"], highlightthickness=2))
    widget.bind("<FocusOut>", lambda e: parent.configure(
        highlightbackground=T["border_subtle"], highlightthickness=1))
```

### WCAG Contrast Checker
```python
def contrast_ratio(hex1: str, hex2: str) -> float:
    """Returns WCAG contrast ratio. Must be ≥4.5 for normal text, ≥3.0 for large."""
    def luminance(h):
        r,g,b = int(h[1:3],16)/255, int(h[3:5],16)/255, int(h[5:7],16)/255
        def lin(c): return c/12.92 if c<=0.04045 else ((c+0.055)/1.055)**2.4
        return 0.2126*lin(r) + 0.7152*lin(g) + 0.0722*lin(b)
    l1, l2 = luminance(hex1), luminance(hex2)
    lighter, darker = max(l1,l2), min(l1,l2)
    return (lighter + 0.05) / (darker + 0.05)

# Verify your token pairs:
assert contrast_ratio(T["text_primary"],  T["bg_surface"]) >= 4.5
assert contrast_ratio(T["text_secondary"],T["bg_surface"]) >= 3.0
```

---

## 13. PyQt6 Stylesheet System — QSS Best Practices

```python
GLOBAL_QSS = f"""
/* ── Reset ────────────────────────────────────────────────── */
* {{
    font-family: 'Inter', 'Noto Sans', sans-serif;
    font-size: 10pt;
    color: {T['text_primary']};
    outline: none;
}}

/* ── Window ────────────────────────────────────────────────── */
QMainWindow, QDialog {{
    background: {T['bg_surface']};
}}

/* ── Buttons ────────────────────────────────────────────────── */
QPushButton {{
    background: {T['bg_raised']};
    color: {T['text_primary']};
    border: 1px solid {T['border_default']};
    border-radius: 6px;
    padding: 7px 16px;
    font-weight: 500;
}}
QPushButton:hover    {{ background: {T['bg_hover']}; border-color: {T['border_focus']}; }}
QPushButton:pressed  {{ background: {T['bg_overlay']}; }}
QPushButton:disabled {{ opacity: 0.4; }}
QPushButton[class="primary"] {{
    background: {T['accent']};
    color: {T['text_inverse']};
    border: none;
}}
QPushButton[class="primary"]:hover {{ background: {T['accent_hover']}; }}

/* ── Inputs ────────────────────────────────────────────────── */
QLineEdit, QTextEdit, QPlainTextEdit {{
    background: {T['bg_raised']};
    border: 1px solid {T['border_default']};
    border-radius: 6px;
    padding: 6px 10px;
    selection-background-color: {T['accent_dim']};
}}
QLineEdit:focus, QTextEdit:focus {{
    border-color: {T['border_focus']};
}}

/* ── Scrollbar ────────────────────────────────────────────── */
QScrollBar:vertical {{
    background: {T['bg_raised']};
    width: 8px;
    border-radius: 4px;
}}
QScrollBar::handle:vertical {{
    background: {T['border_default']};
    min-height: 30px;
    border-radius: 4px;
}}
QScrollBar::handle:vertical:hover {{
    background: {T['text_muted']};
}}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{ height: 0px; }}

/* ── ComboBox ────────────────────────────────────────────── */
QComboBox {{
    background: {T['bg_raised']};
    border: 1px solid {T['border_default']};
    border-radius: 6px;
    padding: 6px 10px;
    min-width: 120px;
}}
QComboBox::drop-down {{ border: none; width: 20px; }}
QComboBox QAbstractItemView {{
    background: {T['bg_overlay']};
    border: 1px solid {T['border_default']};
    selection-background-color: {T['accent_dim']};
}}
"""
```

---

## 14. Anti-Patterns — Never Do These

```
❌  Hardcoded colors inline:  bg="#1a1a2e"  →  ✅ bg=T["bg_card"]
❌  Mixing pack() and grid() in the same container — crashes with TclError
❌  Running subprocess/IO on the main thread — freezes the UI
❌  root.update() inside loops — flickering and input locks
❌  Overusing place() for layout — breaks on resize
❌  Labels with no wraplength on variable-length text — overflow
❌  Forgetting bind_all("<MouseWheel>") for scrollable canvases on Linux
❌  Not calling update_idletasks() before reading winfo_width() — returns 1
❌  Using tk.Button relief="sunken/raised" — looks ancient; always "flat"
❌  Global fonts without platform detection — wrong rendering on each OS
❌  Building the entire UI in __init__ — use a _build() method
❌  Forgetting daemon=True on background threads — app hangs on close
❌  Calling GUI methods from threads directly — race conditions; use root.after(0, ...)
❌  PyQt6: calling QThread.quit() without wait() — segfaults on exit
```

---

## 15. App Architecture — Clean Structure

```
myapp/
├── main.py                 # Entry: App(), root.mainloop()
├── app.py                  # Main window class
├── theme.py                # Tokens, ThemeManager
├── fonts.py                # Font detection and F dict
├── widgets/
│   ├── __init__.py
│   ├── button.py           # Button, IconButton
│   ├── card.py             # Card, ClickableCard
│   ├── input.py            # LabeledInput, SearchField
│   ├── console.py          # ConsoleWidget
│   ├── progress.py         # ProgressBar, Spinner
│   ├── toast.py            # Toast, NotificationQueue
│   └── dialog.py           # ConfirmDialog, AlertDialog
├── pages/
│   ├── home.py
│   ├── settings.py
│   └── about.py
├── services/
│   ├── installer.py        # Business logic
│   └── config.py           # Persistence
└── assets/
    ├── icons/
    └── fonts/
```

### Main Window Skeleton
```python
class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.theme = ThemeManager(self)
        self._setup_window()
        self._build_ui()
        self.theme.subscribe(self._on_theme_change)

    def _setup_window(self):
        self.title("My App")
        self.configure(bg=T["bg_surface"])
        self.minsize(800, 600)
        center_window(self, 1100, 720)

    def _build_ui(self):
        self._build_header()
        self._build_body()
        self._build_footer()

    def _on_theme_change(self, new_tokens):
        # Rebuild UI with new theme — or surgically update widgets
        self._build_ui()  # simplest; optimize later if needed

    def run(self):
        self.mainloop()

if __name__ == "__main__":
    App().run()
```

---

## 16. Checklist Before Delivering a GUI

Before calling any GUI done, verify:

- [ ] All colors reference tokens — no hardcoded hex values in widget calls
- [ ] Window centers on screen with `center_window()`
- [ ] Minimum window size set with `minsize()`
- [ ] All slow operations run in a background thread via `threading.Thread` or `QThread`
- [ ] Background threads use `root.after(0, fn)` to update the UI safely
- [ ] Background threads are `daemon=True` so app closes cleanly
- [ ] Dark and light themes both render correctly (if toggle is implemented)
- [ ] Scrollable areas have MouseWheel bindings for Linux (Button-4, Button-5)
- [ ] `winfo_width()` calls are preceded by `update_idletasks()`
- [ ] Fonts fall back gracefully across platforms
- [ ] Buttons have `cursor="hand2"` (pointer on hover)
- [ ] Modal dialogs use `transient()` + `grab_set()` + `wait_window()`
- [ ] Long text Labels have a sensible `wraplength`
- [ ] WCAG contrast ≥ 4.5:1 for body text
- [ ] Tab/keyboard navigation works logically
- [ ] App icon set: `root.iconphoto(True, PhotoImage(file="icon.png"))`
- [ ] `atexit` or `protocol("WM_DELETE_WINDOW")` saves user settings on close
