import os
import tkinter as tk
from tkinter import ttk, filedialog
from backend.recording import MacroRecorder
from backend.database import save_macro_to_db
import threading

class RecorderPage(tk.Frame):
    MACRO_SAVE_DIR = os.path.abspath("macros")  # Folder to save macros

    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.recorder = MacroRecorder(capture_mouse_path=False)

        # Ensure macro save directory exists
        os.makedirs(self.MACRO_SAVE_DIR, exist_ok=True)

        ttk.Label(self, text="Recorder Page", font=("Arial", 14)).pack(pady=10)

        # Name Entry
        ttk.Label(self, text="Macro Name:").pack()
        self.name_entry = ttk.Entry(self)
        self.name_entry.pack(pady=2)

        # Description Entry
        ttk.Label(self, text="Description:").pack()
        self.desc_entry = ttk.Entry(self)
        self.desc_entry.pack(pady=2)

        # Image Path (optional)
        self.image_path = tk.StringVar()
        ttk.Button(self, text="Choose Image (Optional)", command=self.select_image).pack(pady=5)

        self.record_btn = ttk.Button(self, text="Start Recording", command=self.start_recording)
        self.record_btn.pack(pady=5)

        self.status = tk.Label(self, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.status.pack(fill=tk.X, pady=5)
        self.update_status("Ready", "lightgray")

        self.log_frame = tk.Frame(self)
        self.log_frame.pack(pady=5, fill=tk.BOTH, expand=True)

        self.log_text = tk.Text(self.log_frame, height=10, state=tk.DISABLED, wrap=tk.WORD)
        self.log_text.pack(fill=tk.BOTH, expand=True)

        self.log_text.tag_config("key", foreground="blue")
        self.log_text.tag_config("mouse", foreground="red")
        self.log_text.tag_config("system", foreground="green")

        ttk.Button(self, text="Back to Home", command=self.show_home).pack(pady=10)

    def show_home(self):
        from frontend.home_ui import HomePage
        self.controller.show_frame(HomePage)

    def update_status(self, text, bg_color):
        self.status.config(text=text, bg=bg_color)

    def select_image(self):
        file = filedialog.askopenfilename(filetypes=[("Image Files", "*.png *.jpg *.jpeg *.bmp")])
        if file:
            self.image_path.set(file)
            self.update_status("Image selected", "lightblue")

    def start_recording(self):
        name = self.name_entry.get().strip()
        description = self.desc_entry.get().strip()
        image = self.image_path.get().strip()

        if not name:
            self.update_status("Please enter a macro name", "red")
            return

        # Sanitize name for filename (replace spaces with underscore)
        safe_name = "".join(c if c.isalnum() or c in (' ', '-', '_') else '_' for c in name).replace(" ", "_")
        json_filename = f"{safe_name}.json"

        # Full absolute path in macros folder
        json_path = os.path.join(self.MACRO_SAVE_DIR, json_filename)

        self.record_btn.config(state=tk.DISABLED)
        self.update_status("Recording... Press ESC to stop", "yellow")
        self.clear_log()

        self.recorder.set_callback(self.log_event)

        def record():
            try:
                # Pass absolute path to recorder
                self.recorder.record_macro(json_filename=json_path)
                # Save macro info to DB
                save_macro_to_db(name, description, image if image else None, json_path)
                self.after(0, lambda: self.update_status(f"Recording saved: {json_path}", "lightgreen"))
            except Exception as e:
                self.after(0, lambda: self.update_status(f"Error: {e}", "red"))
            finally:
                self.after(0, lambda: self.record_btn.config(state=tk.NORMAL))

        threading.Thread(target=record, daemon=True).start()

    def clear_log(self):
        self.log_text.config(state=tk.NORMAL)
        self.log_text.delete(1.0, tk.END)
        self.log_text.config(state=tk.DISABLED)

    def log_event(self, event_type, details):
        self.log_text.config(state=tk.NORMAL)
        tag = "system"
        if "key" in event_type:
            tag = "key"
        elif "mouse" in event_type:
            tag = "mouse"

        self.log_text.insert(tk.END, f"{event_type}: {details}\n", (tag,))
        self.log_text.see(tk.END)
        self.log_text.config(state=tk.DISABLED)
