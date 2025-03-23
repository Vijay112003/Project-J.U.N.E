from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume
from comtypes import CLSCTX_ALL

class Volume:
    @staticmethod
    def get_volume():
        try:
            devices = AudioUtilities.GetSpeakers()
            interface = devices.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
            volume = interface.QueryInterface(IAudioEndpointVolume)
            return round(volume.GetMasterVolumeLevelScalar() * 100)
        except Exception as e:
            return f"Failed to get volume: {e}"

    @staticmethod
    def set_volume(level):
        try:
            devices = AudioUtilities.GetSpeakers()
            interface = devices.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
            volume = interface.QueryInterface(IAudioEndpointVolume)
            volume.SetMasterVolumeLevelScalar(level / 100, None)
        except Exception as e:
            return f"Failed to set volume: {e}"
