import tkinter as tk
from tkinter import ttk
import sys
from datetime import datetime

class LogDisplay(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("J.U.N.E Logs")
        self.geometry("600x400")
        self.setup_styles()
        self.create_widgets()
        self.center_window()
        
        # Redirect stdout and stderr to the log window
        sys.stdout = self
        sys.stderr = self
        
    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('clam')
        style.configure("Title.TLabel", font=("Segoe UI", 16, "bold"))
        style.configure("Heading.TLabel", font=("Segoe UI", 12, "bold"))
        style.configure("Stop.TButton", 
                       font=("Segoe UI", 10, "bold"),
                       foreground="white",
                       background="#dc3545")
        style.map("Stop.TButton", background=[("active", "#bb2d3b")])
        
    def create_widgets(self):
        # Title and control frame
        header_frame = ttk.Frame(self, padding="10")
        header_frame.pack(fill=tk.X)
        
        # Title on the left
        ttk.Label(header_frame, text="📋 System Logs", style="Title.TLabel").pack(side=tk.LEFT)
        
        # Stop button on the right
        self.stop_btn = ttk.Button(header_frame, 
                                 text="⏹ Stop", 
                                 style="Stop.TButton",
                                 command=self.stop_application)
        self.stop_btn.pack(side=tk.RIGHT)
        
        # Log display area
        self.log_frame = ttk.Frame(self, padding="10")
        self.log_frame.pack(fill=tk.BOTH, expand=True)
        
        # Create text widget with scrollbar
        self.log_text = tk.Text(self.log_frame, wrap=tk.WORD, height=20)
        scrollbar = ttk.Scrollbar(self.log_frame, orient="vertical", command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        
        # Configure tags for different message types
        self.log_text.tag_configure("info", foreground="black")
        self.log_text.tag_configure("error", foreground="red")
        self.log_text.tag_configure("warning", foreground="orange")
        self.log_text.tag_configure("success", foreground="green")
        
        # Pack widgets
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
    def center_window(self):
        self.update_idletasks()
        width = self.winfo_width()
        height = self.winfo_height()
        x = (self.winfo_screenwidth() // 2) - (width // 2)
        y = (self.winfo_screenheight() // 2) - (height // 2)
        self.geometry(f'{width}x{height}+{x}+{y}')
        
    def write(self, text):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {text}")
        self.log_text.see(tk.END)
        
    def flush(self):
        pass
        
    def stop_application(self):
        print("Stopping application...")
        if hasattr(self, 'after_id'):
            self.after_cancel(self.after_id)
        self.quit()
        self.destroy()
        sys.exit(0)