import json
import ctypes
import os
import psutil
from modules.brightness import Brightness
from modules.volume import Volume
from modules.power import Power
from modules.wifi import WiFi
from modules.bluetooth import Bluetooth
from voice.voice_processing import BatchScriptGenerator

def lock_computer():
    ctypes.windll.user32.LockWorkStation()

def sleep_computer():
    os.system("rundll32.exe powrprof.dll,SetSuspendState Sleep")

def toggle_power():
    return {"message": Power.toggle_power()}  # Assuming Power module has toggle_power method

def toggle_wifi():
    return {"message": WiFi.toggle_wifi()}  # Assuming WiFi module has toggle_wifi method

def toggle_bluetooth():
    return {"message": Bluetooth.toggle_bluetooth()}  # Assuming Bluetooth module has toggle_bluetooth method

def get_current_status():
    return {
        "brightness": Brightness.get_brightness(),
        "volume": Volume.get_volume(),
        "power": Power.get_power_status(),
        "battery": Power.get_power_percent(),
        "wifi": WiFi.get_wifi_status(),
        "bluetooth": Bluetooth.get_bluetooth_status()
    }

def process_action(payload):
    try:
        data = json.loads(payload)
        
        if data.get("type") == "manual":
            module = data.get("module")
            action = data.get("action")

            if module == "brightness" and action == "set":
                return {"message": Brightness.set_brightness(int(data.get("value", 50)))}
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
            return {"message": f"Executing macro {data.get('id')}"}
        
        elif data.get("type") == "voice":
            text = data.get("text", "").lower()
            GOOGLE_API_KEY = "AIzaSyCPwuJF0lbcGGLPTwwcp02Hg_plqPJGHQc"
            generator = BatchScriptGenerator(api_key=GOOGLE_API_KEY)
            generator.process(text)
            return {"message": "Voice command executed successfully"}

        return {"error": "Unknown command"}
    except json.JSONDecodeError:
        return {"error": "Invalid JSON format"}
        