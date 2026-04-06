import tkinter as tk
from tkinter import ttk
from gui.theme import T, F

class Button(tk.Button):
    STYLES = {
        "primary":   {"fg": T["text_inverse"], "bg": T["accent"],       "hover": T["accent_hover"]},
        "secondary": {"fg": T["text_primary"],  "bg": T["bg_raised"],    "hover": T["bg_overlay"]},
        "ghost":     {"fg": T["text_secondary"],"bg": "",               "hover": T["bg_hover"]},
        "danger":    {"fg": "#ffffff",           "bg": T["error"],        "hover": "#dc2020"},
        "success":   {"fg": "#ffffff",           "bg": T["success"],      "hover": "#16a34a"},
    }
    SIZES = {
        "sm":  {"font": F["btn_sm"], "padx": 10, "pady": 4},
        "md":  {"font": F["btn"],    "padx": 16, "pady": 7},
        "lg":  {"font": F["h3"],     "padx": 22, "pady": 10},
    }

    def __init__(self, parent, text, command=None, variant="primary", size="md", icon="", **kw):
        s = self.STYLES[variant]
        z = self.SIZES[size]
        label = f"{icon}  {text}" if icon else text
        super().__init__(
            parent, text=label, command=command,
            font=z["font"],
            fg=s["fg"], bg=s["bg"] if s["bg"] else parent["bg"],
            activeforeground=s["fg"], activebackground=s["hover"],
            relief="flat", bd=0, cursor="hand2",
            padx=z["padx"], pady=z["pady"],
            **kw,
        )
        self._bg_normal = s["bg"] if s["bg"] else parent["bg"]
        self._bg_hover  = s["hover"]
        self.bind("<Enter>", lambda e: self.configure(bg=self._bg_hover))
        self.bind("<Leave>", lambda e: self.configure(bg=self._bg_normal))

    def set_loading(self, state):
        if state:
            self.configure(state="disabled", text="⏳  " + self["text"])
        else:
            self.configure(state="normal",   text=self["text"].replace("⏳  ",""))
