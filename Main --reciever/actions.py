import screen_brightness_control as sbc
from modules.brightness import Brightness

def set_brightness(value: int):
    try:
        response = Brightness.set_brightness(value)
        return {"message": f"{response}"}
    except Exception as e:
        return {"message": str(e)}
