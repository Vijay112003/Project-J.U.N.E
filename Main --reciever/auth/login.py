import tkinter as tk
from tkinter import ttk, messagebox
import json
import requests

class LoginInterface:
    def __init__(self, on_login_success=None):
        self.root = tk.Tk()
        self.root.title("J.U.N.E Login")
        self.root.geometry("400x300")
        self.root.resizable(False, False)
        
        self.api_url = "https://june-backend-fckl.onrender.com/api/login"
        self.on_login_success = on_login_success
        self.token = None
        self.setup_styles()
        self.create_widgets()
        
        # Center the window
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f'{width}x{height}+{x}+{y}')

    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('clam')
        style.configure("Title.TLabel", font=("Segoe UI", 24, "bold"))
        style.configure("TEntry", padding=5)
        style.configure("Login.TButton", 
                       font=("Segoe UI", 11),
                       padding=10)

    def create_widgets(self):
        # Main container
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Title
        title_label = ttk.Label(main_frame, text="J.U.N.E", style="Title.TLabel")
        title_label.pack(pady=(0, 20))

        # Email
        email_frame = ttk.Frame(main_frame)
        email_frame.pack(fill=tk.X, pady=5)
        ttk.Label(email_frame, text="Email:").pack(anchor=tk.W)
        self.email_entry = ttk.Entry(email_frame)
        self.email_entry.pack(fill=tk.X, pady=2)

        # Password
        password_frame = ttk.Frame(main_frame)
        password_frame.pack(fill=tk.X, pady=5)
        ttk.Label(password_frame, text="Password:").pack(anchor=tk.W)
        self.password_entry = ttk.Entry(password_frame, show="•")
        self.password_entry.pack(fill=tk.X, pady=2)

        # Login Button
        self.login_button = ttk.Button(main_frame, 
                                     text="Login",
                                     style="Login.TButton",
                                     command=self.login)
        self.login_button.pack(pady=20)

    def login(self):
        email = self.email_entry.get()
        password = self.password_entry.get()

        if not email or not password:
            messagebox.showerror("Error", "Please enter both email and password")
            return

        try:
            # Prepare login data
            login_data = {
                "email": email,
                "password": password
            }

            # Make API request
            response = requests.post(self.api_url, json=login_data)
            response_data = response.json()

            if response.status_code == 200:
                # Store the token
                self.token = response_data.get('token')
                messagebox.showinfo("Success", response_data.get('message', 'Login successful!'))
                
                if self.on_login_success:
                    # Pass token to callback
                    self.on_login_success(self.token)
                self.root.destroy()
            else:
                # Show error message
                error_msg = response_data.get('message', 'Login failed. Please try again.')
                messagebox.showerror("Error", error_msg)

        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Connection error: {str(e)}")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {str(e)}")

    def run(self):
        try:
            self.root.mainloop()
        except KeyboardInterrupt:
            print("\nShutting down gracefully...")
            if self.root and self.root.winfo_exists():
                self.root.quit()
                self.root.destroy()
            sys.exit(0)

if __name__ == "__main__":
    def on_success(token):
        print(f"Login successful! Token: {token}")

    login = LoginInterface(on_login_success=on_success)
    login.run()