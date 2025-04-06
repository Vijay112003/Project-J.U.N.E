import tkinter as tk

class MacroApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Macro Recorder App")
        self.geometry("800x600")
        self.minsize(800, 600)
        
        # Create container frame
        container = tk.Frame(self)
        container.pack(fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)
        
        # Initialize frames dictionary
        self.frames = {}
        
        # Import page classes here to avoid circular imports
        from frontend.home_ui import HomePage
        from frontend.recorder_ui import RecorderPage
        from frontend.player_ui import PlayerPage
        from frontend.editor_ui import EditorPage
        
        # Create a list of page classes
        pages = (HomePage, RecorderPage, PlayerPage, EditorPage)
        
        # Initialize frames
        for F in pages:
            # Instead of using keyword arguments, use positional arguments
            # This way, whether the class defines them as 'parent' or not doesn't matter
            frame = F(container, self)
            frame.grid(row=0, column=0, sticky="nsew")
            self.frames[F.__name__] = frame
        
        # Show the home page initially
        self.show_frame("HomePage")
    
    def show_frame(self, page_name):
        """Raise the selected frame to the top"""
        frame = self.frames[page_name]
        frame.tkraise()

if __name__ == "__main__":
    app = MacroApp()
    app.mainloop()