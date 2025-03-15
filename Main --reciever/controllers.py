import json
import ctypes
import os
import psutil
from modules.brightness import Brightness
from modules.volume import Volume
from modules.power import Power
from modules.wifi import WiFi
from modules.bluetooth import Bluetooth

def lock_computer():
    ctypes.windll.user32.LockWorkStation()

def sleep_computer():
    os.system("rundll32.exe powrprof.dll,SetSuspendState Sleep")

def get_current_status():
    return {
        "brightness": Brightness.get_brightness(),
        "volume": Volume.get_volume(),
        "power": Power.get_power_status(),
        "wifi": WiFi.get_wifi_status(),
        "bluetooth": Bluetooth.get_bluetooth_status()
    }

def process_action(payload):
    try:
        data = json.loads(payload)
        
        if data.get("type") == "manual":
            if data.get("module") == "brightness" and data.get("action") == "set":
                return {"status": Brightness.set_brightness(int(data.get("value", 50)))}
            if data.get("module") == "volume" and data.get("action") == "set":
                return {"status": Volume.set_volume(int(data.get("value", 50)))}
        
        elif data.get("type") == "macro":
            return {"status": f"Executing macro {data.get('id')}"}
        
        elif data.get("type") == "voice":
            if "lock computer" in data.get("text", "").lower():
                lock_computer()
                return {"status": "Computer locked"}
            elif "sleep computer" in data.get("text", "").lower():
                sleep_computer()
                return {"status": "Computer going to sleep"}
            elif "brightness" in data.get("text", "").lower():
                import re
                match = re.search(r"(\d+)%", data.get("text", ""))
                if match:
                    brightness_value = int(match.group(1))
                    return {"status": set_brightness(brightness_value)}
        
        return {"error": "Unknown command"}
    except json.JSONDecodeError:
        return {"error": "Invalid JSON format"}
