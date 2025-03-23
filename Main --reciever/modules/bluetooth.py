import bluetooth
import subprocess

class Bluetooth:
    @staticmethod
    def get_bluetooth_status():
        try:
            nearby_devices = bluetooth.discover_devices(duration=4, lookup_names=True)
            return bool(nearby_devices)
        except ImportError:
            return False
        
    def toggle_bluetooth():
        cmd = '''
            $btAdapter = Get-PnpDevice | Where-Object { $_.FriendlyName -match "Bluetooth" -and $_.InstanceId -match "BTHUSB" }
            if ($btAdapter.Status -eq "OK") {
            Disable-PnpDevice -InstanceId $btAdapter.InstanceId -Confirm:$false
            Write-Output "Bluetooth turned OFF"
            } else {
            Enable-PnpDevice -InstanceId $btAdapter.InstanceId -Confirm:$false
            Write-Output "Bluetooth turned ON"
            }
        '''
    
        # Run PowerShell command
        result = subprocess.run(["powershell", "-Command", cmd], capture_output=True, text=True, shell=True)
        print(result.stdout)