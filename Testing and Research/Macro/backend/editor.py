# import json
# from typing import List, Dict, Any, Optional

# class MacroEditorBackend:
#     def __init__(self):
#         self.macro_data: List[Dict[str, Any]] = []
#         self.current_file: Optional[str] = None

#     def load_file(self, file_path: str) -> None:
#         """Load macro data from JSON file"""
#         with open(file_path, 'r') as f:
#             self.macro_data = json.load(f)
#         self.current_file = file_path

#     def save_file(self, file_path: Optional[str] = None) -> None:
#         """Save macro data to JSON file"""
#         save_path = file_path or self.current_file
#         if not save_path:
#             raise ValueError("No file path specified")
        
#         with open(save_path, 'w') as f:
#             json.dump(self.macro_data, f, indent=4)
#         self.current_file = save_path

#     def add_event(self, event: Dict[str, Any]) -> None:
#         """Add a new event to macro data"""
#         if self.validate_event(event):
#             self.macro_data.append(event)
#         else:
#             raise ValueError("Invalid event structure")

#     def delete_event(self, event_index: int) -> None:
#         """Delete an event from macro data"""
#         if not 0 <= event_index < len(self.macro_data):
#             raise IndexError("Event index out of range")
#         del self.macro_data[event_index]

#     def format_data(self) -> str:
#         """Return formatted JSON string of macro data"""
#         return json.dumps(self.macro_data, indent=4)

#     def validate_event(self, event: Dict[str, Any]) -> bool:
#         """Validate an event structure"""
#         required_fields = {
#             'key_press': ['type', 'key', 'time'],
#             'key_release': ['type', 'key', 'time'],
#             'mouse_down': ['type', 'x', 'y', 'button', 'time'],
#             'mouse_up': ['type', 'x', 'y', 'button', 'time'],
#             'mouse_move': ['type', 'x', 'y', 'time']
#         }
        
#         event_type = event.get('type')
#         return (event_type in required_fields and 
#                 all(field in event for field in required_fields[event_type]))

#     def find_event_at_position(self, json_str: str, line: int) -> Optional[int]:
#         """Find event index at specified line in JSON string"""
#         try:
#             lines = json_str.split('\n')
#             brace_count = 0
#             event_start = -1
            
#             for i, l in enumerate(lines[:line+1]):
#                 if '{' in l:
#                     brace_count += 1
#                     if brace_count == 1:
#                         event_start = i
#                 if '}' in l:
#                     brace_count -= 1
#                     if brace_count == 0 and event_start != -1 and i >= line:
#                         event_str = '\n'.join(lines[event_start:i+1])
#                         event = json.loads(event_str)
#                         return self.macro_data.index(event)
#             return None
#         except (ValueError, json.JSONDecodeError):
#             return None