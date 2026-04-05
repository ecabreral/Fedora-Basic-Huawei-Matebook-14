import tkinter as tk
from gui.theme import T

class ProgressBar(tk.Frame):
    def __init__(self, parent, height=6, **kw):
        super().__init__(parent, bg=T["bg_raised"], height=height, **kw)
        self.propagate(False)
        self._bar = tk.Frame(self, bg=T["accent"], height=height)
        self._bar.place(x=0, y=0, relheight=1, width=0)
        self._value = 0

    def set(self, percent, animate=True):
        self.update_idletasks()
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
        if not self._active:
            return
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
