import screen_brightness_control as sbc
from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume
from comtypes import CLSCTX_ALL

class BrightnessControl:
    @staticmethod
    def set_brightness(level):
        sbc.set_brightness(level)
    
    @staticmethod
    def increase_brightness(amount=10):
        current_brightness = sbc.get_brightness(display=0)[0]
        sbc.set_brightness(min(100, current_brightness + amount))
    
    @staticmethod
    def decrease_brightness(amount=10):
        current_brightness = sbc.get_brightness(display=0)[0]
        sbc.set_brightness(max(0, current_brightness - amount))
    
    @staticmethod
    def get_brightness():
        return sbc.get_brightness(display=0)[0]

class VolumeControl:
    def __init__(self):
        devices = AudioUtilities.GetSpeakers()
        interface = devices.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
        self.volume = interface.QueryInterface(IAudioEndpointVolume)
    
    def get_volume(self):
        return round(self.volume.GetMasterVolumeLevelScalar() * 100)
    
    def set_volume(self, level):
        self.volume.SetMasterVolumeLevelScalar(level / 100, None)
    
    def increase_volume(self, amount=10):
        current_volume = self.get_volume()
        self.set_volume(min(100, current_volume + amount))
    
    def decrease_volume(self, amount=10):
        current_volume = self.get_volume()
        self.set_volume(max(0, current_volume - amount))

def menu():
    brightness = BrightnessControl()
    volume = VolumeControl()
    
    while True:
        print("\nMenu:")
        print("1. Increase Brightness")
        print("2. Decrease Brightness")
        print("3. Set Brightness")
        print("4. Get Current Brightness")
        print("5. Increase Volume")
        print("6. Decrease Volume")
        print("7. Set Volume")
        print("8. Get Current Volume")
        print("9. Exit")
        
        choice = input("Enter your choice: ")
        
        if choice == "1":
            brightness.increase_brightness()
        elif choice == "2":
            brightness.decrease_brightness()
        elif choice == "3":
            level = int(input("Enter brightness level (0-100): "))
            brightness.set_brightness(level)
        elif choice == "4":
            print("Current Brightness:", brightness.get_brightness())
        elif choice == "5":
            volume.increase_volume()
        elif choice == "6":
            volume.decrease_volume()
        elif choice == "7":
            level = int(input("Enter volume level (0-100): "))
            volume.set_volume(level)
        elif choice == "8":
            print("Current Volume:", volume.get_volume())
        elif choice == "9":
            break
        else:
            print("Invalid choice, please try again.")

if __name__ == "__main__":
    menu()