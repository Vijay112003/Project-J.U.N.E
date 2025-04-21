# import json
# import tkinter as tk
# from tkinter import filedialog, messagebox, ttk
# from typing import List, Dict, Any, Optional

# class EditorPage(ttk.Frame):  # Inherit from ttk.Frame explicitly
#     def __init__(self, parent, controller):
#         super().__init__(parent)  # Now correctly calls Frame.__init__
#         self.controller = controller
#         self.root = parent  # Use parent as the root instead of assuming it's called root
        
#         # Set title and geometry on the parent if it's a Tk instance
#         if isinstance(self.root, tk.Tk):
#             self.root.title("JSON Event Editor")
#             self.root.geometry("900x600")
#             # Create menu bar only if parent is the root window
#             self.create_menu_bar()
        
#         # Variables
#         self.current_file_path = None
#         self.events_data = []
#         self.modified = False
#         self.selected_event_index = None
        
#         # Create the main frame
#         self.main_frame = ttk.Frame(self)  # Use self instead of root
#         self.main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         # Create the main layout
#         self.create_layout()
        
#         # Initialize with empty data
#         self.update_event_list()
    
#     def create_menu_bar(self):
#         """Create the application menu bar"""
#         # Only create menu if parent is the root window
#         if not isinstance(self.root, tk.Tk):
#             return
            
#         menu_bar = tk.Menu(self.root)
        
#         # File menu
#         file_menu = tk.Menu(menu_bar, tearoff=0)
#         file_menu.add_command(label="Open", command=self.open_file, accelerator="Ctrl+O")
#         file_menu.add_command(label="Save", command=self.save_file, accelerator="Ctrl+S")
#         file_menu.add_command(label="Save As", command=self.save_file_as, accelerator="Ctrl+Shift+S")
#         file_menu.add_separator()
#         file_menu.add_command(label="Exit", command=self.exit_application)
        
#         # Edit menu
#         edit_menu = tk.Menu(menu_bar, tearoff=0)
#         edit_menu.add_command(label="Add Event", command=self.add_event)
#         edit_menu.add_command(label="Delete Event", command=self.delete_selected_event)
        
#         # Add menus to the menu bar
#         menu_bar.add_cascade(label="File", menu=file_menu)
#         menu_bar.add_cascade(label="Edit", menu=edit_menu)
        
#         # Set the menu bar
#         self.root.config(menu=menu_bar)
        
#         # Bind keyboard shortcuts
#         self.root.bind("<Control-o>", lambda event: self.open_file())
#         self.root.bind("<Control-s>", lambda event: self.save_file())
#         self.root.bind("<Control-Shift-S>", lambda event: self.save_file_as())  # Fixed the binding for Shift+S
    
#     def create_layout(self):
#         """Create the main application layout"""
#         # Left panel for event list
#         left_frame = ttk.LabelFrame(self.main_frame, text="Events")
#         left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        
#         # Create a treeview for the event list
#         self.event_tree = ttk.Treeview(left_frame, columns=("Type", "Time"))
#         self.event_tree.heading("#0", text="Index")
#         self.event_tree.heading("Type", text="Event Type")
#         self.event_tree.heading("Time", text="Time")
#         self.event_tree.column("#0", width=50, stretch=tk.NO)
#         self.event_tree.column("Type", width=100, stretch=tk.NO)
#         self.event_tree.column("Time", width=100, stretch=tk.NO)
#         self.event_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
#         # Add scrollbar to the treeview
#         scrollbar = ttk.Scrollbar(left_frame, orient=tk.VERTICAL, command=self.event_tree.yview)
#         scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
#         self.event_tree.configure(yscrollcommand=scrollbar.set)
        
#         # Bind selection event
#         self.event_tree.bind("<<TreeviewSelect>>", self.on_event_select)
        
#         # Right panel for event details
#         right_frame = ttk.LabelFrame(self.main_frame, text="Event Details")
#         right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        
#         # Create a form for event details
#         details_frame = ttk.Frame(right_frame)
#         details_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         # Event type selection
#         ttk.Label(details_frame, text="Event Type:").grid(row=0, column=0, sticky=tk.W, pady=5)
#         self.event_type_var = tk.StringVar()
#         self.event_type_combo = ttk.Combobox(details_frame, textvariable=self.event_type_var, 
#                                             values=["mouse_down", "mouse_up", "key_press", "key_release"])
        
#         self.event_type_combo.grid(row=0, column=1, sticky=tk.W+tk.E, pady=5)
#         self.event_type_combo.bind("<<ComboboxSelected>>", self.update_form_fields)
        
