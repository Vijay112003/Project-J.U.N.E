import subprocess

def toggle_bluetooth(enable: bool):
    """
    Toggles Bluetooth on or off using PowerShell commands.

    :param enable: If True, enables Bluetooth. If False, disables Bluetooth.
    """
    try:
        # PowerShell command to enable or disable Bluetooth
        command = "Enable" if enable else "Disable"
        ps_command = f"Get-PnpDevice -Class Bluetooth | Where-Object {{ $_.FriendlyName -like '*Bluetooth*' }} | {command}-PnpDevice -Confirm:$false"
        
        # Execute the PowerShell command
        subprocess.run(["powershell", "-Command", ps_command], check=True)
        print(f"Bluetooth has been {'enabled' if enable else 'disabled'}.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to toggle Bluetooth: {e}")

# Example usage
if __name__ == "__main__":
    # Set to True to enable Bluetooth, False to disable
    toggle_bluetooth(enable=True)  # Change to False to disable Bluetooth

def is_bluetooth_enabled():
    """
    Checks if Bluetooth is currently enabled.

    :return: True if Bluetooth is enabled, False otherwise.
    """
    try:
        ps_command = "Get-PnpDevice -Class Bluetooth | Where-Object { $_.FriendlyName -like '*Bluetooth*' } | Select-Object -ExpandProperty Status"
        result = subprocess.run(["powershell", "-Command", ps_command], capture_output=True, text=True, check=True)
        return "OK" in result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Failed to check Bluetooth status: {e}")
        return False

# Example usage
if __name__ == "__main__":
    if is_bluetooth_enabled():
        print("Bluetooth is currently enabled.")
        toggle_bluetooth(enable=False)  # Disable Bluetooth
    else:
        print("Bluetooth is currently disabled.")
        toggle_bluetooth(enable=True)  # Enable Bluetooth