import json
import os
import platform

TOKENS = {
    "bg_base":      "#0d0d14",
    "bg_surface":   "#13131f",
    "bg_card":      "#1a1a2c",
    "bg_raised":    "#222238",
    "bg_overlay":   "#2c2c48",
    "bg_hover":     "#30305a",

    "border_subtle": "#252540",
    "border_default":"#38385e",
    "border_focus":  "#60b0f4",

    "accent":        "#60b0f4",
    "accent_hover":  "#4d9fe0",
    "accent_dim":    "#1a3a5c",
    "accent_text":   "#93c7f7",

    "success":  "#4ade80",  "success_dim":  "#14532d",
    "warning":  "#fbbf24",  "warning_dim":  "#78350f",
    "error":    "#f87171",  "error_dim":    "#7f1d1d",
    "info":     "#60b0f4",  "info_dim":     "#1e3a5f",

    "text_primary":   "#e8e8f0",
    "text_secondary": "#9898b8",
    "text_muted":     "#55557a",
    "text_inverse":   "#0d0d14",

    "font_xs":   8,
    "font_sm":   9,
    "font_base": 10,
    "font_md":   11,
    "font_lg":   13,
    "font_xl":   16,
    "font_2xl":  20,
    "font_3xl":  26,

    "space_1":  4,   "space_2":  8,  "space_3": 12,
    "space_4": 16,   "space_5": 20, "space_6": 24,
    "space_8": 32,   "space_10":40, "space_12":48,

    "radius_sm":  3,
    "radius_md":  6,
    "radius_lg":  10,
    "radius_xl":  16,
    "radius_full": 999,
}

T = TOKENS

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

import tkinter.font as tkfont

def first_available_font(candidates):
    available = set(tkfont.families())
    for f in candidates:
        if f in available:
            return f
    return candidates[-1]

FONT_STACK = first_available_font(get_system_fonts()["sans"])
MONO_STACK = first_available_font(get_system_fonts()["mono"])

F = {
    "display":    (FONT_STACK, 26, "bold"),
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


class ThemeManager:
    CONFIG_PATH = os.path.expanduser("~/.config/fedora-setup/settings.json")

    def __init__(self, root):
        self.root = root
        self._dark = self._load_preference()
        self._subscribers = []

    def subscribe(self, callback):
        self._subscribers.append(callback)

    def toggle(self):
        self._dark = not self._dark
        self._save_preference()
        self._apply()

    def _apply(self):
        global T
        for cb in self._subscribers:
            cb(T)

    def _load_preference(self):
        try:
            with open(self.CONFIG_PATH) as f:
                return json.load(f).get("dark_mode", True)
        except (FileNotFoundError, json.JSONDecodeError):
            return True

    def _save_preference(self):
        os.makedirs(os.path.dirname(self.CONFIG_PATH), exist_ok=True)
        with open(self.CONFIG_PATH, "w") as f:
            json.dump({"dark_mode": self._dark}, f)


def center_window(window, width, height):
    window.update_idletasks()
    sw = window.winfo_screenwidth()
    sh = window.winfo_screenheight()
    x = (sw - width) // 2
    y = max(0, (sh - height) // 2 - 40)
    window.geometry(f"{width}x{height}+{x}+{y}")