#         # Time field
#         ttk.Label(details_frame, text="Time:").grid(row=1, column=0, sticky=tk.W, pady=5)
#         self.time_var = tk.StringVar()
#         ttk.Entry(details_frame, textvariable=self.time_var).grid(row=1, column=1, sticky=tk.W+tk.E, pady=5)
        
#         # Mouse event fields
#         self.mouse_frame = ttk.LabelFrame(details_frame, text="Mouse Event")
#         self.mouse_frame.grid(row=2, column=0, columnspan=2, sticky=tk.W+tk.E, pady=5)
        
#         ttk.Label(self.mouse_frame, text="X:").grid(row=0, column=0, sticky=tk.W, pady=5, padx=5)
#         self.x_var = tk.StringVar()
#         ttk.Entry(self.mouse_frame, textvariable=self.x_var).grid(row=0, column=1, sticky=tk.W+tk.E, pady=5)
        
#         ttk.Label(self.mouse_frame, text="Y:").grid(row=1, column=0, sticky=tk.W, pady=5, padx=5)
#         self.y_var = tk.StringVar()
#         ttk.Entry(self.mouse_frame, textvariable=self.y_var).grid(row=1, column=1, sticky=tk.W+tk.E, pady=5)
        
#         ttk.Label(self.mouse_frame, text="Button:").grid(row=2, column=0, sticky=tk.W, pady=5, padx=5)
#         self.button_var = tk.StringVar()
#         ttk.Combobox(self.mouse_frame, textvariable=self.button_var, 
#                     values=["Button.left", "Button.right", "Button.middle"]).grid(
#                     row=2, column=1, sticky=tk.W+tk.E, pady=5)
        
#         # Keyboard event fields
#         self.key_frame = ttk.LabelFrame(details_frame, text="Keyboard Event")
#         self.key_frame.grid(row=3, column=0, columnspan=2, sticky=tk.W+tk.E, pady=5)
        
#         ttk.Label(self.key_frame, text="Key:").grid(row=0, column=0, sticky=tk.W, pady=5, padx=5)
#         self.key_var = tk.StringVar()
#         self.key_entry = ttk.Entry(self.key_frame, textvariable=self.key_var)
#         self.key_entry.grid(row=0, column=1, sticky=tk.W+tk.E, pady=5)
        
#         # Buttons for actions
#         button_frame = ttk.Frame(details_frame)
#         button_frame.grid(row=4, column=0, columnspan=2, sticky=tk.W+tk.E, pady=10)
        
#         ttk.Button(button_frame, text="Apply Changes", command=self.apply_changes).pack(side=tk.LEFT, padx=5)
#         ttk.Button(button_frame, text="Add New Event", command=self.add_event).pack(side=tk.LEFT, padx=5)
#         ttk.Button(button_frame, text="Delete Event", command=self.delete_selected_event).pack(side=tk.LEFT, padx=5)
        
#         # Status bar
#         self.status_var = tk.StringVar()
#         self.status_var.set("Ready")
#         self.status_bar = ttk.Label(self.root, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W)
#         self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
#         # Initially hide the specific event frames
#         self.update_form_fields()
    
#     def update_form_fields(self, event=None):
#         """Show/hide form fields based on the selected event type"""
#         event_type = self.event_type_var.get()
        
#         if event_type in ["mouse_down", "mouse_up"]:
#             self.mouse_frame.grid()
#             self.key_frame.grid_remove()
#         elif event_type in ["key_press", "key_release"]:
#             self.mouse_frame.grid_remove()
#             self.key_frame.grid()
#         else:
#             # Default or empty selection
#             self.mouse_frame.grid_remove()
#             self.key_frame.grid_remove()
    
#     def open_file(self):
#         """Open a JSON file using file dialog"""
#         if self.modified:
#             if not messagebox.askyesno("Unsaved Changes", "You have unsaved changes. Do you want to continue?"):
#                 return
        
#         file_path = filedialog.askopenfilename(
#             title="Open JSON File",
#             filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
#         )
        
#         if not file_path:
#             return
        
#         try:
#             with open(file_path, 'r') as file:
#                 self.events_data = json.load(file)
            
#             self.current_file_path = file_path
#             self.update_event_list()
#             self.modified = False
#             self.status_var.set(f"Opened: {file_path}")
#         except Exception as e:
#             messagebox.showerror("Error", f"Failed to open file: {str(e)}")
    
#     def save_file(self, event=None):
#         """Save the current data to the opened file"""
#         if not self.current_file_path:
#             return self.save_file_as()
        
#         try:
#             with open(self.current_file_path, 'w') as file:
#                 json.dump(self.events_data, file, indent=4)
            
#             self.modified = False
#             self.status_var.set(f"Saved to: {self.current_file_path}")
#             return True
#         except Exception as e:
#             messagebox.showerror("Error", f"Failed to save file: {str(e)}")
#             return False
    
