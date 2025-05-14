import sqlite3
import os

DB_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), "june.db")

def init_db():
    """Initialize the database and create macros table if not exists."""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS macros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            json_path TEXT
        )
    """)
    conn.commit()
    conn.close()

def save_macro_to_db(name, description, json_path):
    """Save macro details to the database."""
    init_db()  # Ensure DB is initialized before saving

    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('''
        INSERT INTO macros (name, description, json_path)
        VALUES (?, ?, ?)
    ''', (name, description, json_path))
    conn.commit()
    conn.close()

def fetch_all_macros():
    """Fetch all macros from the database."""
    init_db()
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, json_path FROM macros")
        rows = cursor.fetchall()
        conn.close()
        return rows
    except sqlite3.Error as e:
        print("DB Error:", e)
        return []

if __name__ == "__main__":
    macros = fetch_all_macros()
    print(macros)
