import tkinter as tk
from tkinter import scrolledtext
import re
from gui.theme import T, F

class ConsoleWidget(tk.Frame):
    TAGS = {
        "info":    "#60b0f4",
        "success": "#4ade80",
        "warning": "#fbbf24",
        "error":   "#f87171",
        "cmd":     "#c084fc",
        "dim":     "#55557a",
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

        self.text = scrolledtext.ScrolledText(
            self, bg=T["bg_base"], fg="#cdd6f4",
            font=F["mono"], insertbackground=T["accent"],
            relief="flat", bd=0, state="disabled",
            wrap="word", padx=T["space_4"], pady=T["space_2"],
        )
        self.text.pack(fill="both", expand=True)
        for tag, color in self.TAGS.items():
            if color:
                self.text.tag_config(tag, foreground=color)

    def write(self, text, level="info"):
        clean = re.sub(r'\x1b\[[0-9;]*[mGKHF]', '', text)
        tag = self._auto_tag(clean) if level == "auto" else level
        self.text.configure(state="normal")
        self.text.insert("end", clean, tag)
        self.text.configure(state="disabled")
        self.text.see("end")

    def _auto_tag(self, line):
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
