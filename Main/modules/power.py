import psutil

class Power:
    @staticmethod
    def get_power_status():
        battery = psutil.sensors_battery()
        return "Charging" if battery.power_plugged else "Discharging"
    
    @staticmethod
    def get_power_percent():
        battery = psutil.sensors_battery()
        return battery.percent