#     def save_file_as(self, event=None):
#         """Save the current data to a new file"""
#         file_path = filedialog.asksaveasfilename(
#             title="Save JSON File As",
#             defaultextension=".json",
#             filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
#         )
        
#         if not file_path:
#             return False
        
#         self.current_file_path = file_path
#         return self.save_file()
    
#     def exit_application(self):
#         """Exit the application with confirmation if there are unsaved changes"""
#         if self.modified:
#             if not messagebox.askyesno("Unsaved Changes", "You have unsaved changes. Do you want to exit anyway?"):
#                 return
        
#         self.root.destroy()
    
#     def update_event_list(self):
#         """Update the event list treeview with current data"""
#         # Clear existing items
#         for item in self.event_tree.get_children():
#             self.event_tree.delete(item)
        
#         # Add events to the treeview
#         for i, event in enumerate(self.events_data):
#             self.event_tree.insert("", tk.END, text=str(i), 
#                                 values=(event.get("type", ""), f"{event.get('time', 0):.2f}"))
    
#     def on_event_select(self, event):
#         """Handle event selection in the treeview"""
#         selection = self.event_tree.selection()
#         if not selection:
#             return
        
#         # Get the selected item index
#         item_id = selection[0]
#         index = int(self.event_tree.item(item_id, "text"))
#         self.selected_event_index = index
        
#         # Load the selected event data into the form
#         self.load_event_data(self.events_data[index])
    
#     def load_event_data(self, event_data):
#         """Load event data into the form fields"""
#         # Set event type
#         event_type = event_data.get("type", "")
#         self.event_type_var.set(event_type)
        
#         # Set time
#         self.time_var.set(str(event_data.get("time", "")))
        
#         # Set mouse-specific fields
#         if event_type in ["mouse_down", "mouse_up"]:
#             self.x_var.set(str(event_data.get("x", "")))
#             self.y_var.set(str(event_data.get("y", "")))
#             self.button_var.set(event_data.get("button", "Button.left"))
        
#         # Set keyboard-specific fields
#         elif event_type in ["key_press", "key_release"]:
#             self.key_var.set(event_data.get("key", ""))
        
#         # Update form visibility
#         self.update_form_fields()
    
#     def apply_changes(self):
#         """Apply the form changes to the selected event"""
#         if self.selected_event_index is None:
#             messagebox.showinfo("No Selection", "Please select an event first.")
#             return
        
#         try:
#             event_type = self.event_type_var.get()
#             time_value = float(self.time_var.get())
            
#             # Create a new event object
#             event_data = {
#                 "type": event_type,
#                 "time": time_value
#             }
            
#             # Add type-specific fields
#             if event_type in ["mouse_down", "mouse_up"]:
#                 event_data["x"] = int(self.x_var.get())
#                 event_data["y"] = int(self.y_var.get())
#                 event_data["button"] = self.button_var.get()
#             elif event_type in ["key_press", "key_release"]:
#                 event_data["key"] = self.key_var.get()
            
#             # Update the event data
#             self.events_data[self.selected_event_index] = event_data
#             self.update_event_list()
#             self.modified = True
            
#             # Update status
#             self.status_var.set("Changes applied. Don't forget to save.")
        
#         except ValueError as e:
#             messagebox.showerror("Invalid Value", "Please enter valid numeric values for time, x, and y.")
    
#     def add_event(self):
#         """Add a new event to the data"""
#         # Create a default new event
#         new_event = {
#             "type": "mouse_down",
#             "x": 0,
#             "y": 0,
#             "button": "Button.left",
#             "time": 0.0
#         }
        
#         self.events_data.append(new_event)
#         self.update_event_list()
#         self.modified = True
        
#         # Select the new event
#         self.selected_event_index = len(self.events_data) - 1
#         last_item = self.event_tree.get_children()[-1]
#         self.event_tree.selection_set(last_item)
#         self.event_tree.see(last_item)
#         self.load_event_data(new_event)
        
#         # Update status
#         self.status_var.set("New event added. Don't forget to save.")
    
#     def delete_selected_event(self):
#         """Delete the selected event"""
#         if self.selected_event_index is None:
#             messagebox.showinfo("No Selection", "Please select an event first.")
#             return
        
#         if messagebox.askyesno("Confirm Deletion", "Are you sure you want to delete this event?"):
#             del self.events_data[self.selected_event_index]
#             self.update_event_list()
#             self.selected_event_index = None
#             self.modified = True
            
#             # Update status
#             self.status_var.set("Event deleted. Don't forget to save.")

# def main():
#     root = tk.Tk()
#     app = JSONEventEditor(root)
#     root.protocol("WM_DELETE_WINDOW", app.exit_application)
#     root.mainloop()

# if __name__ == "__main__":
#     main()