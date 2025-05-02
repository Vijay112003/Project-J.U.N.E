import sqlite3

DB_FILE = "macro_data.db"

def init_db():
    """Initialize the database and create macros table if not exists."""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS macros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            image_path TEXT,
            json_path TEXT
        )
    """)
    conn.commit()
    conn.close()

def save_macro_to_db(name, description, image_path, json_path):
    """Save macro details to the database."""
    init_db()  # Ensure DB is initialized before saving

    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('''
        INSERT INTO macros (name, description, image_path, json_path)
        VALUES (?, ?, ?, ?)
    ''', (name, description, image_path, json_path))
    conn.commit()
    conn.close()

def fetch_all_macros():
    """Fetch all macros from the database."""
    init_db()  # Ensure DB is initialized before fetching
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, image_path, json_path FROM macros")
        rows = cursor.fetchall()
        print(rows)  # Debugging line to check fetched data
        conn.close()
        return rows
    except sqlite3.Error as e:
        print("DB Error:", e)
        return []
