import psutil
import os

class WiFi:
    @staticmethod
    def get_wifi_status():
        interfaces = psutil.net_if_addrs()
        wifi_connected = any('Wi-Fi' in iface or 'wlan' in iface.lower() for iface in interfaces)
        return wifi_connected
    
    @staticmethod
    def toggle_wifi():
        wifi_status = WiFi.get_wifi_status()
        if wifi_status:
            os.system("netsh interface set interface Wi-Fi disable")
            return "Wi-Fi turned off"
        else:
            os.system("netsh interface set interface Wi-Fi enable")
            return "Wi-Fi turned on"
