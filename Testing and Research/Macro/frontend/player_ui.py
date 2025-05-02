import tkinter as tk
import threading
from backend.database import fetch_all_macros
from backend.player import MacroPlayer

class PlayerPage(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.player = MacroPlayer()

        tk.Label(self, text="Player Page", font=("Arial", 14)).pack(pady=10)

        # Fetch macros from DB
        self.macros = fetch_all_macros()
        self.macro_map = {f"{m[0]}: {m[1]}": m[4] for m in self.macros}  # display name -> json_path

        # Prepare dropdown options and initial value
        options = list(self.macro_map.keys())
        initial_value = options[0] if options else "No macros available"

        self.selected_macro = tk.StringVar(self)
        self.selected_macro.set(initial_value)

        self.dropdown = tk.OptionMenu(self, self.selected_macro, initial_value, *options)
        self.dropdown.pack(pady=5)

        self.play_btn = tk.Button(self, text="Play Selected Macro", command=self.play_selected_macro)
        self.play_btn.pack(pady=5)

        self.status = tk.Label(self, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.status.pack(fill=tk.X, pady=5)

        from frontend.home_ui import HomePage
        tk.Button(self, text="Back to Home", command=lambda: controller.show_frame(HomePage)).pack(pady=10)

    def play_selected_macro(self):
        macro_display_name = self.selected_macro.get()
        json_path = self.macro_map.get(macro_display_name)

        if not json_path or macro_display_name == "No macros available":
            self.status.config(text="Please select a valid macro!")
            return

        self.play_btn.config(state=tk.DISABLED)
        self.status.config(text=f"Playing: {macro_display_name}")

        def play():
            self.player.play_macro(filename=json_path)
            self.after(0, lambda: self.status.config(text="Playback complete"))
            self.after(0, lambda: self.play_btn.config(state=tk.NORMAL))

        threading.Thread(target=play, daemon=True).start()
