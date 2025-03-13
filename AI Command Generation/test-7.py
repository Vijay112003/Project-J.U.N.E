import pandas as pd
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from sklearn.feature_extraction.text import TfidfVectorizer
import string
import os
import screen_brightness_control as sbc
from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume
from comtypes import CLSCTX_ALL
import spacy
import re

# Load the English NLP model
nlp = spacy.load("en_core_web_sm")

# Sample dataset: user commands and corresponding labels
data = {
    "command": [
        "set brightness to 50%", "reduce brightness to 20%", "increase screen light",
        "set volume to 50%", "mute audio", "increase sound",
        "shutdown my computer", "restart PC", "log off user",
        "turn off WiFi", "disable internet", "disconnect WiFi"
    ],
    "label": [
        "brightness", "brightness", "brightness",
        "volume", "volume", "volume",
        "shutdown", "shutdown", "shutdown",
        "wifi", "wifi", "wifi"
    ]
}

df = pd.DataFrame(data)

# Download stopwords
nltk.download("stopwords")
nltk.download("punkt")

stop_words = set(stopwords.words("english"))

# Function to preprocess text
def preprocess_text(text):
    text = text.lower()  # Lowercase
    text = text.translate(str.maketrans("", "", string.punctuation))  # Remove punctuation
    words = word_tokenize(text)  # Tokenization
    words = [word for word in words if word not in stop_words]  # Remove stopwords
    return " ".join(words)

df["command"] = df["command"].apply(preprocess_text)

vectorizer = TfidfVectorizer()
X = vectorizer.fit_transform(df["command"])  # Convert text to vectors
y = df["label"]  # Labels

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train classifier
clf = LogisticRegression()
clf.fit(X_train, y_train)

# Test classifier
y_pred = clf.predict(X_test)
print("Accuracy:", accuracy_score(y_test, y_pred))

# Class for handling brightness
class Brightness:
    def set_brightness(self, level):
        level = int(level)  # Ensure level is an integer
        sbc.set_brightness(level)

    def increase_brightness(self):
        brg = sbc.get_brightness(display=0)[0]
        sbc.set_brightness(min(brg + 10, 100))  # Prevent exceeding 100

    def decrease_brightness(self):
        brg = sbc.get_brightness(display=0)[0]
        sbc.set_brightness(max(brg - 10, 0))  # Prevent going below 0

# Class for handling volume
class Volume:
    def __init__(self):
        devices = AudioUtilities.GetSpeakers()
        interface = devices.Activate(IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
        self.volume = interface.QueryInterface(IAudioEndpointVolume)

    def get_volume(self):
        return self.volume.GetMasterVolumeLevelScalar() * 100

    def set_volume(self, level):
        level = float(level) / 100  # Convert percentage to decimal
        self.volume.SetMasterVolumeLevelScalar(level, None)

    def increase_volume(self):
        current_vol = self.get_volume() / 100
        self.volume.SetMasterVolumeLevelScalar(min(current_vol + 0.1, 1.0), None)  # Max limit 100%

    def decrease_volume(self):
        current_vol = self.get_volume() / 100
        self.volume.SetMasterVolumeLevelScalar(max(current_vol - 0.1, 0.0), None)  # Min limit 0%

# Extract information from command
def extract_info(command):
    doc = nlp(command)

    action = None
    keyword = None
    value = None

    # Extracting verb (action) and noun (keyword)
    for token in doc:
        if token.pos_ == "VERB":  # Look for action (e.g., "set")
            action = token.text
        elif token.pos_ in ["NOUN", "PROPN"] and not re.search(r'[%$@!]', token.text):
            keyword = token.text

    # Extract numbers (like "50%")
    match = re.search(r'\d+', command)
    if match:
        value = match.group()

    return {"action": action, "keyword": keyword, "value": value}

# Handle brightness commands
def brightness_handle(action, keyword, value, brightness):
    if value:
        value = int(value)
    
    if action == "set" and value is not None:
        brightness.set_brightness(value)
    elif action in ["increase", "raise", "up"]:
        brightness.increase_brightness()
    elif action in ["decrease", "reduce", "down"]:
        brightness.decrease_brightness()
    else:
        print("Unknown brightness command!")

# Handle volume commands
def volume_handle(action, keyword, value, volume):
    if value:
        value = int(value)
    
    if action == "set" and value is not None:
        volume.set_volume(value)
    elif action in ["increase", "raise", "up"]:
        volume.increase_volume()
    elif action in ["decrease", "reduce", "down"]:
        volume.decrease_volume()
    else:
        print("Unknown volume command!")

# Execute command
def execute_command(command, brightness, volume):
    info = extract_info(command)
    processed_command = preprocess_text(command)
    command_vector = vectorizer.transform([processed_command])
    label = clf.predict(command_vector)[0]

    if label == "brightness":
        brightness_handle(info["action"], info["keyword"], info["value"], brightness)
    elif label == "volume":
        volume_handle(info["action"], info["keyword"], info["value"], volume)
    elif label == "shutdown":
        os.system("shutdown /s /t 0")
    elif label == "wifi":
        print("WiFi toggle not implemented yet.")
    else:
        print("Unknown command!")

# Create instances of the classes
brightness = Brightness()
volume = Volume()

# Get user input and execute
user_input = input("Enter your command: ")
execute_command(user_input, brightness, volume)
