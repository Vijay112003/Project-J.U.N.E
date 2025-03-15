import bluetooth

class Bluetooth:
    @staticmethod
    def get_bluetooth_status():
        try:
            nearby_devices = bluetooth.discover_devices(duration=4, lookup_names=True)
            return bool(nearby_devices)
        except ImportError:
            return False