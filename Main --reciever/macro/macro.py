import pyautogui
import json
import time
import keyboard

class MacroPlayer:
    SPECIAL_KEYS = {
        "Key.backspace": "backspace",
        "Key.enter": "enter",
        "Key.space": "space",
        "Key.shift": "shift",
        "Key.shift_l": "shift",
        "Key.shift_r": "shift",
        "Key.ctrl": "ctrl",
        "Key.ctrl_l": "ctrl",
        "Key.ctrl_r": "ctrl",
        "Key.alt": "alt",
        "Key.alt_l": "alt",
        "Key.alt_r": "alt",
        "Key.cmd": "win",
        "Key.cmd_l": "win",
        "Key.cmd_r": "win",
        "Key.tab": "tab",
        "Key.esc": "esc",
        "Key.caps_lock": "capslock",
        "Key.delete": "delete",
        "Key.insert": "insert",
        "Key.home": "home",
        "Key.end": "end",
        "Key.page_up": "pageup",
        "Key.page_down": "pagedown",
        "Key.left": "left",
        "Key.right": "right",
        "Key.up": "up",
        "Key.down": "down",
        "Key.f1": "f1", "Key.f2": "f2", "Key.f3": "f3", "Key.f4": "f4",
        "Key.f5": "f5", "Key.f6": "f6", "Key.f7": "f7", "Key.f8": "f8",
        "Key.f9": "f9", "Key.f10": "f10", "Key.f11": "f11", "Key.f12": "f12"
    }

    def __init__(self, playback_speed=1.0):
        self.playback_speed = playback_speed

    def clean_key_name(self, key):
        """Convert recorded key names to proper format"""
        return self.SPECIAL_KEYS.get(key, key)

    def load_macro(self, filename="macro.json"):
        """Load macro actions from JSON file"""
        with open(filename, "r") as file:
            return json.load(file)

    def play_actions(self, actions):
        """Execute the loaded macro actions"""
        start_time = time.time()

        for action in actions:
            delay = (action["time"] - (time.time() - start_time)) / self.playback_speed
            if delay > 0:
                time.sleep(delay)

            if action["type"] == "mouse_move":
                pyautogui.moveTo(action["x"], action["y"], duration=0.05)

            elif action["type"] in ["mouse_down", "mouse_up"]:
                button = action["button"].split(".")[-1]
                if action["type"] == "mouse_down":
                    pyautogui.mouseDown(x=action["x"], y=action["y"], button=button)
                else:
                    pyautogui.mouseUp(x=action["x"], y=action["y"], button=button)

            elif action["type"] == "key_press":
                key = self.clean_key_name(action["key"])
                keyboard.press(key)
                time.sleep(0.05)
                keyboard.release(key)

    def play_macro(self, filename="macro.json"):
        """Load and play a macro from file"""
        actions = self.load_macro(filename)
        self.play_actions(actions)