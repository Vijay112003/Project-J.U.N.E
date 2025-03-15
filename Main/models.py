from pydantic import BaseModel

class ActionBase(BaseModel):
    type: str

class ManualAction(ActionBase):
    module: str
    action: str
    value: str

class MacroAction(ActionBase):
    id: str

class VoiceAction(ActionBase):
    text: str
