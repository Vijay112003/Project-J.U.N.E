import tkinter as tk
from tkinter import ttk
from backend.recording import MacroRecorder
import threading

class RecorderPage(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.recorder = MacroRecorder(capture_mouse_path=False)
        
        ttk.Label(self, text="Recorder Page", font=("Arial", 14)).pack(pady=10)

        self.record_btn = ttk.Button(self, text="Start Recording", command=self.start_recording)
        self.record_btn.pack(pady=5)

        # Status label with colored backgrounds for different states
        self.status = tk.Label(self, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.status.pack(fill=tk.X, pady=5)
        self.update_status("Ready", "lightgray")
        
        self.log_frame = tk.Frame(self)
        self.log_frame.pack(pady=5, fill=tk.BOTH, expand=True)
        
        self.log_text = tk.Text(self.log_frame, height=10, state=tk.DISABLED, wrap=tk.WORD)
        self.log_text.pack(fill=tk.BOTH, expand=True)
        
        # Configure text colors for different event types
        self.log_text.tag_config("key", foreground="blue")
        self.log_text.tag_config("mouse", foreground="red")
        self.log_text.tag_config("system", foreground="green")
        
        ttk.Button(self, text="Back to Home", command=self.show_home).pack(pady=10)

    def show_home(self):
        from frontend.home_ui import HomePage
        self.controller.show_frame(HomePage)
    
    def update_status(self, text, bg_color):
        """Update status label with text and background color"""
        self.status.config(text=text, bg=bg_color)
    
    def start_recording(self):
        self.record_btn.config(state=tk.DISABLED)
        self.update_status("Recording... Press ESC to stop", "yellow")
        self.clear_log()
        
        # Set the callback for the recorder
        self.recorder.set_callback(self.log_event)
        
        def record():
            self.recorder.record_macro()
            self.after(0, lambda: self.update_status("Recording complete", "lightgreen"))
            self.after(0, lambda: self.record_btn.config(state=tk.NORMAL))

        threading.Thread(target=record, daemon=True).start()
    
    def clear_log(self):
        """Clear the log text"""
        self.log_text.config(state=tk.NORMAL)
        self.log_text.delete(1.0, tk.END)
        self.log_text.config(state=tk.DISABLED)
    
    def log_event(self, event_type, details):
        """Log events with appropriate colors"""
        self.log_text.config(state=tk.NORMAL)
        
        # Determine tag based on event type
        tag = "system"
        if "key" in event_type:
            tag = "key"
        elif "mouse" in event_type:
            tag = "mouse"
        
        self.log_text.insert(tk.END, f"{event_type}: {details}\n", (tag,))
        self.log_text.see(tk.END)
        self.log_text.config(state=tk.DISABLED)