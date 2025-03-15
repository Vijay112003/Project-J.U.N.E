import psutil

class WiFi:
    @staticmethod
    def get_wifi_status():
        interfaces = psutil.net_if_addrs()
        wifi_connected = any('Wi-Fi' in iface or 'wlan' in iface.lower() for iface in interfaces)
        return wifi_connected
