import json
import time
import os
from pynput import keyboard, mouse

class MacroRecorder:
    def __init__(self, capture_mouse_path=True):
        self.capture_mouse_path = capture_mouse_path
        self.macro_data = []
        self.recording = False
        self.start_time = None
        self.key_listener = None
        self.mouse_listener = None
        self.callback = None  # Callback function for UI updates

    def set_callback(self, callback):
        """Set the callback function for UI updates"""
        self.callback = callback

    def current_time(self):
        return time.time() - self.start_time if self.start_time else 0

    def log(self, event_type, details):
        if self.callback:
            self.callback(event_type, details)

    def on_press(self, key):
        if not self.recording:
            return False

        try:
            key_name = key.char if hasattr(key, 'char') else str(key)
            self.macro_data.append({
                "type": "key_press",
                "key": key_name,
                "time": self.current_time()
            })
            self.log("key_press", key_name)
        except AttributeError:
            pass

    def on_release(self, key):
        if not self.recording:
            return False

        if key == keyboard.Key.esc:
            self.log("system", "Recording stopped by ESC key")
            self.stop_recording()
            return False

        key_name = key.char if hasattr(key, 'char') else str(key)
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
        if not self.recording:
            return False

        if self.capture_mouse_path:
            self.macro_data.append({
                "type": "mouse_move",
                "x": x,
                "y": y,
                "time": self.current_time()
            })
            self.log("mouse_move", f"({x}, {y})")

    def stop_recording(self):
        if self.recording:
            self.recording = False
            if self.key_listener:
                self.key_listener.stop()
            if self.mouse_listener:
                self.mouse_listener.stop()

    def record_macro(self, json_filename="macro.json"):
        self.macro_data = []
        self.recording = True
        self.start_time = time.time()
        self.log("system", "Recording started")

        # Start listeners
        self.key_listener = keyboard.Listener(on_press=self.on_press, on_release=self.on_release)
        self.mouse_listener = mouse.Listener(on_click=self.on_click, on_move=self.on_move if self.capture_mouse_path else None)

        self.key_listener.start()
        self.mouse_listener.start()

        # Wait for recording to complete
        while self.recording:
            time.sleep(0.1)

        # Ensure directory exists
        save_dir = "saved_macros"
        os.makedirs(save_dir, exist_ok=True)
        save_path = os.path.join(save_dir, json_filename)

        # Save to file
        with open(save_path, "w") as file:
            json.dump(self.macro_data, file, indent=4)

        self.log("system", f"Recording saved to '{save_path}'")
        return save_path
