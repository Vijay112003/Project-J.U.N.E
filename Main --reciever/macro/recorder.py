import os
import json
import time
import threading
import tkinter as tk
from tkinter import ttk
from pynput import keyboard, mouse
from database import save_macro_to_db, init_db
from contextlib import suppress
import traceback

# --------------- Macro Recorder ---------------- #

class MacroRecorder:
    def __init__(self, capture_mouse_path=True):
        self.capture_mouse_path = capture_mouse_path
        self.macro_data = []
        self.recording = False
        self.start_time = None
        self.key_listener = None
        self.mouse_listener = None
        self.callback = None

    def set_callback(self, callback):
        self.callback = callback

    def current_time(self):
        return time.time() - self.start_time if self.start_time else 0

    def log(self, event_type, details):
        if self.callback:
            self.callback(event_type, details)

    def on_press(self, key):
        if not self.recording:
            return False
        with suppress(AttributeError):
            key_name = key.char if hasattr(key, 'char') and key.char else str(key)
            self.macro_data.append({
                "type": "key_press",
                "key": key_name,
                "time": self.current_time()
            })
            self.log("key_press", key_name)

    def on_release(self, key):
        if not self.recording:
            return False
        if key == keyboard.Key.esc:
            self.log("system", "Recording stopped by ESC key")
            self.stop_recording()
            return False
        with suppress(AttributeError):
            key_name = key.char if hasattr(key, 'char') and key.char else str(key)
            self.macro_data.append({
                "type": "key_release",
                "key": key_name,
                "time": self.current_time()
            })
            self.log("key_release", key_name)

    def on_click(self, x, y, button, pressed):
        if not self.recording:
            return False
        action = "mouse_down" if pressed else "mouse_up"
        self.macro_data.append({
            "type": action,
            "x": x,
            "y": y,
            "button": str(button),
            "time": self.current_time()
        })
        self.log(action, f"({x}, {y}) with {button}")

    def on_move(self, x, y):
        if not self.recording or not self.capture_mouse_path:
            return False
        # Optional: add throttling or threshold filtering here
        self.macro_data.append({
            "type": "mouse_move",
            "x": x,
            "y": y,
            "time": self.current_time()
        })
        self.log("mouse_move", f"({x}, {y})")

    def stop_recording(self):
        self.recording = False
        if self.key_listener:
            self.key_listener.stop()
        if self.mouse_listener:
            self.mouse_listener.stop()

    def record_macro(self, json_filename="macro.json"):
        self.macro_data.clear()
        self.recording = True
        self.start_time = time.time()
        self.log("system", "Recording started")

        self.key_listener = keyboard.Listener(on_press=self.on_press, on_release=self.on_release)
        self.mouse_listener = mouse.Listener(on_click=self.on_click, on_move=self.on_move if self.capture_mouse_path else None)

        self.key_listener.start()
        self.mouse_listener.start()

        while self.recording:
            time.sleep(0.1)

        dir_path = os.path.dirname(json_filename)
        if dir_path:
            os.makedirs(dir_path, exist_ok=True)

        with open(json_filename, "w") as file:
            json.dump(self.macro_data, file, indent=4)

        self.log("system", f"Recording saved to '{json_filename}'")
        return json_filename


# --------------- UI ---------------- #

class RecorderPage(tk.Frame):
    MACRO_SAVE_DIR = os.path.abspath("macros")

    def __init__(self, parent):
        super().__init__(parent, padx=20, pady=20)
        self.recorder = MacroRecorder(capture_mouse_path=False)
        os.makedirs(self.MACRO_SAVE_DIR, exist_ok=True)
        init_db()

        self.set_style()

        ttk.Label(self, text="🎬 Macro Recorder", style="Title.TLabel").pack(pady=(0, 10))

        form_frame = ttk.Frame(self)
        form_frame.pack(fill=tk.X, pady=10)

        ttk.Label(form_frame, text="Macro Name:").grid(row=0, column=0, sticky=tk.W, padx=5, pady=5)
        self.name_entry = ttk.Entry(form_frame, width=40)
        self.name_entry.grid(row=0, column=1, sticky=tk.W, padx=5, pady=5)

        ttk.Label(form_frame, text="Description:").grid(row=1, column=0, sticky=tk.W, padx=5, pady=5)
        self.desc_entry = ttk.Entry(form_frame, width=40)
        self.desc_entry.grid(row=1, column=1, sticky=tk.W, padx=5, pady=5)

        self.record_btn = ttk.Button(self, text="🎥 Start Recording", style="Primary.TButton", command=self.start_recording)
        self.record_btn.pack(pady=10)

        self.status = tk.Label(self, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W, bg="lightgray", fg="black")
        self.status.pack(fill=tk.X, pady=(10, 0))

        ttk.Label(self, text="Activity Log", style="Heading.TLabel").pack(anchor="w", pady=(15, 5))
        log_container = ttk.Frame(self)
        log_container.pack(fill=tk.BOTH, expand=True)

        self.log_text = tk.Text(log_container, height=12, state=tk.DISABLED, wrap=tk.WORD, relief=tk.FLAT)
        self.log_text.pack(fill=tk.BOTH, expand=True)
        self.log_text.tag_config("key", foreground="blue")
        self.log_text.tag_config("mouse", foreground="red")
        self.log_text.tag_config("system", foreground="green")

    def set_style(self):
        style = ttk.Style()
        style.theme_use('clam')
        style.configure("Primary.TButton", foreground="white", background="#0d6efd", font=("Segoe UI", 10, "bold"))
        style.map("Primary.TButton", background=[("active", "#0b5ed7")])
        style.configure("Title.TLabel", font=("Segoe UI", 16, "bold"))
        style.configure("Heading.TLabel", font=("Segoe UI", 12, "bold"))

    def update_status(self, text, bg_color):
        self.status.config(text=text, bg=bg_color)

    def start_recording(self):
        name = self.name_entry.get().strip()
        description = self.desc_entry.get().strip()

        if not name:
            self.update_status("Please enter a macro name", "red")
            return

        safe_name = "".join(c if c.isalnum() or c in (' ', '-', '_') else '_' for c in name).replace(" ", "_")
        json_path = os.path.join(self.MACRO_SAVE_DIR, f"{safe_name}.json")

        self.record_btn.config(state=tk.DISABLED)
        self.update_status("Recording... Press ESC to stop", "yellow")
        self.clear_log()
        self.recorder.set_callback(self.log_event)

        def record():
            try:
                recorded_file = self.recorder.record_macro(json_filename=json_path)
                save_macro_to_db(name, description, recorded_file)
                self.after(0, lambda: self.update_status(f"Recording saved: {recorded_file}", "lightgreen"))
            except Exception as e:
                print("DEBUG: An error occurred during macro recording:")
                traceback.print_exc()
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
        self.log_text.insert(tk.END, f"{event_type}: {details}\n", tag)
        self.log_text.see(tk.END)
        self.log_text.config(state=tk.DISABLED)

# --------------- Run App ---------------- #

if __name__ == "__main__":
    root = tk.Tk()
    root.title("Macro Recorder App")
    root.geometry("600x550")
    root.resizable(False, False)
    RecorderPage(root).pack(fill=tk.BOTH, expand=True)
    root.mainloop()
