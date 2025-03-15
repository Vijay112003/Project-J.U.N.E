import screen_brightness_control as sbc

class Brightness:
    @staticmethod
    def get_brightness():
        try:
            return sbc.get_brightness()[0]
        except Exception as e:
            return f"Failed to get brightness: {e}"

    @staticmethod
    def set_brightness(value):
        try:
            sbc.set_brightness(value)
            return f"Brightness set to {value}%"
        except Exception as e:
            return f"Failed to set brightness: {e}"
        
        
