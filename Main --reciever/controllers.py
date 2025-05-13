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
        type_ = data.get("type")

        if type_ == "status":
            status_info = get_current_status()
            return {
                "type": "status",
                "data": status_info
            }

        elif type_ == "macro" and data.get("action") == "get_macro":
            info = get_macro_info()
            if "error" in info:
                return {
                    "type": "error",
                    "message": info["error"]
                }
            return {
                "type": "macro",
                "data": info
            }

        elif type_ == "manual":
            module = data.get("module")
            action = data.get("action")
            value = data.get("value")

            if module == "brightness" and action == "set":
                threading.Thread(target=threaded_brightness_control, args=(value,)).start()
                return {
                    "type": "manual",
                    "data": {
                        "message": f"Brightness set to {value}"
                    }
                }

            elif module == "volume" and action == "set":
                message = Volume.set_volume(int(value))
                return {
                    "type": "manual",
                    "data": {
                        "message": message
                    }
                }

            elif module == "power" and action == "toggle":
                power_message = Power.toggle_power()
                return {
                    "type": "manual",
                    "data": {
                        "message": power_message
                    }
                }

            elif module == "lock" and action == "toggle":
                lock_computer()
                return {
                    "type": "manual",
                    "data": {
                        "message": "Computer locked"
                    }
                }

            elif module == "wifi" and action == "toggle":
                wifi_message = WiFi.toggle_wifi()
                return {
                    "type": "manual",
                    "data": {
                        "message": wifi_message
                    }
                }

            elif module == "bluetooth" and action == "toggle":
                bt_message = Bluetooth.toggle_bluetooth()
                return {
                    "type": "manual",
                    "data": {
                        "message": bt_message
                    }
                }

            else:
                return {
                    "type": "error",
                    "message": f"Unsupported manual module/action: {module}/{action}"
                }

        elif type_ == "macro":
            filenm = data.get("filepath")
            if not filenm:
                return {
                    "type": "error",
                    "message": "Filepath not provided for macro"
                }
            threading.Thread(target=threaded_macro_execution, args=(filenm,)).start()
            return {
                "type": "macro",
                "data": {
                    "message": f"Executing macro from {filenm}"
                }
            }

        elif type_ == "voice":
            text = data.get("text", "").strip()
            if not text:
                return {
                    "type": "error",
                    "message": "Voice command text is missing"
                }
            generator = BatchScriptGenerator(api_key="AIzaSyCPwuJF0lbcGGLPTwwcp02Hg_plqPJGHQc")
            generator.process(text)
            return {
                "type": "voice",
                "data": {
                    "message": "Voice command executed successfully"
                }
            }

        elif type_ == "terminal":
            command = data.get("text", "").strip()
            if not command:
                return {
                    "type": "error",
                    "message": "Terminal command is empty"
                }
            output = terminal.execute_command(command)
            return {
                "type": "terminal",
                "data": {
                    "output": output
                }
            }

        else:
            return {
                "type": "error",
                "message": "Unknown type or unsupported action"
            }

    except json.JSONDecodeError:
        return {
            "type": "error",
            "message": "Invalid JSON format"
        }

    except Exception as e:
        return {
            "type": "error",
            "message": str(e)
        }
