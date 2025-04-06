import tkinter as tk
import threading
from backend.player import MacroPlayer  # Import MacroPlayer
from frontend.home_ui import HomePage  # Import HomePage for navigation

class PlayerPage(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.player = MacroPlayer()
        
        tk.Label(self, text="Player Page", font=("Arial", 14)).pack(pady=10)
        
        self.play_btn = tk.Button(self, text="Play Macro", command=self.play_macro)
        self.play_btn.pack(pady=5)
        
        self.status = tk.Label(self, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.status.pack(fill=tk.X, pady=5)
        
        tk.Button(self, text="Back to Home", command=lambda: controller.show_frame(HomePage)).pack(pady=10)
        
    def play_macro(self):
        self.play_btn.config(state=tk.DISABLED)
        self.status.config(text="Playing macro...")

        def play():
            self.player.play_macro()
            self.after(0, lambda: self.status.config(text="Playback complete"))
            self.after(0, lambda: self.play_btn.config(state=tk.NORMAL))
        
        threading.Thread(target=play, daemon=True).start()
