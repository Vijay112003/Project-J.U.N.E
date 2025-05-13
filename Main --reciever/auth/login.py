import tkinter as tk
from tkinter import ttk, messagebox
import json
import requests
import sqlite3
import os

class LoginInterface:
    def __init__(self, parent=None, on_login_success=None):
        self.api_url = "https://june-backend-fckl.onrender.com/api/login"
        self.on_login_success = on_login_success
        self.token = None
        self.db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "june.db")
        
        # Initialize root/window first
        if parent:
            self.root = tk.Toplevel(parent)
        else:
            self.root = tk.Tk()
        
        # Check token after window creation
        self.init_db()
        if self.check_existing_token():
            self.root.destroy()
            return
            
        # Continue with window setup
        self.root.title("J.U.N.E Login")
        self.root.geometry("400x350")
        self.root.resizable(False, False)
        
        self.setup_styles()
        self.create_widgets()
        
        # Center the window
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f'{width}x{height}+{x}+{y}')
    
    def init_db(self):
        """Initialize the database with tokens table"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tokens (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                token TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
        conn.close()
        
    def save_token(self, token):
        """Save token to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        # Clear existing tokens first
        cursor.execute("DELETE FROM tokens")
        # Insert new token
        cursor.execute("INSERT INTO tokens (token) VALUES (?)", (token,))
        conn.commit()
        conn.close()
        
    def check_existing_token(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT token FROM tokens ORDER BY created_at DESC LIMIT 1")
        result = cursor.fetchone()
        conn.close()
        
        if result and result[0]:
            # If token exists, use it and skip login
            self.root.destroy()
            if self.on_login_success:
                self.on_login_success(result[0])
            return True
        return False

    def setup_styles(self):
        style = ttk.Style(self.root)  # Initialize style with root window
        style.theme_use('clam')
        
        # Configure label styles
        style.configure("Title.TLabel", font=("Segoe UI", 24, "bold"))
        style.configure("TEntry", padding=5)
        
        # Configure button style with explicit colors and padding
        style.configure("Login.TButton",
                        font=("Segoe UI", 11),
                        padding=10)
        
        # Map dynamic states
        style.map("Login.TButton",
                background=[("active", "#0b5ed7"), ("!active", "#0d6efd")],
                foreground=[("active", "white"), ("!active", "white")])

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

        # Login Button - Using tk.Button instead of ttk.Button
        self.login_button = tk.Button(main_frame, 
                                    text="Login",
                                    command=self.login,
                                    font=("Segoe UI", 11),
                                    bg="#0d6efd",
                                    fg="white",
                                    activebackground="#0b5ed7",
                                    activeforeground="white",
                                    padx=20,
                                    pady=10,
                                    relief=tk.RAISED,
                                    cursor="hand2")
        self.login_button.pack(pady=20, fill=tk.X)

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
                self.save_token(self.token)  # Save token to database
                messagebox.showinfo("Success", response_data.get('message', 'Login successful!'))
                self.root.destroy()

                if self.on_login_success:
                    self.on_login_success(self.token)
            else:
                # Show error message
                error_msg = response_data.get('message', 'Login failed. Please try again.')
                messagebox.showerror("Error", error_msg)

        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"Connection error: {str(e)}")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {str(e)}")

    def run(self):
        if not self.check_existing_token():
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