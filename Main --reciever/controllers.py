import json
import ctypes
import os
import threading
import psutil
from modules.brightness import Brightness
from modules.volume import Volume
from modules.power import Power
from modules.wifi import WiFi
from modules.bluetooth import Bluetooth
from voice.voice_processing import BatchScriptGenerator
from terminal.terminal import Terminal
from macro.macro import MacroPlayer
from macro.database import fetch_all_macros

terminal = Terminal()  # Initialize Terminal instance

def lock_computer():
    ctypes.windll.user32.LockWorkStation()

def sleep_computer():
    os.system("rundll32.exe powrprof.dll,SetSuspendState Sleep")

def toggle_power():
    return {"message": Power.toggle_power()}

def toggle_wifi():
    return {"message": WiFi.toggle_wifi()}

def toggle_bluetooth():
    return {"message": Bluetooth.toggle_bluetooth()}

def get_current_status():
    return {
        "brightness": Brightness.get_brightness(),
        "volume": Volume.get_volume(),
        "power": Power.get_power_status(),
        "battery": Power.get_power_percent(),
        "wifi": WiFi.get_wifi_status(),
        "bluetooth": Bluetooth.get_bluetooth_status()
    }

def threaded_brightness_control(value):
    Brightness.set_brightness(int(value))

def threaded_macro_execution(filenm):
    player = MacroPlayer(playback_speed=1.0)
    player.play_macro(filename=filenm)
    
import json

def get_macro_info():
    try:
        # Fetch macros from the database
        macros = fetch_all_macros()  # Expected: List of tuples (id, name, description, json_path)
        macro_list = []

        for macro in macros:
            # Normalize backslashes to forward slashes for JSON readability
            json_path_clean = macro[3].replace("\\", "/")

            # Build macro dictionary
            macro_data = {
                "id": macro[0],
                "name": macro[1],
                "description": macro[2],
                "json_path": json_path_clean
            }
            macro_list.append(macro_data)

        # Return minified clean JSON string (no indentation, no extra escaping)
        return {"macros": macro_list}

    except Exception as e:
        # Return minified error JSON
        return {"error": str(e)}
    
def process_action(payload):
    try:
        data = json.loads(payload)
        
        if data.get("action") == "get_macro":
            info = get_macro_info()
            print(f"Macro info: {info}")
            return info
        
        if data.get("type") == "manual":
            module = data.get("module")
            action = data.get("action")

            if module == "brightness" and action == "set":
                value = data.get("value", 50)
                threading.Thread(target=threaded_brightness_control, args=(value,)).start()
                return {"message": f"Brightness set to {value}"}

            elif module == "volume" and action == "set":
                return {"message": Volume.set_volume(int(data.get("value", 50)))}

            elif module == "power" and action == "toggle":
                return toggle_power()

            elif module == "lock" and action == "toggle":
                lock_computer()
                return {"message": "Computer locked"}

            elif module == "wifi" and action == "toggle":
                return toggle_wifi()

            elif module == "bluetooth" and action == "toggle":
                return toggle_bluetooth()

        elif data.get("type") == "macro":
            filenm = data.get("filepath", "")
            threading.Thread(target=threaded_macro_execution, args=(filenm,)).start()
            return {"message": f"Executing macro {data.get('id')}"}

        elif data.get("type") == "voice":
            text = data.get("text", "").lower()
            GOOGLE_API_KEY = "AIzaSyCPwuJF0lbcGGLPTwwcp02Hg_plqPJGHQc"
            generator = BatchScriptGenerator(api_key=GOOGLE_API_KEY)
            generator.process(text)
            return {"message": "Voice command executed successfully"}

        elif data.get("type") == "terminal":
            command = data.get("text", "")
            if command:
                return {"terminal" : terminal.execute_command(command)}
            return {"terminal_error": "Empty command"}

        return {"error": "Unknown command"}
    except json.JSONDecodeError:
        return {"error": "Invalid JSON format"}
