import tkinter as tk
from tkinter import ttk

class HomePage(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.setup_ui()
        
    def setup_ui(self):
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)
        
        content = ttk.Frame(self)
        content.grid(row=0, column=0, sticky="nsew")
        
        ttk.Label(content, text="Macro Recorder App", font=("Arial", 16)).pack(pady=20)
        
        buttons = [
            ("Recorder", "RecorderPage"),
            ("Player", "PlayerPage"),
            ("Editor", "EditorPage")
        ]
        
        for text, page_name in buttons:
            ttk.Button(
                content, 
                text=text, 
                command=lambda p=page_name: self.controller.show_frame(p)
            ).pack(pady=5, ipadx=10, ipady=5)