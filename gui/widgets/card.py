import tkinter as tk
from gui.theme import T, F

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
        tk.Frame(self, bg=T["border_subtle"], height=1).pack(fill="x")
        self.body = tk.Frame(self, bg=T["bg_card"])
        self.body.pack(fill="both", expand=True, padx=T["space_4"], pady=T["space_4"])
